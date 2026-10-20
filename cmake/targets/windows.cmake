# windows specific target definitions
# Target name stays `sunshine`, but the produced binary must be NVStream.exe to match
# the shortcuts, service wrapper (tools/nvstreamsvc.cpp) and setup scripts.
set_target_properties(sunshine PROPERTIES
        LINK_SEARCH_START_STATIC 1
        OUTPUT_NAME "${CMAKE_PROJECT_NAME}")
set(CMAKE_FIND_LIBRARY_SUFFIXES ".dll")
find_library(ZLIB ZLIB1)
list(APPEND SUNSHINE_EXTERNAL_LIBRARIES
        $<TARGET_OBJECTS:sunshine_rc_object>
        Windowsapp.lib
        Wtsapi32.lib
        version.lib)
