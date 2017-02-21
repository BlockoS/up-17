#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>

#include <utils/print.h>

int main()
{
    int total = 96;
    
    int8_t *x = (int8_t*)malloc(total * 3 * sizeof(int8_t));
    int8_t *y = x + total;
    int8_t *z = y + total;
    
    int i;
    
    float r0 = 40.0;
    float r1 = 16.0;
    float s  = 10.0;
    
    for(i=0; i<total; i++)
    {
        float t = 2.0 * M_PI * i / (float)total;
        x[i] = round( (r0 + r1*cos(s*t)) * cos(t) );
        y[i] = round( (r0 + r1*cos(s*t)) * sin(t) );
        z[i] = round( r1*sin(s*t) );
    }

    print_table("torus_x", x, total);
    print_table("torus_y", y, total);
    print_table("torus_z", z, total);

    free(x);

    return 0;
}
