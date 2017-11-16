IFNDEF UTILS
UTILS equ <1>
;交换两个内存中的操作数，注意两个操作数的大小应该相同
mov_m2m MACRO op1, op2
	push op2
	pop op1
ENDM
ENDIF
