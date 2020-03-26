# Current working directory should be the project root

# Constants
set(vcpkgToolchain C:/Users/Janko/vcpkg/scripts/buildsystems/vcpkg.cmake)

# Create binary directory
execute_process(COMMAND "${CMAKE_COMMAND}" -E remove_directory build)
execute_process(COMMAND "${CMAKE_COMMAND}" -E make_directory build)

# Generate Ninja project
execute_process(
  COMMAND "${CMAKE_COMMAND}"
    -S .
    -B build
    -G Ninja
    -D CMAKE_C_COMPILER=clang
    -D CMAKE_CXX_COMPILER=clang++
    -D CMAKE_BUILD_TYPE:STRING=Debug
    -D CMAKE_EXPORT_COMPILE_COMMANDS:BOOL=ON
    -D CMAKE_TOOLCHAIN_FILE:FILEPATH=${vcpkgToolchain}
)

# Add compile_commands.json to the root of the project.
# mklink requires backslashes
set(compileCommandsPath build/compile_commands.json)
file(TO_NATIVE_PATH "${compileCommandsPath}" compileCommandsPath)
execute_process(COMMAND cmd /C mklink /H compile_commands.json "${compileCommandsPath}")
