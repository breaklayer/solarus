cmake_minimum_required(VERSION 2.6)
project(SOLARUS_ENGINE)

if(COMMAND cmake_policy)
  cmake_policy(SET CMP0003 NEW)
endif()

set(CMAKE_MODULE_PATH "${SOLARUS_ENGINE_SOURCE_DIR}/cmake/modules/")

# find the headers and the libraries of dependencies
find_package(SDL REQUIRED)
find_package(SDL_image REQUIRED)
find_package(SDL_ttf REQUIRED)
find_package(OpenAL REQUIRED)
find_package(VorbisFile REQUIRED)
find_package(Ogg REQUIRED)
find_package(ModPlug REQUIRED)
find_package(Lua51 REQUIRED)
find_package(PhysFS REQUIRED)

# source files
file(
  GLOB
  source_files
  src/*.cpp
  src/entities/*.cpp
  src/hero/*.cpp
  src/hud/*.cpp
  src/lowlevel/*.cpp
  src/lua/*.cpp
  src/menus/*.cpp
  src/movements/*.cpp
  src/snes_spc/*.cpp
  include/*.h
  include/entities/*.h
  include/hero/*.h
  include/hud/*.h
  include/lowlevel/*.h
  include/lua/*.h
  include/menus/*.h
  include/movements/*.h
  include/simpleini/*.h
  include/snes_spc/*.h
)

# additional source files for Mac OS
if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  include_directories(
    ${SOLARUS_ENGINE_SOURCE_DIR}/include/lowlevel/osx
  )
  set(source_files
    ${source_files}
    src/lowlevel/osx/SDLMain.m
    include/lowlevel/osx/SDLMain.h
  )
endif()

# build the executable
set(main_source_file src/lowlevel/Main.cc)
add_library(solarus_static
  STATIC
  ${source_files}
)
add_executable(solarus
  ${main_source_file}
)

# generate -I flags
include_directories(
  ${SOLARUS_ENGINE_SOURCE_DIR}/include
  ${SOLARUS_ENGINE_SOURCE_DIR}/include/snes_spc
  ${SDL_INCLUDE_DIR}
  ${SDLTTF_INCLUDE_DIR}
  ${SDLIMAGE_INCLUDE_DIR}
  ${OPENAL_INCLUDE_DIR}
  ${VORBISFILE_INCLUDE_DIR}
  ${OGG_INCLUDE_DIR}
  ${MODPLUG_INCLUDE_DIR}
  ${LUA_INCLUDE_DIR}
  ${PHYSFS_INCLUDE_DIR}
)

# generate -l flags
target_link_libraries(solarus
  solarus_static
  ${SDL_LIBRARY}
  ${SDLIMAGE_LIBRARY}
  ${SDLTTF_LIBRARY}
  ${OPENAL_LIBRARY}
  ${LUA_LIBRARY}
  ${PHYSFS_LIBRARY}
  ${VORBISFILE_LIBRARY}
  ${OGG_LIBRARY}
  ${MODPLUG_LIBRARY}
)

# default compilation flags
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING
      "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel."
      FORCE)
endif()
set(CMAKE_CXX_FLAGS "-Wall ${CMAKE_CXX_FLAGS}")
set(CMAKE_CXX_FLAGS_DEBUG "-Werror ${CMAKE_CXX_FLAGS_DEBUG}")

# compilation flags for Mac OS X (Intel) deployment
if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin" AND CMAKE_BUILD_TYPE MATCHES "Release")
  if(EXISTS /Developer/SDKs/MacOSX10.5.sdk)
    set(CMAKE_OSX_SYSROOT "/Developer/SDKs/MacOSX10.5.sdk" CACHE STRING "OS version whose headers you'll use" FORCE)
    set(CMAKE_OSX_ARCHITECTURES "ppc;i386;x86_64;" CACHE STRING "Compile for these processor architecture" FORCE)
  endif()
  if(NOT $ENV{MACOSX_DEPLOYMENT_TARGET} EQUAL "")
    set(CMAKE_OSX_DEPLOYMENT_TARGET "$ENV{MACOSX_DEPLOYMENT_TARGET}" CACHE STRING "The oldest OS version supported" FORCE)
    if($ENV{MACOSX_DEPLOYMENT_TARGET} STRGREATER "10.4")
      set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Xlinker -rpath -Xlinker @loader_path/../Frameworks/" CACHE STRING "Embed frameworks search path" FORCE)
    endif()
    if($ENV{MACOSX_DEPLOYMENT_TARGET} STRLESS "10.6")
      set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -no_compact_linkedit" CACHE STRING "Disable 10.6+ features if deploy on older version" FORCE)
    endif()
  endif()
endif()

# solarus options
option(DEBUG_KEYS "Enable the debugging keys." OFF)
if(DEBUG_KEYS)
  add_definitions(-DSOLARUS_DEBUG_KEYS)
endif()

set(DEFAULT_QUEST "." CACHE STRING "Path to the quest to launch if none is specified at runtime.")
if(DEFAULT_QUEST)
  add_definitions(-DSOLARUS_DEFAULT_QUEST=\"${DEFAULT_QUEST}\")
endif()

if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  set(DEFAULT_WRITE_DIR "Library/Application Support/Solarus")
else()
  set(DEFAULT_WRITE_DIR ".solarus")
endif()
set(WRITE_DIR ${DEFAULT_WRITE_DIR} CACHE STRING "Directory where Solarus savegames are stored, relative to the user's home directory")
if(WRITE_DIR)
  add_definitions(-DSOLARUS_WRITE_DIR=\"${WRITE_DIR}\")
endif()

if(PANDORA)
  set(DEFAULT_SCREEN_WIDTH 400)
else()
  set(DEFAULT_SCREEN_WIDTH 320)
endif()
set(SCREEN_WIDTH ${DEFAULT_SCREEN_WIDTH} CACHE INTEGER "Width of the logical screen in pixels")
set(SCREEN_HEIGHT 240 CACHE INTEGER "Height of the logical screen in pixels")
if(SCREEN_WIDTH)
  add_definitions(-DSOLARUS_SCREEN_WIDTH=${SCREEN_WIDTH})
endif()
if(SCREEN_HEIGHT)
  add_definitions(-DSOLARUS_SCREEN_HEIGHT=${SCREEN_HEIGHT})
endif()

# files to install with make install
install(TARGETS	solarus
  RUNTIME DESTINATION bin
)

