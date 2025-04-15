# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file LICENSE.rst or https://cmake.org/licensing for details.

# See supported GPUs on Wikipedia
# https://en.wikipedia.org/wiki/CUDA#GPUs_supported

function(cmake_cuda_architectures_all lang lang_var_)
  # Initial set based on CUDA 7.0.
  set(CMAKE_CUDA_ARCHITECTURES_ALL 20 21 30 35 37 50 52 53)
  set(CMAKE_CUDA_ARCHITECTURES_ALL_MAJOR 20 30 35 50)

  if(${lang_var_}TOOLKIT_VERSION VERSION_GREATER_EQUAL 8.0)
    list(APPEND CMAKE_CUDA_ARCHITECTURES_ALL 60 61 62)
    list(APPEND CMAKE_CUDA_ARCHITECTURES_ALL_MAJOR 60)
  endif()

  if(${lang_var_}TOOLKIT_VERSION VERSION_GREATER_EQUAL 9.0)
    if(CMAKE_${lang}_COMPILER_ID STREQUAL "NVIDIA"
        OR (CMAKE_${lang}_COMPILER_ID STREQUAL "Clang" AND CMAKE_${lang}_COMPILER_VERSION VERSION_GREATER_EQUAL 6.0)
        )
      list(APPEND CMAKE_CUDA_ARCHITECTURES_ALL 70 72)
      list(APPEND CMAKE_CUDA_ARCHITECTURES_ALL_MAJOR 70)
    endif()

    list(REMOVE_ITEM CMAKE_CUDA_ARCHITECTURES_ALL 20 21)
    list(REMOVE_ITEM CMAKE_CUDA_ARCHITECTURES_ALL_MAJOR 20)
  endif()

  if(${lang_var_}TOOLKIT_VERSION VERSION_GREATER_EQUAL 10.0)
    if(CMAKE_${lang}_COMPILER_ID STREQUAL "NVIDIA"
        OR (CMAKE_${lang}_COMPILER_ID STREQUAL "Clang" AND CMAKE_${lang}_COMPILER_VERSION VERSION_GREATER_EQUAL 8.0)
        )
      list(APPEND CMAKE_CUDA_ARCHITECTURES_ALL 75)
    endif()
  endif()

  if(${lang_var_}TOOLKIT_VERSION VERSION_GREATER_EQUAL 11.0)
    if(CMAKE_${lang}_COMPILER_ID STREQUAL "NVIDIA"
        OR (CMAKE_${lang}_COMPILER_ID STREQUAL "Clang" AND CMAKE_${lang}_COMPILER_VERSION VERSION_GREATER_EQUAL 11.0)
        )
      list(APPEND CMAKE_CUDA_ARCHITECTURES_ALL 80)
      list(APPEND CMAKE_CUDA_ARCHITECTURES_ALL_MAJOR 80)
    endif()

    list(REMOVE_ITEM CMAKE_CUDA_ARCHITECTURES_ALL 30)
    list(REMOVE_ITEM CMAKE_CUDA_ARCHITECTURES_ALL_MAJOR 30)
  endif()

  if(${lang_var_}TOOLKIT_VERSION VERSION_GREATER_EQUAL 11.1)
    if(CMAKE_${lang}_COMPILER_ID STREQUAL "NVIDIA"
        OR (CMAKE_${lang}_COMPILER_ID STREQUAL "Clang" AND CMAKE_${lang}_COMPILER_VERSION VERSION_GREATER_EQUAL 13.0)
        )
      list(APPEND CMAKE_CUDA_ARCHITECTURES_ALL 86)
    endif()
  endif()

  if(${lang_var_}TOOLKIT_VERSION VERSION_GREATER_EQUAL 11.4)
    if(CMAKE_${lang}_COMPILER_ID STREQUAL "NVIDIA"
        OR (CMAKE_${lang}_COMPILER_ID STREQUAL "Clang" AND CMAKE_${lang}_COMPILER_VERSION VERSION_GREATER_EQUAL 16.0)
        )
      list(APPEND CMAKE_CUDA_ARCHITECTURES_ALL 87)
    endif()
  endif()

  if(${lang_var_}TOOLKIT_VERSION VERSION_GREATER_EQUAL 11.8)
    if(CMAKE_${lang}_COMPILER_ID STREQUAL "NVIDIA"
        OR (CMAKE_${lang}_COMPILER_ID STREQUAL "Clang" AND CMAKE_${lang}_COMPILER_VERSION VERSION_GREATER_EQUAL 16.0)
        )
      list(APPEND CMAKE_CUDA_ARCHITECTURES_ALL 89 90)
      list(APPEND CMAKE_CUDA_ARCHITECTURES_ALL_MAJOR 90)
    endif()
  endif()

  if(${lang_var_}TOOLKIT_VERSION VERSION_GREATER_EQUAL 12.8)
    if(CMAKE_${lang}_COMPILER_ID STREQUAL "NVIDIA"
        OR (CMAKE_${lang}_COMPILER_ID STREQUAL "Clang" AND CMAKE_${lang}_COMPILER_VERSION VERSION_GREATER_EQUAL 16.0)
        )
      list(APPEND CMAKE_CUDA_ARCHITECTURES_ALL 100 101 120)
      list(APPEND CMAKE_CUDA_ARCHITECTURES_ALL_MAJOR 100 120)
    endif()
  endif()

  if(${lang_var_}TOOLKIT_VERSION VERSION_GREATER_EQUAL 12.0)
    list(REMOVE_ITEM CMAKE_CUDA_ARCHITECTURES_ALL 35 37)
    list(REMOVE_ITEM CMAKE_CUDA_ARCHITECTURES_ALL_MAJOR 35)
  endif()

  # only generate jit code for the newest arch for all/all-major
  list(POP_BACK CMAKE_CUDA_ARCHITECTURES_ALL _latest_arch)
  list(TRANSFORM CMAKE_CUDA_ARCHITECTURES_ALL APPEND "-real")
  list(APPEND CMAKE_CUDA_ARCHITECTURES_ALL ${_latest_arch})

  list(POP_BACK CMAKE_CUDA_ARCHITECTURES_ALL_MAJOR _latest_arch)
  list(TRANSFORM CMAKE_CUDA_ARCHITECTURES_ALL_MAJOR APPEND "-real")
  list(APPEND CMAKE_CUDA_ARCHITECTURES_ALL_MAJOR ${_latest_arch})

  set(CMAKE_${lang}_ARCHITECTURES_ALL "${CMAKE_CUDA_ARCHITECTURES_ALL}" PARENT_SCOPE)
  set(CMAKE_${lang}_ARCHITECTURES_ALL_MAJOR "${CMAKE_CUDA_ARCHITECTURES_ALL_MAJOR}" PARENT_SCOPE)
endfunction()
