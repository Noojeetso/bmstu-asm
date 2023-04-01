PUBLIC scan_menu_number
PUBLIC update_unsigned_hex

EXTRN print_newline: near
EXTRN print_space: near
EXTRN fill_hex_string_buffer: near

EXTRN unsigned_hex: byte

DATASEG SEGMENT PARA PUBLIC 'DATA'
	matrix_dimension_error_prompt DB 'Error: matrix dimensions should be positive numbers!', 13, 10, '$'  ; '
	digit_error_prompt DB 'Error: character must be between 0 and 9 or A and F inclusive (hexadecimal)', 13, 10, '$'  ; '
	unsigned_hex_input_prompt DB 'Input unsigned hex number: $'
	menu_number_prompt DB 'Input menu number: $'
	menu_number_error_prompt DB 'Error: menu number should be between 0 and 3 inclusive', 13, 10, '$'  ; '
	current_digit DB 0
	iterations_left DW 0
DATASEG ENDS

CODESEG SEGMENT para public 'CODE'
	ASSUME CS:CODESEG, DS:DATASEG
	

; RETURNS
; AX: RETURN CODE
; BX: INDEX IN JUMPTABLE
scan_menu_number proc near
	; LINK DS WITH DATA SEGMENT
	mov ax, DATASEG
	mov ds, ax
	
	; PRINT MENU NUMBER INPUT PROMPT
	mov dx, offset menu_number_prompt
	mov ah, 09h
	int 21h
	
	; INPUT MENU NUMBER INTO BX REGISTER
	mov ah, 01h
	int 21h
	xor bx, bx
	mov bl, al
	
	call print_newline
	
	; MENU ITEMS BOUNDS CHECK
	cmp bl, '0'
	jl input_error
	cmp bl, '3'
	jg input_error
	
	call print_newline
	
	; CONVERT FROM ASCII 
	sub bl, '0'
	; MULTIPLY INDEX BY TWO BECAUSE NEAR CALL USES TWO BYTES OFFSET
	mov al, bl
	mov cl, 2
	mul cl
	mov bl, al
	
	; SET RETURN CODE AS SUCCESS
	mov ax, 0
	ret
	
input_error:
	; PRINT MENU NUMBER INPUT ERROR PROMPT
	mov dx, offset menu_number_error_prompt
	mov ah, 09h
	int 21h
	
	call print_newline
	
	; SET RETURN CODE AS FAILURE
	mov ax, 1
	ret
scan_menu_number endp



; RETURNS
; AX: RETURN CODE
; CHANGES
; current_digit: INTEGER VALUE OF SCANNED HEX SYMBOL
scan_hex_digit proc near
	; SCAN ONE ASCII SYMBOL
	mov ah, 01h
	int 21h
	
	; SCAN ONE ASCII SYMBOL
	mov current_digit, al

	; REMEMBER THIS SYMBOL
	mov al, current_digit
	
	; SPECIFYING A GAP OF ASCII TABLE FOR FURTHER PROCESSING OF A NUMBER 
	cmp al, '0'
	jl not_hex
	cmp al, '9'
	jl hex_dec
	cmp al, 'a'
	jl not_hex
	cmp al, 'f'
	jle hex_lower_char
	cmp al, 'A'
	jl not_hex
	cmp al, 'F'
	jle hex_upper_char
	
not_hex:
	; DIGIT IS NOT HEXADECIMAL
	; SET RETURN CODE AS FAILURE
	mov ax, 1
	ret
hex_dec:
	; CONVERT FROM DIGIT CHAR TO INTEGER
	mov al, current_digit
	sub al, '0'
	mov current_digit, al
	; SET RETURN CODE AS SUCCESS
	mov ax, 0
	ret
hex_lower_char:
	; CONVERT FROM LOWER CHAR TO INTEGER
	mov al, current_digit
	sub al, 'a'
	add al, 10
	mov current_digit, al
	
	; SET RETURN CODE AS SUCCESS
	mov ax, 0
	ret
hex_upper_char:
	; CONVERT FROM UPPER CHAR TO INTEGER
	mov al, current_digit
	sub al, 'A'
	add al, 10
	mov current_digit, al
	
	; SET RETURN CODE AS SUCCESS
	mov ax, 0
	ret
scan_hex_digit endp



; DESCRIPTION:
; SCANS 2 BYTES OF HEX NUMBER AND FILLS HEX STRING BUFFER
; RETURNS:
; AX: RETURN CODE
; CHANGES
; hexadecimal_string: HEX STRING BUFFER
update_unsigned_hex proc near
	; LINK DS WITH DATA SEGMENT
	mov ax, DATASEG
	mov ds, ax

	; PRINT HEX INPUT PROMPT
	mov dx, offset unsigned_hex_input_prompt
	mov ah, 09h
	int 21h
	
	; CLEAR CURRENT HEX NUMBER
	mov word ptr [unsigned_hex], 0
	; 4 ITERATIONS FOR 4 SCANNED HEX CHARS
	mov cx, 4
read_number:
	; REMEMBER ITERATIONS AMOUNT TO RELEASE CX REGISTER
	mov iterations_left, cx
	; SET SI REGISTER FOR FURTHER INDEXING
	mov si, cx
	
	call scan_hex_digit
	; CHECK FOR SCAN SUCCESS
	cmp al, 0
	jne input_error
	
	;xor ax, ax
	; MOV SCANNED INTEGER DIGIT
	mov al, current_digit
	
	; MULTIPLY BY 16 IF IT'S HIGH HEX DIGIT IN BYTE
	test cx, 1
	jnz add_next_digit
	mov cl, 4
	shl al, cl
add_next_digit:
	; CALCULATE CURRENT BYTE INDEX IN HEX BUFFER (LITTLE ENDIAN)
	dec si
	shr si, 1
	add unsigned_hex[si], al
	
	; RETRIEVE ITERATIONS AMOUNT
	mov cx, iterations_left
	loop read_number
	
	call print_newline
	
	; UPDATE HEX STRING BUFFER
	call fill_hex_string_buffer
	
	; SET RETURN CODE AS SUCCESS
	mov ax, 0
	ret
	
input_error:
	call print_newline
	
	; PRINT SCAN HEX ERROR PROMPT
	mov dx, offset digit_error_prompt
	mov ah, 09h
	int 21h
	
	; SET RETURN CODE AS FAILURE
	mov ax, 1
	ret
update_unsigned_hex endp


CODESEG ENDS
END
