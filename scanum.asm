DEFINE_SCAN_NUM     MACRO
; Definir as labels como locais para impedir o conflito de nomes.
LOCAL make_minus, ten, next_digit, set_minus
LOCAL too_big, backspace_checked, too_big2
LOCAL stop_input, not_minus, skip_proc_scan_num
LOCAL remove_not_digit, ok_AE_0, ok_digit, not_cr

SCAN_NUM        PROC        ; Define o processo SCAN NUM
        ; Salva o estado das variaveis na Pilha
        PUSH    DX
        PUSH    AX          
        PUSH    SI
        
        MOV     CX, 0       ; Inicializa CX como 0.
        
        
next_digit:

        GETC                ; Usa a macro que criamos (GETC) para pegar um char e salvar em AL
   
        MOV     AH, 0Eh
        INT     10h
                            
        CMP     AL, '-'     ; Compara e checa por menos
        JE      set_minus   

        CMP     AL, 13      ; Checa pela tecla ENTER.
        JNE     not_cr
        JMP     stop_input  ; Se for ENTER, terminar.

not_cr:


        CMP     AL, 8                   ; Checa pela tecla BACKSPACE 
        JNE     backspace_checked
        MOV     DX, 0                   ; Se BS foi teclado, remove o ultimo digito por divisao.
        MOV     AX, CX                
        DIV     CS:ten                  ; AX = DX:AX / 10 (DX-rem).
        MOV     CX, AX
        PUTC    ' '                     ; Limpa a posicao.
        PUTC    8                
        JMP     next_digit
backspace_checked:


        ; Apenas permitir digitos
        CMP     AL, '0'
        JAE     ok_AE_0
        JMP     remove_not_digit
ok_AE_0:        
        CMP     AL, '9'
        JBE     ok_digit
remove_not_digit:       
        PUTC    8       ; Insere backspace no lugar
        PUTC    ' '     ; Limpa a posicao.
        PUTC    8       ; Backspace novamente.        
        JMP     next_digit ; Aguardar para proximo input.       
ok_digit:


        ; Faz a gambiarra de unidade, centena, dezena...
        PUSH    AX
        MOV     AX, CX
        MUL     CS:ten                  ; DX:AX = AX*10
        MOV     CX, AX
        POP     AX

        ; Checa se o numero eh maior que 16bits.
        CMP     DX, 0
        JNE     too_big

        ; Converte de ASCII para int (30h = '0'):
        SUB     AL, 30h

        ; Adiciona AL com CX:
        MOV     AH, 0
        MOV     DX, CX      ; Backup no caso do numero ser muito grande.
        ADD     CX, AX
        JC      too_big2    ; Saltar se for muito grande.

        JMP     next_digit

set_minus:
        MOV     CS:make_minus, 1
        JMP     next_digit

too_big2:
        MOV     CX, DX      ; Restora o backup.
        MOV     DX, 0       ; DX era 0 antes do backup.
too_big:
        MOV     AX, CX
        DIV     CS:ten  ; Volta a op DX:AX = AX*10, faz AX = DX:AX / 10
        MOV     CX, AX
        PUTC    8       ; Backspace.
        PUTC    ' '     ; Limpa ultimo digito.
        PUTC    8       ; Backspace novamente.        
        JMP     next_digit ; Aguardade Enter/Backspace.
        
        
stop_input:
        ; Checa a flag:
        CMP     CS:make_minus, 0
        JE      not_minus
        NEG     CX
not_minus:

        POP     SI
        POP     AX
        POP     DX
        RET
make_minus      DB      ?       ; Usado como flag.
ten             DW      10      ; Usado como multiplicador.
SCAN_NUM        ENDP

skip_proc_scan_num:

DEFINE_SCAN_NUM         ENDM
                                       
; ============================================   
; INICIO DO PROGRAMA 
; ============================================