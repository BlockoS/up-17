#include <stdio.h>
#include <stdint.h>
#include <math.h>

int main()
{
    int n = 512;
    int i;

    uint8_t tbl[512];

    printf("mul_tbl:\n");
    for(i=0; i<n; i++)
    {
        uint16_t x = i & 0xff;
        if(x > 127) { x = 256 - x; }
        if((i%8) == 0)
        {
            printf("    .db ");
        }
        x = round((x*x) / 256.0);
        tbl[i] = (uint8_t)x;
        printf("$%02x%c", (uint8_t)x, ((i%8) == 7) ? '\n':',');
    }

    return 0;
}
