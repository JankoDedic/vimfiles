# Current working directory should be the project root

string(FIND ${CMAKE_SOURCE_DIR} "/" lastSlashIndex REVERSE)
string(SUBSTRING ${CMAKE_SOURCE_DIR} lastSlashIndex -1 projectName)

# TODO We should switch to ctest
execute_process(COMMAND [[build\x64-windows-ninja-debug\CppProject-tests.exe]] RESULT_VARIABLE result)
if(result)
  message(STATUS "${result}")
endif()
