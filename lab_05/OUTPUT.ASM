PUBLIC print_newline
PUBLIC print_unsigned_hex
PUBLIC print_unsigned_bin
PUBLIC print_signed_dec

PUBLIC hexadecimal_string
PUBLIC binary_string
PUBLIC decimal_string

EXTRN fill_hex_string_buffer: near
EXTRN fill_binary_string_buffer: near
EXTRN fill_decimal_string_buffer: near

EXTRN unsigned_hex: byte

DATASEG SEGMENT PARA PUBLIC 'DATA'
	hex_number_output_prompt DB 'Current unsigned hexadecimal number: $'
	binary_number_output_prompt DB 'Output binary number: $'
	decimal_number_output_prompt DB 'Output decimal number: $'
	hexadecimal_string DB 5 DUP('$')
	binary_string DB 21 DUP('$')  ; 21 CHARS IN BUFFER (16 BIN DIGITS + 4 SPACES + EOL SYMBOL)
	decimal_string DB 7 DUP('$')  ; 4 HEX DIGITS CAN REPRESENT AT MAX 5 DECIMAL DIGITS + SIGN + EOL SYMBOL
	iterations_left DW 0
DATASEG ENDS

CODESEG SEGMENT para public 'CODE'
	ASSUME CS:CODESEG, DS:DATASEG


print_newline proc near
	mov ah, 02h
	
	mov dl, 10
	int 21h
	
	mov dl, 13
	int 21h
	
	ret
print_newline endp


print_space proc near
	mov ah, 02h
	mov dl, ' '
	int 21h
	
	ret
print_space endp


print_unsigned_hex proc near
	; LINK DS WITH DATA SEGMENT
	mov ax, DATASEG
	mov ds, ax
	
	; PRINT OUTPUT PROMPT
	mov dx, offset hex_number_output_prompt
	mov ah, 09h
	int 21h
	
	; UPDATE HEX STRING BUFFER
	call fill_hex_string_buffer
	
	; PRINT CONVERTED NUMBER
	mov ah, 09h
	mov dx, offset hexadecimal_string
	int 21h
	
	call print_newline
	
	ret
print_unsigned_hex endp


print_unsigned_bin proc near
	; LINK DS WITH DATA SEGMENT
	mov ax, DATASEG
	mov ds, ax
	
	; PRINT OUTPUT PROMPT
	mov dx, offset binary_number_output_prompt
	mov ah, 09h
	int 21h
	
	; UPDATE BINARY STRING BUFFER
	call fill_binary_string_buffer
	
	; PRINT CONVERTED NUMBER
	mov ah, 09h
	mov dx, offset binary_string
	int 21h
	
	call print_newline
	
	ret
print_unsigned_bin endp


print_signed_dec proc near
	; LINK DS WITH DATA SEGMENT
	mov ax, DATASEG
	mov ds, ax
	
	; PRINT OUTPUT PROMPT
	mov dx, offset decimal_number_output_prompt
	mov ah, 09h
	int 21h
	
	; UPDATE DECIMAL STRING BUFFER
	call fill_decimal_string_buffer
	
	; PRINT CONVERTED NUMBER
	mov ah, 09h
	mov dx, offset decimal_string
	int 21h
	
	call print_newline
	
	ret
print_signed_dec endp


CODESEG ENDS
END
