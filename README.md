# MASM-editor

+ 11.14 finish link,node and string

## a simple example for link, node and string
~~~asm
    .data
    outstr1 db "place:%x", endl, 0
    outstr2 db "data:%s", endl, 0
    outstrtest db "count : %d", endl, 0
    mylist List <>

    .code
    main PROC
        local stringPtr: DWORD
        invoke InitList, ADDR mylist
        invoke InsertNode, ADDR mylist
        mov esi, mylist.currentNode
        invoke InitString, esi
        ;we can directly use esi to represent the position of mylist.data
        invoke InsertChar, esi, 'a', 0
        invoke InsertChar, esi, 'b', 1
        invoke InsertChar, esi, 'c', 2
        invoke DeleteChar, esi, 0
        mov esi, (String PTR[esi]).string
        pushad
            invoke crt_printf, ADDR outstr2, esi
        popad
        invoke ExitProcess, 0
    main ENDP
~~~