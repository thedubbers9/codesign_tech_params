#=========================================================================
# compile.tcl
#=========================================================================
# Author : Alex Carsello
# Date   : September 28, 2020

set_attr uniquify_naming_style "%s_%d"
uniquify $design_name

set_multi_cpu_usage -local_cpu 8

# Obey flattening effort of mflowgen graph
# set_attribute auto_ungroup $auto_ungroup_val

# ungroup -all [find /designs/NOC -inst /designs/NOC/instances_hier/]

syn_gen
set_attr syn_map_effort high
syn_map
syn_opt
