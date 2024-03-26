cmake_minimum_required(VERSION 3.25)

project(SwiftWebDriver
  LANGUAGES Swift)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_Swift_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/swift)

option(SWIFT_WEBDRIVER_BUILD_WINAPPDRIVER "Build WinAppDriver functionality." TRUE)

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

if(SWIFT_WEBDRIVER_BUILD_WINAPPDRIVER)
  add_subdirectory(Sources/WinAppDriver)
endif()
