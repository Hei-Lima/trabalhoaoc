#include <stdio.h>

int calcularMDC(int a, int b) {

    while (b != 0) {
        int auxiliar = b;
        b = a % b;
        a = auxiliar;
    }
    return a;
}

int main() {    

    int num1, num2;
    int MDC;

    printf("Digite o primeiro numero inteiro e positivo (A): ");
    scanf("%d", &num1);

    printf("Digite o segundo numero inteiro e positivo (B): ");
    scanf("%d", &num2);

    MDC = calcularMDC(num1, num2);

    printf("O MDC de %d e %d eh: %d\n", num1, num2, MDC);

    return 0;
}