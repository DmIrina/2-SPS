dseg segment
msg_01 db "Assembler AUTS",10,13,'$'
msg_02 db "Lab 03, Var=07",10,13,'$'
msg_03 db "---------------------------",10,13,'$'
msg_err  db      10,13,"Incorrect input!$"
msg_v1 db "z = (15*x-1)/(y(x-y)) = $"
msg_v2 db "z = 35*x^2 + 8x = $"
msg_v3 db "z = (10-x)^2 = $"
msg_verr db "Error: x=y Divide of 0!",10,13,"$"
msg_over db "Error: Overriding!$"
msg_input db "> $"

msg_cr 	   db 10,13,'$'
msg_input_x db "Input x: $"
msg_input_y db "Input y: $"
msg_res_z db "z = $"
maxlen  = 10
len     = 0
buf db maxlen,len,maxlen DUP ('$')	; | 10 | 0 | $ | $ | $ | $ | $ | $ | $ | $ | $ | $ |  

dseg ends

sseg segment
sseg ends

cseg segment
assume cs:cseg, ss:sseg, ds:dseg

include macros3.asm

main proc

push ds
sub ax, ax
push ax

; ініціалізація DS
mov ax, dseg
mov ds, ax

; інформація про завдання
introduction msg_01, msg_02, msg_03

; введення числа x - строки та її перетворення в ціле
print msg_input_x
input_int buf, msg_input		; введення числа (ціле зі знаком), результат - в ax
mov bx, ax

; введення числа y
print msg_input_y
input_int buf, msg_input
mov cx, ax
  
; обчислення
	
func_z bx, cx


out_int ax		; вивід результату на екран

mov ax, 4C00h	; Finish
int 21h
main endp

cseg ends
end main