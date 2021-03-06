include <config.scad>

use <holder.scad>
use <brush.scad>
use <corner.scad>

show_all = true;
explode = false;

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

module metalcorner(){
    translate([0,-20,0])
    difference(){
        union(){                    
            cube([40,40,2]);
            cube([2,40,40]);
        }
        for(i=[0,-90])
        rotate([0,i,0])
        {
            translate([10,10,-5])
            cylinder(10,d=5);
            translate([30,30,-5])
            cylinder(10,d=5);
        }
   }
}

union(){
    rotate([0,0,360*$t]){
    //PCB
        color("Black")
        translate([-100/2,-100/2,-1.6]) 
            cube([100,100,1.6]);
        for(i=[[0,66/2],[90,71.1/2],[180,66/2],[270,71.1/2]])
        color("Black")
        rotate([0,0,i[0]])
        translate([-12/2,10,-3-5]) 
            cube([12,230,3]);

        holder();

    }

    //Motor
    translate([0,0,27])
    {
        cylinder(h=16,d=5);
        translate([0,0,16])
            cylinder(h=4,d=18);
        translate([0,0,16+4])
            cylinder(h=80,d=45);
    }
    //brush holder
    translate([0,-51,44]){
        rotate([180,0,180])
        brush();
    }
    //brackets
    color("Black")
    for(i=[0,-51])
    translate([0,i,44]){
        translate([-36,-50/2,0])
            cube([52,50,3]);
        translate([-36,-50/2,0])
            cube([3,50,60]);
    }
    
    //PCB Motor
    color("Green")
    translate([12,-225+70,80]){
        translate([-36,-50/2,0])
            cube([1.6,78,44]);
    }
    

    wood_w=500;
    wood_h=160;
    wood_d=10;
    translate([0,0,-30]){
        color(wood)
        {
            translate([-wood_d-36,-wood_w/2,wood_h-100])
               dcube("wood",[wood_d,wood_w,100]);
            if(show_all)
            translate([-wood_w/2,-wood_w/2,wood_h+(explode?100:0)])
               dcube("wood",[wood_w,wood_w,wood_d]);
            if(show_all)
            for(d=[0,90,180,270])
            rotate(d)
            translate([(wood_w+wood_d)/2-wood_d/2+(explode?30:0),-wood_w/2-wood_d,0])
               dcube("wood",[wood_d,wood_w+wood_d,wood_h+wood_d]);
        }
        
        if(show_all)
        for(r=[0,90,180,270])
        rotate([0,0,r])
        translate([-wood_w/2,-wood_w/2,2])
        rotate([90,0,90])
            corner();
                
        if(show_all)
        %color("LightCyan",0.2){
            translate([-wood_w/2,-wood_w/2,0])
                dcube("glas",[wood_w,wood_w,2]);    
        }
    }
}







