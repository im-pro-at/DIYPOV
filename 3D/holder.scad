include <config.scad>

module holder(){
    base_w=25;
    base_h=17.5;
    cylinder_d=18.5;
    cylinder_h=7;
    difference(){
        union(){
            //base
            translate([-base_w/2,-base_w/2,0])
                cube([base_w,base_w,base_h]);
            
            //cylinder
            translate([0,0,base_h-1])
                cylinder(h=cylinder_h+1,d=cylinder_d);
        }    
        //cable holes
        rotate([0,-90,0])        
            translate([0,0,0])
                cylinder(h=base_h+cylinder_h+2,r=3);
        translate([-cylinder_d/2,0,base_h+1])
            cylinder(h=cylinder_h+4,r=3);
        translate([-cylinder_d/2+3,0,base_h])
        rotate([0,-90,0])        
            cylinder(h=base_w/2,r=3);
            
        //motor hole
        translate([0,0,-1])
            cylinder(h=base_h+cylinder_h+2,d=5+play);
        for(r=[0,180])
        rotate([0,0,r+90])        
        translate([0,0,base_h-5])
        rotate([0,90,0]){        
            translate([0,0,0])
                cylinder(h=base_h+cylinder_h+2,d=3.2+play);
            translate([0,0,4]){
                rotate([0,0,30])
                    cylinder(h=M3_nut_h,r=M3_nut_d/2,$fn=6);        
                translate([0,-M3_nut_d/2,0])
                    cube([base_h,M3_nut_d,M3_nut_h]);        
            }
        }
        //holes
        holes_w=15.24;
        for(dx=[-1,1])
        for(dy=[-1,1])
        translate([dx*holes_w/2,dy*holes_w/2,0]){
            translate([0,0,-1])
                cylinder(h=base_h+2,d=3.2+play);
            translate([0,0,11]){
                rotate([0,0,30])
                    cylinder(h=M3_nut_h,r=M3_nut_d/2,$fn=6);        
                translate([base_w*(dx-1)/2,-M3_nut_d/2,0])
                    cube([base_w,M3_nut_d,M3_nut_h]);        
            }
        }
        //fpga
        translate([10,-70/2,-1])
            cube([18,70,18+1]);
        for(i=[[base_w/2,5],[0,10],[-base_w/2,5]])
        translate([10-3,-i[1]/2-i[0],-1])
            cube([18,i[1],3]);
    }
}

holder();