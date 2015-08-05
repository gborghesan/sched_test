
#
# Components, types and plugins.
#
# The CMake 'target' names are identical to the first argument of the
# macros below, except for orocos_typegen_headers, where the target is fully
# controlled by generated code of 'typegen'.
#

# Creates a component library libsched_test-<target>.so
# and installs in the directory lib/orocos/sched_test/
#

orocos_component(sched_test sched_test-component.hpp sched_test-component.cpp) # ...you may add multiple source files

#
# You may add multiple orocos_component statements.

#
# Additional headers:
#
# Installs in the include/orocos/sched_test/ directory
#

#orocos_install_headers(sched_test-component.hpp) # ...you may add multiple header files

#
# You may add multiple orocos_install_headers statements.

#
# Building a Plugin
#
# Creates a plugin library libsched_test-plugin-<target>.so
# and installs in the directory lib/orocos/sched_test/plugins/
#
# Be aware that a plugin may only have the loadRTTPlugin() function once defined in a .cpp file.
# This function is defined by the plugin and service CPP macros.
#

#orocos_plugin(sched_test-plugin sched_test-plugin.cpp) # ...only one plugin function per library !

#
# You may add multiple orocos_plugin statements.


#
# Building a Service:
#
# Creates a plugin library libsched_test-service-<target>.so
# and installs in the directory lib/orocos/sched_test/plugins/
#

#orocos_service(sched_test-service sched_test-service.cpp) # ...only one service per library !

#
# You may add multiple orocos_service statements.


#
# Building a normal library (optional):
#
# Creates a library libsched_test-support-<target>.so and installs it in
# lib/
#

#orocos_library(sched_test-support support.cpp) # ...you may add multiple source files

#
# You may add multiple orocos_library statements.


