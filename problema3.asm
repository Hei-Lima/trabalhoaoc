           name "Fibonacci"
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

; ============================================   
; MACROS 
; ============================================
; Imprime caracter na tela
PUTC    MACRO   char        ; Macro com "parametro" char
        PUSH    AX          ; Guarda AX na stack pois ele vai ser sobrescrito
        MOV     AL, char    ; Coloca o char em AL de acordo com a interrupcao
        MOV     AH, 0Eh
        INT     10h         ; Executa 10h/0Eh     
        POP     AX      
ENDM

; -------------------------------------------------
; Retorna o Caractere em AL
GETC    MACRO               ; Retorna o Caractere em AL   
        MOV     AH, 00h
        INT     16h        
ENDM

; -------------------------------------------------                            ; Coloca o ponteiro no inicio da linha e pula a linha
; Coloca o ponteiro no inicio da linha e pula a linha
BARRAENE MACRO
        PUSH    AX
        MOV     AH, 0Eh
        MOV     AL, 0Dh     ; '\r'
        INT     10h
        MOV     AL, 0Ah     ; '\n'
        INT     10h
        POP     AX
ENDM       

; -------------------------------------------------
; Printa uma string usando interrupcoes DOS                            
PRINT_S MACRO   string
    PUSH AX                 ; Backup dos registradores
    PUSH DX
    MOV DX, string
    MOV AH, 9
    INT 21h
    POP DX                  ; Restaura o estado dos registradores
    POP AX
ENDM

; ============================================   
; INICIO DO PROGRAMA 
; ============================================

ORG 100h

LEA DX, str_a
PRINT_S DX
CALL SCAN_NUM
MOV num1, CX
BARRAENE

LEA DX, str_b
PRINT_S DX
CALL SCAN_NUM
MOV num2, CX
BARRAENE

MOV BX, num1
MOV CX, num2

CALL CALCULAR_MDC
MOV mdc, BX

LEA DX, str_final1
PRINT_S DX

MOV AX, num1
CALL PRINT_NUM

LEA DX, str_final2
PRINT_S DX

MOV AX, num2
CALL PRINT_NUM

LEA DX, str_final3
PRINT_S DX

MOV AX, mdc
CALL PRINT_NUM
    
; ============================================   
; VARIAVEIS
; ============================================      

num1 DW ?
num2 DW ?
mdc DW ?
str_a DB 'Digite o primeiro numero inteiro e positivo (A): $'
str_b DB 'Digite o segundo numero inteiro e positivo (B): $'                  
str_final1 DB 'O MDC de: $'
str_final2 DB ' e $'
str_final3 DB ' eh: $' 
 
; ============================================   
; PROCEDIMENTOS 
; ============================================

; Calcula MDC e retorna em BX
CALCULAR_MDC    PROC       
                            ; Colocar num1 em BX
                            ; Colocar num2 em CX        
        
        while:              
        CMP CX, 0           ; Compara CX (B) = 0 
        JE fim
        
        MOV DX, 0           ; Limpa DX para o DIV
        MOV AX, BX          ; Coloca BX em AX para executar o DIV
        DIV CX              ; DX = AX % CX
        MOV BX, CX          ; BX (A) = Auxiliar
        MOV CX, DX          ; CX (B) = DX (A % B)
        
        JMP while
        
        fim:
        RET                 ; Retorna o final em BX
        
; Escaneia um numero e salva ele em CX. 
SCAN_NUM        PROC        ; Define o procedimento SCAN NUM
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
RET
        

GET_S PROC; Pega uma string do usuario de tamanho predefinido e retorna em BX
; Colocar o tamanho da string (sem terminador NULO) em DI (ate 8 bits)
; Colocar o endereco de destino da STRING em BX
    MOV SI, 0
    get_next_char:
        GETC                ; Pega o caracter e salva em AL
        PUTC AL             ; Imprime caractere atual
        MOV [BX + SI], AL   ; STRING[i] = AL        
        INC SI              ; i++
        CMP SI, DI          ; Compara se SI == DI
        JNE get_next_char   ; Se SI != AH, continua o ciclo
    MOV [BX + SI], 0        ; Insere o terminador NULO
    BARRAENE
RET
GET_S ENDP

STR_TO_INT_3 PROC           ; Transforma string de 3 caracteres numéricos em inteiro

    MOV AX, 0               ; zera acumulador
    MOV CX, 0               ; CX = resultado final

    ; Primeiro caractere (posicao 0) * 100
    MOV DL, [BX + 0]
    SUB DL, '0'
    MOV AL, DL
    MOV AH, 0
    MOV SI, 100             ; peso
    MUL SI                  ; AX = DL * 100
    ADD CX, AX

    ; Segundo caractere (posicao 1) * 10
    MOV DL, [BX + 1]
    SUB DL, '0'
    MOV AL, DL
    MOV AH, 0
    MOV SI, 10
    MUL SI                  ; AX = DL * 10
    ADD CX, AX

    ; Terceiro caractere (posicao 2) * 1
    MOV DL, [BX + 2]
    SUB DL, '0'
    MOV AL, DL
    MOV AH, 0
    ADD CX, AX        

    MOV AX, CX        
    RET
STR_TO_INT_3 ENDP

; This macro defines a procedure that prints number in AX,
; used with PRINT_NUM_UNS to print signed numbers:
; Requires DEFINE_PRINT_NUM_UNS !!!
PRINT_NUM       PROC
        PUSH    DX
        PUSH    AX

        CMP     AX, 0
        JNZ     not_zero

        PUTC    '0'
        JMP     printed

not_zero:
        ; the check SIGN of AX,
        ; make absolute if it's negative:
        CMP     AX, 0
        JNS     positive
        NEG     AX

        PUTC    '-'

positive:
        CALL    PRINT_NUM_UNS
printed:
        POP     AX
        POP     DX
        RET
PRINT_NUM       ENDP

skip_proc_print_num:

DEFINE_PRINT_NUM        ENDM

;***************************************************************
; This macro defines a procedure that prints out an unsigned
; number in AX (not just a single digit)
; allowed values from 0 to 65535 (0FFFFh)
JMP     skip_proc_print_num_uns

PRINT_NUM_UNS   PROC    NEAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX

        ; flag to prevent printing zeros before number:
        MOV     CX, 1

        ; (result of "/ 10000" is always less or equal to 9).
        MOV     BX, 10000       ; 2710h - divider.

        ; AX is zero?
        CMP     AX, 0
        JZ      print_zero

begin_print:

        ; check divider (if zero go to end_print):
        CMP     BX,0
        JZ      end_print

        ; avoid printing zeros before number:
        CMP     CX, 0
        JE      calc
        ; if AX<BX then result of DIV will be zero:
        CMP     AX, BX
        JB      skip
calc:
        MOV     CX, 0   ; set flag.

        MOV     DX, 0
        DIV     BX      ; AX = DX:AX / BX   (DX=remainder).

        ; print last digit
        ; AH is always ZERO, so it's ignored
        ADD     AL, 30h    ; convert to ASCII code.
        PUTC    AL


        MOV     AX, DX  ; get remainder from last div.

skip:
        ; calculate BX=BX/10
        PUSH    AX
        MOV     DX, 0
        MOV     AX, BX
        DIV     CS:ten  ; AX = DX:AX / 10   (DX=remainder).
        MOV     BX, AX
        POP     AX

        JMP     begin_print
        
print_zero:
        PUTC    '0'
        
end_print:

        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET     
PRINT_NUM_UNS   ENDP

skip_proc_print_num_uns:

DEFINE_PRINT_NUM_UNS    ENDM