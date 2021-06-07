IMGUI_DIR = cimgui/imgui
SOURCES = src/bind_imgui_impl_sdl.cpp src/bind_imgui_impl_opengl3.cpp
SOURCES += $(IMGUI_DIR)/backends/imgui_impl_sdl.cpp $(IMGUI_DIR)/backends/imgui_impl_opengl3.cpp
OBJS = $(addsuffix .o, $(basename $(notdir $(SOURCES))))
UNAME_S := $(shell uname -s)

CXXFLAGS = -I$(IMGUI_DIR) -I$(IMGUI_DIR)/backends
CXXFLAGS += -g -Wall -Wformat
CXXFLAGS += -fPIC -I.
LIBS =

SOURCES += $(IMGUI_DIR)/examples/libs/gl3w/GL/gl3w.c
CXXFLAGS += -I$(IMGUI_DIR)/examples/libs/gl3w -DIMGUI_IMPL_OPENGL_LOADER_GL3W

ifeq ($(UNAME_S), Linux) # Linux
	LIBS += -lGl -ldl `sdl2-config --libs`
	CXXFLAGS += `sdl2-config --cflags`
	CFLAGS = $(CXXFLAGS)
else ifeq ($(UNAME_S), Darwin) # Mac
	LIBS += -framework OpenGL -framework Cocoa -framework IOKit -framework CoreVideo `sdl2-config --libs`
	LIBS += -L/usr/local/lib -L/opt/local/lib
	CXXFLAGS += `sdl2-config --cflags`
	CXXFLAGS += -I/usr/local/include -I/opt/local/include
	CFLAGS = $(CXXFLAGS)
else # Windows
    LIBS += -lgdi32 -lopengl32 -limm32 `pkg-config --static --libs sdl2`
    CXXFLAGS += `pkg-config --cflags sdl2`
    CFLAGS = $(CXXFLAGS)
endif

all: cimgui_path $(OBJS)

########## Build rules

%.o:%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

%.o:$(IMGUI_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

%.o:$(IMGUI_DIR)/backends/%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

%.o:$(IMGUI_DIR)/examples/libs/gl3w/GL/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.o:src/%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

########## Setting up dependencies

cimgui_path: init_submodules
	cmake -DCMAKE_CXX_FLAGS='-DIMGUI_USE_WCHAR32' -S cimgui -B cimgui
	cmake --build cimgui
	ln -f -s cimgui/cimgui.so libcimgui.so  # or .dylib on macOS

.PHONY: init_submodules
init_submodules: cimgui cimgui/imgui

.PHONY: cimgui/imgui
cimgui/imgui:
	git submodule update --init --recursive

########## Cleanup

clean:
	rm -f $(OBJS)
	git submodule foreach --recursive git reset --hard
