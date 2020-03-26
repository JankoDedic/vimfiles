# Current working directory should be the project root

# TODO Is there a more robust way than the -main suffix convention?
execute_process(COMMAND cmd /C start cmd /C "cmake --build build & pause" RESULT_VARIABLE result)
if(result)
  message(STATUS "${result}")
endif()
