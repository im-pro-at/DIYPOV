include <config.scad>

module corner(){
    difference(){
        union(){
            cube([20,20,3]);

            cube([20,8,20]);

            cube([3,20,20]);

        }
        
        rotate([-90,0,0])
        translate([20/2,-20/2,0]){
            translate([0,0,8-2])
                cylinder(h=3,d=10+play*2);
            translate([0,0,-3+2])
                cylinder(h=3,d=12+play*2);
        }
        
        translate([20/2+2,20/2+4,-1])
            cylinder(h=3+2,d=3+play*2);

        rotate([0,-90,0])
        translate([20/2+2,20/2+4,-3-1])
            cylinder(h=3+2,d=3+play*2);
    }
}

corner();