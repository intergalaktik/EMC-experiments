include <box.scad>

h_pcb = 0;
holes_raster = [30,17]*2.54; // ulx3s holes raster
holes_d = 3.3; // holes diameter
holder_pin_d = 2.5;
holder_thick = 2.5;
holder_pin_h = 4;
holder_mount_raster = [68,32];
holder_hole_d = 1.8;


emc_box_width = 300;
emc_box_height = 200;
emc_box_depth = 200;
emc_box_thickness = 2.5;
emc_box_finger_width = 20;
emc_box_inner = true;
emc_box_assemble = true;
draw_connector = false;
ulx3s_test = false;
draw_antenna = false;
draw_emc_box = true;

module ulx3s()
{
  color([0,0.7,0])
  difference()
  {
    cube([94,51,1.6],center=true);
    for(i=[-1,1])
      for(j=[-1,1])
        translate([holes_raster[0]/2*i, holes_raster[1]/2*j])
          cylinder(d=holes_d,h=5,$fn=12,center=true);
  }
}


// flange connector
// mouser
// pn-530-142-0701-631-datasheet-CCS-JOHN-142-0701-631
module connector()
{
  baseplate = [0.5,0.5,0.065]*25.4;
  holes_raster = 0.34*25.4;
  // base plate
  translate([0,0,baseplate[2]/2])
  difference()
  {
    cube(baseplate,center=true);
    for(i=[-1,1])
      for(j=[-1,1])
        translate([i,j]*0.5*holes_raster)
          cylinder(d=2.54,h=2,$fn=12,center=true);
  }
  // solder pin
  rotate([180,0,0])
    cylinder(d=0.05*25.4,h=0.2*25.4,$fn=12);
  // connector screw
  cylinder(d=0.312*25.4,h=0.375*25.4,$fn=12);
}

module box_with_holes(){
difference(){
box(width = emc_box_width, height = emc_box_height, depth = emc_box_depth, thickness = emc_box_thickness, finger_width = emc_box_finger_width, inner = emc_box_inner, assemble = emc_box_assemble);
translate([40,100,200])rotate([0,0,0])cylinder(h=20,d=5,$fn=12);
translate([35.5,104.3,200])rotate([0,0,0])cylinder(h=20,d=2,$fn=12);
translate([45,104.3,200])rotate([0,0,0])cylinder(h=20,d=2,$fn=12);
translate([35.5,95.6,200])rotate([0,0,0])cylinder(h=20,d=2,$fn=12);
translate([45,95.6,200])rotate([0,0,0])cylinder(h=20,d=2,$fn=12);       
}
}

if(draw_emc_box){
    box_with_holes();
    }

if(draw_connector){
    color([0.5,0.5,0,0.8])translate([40,100,200+5])rotate([0,0,0])connector();
    }
    
if(ulx3s_test){
    color([0.5,0.5,0,0.8])translate([200,100,50])ulx3s();
    }

if(draw_antenna){
    color([0.5,0.5,0,0.8])translate([40,100,200-35])rotate([0,0,0])cylinder(h=40,d=0.5,$fn=12);    
    }