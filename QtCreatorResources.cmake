# Macro to include arbitrary files in the QtCreator tree
#  when importing cmake
macro( qtcreator_add_project_resources resources )
    if(NOT DEFINED ${PROJECT_NAME}_NO_RESOURCE_PROJECTS)
        set(${PROJECT_NAME}_NO_RESOURCE_PROJECTS 0)
    else(NOT DEFINED ${PROJECT_NAME}_NO_RESOURCE_PROJECTS)
        MATH( EXPR ${PROJECT_NAME}_NO_RESOURCE_PROJECTS "${${PROJECT_NAME}_NO_RESOURCE_PROJECTS} + 1" )
    endif(NOT DEFINED ${PROJECT_NAME}_NO_RESOURCE_PROJECTS)
    add_custom_target( ${PROJECT_NAME}_Resources${${PROJECT_NAME}_NO_RESOURCE_PROJECTS} ALL SOURCES ${ARGN} )
endmacro()
