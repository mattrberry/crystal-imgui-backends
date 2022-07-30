imgui := cimgui/imgui
backends := $(imgui)/backends
supported_backends := sdl opengl3
supported_backends_full := $(addprefix imgui_impl_, $(addsuffix .o, $(supported_backends)))

cimgui_src := cimgui/cimgui.cpp cimgui/cimgui.h
imgui_src := $(imgui)/imgui.h $(imgui)/imgui.cpp $(imgui)/imgui_draw.cpp $(imgui)/imgui_widgets.cpp $(imgui)/imgui_tables.cpp $(imgui)/imgui_demo.cpp
bind_objs := $(addprefix src/bind_, $(supported_backends_full)) # all bindings must be named bind_imgui_impl_<backend>.o
backend_objs := $(addprefix $(backends)/, $(supported_backends_full)) # add imgui backend sources
obj_files := imgui.o imgui_draw.o imgui_widgets.o imgui_tables.o imgui_demo.o cimgui.o
obj_files += $(bind_objs) $(backend_objs)

ifeq ($(shell uname -s),Darwin)
	opengl := -framework OpenGL
else
	opengl := -lGL
endif

libcimgui.so: $(obj_files)
	$(CXX) -std=c++11 -fPIC -shared $(opengl) -o $@ $(obj_files)

# stick shared libraries in requiring shard's root
shard: libcimgui.so
	ln -f -s lib/imgui-backends/libcimgui.so ../..

config_flags := -std=c++11 -fPIC -I. -I$(imgui) -I$(backends)

%.o: $(imgui)/%.cpp $(imgui)/imgui.h
	@echo Building $@
	$(CXX) $(config_flags) $(CXXFLAGS) -o $@ -c $<

cimgui.o: $(cimgui_src) $(imgui)/imgui.h
	@echo Building cimgui.o
	$(CXX) $(config_flags) $(CXXFLAGS) -o $@ -c $<

src/bind_%.o: src/bind_%.cpp $(imgui)/imgui.h
	@echo Building binding $@
	$(CXX) $(config_flags) $(CXXFLAGS) -o $@ -c $<

$(backends)/%.o: $(backends)/%.cpp $(imgui)/imgui.h
	@echo Building backend $@
	$(CXX) $(config_flags) $(CXXFLAGS) `sdl2-config --cflags` -o $@ -c $<

# cimgui/imgui/backends/imgui_impl_sdl.o: cimgui/imgui/backends/imgui_impl_sdl.cpp $(imgui)/imgui.h
# 	@echo Building backend $@   ":("
# 	$(CXX) $(config_flags) $(CXXFLAGS) `sdl2-config --cflags` -o $@ -c $<

# cimgui/imgui/backends/imgui_impl_opengl3.o: cimgui/imgui/backends/imgui_impl_opengl3.cpp $(imgui)/imgui.h
# 	@echo Building backend $@   ":("
# 	$(CXX) $(config_flags) $(CXXFLAGS) `sdl2-config --cflags` -o $@ -c $<

.PRECIOUS: $(cimgui_src) $(imgui_src)

.INTERMEDIATE: cimgui_src
$(cimgui_src): cimgui_src ;
cimgui_src:
	curl -s -L https://github.com/cimgui/cimgui/archive/1.87.tar.gz | tar -xz --strip-components=1 -C cimgui

.INTERMEDIATE: imgui_src
$(imgui_src): imgui_src ;
imgui_src: cimgui_src
	curl -s -L https://github.com/ocornut/imgui/archive/v1.87.tar.gz | tar -xz --strip-components=1 -C $(imgui)

.PHONY: clean
clean:
	rm -f $(obj_files) *.o *.obj *.so *.lib
	git submodule foreach --recursive git reset --hard
