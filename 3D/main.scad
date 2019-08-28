include <config.scad>

use <pcb.scad>
use <holder.scad>
use <brush.scad>
use <corner.scad>
use <motor.scad>
use <magnete.scad>

show_all = true;

module dcube(name,d,center=false){
    cube(d,center=center);
    echo("Cube: ",name,d);
}

rotate([0,60,0]){
    rotate([0,0,360*$t]){
    //PCB
        translate([-66/2,-71.2/2,-1.6]) 
            new_board1();
        if(show_all)
        for(i=[[0,66/2],[90,71.1/2],[180,66/2],[270,71.1/2]])
        rotate([0,0,i[0]])
        translate([i[1]+0.1,-22.86/2,-1.6]) 
            new_board2();

        //FPGA
        color("black")
        translate([10,-70/2,0.1])
            cube([18,70,18]);

        holder();

    }

    //Motor
    translate([0,0,10])
    {
    cylinder(h=16,d=5);
    translate([0,0,16])
        cylinder(h=4,d=18);
    translate([0,0,16+4])
        cylinder(h=67,d=42);
    }


    translate([0,0,85]){
        brush1();
        brush2();
    }

    translate([0,0,45])
    rotate([0,180,180]){
        brush1();
        brush2();
    }

    wood_w=370;
    wood_d=9;
    translate([0,0,-10]){
        color(wood)
        {
            translate([-wood_w/2,-wood_w/2,25+46])
                dcube("wood",[wood_w,wood_w,wood_d]);
            if(show_all)
            translate([-wood_w/2,-wood_w/2-wood_d,-20])
                dcube("wood",[wood_w,wood_d,25+20+wood_d+100+46]);
            if(show_all)
            translate([-wood_w/2,+wood_w/2,-20])
                dcube("wood",[wood_w,wood_d,25+20+wood_d+46]);
            if(show_all)
            for(d=[1,-1])
            translate([d*(wood_w+wood_d)/2-wood_d/2,-wood_w/2-wood_d,-20])
                dcube("wood",[wood_d,wood_w+2*wood_d,25+20+wood_d+46]);
        }
        
        if(show_all)
        for(r=[0,90,180,270])
        rotate([0,0,r])
        translate([-wood_w/2,-wood_w/2,-20])
        rotate([90,0,90])
            corner();
        
        for(r=[0,90,180,270])
        rotate([0,0,r])
        translate([0,0,25+46])
        rotate([0,180,0])
            motor();
        for(r=[0,90,180,270])
        rotate([0,0,r])
        translate([0,0,25+46+wood_d])
            motor();
        
        translate([160,0,25+46])
        rotate([0,180,0])
            magnete();        

        if(show_all)
        %color("LightCyan",0.2){
            translate([-wood_w/2-wood_d,-wood_w/2-wood_d,-20-3])
                dcube("glas",[wood_w+wood_d*2,wood_w+wood_d*2,3]);    
        }
    }
}







