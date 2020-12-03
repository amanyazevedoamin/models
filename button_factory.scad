/* Button Factory*/
//Amany Azevedo Amin 02/12/2020
//v0: facility for round buttons. Rims: rounded or straight. Eyelets: round, 1 to 50. Surfaces: chamfered or flat top and bottom. 

/* [Button Type] */

eyelets=4; // [1:50]
rim_type="round"; //["round","straight"]

/* [Button Dimensions - mm] */

//button diameter
button_radius=6; // [1:200]
button_diameter=button_radius*2;

//button thickness
button_thickness=5; // [1:50]

//eyelet_radius
eyelet_radius=1; // [1:20]
eyelet_diameter=eyelet_radius*2;

//Distance of the centre of the eyelet from the centre of the button
eyelet_placement=5;  //[1:50]
ep=eyelet_placement;
et=sqrt((ep*ep)/2);

//rim thickness
rim_thickness=1;// [0:10]

// Recess depth (set to 0 for flat surface)
recess_depth=1; //[0:10]

// Recess chamfer angle
recess_chamfer_angle=60; // [0:90]

// Base chamfer angle
base_chamfer_angle=35; // [0:60]


/*[Tolerances - mm]*/

//Edge Clearance - Clearance between the eyelet edge and button edge
edge_clearance=1; //[0:10]

//Eyelet Clearance - Clearance between the eyelets
eyelet_clearance=1; //[0:10]

//Mibimum Base Thickness
min_base_clearance=1; //[0:10]

//Minimum Wall Thickness - With the application of chamfers and recesses, wall thickness may be unacceptable;
min_wall_tolerated=1; //[0:10]

//// Computed Dimensions
recess_outer_diameter=button_diameter-rim_thickness;

recess_inner_diameter=recess_outer_diameter-(recess_depth/tan(-recess_chamfer_angle-90));

base_diameter=button_diameter-((button_thickness)/tan(-base_chamfer_angle-90));

//// Warnings 

if (recess_inner_diameter<0)
{
    echo("WARNING: chamfer angle not possible with set recess depth, decrease depth or increase angle");
    echo("Flat surface will be generated");
}

if (base_diameter<0)
{
    echo("WARNING: base chamfer angle not possible with set button thickness, decrease depth or angle");
}

if ((-eyelet_diameter+eyelet_placement*sin(360/(2*eyelets)))<=eyelet_clearance)
{
    echo("WARNING: low clearance between eyelets");
}
   
if ((ep+eyelet_diameter)>=button_diameter-rim_thickness/2-edge_clearance)
{
    echo("WARNING: low clearance between eyelets and edge");
}
    
if (recess_depth>(button_thickness-min_base_clearance))
{
    echo("WARNING: recess depth too high");
}


// This section calculates the wall thickness between the base of the recess and the outer wall
recess_excess=recess_depth*tan(recess_chamfer_angle);

if (rim_type=="round" && rim_thickness/2>recess_depth)   
{
    base_cutout=tan(base_chamfer_angle)*recess_depth;
    min_wall_thickness=recess_excess+rim_thickness/2+sqrt(pow((rim_thickness/2),2)-pow(recess_depth,2));
    
    if ((min_wall_thickness)<min_wall_tolerated)
    {
        echo("WARNING: minimum wall thickess is too low. Try lowering chamfer angles or increasing rim thickness.");
    }
    
}

else
{
    recess_excess=recess_depth*tan(recess_chamfer_angle);
    min_wall_thickness=recess_excess+rim_thickness-(tan(base_chamfer_angle)*recess_depth);
    
    if ((min_wall_thickness)<min_wall_tolerated)
    {
        echo("WARNING: minimum wall thickess is too low. Try lowering chamfer angles or increasing rim thickness.");
    }    
}


//// Model Generation

if(rim_type=="round")
{
    difference()
    {
        //create the button, then slice the top to add a torus as the rim
        button(eyelets,button_diameter,button_thickness,eyelet_diameter,eyelet_placement,base_diameter,recess_depth,recess_outer_diameter,recess_inner_diameter);      
        translate([0,0,button_thickness-rim_thickness/2])
        {  
            difference()
            {
                cylinder(rim_thickness/2,button_diameter,button_diameter, $fn = 64);
                cylinder(rim_thickness/2,button_diameter-rim_thickness/2,   button_diameter-rim_thickness/2, $fn = 64);     
            }   
        }       
    }   
    // add torus as a rim
    rotate_extrude(convexity = 10, $fn = 64) 
    translate([button_diameter-rim_thickness/2, button_thickness-rim_thickness/2]) 
    circle(r = rim_thickness/2, $fn = 64);   
}
    

else
{
    button(eyelets,button_diameter,button_thickness,eyelet_diameter,eyelet_placement,base_diameter,recess_depth,recess_outer_diameter,recess_inner_diameter);    
}


//Creates the button
module button(eyelets,button_diameter,button_thickness,eyelet_diameter,eyelet_placement,base_diameter,recess_depth,recess_outer_diameter,recess_inner_diameter)
{
    difference()
    {
        cylinder(button_thickness,base_diameter,button_diameter, $fn = 64);
        // recess at the top of the button
        translate([0,0,button_thickness-recess_depth+0.001])
        {
            cylinder(recess_depth,recess_inner_diameter,recess_outer_diameter,$fn = 64);
        }
        
        // Creates the eyelets
        for (i =[1:eyelets])
        {    
            translate([eyelet_placement*cos(i*360/eyelets),ep*sin(i*360/eyelets),-0.01]) cylinder(3*button_thickness,eyelet_diameter,eyelet_diameter,$fn = 64);  
        }
    }
}


