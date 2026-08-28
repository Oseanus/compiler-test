# ============================================================
# DiscoverProjects.cmake (Qt-free)
# layouts:
#
#   src/lib/<name>      -> <name>.lib
#   src/libs/<name>     -> <name>.lib
#
#   src/app/<name>      -> <name>.app
#   src/apps/<name>     -> <name>.app
#
#   src/<name>          -> <name>.lib or <name>.app
#                          depending on DIRECT_SRC_PROJECT_TYPE
#
#   tests/<name>        -> <name>-lib.test
#
#   tests/*.cpp         -> ${ROOT_PROJECT_NAME}.lib.test
#
# Notes:
#   - src/ is required.
#   - tests/ is optional.
#   - Empty tests/ folders are ignored.
#   - Empty test subfolders are ignored.
#   - Each library can be STATIC or SHARED.
# ============================================================

# ============================================================
# Helper: collect direct subfolders
# ============================================================

function(dp_collect_direct_subfolders INPUT_DIR OUTPUT_LIST)
    set(RESULT_LIST "")

    if(IS_DIRECTORY "${INPUT_DIR}")
        file(
                GLOB CHILDREN
                LIST_DIRECTORIES true
                CONFIGURE_DEPENDS
                "${INPUT_DIR}/*"
        )

        foreach(CHILD ${CHILDREN})
            if(IS_DIRECTORY "${CHILD}")
                list(APPEND RESULT_LIST "${CHILD}")
            endif()
        endforeach()
    endif()

    set(${OUTPUT_LIST} "${RESULT_LIST}" PARENT_SCOPE)
endfunction()

# ============================================================
# Helper: collect source files recursively
# ============================================================

function(dp_collect_project_sources PROJECT_DIR OUTPUT_LIST)
    set(SOURCE_FILES "")

    if(IS_DIRECTORY "${PROJECT_DIR}")
        file(
                GLOB_RECURSE SOURCE_FILES
                CONFIGURE_DEPENDS

                "${PROJECT_DIR}/*.c"
                "${PROJECT_DIR}/*.cc"
                "${PROJECT_DIR}/*.cpp"
                "${PROJECT_DIR}/*.cxx"

                "${PROJECT_DIR}/*.h"
                "${PROJECT_DIR}/*.hh"
                "${PROJECT_DIR}/*.hpp"
                "${PROJECT_DIR}/*.hxx"
        )
    endif()

    set(${OUTPUT_LIST} "${SOURCE_FILES}" PARENT_SCOPE)
endfunction()

# ============================================================
# Helper: collect source files directly in one folder only
# ============================================================

function(dp_collect_direct_project_sources PROJECT_DIR OUTPUT_LIST)
    set(SOURCE_FILES "")

    if(IS_DIRECTORY "${PROJECT_DIR}")
        file(
                GLOB SOURCE_FILES
                CONFIGURE_DEPENDS

                "${PROJECT_DIR}/*.c"
                "${PROJECT_DIR}/*.cc"
                "${PROJECT_DIR}/*.cpp"
                "${PROJECT_DIR}/*.cxx"

                "${PROJECT_DIR}/*.h"
                "${PROJECT_DIR}/*.hh"
                "${PROJECT_DIR}/*.hpp"
                "${PROJECT_DIR}/*.hxx"
        )
    endif()

    set(${OUTPUT_LIST} "${SOURCE_FILES}" PARENT_SCOPE)
endfunction()

# ============================================================
# Helper: create target name from folder name and suffix
# ============================================================

function(dp_create_project_name PROJECT_DIR SUFFIX OUTPUT_NAME)
    get_filename_component(BASE_NAME "${PROJECT_DIR}" NAME)
    set(PROJECT_NAME_WITH_SUFFIX "${BASE_NAME}${SUFFIX}")
    set(${OUTPUT_NAME} "${PROJECT_NAME_WITH_SUFFIX}" PARENT_SCOPE)
endfunction()

# ============================================================
# Helper: add include directories
#
# Adds:
#   <project-folder>
#   <project-folder>/include
# ============================================================

function(dp_add_project_include_dirs TARGET_NAME PROJECT_DIR VISIBILITY)
    target_include_directories(
            "${TARGET_NAME}"
            ${VISIBILITY}
            "${PROJECT_DIR}"
    )

    if(IS_DIRECTORY "${PROJECT_DIR}/include")
        target_include_directories(
                "${TARGET_NAME}"
                ${VISIBILITY}
                "${PROJECT_DIR}/include"
        )
    endif()
endfunction()

# ============================================================
# Helper: validate config
# ============================================================

function(dp_validate_project_config)
    if(NOT DEFINED ROOT_PROJECT_NAME OR "${ROOT_PROJECT_NAME}" STREQUAL "")
        message(
                FATAL_ERROR
                "ROOT_PROJECT_NAME is not set. "
                "Set it before calling discover_projects(), for example: set(ROOT_PROJECT_NAME \"MyProject\")"
        )
    endif()

    if(NOT DEFINED ROOT_CPP_STANDARD OR "${ROOT_CPP_STANDARD}" STREQUAL "")
        message(
                FATAL_ERROR
                "ROOT_CPP_STANDARD is not set. "
                "Set it before calling discover_projects(), for example: set(ROOT_CPP_STANDARD 20)"
        )
    endif()

    if(NOT DEFINED DIRECT_SRC_PROJECT_TYPE OR "${DIRECT_SRC_PROJECT_TYPE}" STREQUAL "")
        set(DIRECT_SRC_PROJECT_TYPE "LIB" PARENT_SCOPE)
    elseif(NOT "${DIRECT_SRC_PROJECT_TYPE}" STREQUAL "LIB" AND
            NOT "${DIRECT_SRC_PROJECT_TYPE}" STREQUAL "APP")
        message(
                FATAL_ERROR
                "DIRECT_SRC_PROJECT_TYPE must be either LIB or APP."
        )
    endif()

    if(NOT DEFINED DEFAULT_LIBRARY_TYPE OR "${DEFAULT_LIBRARY_TYPE}" STREQUAL "")
        set(DEFAULT_LIBRARY_TYPE "STATIC" PARENT_SCOPE)
    elseif(NOT "${DEFAULT_LIBRARY_TYPE}" STREQUAL "STATIC" AND
            NOT "${DEFAULT_LIBRARY_TYPE}" STREQUAL "SHARED")
        message(
                FATAL_ERROR
                "DEFAULT_LIBRARY_TYPE must be either STATIC or SHARED."
        )
    endif()
endfunction()

# ============================================================
# Helper: create library project
# ============================================================

function(dp_create_library_project PROJECT_DIR PROJECT_CXX_FEATURE)
    dp_create_project_name("${PROJECT_DIR}" ".lib" LIB_PROJECT_NAME)
    dp_collect_project_sources("${PROJECT_DIR}" LIB_PROJECT_SOURCES)

    if(LIB_PROJECT_SOURCES)
        set(LIBRARY_TYPE "${DEFAULT_LIBRARY_TYPE}")
        set(LIBRARY_TYPE_VARIABLE "${LIB_PROJECT_NAME}_LIBRARY_TYPE")

        if(DEFINED ${LIBRARY_TYPE_VARIABLE})
            set(LIBRARY_TYPE "${${LIBRARY_TYPE_VARIABLE}}")
        endif()

        if(NOT "${LIBRARY_TYPE}" STREQUAL "STATIC" AND
                NOT "${LIBRARY_TYPE}" STREQUAL "SHARED")
            message(
                    FATAL_ERROR
                    "Invalid library type '${LIBRARY_TYPE}' for ${LIB_PROJECT_NAME}. "
                    "Allowed values are STATIC or SHARED."
            )
        endif()

        add_library(
                "${LIB_PROJECT_NAME}"
                ${LIBRARY_TYPE}
                ${LIB_PROJECT_SOURCES}
        )

        dp_add_project_include_dirs(
                "${LIB_PROJECT_NAME}"
                "${PROJECT_DIR}"
                PUBLIC
        )

        target_compile_features(
                "${LIB_PROJECT_NAME}"
                PUBLIC
                ${PROJECT_CXX_FEATURE}
        )

        message(STATUS "Library project: ${LIB_PROJECT_NAME}")
        message(STATUS "Library type: ${LIBRARY_TYPE}")
        message(STATUS "Library sources: ${LIB_PROJECT_SOURCES}")

        set(DP_CREATED_LIBRARY_PROJECT_NAME "${LIB_PROJECT_NAME}" PARENT_SCOPE)
        set(DP_CREATED_LIBRARY_PROJECT_SOURCES "${LIB_PROJECT_SOURCES}" PARENT_SCOPE)
    else()
        message(STATUS "Ignoring library folder without source files: ${PROJECT_DIR}")

        set(DP_CREATED_LIBRARY_PROJECT_NAME "" PARENT_SCOPE)
        set(DP_CREATED_LIBRARY_PROJECT_SOURCES "" PARENT_SCOPE)
    endif()
endfunction()

# ============================================================
# Helper: create application project
# ============================================================

function(dp_create_application_project PROJECT_DIR PROJECT_CXX_FEATURE)
    dp_create_project_name("${PROJECT_DIR}" ".app" APP_PROJECT_NAME)
    dp_collect_project_sources("${PROJECT_DIR}" APP_PROJECT_SOURCES)

    if(APP_PROJECT_SOURCES)
        add_executable(
                "${APP_PROJECT_NAME}"
                ${APP_PROJECT_SOURCES}
        )

        dp_add_project_include_dirs(
                "${APP_PROJECT_NAME}"
                "${PROJECT_DIR}"
                PRIVATE
        )

        target_compile_features(
                "${APP_PROJECT_NAME}"
                PUBLIC
                ${PROJECT_CXX_FEATURE}
        )

        message(STATUS "Application project: ${APP_PROJECT_NAME}")
        message(STATUS "Application sources: ${APP_PROJECT_SOURCES}")

        set(DP_CREATED_APPLICATION_PROJECT_NAME "${APP_PROJECT_NAME}" PARENT_SCOPE)
        set(DP_CREATED_APPLICATION_PROJECT_SOURCES "${APP_PROJECT_SOURCES}" PARENT_SCOPE)
    else()
        message(STATUS "Ignoring application folder without source files: ${PROJECT_DIR}")

        set(DP_CREATED_APPLICATION_PROJECT_NAME "" PARENT_SCOPE)
        set(DP_CREATED_APPLICATION_PROJECT_SOURCES "" PARENT_SCOPE)
    endif()
endfunction()

# ============================================================
# Main function
# ============================================================

function(discover_projects)

    dp_validate_project_config()

    set(PROJECT_CXX_FEATURE "cxx_std_${ROOT_CPP_STANDARD}")

    set(PROJECT_ROOT "${CMAKE_SOURCE_DIR}")
    set(SRC_DIR     "${PROJECT_ROOT}/src")
    set(TESTS_DIR   "${PROJECT_ROOT}/tests")

    set(APP_CONTAINER_NAMES "app" "apps")
    set(LIB_CONTAINER_NAMES "lib" "libs")

    set(APP_PROJECT_NAMES "")
    set(LIB_PROJECT_NAMES "")
    set(TEST_PROJECT_NAMES "")

    if(NOT IS_DIRECTORY "${SRC_DIR}")
        message(FATAL_ERROR "Required folder 'src' was not found in project root: ${PROJECT_ROOT}")
    endif()

    message(STATUS "Found src folder: ${SRC_DIR}")

    # ============================================================
    # Parse src/lib and src/libs
    # ============================================================

    foreach(LIB_CONTAINER_NAME ${LIB_CONTAINER_NAMES})
        set(LIB_CONTAINER_DIR "${SRC_DIR}/${LIB_CONTAINER_NAME}")

        if(IS_DIRECTORY "${LIB_CONTAINER_DIR}")
            message(STATUS "Found library container folder: ${LIB_CONTAINER_DIR}")

            dp_collect_direct_subfolders("${LIB_CONTAINER_DIR}" LIB_PROJECT_DIRS)

            foreach(LIB_PROJECT_DIR ${LIB_PROJECT_DIRS})
                dp_create_library_project("${LIB_PROJECT_DIR}" "${PROJECT_CXX_FEATURE}")

                if(DP_CREATED_LIBRARY_PROJECT_NAME)
                    list(APPEND LIB_PROJECT_NAMES "${DP_CREATED_LIBRARY_PROJECT_NAME}")
                    set(
                            "${DP_CREATED_LIBRARY_PROJECT_NAME}_SOURCES"
                            "${DP_CREATED_LIBRARY_PROJECT_SOURCES}"
                    )
                endif()
            endforeach()
        endif()
    endforeach()

    # ============================================================
    # Parse src/app and src/apps
    # ============================================================

    foreach(APP_CONTAINER_NAME ${APP_CONTAINER_NAMES})
        set(APP_CONTAINER_DIR "${SRC_DIR}/${APP_CONTAINER_NAME}")

        if(IS_DIRECTORY "${APP_CONTAINER_DIR}")
            message(STATUS "Found application container folder: ${APP_CONTAINER_DIR}")

            dp_collect_direct_subfolders("${APP_CONTAINER_DIR}" APP_PROJECT_DIRS)

            foreach(APP_PROJECT_DIR ${APP_PROJECT_DIRS})
                dp_create_application_project("${APP_PROJECT_DIR}" "${PROJECT_CXX_FEATURE}")

                if(DP_CREATED_APPLICATION_PROJECT_NAME)
                    list(APPEND APP_PROJECT_NAMES "${DP_CREATED_APPLICATION_PROJECT_NAME}")
                    set(
                            "${DP_CREATED_APPLICATION_PROJECT_NAME}_SOURCES"
                            "${DP_CREATED_APPLICATION_PROJECT_SOURCES}"
                    )
                endif()
            endforeach()
        endif()
    endforeach()

    # ============================================================
    # Parse direct src/<name> projects
    # ============================================================

    dp_collect_direct_subfolders("${SRC_DIR}" DIRECT_SRC_PROJECT_DIRS)

    foreach(DIRECT_SRC_PROJECT_DIR ${DIRECT_SRC_PROJECT_DIRS})
        get_filename_component(DIRECT_SRC_FOLDER_NAME "${DIRECT_SRC_PROJECT_DIR}" NAME)

        set(IS_RESERVED_FOLDER FALSE)

        foreach(APP_CONTAINER_NAME ${APP_CONTAINER_NAMES})
            if("${DIRECT_SRC_FOLDER_NAME}" STREQUAL "${APP_CONTAINER_NAME}")
                set(IS_RESERVED_FOLDER TRUE)
            endif()
        endforeach()

        foreach(LIB_CONTAINER_NAME ${LIB_CONTAINER_NAMES})
            if("${DIRECT_SRC_FOLDER_NAME}" STREQUAL "${LIB_CONTAINER_NAME}")
                set(IS_RESERVED_FOLDER TRUE)
            endif()
        endforeach()

        if(NOT IS_RESERVED_FOLDER)
            if("${DIRECT_SRC_PROJECT_TYPE}" STREQUAL "LIB")
                dp_create_library_project("${DIRECT_SRC_PROJECT_DIR}" "${PROJECT_CXX_FEATURE}")

                if(DP_CREATED_LIBRARY_PROJECT_NAME)
                    list(APPEND LIB_PROJECT_NAMES "${DP_CREATED_LIBRARY_PROJECT_NAME}")
                    set(
                            "${DP_CREATED_LIBRARY_PROJECT_NAME}_SOURCES"
                            "${DP_CREATED_LIBRARY_PROJECT_SOURCES}"
                    )
                endif()
            elseif("${DIRECT_SRC_PROJECT_TYPE}" STREQUAL "APP")
                dp_create_application_project("${DIRECT_SRC_PROJECT_DIR}" "${PROJECT_CXX_FEATURE}")

                if(DP_CREATED_APPLICATION_PROJECT_NAME)
                    list(APPEND APP_PROJECT_NAMES "${DP_CREATED_APPLICATION_PROJECT_NAME}")
                    set(
                            "${DP_CREATED_APPLICATION_PROJECT_NAME}_SOURCES"
                            "${DP_CREATED_APPLICATION_PROJECT_SOURCES}"
                    )
                endif()
            else()
                message(FATAL_ERROR "DIRECT_SRC_PROJECT_TYPE must be either LIB or APP.")
            endif()
        endif()
    endforeach()

    if(NOT APP_PROJECT_NAMES AND NOT LIB_PROJECT_NAMES)
        message(
                FATAL_ERROR
                "No usable projects found. Expected source files below "
                "src/app, src/apps, src/lib, src/libs, or direct src/<name> folders."
        )
    endif()

    # ============================================================
    # Parse tests
    # ============================================================

    if(IS_DIRECTORY "${TESTS_DIR}")
        dp_collect_direct_subfolders("${TESTS_DIR}" TEST_PROJECT_DIRS)
        dp_collect_direct_project_sources("${TESTS_DIR}" TEST_ROOT_SOURCES)

        set(HAS_USABLE_TESTS FALSE)

        if(TEST_ROOT_SOURCES)
            set(HAS_USABLE_TESTS TRUE)
        endif()

        foreach(TEST_PROJECT_DIR ${TEST_PROJECT_DIRS})
            dp_collect_project_sources("${TEST_PROJECT_DIR}" TEST_PROJECT_SOURCES)

            if(TEST_PROJECT_SOURCES)
                set(HAS_USABLE_TESTS TRUE)
            endif()
        endforeach()

        if(NOT HAS_USABLE_TESTS)
            message(STATUS "Optional tests folder exists but contains no usable source files. Ignoring tests.")
        else()
            enable_testing()
            message(STATUS "Found usable tests folder: ${TESTS_DIR}")

            # ----------------------------------------------------
            # Direct source files in tests/
            # ----------------------------------------------------

            if(TEST_ROOT_SOURCES)
                set(TEST_ROOT_PROJECT_NAME "${ROOT_PROJECT_NAME}.lib.test")

                list(APPEND TEST_PROJECT_NAMES "${TEST_ROOT_PROJECT_NAME}")

                set(
                        "${TEST_ROOT_PROJECT_NAME}_SOURCES"
                        "${TEST_ROOT_SOURCES}"
                )

                add_executable(
                        "${TEST_ROOT_PROJECT_NAME}"
                        ${TEST_ROOT_SOURCES}
                )

                dp_add_project_include_dirs(
                        "${TEST_ROOT_PROJECT_NAME}"
                        "${TESTS_DIR}"
                        PRIVATE
                )

                target_compile_features(
                        "${TEST_ROOT_PROJECT_NAME}"
                        PUBLIC
                        ${PROJECT_CXX_FEATURE}
                )

                add_test(
                        NAME "${TEST_ROOT_PROJECT_NAME}"
                        COMMAND "${TEST_ROOT_PROJECT_NAME}"
                )

                message(STATUS "Root unit-test project: ${TEST_ROOT_PROJECT_NAME}")
                message(STATUS "Root unit-test sources: ${TEST_ROOT_SOURCES}")
            endif()

            # ----------------------------------------------------
            # Subfolder-based test projects
            # ----------------------------------------------------

            foreach(TEST_PROJECT_DIR ${TEST_PROJECT_DIRS})
                dp_create_project_name("${TEST_PROJECT_DIR}" ".lib.test" TEST_PROJECT_NAME)
                dp_collect_project_sources("${TEST_PROJECT_DIR}" TEST_PROJECT_SOURCES)

                if(TEST_PROJECT_SOURCES)
                    list(APPEND TEST_PROJECT_NAMES "${TEST_PROJECT_NAME}")

                    set(
                            "${TEST_PROJECT_NAME}_SOURCES"
                            "${TEST_PROJECT_SOURCES}"
                    )

                    add_executable(
                            "${TEST_PROJECT_NAME}"
                            ${TEST_PROJECT_SOURCES}
                    )

                    dp_add_project_include_dirs(
                            "${TEST_PROJECT_NAME}"
                            "${TEST_PROJECT_DIR}"
                            PRIVATE
                    )

                    target_compile_features(
                            "${TEST_PROJECT_NAME}"
                            PUBLIC
                            ${PROJECT_CXX_FEATURE}
                    )

                    add_test(
                            NAME "${TEST_PROJECT_NAME}"
                            COMMAND "${TEST_PROJECT_NAME}"
                    )

                    message(STATUS "Unit-test project: ${TEST_PROJECT_NAME}")
                    message(STATUS "Unit-test sources: ${TEST_PROJECT_SOURCES}")
                else()
                    message(STATUS "Ignoring empty optional test folder: ${TEST_PROJECT_DIR}")
                endif()
            endforeach()
        endif()
    else()
        message(STATUS "Optional tests folder not found. Skipping unit-test target generation.")
    endif()

    # ============================================================
    # Export generated target lists
    # ============================================================

    set(APP_PROJECT_NAMES  "${APP_PROJECT_NAMES}"  PARENT_SCOPE)
    set(LIB_PROJECT_NAMES  "${LIB_PROJECT_NAMES}"  PARENT_SCOPE)
    set(TEST_PROJECT_NAMES "${TEST_PROJECT_NAMES}" PARENT_SCOPE)

    foreach(APP_PROJECT_NAME ${APP_PROJECT_NAMES})
        set(
                "${APP_PROJECT_NAME}_SOURCES"
                "${${APP_PROJECT_NAME}_SOURCES}"
                PARENT_SCOPE
        )
    endforeach()

    foreach(LIB_PROJECT_NAME ${LIB_PROJECT_NAMES})
        set(
                "${LIB_PROJECT_NAME}_SOURCES"
                "${${LIB_PROJECT_NAME}_SOURCES}"
                PARENT_SCOPE
        )
    endforeach()

    foreach(TEST_PROJECT_NAME ${TEST_PROJECT_NAMES})
        set(
                "${TEST_PROJECT_NAME}_SOURCES"
                "${${TEST_PROJECT_NAME}_SOURCES}"
                PARENT_SCOPE
        )
    endforeach()

    message(STATUS "----------------------------------------")
    message(STATUS "Discovered application projects:")
    message(STATUS "APP_PROJECT_NAMES  = ${APP_PROJECT_NAMES}")
    message(STATUS "")
    message(STATUS "Discovered library projects:")
    message(STATUS "LIB_PROJECT_NAMES  = ${LIB_PROJECT_NAMES}")
    message(STATUS "")
    message(STATUS "Discovered unit-test projects:")
    message(STATUS "TEST_PROJECT_NAMES = ${TEST_PROJECT_NAMES}")
    message(STATUS "----------------------------------------")

endfunction()

# Provides:
#   discover_projects()