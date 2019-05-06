# Current working directory should be the project root

string(FIND ${CMAKE_SOURCE_DIR} "/" lastSlashIndex REVERSE)
string(SUBSTRING ${CMAKE_SOURCE_DIR} lastSlashIndex -1 projectName)

# TODO Is there a more robust way than the -main suffix convention?
execute_process(COMMAND [[build\x64-windows-ninja-debug\CppProject-main.exe]] RESULT_VARIABLE result)
if(result)
  message(STATUS "${result}")
endif()
