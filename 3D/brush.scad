include <config.scad>

motor_maxd=45;

module brush1()
difference(){
    union(){
        cylinder(h=10,d=motor_maxd+6);
        
        translate([-20/2,-(motor_maxd+20)/2,0])
            cube([20,motor_maxd+20,10]);
        
        translate([-(motor_maxd+20)/2,-20/2,0])
            cube([10,20,20]);

    }

    translate([0,0,-1])
        cylinder(h=10+2,d=motor_maxd);

    translate([-10/2,-(motor_maxd+20)/2-1,-1])
        cube([10,motor_maxd+20+2,10+2]);
    for(d=[1,-1])
    translate([-(20+2)/2,d*(motor_maxd+20-8)/2,+10/2])
    rotate([0,90,0])
        cylinder(h=20+2,d=3+play);

    for(d=[1,-1])
    translate([-motor_maxd/2-10/2,d*10/2,-1])
        cylinder(h=20+2,d=3+play);

    translate([-(motor_maxd+10+3+play)/2,10/2-10,-1])
        cube([3+play,10,20+2]);
}


module brush2()
difference(){
    h=7;
    union(){
        translate([-(motor_maxd+20)/2,-10/2,20])
            cube([20,10,h]);
    }
    for(d=[1,-1])
    translate([-motor_maxd/2+d*10/2,0,20-1])
        cylinder(h=h+2,d=3+play);

    translate([-(motor_maxd+10)/2,-(3+play)/2,20-1])
        cube([10,3+play,h+2]);
    
    translate([-(motor_maxd+20)/2+20-5,0,20+h/2])
    rotate([0,90,0])
    {
        cylinder(h=10,d=3+play);        
        cylinder(h=M3_nut_h,r=M3_nut_d/2,$fn=6);        
        translate([-10,-M3_nut_w/2,0])
            cube([10,M3_nut_w,M3_nut_h]);        
    }
}

brush1();
brush2();