#=========================================================================
# main.tcl
#=========================================================================
# Run the foundation flow step
#
# Author : Christopher Torng
# Date   : January 13, 2020

setMultiCpuUsage -localCpu 8
setNanoRouteMode -drouteOnGridOnly true
# set_db route_detail_on_grid_only true

setAttribute -net * -preferred_routing_layer_effort hard
createRouteBlk -box 0 [expr [dbGet top.fPlan.box_ury] - 0.200]  [dbGet top.fPlan.box_urx] [dbGet top.fPlan.box_ury] -layer V6
createRouteBlk -box [expr [dbGet top.fPlan.box_urx] - 0.200 - 0.144] 0 [dbGet top.fPlan.box_urx] [dbGet top.fPlan.box_ury] -layer V6

source -verbose innovus-foundation-flow/INNOVUS/run_route.tcl

report_timing -max_paths 300 > delay.rpt
report_power > power.rpt
report_area -detail -sort_by area -table_style vertical > area.rpt

set core_area [open "core_area.txt" "a"]
puts $core_area [dbGet top.fPlan.box_urx]
puts $core_area [dbGet top.fPlan.box_ury]
close $core_area

verify_drc -report drc.rpt
