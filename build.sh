#!/bin/bash

BUILD_DIR="build"
BUILD_TYPE="release" # Default build type
SANITIZER="" # Default: no sanitizer

export CC=clang
export CXX=clang++

# Function to run tests
run_test() {
    local test_command=$1
    echo "Running test: $test_command"
    eval "$test_command" || {
        echo "Test failed: $test_command"
        exit 1
    }
}

# Check if arguments are provided
if [ "$#" -gt 0 ]; then
    BUILD_TYPE=$(echo "$1" | tr '[:upper:]' '[:lower:]') # Normalize to lowercase
fi

if [ "$BUILD_TYPE" = "clean" ]; then
    echo "Cleaning build directory..."
    rm -rf "$BUILD_DIR"
    exit 0
fi

if [ "$BUILD_TYPE" = "massif" ]; then
    echo "Running Valgrind Massif test..."
    run_test "valgrind --tool=massif --stacks=yes ./$BUILD_DIR/minimalist-lockscreen"
    exit 0
elif [ "$BUILD_TYPE" = "memcheck" ]; then
    echo "Running Valgrind Memcheck test..."
    run_test "valgrind --tool=memcheck --leak-check=full --show-leak-kinds=all ./$BUILD_DIR/minimalist-lockscreen"
    exit 0
elif [[ "$BUILD_TYPE" =~ ^sanitizer-(address|memory|thread)$ ]]; then
    SANITIZER=${BASH_REMATCH[1]}
    echo "Running build with Clang sanitizer: $SANITIZER"
    BUILD_TYPE="Debug"
    export SANITIZER_FLAGS="-fsanitize=$SANITIZER,undefined,leak,integer"
elif [ "$BUILD_TYPE" = "debug" ]; then
    BUILD_TYPE="Debug"
elif [ "$BUILD_TYPE" = "release" ]; then
    BUILD_TYPE="Release"
else
    echo "Invalid build type: $BUILD_TYPE"
    echo "Usage: $0 [debug|release|clean|massif|memcheck|sanitizer-address|sanitizer-memory|sanitizer-thread]"
    exit 1
fi

# Check if the build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo "Creating $BUILD_DIR directory..."
    mkdir "$BUILD_DIR" || exit 1
fi

cd "$BUILD_DIR" || exit 1

echo "Build type: $BUILD_TYPE"

# Run CMake with the specified build type and sanitizers
if [ -n "$SANITIZER" ]; then
    cmake -DCMAKE_BUILD_TYPE="$BUILD_TYPE" -DCMAKE_C_FLAGS="$SANITIZER_FLAGS" -DCMAKE_CXX_FLAGS="$SANITIZER_FLAGS" .. || {
        echo "CMake configuration failed."
        exit 1
    }
else
    cmake -DCMAKE_BUILD_TYPE="$BUILD_TYPE" .. || {
        echo "CMake configuration failed."
        exit 1
    }
fi

# Build the project
make || {
    echo "Build failed."
    exit 1
}

echo "Build successful. Output in $BUILD_DIR."

# Run the executable if a sanitizer is used
if [ -n "$SANITIZER" ]; then
    echo "Running executable with sanitizer: $SANITIZER"
    ./minimalist-lockscreen || {
        echo "Execution failed with sanitizer: $SANITIZER"
        exit 1
    }
fi
