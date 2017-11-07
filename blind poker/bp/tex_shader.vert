attribute vec3 position;
attribute vec2 tex_coord;
uniform mat4 mvp_matrix;
varying vec2 frag_tex_coord;

void main()
{
    frag_tex_coord = tex_coord;
    gl_Position = mvp_matrix*vec4(position, 1);
}
