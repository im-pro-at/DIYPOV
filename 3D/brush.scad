include <config.scad>

use <holder.scad>

brush_holder_d=51;

module debug(){
    translate([0,brush_holder_d,0])
    rotate([180,0,0])
    translate([0,0,-40-2])
        holder();
        

    for(i=[0,brush_holder_d])
    translate([0,i,-1])
    difference(){
        cube([50,50,2],true);
        for(i=[-1,1])
        translate([0,i*29/2,-2])
            cylinder(h=4,d=4.4);
    }
    //PCB
    translate([0,brush_holder_d,40+2])
    rotate(0){        
        translate([-50,-50,0])        
            cube([100,100,1.6]);
        translate([-5/2,-2/2-46,-27])        
            cube([5,2,27]);
    }
}

module brush(){
    brush1();
    translate([0,brush_holder_d-15-26/2-2,16])
    rotate([-90,90,0])
        brush2();
}

module brush1(){
    difference(){
        union(){
            translate([-35/2,brush_holder_d-15-26/2-2-5,0])
                cube([35,5,23.5]);
            translate([0,brush_holder_d-15-26/2-2,0])
            intersection(){                
                translate([-12/2,-15,0])
                    cube([12,15,23.5]);
                translate([0,0,-1])
                    cylinder(h=23.5+2,d=29);
            }
            translate([-35/2,5,0])
                cube([35,15,5]);
            translate([-15/2,-40/2,0])
                cube([15,40,5]);
        }
        
        for(i=[-1,1])
        translate([0,i*29/2,0]){
            translate([0,0,5-2])
                cylinder(h=M4_nut_h,r=M4_nut_d/2,$fn=6);        
            translate([0,0,-1])
                cylinder(h=10+2,d=4+2*play);
        }        
        translate([-M4_nut_d/2,29/2,3])
            cube([M4_nut_d,10,M4_nut_h]);       
        translate([0,brush_holder_d-15-26/2-2,16]){
            translate([0,-1,0])
            difference(){
                union(){                
                    for(i=[-1,1]) 
                    translate([0,0,i*(5+2)/2])
                    rotate([-90,0,0])
                        cylinder(h=2,d=10);
                    for(i=[0,180]) 
                    rotate([i,0,0])
                    translate([0,0,3])
                        cylinder(h=8,d=3);
                }
                translate([-10/2,-1,-1/2])
                    cube([10,4,1]);
            }
            for(i=[-1,1]) 
            translate([i*25/2,-8,0])
                rotate([-90,0,0])
                {
                    cylinder(h=10,d=3.2+play);
                    translate([0,0,2])
                        cylinder(h=M3_nut_h,r=M3_nut_d/2,$fn=6);        
                }
        }
        translate([0,6,21.5-10/2-1])
        rotate([-90,0,0])
            cylinder(h=3,d=10+2*play);        
    }
}

module brush2(){
    difference(){
        union(){
            translate([-15/2,-15/2,0])
                cube([14.4,15,15]);
            translate([-15/2,-35/2,0])
                cube([15,35,3]);
        }
        for(i=[-1,1])
        translate([i*(5+2)/2,0,+15/2])
            cube([4.8+2*play,6.3+2*play,15+2],center=true);
        
        for(i=[-1,1])
        translate([0,i*25/2,-1])
            cylinder(h=20+2,d=3.2+play);        
    }
}


//debug();

brush();
//brush1();
//brush2();