$fn=20;
delta = 0.01;
print_separation = 10;

wall = 3;

// TEAC FD-55GFR 5.25" floppy disk drive.
teac_h = 41.5 + 1.5 /* additional clearance above */;

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


// Sony Z/161 3.5" floppy disk drive.
sony_w = 101.6; // 4" at side screw mounts.
sony_w_lip = 102.5; // At front lip.

sony_holes_front_d = 25; // From front face.
sony_holes_middle_d = 85; // From front face.
sony_holes_rear_d = 115; // From front face.

sony_d = 146; // ~5.7"
sony_d_trunk = teac_d-sony_d;
sony_d_lip = 4;

sony_h_below_clearance = 1;
sony_h = sony_h_below_clearance + 25.4; // 1"
sony_holes_h = sony_h_below_clearance + 5; // From bottom face.

// Brass insert https://www.mcmaster.com/94459A260/
brass_insert_l = 4.3; // Installed Length 0.170"
brass_insert_d = 4; // Maximum hole diameter 0.157"

brass_insert_h1 = sony_holes_h; // Bottom hole.
brass_insert_h2 = sony_h+wall-brass_insert_h1; // Top hole.


// Mounting posts.
post_d = 10;
post_w = brass_insert_l + wall;

sony_x=post_d;


screwdriver_shaft_d = 8;

screw_d = 3; // M3.
screw_l = 6; // Length.

screw_head_d = 8.5;
screw_sink_deep = 3.5; // Accomodate 3mm head depth.
screw_sink_shallow = wall-1.5; // Shallow sink.

strip_w = screw_sink_deep+2;
strip_d = 12;
strip_r = 1;

rail_w = 4;
rail_l = 40;
rail_h = 5;

// Material to remove for adjacent interlocking geometry.
rail_overlapgap_w=.3;
rail_overlapgap_h=.6;


module screwdriver_hole(body_w, d, h) {
    // Left.
    translate([-wall-delta,d,h])
    rotate([0,90,0])
        cylinder(wall+2*delta, screwdriver_shaft_d/2, screwdriver_shaft_d/2);

    // Right.
    translate([body_w-delta,d,h])
    rotate([0,90,0])
        cylinder(wall+2*delta, screwdriver_shaft_d/2, screwdriver_shaft_d/2);
}

module screw_left(screw_l, sink_l) {
    translate([-delta,0,0])
    rotate([0,90,0])
        union() {
            if (screw_l>0) {
                cylinder(sink_l+screw_l+2*delta, screw_d/2, screw_d/2);
            }
            cylinder(sink_l+2*delta, screw_head_d/2, screw_head_d/2);
        }
}

module screw_right(screw_l, sink_l) {
    rotate([0,180,0])
    screw_left(screw_l, sink_l);
}

module screws(x1, x2, d, h, screw_l, sink_l) {
    translate([0, d, h])
    union() {
        translate([x1,0,0])
            screw_left(screw_l, sink_l);
        translate([x2,0,0])
            screw_right(screw_l, sink_l);
    }
}

module teac_drive() {
    translate([wall, 0, wall])
    union() {
        // Main body.
        cube([teac_w, teac_d, teac_h]);
        
        // Front lip.
        translate([-(teac_w_lip-teac_w)/2, -teac_d_lip_neg, 0])
            cube([teac_w_lip, teac_d_lip+teac_d_lip_neg, teac_h]);
    }
}

module teac_drive_remove() {
    translate([0, 0, wall])
    union() {        
        screws(0, 2*wall+teac_w, teac_holes_front_d, teac_holes_bottom_h, screw_l, screw_sink_shallow);
        screws(0, 2*wall+teac_w, teac_holes_front_d, teac_holes_top_h, screw_l, screw_sink_shallow);
        screws(0, 2*wall+teac_w, teac_holes_rear_d, teac_holes_bottom_h, screw_l, screw_sink_shallow);
        screws(0, 2*wall+teac_w, teac_holes_rear_d, teac_holes_top_h, screw_l, screw_sink_shallow);
    }

    translate([wall, -delta, wall])
    // (Incorrectly positioned) front slot.
    translate([5, -delta, (teac_h-5)/2])
        cube([teac_w-10, teac_d-10, 5]);
}

module rails(w, h) {
    // Left rail.
    translate([wall-delta,teac_d-rail_l-delta,-h])
        cube([w+delta,rail_l+2*delta,h]);

    // Right rail.
    translate([wall+teac_w-rail_w,teac_d-rail_l-delta,-h])
        cube([w+delta,rail_l+2*delta,h]);
}

module rail_holders(sidemount) {
    difference() {
            translate([0, 0, -2*rail_h])
            union() {
                // Left rail.
                translate([wall, teac_d-rail_l, 0])
                    cube([wall+rail_w+rail_overlapgap_w,rail_l,2*rail_h]);

                // Right rail.
                translate([teac_w-rail_w-rail_overlapgap_w, teac_d-rail_l, 0])
                    cube([wall+rail_w+rail_overlapgap_w,rail_l,2*rail_h]);

                if (sidemount) {
                    // Left rail.
                    translate([wall, teac_d-rail_l, 2*rail_h])
                        cube([wall+rail_w+rail_overlapgap_w,rail_l,2*rail_h]);

                    // Right rail.
                    translate([teac_w-rail_w-rail_overlapgap_w, teac_d-rail_l, 2*rail_h])
                        cube([wall+rail_w+rail_overlapgap_w,rail_l,2*rail_h]);

                }
            }

            // Remove.
            rails(rail_w+rail_overlapgap_w, rail_h+rail_overlapgap_h);
    }
}

module teac_rail_holders() {
    translate([0, 0, wall+teac_holes_center_h])
        rail_holders(sidemount=true);
}

module teac_case(render_front, render_rear, opentop) {
    difference() {
        // Outer body.
        cube([teac_w, teac_d, teac_h] + [2*wall, wall, 2*wall]);

        // Remove.
        union() {
            teac_drive();
            teac_drive_remove();
            if (opentop) {
                translate([wall,teac_d-teac_d_trunk-delta,wall+teac_h-delta])
                cube([teac_w,teac_d_trunk+delta,wall+2*delta]);
            }
            if (!render_rear) {
                translate([-delta, teac_holes_mid_d, 0-delta])
                    cube([
                        teac_w+2*wall+2*delta,
                        teac_d-teac_holes_mid_d+wall+delta,
                        teac_h+2*wall+2*delta
                    ]);
            }
            if (!render_front) {
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

module teac_top(render_front, render_rear, opentop) {
    difference() {
        teac_case(render_front, render_rear, opentop);

        // Remove bottom of case;
        translate([-delta, -delta, -delta])
            cube([teac_w, teac_d, teac_holes_center_h]
                + [2*wall+2*delta, wall+2*delta, wall]);
    }

    if (render_rear) {
        teac_rail_holders();
        if (opentop) {
            translate([0,0,2*wall+teac_h])
                rails(rail_w, rail_h);
        }
    }
}

module teac_bottom(render_front, render_rear, opentop) {
    difference() {
        teac_case(render_front, render_rear, opentop);

        // Remove top of case;
        translate([-delta, -delta, wall+teac_holes_center_h-delta])
            cube([teac_w, teac_d, teac_h-teac_holes_center_h]
                + [2*wall+2*delta, wall+2*delta, wall+2*delta]);
    }

    translate([0, 0, wall+teac_holes_center_h])
    rails(rail_w, rail_h);
}

module teac_everything(
        print,
        render_front, render_rear,
        render_top, render_bottom,
        opentop, explode_d
) {    
    if (print) {
        if (render_top) {
            translate([print_separation/2, 0, 0 ])
            translate([0, 0, teac_h+2*wall])
            rotate([0, -180, -90])
            union() {
                teac_top(render_front, false, opentop);
                translate([0, explode_d, 0])
                    teac_top(false, render_rear, opentop);
            }
        }

        if (render_bottom) {
            translate([-print_separation/2, 0, 0])
            rotate([0, 0, 90])
            union() {
                teac_bottom(render_front, false, opentop);
                translate([0, explode_d, 0])
                    teac_bottom(false, render_rear, opentop);
            }
        }
    } else {
        if (render_top) {
            translate([0, 0, explode_d])
                teac_top(render_front, false, opentop);
            translate([0, explode_d, explode_d])
                teac_top(false, render_rear, opentop);
        }
        if (render_bottom) {
            teac_bottom(render_front, false, opentop);
            translate([0, explode_d, 0])
                teac_bottom(false, render_rear, opentop);
        }
    }
}

module sony_drive_remove(opentop) {
    // Mounting screw holes.
    translate([sony_x, 0, 0])
        union() {
            screws(0, 2*wall+sony_w, sony_holes_front_d, sony_holes_h, screw_l, screw_sink_shallow);
            screws(0, 2*wall+sony_w, sony_holes_middle_d, sony_holes_h, screw_l, screw_sink_shallow);
            screws(0, 2*wall+sony_w, sony_holes_rear_d, sony_holes_h, screw_l, screw_sink_shallow);
        }

    // Screwdriver access.
    screws(0, 2*wall+teac_w, sony_holes_front_d, sony_holes_h, 0, wall);
    screws(0, 2*wall+teac_w, sony_holes_middle_d, sony_holes_h, 0, wall);
    screws(0, 2*wall+teac_w, sony_holes_rear_d, sony_holes_h, 0, wall);

    translate([wall, 0, 0])
    union() {
        // Drive + trunk.
        translate([sony_x, -delta, -delta])
            cube([sony_w, sony_d+2*delta, sony_h+2*delta]);

        // Front lip.
        translate([sony_x-(sony_w_lip-sony_w)/2, 0, 0])
            cube([sony_w_lip, sony_d_lip, sony_h+delta]);

        if (opentop) {
            translate([0,teac_d-sony_d_trunk-delta,sony_h-delta])
                cube([teac_w,sony_d_trunk+delta,wall+2*delta]);
        }
    }
}

module sony_case_plain(opentop) {
    difference() {
        union() {
            // Sony case.
            translate([sony_x, 0, 0])
                cube([2*wall+sony_w, sony_d, sony_h-delta]);

            // Left side.
            cube([wall, teac_d+wall, sony_h-delta]);

            // Right side.
            translate([wall+teac_w, 0, 0])
                cube([wall, teac_d+wall, sony_h-delta]);

            // Rear wall.
            translate([0, teac_d, 0])
                cube([2*wall+teac_w, wall, sony_h-delta]);
            
            // Top.
            translate([0, 0, sony_h])
                cube([2*wall+teac_w, teac_d+wall, wall]);
        }        

        // Remove.
        sony_drive_remove(opentop);
    }

    // Rails.
    translate([0, 0, sony_h+wall])
        rails(rail_w, rail_h);

    // Rail holders.
    rail_holders(sidemount=true);
}

module sony_attachment_post(d) {
    // Left inner attachment post.
    translate([wall, d-post_d/2, 0])
        cube([post_w, post_d, sony_h]);

    // Right inner attachment post.
    translate([wall+teac_w-post_w, d-post_d/2, 0])
        cube([post_w, post_d, sony_h]);
}

module sony_brass_inserts(d, h) {
    // Left.
    translate([-delta, d, h])
    rotate([0,90,0])
        cylinder(brass_insert_l+delta, brass_insert_d/2, brass_insert_d/2);

    // Right.
    translate([2*wall+teac_w-brass_insert_l, d, h])
    rotate([0,90,0])
        cylinder(brass_insert_l+delta, brass_insert_d/2, brass_insert_d/2);
}

module sony_case(opentop) {
    difference() {
        union() {
            sony_case_plain(opentop);
            sony_attachment_post(teac_holes_rear_d);
        }

        // Brass inserts.
        sony_brass_inserts(teac_holes_rear_d, brass_insert_h1);
        sony_brass_inserts(teac_holes_rear_d, brass_insert_h2);
    }
}

module _sony_everything(print, render_front, render_rear, opentop) {
    difference() {
        sony_case(opentop);

        // Remove.
        translate([0,0,-3*rail_h])
        union() {
            if (!render_rear) {
                translate([-delta, teac_holes_mid_d, 0-delta])
                    cube([
                        teac_w+2*wall+2*delta,
                        teac_d-teac_holes_mid_d+wall+delta,
                        teac_h+2*wall+2*delta
                    ]);
            }
            if (!render_front) {
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

module sony_everything(print, render_front, render_rear, opentop, explode_d) {
    if (print) {
        rotate([0,180,90])
        translate([print_separation/2, 0, -sony_h-wall])
        union() {
            _sony_everything(print, render_front, false, opentop);
            translate([0, explode_d, 0])
                _sony_everything(print, false, render_rear, opentop);
        }
    } else {
        translate([0, 0, 2*wall+teac_h])
        union() {
            translate([0, 0, 2*explode_d])
                _sony_everything(print, render_front, false, opentop);
            translate([0, explode_d, 2*explode_d])
                _sony_everything(print, false, render_rear, opentop);
        }
    }
}

module case_lid(print, explode_d) {
    if (print) {
        translate([0, -2*wall-teac_w-print_separation/2, 0])
        rotate([0,180,-90])
        union() {
            translate([0, explode_d, 0])
            translate([0, teac_d-sony_d_trunk-wall, 0])
                cube([2*wall+teac_w, sony_d_trunk+2*wall, wall]);

            rail_holders(sidemount=false);
        }
    } else {
        translate([0, 0, 3*wall+teac_h+sony_h])
        translate([0, explode_d, 3*explode_d])
        union() {
            translate([0, teac_d-sony_d_trunk-wall, 0])
                cube([2*wall+teac_w, sony_d_trunk+2*wall, wall]);

            rail_holders(sidemount=false);
        }
    }
}

module plain_strip(print) {
    minkowski()
    {
        // Base shape.
        translate([2*strip_r,0,strip_r])
            cube([strip_w-2*strip_r, strip_d, 3*wall+teac_h+sony_h-3*strip_r]);

        // Round corners.
        difference() {
            rotate([-90,0,0])
                cylinder(r=strip_r,h=1);
            translate([0,-delta,-strip_r-delta])
                cube([strip_r,1+2*delta,2*strip_r+2*delta]);
        }
        difference()
        {
            rotate([0,0,90])
                cylinder(r=strip_r,h=1);
            translate([0,-strip_r-delta,-delta])
                cube([strip_r,2*strip_r+2*delta,1+2*delta]);
        }
    }
}

module strip(print) {
    difference() {
        plain_strip(print);
        
        // Remove screws.
        translate([0, strip_d/2, wall+teac_holes_bottom_h])
            screw_left(screw_l, screw_sink_deep);
        translate([0, strip_d/2, wall+teac_holes_top_h])
            screw_left(screw_l, screw_sink_deep);
        translate([0, strip_d/2, 2*wall+teac_h+brass_insert_h1])
            screw_left(screw_l, screw_sink_deep);
        translate([0, strip_d/2, 2*wall+teac_h+brass_insert_h2])
            screw_left(screw_l, screw_sink_deep);
    }
}

module case_strips(print, explode_d) {
    if (print) {
        //Left.
        translate([print_separation, -strip_d-print_separation, strip_w])
        rotate([0, 90, 0])
            strip(false);

        //Right.
        translate([print_separation, -2*strip_d-2*print_separation, strip_w])
        rotate([0, 90, 0])
            strip(false);

    } else {
        translate([0, explode_d, explode_d])
        union() {
            //Left.
            translate([-strip_w-explode_d,teac_holes_rear_d-strip_d/2,0])
                strip(false);

            // Right.
            translate([2*wall+teac_w+explode_d,teac_holes_rear_d-strip_d/2,0])
            translate([strip_w, strip_d, 0])
            rotate([0,0,180])
                strip(false);
        }
    }
}

print=!true;
opentop=true;
teac=true;
sony=true;
lid=true;
strips=true;
render_front=true;
render_rear=true;
render_top=true;
render_bottom=true;

explode_d=15;


if (teac) {
    teac_everything(
        print,
        render_front, render_rear,
        render_top, render_bottom,
        opentop, explode_d
    );
}

if (sony) {
    sony_everything(print, render_front, render_rear, opentop, explode_d);
}

if (lid) {
    case_lid(print, explode_d);
}

if (strips) {
    case_strips(print, explode_d);
}