vala_precompile(VALA_C
    config.vala
    Coins.vala
	MainWindow.vala
	Api/CoinMarketCap.vala
PACKAGES
    ${FORECAST_PACKAGES}
OPTIONS
    ${VALAC_OPTIONS}
)

#Here we define our executable name.
add_executable(coins
    ${VALA_C} )

add_definitions (${DEPS_CFLAGS})

#We need to link the libraries with our Executable.
target_link_libraries(coins ${DEPS_LIBRARIES} -lX11 gthread-2.0)

install (TARGETS ${CMAKE_PROJECT_NAME} RUNTIME DESTINATION bin)
