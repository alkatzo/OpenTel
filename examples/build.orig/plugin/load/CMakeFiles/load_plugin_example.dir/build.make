# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.28

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/alex/OpenTel/examples

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/alex/OpenTel/examples/build

# Include any dependencies generated for this target.
include plugin/load/CMakeFiles/load_plugin_example.dir/depend.make
# Include any dependencies generated by the compiler for this target.
include plugin/load/CMakeFiles/load_plugin_example.dir/compiler_depend.make

# Include the progress variables for this target.
include plugin/load/CMakeFiles/load_plugin_example.dir/progress.make

# Include the compile flags for this target's objects.
include plugin/load/CMakeFiles/load_plugin_example.dir/flags.make

plugin/load/CMakeFiles/load_plugin_example.dir/main.cc.o: plugin/load/CMakeFiles/load_plugin_example.dir/flags.make
plugin/load/CMakeFiles/load_plugin_example.dir/main.cc.o: /home/alex/OpenTel/examples/plugin/load/main.cc
plugin/load/CMakeFiles/load_plugin_example.dir/main.cc.o: plugin/load/CMakeFiles/load_plugin_example.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --green --progress-dir=/home/alex/OpenTel/examples/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object plugin/load/CMakeFiles/load_plugin_example.dir/main.cc.o"
	cd /home/alex/OpenTel/examples/build/plugin/load && /usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -MD -MT plugin/load/CMakeFiles/load_plugin_example.dir/main.cc.o -MF CMakeFiles/load_plugin_example.dir/main.cc.o.d -o CMakeFiles/load_plugin_example.dir/main.cc.o -c /home/alex/OpenTel/examples/plugin/load/main.cc

plugin/load/CMakeFiles/load_plugin_example.dir/main.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --green "Preprocessing CXX source to CMakeFiles/load_plugin_example.dir/main.cc.i"
	cd /home/alex/OpenTel/examples/build/plugin/load && /usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /home/alex/OpenTel/examples/plugin/load/main.cc > CMakeFiles/load_plugin_example.dir/main.cc.i

plugin/load/CMakeFiles/load_plugin_example.dir/main.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --green "Compiling CXX source to assembly CMakeFiles/load_plugin_example.dir/main.cc.s"
	cd /home/alex/OpenTel/examples/build/plugin/load && /usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /home/alex/OpenTel/examples/plugin/load/main.cc -o CMakeFiles/load_plugin_example.dir/main.cc.s

# Object files for target load_plugin_example
load_plugin_example_OBJECTS = \
"CMakeFiles/load_plugin_example.dir/main.cc.o"

# External object files for target load_plugin_example
load_plugin_example_EXTERNAL_OBJECTS =

plugin/load/load_plugin_example: plugin/load/CMakeFiles/load_plugin_example.dir/main.cc.o
plugin/load/load_plugin_example: plugin/load/CMakeFiles/load_plugin_example.dir/build.make
plugin/load/load_plugin_example: plugin/load/CMakeFiles/load_plugin_example.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --green --bold --progress-dir=/home/alex/OpenTel/examples/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX executable load_plugin_example"
	cd /home/alex/OpenTel/examples/build/plugin/load && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/load_plugin_example.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
plugin/load/CMakeFiles/load_plugin_example.dir/build: plugin/load/load_plugin_example
.PHONY : plugin/load/CMakeFiles/load_plugin_example.dir/build

plugin/load/CMakeFiles/load_plugin_example.dir/clean:
	cd /home/alex/OpenTel/examples/build/plugin/load && $(CMAKE_COMMAND) -P CMakeFiles/load_plugin_example.dir/cmake_clean.cmake
.PHONY : plugin/load/CMakeFiles/load_plugin_example.dir/clean

plugin/load/CMakeFiles/load_plugin_example.dir/depend:
	cd /home/alex/OpenTel/examples/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/alex/OpenTel/examples /home/alex/OpenTel/examples/plugin/load /home/alex/OpenTel/examples/build /home/alex/OpenTel/examples/build/plugin/load /home/alex/OpenTel/examples/build/plugin/load/CMakeFiles/load_plugin_example.dir/DependInfo.cmake "--color=$(COLOR)"
.PHONY : plugin/load/CMakeFiles/load_plugin_example.dir/depend

