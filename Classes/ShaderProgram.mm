//
//  ShaderProgram.m
//  OpenGLEditor
//
//  Created by Filip Kunc on 12/31/09.
//  For license see LICENSE.TXT
//

#import "ShaderProgram.h"

void ProgramLog(GLuint program)
{
	int infoLogLength = 0;
	int charsWritten = 0;
	GLchar *infoLog;
	
	glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infoLogLength);
	
	if (infoLogLength > 0)
	{
		infoLog = (GLchar *)malloc((size_t)infoLogLength);
		glGetProgramInfoLog(program, infoLogLength, &charsWritten, infoLog);
		free(infoLog);
	}
}

ShaderProgram *globalNormalShader = nil;
ShaderProgram *globalFlippedShader = nil;

@implementation ShaderProgram

+ (ShaderProgram *)normalShader
{
	if (!globalNormalShader)
	{
		globalNormalShader = [[ShaderProgram alloc] init];
		[globalNormalShader attachShaderWithType:GL_VERTEX_SHADER resourceInBundle:@"twoSidedLighting"];
	}
	return globalNormalShader;
}

+ (ShaderProgram *)flippedShader
{
	if (!globalFlippedShader)
	{
		globalFlippedShader = [[ShaderProgram alloc] init];
		[globalFlippedShader attachShaderWithType:GL_VERTEX_SHADER resourceInBundle:@"twoSidedLightingFlipped"];
	}
	return globalFlippedShader;
}

- (id)init
{
	self = [super init];
	if (self)
	{
		program = glCreateProgram();
	}
	return self;
}

- (void)dealloc
{
	glDeleteProgram(program);
}

- (void)attachShaderWithType:(GLenum)type resourceInBundle:(NSString *)resourceInBundle
{
	Shader *shader = [[Shader alloc] initWithShaderType:type resourceInBundle:resourceInBundle];
	[self attachShader:shader]; // performs shader release
}

- (void)attachShader:(Shader *)aShader
{
	glAttachShader(program, [aShader shader]);
}

// GL_TRIANGLES, GL_TRIANGLE_STRIP
- (void)setGeometryInput:(GLenum)input output:(GLenum)output
{
	glProgramParameteriEXT(program, GL_GEOMETRY_INPUT_TYPE_EXT, (int)input);
	glProgramParameteriEXT(program, GL_GEOMETRY_OUTPUT_TYPE_EXT, (int)output);
	
	int temp;
	glGetIntegerv(GL_MAX_GEOMETRY_OUTPUT_VERTICES_EXT, &temp);
	glProgramParameteriEXT(program, GL_GEOMETRY_VERTICES_OUT_EXT, temp);
}

- (void)linkProgram
{
	glLinkProgram(program);	
	ProgramLog(program);
}

- (void)useProgram
{
	glUseProgram(program);
}

+ (void)resetProgram
{
	glUseProgram(0);
}

@end
