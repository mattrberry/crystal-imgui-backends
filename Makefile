IMGUI_DIR = cimgui/imgui
SOURCES = src/bind_imgui_impl_sdl.cpp src/bind_imgui_impl_opengl3.cpp
AFTER_CLONE = $(IMGUI_DIR)/backends/imgui_impl_sdl.cpp $(IMGUI_DIR)/backends/imgui_impl_opengl3.cpp
UNAME_S := $(shell uname -s)

CXXFLAGS = -I$(IMGUI_DIR) -I$(IMGUI_DIR)/backends
CXXFLAGS += -g -Wall -Wformat
CXXFLAGS += -fPIC -I.
LIBS =

AFTER_CLONE += $(IMGUI_DIR)/examples/libs/gl3w/GL/gl3w.c
CXXFLAGS += -I$(IMGUI_DIR)/examples/libs/gl3w -DIMGUI_IMPL_OPENGL_LOADER_GL3W

SOURCES += $(AFTER_CLONE)
OBJS = $(addsuffix .o, $(basename $(notdir $(SOURCES))))

ifeq ($(UNAME_S), Linux) # Linux
	LIBS += -lGl -ldl `sdl2-config --libs`
	CXXFLAGS += `sdl2-config --cflags`
	CFLAGS = $(CXXFLAGS)
	SHARED_LIB_EXT = so
else ifeq ($(UNAME_S), Darwin) # Mac
	LIBS += -framework OpenGL -framework Cocoa -framework IOKit -framework CoreVideo `sdl2-config --libs`
	LIBS += -L/usr/local/lib -L/opt/local/lib
	CXXFLAGS += `sdl2-config --cflags`
	CXXFLAGS += -I/usr/local/include -I/opt/local/include
	CFLAGS = $(CXXFLAGS)
	SHARED_LIB_EXT = dylib
else # Windows
    LIBS += -lgdi32 -lopengl32 -limm32 `pkg-config --static --libs sdl2`
    CXXFLAGS += `pkg-config --cflags sdl2`
    CFLAGS = $(CXXFLAGS)
endif

all: cimgui_path checkpoint $(OBJS)

checkpoint: $(AFTER_CLONE)

########## For Shard install

shard: all
	ln -f -s lib/imgui-backends/cimgui/cimgui.$(SHARED_LIB_EXT) ../..

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
	ln -f -s cimgui/cimgui.$(SHARED_LIB_EXT) cimgui.$(SHARED_LIB_EXT) # or .dylib on macOS
	ln -f -s cimgui/cimgui.$(SHARED_LIB_EXT) libcimgui.$(SHARED_LIB_EXT) # or .dylib on macOS

init_submodules: cimgui_src imgui_src

# Need to curl these rather than git submodule update since shards doesn't git clone

.INTERMEDIATE: cimgui_src
$(cimgui_src): cimgui_src ;
cimgui_src:
	curl -s -L https://github.com/cimgui/cimgui/archive/83f729b09313749a56948604c4bc13492ac47e00.tar.gz | tar -xz --strip-components=1 -C cimgui

.INTERMEDIATE: imgui_src
$(imgui_src): imgui_src ;
imgui_src: cimgui_src
	curl -s -L https://github.com/ocornut/imgui/archive/64aab8480a5643cec1880af17931963a90a8f990.tar.gz | tar -xz --strip-components=1 -C cimgui/imgui

########## Cleanup

clean:
	rm -f $(OBJS)
	rm -f cimgui.$(SHARED_LIB_EXT)
	rm -f libcimgui.$(SHARED_LIB_EXT)
	git submodule foreach --recursive git reset --hard
