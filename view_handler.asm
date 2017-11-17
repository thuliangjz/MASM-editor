.486
.model flat, stdcall
option casemap:none

include view_handler.inc
include ui.inc
include control.inc
.code
;复用了编辑部分的代码
UpKeyHandler PROTO

LeftKeyHandler PROTO

RightKeyHandler PROTO

DownKeyHandler PROTO


ViewKeyHandler PROC, input:KEY_INPUT
.IF input.is_special == TRUE
    .IF input.virtual_key == VK_LEFT
        invoke LeftKeyHandler
    .ELSEIF input.virtual_key == VK_RIGHT
        invoke RightKeyHandler
    .ELSEIF input.virtual_key == VK_UP
        invoke UpKeyHandler
    .ELSEIF input.virtual_key == VK_DOWN
        invoke DownKeyHandler
    .ELSEIF input.virtual_key == VK_BACK
        invoke LeftKeyHandler
    .ENDIF
.ELSE
    .IF input.ascii_char == 'h'
        invoke LeftKeyHandler
    .ELSEIF input.ascii_char == 'l'
        invoke RightKeyHandler
    .ELSEIF input.ascii_char == 'j'
        invoke DownKeyHandler
    .ELSEIF input.ascii_char == 'k'
        invoke UpKeyHandler
    .ENDIF
.ENDIF
ret
ViewKeyHandler ENDP
END