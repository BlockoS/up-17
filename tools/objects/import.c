#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <errno.h>
#include <math.h>

typedef struct
{
	float x, y, z;
} vec3_t;

typedef struct
{
	int capacity;
	int count;
	vec3_t *data;
} point_cloud_t;

int create(point_cloud_t* points, size_t capacity)
{
	points->count = 0;
	points->data = (vec3_t*)malloc(capacity * sizeof(vec3_t));
	if(NULL == points->data)
	{
		fprintf(stderr, "failed to allocate point cloud buffer: %s\n", strerror(errno));
		points->capacity = 0;
		return 0;
	}
	points->capacity = capacity;		
	return 1;
}

void destroy(point_cloud_t* points)
{
	points->count = 0;
	points->capacity = 0;
	if(points-> data)
	{
		free(points->data);
		points->data = 0;
	}
}

int add(point_cloud_t* points, vec3_t *p)
{
	if(points->count >= (points->capacity-1))
	{
		vec3_t *tmp;
		size_t size = points->capacity * 2;
		tmp = (vec3_t*)realloc(points->data, size * sizeof(vec3_t));
		if(NULL == tmp)
		{
			fprintf(stderr, "failed to expand point cloud buffer: %s\n", strerror(errno));
			return 0;
		}
		points->capacity = size;
		points->data = tmp;
	}

	memcpy(&points->data[points->count], p, sizeof(vec3_t));
	points->count++;

	return 1;
}

int read_obj(const char* filename, point_cloud_t* points)
{
	char* line;
	size_t length;
	ssize_t read;

	int ret;
	
	FILE* in;

	vec3_t v;

	length = 0;
	line = 0;

	in = fopen(filename, "rb");
	if(!in)
	{
		fprintf(stderr, "failed to open %s: %s\n", filename, strerror(errno));
		return 0;
	}

	while( (read = getline(&line, &length, in)) != -1 )
	{
		ret = sscanf(line, "v %f %f %f", &v.x, &v.y, &v.z);
		if(3 == ret)
		{
			ret = add(points, &v);
			if(!ret)
			{
				fprintf(stderr, "failed to add point\n");
				return 0;
			}
		}
	}

	fclose(in);
	
	if(line)
	{
		free(line);
	}

	return 1;	
}

float v_min(vec3_t* v)
{
	return (v->x < v->y)
	       ? ((v->x < v->z) ? v->x : v->z)
	       : ((v->z < v->y) ? v->z : v->y);
}

float v_max(vec3_t* v)
{
	return (v->x > v->y)
	       ? ((v->x > v->z) ? v->x : v->z)
	       : ((v->z > v->y) ? v->z : v->y);
}

void rescale(point_cloud_t* points, float max_coord)
{
	float s0;
	float s1;
	
	vec3_t p0;
	vec3_t p1;
	vec3_t centroid;

	int i;

	if(!points->count)
	{
		return;
	}

	p0.x = p1.x = points->data[0].x;
	p0.y = p1.y = points->data[0].y;
	p0.z = p1.z = points->data[0].z;
	for(i=1; i<points->count; i++)
	{
		p0.x = (points->data[i].x < p0.x) ? points->data[i].x : p0.x;
		p0.y = (points->data[i].y < p0.y) ? points->data[i].y : p0.y;
		p0.z = (points->data[i].z < p0.z) ? points->data[i].z : p0.z;
		
		p1.x = (points->data[i].x > p1.x) ? points->data[i].x : p1.x;
		p1.y = (points->data[i].y > p1.y) ? points->data[i].y : p1.y;
		p1.z = (points->data[i].z > p1.z) ? points->data[i].z : p1.z;
	}

	centroid.x= (p0.x + p1.x) / 2.0;
	centroid.y= (p0.y + p1.y) / 2.0;
	centroid.z= (p0.z + p1.z) / 2.0;

	for(i=0; i<points->count; i++)
	{
		points->data[i].x -= centroid.x;
		points->data[i].y -= centroid.y;
		points->data[i].z -= centroid.z;
	}

	s0 = v_min(&points->data[0]);
	s1 = v_max(&points->data[0]);

	for(i=1; i<points->count; i++)
	{
		float t0 = v_min(&points->data[i]);
		float t1 = v_max(&points->data[i]);
		if(t0 < s0)
		{
			s0 = t0;
		}
		if(t1 > s1)
		{
			s1 = t1;
		}
	}

	s0 = fabs(s0);
	s1 = fabs(s1);
	s0 = max_coord / ((s1 < s0) ? s0 : s1);

	for(i=0; i<points->count; i++)
	{
		points->data[i].x *= s0;
		points->data[i].y *= s0;
		points->data[i].z *= s0;
	}
}

void print(const char* name, point_cloud_t *points)
{
	static const char* suffix[] =
	{
		"_x", "_y", "_z"
	};
	float* v[] = 
	{
		&(points->data[0].x),
		&(points->data[0].y),
		&(points->data[0].z)
	};
    int i, j;

	for(j=0; j<3; j++)
	{
		printf("%s%s:\n", name, suffix[j]);
		for(i=0; i<points->count; i++)
	    {
	        if((i%16) == 0)
	        {
	            printf("    .db ");
	        }
	        printf("$%02x%c", (uint8_t)round(v[j][0]), (((i%16) == 15) || (i >= (points->count-1))) ? '\n':',');
			v[j] += 3;
		}
	}
}


int main(int argc, char **argv)
{
	int ret = EXIT_FAILURE;
	point_cloud_t points;
	float scale = 1.0;

	if(argc < 3)
	{
		fprintf(stderr, "usage : %s filename scale.\n", argv[0]);
		return EXIT_FAILURE;
	}

	scale = atof(argv[2]);
	if( !create(&points, scale) )
	{
		return EXIT_FAILURE;
	}
	if( !read_obj(argv[1], &points) )
	{
		goto err;
	}

	rescale(&points, 63);
	print("bla", &points);

	ret = EXIT_SUCCESS;
err:
	destroy(&points);
	return ret;
}
