.486                                    ; create 32 bit code
.model flat, stdcall                    ; 32 bit memory model
option casemap :none                    ; case sensitive

include linkedList.inc
include ui.inc
include controll.inc
include key_handlers.inc

includelib masm32.lib
includelib kernel32.lib
includelib msvcrt.lib

UpKeyHandler PROC 
    pushad
        mov edi, cursor_position_logic.p_node
        mov esi, (Node PTR [edi]).prev
        mov ebx, (Node PTR [esi]).prev
        .if ebx == NULL
        ; previous node is head
            jmp quit
        .endif
        mov cursor_position_logic.p_node, esi
        mov ecx, cursor_position_logic.index_char
        .if ecx < record_cursor_max_index
            mov ecx, record_cursor_max_index
        .else
            mov record_cursor_max_index, ecx
        .endif
        .if (Node PTR [esi]).datalength >= ecx
            mov cursor_position_logic.index_char, ecx
        .else
            mov ecx, (Node PTR [esi]).datalength
            mov cursor_position_logic.index_char, ecx
        .endif
    popad
    ret
UpKeyHandler ENDP

LeftKeyHandler PROC 
    pushad

        mov record_cursor_max_index, 0
        .if cursor_position_logic.index_char > 0
        ;if cursor isn't at the beginning of logic line
            dec cursor_position_logic.index_char 
            .if cursor_position_ui.x > 0
                dec cursor_position_ui.x
            .else
                mov bx, window_size.x
                dec bx
                mov cursor_position_ui.x, bx
                .if cursor_position_ui.y > 0
                    dec cursor_position_ui.y
                .endif
            .endif
        .else
        ;if cursor is at the beginning of logic line            
            mov edi, cursor_position_logic.p_node
            mov esi, (Node PTR [edi]).prev
            mov ebx, (Node PTR [esi]).prev
            .if ebx == NULL
            ;if prevnode is head
                jmp quit
            .endif
            mov cursor_position_logic.p_node, esi
            mov ebx, (Node PTR [esi]).data.datalength
            dec ebx ;ebx = datalength - 1
            mov cursor_position_logic.index_char, ebx ;index_char = prevnode->length - 1
            
            movzx ecx, window_size.x
            pushad
                mov edx, 0
                mov eax, ebx                         
                div ecx                             ;cursor_position_ui.x = (datalength - 1) % window_size.x
                mov cursor_position_ui.x, dx    
            popad
            .if cursor_position_ui.y > 0
                dec cursor_position_ui.y
            .endif

        .endif

    popad
    ret
LeftKeyHandler ENDP

RightKeyHandler PROC 
    pushad
        mov record_cursor_max_index, 0
        mov edi, cursor_position_logic.p_node
        mov ebx, (Node PTR [edi]).data.datalength
        dec ebx ;ebx = datalength - 1

        .if cursor_position_logic.index_char < ebx
        ;if cursor isn't at the end of logic line
            inc cursor_position_logic.index_char
            mov cx, window_size.x
            dec cx 
            .if cursor_position_ui.x < cx
                inc cursor_position_ui.x
            .else
                mov cursor_position_ui.x, 0
                mov dx, window_size.y
                dec dx
                .if cursor_position_ui.y < dx
                    inc cursor_position_ui.y
                .endif
            .endif
        
        .else
            ;if cursor is at the end of logic line
            mov esi, (Node PTR[esi]).next
            .if esi == NULL
                jmp quit
            .endif
            mov cursor_position_logic.p_node, esi
            mov cursor_position_logic.index_char, 0
            mov cursor_position_ui.x, 0
            mov dx, window_size.y
            dec dx
            .if cursor_position_ui.y < dx
                inc cursor_position_ui.y
            .endif

        .endif
    popad
    ret
RightKeyHandler ENDP

DownKeyHandler PROC 
    pushad
        
    popad
    ret
DownKeyHandler ENDP

END