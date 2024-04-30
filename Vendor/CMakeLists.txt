include(FetchContent)

# Ignore warnings from dependencies' source code.
add_compile_options($<$<COMPILE_LANGUAGE:Swift>:-suppress-warnings>)
add_compile_options($<$<COMPILE_LANGUAGE:Swift>:-suppress-remarks>)

if(BUILD_TESTING)
  include(SwiftTesting.cmake)
endif()
