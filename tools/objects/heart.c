#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>

#include <utils/print.h>

int main()
{
    int total = 96;
    float depth = 16.0f;
    float size  = 4.0f;
    
    int8_t *x = (int8_t*)malloc(total * 3 * sizeof(int8_t));
    int8_t *y = x + total;
    int8_t *z = y + total;
    
    int n = 4;
    int m = 24;

    int i,j,k;

    for(j=0, k=0; j<n; j++)
    {
        float v = (2.0*j - n) / (float)n;
        float scale = 1.0 - fabs(v+0.25) * fabs(v+0.25);
        for(i=0; i<m; i++, k++)
        {
            float u = (2.0*i - m) / (float)m;
            float theta = u * M_PI;
            
            float sn = sin(theta);
            float s = 16.0*sn*sn*sn;
            float t = 13.0*cos(theta) - 5.0*cos(2.0*theta) - 2.0*cos(3.0*theta) - cos(4.0*theta);
            x[k] = round( s * scale * size );
            y[k] = round(-t * scale * size );
            z[k] = round( v * depth );
        }
    }

    print_table("heart_x", x, total);
    print_table("heart_y", y, total);
    print_table("heart_z", z, total);

    free(x);

    return 0;
}
