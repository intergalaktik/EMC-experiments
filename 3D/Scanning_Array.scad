for ( i=[0:6:100]) {
for ( j=[0:6:50]) {
    translate([i,j,0])
    cylinder(h=0.3,d=5, center=true);
    //cube(5,center=true);
}}

