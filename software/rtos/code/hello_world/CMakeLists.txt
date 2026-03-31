# SPDX-License-Identifier: Apache-2.0

cmake_minimum_required(VERSION 3.20.0)

# BOARD_ROOT: use env if set (e.g. from software/rtos/conf), else default to repo root (../.. from code/hello_world)
if(DEFINED ENV{BOARD_ROOT})
  list(APPEND BOARD_ROOT $ENV{BOARD_ROOT})
else()
  get_filename_component(RTOS_BOARD_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../.." ABSOLUTE)
  list(APPEND BOARD_ROOT ${RTOS_BOARD_ROOT})
endif()

# This must come BEFORE find_package(Zephyr)
set(SUBSTITUTE_ARCH_FLAGS "-march=rv32im -mabi=ilp32")
set(ARCH_FLAGS "-march=rv32im -mabi=ilp32")

# Force the toolchain to see the M extension
set(CMAKE_C_FLAGS "-march=rv32im -mabi=ilp32" CACHE INTERNAL "")
set(CMAKE_ASM_FLAGS "-march=rv32im -mabi=ilp32" CACHE INTERNAL "")

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(hello_world)

target_sources(app PRIVATE src/main.c)
