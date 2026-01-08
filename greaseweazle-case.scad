// ------------------------------------

// Model.
model(
    assembled=!true,
    top=true,
    bottom=true,
    pcb=true);

// ------------------------------------

// Convenience zero vector.
zero = [0, 0, 0];

// Wall thickness, bottom and sides.
wall=2;

// Support thickness, back and middle.
support=1;

// Tiny delta to fix `difference()` for aligned geometry.
delta=.01;

// Material to remove for adjacent interlocking geometry.
overlapgap=.01;

// Ledge height above bottom wall.
ledgeheight=2;

// Ledge thickness from side walls.
ledgethick=1;

// PCB without components.
pcbdim=[96, 50.5, 1.8];
pcbpos=[wall, wall, wall+ledgeheight];

// Assembled case.
case=[pcbdim.x+2*wall, pcbdim.y+2*wall, 14.5];
casebottomheight=case.z-wall;

pcbtolidheight=casebottomheight-wall-ledgeheight-pcbdim.z;

// Top/bottom case interlocking rail dimension.
railwidth=1;
railheight=wall+ledgeheight+pcbdim.z+pcbtolidheight/2;
railthickness=sqrt(2)/2;

// USB-C cut-out.
usbcextraheight=pcbtolidheight-3.5;
usbcextraplugclearance=1;
usbcprotrude=1;
usbcdim=[10+2*usbcextraplugclearance, 7.5, 3.5];
usbcdimext=[0, wall, usbcextraheight];
usbcpos=[15.7-usbcextraplugclearance, 44+usbcprotrude, 0];
usbcposext=[0, wall, 0];
usbcabovedim=[usbcdim.x, wall*2, usbcextraheight+delta];
usbcabovepos=[usbcpos.x, pcbdim.y-usbcabovedim.y+wall, pcbtolidheight-usbcabovedim.z+pcbdim.z+delta];

// IDE connector.
ideextraheight=5;
idedim=[50.8, 9, 9]; // Plastic dimensions.
idedimext=[1, wall, ideextraheight];
idepos=[29, -1, 0]; // Relative to PCB.
ideposext=[0, -wall, 0];

// IDE connector pin 1 indicator
idepin1size=4;
idepin1arrow=[[0, 0], [idepin1size, 1], [1, idepin1size]];
idepin1pos=idepos + [43.1+idepin1size*sqrt(2)/2, 15.1, 0];

// Disk drive Berg power connector.
bergextrax=4+delta;
bergextraheight=10;
bergdim=[12, 11-delta, 5]; // Plastic dimensions.
bergdimext=[bergextrax, wall, bergextraheight];
bergpos=[13, 0-wall-delta, 0]; // Relative to PCB.
bergposext=[0,0,0];

// USB 5V enable jumper.
enable5vextraheight=10;
enable5vdim=[16, 6.5, 9];
enable5vdimext=[0, 0, enable5vextraheight];
enable5vpos=[2+delta, 19.5, 0];
enable5vposext=[0, 0, 0];

// Jumper block.
jumpersextraheight=5;
jumperspos=[35, 22, 0];
jumpersposext=[-6, 0, 0];
jumpersdim=[6, 17, 12];
jumpersdimext=[12, 0, jumpersextraheight];

// Power and activity LEDs.
ledsextraheight=10;
ledspos=[38, 41.5, 0];
ledsdim=[6, 8, 1+ledsextraheight];


// ------------------------------------

module model(assembled, top, bottom, pcb) {
    if (assembled) {
        if (bottom) { bottom(); }
        if (top) { top(); }
        if (pcb) { %pcb(); }
    } else {
        // Bottom.
        translate([0, 3, 0])
        union() {
            if (bottom) { bottom(); }
            if (pcb) { %pcb(); }
        }

        // Top, flipped over.
        translate([0, 0, case.z])
        rotate([180, 0, 0])
            if (top) { top(); }
    }
}

module pcb() {
    usbc(false);
    jumpers(false);
    berg(false);
    enable5v(false);
    ide(false);

    // PCB.
    translate(pcbpos)
        cube(pcbdim);
}

module top() {
    difference() {
        top_basic();
        top_subtractions();
    }
    usbcabove();
}

module top_subtractions() {
    ide(ext=true);
    idepin1();
    berg(ext=true);
    enable5v(ext=true);
    jumpers(ext=true);
    leds();
    usbc(ext=true);
    silkscreen();
}

module silkscreen() {
    fontsize=1;
    font="Liberation Mono";

    translate([pcbpos.x, pcbpos.y, case.z-.5])
    linear_extrude(1)
    union() {
        translate(idepin1pos+[0, 5, 0])
        rotate([0, 0, 180])
            text("Pin 1", size=fontsize, font=font, halign="center");

        translate(enable5vpos+enable5vposext+[enable5vdim.x/2 + enable5vdimext.x/2, -1, 0])
        rotate([0, 0, 180])
            text("USB 5V Enable", size=fontsize, font=font, halign="center");

        translate(ledspos+[-1, 6, 0])
        rotate([0, 0, 180])
            text("Power", size=fontsize, font=font);

        translate(ledspos+[-1, 3, 0])
        rotate([0, 0, 180])
            text("Activity", size=fontsize, font=font);

        d=2.7;

        translate(jumperspos+jumpersposext+[-1, -1, 0]) union() {
            translate([0, d*1, 0]) rotate([0, 0, 180])
                text("3.3V", size=fontsize, font=font);
            translate([0, d*2, 0]) rotate([0, 0, 180])
                text("GND", size=fontsize, font=font);
            translate([0, d*3, 0]) rotate([0, 0, 180])
                text("TXO", size=fontsize, font=font);
            translate([0, d*4, 0]) rotate([0, 0, 180])
                text("RXI", size=fontsize, font=font);
            translate([0, d*5, 0]) rotate([0, 0, 180])
                text("SWCLK", size=fontsize, font=font);
            translate([0, d*6, 0]) rotate([0, 0, 180])
                text("SWDIO", size=fontsize, font=font);
        }

        translate(jumperspos+jumpersposext+[jumpersdim.x+jumpersdimext.x, 0, 0]+[1, -1, 0]) union() {
            translate([0, d*1, 0]) rotate([0, 0, 180])
                text("DFU", size=fontsize, font=font, halign="right");
            translate([0, d*2, 0]) rotate([0, 0, 180])
                text("GND", size=fontsize, font=font, halign="right");
            translate([0, d*3, 0]) rotate([0, 0, 180])
                text("RESET", size=fontsize, font=font, halign="right");
            translate([0, d*4, 0]) rotate([0, 0, 180])
                text("WRITE- [", size=fontsize, font=font, halign="right");
            translate([0, d*5, 0]) rotate([0, 0, 180])
                text("ENABLE [", size=fontsize, font=font, halign="right");
            translate([0, d*6, 0]) rotate([0, 0, 180])
                text("5V", size=fontsize, font=font, halign="right");
        }

        translate(bergpos+bergposext+[bergdim.x/2+bergdimext.x/2, bergdim.y+bergdimext.y, 0]+[-5, 1, 0])
        union() {
            translate([10-d*1,0,0]) rotate([0, 0, 90])
               text("+5V", size=fontsize, font=font);
            translate([10-d*2,0,0]) rotate([0, 0, 90])
               text("GND", size=fontsize, font=font);
            translate([10-d*3,0,0]) rotate([0, 0, 90])
               text("GND", size=fontsize, font=font);
            translate([10-d*4,0,0]) rotate([0, 0, 90])
               text("NC", size=fontsize, font=font);
        }
    }
}

module enable5v(ext) {
    translate(pcbpos)
    translate(enable5vpos)
    translate(ext ? enable5vposext : zero)
        cube(enable5vdim + (ext ? enable5vdimext : zero));
}

module jumpers(ext) {
    translate(pcbpos)
    translate(jumperspos)
    translate(ext ? jumpersposext : zero)
        cube(jumpersdim + (ext ? jumpersdimext : zero));
}

module leds() {
    translate(pcbpos)
    translate(ledspos)
        cube(ledsdim);
}

module top_basic() {
    top_lid();
    top_sides();
    top_supports();
    rails(backrail=false);
}

module top_sides() {
    // Left.
    translate([wall, wall, case.z-wall-pcbtolidheight])
        top_side();

    // Right.
    translate([case.x-2*wall, wall, case.z-wall-pcbtolidheight])
        top_side();
}

module top_supports() {
    // Back.
    translate([wall, case.y-wall-support-delta, case.z-wall-pcbtolidheight])
        cube([case.x-2*wall, support, pcbtolidheight]);

    // Middle.
    translate([wall, wall+enable5vpos.y-support-delta, case.z-wall-pcbtolidheight])
        cube([case.x-2*wall, support, pcbtolidheight]);
}

module top_side() {
    cube([wall, case.y-2*wall, pcbtolidheight]);   
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
    rails(backrail=true);
    usbc(ext=true);
    ide(ext=true);
    berg(ext=true);
}

module usbc(ext) {
    translate(ext ? usbcposext : zero)
    translate([0, 0, pcbdim.z-delta])
    translate(pcbpos)
    translate(usbcpos)
        cube(usbcdim + (ext ? usbcdimext : zero) + [0, 0, delta]);
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

module ide(ext) {
    translate(pcbpos)
    translate([0, 0, pcbdim.z])
    translate(idepos)
    translate(ext ? ideposext : zero)
        cube(idedim + (ext ? idedimext : zero));
}

module berg(ext) {
    translate(pcbpos)
    translate([0, 0, pcbdim.z])
    translate(bergpos)
    translate(ext ? bergposext : zero)
        cube(bergdim + (ext ? bergdimext : zero));
}

module rails(backrail) {
    // Left.
    translate([wall-railthickness, wall, railheight])
    rotate([0, -45, 0])
        railseed(case.y-2*wall);

    // Right.
    translate([case.x-wall+railthickness, wall, railheight])
    rotate([0, 135, 0])
        railseed(case.y-2*wall);

    // Back.
    if (backrail) {
        translate([wall, case.y-wall+railthickness, railheight])
        rotate([0, 0, -90])
        rotate([0, -45, 0])
            railseed(case.x-2*wall);
    }
}

module railseed(length) {
    rotate([-90, 0, 0])
    linear_extrude(length)
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
