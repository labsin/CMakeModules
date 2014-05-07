# - Help functions for including libs for click packages
# It makes use of the latest manifest file provided on the Ubuntu website
#  http://cdimage.ubuntu.com/ubuntu-touch/daily-preinstalled/current/
# Following cmake files need to be included:
#  ResolveLibs.cmake
# You can change the url for lookup with:
#  MANIFEST_URL_PREFIX - defaults to http://cdimage.ubuntu.com/ubuntu-touch/daily-preinstalled/current/trusty-preinstalled-touch-
#  MANIFEST_URL_SUFFIX - defaults to .manifest
#  MANIFEST_USE_ARCH - defaults to true
#
# Other variables that are used:
#  CLICK_DEPLOY_ONLY_LIBS - defaults to true
#  CLICK_DEPLOY_STATIC_LIBS - defaults to false
#  CLICK_DEPLOY_INCLUDE_NO_MANIFEST - Include the libs when no manifest was found,
#    defaults to true


include(ResolveLibs)

if(NOT DEFINED DPKG_BUILD_ARCH)
    execute_process(COMMAND dpkg-architecture -qDEB_HOST_ARCH
        OUTPUT_VARIABLE BUILD_ARCH_TEMP
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    set(DPKG_BUILD_ARCH ${BUILD_ARCH_TEMP} CACHE PATH "Debian arch")
endif()

if(NOT DEFINED MANIFEST_URL_PREFIX)
    set(MANIFEST_URL_PREFIX "http://cdimage.ubuntu.com/ubuntu-touch/daily-preinstalled/current/trusty-preinstalled-touch-")
endif()

if(NOT DEFINED MANIFEST_URL_SUFFIX)
    set(MANIFEST_URL_SUFFIX ".manifest")
endif()

if(NOT DEFINED MANIFEST_USE_ARCH)
    set(MANIFEST_USE_ARCH true)
endif()

if(NOT DEFINED CLICK_DEPLOY_ONLY_LIBS)
    set(CLICK_DEPLOY_ONLY_LIBS true)
endif()

if(NOT DEFINED CLICK_DEPLOY_STATIC_LIBS)
    set(CLICK_DEPLOY_STATIC_LIBS false)
endif()

if(NOT DEFINED CLICK_DEPLOY_INCLUDE_NO_MANIFEST)
    set(CLICK_DEPLOY_INCLUDE_NO_MANIFEST true)
endif()

set(MANIFEST_URL "${MANIFEST_URL_PREFIX}")
if(MANIFEST_USE_ARCH)
    set(MANIFEST_URL "${MANIFEST_URL}${DPKG_BUILD_ARCH}")
endif()
set(MANIFEST_URL "${MANIFEST_URL}${MANIFEST_URL_SUFFIX}")

message(STATUS "MANIFEST_URL: ${MANIFEST_URL}")
execute_process(
    COMMAND curl -s "${MANIFEST_URL}"
    COMMAND cut -f 1
    OUTPUT_VARIABLE PACKAGES
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

if(${PACKAGES} MATCHES "^<" OR NOT PACKAGES) # It's a HTML page or nothing returned
    message(STATUS "Error retreiving manifest")
    set(PACKAGES "")
    set(PACKAGES_LIST "")
else()
    STRING(REGEX REPLACE "\n" ";" PACKAGES_LIST ${PACKAGES})
endif()

function(deploy_lib lib)
    message(STATUS "Mark ${lib} for install")
    install(FILES ${lib}
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/)
endfunction()

function(deploy_libs libs)
    message(STATUS "Deploy Libs")
    set(error false)
    if(NOT PACKAGES_LIST) # If manifest was not downloaded
        if(NOT ${CLICK_DEPLOY_INCLUDE_NO_MANIFEST})
            set(error true)
            message(STATUS "  No manifest found")
        endif()
    endif()
    if(NOT error)
        foreach(lib ${ARGN})
            set(error false)
            message(STATUS "  LIB: ${lib}")
            resolve_lib(${lib} resolved found_lib)
            if(found_lib)
                message(STATUS "    RESOLVED: ${resolved}")
                if(NOT ${CLICK_DEPLOY_STATIC_LIBS})
                    if(${resolved} MATCHES "^.*\\.a([0-9]|\\.)*$") # If it's a static lib
                        set(error true)
                        message(STATUS "    Not deploying static libs")
                    endif()
                endif(NOT ${CLICK_DEPLOY_STATIC_LIBS})
                if(${CLICK_DEPLOY_ONLY_LIBS})
                    if(${resolved} MATCHES "^.*\\.(so|a)([0-9]|\\.)*$") # If it's a static or dynamic lib
                    else()
                        set(error true)
                        message(STATUS "    Only deploy libs")
                    endif()
                endif(${CLICK_DEPLOY_ONLY_LIBS})
            endif(found_lib)
            if(found_lib AND NOT error)
                if(NOT PACKAGES_LIST)
                    deploy_lib(${resolved})
                else(NOT PACKAGES_LIST)
                    execute_process(
                        COMMAND dpkg -S ${resolved}
                        COMMAND sed "s/^\\(.*\\):.*$/\\1/"
                        COMMAND sed "s/^\\(.*\\):${DPKG_BUILD_ARCH}\$/\\1/"
                        OUTPUT_VARIABLE PACKAGE
                        OUTPUT_STRIP_TRAILING_WHITESPACE)
                    message(STATUS "    PACKAGE: ${PACKAGE}")
                    list(FIND PACKAGES_LIST ${PACKAGE} index) # Search for package in manifest list
                    if(index EQUAL -1)
                        list(FIND PACKAGES_LIST "${PACKAGE}:${DPKG_BUILD_ARCH}" index) # Search for package:architecture in manifest
                    endif(index EQUAL -1)
                    if(index EQUAL -1)
                        deploy_lib(${resolved})
                    else(index EQUAL -1)
                        message(STATUS "    In manifest")
                    endif(index EQUAL -1)
                endif(NOT PACKAGES_LIST)
            else(found_lib AND NOT error)
                if(NOT error)
                    message(STATUS "    Lib not found")
                endif(NOT error)
            endif(found_lib AND NOT error)
        endforeach(lib ${ARGN})
    endif(NOT error)
endfunction()
