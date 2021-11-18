dseg segment
msg_01 db "Assembler AUTS",10,13,'$'
msg_02 db "Lab 03, Var=07",10,13,'$'
msg_03 db "---------------------------",10,13,'$'
msg_err  db      10,13,"Incorrect input!$"
msg_v1 db "z = (15*x-1)/(y(x-y)) = $"
msg_v2 db "z = 35*x^2 + 8x = $"
msg_v3 db "z = (10-x)^2 = $"
msg_verr db "Error: x=y Divide of 0!$"
msg_over db "Error: Overriding!$"

msg_cr 	   db 10,13,'$'
msg_input_x db "Input x = $"
msg_input_y db "Input y = $"
msg_res_z db "z = $"
maxlen  = 10
len     = 0
string  db      maxlen,len,maxlen DUP ('$')	; | 10 | 0 | $ | $ | $ | $ | $ | $ | $ | $ | $ | $ |  

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

; інформація про завдання

call introduction

; введення числа x - строки

lea dx, msg_input_x
call print
mov ah, 0ah		; ввід строки
lea dx, string
int 21h
call print_cr

; строка x -> число

call string_to_int
mov bx, ax

; введення числа y - строки

lea dx, msg_input_y
call print
mov ah, 0ah
lea dx, string
int 21h
call print_cr

; строка y -> число

call string_to_int
mov cx, ax
  
; обчислення
	
call func_z

; вивід результату з ах на екран

call out_int
mov ax, 4C00h	; Finish
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
	ret
introduction endp 

; вивід строки на екран
; на вхід: [dx] - строка 

println proc 
	push ax
	mov ah, 9h	
    int 21h
	lea dx, msg_cr
    int 21h
	pop ax	
	ret
println endp 


; вивід строки на екран (без cr)
; на вхід: [dx] - строка 

print proc 
	push ax
	mov ah,9h
    int 21h
	pop ax	
	ret
print endp 

; \n

print_cr proc 
	push	ax
	push	dx
	mov     ah, 9h
	lea     dx, msg_cr
    int     21h
	pop 	dx	
	pop 	ax	
	ret
print_cr endp 

; string_to_int - строка цифр у число 

; на вхід: string - строка (буфер): 
; 0-й байт - розмір буферу, 1-й - кількість введених символів
; 2-й - .... - символи для перетворення 						
; на вихід: число з ах

string_to_int proc
	push bx
	push dx
        xor ax, ax                   
        lea di, string+2     ; di - індексний регістр - вказує на строку з цифрами
		lea bx, string+1	 ; адреса другого елемента буферу
		mov cx, [bx]    	 ; кількість введених символів - довжина строки
		xor ch, ch              
        mov si, 10            
        xor bh, bh                   
	mov dl, [di]
	push dx
	cmp dl, '-'  			 ; перевірка: '-'?
	jne @@start_loop   		 ; ні - перехід на обробку
	inc di           	     ; інкремент di - пропустити "-1"
	dec cx			  		 ; в циклі на 1 цифру менше

        
@@start_loop:
        mul si           	 ; вміст ax * вміст si(10)
	jo	@@override			 ; флаг of == 1 - переповнення
        mov bl, [di]         ; bl <- наступний символ
        cmp bl, 30h     	 ; порівняння з 0
        jl @@common_err 	 ; якщо менше
        cmp bl, 39h     	 ; порівняння з 9
        jg @@common_err  	 ; якщо більше
        sub bl, 30h      	 ; -30h
        add ax, bx       	 ; + до суми в ax
	jo	@@override		  	 ; флаг of == 1 - переповнення
        inc     di           ; інкремент di
        loop    @@start_loop ; повтор циклу
	pop dx
	cmp dl, '-'  			 ; перевірка: '-'?
	jne @@positiv     		 ; не - 
	neg ax      			 ; так: змінити знак числа
	
@@positiv:	
	pop dx
	pop bx
	ret

; переповнення
     		
@@override:
	mov ah, 9h
	lea dx, msg_over
	int 21h
	mov ax, 4C00h
	int 21h	
       		
; повідомлення про загальні помилки
       		
@@common_err:
	mov ah,9h
	lea dx,msg_err
	int 21h
	mov ax,4C00h
	int 21h	

string_to_int endp 

; out_int виведення знакового 16-розрядного числа з AX на екран

; вхід: 	ax - число для відображення 
; вихід:  	число на екрані

out_int proc 
        mov bx, 10      ; дільник
        xor cx, cx      ; кількість символів у модулі числа
        or ax, ax       ; для від'ємного числа
        jns @@divide	; jump if not signed (signed) (sf=0)
            neg ax      ; змінити знак (зробити додатнім)
            push ax     ; вивести на екран символ "-" (мінус)
            mov ah, 02h
            mov dl, '-'
            int 21h
            pop ax
			
        @@divide:       ; ділення на 10
                xor dx, dx
                div bx
                push dx ; остачу зберігаємо у стек
                inc cx  ; кількість цифр у числі
                or ax, ax
        jnz @@divide    ; повтор циклу, поки у числі є цифри
        mov ah, 02h		; вивід символа (int 21h у циклі)
		
        @@store:
            pop dx      ; вилучаємо цифри (остачі від ділення на 10) зі стеку
            add dl, '0' ; цифри -> символи (30h)
            int 21h     ; вивід на екран
        loop @@store
	ret
out_int endp 

; обчислення значення функції

; на вхід:	bx - x
; cx - y
; на вихід: ax - z

func_z proc 
	xor	ax, ax
	cmp bx, 0
        jl @@v2			; якщо менше 35x^2+8x
	cmp bx, 10
        jg @@v3    		; якщо більше (10-x)^2
	cmp	bx, cx	
	je	@@verr			; якщо x=y	
	lea dx, msg_v1
	call print
	mov ax, bx			; ax = x
	sub ax, cx			; ax = x - y
	imul cx				; ax = (x-y)*y
	jo	@@over			; флаг of==1 - переповнення
	mov cx, ax			; dx = (x-y)*y
	mov ax, 15
	imul bx				; ax = 15x
	sub ax, 1
	xor dx, dx
	idiv cx	
	ret

@@verr:	lea dx, msg_verr
	call println
	mov ax,4C00h
	int 21h	
        		
; переповнення
      		
@@over:
	mov ah, 9h
	lea dx, msg_over
	int 21h
	mov ax, 4C00h
	int 21h	

@@v2:	lea dx, msg_v2	
	call print
	mov ax, 35
	imul bx				; 35x
	imul bx				; 35*x*x
	jo	@@over			; флаг of == 1 - переповнення
	mov cx, ax
	mov ax, 8
	jo	@@over			; флаг of == 1 - переповнення
	imul bx
	add ax, cx	
	ret

@@v3:	lea dx, msg_v3
	call print
	mov ax, 10
	sub ax, bx
	imul ax
	jo	@@over			; флаг of==1 - переповнення
	ret

func_z endp

cseg ends
end main