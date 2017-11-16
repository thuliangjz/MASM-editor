.486
.model flat, stdcall
option casemap:none

include input_queue.inc

PushKeyInput PROTO p_key_input:DWORD
.data
size_que equ <128>
_raw_input_que INPUT_RECORD 128 DUP (<>)
_user_input_que KEY_INPUT size_que DUP (<>)
_std_in HANDLE ?
_count_event_read DWORD ?
_que_head DWORD 0
_que_tail DWORD 0
.code
GetUserKeyInput PROC
	LOCAL flag_success:DWORD
	get_raw_input:
		invoke ReadConsoleInput, _std_in, addr _raw_input_que, LENGTHOF _raw_input_que, addr _count_event_read
		mov ecx, _count_event_read
		mov flag_success, 0
		mov esi, OFFSET _raw_input_que
		loop_start:
			cmp (INPUT_RECORD PTR [esi]).EventType, KEY_EVENT
			jne loop_prepare
			;只处理按下时的事件
			cmp (INPUT_RECORD PTR [esi]).KeyEvent.bKeyDown, TRUE
			jne loop_prepare
			;特定的键不要
			mov bx, (INPUT_RECORD PTR [esi]).KeyEvent.wVirtualKeyCode
			cmp bx, VK_SHIFT
			je loop_prepare
			cmp bx, VK_CONTROL
			je loop_prepare
			cmp bx, VK_LSHIFT
			je loop_prepare
			cmp bx, VK_RSHIFT
			je loop_prepare
			cmp bx, VK_LCONTROL
			je loop_prepare
			cmp bx, VK_RCONTROL
			je loop_prepare
			;不要F1~F20
			.IF bx >= 070h && bx <= 087h
				jmp loop_prepare
			.ENDIF
			;将记录放入队列
			invoke PushKeyInput, esi
			mov flag_success, TRUE
		loop_prepare:
			add esi, SIZEOF INPUT_RECORD
			loop loop_start
		;如果没有有效的字符则继续读取
		cmp flag_success, TRUE
		jne get_raw_input
		ret
GetUserKeyInput ENDP

InitInputQueue PROC
	invoke GetStdHandle, STD_INPUT_HANDLE
	mov _std_in, eax
	ret
InitInputQueue ENDP

PushKeyInput PROC USES eax ebx edi, p_key_input:DWORD
	LOCAL is_special:DWORD
	;检验是否为特殊字符
	mov ebx, p_key_input
	mov ax, (INPUT_RECORD PTR [ebx]).KeyEvent.wVirtualKeyCode
	.IF (ax >= VK_LEFT && ax <= VK_DOWN) || (ax == VK_BACK) || (ax == VK_DELETE) || (ax == VK_DELETE)
		mov is_special, TRUE
	.ELSE
		mov is_special, FALSE
	.ENDIF
	;赋值
	mov edi, OFFSET _user_input_que
	add edi, _que_tail
	mov ebx, is_special
	mov (KEY_INPUT PTR [edi]).is_special, ebx
	mov eax, p_key_input
	mov bx, (INPUT_RECORD PTR [eax]).KeyEvent.wVirtualKeyCode
	mov (KEY_INPUT PTR [edi]).virtual_key, bx
	mov bh, (INPUT_RECORD PTR [eax]).KeyEvent.AsciiChar
	mov (KEY_INPUT PTR [edi]).ascii_char, bh
	;更新队列指针
	add _que_tail, SIZEOF KEY_INPUT
	mov eax, SIZEOF _user_input_que
	.IF (eax <= _que_tail)
		mov _que_tail, 0
	.ENDIF
	ret
PushKeyInput ENDP
PeekInputQueue PROC USES esi ebx, p_key_input:DWORD
	mov eax, _que_head
	.IF eax == _que_tail
		mov eax, 1
		ret
	.ENDIF
	mov esi, OFFSET _user_input_que
	add esi, _que_head
	mov eax, p_key_input
	mov ebx, (KEY_INPUT PTR [esi]).is_special
	mov (KEY_INPUT PTR [esi]).is_special, ebx
	mov bx, (KEY_INPUT PTR [esi]).virtual_key
	mov (KEY_INPUT PTR [eax]).virtual_key, bx
	mov bh, (KEY_INPUT PTR [esi]).ascii_char
	mov (KEY_INPUT PTR [eax]).ascii_char, bh
	mov eax, 0
	ret
PeekInputQueue ENDP

PopInputQueue PROC, p_key_input:DWORD
	invoke PeekInputQueue, p_key_input
	.IF eax == 1
		ret
	.ENDIF
	;如果成功则更新头指针
	add _que_head, SIZEOF KEY_INPUT
	.IF _que_head > SIZEOF _user_input_que
		mov _que_head, 0
	.ENDIF
	ret
PopInputQueue ENDP
END
