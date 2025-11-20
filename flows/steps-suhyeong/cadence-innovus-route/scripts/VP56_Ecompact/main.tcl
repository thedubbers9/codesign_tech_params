#=========================================================================
# main.tcl
#=========================================================================
# Run the foundation flow step
#
# Author : Christopher Torng
# Date   : January 13, 2020

setMultiCpuUsage -localCpu 8
setNanoRouteMode -drouteOnGridOnly true

set pitch 0.144
set top_offset [expr $pitch * 0.5]
set right_offset [expr $pitch * 1.5]
set top_margin $top_offset
set right_margin $right_offset

setNanoRouteMode -route_strictly_honor_1d_routing true
createRouteBlk -box 0 [expr [dbGet top.fPlan.box_ury] - $top_margin]  [dbGet top.fPlan.box_urx] [dbGet top.fPlan.box_ury] -layer {M2 M3 M4 M5 M6 V6}
createRouteBlk -box [expr [dbGet top.fPlan.box_urx] - $right_margin] 0 [dbGet top.fPlan.box_urx] [dbGet top.fPlan.box_ury] -layer {M2 M3 M4 M5 M6 V6}

source -verbose innovus-foundation-flow/INNOVUS/run_route.tcl

report_timing -max_paths 300 > delay.rpt
report_power > power.rpt
report_area -detail -sort_by area -table_style vertical > area.rpt

set core_area [open "core_area.txt" "a"]
puts $core_area [expr [dbGet top.fPlan.box_urx] - $right_offset]
puts $core_area [expr [dbGet top.fPlan.box_ury] - $top_offset]
close $core_area

verify_drc -report drc.rpt
