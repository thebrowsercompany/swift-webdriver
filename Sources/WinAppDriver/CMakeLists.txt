add_library(WinAppDriver
  CommandLine.swift
  ElementLocator+accessibilityId.swift
  ErrorResponse+WinAppDriver.swift
  ReexportWebDriver.swift
  Win32Error.swift
  Win32ProcessTree.swift
  WinAppDriver+Attributes.swift
  WinAppDriver+Capabilities.swift
  WinAppDriver.swift
  WindowsSystemPaths.swift)
target_link_libraries(WinAppDriver PRIVATE
  WebDriver)
