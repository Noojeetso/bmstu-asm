PUBLIC read_matrix

EXTRN print_newline: far
EXTRN print_space: far

EXTRN matrix_max_rows: byte
EXTRN matrix_max_columns: byte
EXTRN matrix_rows: byte
EXTRN matrix_columns: byte
EXTRN matrix_data: byte

DATASEG SEGMENT PARA PUBLIC 'DATA'
	matrix_dimension_error_prompt DB 'Error: matrix dimensions should be positive numbers!' ;'
	DB 13
	DB 10
	DB '$'
	symbol_error_prompt DB 'Error: character must be between 0 and 9!' ;'
	DB 13
	DB 10
	DB '$'
	matrix_input_columns_prompt DB 'Input matrix columns amount: $'
	matrix_input_rows_prompt DB 'Input matrix rows amount: $'
	matrix_input_prompt DB 'Input matrix row by row:'
	DB 13
	DB 10
	DB '$'
	current_row DB 0
DATASEG ENDS

CODESEG SEGMENT para public 'CODE'
	ASSUME CS:CODESEG, DS:DATASEG


scan_matrix_columns_amount proc near
	mov dx, offset matrix_input_columns_prompt
	mov ah, 09h
	int 21h
	
	mov ah, 01h
	int 21h
	sub al, '0'
	mov matrix_columns, al
	
	call print_newline
	
	ret
scan_matrix_columns_amount endp


scan_matrix_rows_amount proc near
	mov dx, offset matrix_input_rows_prompt
	mov ah, 09h
	int 21h
	
	mov ah, 01h
	int 21h
	sub al, '0'
	mov matrix_rows, al
	
	call print_newline
	
	ret
scan_matrix_rows_amount endp


read_matrix_row proc near
	mov si, 0  ; value index in the matrix row
	
read_matrix_value:	
	; calculate current value offset in bytes from the beginning of the matrix
	mov al, matrix_max_columns
	mul current_row
	mov bx, ax  ; current row offset
	
	; input symbol
	mov ah, 01h
	int 21h
	
	; check if symbol belongs to a number interval
	cmp al, '0'
	jl symbol_error
	cmp al, '9'
	jg symbol_error
	
	; write value to matrix
	sub al, '0'
	mov matrix_data[bx + si], al
	
	call print_space
	
	inc si
	
	; do a new iteration if it's not the last column
	mov ax, si
	cmp al, matrix_columns
	jne short read_matrix_value
	
	call print_newline
	
	; set return code to success for MAIN module to check
	mov ax, 0
	
	ret
	
symbol_error:
	call print_newline
	
	mov dx, offset symbol_error_prompt
	mov ah, 09h
	int 21h
	
	; set return code to error for MAIN module to check
	mov ax, 1
	
	ret
read_matrix_row endp


read_matrix proc far
	mov ax, DATASEG
	mov ds, ax
	
	call scan_matrix_columns_amount
	
	; check if matrix columns amount belongs to the interval from 1 to 9
	mov al, matrix_columns
	add al, '0'
	cmp al, '1'
	jl matrix_dimension_error
	cmp al, '9'
	jg matrix_dimension_error
	
	call scan_matrix_rows_amount
	
	; check if matrix rows amount belongs to the interval from 1 to 9
	mov al, matrix_rows
	add al, '0'
	cmp al, '1'
	jl matrix_dimension_error
	cmp al, '9'
	jg matrix_dimension_error
	
	; scan matrix row by row
	mov dx, offset matrix_input_prompt
	mov ah, 09h
	int 21h
	
	xor cx, cx
	mov cl, matrix_rows
	mov current_row, 0
read_loop:
	call read_matrix_row
	
	; check if the row was read successfully
	cmp ax, 0
	jne input_error
	
	inc current_row
	loop read_loop
	
	; set return code to success for MAIN module to check
	mov ax, 0
	
	ret

matrix_dimension_error:
	mov dx, offset matrix_dimension_error_prompt
	mov ah, 09h
	int 21h
	
input_error:
	; set return code to error for MAIN module to check
	mov ax, 1
	
	ret
read_matrix endp


CODESEG ENDS
END
