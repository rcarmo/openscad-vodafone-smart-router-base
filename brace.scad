
// Very simple brace to mount the rouger flush to the wall.
// This just slots into the top groove.

$fn=50;

module screw_holder() {
translate([-3,4,0])
difference() {
   union() {
      translate([0,-4,0])
        cube([4,8,3]);
      cylinder(3, 4, 4);
   }
   cylinder(3, 2, 2);
}
}


for(y = [0, 80])
  translate([0,y,0])
    screw_holder();
cube([4,88,1]);