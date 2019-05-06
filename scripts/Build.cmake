# Current working directory should be the project root

execute_process(COMMAND "${CMAKE_COMMAND}" --build build/x64-windows-ninja-debug --config Debug RESULT_VARIABLE result)
if(result)
  message(STATUS "${result}")
endif()

  # let g:cpp_scripts = {
  #   \ 'generate': 'rmdir /S /Q build & cd ' . git_repo_root
  #   \   . ' && mkdir build && cd build'
  #   \   . ' && mkdir x64-windows-ninja && cd x64-windows-ninja'
  #   \   . ' && cmake ..\..'
  #   \   . ' -G Ninja'
  #   \   . ' -D CMAKE_EXPORT_COMPILE_COMMANDS=ON'
  #   \   . ' -D CMAKE_TOOLCHAIN_FILE=' . vcpkg_toolchain
  #   \   . ' && cd ..\..'
  #   \   . ' && mklink /H compile_commands.json build\x64-windows-ninja\compile_commands.json'
  #   \   . ' && cd build'
  #   \   . ' && mkdir x64-windows-vs && cd x64-windows-vs'
  #   \   . ' && cmake ..\..'
  #   \   . ' -G "Visual Studio 16 2019" -A x64'
  #   \   . ' -D CMAKE_TOOLCHAIN_FILE=' . vcpkg_toolchain,
  #   \ 'build': 'cmake --build ' . git_repo_root . '/build/x64-windows-ninja',
  #   \ 'test': git_repo_root . '\build\x64-windows-ninja\' . project_name . '-tests.exe',
  #   \ 'run': git_repo_root . '\build\x64-windows-ninja\' . project_name . '-main.exe',
  #   \ 'ide': 'start build\x64-windows-vs\' . project_name . '.sln & exit',
  #   \ }
