

#ifndef matrix_utils_h
#define matrix_utils_h

#include <stdio.h>
#include "vertex_3.h"



void get_perspective_matrix(float fovy, float aspect, float znear, float zfar, float (&mat)[16]);

void get_look_at_matrix(float eyex, float eyey, float eyez, float centrex, float centrey, float centrez, float upx, float upy, float upz, float (&mat)[16]);

void multiply_4x4_matrices(float (&in_a)[16], float (&in_b)[16], float (&out)[16]);

void init_perspective_camera(float fovy, float aspect, float znear, float zfar,
                             float eyex, float eyey, float eyez,
                             float centrex, float centrey, float centrez,
                             float upx, float upy, float upz,
                             float (&projection_modelview_mat)[16]);


#endif
