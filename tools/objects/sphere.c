#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>

#include <utils/print.h>

int main()
{
    int total = 96;
    
    float r = 60.0f;
    
    int8_t *x = (int8_t*)malloc(total * 3 * sizeof(int8_t));
    int8_t *y = x + total;
    int8_t *z = y + total;
    
    int i;
/*
    int j, k;
    int m = sqrt(total);
    int n = total / m;

    for(j=0, k=0; j<m; j++)
    {
        float phi = (2.0 * M_PI * j) / (float)m;
        for(i=0; i<n; i++, k++)
        {
            float theta = (2.0 * M_PI * i) / (float)n;
            x[k] = round( r * cos(theta) * cos(phi) );
            y[k] = round( r * cos(theta) * sin(phi) );
            z[k] = round( r * sin(theta) );
        }
    }
*/
    int a = 2;
    for(i=0; i<total; i++)
    {
        float theta = (2.0 * a * M_PI * i) / (float)total;
        float t = (2.0 * r * i / (float)total) - r;
        float s = sqrt(r*r - t*t);
        x[i] = round( s * cos(theta) );
        y[i] = round( s * sin(theta) );
        z[i] = round( t );
    }
    print_table("sphere_x", x, total);
    print_table("sphere_y", y, total);
    print_table("sphere_z", z, total);
    
    free(x);

    return 0;
}
