# tests/CMakeLists.txt

# Create a test executable
qt_add_executable(tst_viewmodels
    main.cpp
    ../src/viewmodels/VehicleStatusViewModel.cpp
)

target_include_directories(tst_viewmodels PRIVATE ../src)

# Link against Qt Test and our application's libraries if needed
# We also link against Core to ensure it has basic functionality
target_link_libraries(tst_viewmodels
    PRIVATE
    Qt6::Core
    Qt6::Qml
    Qt6::Test
)

# Add it to CTest
add_test(NAME tst_viewmodels COMMAND tst_viewmodels)
