dseg segment
msg_01 	db 	"Assembler AUTS",10,13,'$'
msg_02 	db 	"Lab 05 Task 02",10,13,'$'
msg_03 	db 	"-- number * 9 ---",10,13,'$'
msg_04 db "Enter the number < 7281 and >= 0:",10,13,'$'
msg_finish db 10,13,"Finish",10,13,'$'
msg_x9 db 10,13,"x9",10,13,"----------",10,13,'$'
msg_err db 10,13,"Incorrect input!$"
msg_over db 10,13,"Overflow. Number more than 7281!",10,13,'$'
maxlen  = 7
buf db maxlen,0,maxlen DUP ('$')		; | 10 | 0 | $ | $ | $ | $ | $ | $ | $ | $ | $ | $ |  

include macros2.asm


dseg ends

sseg segment
sseg ends

cseg segment
assume cs:cseg, ss:sseg, ds:dseg

main proc

push ds
sub ax, ax
push ax

; ініціалізація DS

mov ax, dseg 	
mov ds, ax

;-------------------------------
; введення числа й множення на 9
;-------------------------------

; інформація про завдання
introduction msg_01, msg_02, msg_03

; введення числа - строки
input_str buf			

; виведення строки на екран
print buf+2              ; пропустити 2 байта буфера
print msg_x9

; строка -> число

string_to_int buf

; обчислення: множення на 9

mov dx, 09
mul dx

;вивід результату з ах на екран
out_int ax

; повідомлення про завершення
print msg_finish

mov ax, 4C00h
int 21h
	
; повідомлення про загальні помилки	
common_err:
	mov ah, 9h
	lea dx, msg_err
	int 21h
	mov ax, 4C00h
	int 21h	
        		
; переповнення		
over_err:
	mov ah, 9h
	lea dx, msg_over
	int 21h
	mov ax, 4C00h
	int 21h
	
main endp



cseg ends
end main