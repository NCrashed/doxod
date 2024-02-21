module render;

import std.file;
import std.stdio;
import std.string;
import bindbc.opengl;

const GLfloat[9] triangleVertecies = [
    -1.0f, -1.0f, 0.0f,
    1.0f, -1.0f, 0.0f,
    0.0f, 1.0f, 0.0f,
];

struct Renderer
{
    GLuint vertexArray;
    GLuint vertexBuffer;
    GLuint programId;

    void load()
    {
        glGenVertexArrays(1, &vertexArray);
        glBindVertexArray(vertexArray);

        glGenBuffers(1, &vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, triangleVertecies.sizeof, cast(const(void)*)&triangleVertecies, GL_STATIC_DRAW);
        programId = loadShaders("assets/shader/triangle.vs", "assets/shader/triangle.fs");
    }

    void draw()
    {
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glUseProgram(programId);

        glEnableVertexAttribArray(0);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, null);
        glDrawArrays(GL_TRIANGLES, 0, 3);
        glDisableVertexAttribArray(0);
    }

    ~this()
    {
        if (programId)
        {
            glDeleteProgram(programId);
        }
    }
}

GLuint loadShaders(string vertexFilePath, string fragmentFilePath)
{
    auto vertexShaderId = glCreateShader(GL_VERTEX_SHADER);
    scope (exit)
        glDeleteShader(vertexShaderId);

    auto fragmentShaderId = glCreateShader(GL_FRAGMENT_SHADER);
    scope (exit)
        glDeleteShader(fragmentShaderId);

    auto vertexShaderText = readText(vertexFilePath).toStringz();
    auto fragmentShaderText = readText(fragmentFilePath).toStringz();

    GLint result = GL_FALSE;
    int infoLogLength;

    // Compile vertex shader
    writeln("Compiling shader ", vertexFilePath);
    glShaderSource(vertexShaderId, 1, &vertexShaderText, null);
    glCompileShader(vertexShaderId);

    // Check vertex shader 
    glGetShaderiv(vertexShaderId, GL_COMPILE_STATUS, &result);
    glGetShaderiv(vertexShaderId, GL_INFO_LOG_LENGTH, &infoLogLength);
    if (infoLogLength > 0)
    {
        auto errorMessage = new char[infoLogLength + 1];
        glGetShaderInfoLog(vertexShaderId, infoLogLength, null, &errorMessage[0]);
        writeln(errorMessage);
    }

    // Compile fragment shader
    writeln("Compiling shader ", fragmentFilePath);
    glShaderSource(fragmentShaderId, 1, &fragmentShaderText, null);
    glCompileShader(fragmentShaderId);

    // Check fragment shader 
    glGetShaderiv(fragmentShaderId, GL_COMPILE_STATUS, &result);
    glGetShaderiv(fragmentShaderId, GL_INFO_LOG_LENGTH, &infoLogLength);
    if (infoLogLength > 0)
    {
        auto errorMessage = new char[infoLogLength + 1];
        glGetShaderInfoLog(fragmentShaderId, infoLogLength, null, &errorMessage[0]);
        writeln(errorMessage);
    }

    // Link the program
    writeln("Linking shaders...");
    GLuint programId = glCreateProgram();
    glAttachShader(programId, vertexShaderId);
    glAttachShader(programId, fragmentShaderId);
    scope (exit)
    {
        glDetachShader(programId, vertexShaderId);
        glDetachShader(programId, fragmentShaderId);
    }
    glLinkProgram(programId);

    // Check the program
    glGetProgramiv(programId, GL_LINK_STATUS, &result);
    glGetProgramiv(programId, GL_INFO_LOG_LENGTH, &infoLogLength);
    if (infoLogLength > 0)
    {
        auto errorMessage = new char[infoLogLength + 1];
        glGetShaderInfoLog(fragmentShaderId, infoLogLength, null, &errorMessage[0]);
        writeln(errorMessage);
    }

    return programId;
}
