enable_language(C)

if(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "arm64")
  set(host_def HOST_ARM64)
elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "x86_64")
  set(host_def HOST_X86_64)
else()
  message(FATAL_ERROR "CMAKE_HOST_SYSTEM_PROCESSOR is '${CMAKE_HOST_SYSTEM_PROCESSOR}', not 'arm64' or 'x86_64'")
endif()
if(NOT CMAKE_OSX_ARCHITECTURES STREQUAL "")
  message(FATAL_ERROR "CMAKE_OSX_ARCHITECTURES is '${CMAKE_OSX_ARCHITECTURES}', not empty ''")
endif()

add_library(default default.c)
target_compile_definitions(default PRIVATE ${host_def})
