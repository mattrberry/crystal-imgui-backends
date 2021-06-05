#include <cstdio>
#include <GL/gl.h>
#include "cimgui/imgui/backends/imgui_impl_opengl3.h"

extern "C" {
    bool Crystal_ImGui_ImplOpenGL3_Init(const char* glsl_version) {
        return ImGui_ImplOpenGL3_Init(glsl_version);
    }

    void Crystal_ImGui_ImplOpenGL3_NewFrame() {
        ImGui_ImplOpenGL3_NewFrame();
    }

    void Crystal_ImGui_ImplOpenGL3_RenderDrawData(ImDrawData* draw_data) {
        ImGui_ImplOpenGL3_RenderDrawData(draw_data);
    }

    void Crystal_ImGui_ImplOpenGL3_Shutdown() {
        ImGui_ImplOpenGL3_Shutdown();
    }
}
