IFNDEF UTILS
UTILS equ <1>
;注意两个操作数应为相同大小
mov_m2m MACRO op1, op2
	push op1
	pop op2
ENDM
ENDIF
