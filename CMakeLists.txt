cmake_minimum_required(VERSION 3.25)

project(SwiftWebDriver
  LANGUAGES Swift)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_Swift_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/swift)

add_library(WebDriver
  Sources/WebDriver/Capabilities.swift
  Sources/WebDriver/Element.swift
  Sources/WebDriver/ErrorResponse.swift
  Sources/WebDriver/HTTPWebDriver.swift
  Sources/WebDriver/Keys.swift
  Sources/WebDriver/Location.swift
  Sources/WebDriver/MouseButton.swift
  Sources/WebDriver/Poll.swift
  Sources/WebDriver/Request.swift
  Sources/WebDriver/Requests.swift
  Sources/WebDriver/ScreenOrientation.swift
  Sources/WebDriver/Session.swift
  Sources/WebDriver/TimeoutType.swift
  Sources/WebDriver/TouchClickKind.swift
  Sources/WebDriver/URLRequestExtensions.swift
  Sources/WebDriver/WebDriver.swift
  Sources/WebDriver/WebDriverStatus.swift
  Sources/WebDriver/Window.swift)

if(WIN32)
  add_library(WinAppDriver
    Sources/WinAppDriver/CommandLine.swift
    Sources/WinAppDriver/ErrorResponse+WinAppDriver.swift
    Sources/WinAppDriver/ReexportWebDriver.swift
    Sources/WinAppDriver/Win32Error.swift
    Sources/WinAppDriver/Win32ProcessTree.swift
    Sources/WinAppDriver/WinAppDriver+Attributes.swift
    Sources/WinAppDriver/WinAppDriver+Capabilities.swift
    Sources/WinAppDriver/WinAppDriver.swift
    Sources/WinAppDriver/WindowsSystemPaths.swift)
  target_link_libraries(WinAppDriver PRIVATE
    WebDriver)
endif()
