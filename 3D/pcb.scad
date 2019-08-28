include <config.scad>

module APA102(){
    color("White")
    translate([-2.5,-2.5,-1.7])
        cube([5,5,1.4]);
    color("SkyBlue")
    translate([0,0,-1.7-0.1])
        cylinder(h=0.1);
}

include  <../pcb/new_board1.scad>
include <../pcb/new_board2.scad>