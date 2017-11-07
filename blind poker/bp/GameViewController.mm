

#import "GameViewController.h"
#import <OpenGLES/ES2/glext.h>

#include "Shader.h"
#include "matrix_utils.h"
#include "tga_image.h"

#include <iostream>
using std::cout;
using std::endl;

#include <vector>
using std::vector;

#include <chrono>
using std::chrono::high_resolution_clock;
using std::chrono::duration_cast;
using std::chrono::milliseconds;
using std::chrono::time_point;

float pi = 4*atan(1.0);
float y_fov_degrees = 45;
float y_fov_radians = pi/4;

float last_click_float_x;
float last_click_float_y;

bool gl_setup = false;

Shader *tex_shader;
Shader *flat_shader;

unsigned int triangle_buffer;
GLuint card_tex;
GLuint rank_tex;



@interface GameViewController(){}

@property (strong, nonatomic) EAGLContext *context;

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    // Call setupGL here, where the OpenGL context is
    // guaranteed to be valid
    [self setupGL];
}

- (void)dealloc
{
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setupGL
{
    if(gl_setup == true)
        return;
    
    gl_setup = true;
    
//    NSLog(@"setupGL");
    
    [EAGLContext setCurrentContext:self.context];
    
    glClearColor(0.284313, 0.415686, 0, 1);
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
    glClearDepthf(1.0);
    
    glEnable(GL_CULL_FACE);

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    tex_shader = new Shader("tex_shader.vert", "tex_shader.frag");
    
    if(!tex_shader->compileAndLink())
    {
        cout << "Failed to load tex shaders. Did you call setupGL while the context is invalid?" << endl;
        gl_setup = false;
        delete tex_shader;
        tex_shader = 0;
        return;
    }

    flat_shader = new Shader("flat_shader.vert", "flat_shader.frag");
    
    if(!flat_shader->compileAndLink())
    {
        cout << "Failed to load flat shaders. Did you call setupGL while the context is invalid?" << endl;
        gl_setup = false;
        delete tex_shader;
        tex_shader = 0;
        delete flat_shader;
        flat_shader = 0;
        return;
    }
    
    unsigned int m_renderbufferWidth, m_renderbufferHeight;
    CGRect Rect=[[UIScreen mainScreen] bounds];
    m_renderbufferWidth = Rect.size.width;
    m_renderbufferHeight = Rect.size.height;
    
    float projection_modelview_mat[16];
    
    init_perspective_camera(y_fov_degrees,
                            float(m_renderbufferWidth)/float(m_renderbufferHeight),
                            0.01f, 2.0f,
                            0, 0, 1, // Camera position.
                            0, 0, 0, // Look at position.
                            0, 1, 0, // Up direction vector.
                            projection_modelview_mat);
    
    glUseProgram(tex_shader->getProgram());
    
    glUniformMatrix4fv(glGetUniformLocation(tex_shader->getProgram(), "mvp_matrix"), 1, GL_FALSE, &projection_modelview_mat[0]);

    glUseProgram(flat_shader->getProgram());
    
    glUniformMatrix4fv(glGetUniformLocation(flat_shader->getProgram(), "mvp_matrix"), 1, GL_FALSE, &projection_modelview_mat[0]);
    
    glGenBuffers(1, &triangle_buffer);

    glActiveTexture(GL_TEXTURE0);
    glGenTextures(1, &card_tex);
    glBindTexture(GL_TEXTURE_2D, card_tex);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    NSString *fileRoot = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"card_texture.tga"];
    
    tga_32bit_image card_img;
    
    card_img.load([fileRoot UTF8String]);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, card_img.width, card_img.height,
                 0, GL_RGBA,
                 GL_UNSIGNED_BYTE, &card_img.pixels[0]);

    
    
    glActiveTexture(GL_TEXTURE1);
    glGenTextures(1, &rank_tex);
    glBindTexture(GL_TEXTURE_2D, rank_tex);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    fileRoot = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"rank_texture.tga"];
    
    tga_32bit_image rank_img;
 
    rank_img.load([fileRoot UTF8String]);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, rank_img.width, rank_img.height,
                 0, GL_RGBA,
                 GL_UNSIGNED_BYTE, &rank_img.pixels[0]);
}

- (void)tearDownGL
{
    if(gl_setup == false)
        return;
    
    gl_setup = false;
    
 //   NSLog(@"tearDownGL");
    
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &triangle_buffer);
    
    glDeleteTextures(1, &card_tex);
    
    glDeleteTextures(1, &rank_tex);
    
    if(tex_shader)
    {
        delete tex_shader;
        tex_shader = 0;
    }
    
    if(flat_shader)
    {
        delete flat_shader;
        flat_shader = 0;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{

    
    
}

void touch_up_pos(int x, int y, unsigned int m_renderbufferWidth, unsigned int m_renderbufferHeight)
{
    const float aspect = (float)(m_renderbufferWidth) / (float)(m_renderbufferHeight);
    const float fx = 2.0f * ((float)(x) / (float)(m_renderbufferWidth - 1)) - 1.0f;
    const float fy = 2.0f * ((float)(y) / (float)(m_renderbufferHeight - 1)) - 1.0f;
    const float tangent = tan(y_fov_radians / 2.0f);
    last_click_float_x = aspect*tangent*fx;
    last_click_float_y = -tangent*fy;
    
    cout << "touch up pos " << last_click_float_x << " " << last_click_float_y << endl;
}

- (void) touchesEnded: (NSSet*) touches withEvent: (UIEvent*) event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view];

    unsigned int m_renderbufferWidth, m_renderbufferHeight;
    CGRect Rect=[[UIScreen mainScreen] bounds];
    m_renderbufferWidth = Rect.size.width;
    m_renderbufferHeight = Rect.size.height;
    
    touch_up_pos(location.x, location.y, m_renderbufferWidth, m_renderbufferHeight);
}
 
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    // Call setupGL here, where the OpenGL context is
    // guaranteed to be valid
    if(gl_setup == false)
        [self setupGL];
    
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
 
    glUseProgram(tex_shader->getProgram());

    //  set the alpha on this to greater than zero to draw in a flat colour
    // it is done this way to save on shader objects
    //glUniform4f(glGetUniformLocation(flat_shader->getProgram(), "colour"), 0, 0, 0, 0);
    
    glUniform1i(glGetUniformLocation(tex_shader->getProgram(), "tex"), 0);
    //glUniform1i(glGetUniformLocation(shader.getProgram(), "tex"), 1);
    
     vector<GLfloat> vertex_data = {
        
        // 3D position, 2D texture coordinate
        
        // card front
        -0.025, -0.025,  0.0,   1*0.125, 4*0.125, // vertex 0
         0.025, -0.025,  0.0,   2*0.125, 4*0.125, // vertex 1
         0.025,  0.025,  0.0,   2*0.125, 5*0.125, // vertex 2
        -0.025, -0.025,  0.0,   1*0.125, 4*0.125, // vertex 0
         0.025,  0.025,  0.0,   2*0.125, 5*0.125, // vertex 2
        -0.025,  0.025,  0.0,   1*0.125, 5*0.125, // vertex 3

        // card back
         0.025,  0.025,  0.0,   4*0.125, 2*0.125, // vertex 2
         0.025, -0.025,  0.0,   4*0.125, 1*0.125, // vertex 1
        -0.025, -0.025,  0.0,   5*0.125, 1*0.125, // vertex 0
         0.025,  0.025,  0.0,   4*0.125, 2*0.125, // vertex 2
        -0.025, -0.025,  0.0,   5*0.125, 1*0.125, // vertex 0
        -0.025,  0.025,  0.0,   5*0.125, 2*0.125  // vertex 3
    };
    
    const GLuint components_per_vertex = 5;
    const GLuint components_per_position = 3;
    const GLuint components_per_tex_coord = 2;
    const GLuint num_vertices = vertex_data.size()/components_per_vertex;
    
    for(size_t i = 0; i < vertex_data.size(); i += components_per_vertex)
    {
        vertex_data[i + 0] += last_click_float_x;
        vertex_data[i + 1] += last_click_float_y;
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, triangle_buffer);
    
    glBufferData(GL_ARRAY_BUFFER, vertex_data.size()*sizeof(GLfloat), &vertex_data[0], GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(glGetAttribLocation(tex_shader->getProgram(), "position"));
    glVertexAttribPointer(glGetAttribLocation(tex_shader->getProgram(), "position"),
                          components_per_position,
                          GL_FLOAT,
                          GL_FALSE,
                          components_per_vertex*sizeof(GLfloat),
                          NULL);
    
    glEnableVertexAttribArray(glGetAttribLocation(tex_shader->getProgram(), "tex_coord"));
    glVertexAttribPointer(glGetAttribLocation(tex_shader->getProgram(), "tex_coord"),
                          components_per_tex_coord,
                          GL_FLOAT,
                          GL_TRUE,
                          components_per_vertex*sizeof(GLfloat),
                          (const GLvoid*)(components_per_position*sizeof(GLfloat)));
    
    // Draw 12 vertices per card
    glDrawArrays(GL_TRIANGLES, 0, num_vertices);

    
    
    
    /*
    static time_point<high_resolution_clock> t0 = high_resolution_clock::now();
    
    time_point<high_resolution_clock> t1 = high_resolution_clock::now();
    
    long long unsigned int ms = duration_cast <milliseconds>(t1 - t0).count();
    
    t0 = t1;
    
    cout << ms << endl;
    */
}

@end
