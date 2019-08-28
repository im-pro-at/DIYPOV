include <config.scad>

module magnete()
difference(){
    union(){
        translate([-13/2,-13/2,0])
            cube([13,13,42]);
    }
    
    translate([0,0,42-2])
        cylinder(h=2+1,d=10+2*play);
    
    translate([0,0,-1])
        cylinder(h=20+1,d=3+play);
    
    translate([0,0,15]){
    rotate([0,0,30])
        cylinder(h=M3_nut_h,r=M3_nut_d/2,$fn=6);        
    translate([0,-M3_nut_d/2,0])
        cube([13,M3_nut_d,M3_nut_h]);        
    }
}

magnete();
/*
        color("yellow")
        translate([160,0,25])
            magnete();
*/