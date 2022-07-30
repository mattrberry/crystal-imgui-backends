# This example is designed to roughly mirror https://github.com/ocornut/imgui/blob/master/examples/example_sdl_opengl3/main.cpp

require "sdl"
require "imgui"
require "crystal-raw-gl/gl"
require "../src/imgui-backends"

SDL.init(SDL::Init::VIDEO | SDL::Init::AUDIO | SDL::Init::JOYSTICK)
LibSDL.joystick_open 0
at_exit { SDL.quit }

glsl_version = "#version 330"
LibSDL.gl_set_attribute(LibSDL::GLattr::SDL_GL_CONTEXT_PROFILE_MASK, LibSDL::GLprofile::PROFILE_CORE)
LibSDL.gl_set_attribute(LibSDL::GLattr::SDL_GL_CONTEXT_MAJOR_VERSION, 3)
LibSDL.gl_set_attribute(LibSDL::GLattr::SDL_GL_CONTEXT_MINOR_VERSION, 3)

# Create window with graphics context
LibSDL.gl_set_attribute(LibSDL::GLattr::SDL_GL_DOUBLEBUFFER, 1)
LibSDL.gl_set_attribute(LibSDL::GLattr::SDL_GL_DEPTH_SIZE, 24)
LibSDL.gl_set_attribute(LibSDL::GLattr::SDL_GL_STENCIL_SIZE, 8)
window_flags = SDL::Window::Flags::OPENGL | SDL::Window::Flags::RESIZABLE | SDL::Window::Flags::ALLOW_HIGHDPI
window = SDL::Window.new("imgui_impl_opengl3", 1280, 720, flags: window_flags)
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
# io.config_flags |= ImGui::ImGuiConfigFlags::NavEnableKeyboard # Enable Keyboard Controls
# io.config_flags |= ImGui::ImGuiConfigFlags::NavEnableGamepad # Enable Gamepad Controls

# Setup Dear ImGui style
ImGui.style_colors_dark
# ImGui.style_colors_light

# Setup Platform/Renderer backends
ImGui::SDL2.init_for_opengl(window, gl_context)
ImGui::OpenGL3.init(glsl_version)

# Our state
show_demo_window = true
show_another_window = false
clear_color = ImGui::ImVec4.new 0.45, 0.55, 0.60, 1.00
f = 0.0
counter = 0

# Main loop
done = false
until done
  # Poll and handle events (inputs, window resize, etc.)
  # You can read the io.WantCaptureMouse, io.WantCaptureKeyboard flags to tell if dear imgui wants to use your inputs.
  # - When io.WantCaptureMouse is true, do not dispatch mouse input data to your main application, or clear/overwrite your copy of the mouse data.
  # - When io.WantCaptureKeyboard is true, do not dispatch keyboard input data to your main application, or clear/overwrite your copy of the keyboard data.
  # Generally you may always pass all inputs to dear imgui, and hide them from your application based on those two flags.
  while event = SDL::Event.poll
    ImGui::SDL2.process_event(event)
    case event
    when SDL::Event::Quit then done = true
    when SDL::Event::Keyboard
      case event.sym
      when .q? then done = true
      end
    end
  end

  # Start the Dear ImGui frame
  ImGui::OpenGL3.new_frame
  ImGui::SDL2.new_frame(window)
  ImGui.new_frame

  # 1. Show the big demo window (Most of the sample code is in ImGui::ShowDemoWindow()! You can browse its code to learn more about Dear ImGui!).
  ImGui.show_demo_window(pointerof(show_demo_window)) if show_demo_window

  # 2. Show a simple window that we create ourselves. We use a Begin/End pair to created a named window.
  ImGui.begin("Hello, world!")
  ImGui.text("This is some useful text.")
  ImGui.checkbox("Demo Window", pointerof(show_demo_window))
  ImGui.checkbox("Another Window", pointerof(show_another_window))
  ImGui.slider_float("float", pointerof(f).as(Float32*), 0.0_f32, 1.0_f32)
  ImGui.color_edit3("clear color", pointerof(clear_color))
  counter += 1 if ImGui.button("Button")
  ImGui.same_line
  ImGui.text("counter = #{counter}")
  ImGui.text("Application average #{(1000 / io.framerate).format(decimal_places: 3)} ms/frame (#{io.framerate.format(decimal_places: 1)} FPS)")
  ImGui.end

  # 3. Show another simple window.
  if show_another_window
    ImGui.begin("Another Window", pointerof(show_another_window))
    ImGui.text("Hello from another window!")
    show_another_window = false if ImGui.button("Close Me")
    ImGui.end
  end

  # Rendering
  ImGui.render
  GL.viewport(0, 0, io.display_size.x, io.display_size.y)
  GL.clear_color(clear_color.x * clear_color.w, clear_color.y * clear_color.w, clear_color.z * clear_color.w, clear_color.w)
  GL.clear(GL::COLOR_BUFFER_BIT)
  ImGui::OpenGL3.render_draw_data(ImGui.get_draw_data)
  LibSDL.gl_swap_window(window)
end

# Cleanup
ImGui::OpenGL3.shutdown
ImGui::SDL2.shutdown
ImGui.destroy_context

LibSDL.gl_delete_context(gl_context)
window.finalize
SDL.quit
