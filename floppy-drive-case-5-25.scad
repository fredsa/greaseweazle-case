delta = 0.01;

wall = 3;

// TEAC FD-55GFR 5.25" floppy disk drive.
teac_h = 41.5 + 1.5 /* additional clearance: */;

teac_w = 146; // At side screw mounts.
teac_w_lip = 149; // At front lip.

teac_d_trunk = 100;
teac_d = 208 + teac_d_trunk;
teac_d_lip = 5; // Depth of lip.
teac_d_lip_neg = .5; // Stick out in front of drive.

teac_holes_front_d = 52.5; // From front face.
teac_holes_rear_d = 131.5; // From front face.
teac_holes_mid_d = (teac_holes_front_d + teac_holes_rear_d)/2;
teac_holes_bottom_h = 10; // From bottom face.
teac_holes_top_h = 22; // From bottom face.
teac_holes_center_h = (teac_holes_top_h + teac_holes_bottom_h)/2;

teac_screw_d = 3; // M3.
teac_screw_l = 5; // Length.

teac_screw_head_d = 5;
teac_screw_head_l = 1;

rail_w = 4;
rail_l = 40;
rail_h = 5;

// Material to remove for adjacent interlocking geometry.
rail_overlapgap=.1;

module hole(body_w, d, h) {
    $fn=20; 
    // Left.
    translate([-wall-delta, d, h])
    rotate([0,90,0])
        union() {
            cylinder(teac_screw_l+wall, teac_screw_d/2, teac_screw_d/2);
            cylinder(teac_screw_head_l, teac_screw_head_d/2, teac_screw_head_d/2);
        }

    // Right.
    translate([teac_w+wall+delta, d, h])
    rotate([0,-90,0])
        union() {
            cylinder(teac_screw_l+wall, teac_screw_d/2, teac_screw_d/2);
            cylinder(teac_screw_head_l, teac_screw_head_d/2, teac_screw_head_d/2);
        }
}

module drive() {
    translate([wall, 0, wall])
    union() {
        // Main body.
        cube([teac_w, teac_d, teac_h]);
        
        // Front lip.
        translate([-(teac_w_lip-teac_w)/2, -teac_d_lip_neg, 0])
            cube([teac_w_lip, teac_d_lip+teac_d_lip_neg, teac_h]);
    }
}

module drive_remove() {
    translate([wall, -delta, wall])
    union() {
        // Remove.
        hole(teac_w, teac_holes_front_d,teac_holes_bottom_h);
        hole(teac_w, teac_holes_front_d,teac_holes_top_h);
        hole(teac_w, teac_holes_rear_d,teac_holes_bottom_h);
        hole(teac_w, teac_holes_rear_d,teac_holes_top_h);
        
        // (Incorrectly positioned) front slot.
        translate([5, -delta, (teac_h-5)/2])
            cube([teac_w-10, teac_d-10, 5]);
    }
}

module rails(w, h) {
    // Left rail.
    translate([wall-delta,teac_d-rail_l-delta,wall+teac_holes_center_h-h])
    cube([w+delta,rail_l+2*delta,h]);

    // Right rail.
    translate([wall+teac_w-rail_w,teac_d-rail_l-delta,wall+teac_holes_center_h-h])
    cube([w+delta,rail_l+2*delta,h]);
}

module rail_holders() {
    difference() {
        union() {
            // Left rail.
            translate([wall,teac_d-rail_l,wall+teac_holes_center_h-2*rail_h])
            cube([wall+rail_w,rail_l,4*rail_h]);

            // Right rail.
            translate([teac_w-rail_w,teac_d-rail_l,wall+teac_holes_center_h-2*rail_h])
            cube([wall+rail_w,rail_l,4*rail_h]);
        }

        rails(rail_w+rail_overlapgap, rail_h+rail_overlapgap);
    }
}

module case(front,opentop) {
    difference() {
        // Outer body.
        cube([teac_w, teac_d, teac_h] + [2*wall, wall, 2*wall]);

        // Remove.
        union() {
            drive();
            drive_remove();
            if (opentop) {
                translate([wall,teac_d-teac_d_trunk-delta,wall+teac_h-delta])
                cube([teac_w,teac_d_trunk+delta,wall+2*delta]);
            }
            if (front) {
                translate([-delta, teac_holes_mid_d, 0-delta])
                    cube([
                        teac_w+2*wall+2*delta,
                        teac_d-teac_holes_mid_d+wall+delta,
                        teac_h+2*wall+2*delta
                    ]);
            } else {
                translate([-delta, -delta, 0-delta])
                    cube([
                        teac_w+2*wall+2*delta,
                        teac_holes_mid_d+delta,
                        teac_h+2*wall+2*delta
                    ]);
            }
        }
    }
}

module top(front,opentop) {
    difference() {
        case(front,opentop);

        // Remove bottom of case;
        translate([-delta, -delta, -delta])
            cube([teac_w, teac_d, teac_holes_center_h]
                + [2*wall+2*delta, wall+2*delta, wall]);
    }

    rail_holders();
    if (opentop) {
        translate([0,0,teac_h-teac_holes_center_h+wall])
        rails(rail_w, rail_h);
    }
}

module bottom(front) {
    difference() {
        case(front,opentop);

        // Remove top of case;
        translate([-delta, -delta, wall+teac_holes_center_h-delta])
            cube([teac_w, teac_d, teac_h-teac_holes_center_h]
                + [2*wall+2*delta, wall+2*delta, wall+2*delta]);
    }

    rails(rail_w, rail_h);
}

module everything(print, front, print_top, print_bottom, opentop) {
    separation = 10;
    
    if (print) {
        if (print_top) {
            translate([separation/2, 0, 0 ])
            translate([0, 0, teac_h+2*wall])
            rotate([0, -180, -90])
            union() {
                top(front,opentop);
                //%drive();
            }
        }

        if (print_bottom) {
            translate([-separation/2, 0, 0])
            rotate([0, 0, 90])
            union() {
                bottom(front,opentop);
                //%drive();
            }
        }
    } else {
        case(front,opentop);
    }
}

everything(print=true, front=!true, print_top=true, print_bottom=!true, opentop=true);
