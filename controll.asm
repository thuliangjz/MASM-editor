.386                                    ; create 32 bit code
.model flat, stdcall                    ; 32 bit memory model
option casemap :none                    ; case sensitive

include controll.inc
include key_handlers.inc
include input_queue.inc
include ui.inc


includelib masm32.lib
includelib kernel32.lib
includelib msvcrt.lib

endl EQU <0dh, 0ah>

.data
program_status DWORD 0   ;0: watching  1:editing 2:commanding
record_cursor_max_index DWORD 0
text_list:LinkedList

keyInputHandle PROC
    pushad
    invoke GetUserKeyInput
    .if eax == 0
        jmp quit
    .endif

    .if program_status == 0
        ;watching
    .elseif program_status == 1
        ;editing
        invoke EditingStatusHandle
    .else
        ;commanding
    .endif
quit:
    popad
    ret
keyInputHandle ENDP


EditingStatusHandle PROC
    local key_input: KEY_INPUT
    pushad
    invoke PopInputQueue, addr key_input

    .if key_input.is_special == 0
        ;normal char
        invoke NormalKeyDeal, key_input    
    .else
        ;special key
        invoke SpecialKeyDeal, key_input
    .endif





    ;need redraw here
quit:
    popad
    ret



EditingStatusHandle ENDP



NormalKeyDeal PROC, key_input: KEY_INPUT
    pushad

        mov edi, cursor_position_logic.p_node
        mov eax, cursor_position_logic.index_char
        mov esi, (Node PTR [edi]).data
        invoke InsertChar esi, key_input.ascii_char, cursor_position_logic.index_char
        inc cursor_position_logic.index_char
        mov ax, window_size.x
        mov bx, window_size.y
        .if ax == cursor_position_ui.x
            mov cursor_position_ui.x, 0
            .if bx > cursor_position_ui.y
                inc cursor_position_ui.y
            .endif
        .else
            inc cursor_position_ui.x
        .endif

    popad
    ret
NormalKeyDeal ENDP


SpecialKeyDeal PROC, key_input: KEY_INPUT
    pushad
        mov ax, key_input.virtual_key
        .if ax == VK_LEFT
            invoke LeftKeyHandler


        .elseif ax == VK_RIGHT
            invoke RightKeyHandler

        .elseif ax == VK_UP
            invoke UpKeyHandler

        .elseif ax == VK_DOWN
            invoke DownKeyHandler
        .endif

quit:
    popad
    ret
SpecialKeyDeal ENDP

END