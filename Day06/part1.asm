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
    open 📁, 0, O_RDONLY
    mov [rbp-4], rax

    ; prepare memory for file
    mmap 0, MEGABYTE, PROT_READ+PROT_WRITE, MAP_ANONYMOUS+MAP_PRIVATE, -1, 0
    mov [rbp-12], rax

    ; read file to memory
    read [rbp-4], [rbp-12], MEGABYTE
    add rax, [rbp-12]
    mov [rbp-20], rax ; next byte in memory after the file
    mov r13, rax

    close [rbp-4]

    xor rdi, rdi ; num cols
    xor rdx, rdx ; num rows
    mov rcx, 1   ; for counting cols
    ; parse ints
    xor rbx, rbx
    mov r12, [rbp-12]
.read_number:
    cmp BYTE [r12], ' '
    je .next
    cmp BYTE [r12], 0xA
    je .newline
    cmp BYTE [r12], '+'
    je  .operators
    cmp BYTE [r12], '*'
    je  .operators
    xor r8, r8
    imul rbx, 10
    mov  r8l, [r12]
    sub  r8l, '0'
    add  rbx, r8
    inc  r12
    cmp  BYTE [r12], '0'
    jge  .read_number
    mov [r13], rbx
    add r13, 8
    add rdi, rcx
    xor rbx, rbx
    jmp .read_number
.next:
    inc r12
    jmp .read_number
.newline:
    inc r12
    mov rcx, 0
    inc rdx
    jmp .read_number

.operators:
    xor rbx, rbx ; answer
    xor rcx, rcx ; col counter
    mov rax, [rbp-20]
.col_loop:
    cmp rcx, rdi
    jge .col_loop_end

    mov rsi, 1 ; row counter
    mov r15, [rax+rcx*8]

.get_op:
    cmp BYTE [r12], '+'
    je .row_loop
    cmp BYTE [r12], '*'
    je .row_loop
    inc r12
    jmp .get_op
.row_loop:
    cmp rsi, rdx
    jge .row_loop_end

    ; loop body
    mov  r9, rsi
    imul r9, rdi
    add  r9, rcx
    mov  r14, [rax+r9*8]
    cmp BYTE [r12], '+'
    je .plus
    jmp .mult
.plus:
    add r15, r14
    jmp .mult_end
.mult:
    imul r15, r14
.mult_end:

    inc rsi
    jmp .get_op
.row_loop_end:
    add rbx, r15
    inc rcx
    inc r12
    jmp .col_loop
.col_loop_end:

    mov rdi, rbx
    call print
    stack_restore 20
    exit 0

📁: db "input", 0
