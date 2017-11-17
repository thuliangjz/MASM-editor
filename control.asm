.486
.model flat, stdcall
option casemap:none

include edit_handler.inc
include view_handler.inc
include command_handler.inc
include ui.inc

includelib msvcrt.lib
includelib masm32.lib
includelib kernel32.lib

.data

MODE_VIEW equ <0>
MODE_EDIT equ <1>
MODE_COMMAND equ <2>

CURSOR_HIGI equ 100
CURSOR_LOW equ 10

text_list LinkedList <>
input KEY_INPUT <>
hNewScreenBuffer HANDLE ?
hStdout HANDLE ?
_status DWORD MODE_VIEW
_show_command_result DWORD FALSE
_cursor_info CONSOLE_CURSOR_INFO <CURSOR_HIGI , TRUE>
.code
    Dispatch PROTO STDCALL user_input:KEY_INPUT

Render PROC
    LOCAL command_pos:COORD
    LOCAL count_write:DWORD
    LOCAL cursor_pos:COORD
    mov command_pos.x, 0
    mov_m2m command_pos.y, window_size.y
    invoke DrawText
    .IF _status == MODE_VIEW
        .IF _show_command_result == TRUE
            ;绘制命令处理结果
            lea eax, count_write
            invoke WriteConsoleOutputCharacter, hNewScreenBuffer, 
                addr process_result, process_result_length,
                DWORD PTR[command_pos], eax
        .ENDIF
        mov_m2m cursor_pos.x, cursor_position_ui.x
        mov_m2m cursor_pos.y, cursor_position_ui.y
    .ELSEIF _status == MODE_EDIT
        mov_m2m cursor_pos.x, cursor_position_ui.x
        mov_m2m cursor_pos.y, cursor_position_ui.y
    .ELSE
        mov eax, console_cursor_index
        mov cursor_pos.x, ax
        mov_m2m cursor_pos.y, window_size.y
        lea eax, count_write
        invoke WriteConsoleOutputCharacter, hNewScreenBuffer,addr console_input_string,
            console_input_string_length, DWORD PTR [command_pos], eax
    .ENDIF
        invoke SetConsoleCursorPosition, hNewScreenBuffer, DWORD PTR [cursor_pos]
        ret
Render ENDP

Dispatch PROC, user_input:KEY_INPUT
    .IF _status == MODE_VIEW
        .IF user_input.is_special == FALSE && user_input.ascii_char == 'i'
            ;转为编辑状态
            mov _status, MODE_EDIT
            ;设定光标大小
            mov _cursor_info.dwSize, CURSOR_LOW
            invoke SetConsoleCursorInfo, hNewScreenBuffer, addr _cursor_info
            ;消除命令结果展示
            mov _show_command_result, FALSE
        .ELSEIF user_input.is_special == FALSE && user_input.ascii_char == ':'
            ;转为命令状态
            mov _status, MODE_COMMAND
            invoke InitCommandHandler
            mov _show_command_result, TRUE
            mov _cursor_info.dwSize, CURSOR_LOW
            invoke SetConsoleCursorInfo, hNewScreenBuffer, addr _cursor_info
        .ELSE
            invoke ViewKeyHandler, user_input
        .ENDIF
    .ELSEIF _status == MODE_EDIT
        .IF user_input.virtual_key == VK_ESCAPE
            ;返回浏览模式
            mov _status, MODE_VIEW
            mov _cursor_info.dwSize, CURSOR_HIGI
            invoke SetConsoleCursorInfo, hNewScreenBuffer, addr _cursor_info
        .ELSE
            invoke EditHandler, user_input
        .ENDIF
    .ELSE
        ;命令处理状态
        .IF user_input.virtual_key == VK_ESCAPE
            mov _status, MODE_VIEW
            mov _cursor_info.dwSize, CURSOR_HIGI
            invoke SetConsoleCursorInfo, hNewScreenBuffer, addr _cursor_info
            mov _show_command_result, FALSE
       .ELSE
            invoke CommandHandler, user_input
            .IF user_input.virtual_key == VK_RETURN
                mov _status, MODE_VIEW
                mov _cursor_info.dwSize, CURSOR_HIGI
                invoke SetConsoleCursorInfo, hNewScreenBuffer, addr _cursor_info
            .ENDIF
       .ENDIF
    .ENDIF
    ;绘制部分
    invoke Render
    ret
Dispatch ENDP

start:
    invoke InitList, addr text_list
    ;创建新屏幕
    invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov hStdout, eax
	invoke CreateConsoleScreenBuffer, GENERIC_READ + GENERIC_WRITE,	FILE_SHARE_READ + FILE_SHARE_WRITE, 0, CONSOLE_TEXTMODE_BUFFER, 0
	mov hNewScreenBuffer, eax
	invoke SetConsoleActiveScreenBuffer, hNewScreenBuffer
	invoke UIInit, hNewScreenBuffer
    invoke InitInputQueue
    ;文档链表初始化
    invoke InitList, addr text_list
    mov_m2m text_list.currentNode, text_list.head
    ;创建一个空的行
    invoke InsertNode, addr text_list
    ;光标初始化
    mov cursor_position_ui.x, 0
    mov cursor_position_ui.y, 0
    mov eax, text_list.head
    mov_m2m cursor_position_logic.p_node, (Node PTR [eax]).next
    mov cursor_position_logic.index_char, 0
    invoke SetConsoleCursorInfo, hNewScreenBuffer, addr _cursor_info
    ;工作循环
    loop_work:
        invoke GetUserKeyInput
        invoke PopInputQueue, addr input
        invoke Dispatch, input
        jmp loop_work
    invoke ExitProcess, 0
END start