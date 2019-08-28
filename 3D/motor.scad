include <config.scad>

module motor(){
    w=20;
    translate([45/2-3,0,0])
    difference(){
       union(){
            translate([0,-w/2,0])
                cube([20,w,10]);
            
            translate([10,-(w+15)/2,0])
                cube([10,w+15,10]);
        }
        translate([-45/2+3,0,-1])
            cylinder(h=10+2,d=45);
        
        translate([9,-(w+15+2)/2,-1])
            cube([2,w+15+2,10+2]);
        
        for(d=[1,-1])
        translate([5,d*(w/2-5),10/2])
        rotate([0,90,0]){
            cylinder(h=20+2,d=3+play*2);
            translate([0,0,3+3-1])
                cylinder(h=M3_nut_h+1,r=M3_nut_d/2,$fn=6);        
        }
        
        for(d=[1,-1])
        translate([18.5-3,d*(w+12-5)/2,-1])
            cylinder(h=10+2,d=3+play*2);
    }
}

motor();
