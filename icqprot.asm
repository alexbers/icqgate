.data

clientsendmsg1 		db 2Ah, 02h, 5Ch, 01h, 00h, 5Eh, 00h, 04h, 00h, 06h, 00h, 00h, 00h, 01h, 00h, 06h, 0Fh
			db 6Fh, 36h, 00h, 0FFh, 0Ah, 00h, 00h, 00h, 01h
sizeclientsendmsg1 = $-clientsendmsg1

clientsendmsg2 		db 00h, 02h, 00h, 18h, 05h, 01h, 00h, 01h, 01h, 01h, 01h
sizeclientsendmsg2 = $-clientsendmsg2

clientsendmsg3 		db 00h, 03h, 00h, 00h, 00h, 06h, 00h, 00h
sizeclientsendmsg3 = $-clientsendmsg3

;clientchangestatus	db 2ah, 02h, 32h, 0eh, 00h, 12h, 00h, 01h, 00h, 1eh, 00h, 00h, 00h, 00h, 00h, 1eh
;			db 00h, 06h, 00h, 04h, 00h, 02h, 00h, 01h
;sizeclientchangestatus = $-clientchangestatus

clientfamilies db 2ah, 02h, 2bh, 5dh, 00h, 32h, 00h, 01h, 00h, 17h, 00h, 00h, 00h, 00h, 00h, 17h
		  db 00h, 01h, 00h, 04h, 00h, 13h, 00h, 04h, 00h, 02h, 00h, 01h, 00h, 03h, 00h, 01h
		  db 00h, 15h, 00h, 01h, 00h, 04h, 00h, 01h, 00h, 06h, 00h, 01h, 00h, 09h, 00h, 01h
		  db 00h, 0ah, 00h, 01h, 00h, 0bh, 00h, 01h
sizeclientfamilies = $-clientfamilies

clientcheckroaster db 2ah, 02h, 51h, 33h, 00h, 10h, 00h, 13h, 00h, 05h, 00h, 00h, 00h, 01h, 00h, 05h
		     db 00h, 00h, 00h, 00h, 00h, 00h
sizeclientcheckroaster = $-clientcheckroaster

;requestofflinemsg db 2Ah, 02h, 5Ah, 0CFh, 00h, 18h, 00h, 15h, 00h, 02h, 00h, 00h, 00h, 02h, 00h, 01h
;		    db 00h, 01h, 00h, 0Ah, 08h, 00h, 8Fh, 0E4h, 5Eh, 00h, 3Ch, 00h, 02h, 00h
;sizerequestofflinemsg = $-requestofflinemsg

clientroasterack db 2ah, 02h, 51h, 3bh, 00h, 0ah, 00h, 13h, 00h, 07h, 00h, 00h, 00h, 00h, 00h, 07h
sizeclientroasterack = $-clientroasterack


clientready db 2Ah, 02h, 22h, 93h, 00h, 5Ah, 00h, 01h,  00h, 02h, 00h, 00h, 00h, 00h, 00h, 02h
	      db 00h, 01h, 00h, 03h, 01h, 10h, 04h, 7Bh,  00h, 13h, 00h, 02h, 01h, 10h, 04h, 7Bh
	      db 00h, 02h, 00h, 01h, 01h, 01h, 04h, 7Bh,  00h, 03h, 00h, 01h, 01h, 10h, 04h, 7Bh
	      db 00h, 15h, 00h, 01h, 01h, 10h, 04h, 7Bh,  00h, 04h, 00h, 01h, 01h, 10h, 04h, 7Bh
	      db 00h, 06h, 00h, 01h, 01h, 10h, 04h, 7Bh,  00h, 09h, 00h, 01h, 01h, 10h, 04h, 7Bh
	      db 00h, 0Ah, 00h, 01h, 01h, 10h, 04h, 7Bh,  00h, 0Bh, 00h, 01h, 01h, 10h, 04h, 7Bh
sizeclientready = $-clientready

clientseticbm db 2ah, 02h, 2ah, 0e4h, 00h, 1ah, 00h, 04h, 00h, 02h, 00h, 00h, 00h, 00h, 00h, 02h
		db 00h, 02h, 00h, 00h, 00h, 03h, 1fh, 40h, 03h, 0e7h, 03h, 0e7h, 00h, 00h, 00h, 00h
sizeclientseticbm = $-clientseticbm

;clientrequestnick db 2Ah, 02h, 79h, 75h, 00h, 1Eh, 00h, 15h, 00h, 02h, 00h, 00h, 00h, 07h, 00h, 02h
;		    db 00h, 01h, 00h, 10h, 0Eh, 00h, 8Fh, 0E4h, 5Eh, 00h, 0D0h, 07h, 08h, 00h, 0BAh, 04h
;		    db 8Fh, 0E4h, 5Eh, 00h
;sizeclientrequestnick = $-clientrequestnick

clientsetstatus db 2Ah, 02h, 23h, 2Bh, 00h, 12h, 00h, 01h, 00h, 1Eh, 00h, 00h, 00h, 00h, 00h, 1Eh
		  db 00h, 06h, 00h, 04h, 10h, 00h, 00h, 00h
sizeclientsetstatus = $-clientsetstatus



clientgoodbye		db 2ah, 04h, 73h, 0aah, 0h, 0h
sizeclientgoodbye = $-clientgoodbye


.code

ICQConnect proc
	invoke socket,AF_INET,SOCK_STREAM,0
	cmp eax,-1
	je @ending
	mov hICQSock,eax

	invoke htons,Port
	mov ICQsock.sin_port,ax
	mov ICQsock.sin_family, AF_INET

	invoke gethostbyname,addr ICQServer
	cmp eax,0
	je @ending
	
	mov eax,[eax+12]
	mov eax,[eax]
	mov eax,[eax]
	mov ICQsock.sin_addr,eax

;/////////// BUILD PACKET ///////////////////

	lea edi,SendBuff
	mov word ptr[edi],12Ah ;FLAP

	invoke GetSequence

	mov word ptr[edi+2], ax
	mov dword ptr[edi+6], 01000000h

	add edi, 6+4

	lea esi,[UIN]

	invoke lstrlen,	esi

	push	eax

	shl	eax, 16+8

	or	eax, 100h ;tlv.type1
	stosd
	pop	ecx
	rep	movsb

	invoke lstrlen,addr Password

	push	eax
	shl	eax, 16+8
	or	eax, 200h ;tlv.type2
	stosd

	lea	esi, PassBuff

	push esi
	invoke lstrcpy, esi, addr Password
	pop esi	

	invoke RoastPassword, esi, addr XORString

	pop	ecx
	rep	movsb

	mov	ecx, sizeclientid
	mov	eax, (sizeclientid SHL 24) or 300h ;tlv.type3

	stosd
	lea	esi, clientid
	rep	movsb

	mov	dword ptr[edi], 2001600h ; tlv.type16
	mov	dword ptr[edi+4], 17000a01h ; tlv.type17
	mov	dword ptr[edi+8], 14000200h
	mov	dword ptr[edi+12], 2001800h ;tlv.type18
	mov	dword ptr[edi+16], 19002200h ;tlv.type19
	mov	dword ptr[edi+20], 0000200h
	mov	dword ptr[edi+24], 2001A00h ;tlv.type1A
	mov	dword ptr[edi+28], 14001109h ;tlv.type14
	mov	word ptr[edi+32], 400h
	mov	dword ptr[edi+34], 3d040000h
	mov	dword ptr[edi+38], 2000F00h  ;tlv.type0F
	mov	word ptr[edi+42], 'ne'
	mov	dword ptr[edi+44], 2000E00h  ;tlv.type0E
	mov	word ptr[edi+48], 'su'
	xchg	eax, edi
	sub	eax, offset [SendBuff]
	add	eax, 50
	push	0	    ;flags
	push	eax	    ;size
	sub	eax, 6
	xchg	al,ah
	mov	word ptr[SendBuff+4],ax
;////////////// END //////////////////////

	invoke connect,hICQSock,offset ICQsock,sizeof ICQsock
	cmp ax,-1
	je @ending

	lea	ebx, RecvBuff

	invoke	recv, hICQSock, ebx, 512, 0 ;recv HELLO

	push	offset[SendBuff]
	push	hICQSock
	call	[send]

	invoke	recv, hICQSock, ebx, 512,0

	movzx	eax, byte ptr[ebx+14]
	lea	ebx, [ebx+eax+15]
	mov	ax, word ptr[ebx]
	cmp	ax, 0500h
	jnz	@loginerror

	;//////////////////////////////

	;let's extract the ip address+port
	movzx	edi, byte ptr[ebx+3]
	add	ebx, 4
	lea	edx, [ebx+edi+2] ; for later use
	lea	ecx, ip

@copyip:
	mov	al, [ebx]
	inc	ebx
	mov	[ecx], al
	inc	ecx
	dec	edi
	jnz	@copyip
	lea	ecx, ip
@extractport:
	cmp	byte ptr[ecx],":"
	lea	ecx, [ecx+1]
	jnz	@extractport
	mov	byte ptr[ecx-1],0
	
	;invoke MessageBox,0,addr ip,ecx,0

	push ecx
	call [atodw2]

	mov	[portnumber], eax
	movzx	eax, word ptr[edx]
	add	edx, 2
	xchg	al, ah
	lea	edi, Cookie
	stosd
@copycookie:
	mov	cl, [edx]
	inc	edx
	mov	[edi],cl
	inc	edi
	dec	eax
	jnz	@copycookie

	;say goodbye to server
	call	GetSequence
	mov	word ptr[clientgoodbye+2], ax
	invoke	send, hICQSock, addr clientgoodbye, sizeclientgoodbye, 0
	invoke	closesocket, hICQSock

	invoke	gethostbyname,addr ip
	cmp eax,0
	je @ending
	
	mov eax,[eax+12]
	mov eax,[eax]
	mov eax,[eax]
	mov ICQsock.sin_addr,eax

	mov	eax, [portnumber]
	xchg	ah, al

	mov ICQsock.sin_port,ax

;;lets build a reply or rather cli_cookie
	lea	edi, SendBuff

	mov	word ptr[edi], 12Ah ;FLAP
	call	GetSequence
	mov	word ptr[edi+2], ax
	mov     dword ptr[edi+6], 01000000h
	mov	word ptr[edi+10], 600h
	add	edi, 6+4+2

	lea	esi, Cookie
	lodsd
	mov	ecx, eax
	
	xchg	al, ah
	stosw
	rep	movsb

	xchg	edi, eax
	sub	eax, offset [SendBuff]


	push	0	    ;flags
	push	eax	    ;size
	sub	eax, 6
	xchg	al, ah

	mov	word ptr[SendBuff+4],ax

	invoke	socket, AF_INET, SOCK_STREAM, IPPROTO_TCP
	mov	hICQSock, eax
	xchg	esi, eax

	invoke connect, esi, offset ICQsock,sizeof ICQsock

	invoke	recv, esi,addr RecvBuff, 512, 0

	push	offset [SendBuff]
	push	esi

	call	[send]

	invoke	recv, esi,addr RecvBuff, 512, 0

	jmp @endingOK

@loginerror:

	invoke MessageBox,0,addr ErrorPodkl,addr ErrorText,MB_OK or MB_ICONERROR

@ending:
	xor eax,eax
	inc eax
	ret
@endingOK:
	xor eax,eax
ret
ICQConnect endp


;////////////////////////////////////////////

SendFamilies proc
	call	GetSequence
	mov	word ptr[clientfamilies+2], ax
	invoke	send, hICQSock, addr clientfamilies,sizeclientfamilies,0

;	push offset UIN
;	call [atodw2]
;	mov	dword ptr[clientrequestnick+32], eax
;	mov	dword ptr[clientrequestnick+22], eax
;	call	GetSequence
;	mov	word ptr[clientrequestnick+2], ax
;	invoke	send, hICQSock,addr clientrequestnick, sizeclientrequestnick,0

	call	GetSequence
	mov	word ptr[clientcheckroaster+2], ax
	invoke	send, hICQSock, addr clientcheckroaster, sizeclientcheckroaster, 0

;	call	GetSequence
;	mov	word ptr[requestofflinemsg+2],ax

;	push offset UIN
;	call [atodw2]

;	mov	dword ptr[requestofflinemsg+22],eax
;	invoke	send, hICQSock, addr requestofflinemsg, sizerequestofflinemsg, 0

	call	GetSequence
	mov	word ptr[clientseticbm+2], ax
	invoke	send, hICQSock,addr clientseticbm, sizeclientseticbm, 0

	;

	call	GetSequence
	mov	word ptr[clientroasterack+2], ax
	invoke	send, hICQSock,addr clientroasterack, sizeclientroasterack, 0


	call	GetSequence
	mov	word ptr[clientsetstatus+2], ax
	invoke	send, hICQSock,addr clientsetstatus, sizeclientsetstatus, 0



;	call	GetSequence
;	mov	word ptr[clientchangestatus+2], ax
;	and	word ptr[clientchangestatus+22], 0
;	invoke	send, hICQSock, addr clientchangestatus,sizeclientchangestatus,0

	call	GetSequence
	mov	word ptr[clientready+2], ax
	invoke	send, hICQSock,addr clientready, sizeclientready, 0


ret
SendFamilies endp

;/////////////////////////////////

;//////////////////////////////////////////
SendToICQ proc targetUIN:DWORD,Text:DWORD

	lea	edi, SendBuff
	
	push sizeclientsendmsg1
	push offset [clientsendmsg1]
	push edi
	call [StringCopy2]

	add	edi, sizeclientsendmsg1
	call	GetSequence

	mov	word ptr[SendBuff+2], ax

	invoke lstrlen, targetUIN

	stosb

	push eax
	push targetUIN
	push edi
	call [StringCopy2]

	lea	edi, [edi+eax]

	push sizeclientsendmsg2
	push offset [clientsendmsg2]
	push edi
	call [StringCopy2]

	add	edi, sizeclientsendmsg2

	invoke lstrlen,Text

	push	eax
	add	eax, 4
	xchg	al, ah
	stosw

	add	ah, 0dh - 4
	adc	al, 0
	mov	[edi-11],ax
	xor	eax, eax
	stosd

	pop	eax

	push eax
	push Text
	push edi
	call [StringCopy2]

	add	edi, eax

	push sizeclientsendmsg3
	push offset [clientsendmsg3]
	push edi
	call [StringCopy2]

	mov	eax, edi

	sub	eax, offset [SendBuff]-sizeclientsendmsg3

	lea	ecx, [eax-6]

	xchg	cl, ch

	mov	word ptr[SendBuff+4], cx

	invoke	send, hICQSock, addr SendBuff, eax, 0

ret
SendToICQ endp

;////////////////////////////////////////
