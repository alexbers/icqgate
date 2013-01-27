.data

	status1		db "OK!",0
	status2		db "не подключен",0

	TrayHelpOff	db "[ICQ bot by BAY] - offline",0
	TrayHelpOn	db "[ICQ bot by BAY] - online",0

	TrayIconON	db "MYICON",0
	TrayIconOFF	db "TRAYOFF",0

	Reg1		db "L",0
	Reg2		db "P",0

	TheTen		dd 10

	IDI_TRAY equ 0
	IDM_RESTORE equ 1000


	WM_SHELLNOTIFY 	equ 	WM_USER + 5
	WM_SOCKET	equ	WM_USER + 101			; сообщение от сокета

	noteoff			NOTIFYICONDATA <>
	noteon			NOTIFYICONDATA <>

.code

DlgProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	.IF uMsg==WM_INITDIALOG
		push hWnd
		pop hwnd

		;//////////// реестр /////////////////
		invoke RegQueryValue,hRegKey,addr Reg1,addr UIN,addr TheTen
		mov TheTen,10
		invoke RegQueryValue,hRegKey,addr Reg2,addr Password,addr TheTen
		;/////////////////////////////////////
		invoke SetDlgItemText,hWnd,3000,addr UIN
		invoke SetDlgItemText,hWnd,3006,addr Password

		;///////////// иконка в трее - заполнение структур ////////////

	        push hWnd
        	pop noteoff.hwnd
               	mov noteoff.uID,0
               	mov noteoff.uFlags,NIF_ICON+NIF_MESSAGE+NIF_TIP

               	mov noteoff.uCallbackMessage,WM_SHELLNOTIFY
               	invoke LoadIcon,hInstance,addr TrayIconOFF
               	mov noteoff.hIcon,eax
               	invoke lstrcpy,addr noteoff.szTip,addr TrayHelpOff
		;///////////////////////

	        push hWnd
        	pop noteon.hwnd
               	mov noteon.uID,0
               	mov noteon.uFlags,NIF_ICON+NIF_MESSAGE+NIF_TIP

               	mov noteon.uCallbackMessage,WM_SHELLNOTIFY
               	invoke LoadIcon,hInstance,addr TrayIconON
               	mov noteon.hIcon,eax
               	invoke lstrcpy,addr noteon.szTip,addr TrayHelpOn

               	invoke Shell_NotifyIcon,NIM_ADD,addr noteoff		; иконка в трее

		;//////////////////////////////////////////////////

		;invoke GetDlgItem, hWnd,IDC_EDIT
		;invoke SetFocus,eax
	.ELSEIF uMsg==WM_CLOSE
		invoke Shell_NotifyIcon,NIM_DELETE,addr noteon
		invoke DestroyWindow,hWnd
		;invoke EndDialog, hWnd,NULL
	.ELSEIF uMsg==WM_COMMAND
		mov eax,wParam
		.IF lParam!=0
			mov edx,wParam
			shr edx,16
			.if dx==BN_CLICKED
				.IF ax==3001			; подключитсо
					invoke GetDlgItemText,hWnd,3000,addr UIN,32
					invoke GetDlgItemText,hWnd,3006,addr Password,32
					invoke ICQConnect
					
					test eax,eax
					jne @SomeError

					;///////+++
					push offset UIN
					call [atodw2]
					mov dwUIN,eax
					;///////+++			

					;//////////// реестр /////////////////
					invoke RegSetValue,hRegKey,addr Reg1,REG_SZ,addr UIN,9
					invoke RegSetValue,hRegKey,addr Reg2,REG_SZ,addr Password,8
					;/////////////////////////////////////


					invoke SetDlgItemText,hWnd,3006,0
					invoke SendFamilies
					
					invoke WSAAsyncSelect, hICQSock, hWnd, WM_SOCKET, FD_READ or FD_CLOSE	

					invoke Shell_NotifyIcon,NIM_MODIFY,addr noteon
					invoke SetDlgItemText,hWnd,3010,addr status1

					@SomeError:				
				.ELSEIF ax==3002		; отключиццо
					invoke closesocket,hICQSock
					
					invoke Shell_NotifyIcon,NIM_MODIFY,addr noteoff
					invoke SetDlgItemText,hWnd,3010,addr status2	

				.ELSEIF ax==3026		; разорвать соединение

					invoke GetDlgItem,hwnd,3024
					xchg eax,ecx
					push ecx
					invoke SendMessage,ecx,LB_GETCURSEL,0,0
					cmp eax,LB_ERR
					je @failed
					pop ecx
					invoke SendMessage,ecx,LB_GETTEXT,eax,addr NextFuncBuff256	

					xor ecx,ecx
					
					@@:
					
					lea eax,NextFuncBuff256
					add eax,ecx
					
					inc ecx

					cmp byte ptr[eax],'<'
					jne @B

					mov byte ptr[eax],0

					push offset NextFuncBuff256
					call [atodw2]

					invoke dellink,eax

					@failed:

                        ;.ELSEIF ax==IDC_EXIT
			;		invoke SendMessage,hWnd,WM_COMMAND,IDM_EXIT,0
				.ENDIF
			.ENDIF
		.ELSE			; lParam==0
		.ENDIF
	.ELSEIF uMsg==WM_SIZE
		.if wParam==SIZE_MINIMIZED
			invoke ShowWindow,hwnd,SW_HIDE
		.endif

	
	.ELSEIF uMsg==WM_SOCKET			; пришли данные к сокетам
		mov eax, lParam 

		.if ax == FD_READ
			; принять данные от сокета в буфер
			
			invoke	recv, hICQSock, addr RecvBuff, 65536, 0 ;recv HELLO
			lea edi,RecvBuff

			@repeat:
			push edi
			invoke HandleRecv,edi
			pop edi

			movzx	edx, word ptr[edi+4]			; есть ли ещё пакет за этим?
			xchg	dl, dh
			lea	edi, [edi+edx+6]

			cmp	byte ptr[edi], 2Ah
			je	@repeat

			mov eax, 1	;  установить признак, что в буфер чтения получено...
		.elseif ax == FD_CLOSE
			invoke Shell_NotifyIcon,NIM_MODIFY,addr noteoff
			invoke SetDlgItemText,hWnd,3010,addr status2	
		.endif

	.elseif uMsg==WM_SHELLNOTIFY
		.if wParam==IDI_TRAY
			.if lParam==WM_RBUTTONDOWN
				;invoke GetCursorPos,addr pt
				;invoke SetForegroundWindow,hWnd
				;invoke TrackPopupMenu,hPopupMenu,TPM_RIGHTALIGN or TPM_RIGHTBUTTON,pt.x,pt.y,NULL,hWnd,NULL
				;invoke PostMessage,hWnd,WM_NULL,0,0
			.elseif lParam==WM_LBUTTONUP
				invoke ShowWindow,hwnd,SW_RESTORE
				invoke SetForegroundWindow,hwnd		
				;invoke SendMessage,hwnd,WM_COMMAND,IDM_RESTORE,0
			.endif
	.endif


	.ELSE
		mov eax,FALSE
		ret
	.ENDIF
	mov eax,TRUE
	ret
DlgProc endp
