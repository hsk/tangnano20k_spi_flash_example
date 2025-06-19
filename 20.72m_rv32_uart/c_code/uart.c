#include "uart.h"

#define UART_DIV  ((volatile unsigned int  *) 0x80000008)
#define UART_DATA ((volatile unsigned char *) 0x8000000c)

void uart_set_div(unsigned int div) {
  *UART_DIV = div;
  for (volatile int delay = 0; delay < 200; delay++) {}
}

void uart_print_hex(unsigned int val) {
  for (int i = 0; i < 8; i++) {
    char ch = (val & 0xf0000000) >> 28;
    *UART_DATA = "0123456789abcdef"[ch];
    val = val << 4;
  }
}

char uart_getchar(void) {
  unsigned char ch;
  while ((ch = *UART_DATA) == 0xff) {}
  return ch;
}

void uart_putchar(char ch) {
  *UART_DATA = ch;
}

void uart_puts(char* s) {
  while (*s != 0) *UART_DATA = *s++;
}

unsigned int uart_get_hex(void) {
  unsigned int v = 0;
  for (;;) {
    char ch = uart_getchar();
    if ((ch >= '0') && (ch <= '9')) {
      v = 16 * v + (ch - '0');
      uart_putchar(ch);
    } else if ((ch >= 'a') && (ch <= 'f')) {
      v = 16 * v + (ch - 'a' + 10);
      uart_putchar(ch);
    } else if ((ch >= 'A') && (ch <= 'F')) {
      v = 16 * v + (ch - 'A' + 10);
      uart_putchar(ch);
    } else if (ch == '\r') {
      uart_putchar('\n');
      break;
    }
  }
  return v;
}
