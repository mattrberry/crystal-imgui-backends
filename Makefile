IMGUI_DIR = cimgui/imgui
SOURCES = src/bind_imgui_impl_sdl.cpp src/bind_imgui_impl_opengl3.cpp
AFTER_CLONE = $(IMGUI_DIR)/backends/imgui_impl_sdl.cpp $(IMGUI_DIR)/backends/imgui_impl_opengl3.cpp
UNAME_S := $(shell uname -s)

CXXFLAGS = -I$(IMGUI_DIR) -I$(IMGUI_DIR)/backends
CXXFLAGS += -g -Wall -Wformat
CXXFLAGS += -fPIC -I.
LIBS =

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
	CXXFLAGS += -I/usr/local/include -I/opt/local/include -I/opt/homebrew/include
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
	ln -f -s lib/imgui-backends/*.$(SHARED_LIB_EXT) ../.. # stick shared libraries in requiring shard's root

########## Build rules

%.o:%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

%.o:$(IMGUI_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

%.o:$(IMGUI_DIR)/backends/%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

%.o:src/%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

########## Setting up dependencies

cimgui_path: init_submodules
	cd cimgui && make
	ln -f -s cimgui/cimgui.$(SHARED_LIB_EXT) cimgui.$(SHARED_LIB_EXT)
	ln -f -s cimgui/cimgui.$(SHARED_LIB_EXT) libcimgui.$(SHARED_LIB_EXT)

init_submodules: cimgui_src imgui_src

# Need to curl these rather than git submodule update since shards doesn't git clone

.INTERMEDIATE: cimgui_src
$(cimgui_src): cimgui_src ;
cimgui_src:
	curl -s -L https://github.com/cimgui/cimgui/archive/1.86.tar.gz | tar -xz --strip-components=1 -C cimgui

.INTERMEDIATE: imgui_src
$(imgui_src): imgui_src ;
imgui_src: cimgui_src
	curl -s -L https://github.com/ocornut/imgui/archive/v1.86.tar.gz | tar -xz --strip-components=1 -C cimgui/imgui

########## Cleanup

clean:
	rm -f $(OBJS)
	rm -f cimgui.$(SHARED_LIB_EXT)
	rm -f libcimgui.$(SHARED_LIB_EXT)
	git submodule foreach --recursive git reset --hard
