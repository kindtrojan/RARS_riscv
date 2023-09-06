#include <stdio.h>

void printInt(int val) {
	printf("%d\n", val);
}

int absSub(int a, int b) {
    int c;

    c = b - a;
    if(c < 0) {
        c = -c;
    }
    return c;
}

int main(void) {
    printInt(absSub(17, 46));
    return 0;
}

