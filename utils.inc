IFNDEF UTILS
UTILS equ <1>
;ע������������ӦΪ��ͬ��С
mov_m2m MACRO op1, op2
	push op1
	pop op2
ENDM
ENDIF