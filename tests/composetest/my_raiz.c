#include <math.h>
#include <limits.h>
#include <stdio.h>
int main()
{
	printf("La raiz de %d is %f\n", INT_MAX - 1, sqrt(INT_MAX - 1));
	printf("La raiz de %d is %f\n", INT_MAX, sqrt(INT_MAX));
	printf("La raiz de %d is %f\n", INT_MAX + 1, sqrt(INT_MAX + 1));
	return (0);
}

