#include <stdint.h>
#include <stdio.h>

int main(void)
{
	int lo;
	int hi;
	int drop_lo;
	int drop_hi;

	while ((lo = getchar()) != EOF) {
		hi = getchar();
		if (hi == EOF) {
			break;
		}

		if (putchar(lo) == EOF || putchar(hi) == EOF) {
			return 1;
		}

		drop_lo = getchar();
		if (drop_lo == EOF) {
			break;
		}
		drop_hi = getchar();
		if (drop_hi == EOF) {
			break;
		}
	}

	return ferror(stdin) || ferror(stdout);
}
