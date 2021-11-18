dseg segment
msg_01 	db 	"Assembler AUTS",10,13,'$'
msg_02 	db 	"Lab 02",10,13,'$'
msg_03 	db 	"-- number * 9 ---",10,13,'$'
msg_04 db "Enter the number < 7281 and >= 0:",10,13,'$'
msg_finish db 10,13,"Finish",10,13,'$'
msg_x9 db 10,13,"x9",10,13,"----------",10,13,'$'
msg_err db 10,13,"Incorrect input!$"
msg_over db 10,13,"Overflow. Number more than 7281!",10,13,'$'
maxlen  = 7
string db maxlen,0,maxlen DUP ('$')		; | 10 | 0 | $ | $ | $ | $ | $ | $ | $ | $ | $ | $ |  
dseg ends

sseg segment
sseg ends

cseg segment
assume cs:cseg, ss:sseg, ds:dseg

main proc far

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

call introduction 

; введення числа - строки

mov ah, 0ah
lea dx, string
int 21h

; виведення строки на екран

mov ah, 9h
lea dx, string+2
int 21h
lea dx, msg_x9
int 21h

; строка -> число

call string_to_int

; обчислення: множення на 9

mov dx, 09
mul dx

;вивід результату з ах на екран

call out_int
		
; повідомлення про завершення
   		
mov ah, 9h
lea dx, msg_finish
int 21h
ret		
     		
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

;----------------------
; процедури 
;----------------------

; introduction - вивід інформації

introduction proc
    mov ah, 9h
    lea dx, msg_01
    int 21h
    lea dx, msg_02
    int 21h
    lea dx, msg_03
    int 21h
    lea dx, msg_04
    int 21h
	ret
introduction endp


; string_to_int - строка цифр у число 

; на вхід: string - строка (буфер): 
; 0-й байт - розмір буферу, 1-й - кількість введених символів
; 2-й - .... - символи для перетворення 						
; на вихід: число з ах

string_to_int proc
					
        xor ax, ax                   
        lea di, string+2    ; di - індексний регістр - вказує на строку з цифрами
		lea bx, string+1	; адреса другого елемента буферу
		mov cx, [bx]    	; кількість введених символів - довжина строки
		xor ch, ch           		
        mov si, 10                  
        xor bh, bh                  
					        
@@start_loop:
        mul si              ; множення вмісту ax на вміст si(10)
        mov bl,[di]         ; bl <- наступний символ
        cmp bl, 30h         ; порівняння з 0
        jl common_err       ; якщо менше
        cmp bl, 39h         ; порівняння з 9
        jg common_err       ; якщо більше
        sub bl,30h          ; -30h
        add ax,bx           ; + до суми в ax
        inc di              ; інкремент di
        loop @@start_loop   ; повтор циклу
	cmp ax, 7281            ; порівняння введеного числа з максимально можливим: для уникнення переповнення
        jg over_err         ; якщо більше
	ret

string_to_int endp


; out_int виведення знакового 16-розрядного числа з AX на екран

; вхід: 	ax - число для відображення 
; вихід:  	число на екрані

out_int proc
        mov bx, 10      
        xor cx, cx      	; кількість символів у модулі числа
        @@divide:           ; ділення на 10
                xor dx, dx
                div bx		; ax = ax/10
                push dx     ; остача -> стек
                inc cx      ; кількість цифр у числі
                or ax, ax
        jnz     @@divide    ; повторення, поки у числі є цифри (ax != 0)
        mov     ah, 02h		; вивід символа (int 21h у циклі)
        @@store:
                pop dx      ; дістати цифри (остачу від ділення на 10) зі стеку
                add dl, 30h ; цифри -> символи (30h)
                int 21h     ; виведення на екран
        loop    @@store
	ret
out_int endp

cseg ends
end main