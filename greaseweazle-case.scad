// Wall thickness, bottom and sides.
wall=2;

// Tiny delta to fix `difference()` for aligned geometry.
delta=.01;

// Material to remove for adjacent interlocking geometry.
overlapgap=.01;

// Ledge height above bottom wall.
ledgeheight=2;

// Ledge thickness from side walls.
ledgethick=1;

// PCB without components.
pcbdim=[95.25, 50, 1.75];
pcbpos=[wall, wall, wall+ledgeheight];

// Assembled case.
case=[pcbdim.x+2*wall, pcbdim.y+2*wall, 14.5];
casebottomheight=case.z-wall;

pcbtolidheight=casebottomheight-wall-ledgeheight-pcbdim.z;

// Top/bottom case interlocking rail dimension.
rail=[1, case.y-2*wall, 2];
railheight=wall+ledgeheight+pcbdim.z+pcbtolidheight/2;
railthickness=sqrt(2)/2;

// USB-C cut-out.
usbcextraheight=pcbtolidheight-3.5;
usbcextraplugclearance=1;
usbcprotrude=1;
usbcdim=[10+2*usbcextraplugclearance, 7.5+wall, 3.5+usbcextraheight];
usbcpos=[15.7-usbcextraplugclearance, usbcprotrude+wall, 0];
usbcabovedim=[usbcdim.x, wall*2, usbcextraheight+delta];
usbcabovepos=[usbcpos.x, pcbdim.y-usbcabovedim.y+wall, pcbtolidheight-usbcabovedim.z+pcbdim.z+delta];

// IDE connector.
ideextraheight=5;
idedim=[50.8, 9+wall, 9+ideextraheight]; // Plastic dimensions.
idepos=[29, -1-wall, 0]; // Relative to PCB.

// IDE connector pin 1 indicator
idepin1size=2;
idepin1arrow=[[0, 0], [idepin1size, 0], [0, idepin1size]];
idepin1pos=idepos + [43.4+idepin1size*sqrt(2)/2, 16, 0];

// Disk drive Berg power connector.
bergextrax=4+delta;
bergextraheight=10;
bergdim=[10+bergextrax, 10+wall-delta, 5+bergextraheight]; // Plastic dimensions.
bergpos=[15, 0-wall-delta, 0]; // Relative to PCB.

// USB 5V enable jumper.
usb5venableextraheight=5;
usb5venablepos=[wall+delta, 20, 0];
usb5venabledim=[17-wall, 6, 12+usb5venableextraheight];

// Jumper block.
jumpersextraheight=5;
jumperspos=[29, 23, 0];
jumpersdim=[18, 15, 12+jumpersextraheight];

// Power and activity LEDs.
ledsextraheight=10;
ledspos=[38, 41, 0];
ledsdim=[6, 9, 1+ledsextraheight];


// ------------------------------------

// Model.
model(assembled=false);

module model(assembled) {
    if (assembled) {
        bottom();
        top();
    } else {
        // Top.
        translate([0, 3, 0])
            bottom();

        // Bottom, flipped over.
        translate([0, 0, case.z])
        rotate([180, 0, 0])
            top();
    }
}

module top() {
    difference() {
        top_basic();
        top_subtractions();
    }
}

module top_subtractions() {
    ide();
    idepin1();
    berg();
    usb5venable();
    jumpers();
    leds();
}

module usb5venable() {
    translate(pcbpos)
    translate(usb5venablepos)
        cube(usb5venabledim);
}

module jumpers() {
    translate(pcbpos)
    translate(jumperspos)
        cube(jumpersdim);
}

module leds() {
    translate(pcbpos)
    translate(ledspos)
        cube(ledsdim);
}

module top_sides() {
    // Left.
    translate([wall, wall, case.z-wall-pcbtolidheight])
        top_side();

    // Right.
    translate([case.x-2*wall, wall, case.z-wall-pcbtolidheight])
        top_side();
}

module top_side() {
    cube([wall, case.y-2*wall, pcbtolidheight]);   
}

module top_basic() {
    top_lid();
    top_sides();
    usbcabove();

    // Left rail.
    translate([wall-railthickness, wall, railheight])
    rotate([0, -45, 0])
        railseed();

    // Right rail.
    translate([case.x-2*railthickness, wall, railheight])
    rotate([0, 135, 0])
        railseed();
}

module top_lid() {
    difference() {
        hollowcase();
        // Remove bottom.
        translate([-delta, -delta, -delta])
            cube([case.x + 2*delta,
                  case.y + 2*delta,
                  casebottomheight + 2*delta]);
    }
}

module ledge() {
    // Left.
    translate([wall, wall, wall])
        cube([ledgethick, case.y-2*wall, ledgeheight]);

    // Right.
    translate([case.x-wall-ledgethick, wall, wall])
        cube([ledgethick, case.y-2*wall, ledgeheight]);

    // Front.
    translate([wall, wall, wall])
        cube([case.x-2*wall, ledgethick, ledgeheight]);

    // Back.
    translate([wall, case.y-wall-ledgethick, wall])
        cube([case.x-2*wall, ledgethick, ledgeheight]);
}

module bottom() {
    difference() {
        bottom_basic();
        bottom_subtractions();
    }
    ledge();
}

module bottom_subtractions() {
    rails();
    usbc();
    ide();
    berg();
}

module usbc() {
    translate([0, pcbdim.y-usbcdim.y, pcbdim.z])
    translate(pcbpos)
    translate(usbcpos)
        cube(usbcdim);
}

module usbcabove() {
    translate(pcbpos)
    translate(usbcabovepos)
        cube(usbcabovedim);
}

module idepin1() {
    translate(pcbpos)
    translate(idepin1pos)
    rotate([0,0,45])
        linear_extrude(idedim.z+ideextraheight)
        polygon(points=idepin1arrow);
}

module ide() {
    translate(pcbpos)
    translate(idepos)
        cube(idedim);
}

module berg() {
    translate(pcbpos)
    translate(bergpos)
        cube(bergdim);
}

module rails() {
    // Left.
    translate([wall-railthickness, wall, railheight])
    rotate([0, -45, 0])
        railseed();

    // Right;
    translate([case.x-wall+railthickness, wall, railheight])
    rotate([0, 135, 0])
        railseed();
}

module railseed() {
    rotate([-90, 0, 0])
    linear_extrude(rail.y)
        offset(overlapgap)
        polygon(points=[[0, 0], [1, 0], [0, 1]]);
}

module bottom_basic() {
    difference() {
        hollowcase();
        // Remove top.
        translate([-delta,
                   -delta,
                   casebottomheight-delta])
            cube([case.x + 2*delta,
                  case.y + 2*delta,
                  case.z - casebottomheight + 2*delta]);
    }
}

module hollowcase() {
  difference() {
    solidcase();
    translate([wall, wall, wall])
      cube([case.x - 2*wall,
            case.y - 2*wall,
            case.z - 2*wall]);
  }
}

module solidcase() {
    cube(case);
}
