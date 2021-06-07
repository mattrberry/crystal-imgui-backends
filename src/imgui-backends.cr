require "sdl"
require "imgui"

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
      # TODO: This is a temporary fix until https://github.com/ysbaddaden/sdl.cr/pull/42 is merged
      ptr = (pointerof(event).as(Int32*) + 2).as(LibSDL::Event*)
      LibImGuiBackends.ImGui_ImplSDL2_ProcessEvent(ptr)
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
