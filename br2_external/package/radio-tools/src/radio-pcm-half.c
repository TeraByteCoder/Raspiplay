#include <stdio.h>
#include <stdint.h>

int main(void)
{
	unsigned char b[8];
	int16_t left;
	int16_t right;
	int16_t mono;

	while (fread(b, 1, sizeof(b), stdin) == sizeof(b)) {
		left = (int16_t) (uint16_t) (b[0] | (b[1] << 8));
		right = (int16_t) (uint16_t) (b[2] | (b[3] << 8));
		mono = (int16_t) (((int32_t) left + (int32_t) right) / 2);

		if (putchar((unsigned char) (mono & 0xff)) == EOF ||
		    putchar((unsigned char) ((uint16_t) mono >> 8)) == EOF) {
			return 1;
		}
	}

	return ferror(stdin) || ferror(stdout);
}
