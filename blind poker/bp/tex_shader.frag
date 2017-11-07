uniform sampler2D tex;
varying mediump vec2 frag_tex_coord;

void main()
{
    gl_FragColor = texture2D(tex, frag_tex_coord);
}
