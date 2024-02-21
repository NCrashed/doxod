module init;

import std.stdio;
import bindbc.opengl;
import bindbc.glfw;

/*
 Import the sharedlib module for error handling. Assigning an alias ensures the function names do not conflict with
 other public APIs. This isn't strictly necessary, but the API names are common enough that they could appear in other
 packages.
*/
import loader = bindbc.loader.sharedlib;

// Create the OpenGL context before calling this function.
bool engineLoadGL()
{
    /*
     Compare the return value of loadGL with the global `glSupport` constant to determine if the version of GLFW
     configured at compile time is the version that was loaded.
    */
    auto ret = loadOpenGL();
    if (ret != GLSupport.gl33)
    {
        // Log the error info
        foreach (info; loader.errors)
        {
            writeln("OpengGL ", info.error, ": ", info.message);
        }

        // Optionally construct a user-friendly error message for the user
        string msg;
        if (ret == GLSupport.noLibrary)
        {
            msg = "This application requires the GLFW library.";
        }
        else if (ret == GLSupport.badLibrary)
        {
            msg = "The version of the GLFW library on your system is too low. Please upgrade.";
        }
        // GLSupport.noContext
    else
        {
            msg = "This program has encountered a graphics configuration error. Please report it to the developers.";
        }
        writeln(msg);
        return false;
    }
    return true;
}

bool engineLoadGLFW()
{
    /*
     Compare the return value of loadGLFW with the global `glfwSupport` constant to determine if the version of GLFW
     configured at compile time is the version that was loaded.
    */
    auto ret = loadGLFW();
    if (ret != glfwSupport)
    {
        // Log the error info
        foreach (info; loader.errors)
        {
            /*
             A hypothetical logging function. Note that `info.error` and `info.message` are `const(char)*`, not
             `string`.
            */
            writeln("GLFW ", info.error, ": ", info.message);
        }

        // Optionally construct a user-friendly error message for the user
        string msg;
        if (ret == GLFWSupport.noLibrary)
        {
            msg = "This application requires the GLFW library.";
        }
        else
        {
            msg = "The version of the GLFW library on your system is too low. Please upgrade.";
        }
        writeln(msg);
        return false;
    }
    return true;
}
