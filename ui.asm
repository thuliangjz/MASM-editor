.486
.model flat, stdcall
option casemap:none

include ui.inc
include utils.inc

.data
text_list List <>
window_size COORD <>
cursor_position_ui COORD <>
cursor_position_logic CURSOR_POSITION_LOGIC <> 
_screen_buffer_info CONSOLE_SCREEN_BUFFER_INFO <>
window_width_max = 128
window_height_max = 64
_drawn_text_array BYTE window_height_max * window_width_max DUP (?)
.code
UIInit PROC, hScreenBuffer:HANDLE
	invoke GetConsoleScreenBufferInfo, hScreenBuffer, addr _screen_buffer_info
	mov_m2m window_size.x, _screen_buffer_info.srWindow.Right
	mov_m2m window_size.y, _screen_buffer_info.srWindow.Bottom
UIInit ENDP


