.code

GetSequence proc
	inc [Sequence]
	mov eax,[Sequence]
	xchg	ah, al	;network bit
	ret
GetSequence endp

;/////////////////////////////////////////////

RoastPassword proc _password:DWORD,_roast:DWORD
	mov eax, [_password]
	mov ecx, [_roast]
@beginloop:
	mov dl, [eax]
	test dl, dl
	jz @done
	cmp byte ptr[ecx],0
	jnz @F
	mov ecx, [_roast]
@@:
	xor dl, [ecx]
	inc ecx
	mov [eax], dl
	inc eax
	jmp @beginloop
@done:
	ret
RoastPassword endp

;//////////////////////////////////////////////////

StringCopy2 proc
	pushad
	mov	esi, [esp+8+32]
	mov	edi, [esp+4+32]
	mov	ecx, [esp+12+32]
	dec	ecx
	mov	byte ptr[ecx+edi+1], 0
  @@:
	mov	al, [esi+ecx]
	mov	[edi+ecx],al
	dec	ecx
	jns	@B
	popad
	retn 12
ret
StringCopy2 endp

;///////////////////////////////////////

atodw2 proc
	pushad
	mov	eax,[esp+4+32]
	mov	dl,[eax]
	xor	ecx,ecx
	cmp	dl,2Eh
	lea	esi,[eax-1]
	sbb	edx,edx
	mov	eax,ecx
@@:	adc	esi,1
	lea	eax,[eax+4*eax]
	lea	eax,[ecx+2*eax]
	mov	cl,[esi]
	sub	ecx,30h
	jns	@B
	add	eax,edx
	xor	eax,edx
	mov	[esp+28],eax
	popad
	ret 4
atodw2 endp

;//////////////////////////////////

FindCommand proc Text:DWORD,RecuPtr:DWORD
push esi
push edi

	invoke lstrlen,Text
	xchg eax,ecx

	xor eax,eax

	cld
	mov edi,Text
	mov esi,RecuPtr
	repe cmpsb

pop edi
pop esi

	jne @ArraysAreDifferent
	inc eax
@ArraysAreDifferent:
	ret

;	mov TextLen,eax
;
;	xor esi,esi					;очиска смещения от смещения edx
;
;	n111:
;
;	mov eax,Text				;вычисление адреса байта
;	add eax,esi
;	mov cl,byte ptr [eax]			;занести в cl l байт
;
;	mov eax,RecuPtr
;	add eax,esi
;
;	cmp byte ptr[eax],cl			; сравнить с пакетом
;	jne n12					; если не сходитсо - идем нахуй
;
;	inc esi					; esi ++
;	cmp esi,TextLen
;	jne n111
;
;	pop ecx
;	pop esi
;
;	mov eax,1
;	ret
;
;	n12:
;
;	pop ecx
;	pop esi
;
;	mov eax,0
FindCommand endp
