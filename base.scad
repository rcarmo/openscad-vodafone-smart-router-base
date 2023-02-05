use <voronoi_polygon.scad>

// overall dimensions
small_diameter = 19;
large_diameter = 34.7;
small_radius = small_diameter / 2;
large_radius = large_diameter / 2;
full_length = 180;
mid_diameter = 31.3;
mid_radius = mid_diameter / 2;
l1 = 107;
w1 = 26.5;
wt = 2.5;
wh = 7.4;     // height of vent part
wh_plus = 18; // upper height of fromt cut
ext_thickness = 3;
$fn = 100;

// narrow end screw and cylinder
module narrow_end()
{
    difference()
    {
        union()
        {
            // foot
            cylinder(2.8, small_radius, small_radius, $fn = 50);
            // screw
            cylinder(10.25, 12.7 / 2, 12.7 / 2, $fn = 50);
        }
        translate([ 0, 0, -0.1 ]) union()
        {
            cylinder(7, 7 / 2, 7 / 2, $fn = 20);
            cylinder(20, 3 / 2, 3 / 2, $fn = 20);
        }
    }
}

module vent()
{
    union()
    {
        // Vent slats
        translate([ 0, 0, 0 ]) difference()
        {

            // stretched voronoi
            *linear_extrude(1.2)
                voronoi_polygon([ [ -small_radius, 0 ], [ small_radius, 0 ], [ w1 / 2, l1 ], [ -w1 / 2, l1 ] ],
                                n = 55.1, thickness = 1.5, round = 2, edging = 2, seed = 42);
            // clipped voronoi
            intersection()
            {
                linear_extrude(2)
                    polygon([ [ -small_radius, 0 ], [ small_radius, 0 ], [ w1 / 2, l1 ], [ -w1 / 2, l1 ] ]);
                linear_extrude(1.2) voronoi_polygon([ [ -l1 / 2, 0 ], [ l1 / 2, 0 ], [ l1 / 2, l1 ], [ -l1 / 2, l1 ] ],
                                                    n = 162, thickness = 0.9, round = 0.2, edging = 0, seed = 126);
            }

            // normal vent
            *for (y = [5:4:l1])
            {
                translate([ -12, y, -1 ]) cube([ 24, 2, 4 ]);
            }
            cylinder(7, 7 / 2, 7 / 2, $fn = 20);
            cylinder(20, 3 / 2, 3 / 2, $fn = 20);
        }

        // Vent sides
        difference()
        {
            linear_extrude(wh)
            {
                difference()
                {
                    // outer perimeter
                    polygon([ [ -small_radius, 0 ], [ small_radius, 0 ], [ w1 / 2, l1 + 1 ], [ -w1 / 2, l1 + 1 ] ]);
                    // inner cut
                    polygon([
                        [ -small_radius + wt / 2, 0 ], [ small_radius - wt / 2, 0 ], [ (w1 - wt) / 2, l1 - wt + 1 ],
                        [ (-w1 + wt) / 2, l1 - wt + 1 ]
                    ]);
                }
            }
            // fiber connector slot
            color("red") translate([ -7.5, l1 - 5, 5 ]) cube([ 15, 15, 12 ]);
        }
    }
}

module base_inset()
{
    linear_extrude(3) polygon([
        [ -mid_radius + ext_thickness, l1 ], [ mid_radius - ext_thickness, l1 ],
        [ large_radius - ext_thickness, full_length - large_radius ],
        [ -large_radius + ext_thickness, full_length - large_radius ]
    ]);
    translate([ 0, full_length - large_radius, 0 ]) cylinder(3, large_radius, large_radius);
}

module long_end_carveout()
{
    linear_extrude(wh_plus + 0.1) polygon([
        [ -mid_radius + 3, l1 - 0.1 ], [ mid_radius - 3, l1 - 0.1 ],
        [ large_radius - 3, full_length - large_radius + 0.1 ], [ -large_radius + 3, full_length - large_radius + 0.1 ]
    ]);
}

module top_grid()
{
    difference()
    {
        union()
        {
            translate([ 0, 12, wh_plus - 1.2 ]) linear_extrude(height = 1.2) voronoi_polygon(
                [
                    [ -mid_radius + 2, l1 ], [ mid_radius - 2, l1 ],
                    [ large_radius - 2, full_length - large_radius + 0.5 ],
                    [ -large_radius + 2, full_length - large_radius + 0.5 ]
                ],
                thickness = 1.2, round = 0.5, edging = 0, seed = 45.1);
            translate([ -6, full_length - large_radius - 6, wh_plus - 1.2 ]) cylinder(3.2, 6, 3);
            translate([ -large_radius + 1.5, l1 + 12, wh_plus - 1.2 ]) cube([ large_radius * 2 - 3, 1.5, 1.2 ]);
        }
        translate([ -6, full_length - large_radius - 6, 0 ]) cylinder(22, 3 / 2, 3 / 2);
    }
}

// wide end
module wide_end()
{
    difference()
    {
        translate([ 0, full_length - large_radius, 0 ]) cylinder(wh_plus, large_radius, large_radius);
        // square carveout
        long_end_carveout();

        // round internal carveout
        translate([ 3, full_length - large_radius, 0 ]) cylinder(wh_plus + 0.1, large_radius - 6, large_radius - 6);
        translate([ -3, full_length - large_radius, 0 ]) cylinder(wh_plus + 0.1, large_radius - 6, large_radius - 6);

        // horizontal cylinder for smooth inset
        translate([ -25, full_length + large_radius - ext_thickness - 1.4, 18 ]) rotate([ 0, 90, 0 ])
            cylinder(50, large_radius, large_radius);
        translate([ 0, full_length, 2 ]) fiber_entry_cut();
    }
}

module fiber_entry_cut()
{
    rotate([ 90, 0, 0 ])
    {
        translate([ -3, -3, 0 ]) cube([ 6, 3.5, 30 ]);
        cylinder(30, 3, 3);
    }
}

// Main assembly
module main_assembly()
{
    union()
    {
        top_grid();
        // reinforcement
        color("blue") translate([ -w1 / 2, l1 - 1, 0 ]) cube([ w1, 5, 2 ]);

        // rubber feet plates
        color("blue") for (x = [ -w1 / 2 + 2.5, w1 / 2 - 2.5 ], y = [ -18, 39 ])
            translate([ x, full_length - y - 30, 1 ]) cylinder(2, 5, 5, center = true);

        difference()
        {
            union()
            {
                narrow_end();
                vent();
                base_inset();
                wide_end();
                color("green") linear_extrude(wh_plus) polygon([
                    [ -mid_radius, l1 ], [ mid_radius, l1 ], [ large_radius, full_length - large_radius ],
                    [ -large_radius, full_length - large_radius ]
                ]);
            }
            // internal cylindrical cutout to accomodate fiber entry cut
            translate([ 0, full_length - large_radius - 1, -2 ]) cylinder(wh_plus - 5, large_radius - 3, large_radius - 5);
            translate([ 0, full_length, 3 ]) fiber_entry_cut();
            // vertical wedge for oblique transition
            translate([ -20, 111, 0 ]) rotate([ 90, 0, 90 ]) linear_extrude(40)
                polygon([ [ -4, 0 ], [ 0, wh_plus ], [ -4, wh_plus ] ]);
            // carve out for rectangular part
            translate([ 0, 0, 0 ]) long_end_carveout();
        }
    }
}

color("red") 
  main_assembly();

// sliced version for testing  
*intersection()
{
    main_assembly();
    translate([ 0, 160, 41.8 ]) cube([ 50, 40, 50 ], center = true);
}