#include <stdio.h>

int main() {
    int angulo;

    printf("Digite um valor de angulo em graus (inteiro, entre -360 e 360): ");
    scanf("%d", &angulo);

    if (angulo == 360 || angulo == -360) {
        angulo = 0;
    }

    else if (angulo < 0) {
        angulo = angulo + 360;
    }

    if (angulo == 0) {
        printf("O angulo %d representa a Direcao LESTE\n", angulo);
    } else {
        if (angulo > 0 && angulo < 90) {
            printf("O angulo %d representa a Direcao NORDESTE\n", angulo);
        } else {
            if (angulo == 90) {
                printf("O angulo %d representa a Direcao NORTE\n", angulo);
            } else {
                if (angulo > 90 && angulo < 180) {
                    printf("O angulo %d representa a Direcao NOROESTE\n", angulo);
                } else {
                    if (angulo == 180) {
                        printf("O angulo %d representa a Direcao OESTE\n", angulo);
                    } else {
                        if (angulo > 180 && angulo < 270) {
                            printf("O angulo %d representa a Direcao SUDOESTE\n", angulo);
                        } else {
                            if (angulo == 270) {
                                printf("O angulo %d representa a Direcao SUL\n", angulo);
                            } else {
                                printf("O angulo %d representa a Direcao SUDESTE\n", angulo);
                            }
                        }
                    }
                }
            }
        }
    }

    return 0;
}