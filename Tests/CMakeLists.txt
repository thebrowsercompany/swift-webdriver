add_library(TestsCommon
  Common/PNGUtilities.swift)

SwiftTesting_GenerateDerivedSources()
add_executable(SwiftWebdriverPackageTests
  UnitTests/APITests.swift
  UnitTests/MockWebDriver.swift
  ${swiftwebdriver_SwiftTesting_Sources})
set_target_properties(SwiftWebdriverPackageTests PROPERTIES
  SUFFIX .swift-testing)
target_link_libraries(SwiftWebdriverPackageTests PRIVATE
  WebDriver
  Testing
  TestsCommon)

add_test(NAME SwiftWebdriverPackageTests
  COMMAND SwiftWebdriverPackageTests)
