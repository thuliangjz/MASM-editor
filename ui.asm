.486
.model flat, stdcall
option casemap:none

include ui.inc
include utils.inc

.data
text_list List <>
window_size COORD <>
cursor_position_ui COORD <>
cursor_position_logic CURSOR_POSITION_LOGIC <> 
_screen_buffer_info CONSOLE_SCREEN_BUFFER_INFO <>
window_width_max = 128
window_height_max = 64
_drawn_text_array BYTE window_height_max * window_width_max DUP (?)
_hOutputBuffer HANDLE ?
_count_char_screen DWORD ?;max number of char print on screen
.code
UIInit PROC, hScreenBuffer:HANDLE
	invoke GetConsoleScreenBufferInfo, hScreenBuffer, addr _screen_buffer_info
	mov_m2m window_size.x, _screen_buffer_info.srWindow.Right
	mov_m2m window_size.y, _screen_buffer_info.srWindow.Bottom
	mov_m2m _hOutputBuffer, hScreenBuffer
	mov ax, window_size.x
	mul window_size.y
	mov _count_char_screen, eax
UIInit ENDP

DrawText PROC	;may use global varibles in ui.inc as parameters
	LOCAL idx_line_tmp:DWORD, node_tmp:DWORD, length_current:DWORD,
		idx_char_tmp:DWORD, width_window:DWORD
	;initialization
	movzx eax, cursor_position_ui.y
	mov idx_line_tmp, eax
	movzx eax, cursor_position_ui.x
	mov width_window, eax
	mov_m2m node_tmp, cursor_position_logic.p_node
	mov_m2m length_current, cursor_position_logic.index_char
	;search for node pointer and char index of first character on screen
	cmp idx_line_tmp, 0
	je loop_search_end	;no need to search
	loop_search_start:
		;calculate how much (screen) line current node contains
		mov eax, length_current
		movzx ebx, window_size.y
		mov edx, 0
		div ebx
		.IF edx == 0
			inc eax
		.ENDIF
		sub idx_line_tmp, eax	;update current line
		.IF idx_line_tmp > 0
			mov ebx, node_tmp
			mov_m2m node_tmp, (Node PTR [ebx]).prev	;update node pointer(forward)
			mov_m2m length_current, (Node PTR [ebx]).data.dataLength
			jmp loop_search_end
		.ENDIF
	loop_search_end:
		mov_m2m idx_char_tmp, idx_line_tmp
		neg idx_char_tmp
		;copy content to _drawn_text_array
		mov ebx, node_tmp
		mov_m2m length_current, (Node PTR [ebx]).data.dataLength
		output_copy:
			mov eax, length_current
			sub eax, idx_char_tmp
			;ecx contains length of input characters
			;eax contains count of 0 to be filled in current line
			.IF eax >= width_window
				mov ecx, width_window
				mov eax, 0
			.ELSE
				mov ecx, length_current
				sub ecx, idx_char_tmp
				mov eax, width_window
				sub eax, ecx
			.ENDIF
DrawText ENDP
