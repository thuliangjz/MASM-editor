IFNDEF CONTROLL
CONTROLL equ <1>

include linkedList.inc
EXTERNDEF text_list:LinkedList
comment~
keyInputHandle PROTO

EditingStatusHandle PROTO


NormalKeyDeal PROTO, 
    key_input: KEY_INPUT

SpecialKeyDeal PROTO, 
    key_input: KEY_INPUT
~

ENDIF

