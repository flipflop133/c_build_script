# Generic C build tools

---

## Overview

This repository contains a generic **build script** and **Makefile** designed to streamline the building and testing process for C programs. The script and Makefile support common build configurations (`debug`, `release`) and advanced testing workflows, including **Valgrind** memory analysis and **Clang sanitizers**. It is intended to be reusable across projects and simplifies complex build pipelines.

---

## Features

- **Build Configurations**:
  - `debug`: Adds debugging symbols and additional warnings.
  - `release`: Optimized for performance.

- **Valgrind Testing**:
  - **Massif**: Analyze heap memory usage.
  - **Memcheck**: Detect memory leaks and invalid memory accesses.

- **Clang Sanitizers**:
  - AddressSanitizer (`sanitizer-address`): Detects memory corruption and invalid memory accesses.
  - MemorySanitizer (`sanitizer-memory`): Finds uninitialized memory reads.
  - ThreadSanitizer (`sanitizer-thread`): Identifies data races in multithreaded code.

- **Clean Command**:
  - Deletes the build directory for a fresh rebuild.

---

## Usage

### Prerequisites

Ensure the following tools are installed on your system:

- **Clang** (for compilation and sanitizers)
- **CMake** (for build system generation)
- **Valgrind** (for memory analysis)
- **Make** (build automation)

### Commands

Run the script with the appropriate argument:

```bash
./build_script.sh [command]
```

### Available Commands

| Command              | Description                                                                 |
|----------------------|-----------------------------------------------------------------------------|
| `debug`              | Builds the program with debugging symbols and warnings.                    |
| `release`            | Builds the program with optimizations (`-O3`, `-flto`, `-march=native`).   |
| `massif`             | Runs Valgrind's Massif tool to analyze heap memory usage.                  |
| `memcheck`           | Runs Valgrind's Memcheck tool to detect memory leaks and invalid accesses. |
| `sanitizer-address`  | Builds and runs the program with Clang AddressSanitizer.                   |
| `sanitizer-memory`   | Builds and runs the program with Clang MemorySanitizer.                    |
| `sanitizer-thread`   | Builds and runs the program with Clang ThreadSanitizer.                    |
| `clean`              | Deletes the build directory for a clean rebuild.                          |

---

## Examples

### Build in Release Mode

```bash
./build_script.sh release
```

### Build and Debug with AddressSanitizer

```bash
./build_script.sh sanitizer-address
```

### Analyze Heap Memory with Massif

```bash
./build_script.sh massif
```

### Clean the Build Directory

```bash
./build_script.sh clean
```

---

## Contributions

Contributions and suggestions are welcome! If you have ideas for improvement, please open an issue or submit a pull request.

---
