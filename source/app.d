import std.stdio;
import bindbc.opengl;
import bindbc.glfw;

import init;
import render;

void printGLFWError()
{
    const(char)* description;
    int code = glfwGetError(&description);

    if (description)
    {
        writeln("Code: ", code, ". Description: ", description);
    }
}

extern (C) @nogc nothrow void framebufferSizeCallback(GLFWwindow* window, int width, int height)
{
    glViewport(0, 0, width, height);
}

extern (C) void main()
{
    // Load GLFW functions
    if (!engineLoadGLFW())
    {
        return;
    }

    // Initialize GLFW itself
    if (!glfwInit())
    {
        writeln("Failed to init GLFW");
        printGLFWError();
        return;
    }
    scope (exit)
        glfwTerminate();

    // Set which OpenGL context to create before window 
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);

    // Create Window
    auto window = glfwCreateWindow(800, 600, "Doxod showcase", null, null);
    if (!window)
    {
        writeln("Failed to create main window");
        printGLFWError();
    }
    scope (exit)
        glfwDestroyWindow(window);

    // Set OpenGL context first and next load OpenGL functions
    glfwMakeContextCurrent(window);
    if (!engineLoadGL())
    {
        return;
    }

    glfwSetFramebufferSizeCallback(window, &framebufferSizeCallback);

    // Now load OpenGL renderer
    auto renderer = Renderer();
    renderer.load();

    while (!glfwWindowShouldClose(window))
    {
        renderer.draw();

        glfwSwapBuffers(window);
        glfwPollEvents();
    }
}
