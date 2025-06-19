#ifndef _UART_H
#define UART_H

void uart_set_div(unsigned int div);     // UART速度設定
void uart_print_hex(unsigned int val);   // 16進数出力
char uart_getchar(void);                 // 1文字取得
void uart_putchar(char ch);              // 1文字出力
void uart_puts(char *s);                 // 文字列出力
unsigned int uart_get_hex(void);         // 16進数入力

#endif
