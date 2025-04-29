$fn = $preview ? 8 : 16;

// inner radius of each loop, ie slightly less than the radius of the brush handles
// probably not suitable to large brushes 
loops = [2, 3, 3, 4, 4, 5];
// number of rows
rows = 3;
// height of the loops above the ground
height = 80;

// SET TO FALSE TO RENDER INDIVIDUAL PARTS
renderLoops = true;
renderLeftLegs = true;
renderRightLegs = true;

JOIN_DEPTH = 8;
LOOP_WALL_THICKNESS = 3;
LOOP_HEIGHT = 8;
LOOPS_WIDTH = 2 * (sumTo(loops, len(loops) - 1) + len(loops) * LOOP_WALL_THICKNESS);

BOT_PLATE_THICKNESS = 2;

LEG_BOT_DEPTH = 10;
LEG_TOP_DEPTH = 6;

BEVEL_R = 2;

LEG_PROTRUDE = 3;
LEG_LOOP_R = 5;
LEG_LOOP_DEPTH_RATIO = 1.2;
LEG_LOOP_HEIGHT = LOOP_HEIGHT - LEG_PROTRUDE;
LEG_LOOP_X = LOOPS_WIDTH / 2 + LEG_LOOP_R - LOOP_WALL_THICKNESS;

ROW_DEPTH = 2 * (max(loops) + LOOP_WALL_THICKNESS);
ROW_Y = (max(max(loops) + LOOP_WALL_THICKNESS, LEG_BOT_DEPTH + 2 * BEVEL_R) + ROW_DEPTH) / 2;

module Leg (orientation = 0) {
  mirrorVector = orientation == 1 ? [0, 0, 0] : [1, 0, 0];
  tabHeight = 4 * BEVEL_R;
  mirror(mirrorVector) {
    hull() {
      translate([0, -LEG_TOP_DEPTH / 2 + BEVEL_R, height - BEVEL_R])
        sphere(BEVEL_R);
      translate([0, LEG_TOP_DEPTH / 2 - BEVEL_R, height - BEVEL_R])
        sphere(BEVEL_R);
      translate([0, -LEG_BOT_DEPTH / 2, BEVEL_R])
        sphere(BEVEL_R);
      translate([0, LEG_BOT_DEPTH / 2, BEVEL_R])
        sphere(BEVEL_R);
      translate([LEG_LOOP_R, -LEG_BOT_DEPTH / 2, BEVEL_R])
        sphere(BEVEL_R);
      translate([LEG_LOOP_R, LEG_BOT_DEPTH / 2, BEVEL_R])
        sphere(BEVEL_R);
    }
    hull() {
      translate([0, -BEVEL_R, BEVEL_R])
        sphere(BEVEL_R);
      translate([0, BEVEL_R, BEVEL_R])
        sphere(BEVEL_R);
      translate([0, -BEVEL_R, tabHeight - BEVEL_R])
        sphere(BEVEL_R);
      translate([0, BEVEL_R, tabHeight - BEVEL_R])
        sphere(BEVEL_R);
      translate([-LEG_LOOP_R * 1.5, -BEVEL_R, BEVEL_R])
        sphere(BEVEL_R);
      translate([-LEG_LOOP_R * 1.5, BEVEL_R, BEVEL_R])
        sphere(BEVEL_R);
    }
    hull() {
      translate([0, -(LEG_BOT_DEPTH + ROW_DEPTH) / 2, BEVEL_R])
        sphere(BEVEL_R);
      translate([0, (LEG_BOT_DEPTH + ROW_DEPTH) / 2, BEVEL_R])
        sphere(BEVEL_R);
      translate([0, -(LEG_BOT_DEPTH + ROW_DEPTH) / 2, 3 * BEVEL_R])
        sphere(BEVEL_R);
      translate([0, (LEG_BOT_DEPTH + ROW_DEPTH) / 2, 3 * BEVEL_R])
        sphere(BEVEL_R);
      translate([LEG_LOOP_R, -(LEG_BOT_DEPTH + ROW_DEPTH) / 2, BEVEL_R])
        sphere(BEVEL_R);
      translate([LEG_LOOP_R, (LEG_BOT_DEPTH + ROW_DEPTH) / 2, BEVEL_R])
        sphere(BEVEL_R);
    }
  }
}

module Loop (innerRadius, orientation = 0) {
  y = (orientation == 0 ? -1 : 1) * (innerRadius + LOOP_WALL_THICKNESS);
  difference() {
    union() {
    cylinder(r = innerRadius + LOOP_WALL_THICKNESS, h = LOOP_HEIGHT, center = true);
     cube([2 * (innerRadius + LOOP_WALL_THICKNESS), JOIN_DEPTH, LOOP_HEIGHT], true);
    }
    cylinder(r = innerRadius, h = LOOP_HEIGHT + 1, center = true);
    translate([0, y, 0])
      cube([1.4 * innerRadius, innerRadius + 2 * LOOP_WALL_THICKNESS, LOOP_HEIGHT + 1], true);
  }
};

module LegLoop (orientation = 0) {
  scale([1, LEG_LOOP_DEPTH_RATIO, 1])
    cylinder(r = LEG_LOOP_R, h = LEG_LOOP_HEIGHT, center = true);
};

function sumTo(list, end, index = 0, accum = 0) =
  (index < len(list) && index < end + 1) ?
    sumTo(list, end, index + 1, accum + list[index]) :
    accum;

// LOOPS
if (renderLoops) {
  for(r = [ 0 : 1 : rows -1]) {
    translate([0, 1.5 * ROW_DEPTH * r, 0]) {
      mirror([r % 2, 0, 0])
      for(l = [ 0 : 1 : len(loops) - 1]) {
        x = 2 * (sumTo(loops, l - 1) + l * LOOP_WALL_THICKNESS) + loops[l] + LOOP_WALL_THICKNESS;
        translate([x - LOOPS_WIDTH / 2, 0, height - LOOP_HEIGHT / 2])
          Loop(loops[l], l % 2);
      }
      translate([-LEG_LOOP_X, 0, 0])
        difference() {
          translate([0, 0, height - LOOP_HEIGHT + LEG_LOOP_HEIGHT / 2])
            LegLoop();
          Leg();
        }
      translate([LEG_LOOP_X, 0, 0])
        difference() {
          translate([0, 0, height - LOOP_HEIGHT + LEG_LOOP_HEIGHT / 2])
            LegLoop();
          Leg(1);
        }
      }
  }
}

// LEFT LEG(S)
if (renderLeftLegs) {
  for(r = [ 0 : 1 : rows -1]) {
    translate([-LEG_LOOP_X, 1.5 * ROW_DEPTH * r, 0])
      Leg(0);
  }
}

// RIGHT LEG(S)
if (renderRightLegs) {
  for(r = [ 0 : 1 : rows -1]) {
    translate([LEG_LOOP_X, 1.5 * ROW_DEPTH * r, 0])
      Leg(1);
  }
}