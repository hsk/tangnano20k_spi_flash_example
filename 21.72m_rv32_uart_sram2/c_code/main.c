#include "uart.h"

// 関数readtimeはそのうちの1つを使用します。
static inline unsigned int readtime(void) {
  // risc-v仕様でpicorv32コアにはいくつかのカウンタとアクセス命令がある。
  unsigned int val;
  asm volatile("rdtime %0" : "=r" (val));
  return val;
}

// メイン関数
int main() {
  // uartの設定
  uart_set_div(CLK_FREQ / 115200.0 + 0.5);
  uart_puts("\r\nStarting, CLK_FREQ: 0x");
  uart_print_hex(CLK_FREQ);
  uart_puts("\r\n\r\n");
  while (1) {
    uart_puts("Enter command:\r\n");
    uart_puts("   r: read clock\r\n");
    unsigned char ch = uart_getchar();
    switch (ch) {
    case 'r':
      uart_puts("time is ");
      uart_print_hex(readtime());
      break;
    default:
      uart_puts("command not found ");
      uart_putchar(ch);
      break;
    }
    uart_puts("\r\n");
  }
  return 0;
}
