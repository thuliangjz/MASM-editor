; (linkedList.asm)
.386                                    ; create 32 bit code
.model flat, stdcall                    ; 32 bit memory model
option casemap :none                    ; case sensitive

include linkedList.inc

includelib masm32.lib
includelib kernel32.lib
includelib msvcrt.lib

BUFFER_INIT_LENGTH EQU 100
endl EQU <0dh, 0ah>
thisNode EQU <(Node PTR [esi])>
thisList EQU <(List PTR [edi])>


.data
;head Node <0, 0, 0, 0>
outstr1 db "head:%x", endl, 0
outstr2 db "data:%s", endl, 0
outstrtest db "count : %d", endl, 0
mylist List <>



.code
main PROC
    local tmpStr: BYTE
    local stringPtr: DWORD
    invoke InitList, ADDR mylist
    mov tmpStr, 'a'
    mov ecx, 10
createList:
    invoke InsertNode, ADDR mylist
    mov esi, mylist.currentNode
    invoke InitString, esi
    invoke InsertChar, esi, tmpStr, 0 
    inc tmpStr
    loop createList

    mov ecx, 10
    mov esi, mylist.head
printList:
    mov eax, thisNode.data.string
    mov stringPtr, eax
    pushad
        invoke crt_printf, ADDR outstr2, stringPtr
    popad
    mov eax, thisNode.next
    mov esi, eax
    loop printList

    mov ecx, 5
    mov esi, mylist.head
    mov edi, thisNode.next
    mov mylist.currentNode, edi
deleteList:
    invoke DeleteNode, ADDR mylist
    loop deleteList


    mov ecx, 5
    mov esi, mylist.currentNode
printList2:
    mov eax, thisNode.data.string
    mov stringPtr, eax
    pushad
        invoke crt_printf, ADDR outstr2, stringPtr
    popad
    mov eax, thisNode.next
    mov esi, eax
    loop printList2
	
	mov esi, mylist.currentNode
    invoke InsertChar, mylist.currentNode, tmpStr, 1
	mov esi, (Node PTR [esi]).data.string
    pushad
		invoke crt_printf, ADDR outstr2, esi
    popad

    invoke ExitProcess, 0
main ENDP




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
                invoke crt_free, esi
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
            invoke crt_free, esi
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
        inc eax                 ;eax = new length, ebx = new bufferlength
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
            mov pos, eax
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

END main


