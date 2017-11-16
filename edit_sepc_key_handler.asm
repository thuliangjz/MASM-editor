.486
.model flat, stdcall
option casemap:none

include ui.inc
include utils.inc
include controll.inc
include key_handlers.inc

BackSpaceHandler PROC
    LOCAL cursor_prev:CURSOR_POSITION_LOGIC
;保留移动前的光标位置拷贝
mov cursor_prev.p_node, cursor_position_logic.p_node
mov cursor_prev.index_char, cursor_position_logic.index_char
;先调用左移处理光标位置
invoke LeftKeyHandler
;删除文本
mov ebx, cursor_prev.p_node
mov eax, (Node PTR [ebx]).prev
.IF cursor_position_logic.index_char != 0
    ;只需删除文字
    lea eax, [ebx].data
    invoke DeleteChar eax, cursor_prev.index_char
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
    mov ebx, (Node PTR [eax]).Next
    ;创建一个“假的”String, 其内容为当前光标之后的那一段
    mov esi, (Node PTR [eax]).data
    add esi, cursor_position_logic.index_char
    mov str_tmp.data, esi
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
    .ELSEIF (Node PTR [eax]).next != 0
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