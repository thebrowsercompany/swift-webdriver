cmake_minimum_required(VERSION 3.25)

project(SwiftWebDriver
  LANGUAGES Swift)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_Swift_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/swift)

option(SWIFT_WEBDRIVER_BUILD_WINAPPDRIVER "Build WinAppDriver functionality." TRUE)

add_subdirectory(Sources/WebDriver)

if(SWIFT_WEBDRIVER_BUILD_WINAPPDRIVER)
  add_subdirectory(Sources/WinAppDriver)
endif()
