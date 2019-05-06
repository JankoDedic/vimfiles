execute_process(COMMAND cmd /C [[build\x64-windows-vs\CppProject.sln]] RESULT_VARIABLE result)
if(result)
  message(STATUS "${result}")
endif()
