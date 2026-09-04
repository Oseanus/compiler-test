cmake_minimum_required(VERSION 3.20)

# ============================================================
# User configuration
# ============================================================

set(ROOT_PROJECT_NAME "CompilerTest")
set(ROOT_CPP_STANDARD 20)

# Direct folders under src/ can be treated as LIB or APP.
#
# Example:
#   src/compiler
#
# If DIRECT_SRC_PROJECT_TYPE is LIB:
#   src/compiler -> compiler.lib
#
# If DIRECT_SRC_PROJECT_TYPE is APP:
#   src/compiler -> compiler.app
set(DIRECT_SRC_PROJECT_TYPE "LIB")

# Default library type for all generated library targets.
#
# Valid values:
#   STATIC
#   SHARED
set(DEFAULT_LIBRARY_TYPE "STATIC")

# Optional per-library overrides.
#
# Variable naming:
#   <target-name>_LIBRARY_TYPE
#
# Examples:
#   src/lib/compiler -> compiler.lib
#   override var   -> compiler.lib_LIBRARY_TYPE
#
# set(compiler.lib_LIBRARY_TYPE "SHARED")
# set(math.lib_LIBRARY_TYPE "STATIC")
# set(network.lib_LIBRARY_TYPE "SHARED")

project(${ROOT_PROJECT_NAME} LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD ${ROOT_CPP_STANDARD})
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# ============================================================
# Project configuration modules
# ============================================================

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/project_config")
include(DiscoverProjects)

# ============================================================
# Create projects and targets
#
# Must be called before target_link_libraries(),
# because generated targets are created inside discover_projects().
# ============================================================

discover_projects()

# ============================================================
# Optional packages
#
# Add optional find_package calls here.
# Use QUIET so missing packages do not fail configuration.
# ============================================================

# find_package(Boost QUIET)
# find_package(fmt QUIET)
# find_package(spdlog QUIET)
find_package(GTest REQUIRED)

# ============================================================
# Optional target links
#
# Add target_link_libraries() here, after discover_projects().
#
# These are guarded with if(TARGET ...), so they are optional.
# If the target does not exist, the link is skipped.
# ============================================================

# ------------------------------------------------------------
# Example layout:
#
#   src/lib/compiler
#       -> compiler.lib
#
#   src/apps/compiler
#       -> compiler.app
#
#   tests/compiler
#       -> compiler.lib.test
# ------------------------------------------------------------

target_link_libraries(
        compiler.lib
        PUBLIC
        lexer.lib
)

if(TARGET compiler.app AND TARGET compiler.lib)
    target_link_libraries(
            compiler.app
            PUBLIC
            compiler.lib
    )
endif()

 if(TARGET compiler.lib.test AND TARGET compiler.lib)
     target_link_libraries(
         compiler.lib.test
         PUBLIC
         compiler.lib
         GTest::gtest_main
     )
 endif()

if(TARGET lexer.lib.test AND TARGET lexer.lib)
    target_link_libraries(
            lexer.lib.test
            PUBLIC
            lexer.lib
            GTest::gtest_main
    )
endif()

# ------------------------------------------------------------
# Example for direct tests/*.cpp target:
#
# If tests/ contains source files directly, the generated test
# target is:
#
#   ${ROOT_PROJECT_NAME}.lib.test
# ------------------------------------------------------------

# if(TARGET ${ROOT_PROJECT_NAME}.lib.test AND TARGET compiler.lib)
#     target_link_libraries(
#         ${ROOT_PROJECT_NAME}.lib.test
#         PUBLIC
#             compiler.lib
#     )
# endif()

# ============================================================
# Optional: print exported source mappings
# ============================================================

foreach(APP_PROJECT_NAME ${APP_PROJECT_NAMES})
    message(STATUS "${APP_PROJECT_NAME}_SOURCES = ${${APP_PROJECT_NAME}_SOURCES}")
endforeach()

foreach(LIB_PROJECT_NAME ${LIB_PROJECT_NAMES})
    message(STATUS "${LIB_PROJECT_NAME}_SOURCES = ${${LIB_PROJECT_NAME}_SOURCES}")
endforeach()

foreach(TEST_PROJECT_NAME ${TEST_PROJECT_NAMES})
    message(STATUS "${TEST_PROJECT_NAME}_SOURCES = ${${TEST_PROJECT_NAME}_SOURCES}")
endforeach()