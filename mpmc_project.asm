.model small
.stack 100h

.data
menu db 13,10,"Select operation:",13,10,"1. Add",13,10,"2. Subtract",13,10,"3. Multiply",13,10,"4. Divide",13,10,"Enter choice (1-4): $"
msg1 db 13,10,"Enter first number : $"
msg2 db 13,10,"Enter second number : $"
resultMsg db 13,10,"Result: $"
exitMsg db 13,10,"Type 'exit' to return to menu: $"
goodbyeMsg db 13,10,"Exiting program...$"

inputBuffer db 3, 0, 3 dup('$')
num1 dw ?
num2 dw ?
result dw ?
exitBuffer db 5 dup('$')

.code
main:
    mov ax, @data
    mov ds, ax

menu_loop:
    lea dx, menu
    mov ah, 09h
    int 21h

    mov ah, 01h
    int 21h
    sub al, '0'
    cmp al, 1
    je add_op
    cmp al, 2
    je sub_op
    cmp al, 3
    je mul_op
    cmp al, 4
    je div_op
    jmp exit_program

add_op:
    call get_inputs
    mov ax, num1
    add ax, num2
    mov result, ax
    call show_result
    call wait_for_exit
    jmp menu_loop

sub_op:
    call get_inputs
    mov ax, num1
    sub ax, num2
    mov result, ax
    call show_result
    call wait_for_exit
    jmp menu_loop

mul_op:
    call get_inputs
    mov ax, num1
    mov bx, num2
    mul bx
    mov result, ax
    call show_result
    call wait_for_exit
    jmp menu_loop

div_op:
    call get_inputs
    mov ax, num1
    mov bx, num2
    cmp bx, 0
    je div_by_zero
    xor dx, dx
    div bx
    mov result, ax
    call show_result
    call wait_for_exit
    jmp menu_loop

div_by_zero:
    lea dx, msg1
    mov ah, 09h
    int 21h
    jmp menu_loop

get_inputs proc
    lea dx, msg1
    mov ah, 09h
    int 21h
    call read_number
    mov num1, ax

    lea dx, msg2
    mov ah, 09h
    int 21h
    call read_number
    mov num2, ax
    ret
get_inputs endp

read_number proc
    lea dx, inputBuffer
    mov ah, 0Ah
    int 21h

    lea si, inputBuffer+2
    xor ax, ax
    xor cx, cx
.next_digit:
    mov cl, [si]
    cmp cl, 0Dh
    je .done
    cmp cl, 0
    je .done
    sub cl, '0'
    mov bx, ax
    mov ax, 10
    mul bx
    add ax, cx
    inc si
    jmp .next_digit

.done:
    ret
read_number endp

show_result proc
    lea dx, resultMsg
    mov ah, 09h
    int 21h

    mov ax, result
    call print_num
    ret
show_result endp

wait_for_exit proc
    lea dx, exitMsg
    mov ah, 09h
    int 21h

    mov si, 0
.next_char:
    mov ah, 01h
    int 21h
    mov exitBuffer[si], al
    inc si
    cmp si, 4
    jne .next_char

    cmp exitBuffer[0], 'e'
    jne menu_loop
    cmp exitBuffer[1], 'x'
    jne menu_loop
    cmp exitBuffer[2], 'i'
    jne menu_loop
    cmp exitBuffer[3], 't'
    jne menu_loop
    ret
wait_for_exit endp

print_num proc
    push ax
    push bx
    push cx
    push dx

    mov cx, 0
    mov bx, 10

.divide:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne .divide

.print:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop .print

    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_num endp

exit_program:
    lea dx, goodbyeMsg
    mov ah, 09h
    int 21h
    mov ah, 4Ch
    int 21h
