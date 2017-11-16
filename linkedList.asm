; (linkedList.asm)
.486                                    ; create 32 bit code
.model flat, stdcall                    ; 32 bit memory model
option casemap :none                    ; case sensitive

include linkedList.inc
include windows.inc
include kernel32.inc
include msvcrt.inc
include utils.inc
include masm32.inc

BUFFER_INIT_LENGTH EQU 100
endl EQU <0dh, 0ah>
thisNode EQU <(Node PTR [esi])>
thisList EQU <(LinkedList PTR [edi])>

.code
;init the list
InitList PROC, listPtr: DWORD
    ;LOCAL @tmpAddr: DWORD 
    pushad

        invoke crt_malloc, SIZEOF Node
        mov edi, listPtr
        mov thisList.head, eax
        mov thisList.currentNode, eax
        mov esi, eax
        mov thisNode.data.string, 0
        mov thisNode.data.dataLength, 0
        mov thisNode.data.bufferLength, 0
        mov thisNode.prev, 0
        mov thisNode.next, 0

    popad
    ret
InitList ENDP


InsertNode PROC, listPtr: DWORD
    LOCAL tmpString: DWORD
    pushad
        ;eax: newnode,   ebx:oldnode.next  ecx:oldnode
        invoke crt_malloc, SIZEOF Node
        mov edi, listPtr
        mov ecx, thisList.currentNode
        mov esi, ecx
        mov ebx, thisNode.next        ;thisNode == oldnode
        mov thisNode.next, eax         
        .if ebx != 0
            mov esi, ebx              ;thisNode == oldnode.next
            mov thisNode.prev, eax
        .endif
        mov esi, eax                  ;thisNode == newnode
        mov thisNode.prev, ecx
        mov thisNode.next, ebx

        mov thisList.currentNode, eax
        inc thisList.listLength
        
        invoke InitString, ADDR thisNode.data

    popad
    ret
InsertNode ENDP

FreeNode PROC, p_node:DWORD
    mov esi, p_node
    mov eax, (Node PTR [esi]).data.string
    invoke crt_free, eax
    invoke crt_free, p_node
    ret
FreeNode ENDP

DeleteNode PROC, listPtr: DWORD 
    
    pushad
        mov edi, listPtr
        mov esi, thisList.currentNode
        mov ecx, thisNode.prev
        
        .if ecx == 0                      ;is head node
            jmp quit
        .endif
        mov ecx, thisNode.next
        .if ecx == 0                      ;there is no next,  eax:prev
            mov eax, thisNode.prev 
            
            pushad
                invoke FreeNode, esi
            popad

            mov esi, eax
            mov thisNode.next, 0  ;thisNode == currentNode.prev
            
            mov thisList.currentNode, eax
            dec thisList.listLength
            jmp quit
        .endif

        mov eax, thisNode.prev
        mov ebx, thisNode.next
        pushad
            invoke FreeNode, esi
        popad
        mov esi, eax                
        mov thisNode.next, ebx  ;thisNode == currentNode.prev    
        mov esi, ebx
        mov thisNode.prev, eax

        mov thisList.currentNode, ebx
        dec thisList.listLength

quit:   
    popad
    ret
DeleteNode ENDP


InitString PROC, stringPtr: DWORD
    pushad
        invoke crt_malloc, BUFFER_INIT_LENGTH
        mov edi, stringPtr
        mov (String PTR [edi]).string, eax
        mov (String PTR [edi]).bufferLength, BUFFER_INIT_LENGTH
        mov (String PTR [edi]).dataLength, 0
        mov esi, eax
        mov BYTE PTR [esi], 0
    popad
    ret
InitString ENDP

InsertChar PROC, stringPtr: DWORD, char: BYTE, pos:DWORD
    LOCAL tmpStr
    LOCAL tmpStrHead
    LOCAL i
    pushad
        mov i, 0
        mov edi, stringPtr
        mov esi, (String PTR [edi]).string
        mov eax, (String PTR [edi]).dataLength
        mov ebx, (String PTR [edi]).bufferLength
        .if pos > eax
            jmp quit
        .endif
        inc eax                 ;eax = new length, ebx = new bufferLength
        .if eax == ebx                   
            add ebx, ebx
            pushad
                invoke crt_malloc, ebx
                mov tmpStr, eax
                mov tmpStrHead, eax
            popad
            mov ecx, eax
            inc ecx
            push eax
            mov eax, pos
        copystr:
            .if i == eax 
                mov dl, char
                mov BYTE PTR [tmpStr], dl
                inc tmpStr
                inc i
            .else
                mov dl, BYTE PTR [esi]
                mov BYTE PTR [tmpStr], dl
                inc esi
                inc tmpStr
                inc i
            .endif
            loop copystr
            pop eax

            pushad
                invoke crt_free, esi
            popad
            mov esi, tmpStrHead
            mov (String PTR [edi]).string, esi
            mov (String PTR [edi]).dataLength,eax
            mov (String PTR [edi]).bufferLength, ebx

        .else
            mov ecx, eax
            sub ecx, pos
            add esi, eax
        copystr2:
            mov dl, BYTE PTR[esi - 1]
            mov BYTE PTR [esi], dl
            dec esi
            loop copystr2

            mov dl, char
            mov BYTE PTR [esi], dl
            mov (String PTR [edi]).dataLength,eax
        .endif
    
quit:
    popad
    ret
InsertChar ENDP

DeleteChar PROC,  stringPtr: DWORD, pos:DWORD
    pushad
        mov edi, stringPtr
        mov esi, (String PTR [edi]).string
        mov eax, (String PTR [edi]).dataLength
        mov ebx, (String PTR [edi]).bufferLength
        .if pos >= eax
            jmp quit
        .endif
        mov ecx, eax
        sub ecx, pos
        add esi, pos
    deleteLoop:
        mov dl, BYTE PTR [esi + 1]
        mov BYTE PTR [esi], dl
        inc esi
        loop deleteLoop

        dec eax
        mov (String PTR [edi]).dataLength, eax

quit:
    popad
    ret
DeleteChar ENDP

DestroyString PROC, stringPtr: DWORD
    pushad
        mov esi, stringPtr
        mov eax, (String PTR [esi]).bufferLength
        .if eax == 0
            jmp quit
        .endif
        mov (String PTR [esi]).bufferLength, 0
        mov (String PTR [esi]).dataLength, 0
        pushad
            invoke crt_free, (String PTR [esi]).string
        popad
quit:
    popad
    ret
DestroyString ENDP

ConcatString PROC, pstring_source:DWORD, pstring_dest:DWORD
	LOCAL data_length_new:DWORD, buffer_length_new:DWORD
    pushad
	mov esi, pstring_source
	mov edi, pstring_dest
	mov eax, (String PTR [esi]).dataLength
	add eax, (String PTR [edi]).dataLength
	mov ebx, (String PTR [edi]).bufferLength
	mov_m2m buffer_length_new, (String PTR [edi]).bufferLength
	mov data_length_new, eax
	;note the char after string[dataLength] is 0
	.IF eax >= ebx
		add eax, eax	;bufferLength *= 2
		mov buffer_length_new, eax
		invoke crt_malloc, eax
        push eax
		;copy content from p_string_dest->string to newly allocated spaces
		mov edi, eax
		mov esi, pstring_dest
		mov ecx, (String PTR [esi]).dataLength
		mov esi, (String PTR [esi]).string
		cld
		rep movsb
		;free original spaces
		mov esi, pstring_dest
		mov esi, (String PTR [esi]).string
		invoke crt_free, esi
		;resume
		mov edi, pstring_dest
		mov esi, pstring_source
        ;保存新申请的空间到pstring_dest->string上
        pop (String PTR [edi]).string
		;update bufferLength
		mov_m2m (String PTR [esi]).bufferLength, buffer_length_new
	.ENDIF
	;copy from source to dest
	mov ecx, (String PTR [esi]).dataLength
	mov esi, (String PTR [esi]).string
	mov eax, (String PTR [edi]).dataLength
	mov edi, (String PTR [edi]).string
	add edi, eax
	cld
	rep movsb
	;update dataLength
	mov edi, pstring_dest
	mov_m2m (String PTR [edi]).dataLength, data_length_new
    popad
	ret
ConcatString ENDP
END
