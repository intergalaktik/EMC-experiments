// pyramid for EM noise measurement

dihedral_angle = acos(1/3); // angle between adjacent sides
face_edge_angle = atan(sqrt(2)); // angle between edge and a side

a = 374; // edge length
a_cutoff = 32.3; // corner cut off, leaving this long cut length

side_thick = 2;
translate_overlap = [side_thick,-side_thick*0.6,side_thick/2];
bot_up_the_edge = 2*side_thick; // bot holder move up along the edge for side triangles to overlap bottom triangle

h = a*sqrt(3)/2; // height of one side (triangle)
h_cutoff = a_cutoff*sqrt(3)/2; // height of complete pyramid

hp = a*sqrt(2/3); // height of the pyramid

h_pcb = h * sin(dihedral_angle)/3; // center of the pyramid

holes_raster = [30,17]*2.54; // ulx3s holes raster
holes_d = 3.3; // holes diameter

holder_pin_d = 2.5;
holder_thick = 2.5;
holder_pin_h = 4;
holder_mount_raster = [68,32];
holder_hole_d = 1.8;

side_holder_a = 14; // side of side holder
side_holder_h = 10; // length of side holder
side_holder_screw_dist = 0; // screw distance of side holder, 0 for 2 screws, nonzero for 4 screws
side_holder_screw_d = 1.8;

echo(str("dihedral_angle=",dihedral_angle,"°"));
echo(str("face_edge_angle=",face_edge_angle,"°"));
echo(str("h_pcb=", h_pcb, "mm"));

module tetrahedron(a)
{
  // a is edge length
  cylinder(d1=a*2/sqrt(3), d2=0, h=a*sqrt(2/3), $fn=3);
}


module top_connector_holder()
{
  translate([0,0,hp])
    top_connector_holder_origin();
}

// with connector on a side
// seems not correctly parametrized:
// holes move (while they shouldn't)
// when holder edge is resized
module top_connector_holder_origin()
{
  conn_holder_edge = 37;
  conn_from_vertex = 19;
  conn_translate = conn_from_vertex;
  conn_holder_h = conn_holder_edge*sqrt(2/3); // height of conn holder pyramid base
  vertex_cut_top = 11.6; // cut top relative from vertex
  conn_h = conn_holder_edge*sqrt(2/3)-vertex_cut_top;
  extend_bottom = 0;
  antenna_tube = 50;
  // translate to align vertexes of holder and big pyramid
  translate([0,0,0])
    //rotate([0,0,0])
    {
    difference()
    //union()
    {
      union()
      {
        translate([0,0,-conn_holder_h])
        tetrahedron(conn_holder_edge);
        // bottom antenna holder
        translate([0,0,-25])
        rotate([180,0,180+30])
        cylinder(d=10,h=antenna_tube,$fn=6);
        // GND radials
        for(a=[0,120,240])
        rotate([0,dihedral_angle/2,a+60])
        translate([0,0,-50])
        side_holder(side_holder_a,70,50);
      }
      // cut top flat, print friendly
      if(1)
      translate([0,0,-vertex_cut_top])
          //rotate([0,0,180])
          cylinder(d=conn_holder_edge,h=conn_holder_edge,$fn=3);
      // side screw hole
      if(1)
      for(a=[0,120,240])
        rotate([0,0,a+60])
          rotate([0,dihedral_angle,0]) // rotate to be perpendicular on a side
            translate([29,0,-2])
            cylinder(d=1.8,h=10,$fn=12);
      // holes for connector
      if(1)
      rotate([0,dihedral_angle,180]) // rotate to be perpendicular on a side
      //translate([-4,0,8-4])
      translate([conn_translate,0,-5])
      holes_for_connector();
      // bottom hole for antenna
      translate([0,0,20])
      rotate([180,0,0])
        cylinder(d=3,h=100,$fn=16);
      // holes for wires thru GND radials
      for(a=[0,120,240])
        rotate([0,dihedral_angle/2,a+60])
        translate([7,0,-91])
        cylinder(d=3,h=80,$fn=12);
    }
    }    
}

module top_connector_on_a_side()
{
  conn_holder_edge = 30;
  translate([0,0,hp-conn_holder_edge*sqrt(2/3)])
    rotate([0,0,180])
  rotate([0,dihedral_angle,0]) // rotate to be perpendicular on a side
      translate([-4,0,10])
      connector();
}

module top_connector_holder_v1()
{
  conn_h = 10; // above the base
  conn_holder_edge = 45;
  holes_raster = 0.34*25.4;
  translate([0,0,hp-conn_holder_edge*sqrt(2/3)])
    rotate([0,0,180])
    {
      difference()
      {
        tetrahedron(conn_holder_edge);
        // cut top flat
        translate([0,0,conn_h])
          rotate([0,0,180])
          cylinder(d=conn_holder_edge,h=conn_holder_edge,$fn=3);
        // cut screw holes
        for(i=[-1,1])
          for(j=[-1,1])
            translate([i,j,0]*0.5*holes_raster+[0,0,conn_h])
              cylinder(d=1.8,h=2*6,$fn=12,center=true);
        // cut central hole for antenna
        cylinder(d=5,h=conn_holder_edge*2,$fn=12,center=true);
        // cut side holes for mounting
        for(a=[0,120,240])
        translate([0,0,1])
        rotate([0,dihedral_angle,a])
          cylinder(d=1.8,h=conn_holder_edge,$fn=12);
      }
      if(0)
      translate([0,0,conn_h])
        connector();
    }
}

module bot_connector_holders()
{
  for(a=[0,120,240])
    rotate([0,0,a])
      translate([-h/3,0,0])
         translate([-bot_up_the_edge*cos(-face_edge_angle),0,-bot_up_the_edge*sin(-face_edge_angle)])
         rotate([180,0,0])
         rotate([0,dihedral_angle,0])
           translate([h/3,0,0])
           rotate([0,0,120])
      top_connector_holder();
}

module bot_connector_on_a_side()
{
  conn_holder_edge = 30;
  conn_holder_h = conn_holder_edge * sqrt(3)/2;
  translate([h*2/3-conn_holder_h*2/3,0,0])
    rotate([0,0,180-120])
  rotate([0,dihedral_angle,0]) // rotate to be perpendicular on a side
      rotate([0,0,30])
      translate([-5,4.5,10])
      translate([cos(120),sin(120)]*bot_up_the_edge)
      connector();
}

module bot_connectors()
{
  for(a=[0,120,240])
    rotate([0,0,a])
      bot_connector_on_a_side();
}

module triangle(connectors=0)
{
  side_slide = -side_thick*0.6;
  difference()
  {
    cylinder(d = a*2/sqrt(3), h=side_thick, $fn=3, center=true);
    // cut top edge
    if(connectors > 1.5)
    translate([h*2/3,0,0])
      cube([2*h_cutoff,2*h_cutoff*2/sqrt(3),side_thick+1],center=true);
    // cut bottom edge for connector
    if(connectors > 0.5)
      rotate([0,0,120])
      translate([h*2/3+0.2,0,0])
      cube([2*h_cutoff,2*h_cutoff*2/sqrt(3),side_thick+10],center=true);

    // screw hole for edge holders
    if(connectors > 0.5)
    {
      // top edge central screw
      translate([h*2/3-29,0,0]) // experimental fit
        translate(-translate_overlap)
      cylinder(d=2.5,h=10,$fn=12,center=true);
    // central screw holes for bot edges near
    for(a = [120,240])
    {
      movesign = -a/60+3;
    rotate([0,0,a])
    translate([h*2/3-29,0,0]) // experimental fit
        rotate([0,0,-a])
        translate(-translate_overlap)
      translate(movesign*[sin(a),cos(a)]*bot_up_the_edge)
      cylinder(d=2.5,h=10,$fn=12,center=true);
    }
      hole_pos = [-68.5,31.4]; // experimenal fit match holes at holders
      // screws at GND radials, top edge
      for(i=[-1,1])
      translate([h*2/3+hole_pos[0],hole_pos[1]*i,0]) // experimental fit
        translate(-translate_overlap)
      cylinder(d=2.5,h=10,$fn=12,center=true);

      // screws at middle edges
      for(i=[-1,1])
      translate([h*2/3-165.0,87.2*i,0]) // experimental fit
        translate(-translate_overlap)
      cylinder(d=2.5,h=10,$fn=12,center=true);

      // screws at GND radials, bot edges
      for(a = [120,240])
      {
        movesign = -a/60+3;
        rotate([0,0,a])

      for(i=[-1,1])
        translate([h*2/3+hole_pos[0],hole_pos[1]*i,0]) // experimental fit
        rotate([0,0,-a])
        translate(-translate_overlap)
        translate(movesign*[sin(a),cos(a)]*bot_up_the_edge)
        cylinder(d=2.5,h=10,$fn=12,center=true);
      }
    }

    // connector holes FIXME bottom holes don't fit connector
    if(0)
    translate([h*2/3-19,0,-5]-translate_overlap)
      // edge_cut_for_connector();
      holes_for_connector();
    if(0)
    if(connectors > 1.5)
      rotate([0,0,120])
        translate([h*2/3-19,0,-5]-[-translate_overlap[0],translate_overlap[1],translate_overlap[2]])
          // edge_cut_for_connector();
          holes_for_connector();
  }
}

module pyramid()
{
   // 3 top sides
   for(i=[0,120,240])
     rotate([0,0,i])
       translate([-h/3,0,0])
         rotate([0,-dihedral_angle,0])
           translate([h/3,0,0]+translate_overlap)
             // rotate([0,0,i])
     if(i==0)
     triangle(connectors=2);
     else
     triangle(connectors=1);
}

module edge_cut_for_connector()
{
  cube([20,20,10],center=true);
}

module holes_for_connector()
{
  holes_raster = 0.34*25.4;
  for(i=[-1,1])
    for(j=[-1,1])
      translate([i,j]*holes_raster/2)
        cylinder(d=1.8,h=10,$fn=16);
  translate([0,0,-2])
  cylinder(d=4,h=90,$fn=16);
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

module measurement_rod(l)
{
    rotate([90,0,0])
      cylinder(d=2, h=l, $fn=6, center=true);
}

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

// (side_holder_a, side_holder_h)
module side_holder(thick,length,distance)
{
  // thick=side_holder_a;
  difference()
  {
    linear_extrude(height=length,center=true)
      polygon(points=[
      [0,0],
      [thick*cos(dihedral_angle/2),+thick*sin(dihedral_angle/2)],
      [thick*cos(dihedral_angle/2),-thick*sin(dihedral_angle/2)]
    ] /*paths=[0,1,2]*/);

    // screw holes
    for(i=[-1,1])
      for(j=[-1,1])
      translate([
        thick/2*cos(dihedral_angle/2),
        thick/2*sin(dihedral_angle/2)*j,
        distance/2*i])
        rotate([90,0,(90-face_edge_angle)*j])
        cylinder(d=side_holder_screw_d,h=thick-3,$fn=12,center=true);
  }
}

module side_holders()
{
  for(i=[0,120,240])
  rotate([0,0,i])
  translate([a/sqrt(3),0,0])
    rotate([0,-dihedral_angle/2,0])
    rotate([0,0,180])
    translate([0,0,a/2])
    side_holder(side_holder_a, side_holder_h, side_holder_screw_dist);
}

module ulx3s_holder()
{
    // pins
    for(i=[-1,1])
      for(j=[-1,1])
        translate([holes_raster[0]/2*i, holes_raster[1]/2*j,h_pcb])
          cylinder(d=holder_pin_d,h=holder_pin_h,$fn=12);

    // holder box
    translate([0,0,h_pcb/2])
    difference()
    {
      cube([holes_raster[0]+holder_thick,holes_raster[1]+holder_thick,h_pcb],center=true);
      cube([holes_raster[0]-holder_thick,holes_raster[1]-holder_thick,h_pcb+1],center=true);
      // cable organizer hole
      for(i=[-1,1])
      translate([0,0,h_pcb/4*i])
      rotate([90,0,0])
        cylinder(d=30,h=holes_raster[1]+holder_thick*2,$fn=4,center=true);
    }
    
    // central base mount
    translate([0,0,holder_thick/2])
    difference()
    {
        cube([holes_raster[0]+holder_thick,holes_raster[1]+holder_thick,holder_thick],center=true);
        cylinder(d=holder_hole_d,h=holder_thick+1,$fn=12,center=true);
    }
    
    // holder base mounts
    if(0)
    for(i=[-1,1])
      for(j=[-1,1])
        translate([holder_mount_raster[0]/2*i, holder_mount_raster[1]/2*j,holder_thick/2])
          difference()
          {
            cube([10,10,holder_thick],center=true);
            cylinder(d=holder_hole_d,h=holder_thick+1,$fn=12,center=true);
          }
}


module pcb_under_test()
{
  translate([0,0,h_pcb+1])
  ulx3s();
}

module assembly()
{
if(1)
  pcb_under_test();

if(1)
  color([0.8,0.6,0.2])
  ulx3s_holder();

if(1)
  side_holders();

if(1)
  top_connector_holder();

if(1)
  top_connector_on_a_side();

if(1)
  bot_connector_holders();

if(1)
  bot_connectors();

if(1)
  color([0.9,0.9,0.8,0.4])
  {
    triangle(); // base
    pyramid(); // sides
  }

if(0)
  translate([-h/3,0,0])
  measurement_rod(a);
if(0)
  translate([-h_cutoff/3,0,h*sin(dihedral_angle)-h_cutoff])
    measurement_rod(a_cutoff);
}

if(1)
assembly();

// corner.stl
if(0)
  rotate([180,0,0])
  top_connector_holder_origin();

// side.stl
if(0)
  rotate([0,90,0])
  side_holder(side_holder_a, side_holder_h, side_holder_screw_dist);

// triangle0.dxf 1x bottom triangle
if(0)
  projection()
  triangle(connectors=0);

// triangle1.dxf 1x of 2-connector triangle
if(0)
  projection()
  triangle(connectors=2);

// triangle2.dxf 2x of 1-connector triangles
if(0)
  projection()
  triangle(connectors=1);
