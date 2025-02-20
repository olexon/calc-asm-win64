section .bss
    ; uninitialized data

section .data
    c_type: dq 0
    c_n1: dq 0
    c_n2: dq 0

    fmt_in: db "%lld", 0
    fmt_out: db "result = %lld", 0 ; no need for new line this is the last thing printed

    err_out: db "Error.", 10, 0

    ; new line handled by user input
    q_type: db "types: 1 - add, 2 - substract, 3 - multiply, 4 - divide", 10, "selected type: ", 0 
    q_n1: db "first number: ", 0
    q_n2: db "second number: ", 0

section .text
    extern GetLastError, printf, scanf
    global main

    default rel

    calc:
        cmp r8, 1                           ; genious check
        je .add
        cmp r8, 2
        je .sub
        cmp r8, 3
        je .mul
        cmp r8, 4
        je .div
        jmp .error
    .add:
        add rcx, rdx                        ; add rdx to rcx
        jmp .done
    .sub:
        sub rcx, rdx                        ; substract rdx from rcx
        jmp .done
    .mul:
        imul rcx, rdx                       ; signed multiply rcx by rdx
        jmp .done
    .div:                                   ; this is so fucking stupid
        mov r9, rdx                         ; move rdx to r9 so we can clear rdx later
        xor rdx, rdx                        ; clear rdx
        test r9, r9                         ; check if we arent dividing by 0
        jz .error                           ; apparently we are
        mov rax, rcx                        ; move rcx to rax cuz idiv will divide rax by r9 in our case
        cqo                                 ; sign extend otherwise gl dividing by negative n
        idiv r9                             ; divide rax by r9
        mov rcx, rax                        ; move rax back to rcx so this genious function doesnt shit itself on spot
        jmp .done                           ; we done (hopefully it didnt crash before we reached this point)
    .done:
        mov rax, rcx                        ; return results
        ret
    .error:
        mov rcx, err_out                    ; print error message lol
        call printf
        mov rax, 0                          ; also return 0
        ret

    main:
        sub rsp, 20h ; shadow space bullshit

        ; print type question
        mov rcx, q_type
        call printf

        ; get calc type
        mov rcx, fmt_in
        mov rdx, c_type
        call scanf

        ; ask for n1
        mov rcx, q_n1
        call printf

        ; get n1
        mov rcx, fmt_in
        mov rdx, c_n1
        call scanf

        ; ask for n2
        mov rcx, q_n2
        call printf

        ; get n2
        mov rcx, fmt_in
        mov rdx, c_n2
        call scanf

        ; call calc function
        mov rcx, qword [c_n1]
        mov rdx, qword [c_n2]
        mov r8, qword [c_type]
        call calc

        ; print result
        mov rdx, rax
        mov rcx, fmt_out
        call printf

        ; exit  
        call GetLastError
        add rsp, 20h
        ret