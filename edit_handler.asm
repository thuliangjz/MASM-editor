.486
.model flat, stdcall
option casemap:none

include edit_handler.inc

UpKeyHandler PROTO

LeftKeyHandler PROTO

RightKeyHandler PROTO

DownKeyHandler PROTO

BackSpaceHandler PROTO

EnterHandler PROTO

DeleteHandler PROTO

NormalKeyHandler PROTO, key_input:KEY_INPUT
.data
record_cursor_max_index DWORD 0
.code
;分发函数
EditHandler PROC input:KEY_INPUT
.IF input.is_special == TRUE
    .IF input.virtual_key == VK_LEFT
        invoke LeftKeyHandler
    .ELSEIF input.virtual_key == VK_RIGHT
        invoke RightKeyHandler
    .ELSEIF input.virtual_key == VK_UP
        invoke UpKeyHandler
    .ELSEIF input.virtual_key == VK_DOWN
        invoke DownKeyHandler
    .ELSEIF input.virtual_key == VK_RETURN
        invoke EnterHandler
    .ELSEIF input.virtual_key == VK_BACK
        invoke BackSpaceHandler
    .ELSEIF input.virtual_key == VK_DELETE
        invoke DeleteHandler
    .ENDIF
.ELSE
    ;inserting
    invoke NormalKeyHandler, input
.ENDIF
    ret
EditHandler ENDP


NormalKeyHandler PROC, key_input: KEY_INPUT
    pushad
        mov edi, cursor_position_logic.p_node
        mov eax, cursor_position_logic.index_char
        lea esi, (Node PTR [edi]).data
        invoke InsertChar, esi, key_input.ascii_char, cursor_position_logic.index_char
        invoke RightKeyHandler
    popad
    ret
NormalKeyHandler ENDP


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
        ;计算逻辑光标所能达到的最远的距离
        .if ecx < record_cursor_max_index
            mov ecx, record_cursor_max_index
        .else
            mov record_cursor_max_index, ecx
        .endif
        ;ecx现在表示最大能够达到的index
        mov edx, (Node PTR [esi]).data.dataLength
        .if ecx <= edx
            mov cursor_position_logic.index_char, ecx
        .else
            mov ecx, edx
            mov cursor_position_logic.index_char, ecx
        .endif
        ;ecx现在表示逻辑光标的索引
        ;维护屏幕光标
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
            mov eax, (Node PTR [esi]).data.dataLength
            div ebx
            mov sumy_of_prev_line, eax
        popad

        mov eax, sumy_of_prev_line
        sub eax, offset_of_prev_line
        add eax, offset_of_current_line
        inc eax
        movzx ebx, cursor_position_ui.y
        .if ebx < eax
            mov cursor_position_ui.y, 0
        .else
            sub ebx, eax
            mov cursor_position_ui.y, bx
        .endif
quit:
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
            mov ebx, (Node PTR [esi]).data.dataLength
            mov cursor_position_logic.index_char, ebx ;index_char = prevnode->length
            
            movzx ecx, window_size.x
            pushad
                mov edx, 0
                mov eax, ebx                         
                div ecx                             ;cursor_position_ui.x = dataLength % window_size.x
                mov cursor_position_ui.x, dx    
            popad
            .if cursor_position_ui.y > 0
                dec cursor_position_ui.y
            .endif

        .endif
quit:
    popad
    ret
LeftKeyHandler ENDP

RightKeyHandler PROC 
    pushad
        mov record_cursor_max_index, 0
        mov edi, cursor_position_logic.p_node
        mov ebx, (Node PTR [edi]).data.dataLength

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
quit:
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
        mov edx, (Node PTR [esi]).data.dataLength
        .if edx >= ecx
            mov cursor_position_logic.index_char, ecx
        .else
            mov ecx, (Node PTR [esi]).data.dataLength
            mov cursor_position_logic.index_char, ecx
        .endif

        pushad
            movzx ebx, window_size.x
            mov edx, 0
            mov eax, ecx
            div ebx
            mov cursor_position_ui.x, dx
            mov offset_of_next_line, eax
        popad

        pushad
            movzx ebx, window_size.x
            mov edx, 0
            mov eax, (Node PTR [edi]).data.dataLength
            div ebx
            mov sumy_of_current_line, eax
        popad

        mov eax, sumy_of_current_line
        sub eax, offset_of_current_line
        add eax, offset_of_next_line
        inc eax
        movzx ebx, cursor_position_ui.y
        add ebx, eax
        .if bx >= window_size.y
            mov bx, window_size.y
            dec bx
            mov cursor_position_ui.y, bx        
        .else
            mov cursor_position_ui.y, bx
        .endif
quit:
    popad
    ret
DownKeyHandler ENDP

BackSpaceHandler PROC
    LOCAL cursor_prev:CURSOR_POSITION_LOGIC
;保留移动前的光标位置拷贝
mov_m2m cursor_prev.p_node, cursor_position_logic.p_node
mov_m2m cursor_prev.index_char, cursor_position_logic.index_char
;先调用左移处理光标位置
invoke LeftKeyHandler
;删除文本
mov ebx, cursor_prev.p_node
mov eax, (Node PTR [ebx]).prev
.IF cursor_position_logic.index_char != 0
    ;只需删除文字
    lea eax, (Node PTR [ebx]).data
    invoke DeleteChar, eax, cursor_prev.index_char
.ELSEIF eax != text_list.head
    ;合并字符串
    lea esi, (Node PTR [ebx]).data
    lea edi, (Node PTR [ebx]).data
    invoke ConcatString, esi, edi
    ;删除之前所在的行
    mov_m2m text_list.currentNode, cursor_prev.p_node
    invoke DeleteNode, addr text_list
.ENDIF
    ret
BackSpaceHandler ENDP

EnterHandler PROC
    LOCAL str_tmp:String
    ;创建新节点
    mov_m2m text_list.currentNode, cursor_position_logic.p_node
    invoke InsertNode, addr text_list
    ;以下eax指向原先结点而ebx指向新建立的结点
    mov eax, cursor_position_logic.p_node
    mov ebx, (Node PTR [eax]).next
    ;创建一个“假的”String, 其内容为当前光标之后的那一段
    mov esi, (Node PTR [eax]).data.string
    add esi, cursor_position_logic.index_char
    mov str_tmp.string, esi
    mov_m2m str_tmp.dataLength, (Node PTR [eax]).data.dataLength
    mov ecx, cursor_position_logic.index_char
    sub str_tmp.dataLength,ecx
    ;借助于ConcatString拷贝
    lea esi, str_tmp
    lea edi, (Node PTR [ebx]).data
    invoke ConcatString, esi, edi
    ;修改当前结点文本长度
    mov_m2m (Node PTR [eax]).data.dataLength, cursor_position_logic.index_char
    ;移动光标到下一行
    invoke RightKeyHandler
    ret
EnterHandler ENDP

DeleteHandler PROC
    mov eax, cursor_position_logic.p_node   ;以下eax均表示当前所处结点的值
    mov ecx, (Node PTR [eax]).data.dataLength   ;ecx记录最大字符串索引
    .IF ecx > cursor_position_logic.index_char
        ;只需删除后面一个字符
        mov ebx, cursor_position_logic.index_char
        inc ebx
        lea esi, (Node PTR [eax]).data
        invoke DeleteChar, esi, ebx
    mov edx, (Node PTR [eax]).next
    .ELSEIF edx != 0
        ;合并后一个结点
        mov esi, (Node PTR [eax]).next
        lea esi, (Node PTR [esi]).data  ;esi = &p_node->next->string
        lea edi, (Node PTR [eax]).data  ;edi = &p_node->string
        invoke ConcatString, esi, edi
        ;删除后一个结点
        mov_m2m text_list.currentNode, (Node PTR [eax]).next
        invoke DeleteNode, addr text_list
    .ENDIF
    ret
DeleteHandler ENDP

END