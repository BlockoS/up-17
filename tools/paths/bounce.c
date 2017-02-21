#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include <utils/print.h>

#if 0
uint8_t tab[256];

// d = 256;
// c = 220;
uint8_t easeOutBounce(uint8_t t)
{
    if(t < 92)
    {
        return tab[t];
    }
    else if (t < 186)
    {
        t -= 140;
        return tab[t] + 165;
    } else if (t < 232)
    {
        t -= 209;
        return tab[t] + 206;
    } else
    {
        t -= 244;
        return tab[t] + 216;
    }
};
#endif

float easeOutBounce_f(float t, float b, float c, float d)
{
    t /= d;
    if(t < (1/2.75))
    {
        return c*(7.5625*t*t) + b;
    }
    else if (t < (2/2.75))
    {
        t -= 1.5 / 2.75;
        b += c * 0.75;
    }
    else if (t < (2.5/2.75))
    {
        t -= 2.25 / 2.75;
        b += c * 0.9375;
    } else
    {
        t -= 2.625 / 2.75;
        b += c * 0.984375;
    }
    return c*(7.5625*t*t) + b;
}

int main()
{
    int i;
    uint8_t bounce[256];
#if 0    
    uint8_t t;
    for(i=0; i<128; i++)
    {
        int u = i;
        tab[i] = (uint32_t)(220*121*u*u) / (16*256*256);
    }
    for(i=0; i<128; i++)
    {
        int u = -i;
        tab[(uint8_t)u] = (uint32_t)(220*121*i*i) / (16*256*256);
    }
#endif
    for(i=0; i<256; i++)
    {
        bounce[i] = (uint8_t)easeOutBounce_f(i, 0.0, 220.0, 256.0);
    }
    print_table("bounce", (int8_t*)bounce, 256);
    
    return EXIT_SUCCESS;
}
