.code

HandleRecv proc RecvPacket:DWORD

	mov edi,RecvPacket

	mov	ah, [edi+6]
	mov	al, [edi+7]  ;family
	movzx	eax, ax

	mov	ch, [edi+8]
	mov	cl, [edi+9]  ;command
	movzx	ecx, cx

	cmp eax,4
	jne @back
	cmp ecx,7
	jne @back

	add	edi, 27
	movzx	eax, byte ptr[edi-1]

	push eax
	push edi
	push offset [Cookie]
	call [StringCopy2]

	lea	edi,[eax+edi+8]

	searchfortlv2:
	cmp	word ptr[edi-4], 200h
	jz	tlv2found
	cmp	word ptr[edi-4], 500h
	jz	tlv5found
	movzx	eax, word ptr[edi-2]
	xchg	al, ah
	lea	edi, [edi+eax+4]
	jmp	searchfortlv2
      tlv2found:     ;the standard plain text channel
	movzx	ecx, word ptr[edi-2]
	xchg	cl, ch
      searchmsg:
	add	edi, 2
	movzx	edx, word ptr[edi]
	xchg	dl, dh
	cmp	word ptr[edi-2], 101h
	jnz	@F
	add	edi, 6
	lea	eax,[edx-4]

	push eax
	push edi
	push offset [TextBuff]
	call [StringCopy2]	;extract message

	push offset Cookie
	call [atodw2]

	invoke parsein,eax,addr TextBuff
	;invoke SendToICQ,addr Cookie,addr TextBuff
	;invoke MessageBox,0,addr TextBuff,addr Cookie,0

	jmp	@back
      @@:
	add	edx, 2
	lea	edi,[edi+edx]
	sub	ecx, edx
	jns	searchmsg
	jmp	@back
      tlv5found:
;////////////////////
	searchfortlv2new:
	cmp	word ptr[edi-4], 200h
	jz	tlv2foundnew
	movzx	eax, word ptr[edi-2]
	xchg	al, ah
	lea	edi, [edi+eax+4]
	jmp	searchfortlv2new
      tlv2foundnew:     ;the standard plain text channel
	movzx	eax, word ptr[edi-2]
	xchg	al, ah
	sub 	eax,14
	add	edi,14

	push eax
	push edi
	push offset [TextBuff]
	call [StringCopy2]	;extract message

	push offset Cookie
	call [atodw2]

	invoke parsein,eax,addr TextBuff

;////////////////////
;	add	edi, 8
;	movzx	eax,word ptr[edi-2]
;	movzx	ecx,byte ptr[edi-4]
;        stdcall StringCopy2,buffer,ebx,eax

	jmp	@back


@back:

	ret
HandleRecv endp
