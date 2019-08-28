include <config.scad>

use <pcb.scad>
use <holder.scad>
use <brush.scad>
use <corner.scad>
use <motor.scad>

show_all = true;

// input : list of numbers
// output : sorted list of numbers
function quicksort(arr) = !(len(arr)>0) ? [] : let(
    pivot   = arr[floor(len(arr)/2)],
    lesser  = [ for (y = arr) if (y  < pivot) y ],
    equal   = [ for (y = arr) if (y == pivot) y ],
    greater = [ for (y = arr) if (y  > pivot) y ]
) concat(
    quicksort(lesser), equal, quicksort(greater)
);

module dcube(name,d,center=false){
    cube(d,center=center);
    echo("Cube: ",name,quicksort(d)[2],quicksort(d)[1]);
}

{
    rotate([0,0,360*$t]){
    //PCB
        translate([-66/2,-71.2/2,-1.6]) 
           ;//new_board1();
        if(show_all)
        for(i=[[0,66/2],[90,71.1/2],[180,66/2],[270,71.1/2]])
        rotate([0,0,i[0]])
        translate([i[1]+0.1,-22.86/2,-1.6]) 
            ;//new_board2();

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
        //brush1();
        //brush2();
    }


    wood_w=500;
    wood_h=160;
    wood_d=9;
    translate([0,0,-10]){
        color(wood)
        {
            translate([-wood_d-30,-wood_w/2,wood_h-20-100])
               dcube("wood",[wood_d,wood_w,100]);
            if(show_all)
            translate([-wood_w/2,-wood_w/2,wood_h-20])
               dcube("wood",[wood_w,wood_w,wood_d]);
            if(show_all)
            for(d=[0,90,180,270])
            rotate(d)
            translate([(wood_w+wood_d)/2-wood_d/2,-wood_w/2-wood_d,-20])
               dcube("wood",[wood_d,wood_w+wood_d,wood_h+wood_d]);
        }
        
        if(show_all)
        for(r=[0,90,180,270])
        rotate([0,0,r])
        translate([-wood_w/2,-wood_w/2,-20])
        rotate([90,0,90])
            corner();
                
        if(show_all)
        %color("LightCyan",0.2){
            translate([-wood_w/2-wood_d,-wood_w/2-wood_d,-20-3])
                dcube("glas",[wood_w+wood_d*2,wood_w+wood_d*2,3]);    
        }
    }
}







