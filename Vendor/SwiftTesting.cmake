FetchContent_Declare(SwiftTesting
  # GIT_REPOSITORY https://github.com/apple/swift-testing.git
  # GIT_TAG e07ef28413b5be951fa5672b290bc10fa2e3cd65)
  GIT_REPOSITORY https://github.com/thebrowsercompany/swift-testing.git
  GIT_TAG cef620855b4ed1c8e43a43372ee9d517b2cd71bd)
FetchContent_GetProperties(SwiftTesting)
if(NOT SwiftTesting_POPULATED)
  message(STATUS "syncing SwiftTesting")
  FetchContent_MakeAvailable(SwiftTesting)
endif()
