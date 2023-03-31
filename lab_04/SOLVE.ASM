PUBLIC delete_column_with_max_zeros

EXTRN print_newline: far

EXTRN matrix_max_rows: byte
EXTRN matrix_max_columns: byte
EXTRN matrix_rows: byte
EXTRN matrix_columns: byte
EXTRN matrix_data: byte

DATASEG SEGMENT PARA PUBLIC 'DATA'
	matrix_output_prompt DB 'Processed matrix:'
	DB 13
	DB 10
	DB '$'
	column_index_prompt DB 'Max column index: $'
	max_index DB 10
	cnt DB 0
	max_cnt DB 0
DATASEG ENDS

CODESEG SEGMENT para public 'CODE'
	ASSUME CS:CODESEG, DS:DATASEG


shift_columns proc near
	; check if there was columns with at least one zero value
	xor ax, ax
	mov al, max_index
	cmp al, 10
	je shift_end
	
	xor cx, cx
	mov cl, matrix_rows
	mov si, 0  ; row offset in bytes from the beginning of the matrix
	
	; erase column by shifting values in each row
shift_column_loop:
	; start shifting from the index of the column to be deleted
	xor ax, ax
	mov al, max_index
	mov bx, ax
	shift_row_loop:
		; check if it's the last value in a row
		inc bl
		cmp bl, matrix_columns
		je end_shift_row_loop
		dec bl
		
		; overwrite current value with next value in row
		mov al, matrix_data[si + bx + 1]
		mov matrix_data[si + bx], al
		
		inc bx
		
		jmp shift_row_loop
	end_shift_row_loop:
	
	; shift row offset by matrix_max_columns bytes to access a new row
	xor ax, ax
	mov al, matrix_max_columns
	add si, ax
	
	loop shift_column_loop
	
	; decrease matrix column amount by one
	dec matrix_columns
shift_end:
	
	ret
shift_columns endp
	
	
calculate_column_index proc near
	mov si, 0  ; current column index
	
column_loop:
	xor cx, cx
	mov cl, matrix_rows
	
	; start from the value in the first row
	mov bx, si
	
	mov cnt, 0  ; amount of zeros in the current column
	
	row_loop:
		mov al, matrix_data[bx]
		
		; check if the current value equals to zero
		cmp al, 0
		jne non_zero_value
		inc cnt
		
	non_zero_value:
		; shift row offset by matrix_max_columns bytes to access a new row of the same column
		xor ax, ax
		mov al, matrix_max_columns
		add bx, ax
	
		loop row_loop
	
	; check if the current column has more zeros than the previous maximum column
	mov al, max_cnt
	cmp cnt, al
	jle not_greater
	; update maximum zero amount
	mov al, cnt
	mov max_cnt, al
	; update maximum column index
	mov ax, si
	mov max_index, al
	
not_greater:
	inc si  ; increase current column index
	; jump to start if it's not the last column
	mov ax, si
	cmp al, matrix_columns
	jne short column_loop
	
	ret
calculate_column_index endp


; auxiliary function to print the index of the column with the maximum number of zeros
print_max_index proc near
	mov dx, offset column_index_prompt
	mov ah, 09h
	int 21h
	
	mov dl, max_index
	add dl, '0'
	mov ah, 02h
	int 21h
	
	call print_newline

	ret
print_max_index endp


delete_column_with_max_zeros proc far
	mov ax, DATASEG
	mov ds, ax
	
	call calculate_column_index
	
	;call print_max_index
	
	call shift_columns
	
	ret
delete_column_with_max_zeros endp


CODESEG ENDS
END
