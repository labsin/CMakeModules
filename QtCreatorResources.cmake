# Macro to include arbitrary files in the QtCreator tree
#  when importing cmake
macro( qtcreator_add_project_resources resources )
  add_custom_target( ${PROJECT_NAME}_Resources ALL SOURCES ${ARGN} )
endmacro()
