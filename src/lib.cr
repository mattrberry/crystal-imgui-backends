require "sdl"
require "imgui"

@[Link("gl")]
@[Link("cimgui")]
@[Link("stdc++")]
@[Link(ldflags: "-L#{__DIR__}/../cimgui -L#{__DIR__}/.. #{__DIR__}/../*.o")]
lib LibImGuiBackends
  # SDL2
  fun ImGui_ImplSDL2_InitForOpenGL = Crystal_ImGui_ImplSDL2_InitForOpenGL(window : LibSDL::Window*, gl_context : LibSDL::GLContext) : Bool
  fun ImGui_ImplSDL2_NewFrame = Crystal_ImGui_ImplSDL2_NewFrame(window : LibSDL::Window*)
  fun ImGui_ImplSDL2_ProcessEvent = Crystal_ImGui_ImplSDL2_ProcessEvent(event : Void*) : Bool
  fun ImGui_ImplSDL2_Shutdown = Crystal_ImGui_ImplSDL2_Shutdown

  # OpenGL3
  fun ImGui_ImplOpenGL3_Init = Crystal_ImGui_ImplOpenGL3_Init(glsl_version : UInt8*) : Bool
  fun ImGui_ImplOpenGL3_NewFrame = Crystal_ImGui_ImplOpenGL3_NewFrame
  fun ImGui_ImplOpenGL3_RenderDrawData = Crystal_ImGui_ImplOpenGL3_RenderDrawData(draw_data : Void*)
  fun ImGui_ImplOpenGL3_Shutdown = Crystal_ImGui_ImplOpenGL3_Shutdown

  # Misc
  fun gl3wInit
end
