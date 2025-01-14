# Set common project settings
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_LINKER /usr/bin/ld.lld)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON)

set(CMAKE_C_STANDARD 23)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

# Add common include directories
include_directories(
    /usr/include
    /usr/include/freetype2/
)

# Add common build type options
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_compile_options(-pg -Wall -Wextra -DDEBUG)
    add_link_options(-pg)
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    add_compile_options(-O3 -flto -march=native -mtune=native)
endif()

# Define custom targets for tests
function(add_test_target name sanitizer_flags command)
    add_custom_target(${name}
        COMMAND ${CMAKE_COMMAND} -E env ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=print_stacktrace=1
        ${CMAKE_C_COMPILER} ${sanitizer_flags}
        COMMAND ${command}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )
endfunction()

# Target for Valgrind massif
add_custom_target(run_massif
    COMMAND valgrind --tool=massif --stacks=yes ./build/minimalist-lockscreen
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

# Target for Valgrind memcheck
add_custom_target(run_memcheck
    COMMAND valgrind --tool=memcheck --leak-check=full --show-leak-kinds=all ./build/minimalist-lockscreen
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

# Targets for Clang sanitizers
add_custom_target(run_address_sanitizer
    COMMAND cmake -DCMAKE_C_FLAGS="-fsanitize=address,undefined,leak,integer" -B build && cmake --build build
    COMMAND ./build/minimalist-lockscreen
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

add_custom_target(run_memory_sanitizer
    COMMAND cmake -DCMAKE_C_FLAGS="-fsanitize=memory,undefined,leak,integer" -B build && cmake --build build
    COMMAND ./build/minimalist-lockscreen
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

add_custom_target(run_thread_sanitizer
    COMMAND cmake -DCMAKE_C_FLAGS="-fsanitize=thread,undefined,leak,integer" -B build && cmake --build build
    COMMAND ./build/minimalist-lockscreen
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

# Add common status messages
message(STATUS "CMake version: ${CMAKE_VERSION}")
message(STATUS "CMake system name: ${CMAKE_SYSTEM_NAME}")
message(STATUS "CMake system version: ${CMAKE_SYSTEM_VERSION}")
message(STATUS "CMake C compiler: ${CMAKE_C_COMPILER}")
message(STATUS "CMake CXX compiler: ${CMAKE_CXX_COMPILER}")
message(STATUS "Linker: ${CMAKE_LINKER}")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
