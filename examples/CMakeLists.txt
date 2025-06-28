# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

cmake_minimum_required(VERSION 3.14)

# See https://cmake.org/cmake/help/latest/policy/CMP0074.html required by
# certain version of zlib which CURL depends on.
if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.12")
  cmake_policy(SET CMP0074 NEW)
endif()

# Allow to use normal variable for option()
if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.13")
  cmake_policy(SET CMP0077 NEW)
endif()

# Prefer CMAKE_MSVC_RUNTIME_LIBRARY if possible
if(POLICY CMP0091)
  cmake_policy(SET CMP0091 NEW)
endif()

if(POLICY CMP0092)
  # https://cmake.org/cmake/help/latest/policy/CMP0092.html#policy:CMP0092 Make
  # sure the /W3 is not removed from CMAKE_CXX_FLAGS since CMake 3.15
  cmake_policy(SET CMP0092 OLD)
endif()

# MSVC RTTI flag /GR should not be not added to CMAKE_CXX_FLAGS by default. @see
# https://cmake.org/cmake/help/latest/policy/CMP0117.html
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.20.0")
  cmake_policy(SET CMP0117 NEW)
endif()

project(OpenTel-CPP-examples)

# Mark variables as used so cmake doesn't complain about them
mark_as_advanced(CMAKE_TOOLCHAIN_FILE)

# Note: CMAKE_FIND_PACKAGE_PREFER_CONFIG requires cmake 3.15. Prefer cmake
# CONFIG search mode to find dependencies. This is important to properly find
# protobuf versions 3.22.0 and above due to the abseil-cpp dependency.
set(CMAKE_FIND_PACKAGE_PREFER_CONFIG TRUE)

option(WITH_OTLP_GRPC "Whether to include the OTLP gRPC exporter in the SDK"
       ON)

option(WITH_OTLP_HTTP "Whether to include the OTLP http exporter in the SDK"
       ON)

find_package(opentelemetry-cpp CONFIG REQUIRED)
find_package(CURL REQUIRED)

add_subdirectory(common)

add_subdirectory(otlp)
add_subdirectory(grpc)
if(WITH_ETW)
  add_subdirectory(etw_threads)
endif()
# add_subdirectory(zipkin)
# add_subdirectory(prometheus)
add_subdirectory(logs_simple)
add_subdirectory(plugin)
add_subdirectory(simple)
add_subdirectory(batch)
add_subdirectory(metrics_simple)
add_subdirectory(multithreaded)
add_subdirectory(multi_processor)

add_subdirectory(http)
