# - Help functions for including libs for click packages
# It makes use of the latest manifest file provided on the Ubuntu website
#  http://cdimage.ubuntu.com/ubuntu-touch/daily-preinstalled/current/
# Following cmake files need to be included:
#  ResolveLibs.cmake
# You can change the url for lookup with:
#  MANIFEST_URL_PREFIX - defaults to http://cdimage.ubuntu.com/ubuntu-touch/daily-preinstalled/current/trusty-preinstalled-touch-
#  MANIFEST_URL_SUFFIX - defaults to .manifest
#  MANIFEST_USE_ARCH - defaults to true


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

set(MANIFEST_URL "${MANIFEST_URL_PREFIX}")
if(MANIFEST_USE_ARCH)
    set(MANIFEST_URL "${MANIFEST_URL}${DPKG_BUILD_ARCH}")
endif()
set(MANIFEST_URL "${MANIFEST_URL}${MANIFEST_URL_SUFFIX}")

message("MANIFEST_URL: ${MANIFEST_URL}")
execute_process(
    COMMAND curl -s "${MANIFEST_URL}"
    COMMAND cut -f 1
    OUTPUT_VARIABLE PACKAGES
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

#message("PACKAGES: ${PACKAGES}")
if(${PACKAGES} MATCHES "^<" OR NOT PACKAGES)
    message("Error retreiving manifest")
    set(PACKAGES "")
    set(PACKAGES_LIST "")
else()
    STRING(REGEX REPLACE "\n" ";" PACKAGES_LIST ${PACKAGES})
endif()

function(deploy_libs libs)
    foreach(lib ${ARGN})
        message("LIB: ${lib}")
        resolve_lib(${lib} resolved succes)
        if(succes)
            message("RESOLVED: ${resolved}")
            if(NOT PACKAGES_LIST)
                message("Mark for install")
                install(FILES ${resolved}
                    DESTINATION ${CMAKE_INSTALL_LIBDIR}/)
            else()
                execute_process(
                    COMMAND dpkg -S ${resolved} 
                    COMMAND sed "s/^\\(.*\\):.*$/\\1/"
                    COMMAND sed "s/^\\(.*\\):${DPKG_BUILD_ARCH}\$/\\1/"
                    OUTPUT_VARIABLE PACKAGE
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
                message("PACKAGE: ${PACKAGE}")
                list(FIND PACKAGES_LIST ${PACKAGE} index)
                if(index EQUAL -1)
                    list(FIND PACKAGES_LIST "${PACKAGE}:${DPKG_BUILD_ARCH}" index)
                endif()
                if(index EQUAL -1)
                    message("Mark for install")
                    install(FILES ${resolved}
                        DESTINATION ${CMAKE_INSTALL_LIBDIR}/)
                else()
                    message("In manifest")
                endif()
            endif()
        else(succes)
            message("Not includeable")
        endif(succes)
    endforeach()
endfunction()
