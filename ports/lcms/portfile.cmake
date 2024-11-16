vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(SHARED_LIBRARY_PATCH "fix-shared-library.patch")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mm2/Little-CMS
    REF "lcms${VERSION}"
    SHA512 c0d857123a0168cb76b5944a20c9e3de1cbe74e2b509fb72a54f74543e9c173474f09d50c495b0a0a295a3c2b47c5fa54a330d057e1a59b5a7e36d3f5a7f81b2
    HEAD_REF master
    PATCHES
        ${SHARED_LIBRARY_PATCH}
)

# Plugins
if("fastfloat" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dfastfloat=true)
else()
    list(APPEND OPTIONS -Dfastfloat=false)
endif()
if("threaded" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dthreaded=true)
else()
    list(APPEND OPTIONS -Dthreaded=false)
endif()

# Handle tools
set(UTILS_OPTION false)
if("tools" IN_LIST FEATURES)
    set(UTILS_OPTION true)
endif()
if("jpeg" IN_LIST FEATURES)
    list(APPEND OPTIONS -Djpeg=enabled)
    list(APPEND ADDITIONAL_TOOLS jpgicc)
    set(UTILS_OPTION true)
else()
    list(APPEND OPTIONS -Djpeg=disabled)
endif()
if("tiff" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dtiff=enabled)
    list(APPEND ADDITIONAL_TOOLS tificc)
    set(UTILS_OPTION true)
else ()
    list(APPEND OPTIONS -Dtiff=disabled)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
        -Dutils=${UTILS_OPTION}
        -Dsamples=false
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

if(UTILS_OPTION STREQUAL true)
    vcpkg_copy_tools(
        TOOL_NAMES linkicc psicc transicc ${ADDITIONAL_TOOLS}
        AUTO_CLEAN
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/man")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
