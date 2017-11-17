# MASM-editor

## a text editor based on masm32, kernal32, msvcrt, windows

+ 11.14 finish link,node and string<br>
below is a simple example for link, node and string
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

+ 11.16 a demo for basic operations
~~~asm
    .data
    text_list LinkedList <>
    input KEY_INPUT <>
    hNewScreenBuffer HANDLE ?
    hStdout HANDLE ?
    file_name db "test_text_input.txt", 0

    .code
    start:
        ;invoke InitList, addr text_list

        ;创建新屏幕
        invoke GetStdHandle, STD_OUTPUT_HANDLE
        mov hStdout, eax
        invoke CreateConsoleScreenBuffer, GENERIC_READ + GENERIC_WRITE,	FILE_SHARE_READ + FILE_SHARE_WRITE, 0, CONSOLE_TEXTMODE_BUFFER, 0
        mov hNewScreenBuffer, eax
        invoke SetConsoleActiveScreenBuffer, hNewScreenBuffer
        invoke UIInit, hNewScreenBuffer
        invoke InitInputQueue
        ;文档链表初始化
        ;invoke InitList, addr text_list
        ;mov_m2m text_list.currentNode, text_list.head
        ;创建一个空的行
        ;invoke InsertNode, addr text_list
        invoke ReadFileToList, addr file_name
        ;光标初始化
        mov cursor_position_ui.x, 0
        mov cursor_position_ui.y, 0
        mov eax, text_list.head
        mov_m2m cursor_position_logic.p_node, (Node PTR [eax]).next
        mov cursor_position_logic.index_char, 0
        mov_m2m text_list.currentNode, text_list.head
        invoke DrawText
        ;工作循环
        loop_work:
            invoke GetUserKeyInput
            invoke PopInputQueue, addr input
            invoke EditHandler, input
            invoke DrawText
            mov eax, DWORD PTR[cursor_position_ui]
            invoke SetConsoleCursorPosition, hNewScreenBuffer, eax
            jmp loop_work
        invoke ExitProcess, 0
    END start
~~~

+ 11.17 finish the whole program