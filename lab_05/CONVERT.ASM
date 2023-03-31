PUBLIC fill_hex_string_buffer
PUBLIC fill_binary_string_buffer
PUBLIC fill_decimal_string_buffer

EXTRN unsigned_hex: byte
EXTRN hexadecimal_string: byte
EXTRN binary_string: byte
EXTRN decimal_string: byte

DATASEG SEGMENT PARA PUBLIC 'DATA'
	iterations_left DW 0
	signed_hex DB 2 DUP(?)
	decimal_number DB 3 DUP(?)
	multiplier DB 16
	converted_digit DB 0
DATASEG ENDS


CODESEG SEGMENT para public 'CODE'
	ASSUME CS:CODESEG, DS:DATASEG


fill_hex_string_buffer proc near
	; LINK DS WITH DATA SEGMENT
	mov ax, DATASEG
	mov ds, ax
	
	mov cx, 4
	
print_unsigned_hex_digit:
	mov iterations_left, cx
	mov si, cx
	
	dec si
	shr si, 1
	mov dl, unsigned_hex[si]
	
	; CHECK IF IT'S LOW SYMBOL IN BYTE
	test cx, 1
	mov cl, 4  ; PREPARE FOR THE BYTE SHIFTING
	jz byte_to_hex
	; MULTIPLY NUMBER BY 16 (HIGH BYTES NOW ZERO)
	shl dl, cl
	
byte_to_hex:
	; DIVIDE NUMBER BY 16 (FOR BOTH HIGH AND LOW BYTES CONVERSIIONS)
	shr dl, cl
	cmp dl, 9
	jg extended_hex_digit
	add dl, '0'
	jmp end_unsigned_hex_digit_conversion
extended_hex_digit:
	sub dl, 10
	add dl, 'A'
end_unsigned_hex_digit_conversion:
	mov si, 4
	sub si, iterations_left
	mov hexadecimal_string[si], dl
	
	mov cx, iterations_left
	loop print_unsigned_hex_digit																																																															
	
	ret
fill_hex_string_buffer endp


fill_binary_byte proc near
	mov cx, 4
print_bin_digit:
	mov dl, 0
	test bl, 8
	jz leave_zero
	inc dl
leave_zero:
	add dl, '0'
	mov binary_string[di], dl
	inc di
	
	shl bl, 1
	
	loop print_bin_digit
	
	mov binary_string[di], ' '
	inc di
	
	ret
fill_binary_byte endp


fill_binary_string_buffer proc near
	; LINK DS WITH DATA SEGMENT
	mov ax, DATASEG
	mov ds, ax
	
	; CLEAR STRING BUFFER
	mov cx, 21
dec_clear_loop:
	mov si, cx
	dec si
	mov binary_string[si], '$'
	loop dec_clear_loop
	
	mov cx, 4
	mov di, 0
	
fill_binary_byte_loop:
	mov iterations_left, cx
	mov si, cx
	
	dec si
	shr si, 1
	xor ax, ax
	mov bl, unsigned_hex[si]
	
	test cx, 1
	mov cl, 4  ; PREPARE FOR THE BYTE SHIFTING
	jz byte_to_string
	; MULTIPLY NUMBER BY 16 (HIGH BYTES NOW ZERO)
	shl bl, cl
	
byte_to_string:
	; DIVIDE NUMBER BY 16 (FOR BOTH HIGH AND LOW BYTES CONVERSIIONS)
	shr bl, cl
	
	call fill_binary_byte
	
	mov cx, iterations_left
	loop fill_binary_byte_loop
	
	ret
fill_binary_string_buffer endp


from_twos_complement proc near
	mov ax, word ptr [unsigned_hex]
	;dec ax  ; ax -= 1
	;xor ax, 65535  ; INVERT ALL BITS (~ax)
	mov signed_hex[0], al  ; SET BIG_ENDIAN SIGNED HEX LOW BYTE
	mov signed_hex[1], ah  ; SET BIG_ENDIAN SIGNED HEX HIGH BYTE
	
	ret
from_twos_complement endp


fill_decimal_string_buffer proc near
	; LINK DS WITH DATA SEGMENT
	mov ax, DATASEG
	mov ds, ax
	
	; CALCULATE SIGNED BINARY HEX
	call from_twos_complement
	
	; CLEAR STRING BUFFER
	mov cx, 7
dec_clear_loop:
	mov si, cx
	dec si
	mov decimal_string[si], '$'
	loop dec_clear_loop
	
	xor cx,cx  ; STORES DECIMAL DIGITS AMOUNT

	mov si, 0  ; DECIMAL STRING BUFFER POINTER
	
	; CONVERT NUMBER
	; CHECK MINUS SIGN
	mov ax, word ptr [signed_hex]  ; LOAD NUMBER TO AX
	mov bx, ax
	and ax, 7FFFh
	and bx, 8000h
	cmp bx, 0
	je hex_to_dec_cycle
	mov decimal_string[si], '-'
	inc si
	
	; WRITE DECIMAL DIGITS TO STACK
hex_to_dec_cycle:
	mov bx, 10  ; DIVIDE NUMBER AX BY 10
	xor dx, dx  ; DX STORES LAST DECIMAL DIGIT
	div bx  ; DX:AX / BX = AX:QUOTIENT DX:REMAINDER
	
	push dx  ; PUSH TO STACK
	inc cx  ; INCREASE DIGITS AMOUNT
	
	cmp ax, 0  ; CHECK IF QUOTIENT IS ZERO
	jg hex_to_dec_cycle  ; LOOP WHILE QUOTIENT IS NOT ZERO
	
	; WRITE DECIMAL DIGITS TO BUFFER FROM STACK
fill_buffer_loop:
	pop dx  ; GET LAST ADDED DECIMAL DIGIT
	add dl, '0'  ; CONVERT DECIMAL DIGIT TO ASCII CHAR
	mov decimal_string[si], dl  ; PUT CHAR INTO BUFFER STRING
	inc si  ; INCREASE STRING BUFFER POINTER
	loop fill_buffer_loop  ; LOOP WHILE THERE ARE DIGITS IN STACK
	
	ret
fill_decimal_string_buffer endp


CODESEG ENDS
END
