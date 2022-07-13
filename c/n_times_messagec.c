#include <stdio.h>
#include <stdlib.h>

int main(){
	int n;

	printf("in order to print a message n times, \n");
	printf("please pick a number between -99 and 99:\n");
	scanf("%d", &n);

	if(n < 0){
	printf("negative numbers don't really make sense...\nnot in this context at least\n");
	}

	for(int i = 0; i < n; i++)
		printf("Good pick! I love this particular number\n");

	return 0;
}
