;nasm -f elf32 -o <filename>.o <filename>.asm
;ld -m elf_i386 -o mesajDenori mesajDenori.o

; This code reads an integer n and prints
; a message on the stdout n times

;	SYS_EXIT equ 1
;	sysWrite equ 4
;	sysRead equ 3
;	stdin equ 0
;	stdout equ 1

section .text
	global _start
	_start:
		;printing a guiding message
		mov eax, sysWrite
		mov ebx, stdout
		mov ecx, introMsg
		mov edx, lenIntro
		int 0x80
		 
		;this chunk reads any integer between -99 and 99
		;byte by byte
		;first it reads the tens
		mov eax, sysRead
		mov ebx, stdin
		mov ecx, noTens
		mov edx, 1
		int 0x80	

		;then the units
		mov eax, sysRead
		mov ebx, stdin
		mov ecx, noUnits
		mov edx, 1
		int 0x80	
	
		;checks for one digit numbers
		;if the units have the number 10 (ascii for \n) within them 
		;it jumps at "oneUnit"
		cmp byte [noUnits], 10 	
		je oneUnit

		;minimally dealing with overflow
		mov eax, sysRead
		mov ebx, stdin
		mov ecx, buffer
		mov edx, 1
		int 0x80
		
		;checking for negative numbers
		cmp byte [noTens], "-"
		je negative

		;converting to ascii
		sub byte [noTens], 48

		tens:
			xor eax, eax
			mov al, [tensCounter]
			mov ah, [noTens]
			cmp al, ah
			je units

		tensPrinting:
			;actual message printing
			mov eax, sysWrite
			mov ebx, stdout
			mov ecx, msgRepetat
			mov edx, lenRepetat
			int 0x80		

			;clearing registers
			xor eax, eax
			xor ebx, ebx
			xor edx, edx

			inc word [tensCounter]
			
			mov al, 10
			mov dl, [noTens]
			mul dl
			;multiplying is by default between the dl and al registers
			;the result is subsequently stored in ax

			mov bx, [tensCounter]
		 	cmp ax, bx
			jne tensPrinting
		
		units:
		;ascii conversion
		sub byte [noUnits], 48

		;particular case for 0
		xor eax, eax
		mov al, [counter]
		mov ah, [noUnits]
		cmp al, ah
		je exit

		unitsPrinting:
			;actual message printing
			mov eax, sysWrite
			mov ebx, stdout
			mov ecx, msgRepetat
			mov edx, lenRepetat
			int 0x80
			
			;incrementing the counter until it gets to the noUnits
			xor eax, eax
			inc byte [counter]
			mov al, [counter]
			mov ah, [noUnits]
			
			cmp al, ah
			jne unitsPrinting
			je exit

		oneUnit:
			xor eax, eax

			mov al, [noTens]
			mov [noUnits], al
			
			cmp al, al
			je units
		
		negative:
			;if there is an endline in the current buffer there's no need for another one
			xor eax, eax
			cmp byte [buffer], 10
			je noNeed4Buffer

			;recycleing the buffer to account for -(a number)endline
			;in total 3 bytes accounted for
			mov eax, sysRead
			mov ebx, stdin
			mov ecx, buffer
			mov edx, 1
			int 0x80
			
			noNeed4Buffer:
			mov eax, sysWrite
			mov ebx, stdout
			mov ecx, negativeCase
			mov edx, lenNegativeCase
			int 0x80

		exit:
			mov ebx, 0
			mov eax, SYS_EXIT
			int 0x80

section .bss
	noUnits resb 1
	buffer resb 1
	noTens resb 1

section .data
	introMsg db "in order to print a message n times,", 0ah, "please pick a number between -99 and 99:", 0ah, 0h
	lenIntro equ $-introMsg
	
	negativeCase db "negative numbers don't really make sense...", 0ah, "not in this context at least", 0ah, 0h
	lenNegativeCase equ $-negativeCase

	msgRepetat db "Good pick! I love this particular number", 0ah, 0h
	lenRepetat equ $-msgRepetat
	
	counter db 0
	;word deoarece am nevoie de 2 octeti pentru comparatia cu ax
	tensCounter dw 0

	SYS_EXIT equ 1
	sysWrite equ 4
	sysRead equ 3
	stdin equ 0
	stdout equ 1