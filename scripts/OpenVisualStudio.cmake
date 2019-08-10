execute_process(COMMAND cmake --open build/x64-windows-vs RESULT_VARIABLE result)
if(result)
  message(STATUS "${result}")
endif()
