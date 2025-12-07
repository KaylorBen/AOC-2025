format ELF64 executable

STDIN_FILENO  = 0
STDOUT_FILENO = 1
STDERR_FILENO = 2

O_RDONLY = 0
O_WRONLY = 1
O_RDWR   = 2
O_CREAT  = 4
O_TRUNC  = 8

SYS_read  = 0
SYS_write = 1
SYS_open  = 2
SYS_close = 3
SYS_mmap  = 9
SYS_exit  = 60

PROT_NONE  = 0
PROT_READ  = 1
PROT_WRITE = 2
PROT_EXEC  = 4

MAP_SHARED    = 1
MAP_PRIVATE   = 2
MAP_ANONYMOUS = 32

MEGABYTE = 1048576

macro null {
    db 0
}

; print from decompiled c printf
print:
    mov     r9, -3689348814741910323
    sub     rsp, 40
    mov     BYTE [rsp+31], 10
    lea     rcx, [rsp+30]
.L2:
    mov     rax, rdi
    lea     r8, [rsp+32]
    mul     r9
    mov     rax, rdi
    sub     r8, rcx
    shr     rdx, 3
    lea     rsi, [rdx+rdx*4]
    add     rsi, rsi
    sub     rax, rsi
    add     eax, 48
    mov     BYTE [rcx], al
    mov     rax, rdi
    mov     rdi, rdx
    mov     rdx, rcx
    sub     rcx, 1
    cmp     rax, 9
    ja      .L2
    lea     rax, [rsp+32]
    mov     edi, 1
    sub     rdx, rax
    xor     eax, eax
    lea     rsi, [rsp+32+rdx]
    mov     rdx, r8
    mov     rax, 1
    syscall
    add     rsp, 40
    ret

macro stack_reserve space {
    push rbp
    mov rbp, rsp
    sub rsp, space
}

macro stack_restore space {
    add rsp, space
    pop rbp
}

macro syscall1 number, arg1 {
    mov rax, number
    mov rdi, arg1
    syscall
}

macro syscall2 number, arg1, arg2 {
    mov rax, number
    mov rdi, arg1
    mov rsi, arg2
    syscall
}

macro syscall3 number, arg1, arg2, arg3 {
    mov rax, number
    mov rdi, arg1
    mov rsi, arg2
    mov rdx, arg3
    syscall
}

macro mmap addr, len, prot, flags, fd, off {
    mov rax, SYS_mmap
    mov rdi, addr
    mov rsi, len
    mov rdx, prot
    mov r10, flags
    mov r8,  fd
    mov r9,  off
    syscall
}

macro exit code {
    syscall1 SYS_exit, code
}

macro open filename, flags, mode {
    syscall3 SYS_open, filename, flags, mode
}

macro close fd {
    syscall1 SYS_close, fd
}

macro read fd, buf, count {
    syscall3 SYS_read, fd, buf, count
}

entry _start
_start:
    stack_reserve 20
    ; open the file
    open ¿, 0, O_RDONLY
    mov [rbp-4], rax

    ; prepare memory for file
    mmap 0, MEGABYTE, PROT_READ+PROT_WRITE, MAP_ANONYMOUS+MAP_PRIVATE, -1, 0
    mov [rbp-12], rax

    ; read file to memory
    read [rbp-4], [rbp-12], MEGABYTE

    close [rbp-4]

    mov r15, [rbp-12]
.line_len:
    inc r15
    cmp BYTE [r15], 0xA
    jne .line_len
    sub r15, [rbp-12]
    inc r15 ; adjust for newline char
    mov r13, [rbp-12]
    xor rax, rax
.line_height:
    cmp BYTE [r13], '*'
    je .line_height_end
    cmp BYTE [r13], '+'
    je .line_height_end
    add r13, r15
    inc rax
    jmp .line_height
.line_height_end:
    mov r13, rax

    xor rdi, rdi ; total answer
    xor r14, r14 ; line #
    xor rdx, rdx ; operation answer
    xor rcx, rcx ; current opp
    xor r9, r9
.line_loop:
    mov rax, [rbp-12]
    cmp r14, r15
    jge .line_loop_end
    xor r8, r8   ; current num
    xor r12, r12 ; curr height

.col_top:
    inc r12
    cmp BYTE [rax+r14], '*'
    je .col_first_mul
    cmp BYTE [rax+r14], '+'
    je .col_end_add
    cmp r12, r13 ; bottom of col
    jg  .col_opp
    cmp BYTE [rax+r14], ' '
    je .col_rep
    cmp BYTE [rax+r14], 0xA
    je .col_rep

    imul r8, 10
    mov r9l, [rax+r14]
    sub r9l, '0'
    add r8, r9
.col_rep:
    add rax, r15
    jmp .col_top
.col_opp:
    cmp r8, 0
    je .opp_end
    cmp rcx, 1
    je .col_end_mul
    jmp .col_end_add
.col_first_mul:
    mov rdx, 1
.col_end_mul:
    imul rdx, r8
    mov rcx, 1
    jmp .col_end
.col_end_add:
    add rdx, r8
    mov rcx, 2
.col_end:
    inc r14
    jmp .line_loop
.opp_end:
    inc r14
    add rdi, rdx
    xor rdx, rdx
    jmp .line_loop
.line_loop_end:

    call print
    stack_restore 20
    exit 0

¿: db "input", 0
