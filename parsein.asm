.data
RedirStructSize	dd 0

;Format		db "%d",0
FormatListC	db "%u<==>%u",0

Command1	db "!help",0
Command2	db "!start",0
Command3	db "!end",0

HelpString	db "BAY's ICQ bot",0Dh,0Ah,"==================",0Dh,0Ah,0Dh,0Ah,"!start <UIN>",0Dh,0Ah,"!end",0
StartString	db "Session started...",0
EndString	db "Session ended",0
FailedString	db "FAILED!!!",0

LogAdd1		db ": ",0
LineFeed	db 0Dh,0Ah,0

MessageCounter	dd 0

.data?
RedirStruct	dd 16384 dup(?)

InUIDText	db 32 dup(?)
OutUIDText	db 32 dup(?)

CheckUINBuff	db 32 dup(?)


.code
;///////////////////////////////////
FindFromUINStruct proc DWValueToFind:DWORD

	mov eax,DWValueToFind
	mov ecx,RedirStructSize

@begfind:

	jecxz @notfound
	dec ecx

	lea edx,[RedirStruct+ecx*8]

	cmp dword ptr[edx],eax
	jne @begfind

	mov eax,edx
ret
@notfound:
	xor eax,eax
ret
FindFromUINStruct endp
;///////////////////////////////////////

AddToLog proc Text:DWORD
	LOCAL WritedTemp:DWORD

	invoke lstrlen,Text
	xchg eax,ecx
	invoke WriteFile,hLogFile,Text,ecx,addr WritedTemp,0

ret
AddToLog endp
;///////////////////////
CheckFormatUin proc Text:DWORD
	pushad

	xor esi,esi
	xor edi,edi

@Begin:
	mov eax,Text
	add eax,esi

	mov dl,byte ptr[eax]

	test dl,dl
	je @Return

	cmp dl,'-'
	je @End

	cmp dl,30h
	jb @Failed

	cmp dl,39h
	ja @Failed

	mov [CheckUINBuff+edi],dl
	inc edi
	cmp edi,32
	jae @Failed

@End:
	inc esi
	jmp @Begin

@Return:

	test edi,edi
	je @Failed

	mov [CheckUINBuff+edi],0

	popad
	mov eax,offset CheckUINBuff
	ret

@Failed:
	popad
	xor eax,eax
	ret
CheckFormatUin endp

;/////////////////////////////////
dellink proc UinToDel:DWORD

; ././././././././  поиск уина в "ОТ"(при !end) ././././././././././././

	invoke FindFromUINStruct,UinToDel
	cmp eax,0
	je @end

;/////////////////////// Показать в окошке подключений ////////////
	push eax
	mov ecx,dword ptr[eax]
	add eax,4
	mov eax,dword ptr[eax]
	invoke wsprintf,addr NextFuncBuff256,addr FormatListC,ecx,eax
	invoke GetDlgItem,hwnd,3024
	push eax
	invoke SendMessage,eax,LB_FINDSTRING,-1,addr NextFuncBuff256
	xchg eax,ecx
	pop eax
	invoke SendMessage,eax,LB_DELETESTRING,ecx,0

	pop eax
;//////////////////////////////////////////////////////////////

	mov dword ptr[eax],0
	add eax,4
	mov dword ptr[eax],0

	invoke dwtoa,UinToDel,addr NextFuncBuff256
	invoke SendToICQ,addr NextFuncBuff256,addr EndString ;; пофиг.. пусть будет тут

	xor eax,eax
	inc eax
	ret

@end:
	;xor eax,eax		; пока не надо
	ret
ret
dellink endp

;///////////////////////////
parsein proc InUID:DWORD,Text:DWORD

	invoke dwtoa,InUID,addr InUIDText

	;invoke wsprintf,addr InUIDText,addr Format,InUID

;/////////////////////// добавить в лог //////////////////////

;	invoke lstrsen,
	invoke AddToLog,addr InUIDText
	invoke AddToLog,addr LogAdd1
	invoke AddToLog,Text
	invoke AddToLog,addr LineFeed

;/////////////////////// добавить в последнюю реплику ///////////////

	invoke SetDlgItemText,hwnd,3022,Text

	inc [MessageCounter]
	invoke SetDlgItemInt,hwnd,3021,MessageCounter,0
; ././././././././././././././././././././././././././././././
; ././././././././  поиск уина в "В" ././././././././././././
	mov eax,InUID
	mov ecx,RedirStructSize

@begfind2:

	jecxz @notfound2
	dec ecx

	lea edx,[RedirStruct+ecx*8+4]

	cmp dword ptr[edx],eax
	jne @begfind2

	sub edx,4
	mov eax,dword ptr[edx]

	invoke dwtoa,eax,addr OutUIDText

	invoke lstrlen,Text
	add eax,Text
	invoke GetDlgItemText,hwnd,3018,eax,8192

	invoke SendToICQ,addr OutUIDText,Text

	jmp @endparsein							; не обрабатывать команды принимающего

	@notfound2:

; ././././././././././././././././././././././././././././././

	invoke FindCommand,addr Command1,Text
	test eax,eax
	je @next1				; !HELP

	invoke SendToICQ,addr InUIDText,addr HelpString
	jmp @endparsein

@next1:

	invoke FindCommand,addr Command2,Text
	test eax,eax
	je @next2				; !START


; ././././././././  поиск уина в "ОТ"(при !start) ././././././././././././
	mov eax,InUID
	mov ecx,RedirStructSize
	add ecx,ecx

@begfind3:

	jecxz @notfound3
	dec ecx

	lea edx,[RedirStruct+ecx*4]

	cmp dword ptr[edx],eax
	jne @begfind3

@showfailed:
	invoke SendToICQ,addr InUIDText,addr FailedString
	jmp @endparsein

	@notfound3:

;/////////////////// добавить в структуру
;//////////////////// поглядеть свободные места в структуре/////////////////////////////
	invoke FindFromUINStruct,0
	test eax,eax
	je @notfound5						; жутко оптимезированный код-не трогать
	xchg eax,edx
@@:

	mov eax,Text
	add eax,sizeof Command2
	invoke CheckFormatUin,eax
	test eax,eax
	je @showfailed

	push eax
	call [atodw2]

	mov ecx,InUID

	;;;;;;;;;;;;; еще одна проверочка на пристуствие в структурах номера которого хотим добаведь
	pushad
	;в eax - то что надо
	mov ecx,RedirStructSize
	add ecx,ecx

	@begfind4:

	jecxz @notfound4
	dec ecx

	lea edx,[RedirStruct+ecx*4]

	cmp dword ptr[edx],eax
	jne @begfind4
	popad
	jmp @showfailed

	@notfound4:
	popad
	;;;;;;;;;;;;; запретить добавлять ся, и номер на котором седит бот
	cmp eax,ecx
	je @showfailed
	cmp eax,dwUIN
	je @showfailed

	mov dword ptr[edx],ecx
	add edx,4

	mov dword ptr[edx],eax

;/////////////////////// Показать в окошке подключений ////////////
	invoke wsprintf,addr NextFuncBuff256,addr FormatListC,ecx,eax
	invoke GetDlgItem,hwnd,3024
	invoke SendMessage,eax,LB_ADDSTRING,0,addr NextFuncBuff256

;//////////////////////////////////////////////////////////////

	invoke SendToICQ,addr InUIDText,addr StartString

	jmp @endparsein

	@notfound5:

	mov eax,[RedirStructSize]
	lea edx,[RedirStruct+eax*8]

	inc [RedirStructSize]

	jmp @B

;///////////////////////// конец жутко оптимезированого кода /////////////////////////////////////////

@next2:

	invoke FindCommand,addr Command3,Text
	test eax,eax
	je @next3				; !END

	invoke dellink,InUID
	test eax,eax
	je @someerror

	;invoke SendToICQ,addr InUIDText,addr EndString

	@someerror:

	jmp @endparsein

@next3:

; ././././././././  поиск уина в "ОТ" ././././././././././././

	invoke FindFromUINStruct,InUID
	cmp eax,0
	je @F

	add eax,4
	mov eax,dword ptr[eax]


	invoke dwtoa,eax,addr OutUIDText

	invoke lstrlen,Text
	add eax,Text
	invoke GetDlgItemText,hwnd,3014,eax,8192


	invoke SendToICQ,addr OutUIDText,Text

@@:


;	invoke MessageBox,0,addr InUIDText,addr InUIDText,0

@endparsein:

ret
parsein endp