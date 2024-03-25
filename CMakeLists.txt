cmake_minimum_required(VERSION 3.21)
project(slint_hello LANGUAGES CXX)

find_package(Slint QUIET)
if (NOT Slint_FOUND)
  message("Slint could not be located in the CMake module search path. Downloading it from Git and building it locally")
  include(FetchContent)
  FetchContent_Declare(
    Slint
    GIT_REPOSITORY https://github.com/slint-ui/slint.git
    # `release/1` will auto-upgrade to the latest Slint >= 1.0.0 and < 2.0.0
    # `release/1.0` will auto-upgrade to the latest Slint >= 1.0.0 and < 1.1.0
    GIT_TAG release/1
    SOURCE_SUBDIR api/cpp
  )
  FetchContent_MakeAvailable(Slint)
endif (NOT Slint_FOUND)

add_executable(slint_hello src/main.cpp)
target_link_libraries(slint_hello PRIVATE Slint::Slint)
slint_target_sources(slint_hello ui/appwindow.slint)
# On Windows, copy the Slint DLL next to the application binary so that it's found.
# if (WIN32)
#     add_custom_command(TARGET slint_hello POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_RUNTIME_DLLS:slint_hello> $<TARGET_FILE_DIR:slint_hello> COMMAND_EXPAND_LISTS)
# endif()
