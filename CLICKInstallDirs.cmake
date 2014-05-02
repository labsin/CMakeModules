# - Define CLICK installation directories when CLICK_MODE set
#  otherwise defaults to GNU default installation directories
# Provides install directory variables as defined for GNU software:
#  http://www.gnu.org/prep/standards/html_node/Directory-Variables.html
# Inclusion of this module defines the following variables:
#  CMAKE_INSTALL_<dir>      - destination for files of a given type
#  CMAKE_INSTALL_FULL_<dir> - corresponding absolute path
# where <dir> is one of:
#  BINDIR           - user executables (bin)
#  SBINDIR          - system admin executables (sbin)
#  LIBEXECDIR       - program executables (libexec)
#  SYSCONFDIR       - read-only single-machine data (etc)
#  SHAREDSTATEDIR   - modifiable architecture-independent data (com)
#  LOCALSTATEDIR    - modifiable single-machine data (var)
#  LIBDIR           - object code libraries (lib or lib64 or lib/<multiarch-tuple> on Debian)
#  INCLUDEDIR       - C header files (include)
#  OLDINCLUDEDIR    - C header files for non-gcc (/usr/include)
#  DATAROOTDIR      - read-only architecture-independent data root (share)
#  DATADIR          - read-only architecture-independent data (DATAROOTDIR)
#  INFODIR          - info documentation (DATAROOTDIR/info)
#  LOCALEDIR        - locale-dependent data (DATAROOTDIR/locale)
#  MANDIR           - man documentation (DATAROOTDIR/man)
#  DOCDIR           - documentation root (DATAROOTDIR/doc/PROJECT_NAME)
# Each CMAKE_INSTALL_<dir> value may be passed to the DESTINATION options of
# install() commands for the corresponding file type.  If the includer does
# not define a value the above-shown default will be used and the value will
# appear in the cache for editing by the user.
# Each CMAKE_INSTALL_FULL_<dir> value contains an absolute path constructed
# from the corresponding destination by prepending (if necessary) the value
# of CMAKE_INSTALL_PREFIX.

option(CLICK_MODE "Installs to a contained location" off)
if(CLICK_MODE)
    execute_process(COMMAND dpkg-architecture -qDEB_HOST_MULTIARCH
        OUTPUT_VARIABLE BUILD_ARCH_TEMP
        OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    set(BUILD_ARCH_TRIPLET "${BUILD_ARCH_TEMP}" CACHE PATH "Debian multiarch triplet")

    if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
        set(CMAKE_INSTALL_PREFIX "" CACHE PATH "Click install prefix" FORCE)
    endif(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)

    set(CMAKE_INSTALL_BINDIR "${CMAKE_INSTALL_PREFIX}/lib/${BUILD_ARCH_TRIPLET}" CACHE PATH "user executables")
    set(CMAKE_INSTALL_SBINDIR "${CMAKE_INSTALL_BINDIR}" CACHE PATH "system admin executables")
    set(CMAKE_INSTALL_LIBEXECDIR "${CMAKE_INSTALL_BINDIR}" CACHE PATH "program executables")
    set(CMAKE_INSTALL_SYSCONFDIR "${CMAKE_INSTALL_BINDIR}" CACHE PATH "read-only single-machine data")
    set(CMAKE_INSTALL_SHAREDSTATEDIR "${CMAKE_INSTALL_BINDIR}" CACHE PATH "modifiable architecture-independent data")
    set(CMAKE_INSTALL_LOCALSTATEDIR "${CMAKE_INSTALL_BINDIR}" CACHE PATH "modifiable single-machine data")
    set(CMAKE_INSTALL_LIBDIR "${CMAKE_INSTALL_BINDIR}" CACHE PATH "object code libraries")

    set(CMAKE_INSTALL_DATAROOTDIR "${CMAKE_INSTALL_PREFIX}" CACHE PATH "read-only architecture-independent data root")
endif(CLICK_MODE)

include(GNUInstallDirs)
