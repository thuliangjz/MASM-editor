.486
.model flat, stdcall
option casemap:none

include ui.inc
include utils.inc
.data
window_size COORD <>
cursor_position_ui COORD <>
cursor_position_logic CURSOR_POSITION_LOGIC <> 
_screen_buffer_info CONSOLE_SCREEN_BUFFER_INFO <>
window_width_max = 128
window_height_max = 64
blank_line_command equ <2>
_drawn_text_array BYTE window_height_max * window_width_max DUP ('?')
_hOutputBuffer HANDLE ?
_count_text_screen DWORD ?;max number of text print on screen
.code
UIInit PROC, hScreenBuffer:HANDLE
	invoke GetConsoleScreenBufferInfo, hScreenBuffer, addr _screen_buffer_info
	mov_m2m window_size.x, _screen_buffer_info.srWindow.Right
	mov_m2m window_size.y, _screen_buffer_info.srWindow.Bottom
	inc window_size.x
	inc window_size.y
	mov_m2m _hOutputBuffer, hScreenBuffer
	mov ax, window_size.y
	sub ax, blank_line_command
	mul window_size.x
	mov _count_text_screen, eax
	ret
UIInit ENDP

DrawText PROC	;may use global varibles in ui.inc as parameters
	LOCAL idx_line_tmp:DWORD, node_tmp:DWORD, length_current:DWORD,
		idx_char_tmp:DWORD, width_window:DWORD, height_window:DWORD,
		count_write:DWORD
	;initialization
	movzx eax, cursor_position_ui.y
	mov idx_line_tmp, eax
	movzx eax, window_size.x
	mov width_window, eax
	movzx eax, window_size.y
	mov height_window, eax
	mov_m2m node_tmp, cursor_position_logic.p_node
	mov_m2m length_current, cursor_position_logic.index_char
	;search for node pointer and char index of first character on screen
	;idx_line_tmp should stand for node_tmp's first logical line's line-number on screen at before starting next loop
	loop_search_start:
		;calculate how much (screen) line current node contains
		mov eax, length_current
		mov edx, 0
		div width_window
		sub idx_line_tmp, eax	;update current line
		.IF !SIGN? && idx_line_tmp != 0
			mov ebx, node_tmp
			mov_m2m node_tmp, (Node PTR [ebx]).prev	;update node pointer(forward)	node_tmp = node_tmp->prev
			mov ebx, node_tmp
			mov_m2m length_current, (Node PTR [ebx]).data.dataLength
			dec idx_line_tmp
			jmp loop_search_start
		.ENDIF
		mov eax, idx_line_tmp
		neg eax
		mul width_window
		mov idx_char_tmp, eax	;idx_char_tmp = -idx_line_tmp * width_window
		mov idx_line_tmp, 0
	loop_search_end:
		;copy content to _drawn_text_array
		;copy line by line to avoid buffer overflow when one logical line too long
		mov ebx, node_tmp
		mov_m2m length_current, (Node PTR [ebx]).data.dataLength
		mov edi, OFFSET _drawn_text_array	;init edi
		cld	;copy and increase edi
		output_copy:
			mov eax, length_current
			sub eax, idx_char_tmp
			;ecx contains length of input characters
			;eax contains count of 0 to be filled in current line
			.IF eax >= width_window
				mov ecx, width_window
				mov eax, 0
			.ELSE
				mov ecx, eax	;ecx = length_current - idx_char_tmp
				mov eax, width_window
				sub eax, ecx
			.ENDIF
			mov edx, node_tmp
			mov esi, (Node PTR [edx]).data.string
			add esi, idx_char_tmp
			rep movsb	;copy from text input
			mov ecx, eax
			mov al, 0
			rep stosb	;fill 0
			;modify length_current and idx_char_tmp
			mov eax, idx_char_tmp
			add eax, width_window
			mov idx_char_tmp, eax
			.IF eax >= length_current
				;change to new node
				mov ebx, node_tmp
				mov_m2m node_tmp, (Node PTR [ebx]).next
				mov idx_char_tmp, 0
				mov ebx, node_tmp
				.IF ebx != 0
					mov_m2m length_current, (Node PTR [ebx]).data.dataLength
				.ENDIF
			.ENDIF
			inc idx_line_tmp
			;decide whether to continue
			mov eax, idx_line_tmp
			add eax, blank_line_command
			.IF eax < height_window && node_tmp != 0
				jmp output_copy
			.ENDIF
		;may not fill all output characters due to end of linkList
		mov ecx, edi
		sub ecx, OFFSET _drawn_text_array
		neg ecx
		add ecx, _count_text_screen
		mov al, 0
		rep stosb
		;draw text on screen
		lea eax, count_write
		invoke WriteConsoleOutputCharacter, _hOutputBuffer, 
			addr _drawn_text_array, _count_text_screen,
			0, eax
		ret
DrawText ENDP
END
