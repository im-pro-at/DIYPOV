include <config.scad>

holder_base_w=25;
holder_base_h=20;
holder_cylinder_d=23.3;
holder_cylinder_h=6+5+2+5+2;

module holder(){
    holder1();
    translate([0,0,holder_base_h+holder_cylinder_h-6])
        holder2();
    translate([0,0,holder_base_h+holder_cylinder_h-2-6-5])    
        holder3();
}

module holder1(){
    difference(){
        union(){
            //base
            translate([-holder_base_w/2,-holder_base_w/2,0])
                cube([holder_base_w,holder_base_w,holder_base_h]);
            
            //cylinder
            translate([0,0,holder_base_h-1])
                cylinder(h=holder_cylinder_h+1,d=holder_cylinder_d);
            //cylinder2
            translate([0,0,holder_base_h-1])
                cylinder(h=2+1,d=25);
        }   
        //motor hole
        translate([0,0,-1])
            cylinder(h=holder_base_h+holder_cylinder_h+2,d=5+play);
        for(r=[-90,30,150])
        rotate([0,0,r+90])        
        translate([0,0,holder_base_h+holder_cylinder_h-3])
        rotate([0,90,0]){        
            translate([0,0,0])
                cylinder(h=holder_base_h+holder_cylinder_h+2,d=3.2+play);
            translate([0,0,4]){
                rotate([0,0,30])
                    cylinder(h=M3_nut_h,r=M3_nut_d/2,$fn=6);        
                translate([-5,-M3_nut_d/2,0])
                    cube([5,M3_nut_d,M3_nut_h]);        
            }
        }

        //cable holes
        translate([-holder_cylinder_d/2,0,holder_base_h-3+1])
            cylinder(h=holder_cylinder_h+4,r=3);
        translate([-holder_cylinder_d/2+3,0,holder_base_h-3])
        rotate([0,-90,0])        
            cylinder(h=holder_base_w/2,r=3);
           

        //holes
        holes_w=15.24;
        for(dx=[-1,1])
        for(dy=[-1,1])
        translate([dx*holes_w/2,dy*holes_w/2,0]){
            translate([0,0,-1])
                cylinder(h=holder_base_h+2,d=3.2+play);
            translate([0,0,holder_base_h/2-M3_nut_h/2]){
                rotate([0,0,30])
                    cylinder(h=M3_nut_h,r=M3_nut_d/2,$fn=6);        
                translate([holder_base_w*(dx-1)/2,-M3_nut_d/2,0])
                    cube([holder_base_w,M3_nut_d,M3_nut_h]);        
            }
        }

    }
}
module holder2(){
  difference(){
     cylinder(h=6,d=27);
      
     translate([0,0,-1])
        cylinder(h=8+2,d=holder_cylinder_d+play);
    for(r=[-90,30,150])
    rotate([0,0,r+90])        
    translate([0,0,3])
    rotate([0,90,0])      
        translate([0,0,0])
            cylinder(h=holder_base_h+holder_cylinder_h+2,d=3.2+play);
  }
}
module holder3(){
  difference(){
     cylinder(h=2,d=27);
      
    translate([0,0,-1])
        cylinder(h=2+2,d=holder_cylinder_d+play);


  }
}

holder();
//holder1();
//holder2();
//holder3();