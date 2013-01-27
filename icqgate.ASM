; ----- ICQ-gate ------
; -------  BAY   ------
;
; email: 	alex3255@gmail.com
; ICQ: 		1862222


.586
.model flat,stdcall
option casemap:none

include \masm32\include\windows.inc

include \masm32\include\masm32.inc
includelib \masm32\lib\masm32.lib

include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib

include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib

include \masm32\include\wsock32.inc
includelib \masm32\lib\wsock32.lib

include \masm32\include\advapi32.inc
includelib \masm32\lib\ADVAPI32.LIB

include \masm32\include\shell32.inc
includelib \masm32\lib\shell32.LIB

.data

ICQServer		db "205.188.153.98",0
Port			dd 5190

XORString		db 0f3h,26h,81h,0c4h,39h,86h,0dbh,92h

clientid 		db "ICQBasic"
sizeclientid = $-clientid

ErrorText		db "Ошибка",0
ErrorPodkl		db "Ошибка при подключении к серваку",0

DlgName 		db "ICQ-gate",0

LogFile			db "Log.txt",0

ProgRegKey		db "Software\ICQ-gate\",0

.data?

SendBuff		db 512 dup(?)
Cookie			db 512 dup(?)
PassBuff		db 256 dup(?)
RecvBuff		db 65536 dup(?)
TextBuff		db 16384 dup(?)
NextFuncBuff256		db 256 dup(?)

ip 			db 32 dup(?)
portnumber		dd ?

UIN 			db 32 dup(?)
Password		db 32 dup(?)

dwUIN			dd ?

hICQSock		dd ?
hLogFile		dd ?
hRegKey			dd ?
Sequence 		dd ?
hInstance		dd ?

hwnd			dd ?

wsa			WSADATA <?>; структура данных для сети...cм. windows.inc
ICQsock			sockaddr_in <?>; -.-.-

;////////////////////// INCLUDES /////////////////////////////////
include common.asm
include icqprot.asm

include parsein.asm
include recv.asm

include dlg.asm
;////////////////////////////////////////////////////////////////

.code

;///////////////////////////////////////

WinMain PROC

;/////////// Открыть файл лога ////////////
	invoke CreateFile,addr LogFile,GENERIC_WRITE,FILE_SHARE_READ or FILE_SHARE_WRITE,0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN,0
	mov hLogFile,eax
	invoke SetFilePointer,eax,0,0,FILE_END
;////////////// Создать раздел в реестре /////////
	invoke RegCreateKey,HKEY_CURRENT_USER,addr ProgRegKey,addr hRegKey
;////////////////////////////////////////////

	invoke WSAStartup, 101h, addr wsa
	test eax,eax
	jnz @EndProg	

	;///////////// ADDED ////////////////////////

	;invoke RegisterWindowMessage, addr MsgString
	;mov MessageIPC, eax

	;;/////////////// MAIN PART ////////////////////

	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke DialogBoxParam, hInstance, ADDR DlgName,NULL,addr DlgProc,NULL

@EndProg:
	invoke WSACleanup	
	invoke ExitProcess,0
WinMain ENDP

end WinMain