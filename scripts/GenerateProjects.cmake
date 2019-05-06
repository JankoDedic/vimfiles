# Current working directory should be the project root

# Constants
set(vcpkgToolchain C:/Users/Janko/vcpkg/scripts/buildsystems/vcpkg.cmake)

# Create binary directories
execute_process(COMMAND "${CMAKE_COMMAND}" -E remove_directory build                         )
execute_process(COMMAND "${CMAKE_COMMAND}" -E make_directory   build/x64-windows-ninja-debug )
execute_process(COMMAND "${CMAKE_COMMAND}" -E make_directory   build/x64-windows-vs          )

# Generate Ninja project
execute_process(
  COMMAND "${CMAKE_COMMAND}"
    -S .
    -B build/x64-windows-ninja-debug
    -G Ninja
    -D CMAKE_BUILD_TYPE:STRING=Debug
    -D CMAKE_EXPORT_COMPILE_COMMANDS:BOOL=ON
    -D CMAKE_TOOLCHAIN_FILE:FILEPATH=${vcpkgToolchain}
)
# mklink requires backslashes
execute_process(COMMAND cmd /C mklink /H compile_commands.json [[build\x64-windows-ninja-debug\compile_commands.json]])

# Generate Visual Studio project
execute_process(
  COMMAND "${CMAKE_COMMAND}"
    -S .
    -B build/x64-windows-vs
    -G "Visual Studio 16 2019" -A x64
    -D CMAKE_TOOLCHAIN_FILE:FILEPATH=${vcpkgToolchain}
)
