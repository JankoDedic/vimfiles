# Current working directory should be the project root

string(FIND ${CMAKE_SOURCE_DIR} "/" lastSlashIndex REVERSE)
math(EXPR lastSlashIndex "${lastSlashIndex}+1")
string(SUBSTRING ${CMAKE_SOURCE_DIR} ${lastSlashIndex} -1 projectName)

set(exePath "build\\x64-windows-ninja-debug\\${projectName}-main.exe")

# TODO Is there a more robust way than the -main suffix convention?
execute_process(COMMAND cmd /C start cmd /C "${exePath} & pause" RESULT_VARIABLE result)
if(result)
  message(STATUS "${result}")
endif()
