#include "stdint.h"


#include "HalUart.h"

#include "stdio.h" //add 


static void Hw_init(void);

void main(void)
{
    Hw_init();

    uint32_t i = 100;
    while(i--)
    {
        Hal_uart_put_char('N'); //Wanna use lik THIS!! 
    }
	Hal_uart_put_char('\n');

	putstr("Hello JPARK");

}

static void Hw_init(void)
{

    Hal_uart_init();

}
