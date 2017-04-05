# Install script for directory: /home/pbhosale/tools/nifty_reg/reg-lib

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/home/pbhosale/tools/nifty_reg/install")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "RelWithDebInfo")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/home/pbhosale/tools/nifty_reg/build/reg-lib/lib_reg_resampling.a")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_resampling.h")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/home/pbhosale/tools/nifty_reg/build/reg-lib/lib_reg_maths.a")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_maths.h")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/home/pbhosale/tools/nifty_reg/build/reg-lib/lib_reg_globalTransformation.a")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_globalTransformation.h")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/home/pbhosale/tools/nifty_reg/build/reg-lib/lib_reg_mutualinformation.a")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_mutualinformation.h")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/home/pbhosale/tools/nifty_reg/build/reg-lib/lib_reg_ssd.a")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_ssd.h")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/home/pbhosale/tools/nifty_reg/build/reg-lib/lib_reg_KLdivergence.a")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_KLdivergence.h")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/home/pbhosale/tools/nifty_reg/build/reg-lib/lib_reg_blockMatching.a")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_blockMatching.h")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/home/pbhosale/tools/nifty_reg/build/reg-lib/lib_reg_femTransformation.a")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_femTransformation.h")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/home/pbhosale/tools/nifty_reg/build/reg-lib/lib_reg_tools.a")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_tools.h")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/home/pbhosale/tools/nifty_reg/build/reg-lib/lib_reg_localTransformation.a")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_localTransformation.h")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/home/pbhosale/tools/nifty_reg/build/reg-lib/lib_reg_globalTransformation_gpu.a")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_globalTransformation_gpu.h")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/home/pbhosale/tools/nifty_reg/build/reg-lib/lib_reg_blockMatching_gpu.a")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_blockMatching_gpu.h")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/home/pbhosale/tools/nifty_reg/build/reg-lib/lib_reg_localTransformation_gpu.a")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_localTransformation_gpu.h")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/home/pbhosale/tools/nifty_reg/build/reg-lib/lib_reg_mutualinformation_gpu.a")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_mutualinformation_gpu.h")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/home/pbhosale/tools/nifty_reg/build/reg-lib/lib_reg_resampling_gpu.a")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_resampling_gpu.h")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/home/pbhosale/tools/nifty_reg/build/reg-lib/lib_reg_tools_gpu.a")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_tools_gpu.h")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/home/pbhosale/tools/nifty_reg/build/reg-lib/lib_reg_cudaCommon.a")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_cudaCommon.h")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_blocksize_gpu.h")
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES
    "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_f3d_gpu.h"
    "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_f3d_gpu.cpp"
    )
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "RuntimeLibraries" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/lib_reg_f3d.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/lib_reg_f3d.so")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/lib_reg_f3d.so"
         RPATH "")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/home/pbhosale/tools/nifty_reg/build/reg-lib/lib_reg_f3d.so")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/lib_reg_f3d.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/lib_reg_f3d.so")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/lib_reg_f3d.so")
    endif()
  endif()
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES
    "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_f3d.h"
    "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_f3d.cpp"
    )
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES
    "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_f3d2.h"
    "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_f3d2.cpp"
    )
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES
    "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_f3d_sym.h"
    "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_f3d_sym.cpp"
    )
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "RuntimeLibraries" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/lib_reg_aladin.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/lib_reg_aladin.so")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/lib_reg_aladin.so"
         RPATH "")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/home/pbhosale/tools/nifty_reg/build/reg-lib/lib_reg_aladin.so")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/lib_reg_aladin.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/lib_reg_aladin.so")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/lib_reg_aladin.so")
    endif()
  endif()
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES
    "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_aladin.h"
    "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_aladin.cpp"
    "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_macros.h"
    )
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "RuntimeLibraries" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/lib_reg_thinPlateSpline.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/lib_reg_thinPlateSpline.so")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/lib_reg_thinPlateSpline.so"
         RPATH "")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/home/pbhosale/tools/nifty_reg/build/reg-lib/lib_reg_thinPlateSpline.so")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/lib_reg_thinPlateSpline.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/lib_reg_thinPlateSpline.so")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/lib_reg_thinPlateSpline.so")
    endif()
  endif()
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Development" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES
    "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_thinPlateSpline.h"
    "/home/pbhosale/tools/nifty_reg/reg-lib/_reg_thinPlateSpline.cpp"
    )
endif()

