.486
.model flat, stdcall
option casemap:none

include command_handler.inc
include msvcrt.inc
MAXLENGTH = 128 ; max length of a console input

.data
key_input KEY_INPUT <>
console_input_string_length DWORD 0 ; current string length
console_cursor_index DWORD 0 ; console cursor index
console_input_string BYTE MAXLENGTH + 1 DUP(?) ; inpur string

process_result BYTE MAXLENGTH DUP (?)
process_result_length DWORD ?

_command_arg BYTE MAXLENGTH DUP(?)
_response_file_save BYTE 'file saved as %s', 0
_response_file_open BYTE 'open file %s', 0
_response_unknow_command BYTE 'unknown command', 0
.code

InitCommandHandler PROTO
AddACharFromConsole PROTO
AdjustDirectionLeft PROTO
AdjustDirectionRight PROTO
CommandBackHandler PROTO
CommandDeleteHandler PROTO
ProcessCommand PROTO
CopyArg PROTO
;分发函数 判断字符的类型
; case 1:是 "enter"键
; case 2:是 左键或者右键
; case 3:是 可接收的字符
; case 4:其它字符，忽略

InitCommandHandler PROC
	mov console_cursor_index, 0
	mov console_input_string_length, 0
	ret
InitCommandHandler ENDP

CommandHandler PROC user_input:KEY_INPUT
; 不是特殊按键,是可以添加的字符
	mov_m2m key_input.is_special, user_input.is_special
	mov_m2m key_input.virtual_key, user_input.virtual_key
	mov al, user_input.ascii_char
	mov key_input.ascii_char, al
	.IF (key_input.is_special == 0)
		Invoke AddACharFromConsole
	; 是特殊按键
	.ELSE
		;是左键
		.IF(key_input.virtual_key == VK_LEFT)
			Invoke AdjustDirectionLeft
		;是右键
		.ELSEIF(key_input.virtual_key == VK_RIGHT)
			Invoke AdjustDirectionRight
		; 是Backspace键
		.ELSEIF(key_input.virtual_key == VK_BACK)
			Invoke CommandBackHandler
		; 是delete键
		.ELSEIF(key_input.virtual_key == VK_DELETE)
			Invoke CommandDeleteHandler
		;是Enter键
		.ELSEIF(key_input.virtual_key == VK_RETURN)
			Invoke ProcessCommand
		.ENDIF
	.ENDIF
	ret
CommandHandler ENDP

; case 2:是 左键,调整逻辑鼠标位
AdjustDirectionLeft PROC
	.IF console_cursor_index != 0
		dec console_cursor_index
	.ENDIF
	ret
AdjustDirectionLeft ENDP

; case 3:是 右键,调整逻辑鼠标位
AdjustDirectionRight PROC
	mov ebx,console_cursor_index
	.IF(ebx != console_input_string_length)
		inc console_cursor_index
	.ENDIF
	ret
AdjustDirectionRight ENDP

; backspace 键逻辑
CommandBackHandler PROC
	mov ebx,console_input_string_length
	; 在最开头
	.IF(console_cursor_index == 0)
		ret
	; 若否
	.ELSE
		mov edi, OFFSET console_input_string
		add edi, console_cursor_index
		dec edi
		mov esi, edi
		inc esi
		mov ecx, console_input_string_length
		sub ecx, console_cursor_index
		cld
		rep movsb
		dec console_input_string_length
		dec console_cursor_index
	comment~
		; 在末位加0	
		mov esi, OFFSET console_input_string
		add esi, console_input_string_length
		mov BYTE PTR [esi], 0
	~
	.ENDIF
	ret
CommandBackHandler ENDP


; delete 键逻辑
CommandDeleteHandler PROC
	mov ebx,console_input_string_length
	; 在最右端,无法删除
	.IF(ebx == console_cursor_index )
		ret
	.ELSE
		mov edi,OFFSET console_input_string
		add edi,console_cursor_index
		mov esi,edi
		inc esi
		mov ecx,console_input_string_length
		sub ecx,console_cursor_index
		dec ecx
		cld
		rep movsb
		dec console_input_string_length
		; 补 0
		mov esi, OFFSET console_input_string
		add esi, console_input_string_length
		mov BYTE PTR [esi], 0
	.ENDIF
	ret
CommandDeleteHandler ENDP

; case 4:是 可接收的字符	
AddACharFromConsole PROC

	mov ebx,console_cursor_index
	.IF console_input_string_length == MAXLENGTH
		ret
	.ELSE
		; 把在index和length之间的字符全部后移一位
		mov esi, OFFSET console_input_string
		add esi, console_input_string_length
		mov edi, esi
		dec esi
		mov ecx, console_input_string_length
		sub ecx, console_cursor_index
		std
		rep movsb
		; 插入要插的那个字符
		mov esi, OFFSET console_input_string
		add esi, console_cursor_index
		mov [esi],al	

		; 鼠标位置与输入字符串长度均+1
		inc console_input_string_length
		inc console_cursor_index
	.ENDIF
	ret
AddACharFromConsole ENDP

; 接收到enter键，去处理指令,要去实现的命令如下
; :w     将缓冲区写入文件，即保存修改,参数表示文件名
; :q     退出，如果对缓冲区进行过修改，则会提示
; :e     打开文件
ProcessCommand PROC
	; 单指令 w 和 q
	mov esi, OFFSET console_input_string
	.IF (BYTE PTR [esi]) == 'w'
		invoke CopyArg
		;调用保存函数
		invoke WriteListToFile, addr _command_arg
		pushad
		invoke crt_sprintf, addr process_result, addr _response_file_save, OFFSET _command_arg
		invoke crt_strlen, addr process_result
		mov process_result_length, eax
		popad	
	.ELSEIF (BYTE PTR [esi]) == 'e'
		invoke CopyArg
		;调用打开函数
		invoke DestroyList, addr text_list
		invoke ReadFileToList, addr _command_arg
		pushad
		invoke crt_sprintf, addr process_result, addr _response_file_open, OFFSET _command_arg
		invoke crt_strlen, addr process_result
		mov process_result_length, eax
		popad
	.ELSEIF BYTE PTR [esi] == 'q'
		;直接退出
		invoke ExitProcess, 0
	.ELSE
		pushad
			invoke crt_sprintf, addr process_result, addr _response_unknow_command
			invoke crt_strlen, addr process_result
			mov process_result_length, eax
		popad
	.ENDIF
	ret
ProcessCommand ENDP

CopyArg PROC
	mov edi, OFFSET _command_arg
	mov esi, OFFSET console_input_string
	add esi, 2	;假定命令从第二个起
	mov ecx, console_input_string_length
	sub ecx, 2
	rep movsb
	mov BYTE PTR [edi], 0
	ret
CopyArg ENDP

END