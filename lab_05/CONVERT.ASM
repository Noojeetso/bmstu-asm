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


; CHANGES
; hexadecimal_string: HEX STRING BUFFER
fill_hex_string_buffer proc near
	; LINK DS WITH DATA SEGMENT
	mov ax, DATASEG
	mov ds, ax
	
	mov cx, 4  ; 4 ITERATIONS FOR 4 PROCESSED HEX DIGITS
print_unsigned_hex_digit:
	mov iterations_left, cx  ; REMEMBER ITERATIONS AMOUNT TO RELEASE CX REGISTER
	mov si, cx  ; SET SI REGISTER FOR FURTHER INDEXING
	
	; CALCULATE CURRENT BYTE INDEX IN HEX BUFFER (LITTLE ENDIAN)
	dec si
	shr si, 1
	mov dl, unsigned_hex[si]  ; GET CURRENT BYTE FROM HEX BUFFER
	
	; CHECK IF IT'S LOW DIGIT IN BYTE
	test cx, 1
	mov cl, 4  ; PREPARE FOR BIT SHIFTING
	jz byte_to_hex
	shl dl, cl  ; MULTIPLY NUMBER BY 16 (PUT LOW DIGIT IN PLACE OF HIGH DIGIT)
	
byte_to_hex:
	shr dl, cl  ; DIVIDE NUMBER BY 16 (FOR BOTH HIGH AND LOW DIGITS CONVERSIIONS)
	cmp dl, 9  ; CHECK IF HEX DIGIT CAN BE REPRESENTED AS DECIMAL DIGIT
	jg extended_hex_digit
	; INTEGER DIGIT IS IN RANGE BETWEEN 0 AND 9
	add dl, '0'
	jmp end_unsigned_hex_digit_conversion
extended_hex_digit:
	; INTEGER DIGIT IS IN RANGE BETWEEN 10 AND 15 ('A' AND 'F')
	sub dl, 10
	add dl, 'A'
end_unsigned_hex_digit_conversion:
	mov si, 4  ; SET INDEX VALUE TO MAX_INDEX + 1
	sub si, iterations_left  ; SUBTRACT REMAINING AMOUNT OF ITERATIONS FROM INDEX VALUE
	mov hexadecimal_string[si], dl  ; WRITE CURRENT CHAR IN HEX STRING BUFFER
	
	mov cx, iterations_left  ; RETRIEVE ITERATIONS AMOUNT
	loop print_unsigned_hex_digit																																																															
	
	ret
fill_hex_string_buffer endp


; RECIEVES
; BL: CURRENT HEX DIGIT 
; CHANGES
; binary_string: BINARY STRING BUFFER
fill_binary_byte proc near
	mov cx, 4  ; 1 HEX DIGIT REPRESENTS 4 BINARY DIGITS
	; PROCESS ALL BITS OF A DIGIT FROM LEFT TO RIGHT
fill_bin_digits:
	mov dl, 0  ; CLEAR DL REGISTER
	test bl, 8  ; CHECK LEFT BIT OF THE DIGIT
	jz leave_zero  ; CHECK IF THE LEFT BIT EQUALS TO 1
	inc dl  ; SET DL REGISTER TO 1 IF THE LEFT BIT EQUALS TO 1
leave_zero:
	add dl, '0'  ; CONVERT BINARY DIGIT TO ASCII CHAR
	mov binary_string[di], dl  ; WRITE CURRENT CHAR INTO BINARY STRING BUFFER
	inc di  ; INCREMENT INDEX OF CURRENT CHAR IN STRING BUFFER
	
	shl bl, 1  ; SHIFT ALL BITS TO THE LEFT BY ONE
	
	loop fill_bin_digits
	
	mov binary_string[di], ' '  ; WRITE SEPARATOR (SPACE) AFTER EVERY 4 BINARY DIGITS 
	inc di  ; INCREMENT INDEX OF CURRENT CHAR IN STRING BUFFER
	
	ret
fill_binary_byte endp


; CHANGES
; binary_string: BINARY STRING BUFFER
fill_binary_string_buffer proc near
	; LINK DS WITH DATA SEGMENT
	mov ax, DATASEG
	mov ds, ax
	
	; CLEAR BINARY STRING BUFFER
	mov cx, 21  ; 21 CHARS IN BUFFER (16 BIN DIGITS + 4 SPACES + EOL SYMBOL)
dec_clear_loop:
	mov si, cx
	dec si
	mov binary_string[si], '$'
	loop dec_clear_loop
	
	mov cx, 4  ; 4 ITERATIONS FOR 4 PROCESSED HEX DIGITS
	mov di, 0
fill_binary_byte_loop:
	mov iterations_left, cx  ; REMEMBER ITERATIONS AMOUNT TO RELEASE CX REGISTER
	mov si, cx  ; SET SI REGISTER FOR FURTHER INDEXING
	
	; CALCULATE CURRENT BYTE INDEX IN HEX BUFFER (LITTLE ENDIAN)
	dec si  ; INDEXING STARTS FROM ZERO
	shr si, 1  ; THERE ARE TWO HEX DIGITS IN BYTE, SO DIVIDE COUNTER BY TWO
	mov bl, unsigned_hex[si]  ; WRITE CURRENT BYTE TO PROCESS INTO BL REGISTER
	
	test cx, 1  ; EVEN/ODD DIGIT IN BYTE SEPARATION
	mov cl, 4  ; PREPARE FOR BIT SHIFTING
	jz byte_to_string  ; JUMP IF IT'S HIGH DIGIT IN BYTE
	shl bl, cl  ; IT'S LOW DIGIT SO MULTIPLY NUMBER BY 16 (HIGH DIGIT IS NOW ZERO DUE TO OVERFLOW)
	
byte_to_string:
	shr bl, cl  ; DIVIDE NUMBER BY 16 (FOR BOTH HIGH AND LOW DIGITS CONVERSIIONS)
	
	call fill_binary_byte
	
	mov cx, iterations_left  ; RETRIEVE ITERATIONS AMOUNT
	loop fill_binary_byte_loop
	
	ret
fill_binary_string_buffer endp


get_signed_hex proc near
	; READ LITTLE-ENDIAN 2-BYTE HEX NUMBER
	mov ax, word ptr [unsigned_hex]
	; WRITE BIG-ENDIAN SIGNED HEX LOW BYTE
	mov signed_hex[0], al
	; WRITE BIG-ENDIAN SIGNED HEX HIGH BYTE
	mov signed_hex[1], ah
	
	ret
get_signed_hex endp


fill_decimal_string_buffer proc near
	; LINK DS WITH DATA SEGMENT
	mov ax, DATASEG
	mov ds, ax
	
	; CONVERT TO BIG-ENDIAN SIGNED HEX
	call get_signed_hex
	
	; CLEAR STRING BUFFER
	mov cx, 7  ; 7 CHARS IN BUFFER
dec_clear_loop:
	mov si, cx
	dec si
	mov decimal_string[si], '$'
	loop dec_clear_loop
	
	xor cx, cx  ; STORES DECIMAL DIGITS AMOUNT

	mov si, 0  ; CURRENT CHAR INDEX IN DECIMAL STRING BUFFER
	
	; CONVERT NUMBER
	; CHECK FOR MINUS SIGN
	mov ax, word ptr [signed_hex]  ; LOAD SIGNED HEX NUMBER TO AX
	mov bx, ax  ; COPY HEX NUMBER BECAUSE LOGICAL AND OPERATION CHANGES REGISTER VALUE
	and ax, 7FFFh  ; SET SIGN BIT TO ZERO
	and bx, 8000h  ; LOGICAL AND BETWEEN HEX NUMBER AND LAST (SIGN) BIT
	cmp bx, 0  ; CHECK IF SIGN BIT IS ZERO
	je hex_to_dec_cycle  ; SKIP MINUS SIGN APPENDING IF SIGN BIT EQUALS TO ZERO
	mov decimal_string[si], '-'  ; WRITE MINUS SIGN TO STRING BUFFER
	inc si  ; INCREASE CURRENT CHAR INDEX
	
	; WRITE DECIMAL DIGITS TO STACK
hex_to_dec_cycle:
	mov bx, 10  ; DIVIDE NUMBER IN AX REGISTER BY 10
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
