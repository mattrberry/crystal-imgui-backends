require "sdl"
require "imgui"
require "./lib"

module ImGui
  module SDL2
    extend self

    def init_for_opengl(window : SDL::Window, gl_context : LibSDL::GLContext) : Bool
      LibImGuiBackends.ImGui_ImplSDL2_InitForOpenGL(window, gl_context)
    end

    def new_frame(window : SDL::Window) : Nil
      LibImGuiBackends.ImGui_ImplSDL2_NewFrame(window)
    end

    def process_event(event : SDL::Event) : Bool
      LibImGuiBackends.ImGui_ImplSDL2_ProcessEvent(event)
    end

    def shutdown : Nil
      LibImGuiBackends.ImGui_ImplSDL2_Shutdown
    end
  end

  module OpenGL3
    extend self

    def init(glsl_version : String) : Bool
      LibImGuiBackends.ImGui_ImplOpenGL3_Init(glsl_version)
    end

    def new_frame : Nil
      LibImGuiBackends.ImGui_ImplOpenGL3_NewFrame
    end

    def render_draw_data(im_draw_data : ImDrawData) : Nil
      LibImGuiBackends.ImGui_ImplOpenGL3_RenderDrawData(im_draw_data)
    end

    def shutdown : Nil
      LibImGuiBackends.ImGui_ImplOpenGL3_Shutdown
    end
  end
end
