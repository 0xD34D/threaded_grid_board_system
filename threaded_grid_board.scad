// Cell size in mm
cell_size = 25;
// Number of columns
num_columns = 3;
// Number of rows
num_rows = 2;
// Board height / thickness in mm
board_height = 6;
// Cell divider width in mm
divider_width = 1;
// Cell divider depth in mm
divider_depth = 1;

// Height of the threads
thread_height	  				    = board_height;	
// Outer diameter of the bolt thread to match (usually set about 1mm larger than bolt diameter to allow easy fit - adjust to personal preferences) 
thread_diameter     	= 10;		
// Thread step or Pitch (2mm works well for most applications ref. ISO262: M3=0.5,M4=0.7,M5=0.8,M6=1,M8=1.25,M10=1.5)
thread_step    				= 2;
//Step shape degrees (45 degrees is optimised for most printers ref. ISO262: 30 degrees)
thread_step_shape_degrees 			= 45;	
//Resolution (lower values for higher resolution, but may slow rendering)
thread_resolution                  = 0.99;

board(cell_size, num_columns, num_rows);

module base_block(cell_size, columns, rows) {
    cube([columns * cell_size, rows * cell_size, board_height]);
}

module thread_hole() {
    union() {
        hex_countersink_ends(thread_step/2,thread_diameter,thread_step_shape_degrees,thread_resolution,thread_height);
        screw_thread(thread_diameter,thread_step,thread_step_shape_degrees,thread_height,thread_resolution,-2);
    }
}

module board(cell_size, columns, rows) {
    board_width = cell_size * columns;
    board_length = cell_size * rows;
    difference() {
        base_block(cell_size, columns, rows);
        for ( y = [0 : rows-1] ) {
            for ( x = [0 : columns-1] ) {
                translate([x * cell_size + cell_size/2, y * cell_size + cell_size/2, 0]) {
                    thread_hole();
                }
            }
        }
        for ( x = [0 : columns] ) {
            translate([x * cell_size, board_length / 2, board_height - divider_depth/2]) {
                cube([divider_width, board_length, divider_depth], center=true);
            }
        }
        for ( y = [0 : rows] ) {
            translate([board_width / 2, y * cell_size, board_height - divider_depth/2]) {
                cube([board_width, divider_width, divider_depth], center=true);
            }
        }
    }
}


/* Library included below to allow customizer functionality    
 *   
 * polyScrewThread_r1.scad    by aubenc @ Thingiverse
 *
 * Modified by mike_mattala @ Thingiverse 1/1/2017 to remove deprecated assign
 * 
 * This script contains the library modules that can be used to generate
 * threaded rods, screws and nuts.
 *
 * http://www.thingiverse.com/thing:8796
 *
 * CC Public Domain
 */

module thread_shape(cs,lt,or,ir,sn,st)
{
    if ( cs == 0 )
    {
        cylinder(h=lt, r=or, $fn=sn, center=false);
    }
    else
    {
        union()
        {
            translate([0,0,st/2])
              cylinder(h=lt-st+0.005, r=or, $fn=sn, center=false);

            if ( cs == -1 || cs == 2 )
            {
                cylinder(h=st/2, r1=ir, r2=or, $fn=sn, center=false);
            }
            else
            {
                cylinder(h=st/2, r=or, $fn=sn, center=false);
            }

            translate([0,0,lt-st/2])
            if ( cs == 1 || cs == 2 )
            {
                  cylinder(h=st/2, r1=or, r2=ir, $fn=sn, center=false);
            }
            else
            {
                cylinder(h=st/2, r=or, $fn=sn, center=false);
            }
        }
    }
}

module screw_thread(od,st,lf0,lt,rs,cs)
{
    or=od/2;
    ir=or-st/2*cos(lf0)/sin(lf0);
    pf=2*PI*or;
    sn=floor(pf/rs);
    lfxy=360/sn;
    ttn=round(lt/st+1);
    zt=st/sn;

    intersection()
    {
        if (cs >= -1)
        {
           thread_shape(cs,lt,or,ir,sn,st);
        }

        full_thread(ttn,st,sn,zt,lfxy,or,ir);
    }
}

module hex_screw(od,st,lf0,lt,rs,cs,df,hg,ntl,ntd)
{
    ntr=od/2-(st/2)*cos(lf0)/sin(lf0);

    union()
    {
        hex_head(hg,df);

        translate([0,0,hg])
        if ( ntl == 0 )
        {
            cylinder(h=0.01, r=ntr, center=true);
        }
        else
        {
            if ( ntd == -1 )
            {
                cylinder(h=ntl+0.01, r=ntr, $fn=floor(od*PI/rs), center=false);
            }
            else if ( ntd == 0 )
            {
                union()
                {
                    cylinder(h=ntl-st/2,
                             r=od/2, $fn=floor(od*PI/rs), center=false);

                    translate([0,0,ntl-st/2])
                    cylinder(h=st/2,
                             r1=od/2, r2=ntr, 
                             $fn=floor(od*PI/rs), center=false);
                }
            }
            else
            {
                cylinder(h=ntl, r=ntd/2, $fn=ntd*PI/rs, center=false);
            }
        }

        translate([0,0,ntl+hg]) screw_thread(od,st,lf0,lt,rs,cs);
    }
}

module hex_countersink_ends(chg,cod,clf,crs,hg)
{
    translate([0,0,-0.1])
    cylinder(h=chg+0.01, 
             r1=cod/2, 
             r2=cod/2-(chg+0.1)*cos(clf)/sin(clf),
             $fn=floor(cod*PI/crs), center=false);

    translate([0,0,hg-chg+0.1])
    cylinder(h=chg+0.01, 
             r1=cod/2-(chg+0.1)*cos(clf)/sin(clf),
             r2=cod/2, 
             $fn=floor(cod*PI/crs), center=false);
}

module full_thread(ttn,st,sn,zt,lfxy,or,ir)
{
  if(ir >= 0.2)
  {
    for(i=[0:ttn-1])
    {
        for(j=[0:sn-1])
        {
			pt = [[0,0,i*st-st],
                 [ir*cos(j*lfxy),     ir*sin(j*lfxy),     i*st+j*zt-st       ],
                 [ir*cos((j+1)*lfxy), ir*sin((j+1)*lfxy), i*st+(j+1)*zt-st   ],
				 [0,0,i*st],
                 [or*cos(j*lfxy),     or*sin(j*lfxy),     i*st+j*zt-st/2     ],
                 [or*cos((j+1)*lfxy), or*sin((j+1)*lfxy), i*st+(j+1)*zt-st/2 ],
                 [ir*cos(j*lfxy),     ir*sin(j*lfxy),     i*st+j*zt          ],
                 [ir*cos((j+1)*lfxy), ir*sin((j+1)*lfxy), i*st+(j+1)*zt      ],
                 [0,0,i*st+st]];
               
            polyhedron(points=pt,faces=[[1,0,3],[1,3,6],[6,3,8],[1,6,4], //changed triangles to faces (to be deprecated)
										[0,1,2],[1,4,2],[2,4,5],[5,4,6],[5,6,7],[7,6,8],
										[7,8,3],[0,2,3],[3,2,7],[7,2,5]	]);
        }
    }
  }
  else
  {
    echo("Step Degrees too agresive, the thread will not be made!!");
    echo("Try to increase de value for the degrees and/or...");
    echo(" decrease the pitch value and/or...");
    echo(" increase the outer diameter value.");
  }
}
