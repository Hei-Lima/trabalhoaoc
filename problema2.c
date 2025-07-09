#include <stdio.h>

int main(void){
  int a = 1, b = 1, c = 0;
  int m = 0, n = 0;
  int cont = 0;

  while(n<=m || m<3){
    printf("Insira M: ");
    scanf("%d", &m);
    printf("\nInsira N: ");
    scanf(" %d", &n);
  }

  while(c<n){
    c = a+b;
    if(c>=m && c<n){
      printf("\n%d", c);
      cont++;
    }
    a = b;
    b = c;
  }

  printf("\nTotal de números impressos: %d", cont);
  return 0;
}