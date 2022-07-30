require "sdl"
require "imgui"
require "crystal-raw-gl/gl"
require "../src/imgui-backends"

SDL.init(SDL::Init::None)

glsl_version = "#version 330"
LibSDL.gl_set_attribute(LibSDL::GLattr::SDL_GL_CONTEXT_PROFILE_MASK, LibSDL::GLprofile::PROFILE_CORE)
LibSDL.gl_set_attribute(LibSDL::GLattr::SDL_GL_CONTEXT_MAJOR_VERSION, 3)
LibSDL.gl_set_attribute(LibSDL::GLattr::SDL_GL_CONTEXT_MINOR_VERSION, 3)

LibSDL.gl_set_attribute(LibSDL::GLattr::SDL_GL_DOUBLEBUFFER, 1)
LibSDL.gl_set_attribute(LibSDL::GLattr::SDL_GL_DEPTH_SIZE, 24)
LibSDL.gl_set_attribute(LibSDL::GLattr::SDL_GL_STENCIL_SIZE, 8)
window_flags = SDL::Window::Flags::OPENGL | SDL::Window::Flags::RESIZABLE | SDL::Window::Flags::ALLOW_HIGHDPI
window = SDL::Window.new("test", 1280, 720, flags: window_flags)
gl_context = LibSDL.gl_create_context window
LibSDL.gl_make_current(window, gl_context)
LibSDL.gl_set_swap_interval(1) # Enable vsync

# Setup Dear ImGui context
ImGui.debug_check_version_and_data_layout(
  ImGui.get_version, *{
  sizeof(LibImGui::ImGuiIO), sizeof(LibImGui::ImGuiStyle), sizeof(ImGui::ImVec2),
  sizeof(ImGui::ImVec4), sizeof(ImGui::ImDrawVert), sizeof(ImGui::ImDrawIdx),
}.map &->LibC::SizeT.new(Int32))
ImGui.create_context
io = ImGui.get_io

ImGui::SDL2.init_for_opengl(window, gl_context)
ImGui::OpenGL3.init(glsl_version)

while event = SDL::Event.poll
  ImGui::SDL2.process_event(event)
end

ImGui::OpenGL3.new_frame
ImGui::SDL2.new_frame(window)
ImGui.new_frame

ImGui.render
GL.viewport(0, 0, io.display_size.x, io.display_size.y)
ImGui::OpenGL3.render_draw_data(ImGui.get_draw_data)
LibSDL.gl_swap_window(window)

ImGui::OpenGL3.shutdown
ImGui::SDL2.shutdown
ImGui.destroy_context

LibSDL.gl_delete_context(gl_context)
window.finalize
SDL.quit
