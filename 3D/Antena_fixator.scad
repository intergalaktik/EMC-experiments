
$fn=100;

holder_thickness = 1;
holder_diameter = 5.2;

difference(){
cylinder(h=holder_thickness,d=15 , center=true);
translate([0,0,-holder_thickness])cylinder(h=4,d=holder_diameter,center=true);
translate([0,5,-holder_thickness])cube([5,10,5], center=true);    
}