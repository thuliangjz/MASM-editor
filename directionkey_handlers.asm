.486                                    ; create 32 bit code
.model flat, stdcall                    ; 32 bit memory model
option casemap :none                    ; case sensitive

include linkedList.inc
include ui.inc
include controll.inc
include key_handlers.inc

UpKeyHandler PROC 
    local offset_of_prev_line
    local offset_of_current_line
    local sumy_of_prev_line

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

        pushad
            movzx ebx, window_size.x
            mov edx, 0
            mov eax, ecx
            div ebx
            mov offset_of_current_line, eax
        popad

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

        pushad
            movzx ebx, window_size.x
            mov edx, 0
            mov eax, ecx
            div ebx
            mov cursor_position_ui.x, dx
            mov offset_of_prev_line, eax
        popad

        pushad
            movzx ebx, window_size.x
            mov edx, 0
            mov eax, (Node PTR [esi]).datalength
            div ebx
            mov sumy_of_prev_line, eax
        popad

        mov eax, sumy_of_prev_line
        dec eax, offset_of_prev_line
        add eax, offset_of_current_line
        inc eax
        movzx bx, cursor_position_ui.y
        .if ebx < eax
            mov cursor_position_ui.y, 0
        .else
            dec ebx, eax
            mov cursor_position_ui.y, bx
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
            mov cursor_position_logic.index_char, ebx ;index_char = prevnode->length
            
            movzx ecx, window_size.x
            pushad
                mov edx, 0
                mov eax, ebx                         
                div ecx                             ;cursor_position_ui.x = datalength % window_size.x
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
    local offset_of_next_line
    local offset_of_current_line
    local sumy_of_current_line

    pushad
        mov edi, cursor_position_logic.p_node
        mov esi, (Node PTR [edi]).next
        .if esi == NULL
        ; next node is head
            jmp quit
        .endif
        mov cursor_position_logic.p_node, esi
        mov ecx, cursor_position_logic.index_char

        pushad
            movzx ebx, window_size.x
            mov edx, 0
            mov eax, ecx
            div ebx
            mov offset_of_current_line, eax
        popad

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

        pushad
            movzx ebx, window_size.x
            mov edx, 0
            mov eax, ecx
            div ebx
            mov cursor_position_ui.x, dx
            mov offset_of_prev_line, eax
        popad

        pushad
            movzx ebx, window_size.x
            mov edx, 0
            mov eax, (Node PTR [edi]).datalength
            div ebx
            mov sumy_of_current_line, eax
        popad

        mov eax, sumy_of_current_line
        dec eax, offset_of_current_line
        add eax, offset_of_next_line
        inc eax
        movzx bx, cursor_position_ui.y
        add ebx, eax
        .if bx >= window_size.y
            mov bx, window_size.y
            dec bx
            mov cursor_position_ui.y, bx        
        .else
            mov cursor_position_ui.y, bx
        .endif
        
    popad
    ret
DownKeyHandler ENDP

END