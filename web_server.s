.intel_syntax noprefix
.global _start

_start:
        mov rax, 0x29
        mov rdi, 2
        mov rsi, 1
        mov rdx, 0
        syscall

        mov r12, rax    #saving the return value of socket (the fd)

        # setting up the sockaddr_in for bind

        sub rsp, 16 #allocating

        mov word ptr [rsp], 2
        mov word  ptr [rsp + 2], 0x401F # port 80 big endian
        mov dword ptr [rsp + 4], 0
        mov qword ptr [rsp + 8], 0


        # setting up bind
        mov rax, 0x31
        mov rdi, r12
        mov rsi, rsp
        mov rdx, 16
        syscall

        # setting up listen
        mov rax, 0x32 # listen
        mov rdi, r12
        mov rsi, 0
        syscall


.client_loop:
        # setting up accept
        mov rax, 0x2B # accept
        mov rdi, r12
        xor rsi, rsi # setting rsi and rdx to NULL
        xor rdx, rdx
        syscall

        # storing the client fd
        mov r13, rax

        # forking
        mov rax, 0x39
        syscall

        cmp rax, 0
        jne .parent

        # closing fd 3
        #mov rax, 3
        #mov rdi, 3
        #syscall

        # setting up read
        sub rsp, 1024 # allocating space for read
        mov rax, 0
        mov rdi, r13
        mov rsi, rsp
        mov rdx, 1024
        syscall

        mov r15, rax

        # parcing the input stored in the stack from read
        # r13 contains the client fd
        # r15 contains the open file fd
        # r14 used to parse


        mov al, byte ptr [rsp]
        cmp al, 'G'
        jne .post

.get:
        # parcing the input stored in the stack from read

        mov rsi, rsp
        add rsi, 5
        sub rsp, 512
        mov r14, rsp

.parse_loop_g:
        mov al, byte ptr [rsi]
        cmp al, ' '
        je .done_g
        mov byte ptr [r14], al
        inc rsi
        inc r14
        jmp .parse_loop_g

.done_g:
        mov byte ptr [r14], 0

        # opening the file to read from
        mov rax, 2
        mov rdi, rsp
        xor rsi, rsi
        syscall

        # reading the opened file
        sub rsp, 1024
        mov rbx, rsp
        mov r15, rax
        mov rdi, r15
        mov rsi, rbx
        xor rax, rax
        mov rdx, 1024
        syscall

        mov r14, rax

        # calling close to close the open file fd
        mov rax, 3
        mov rdi, r15
        syscall

        #setting up write for response with 200 OK
        sub rsp, 20
        mov rdi, r13
        mov rsi, rsp
        mov rdx, 19

        mov rax, 0x302e312f50545448 # "0.1/PTTH"
        mov qword ptr [rsp], rax

        mov dword ptr [rsp+8], 0x30303220 # "002 "

        mov rax, 0x0a0d0a0d4b4f20 # "\n\r\n\rKO "
        mov qword ptr [rsp+12], rax

        mov rax, 1
        syscall

        #setting up write for response with file content
        mov rdi, r13
        mov rsi, rbx
        mov rdx, r14
        mov rax, 1
        syscall

        mov rax, 60
        mov rdi, 0
        syscall


.post:
        mov rsi, rsp
        add rsi, 6
        sub rsp, 512
        mov r14, rsp

.parse_loop:
        mov al, byte ptr [rsi]
        cmp al, ' '
        je .done
        mov byte ptr [r14], al
        inc rsi
        inc r14
        jmp .parse_loop

.done:
        mov byte ptr [r14], 0

        # saving base read buffer in r14
        # r15 contains read return value
        mov r14, rsp
        add r14, 512

        # opening the file to write to
        mov rax, 2
        mov rdi, rsp
        mov rsi, 0x41
        mov rdx, 0777
        syscall

        mov rbx, rax
        mov rsi, r14
        xor r14, r14

.loop_read:
        mov al, byte ptr [rsi]
        cmp al, 0x0a
        je .check
        inc rsi
        inc r14
        jmp .loop_read

.check:
        inc rsi
        inc r14
        mov al, byte ptr [rsi]
        cmp al, 0x0d
        je .content_cp
        inc rsi
        inc r14
        jmp .loop_read

.content_cp:
        add rsi, 2
        add r14, 2
        sub r15, r14
        sub rsp, r15
        mov r14, rsp
        xor rcx, rcx
.loop_cp:
        cmp rcx, r15
        jge .done_cp
        mov al, byte ptr [rsi]
        mov byte ptr [r14], al
        inc rcx
        inc rsi
        inc r14
        jmp .loop_cp

.done_cp:
        mov rax, 1
        mov rdi, rbx
        mov rsi, rsp
        mov rdx, r15
        syscall


        # calling close to close the open file fd
        mov rax, 3
        mov rdi, r15
        syscall

        #setting up write for response with 200 OK
        sub rsp, 20
        mov rdi, r13
        mov rsi, rsp
        mov rdx, 19

        mov rax, 0x302e312f50545448 # "0.1/PTTH"
        mov qword ptr [rsp], rax

        mov dword ptr [rsp+8], 0x30303220 # "002 "

        mov rax, 0x0a0d0a0d4b4f20 # "\n\r\n\rKO "
        mov qword ptr [rsp+12], rax

        mov rax, 1
        syscall

        # exiting the child process
        mov rax, 60
        mov rdi, 0
        syscall

.parent:
        mov rax, 3
        mov rdi, r13
        syscall
        jmp .client_loop
