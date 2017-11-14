IFNDEF INPUT_QUEUE
INPUT_QUEUE equ <1>
include windows.inc
include kernel32.inc
include masm32.inc
KEY_INPUT STRUCT
  is_special BOOL ?
  virtual_key WORD ?	;对应于KEY_EVENT_RECORD中的wVirtualKeyCode
  ascii_char BYTE ?
KEY_INPUT ENDS
GetUserKeyInput PROTO STDCALL
InitInputQueue PROTO STDCALL
PopInputQueue PROTO STDCALL p_key_input:DWORD	;成功则返回0，否则（如队列为空）返回1，改变头指针位置
PeekInputQueue PROTO STDCALL p_key_input:DWORD	;成功返回0，否则返回1，不改变头指针位置
ENDIF
