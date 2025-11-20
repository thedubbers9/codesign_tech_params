#=========================================================================
# pin-assignments.tcl
#=========================================================================
# The ports of this design become physical pins along the perimeter of the
# design. The commands below will spread the pins along the left and right
# perimeters of the core area. This will work for most designs, but a
# detail-oriented project should customize or replace this section.
#
# Author : Christopher Torng
# Date   : March 26, 2018

#-------------------------------------------------------------------------
# Pin Assignments
#-------------------------------------------------------------------------

# Take all ports and split into halves
set top_layer M8
set sub_top_layer M7

set bot_layer M1

set buf 0
set base_pitch 0.144
set xoffset $base_pitch
set yoffset $base_pitch
set pin_depth 0.112

# how to calculate block_width is key
set block_width [expr $base_pitch * 2 + $xoffset * 2]

set all_ports   [dbGet top.terms.name]

set real_ports	[lsearch -inline -all -not  -regexp $all_ports "fake"]
set fake_ports	[lsearch -inline -all       -regexp $all_ports "fake"]

set real_in_ports	[lsearch -inline -all -not  -regexp $real_ports "out_data"]
set real_out_ports	[lsearch -inline -all       -regexp $real_ports "out_data"]
set fake_in_ports	[lsearch -inline -all -not  -regexp $fake_ports "out_data"]
set fake_out_ports	[lsearch -inline -all       -regexp $fake_ports "out_data"]

set in_ports	[lsearch -inline -all -not  -regexp $all_ports "out_data"]

set block_height [dbGet top.fPlan.box_ury]
	createPlaceBlockage -type hard -box 0 0 $block_width $block_height
setPinAssignMode -pinEditInBatch true

# fake out
set pitchY [expr $base_pitch * 2]
set pitchX $base_pitch

set odd 1
set y $yoffset
set x $xoffset
foreach port $fake_out_ports { 
  editPin -layer $bot_layer -pin $port -assign $x $y -side INSIDE -pinDepth $pin_depth
#  add_via -via VIA12 -pt $x $y
#  add_via -via VIA23 -pt $x $y
#  add_via -via VIA34 -pt $x $y
  if {$y >= [expr $block_height - $yoffset - $pitchY]} {
	if {$odd == 1} {
      set y [expr $yoffset + $base_pitch]
	  set odd 0
	} else {
	  set y $yoffset
	  set odd 1
	}
	set x [expr $x + $pitchX]
  } else {
    set y [expr $y + $pitchY]
  }
}

# real out
foreach port $real_out_ports { 
  editPin -layer $bot_layer -pin $port -assign $x $y -side INSIDE -pinDepth $pin_depth
  if {$y >= [expr $block_height - $yoffset - $pitchY]} {
	if {$odd == 1} {
      set y [expr $yoffset + $base_pitch]
	  set odd 0
	} else {
	  set y $yoffset
	  set odd 1
	}
	set x [expr $x + $pitchX]
  } else {
    set y [expr $y + $pitchY]
  }
}

# all in
set length [llength $in_ports]
set quarter [expr $length / 4]

set top_quarter [lrange $in_ports 0 [expr $quarter - 1]]
set right_half [lrange $in_ports $quarter [expr $length - $quarter - 1]]
set bot_quarter [lrange $in_ports [expr $length - $quarter] [expr $length - 1]]

editPin -layer $sub_top_layer -pin $top_quarter -side TOP -spreadType SIDE -pinDepth $pin_depth
editPin -layer $top_layer -pin $right_half -side RIGHT -spreadType SIDE -pinDepth $pin_depth
editPin -layer $sub_top_layer -pin $bot_quarter -side BOTTOM -spreadType SIDE -pinDepth $pin_depth

setPinAssignMode -pinEditInBatch false
