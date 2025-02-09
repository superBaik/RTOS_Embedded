
#include "stdint.h"
#include "HalUart.h"
#include "stdio.h"


uint32_t putstr(const char* s) //좋은 습관 man 
{
    uint32_t c = 0;
    while(*s)
    {
        Hal_uart_put_char(*s++); // wanna use like this ! 
        c++;
    }
    return c;
}
