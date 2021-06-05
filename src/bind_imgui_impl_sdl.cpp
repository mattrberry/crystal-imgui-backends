#include <SDL2/SDL.h>
#include "cimgui/imgui/backends/imgui_impl_sdl.h"

extern "C" {
    bool Crystal_ImGui_ImplSDL2_InitForOpenGL(SDL_Window* window, void* sdl_gl_context) {
        return ImGui_ImplSDL2_InitForOpenGL(window, sdl_gl_context);
    }

    void Crystal_ImGui_ImplSDL2_NewFrame(SDL_Window* window) {
        ImGui_ImplSDL2_NewFrame(window);
    }

    bool Crystal_ImGui_ImplSDL2_ProcessEvent(const SDL_Event* event) {
        return ImGui_ImplSDL2_ProcessEvent(event);
    }
}
