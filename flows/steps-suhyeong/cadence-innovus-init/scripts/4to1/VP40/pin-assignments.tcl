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
set top_layer M4
set bot_layer M1

set buf 0
set base_pitch 0.144
set xoffset $base_pitch
set yoffset $base_pitch
set pin_depth 0.112

# how to calculate block_width is key
set block_width [expr $base_pitch * 6 + $xoffset * 3]

set all_ports   [dbGet top.terms.name]

set real_ports	[lsearch -inline -all -not  -regexp $all_ports "fake"]
set fake_ports	[lsearch -inline -all       -regexp $all_ports "fake"]

set real_in_ports	[lsearch -inline -all -not  -regexp $real_ports "out_data"]
set real_out_ports	[lsearch -inline -all       -regexp $real_ports "out_data"]
set fake_in_ports	[lsearch -inline -all -not  -regexp $fake_ports "out_data"]
set fake_out_ports	[lsearch -inline -all       -regexp $fake_ports "out_data"]

set block_height [dbGet top.fPlan.box_ury]
	createPlaceBlockage -type hard -box 0 0 $block_width $block_height
setPinAssignMode -pinEditInBatch true

# fake in & out
set pitchY [expr $base_pitch * 3]
set pitchX [expr $base_pitch * 2]
set odd 1
set y $yoffset
set x $xoffset
foreach port $fake_in_ports { 
  editPin -layer $top_layer -pin $port -assign $x $y -side INSIDE -pinDepth $pin_depth
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

# real in
set length [llength $real_in_ports]
set edge ([expr {ceil([expr {sqrt($length)}])}])

set sizeX [expr [dbGet top.fPlan.box_urx] - $pin_depth]
set sizeY [expr [dbGet top.fPlan.box_ury] - $yoffset - $buf]

set pitchX [expr floor([expr [expr $sizeX / $edge] / $base_pitch]) * $base_pitch]
set pitchY [expr floor([expr [expr $sizeY / $edge] / $base_pitch]) * $base_pitch]

set idx 0
foreach port $real_in_ports {
  set x [expr [expr {int($idx / [expr int($edge)])}] * $pitchX + $xoffset * 4 + $block_width]
  set y [expr [expr $pitchY * [expr {int($idx % [expr int($edge)])}]] + $yoffset]
  editPin -layer $top_layer -pin $port -assign $x $y -side INSIDE -pinDepth $pin_depth   
  incr idx
}

setPinAssignMode -pinEditInBatch false
