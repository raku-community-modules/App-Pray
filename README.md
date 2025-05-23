[![Actions Status](https://github.com/raku-community-modules/App-Pray/actions/workflows/linux.yml/badge.svg)](https://github.com/raku-community-modules/App-Pray/actions) [![Actions Status](https://github.com/raku-community-modules/App-Pray/actions/workflows/macos.yml/badge.svg)](https://github.com/raku-community-modules/App-Pray/actions) [![Actions Status](https://github.com/raku-community-modules/App-Pray/actions/workflows/windows.yml/badge.svg)](https://github.com/raku-community-modules/App-Pray/actions)

NAME
====

App::Pray - Raku Ray Tracing Engine

SYNOPSIS
========

    $ pray scene.json --width=100

DESCRIPTION
===========

This is Pray, a Raku ray tracer. It is tested to work with recent builds of Rakudo on the MoarVM backend, though it is likely to work on any modern Rakudo. Image::PNG::Portable and JSON::Tiny are required.

USAGE
=====

Input is a JSON scene file, described later. Output is a 24-bit PNG image file.

Pray is normally invoked as the `pray` script.

Two positional arguments are accepted. The first is the name of the scene file to read, which defaults to "scene.json". The second is the file name of the PNG image to write, and defaults to the file name of the scene file (ignoring any directory prefix), with everything after the last period replaced by "png". If the scene file name is "examples/scene-01.json" for instance, then the image file name defaults to "scene-01.png" in the current working directory.

  * --width

  * --height The size of the output image in positive whole numbers. At least one of these is required, and an omitted one will default to the value of the other. The field of view will be expanded to fill non-square aspect ratios, as opposed to being clipped.

  * --preview Shows a preview of the in-progress render. On by default.

  * --verbose Currently just prints the line number of the currently rendering line. Useful if preview is disabled. May do more or something else entirely in the future. Off by default.

  * --quiet Disables the summary of the performance of the operation when complete. Also disables preview, unless it is explicitly enabled. Off by default.

SCENES
======

DISCLAIMER: As the scene files could be thought of as the main user interface, an important note about them goes here: they're not done yet. The author feels that they are verbose, cumbersome, rigid, and fail with cryptic error messages. This will change, as will many other things about scene files. So don't expect your scene files to work unaltered in future versions until Pray is a little less alpha-ish.

The scene files are JSON formatted. As such, numbers must always have a digit before a decimal ("0.5", not ".5"), and single quotes ("'") and trailing commas ("[1,2,3,]") are illegal.

The outermost block of the scene file represents the scene itself, and is an object with keys "camera", "objects", and "lights". See the included examples for details. Wherever possible, sane defaults are used. The structure looks roughly like this:

    scene                       the top-level block of the file
        camera                  the view into the scene
            position            view point
            object              view direction (towards point)
            roll                rotation around axis of viewing direction
            fov                 field of view
            exposure            scale of color values
        lights                  list of lights in the scene
            position            light placement
            color               light color
            intensity           brightness
        objects                 list of objects in the scene
            geometry            the physical shape of the object
                primitive       cube, cylinder, cone, or sphere
                position        placement
                scale           size
                rotate          orientation
                csg             list of csg operations and geometries
            material            appearance of the object
                ambient         flat constant lighting
                    color
                    intensity
                diffuse         smooth shaded lighting per light
                    color
                    intensity
                specular        "shiny spot" per light
                    color
                    intensity
                    sharpness   how sharp or soft the highlight is
                reflective      visible reflection of other objects
                    color
                    intensity
                transparent     light passing through the object
                    color
                    intensity   how transparent the object is (fades other colors)
                    refraction  whether and how much this object bends light

The coordinate system uses Y for depth and Z for height, and is left-handed (if +X is right and +Z is up, +Y is forward). Except for the camera, positions and rotations default to 0, and scales default to 1. The camera defaults to an off-axis position in the +X,-Y,+Z region, pointing towards the origin.

Colors and coordinates are specified as objects with r,g,b/x,y,z keys. Any omitted elements default to 0, so to make blue for instance, you only have to write '{ "b":1 }'.

Entirely omitted colors default to white, but omitted lightings are not used, thus have effectively no color (white or otherwise).

The key "intensity" adjusts the brightness of lights and colors. In a "transparent" lighting block, it will also adjust the opacity of the object as a whole.

In most cases, "intensity" is intended to be a value between and inclusive of 0 and 1. However, for lights, intensity is not intended to have an upper bound. Balancing light and material "color" and "intensity" (and "exposure" of your camera) is up to you. Auto-exposure may make this simpler in the future.

At this point, it would only be fair to say the lighting model is "loosely based" on physical reality. Until more realistic algorithms are implemented, some restraint must be exercised if a realistic appearance is desired. For example, setting several of the lighting options at a high intensity could cause the material to appear far brighter than should be possible for the amount of light falling on it. Caveat emptor, etc.

If you omit the whole material block, it will default to a white, fully diffusive, slightly ambient material.

If you omit the "primitive" in a geometry block, that object will have no physical manifestation unless you add geometry to it with CSG.

CSG is an even-length array of "operation, geometry" values. The array implements a FIFO pipeline - in effect, the listed operations will be chained. In addition to chaining, CSG operations can also be nested, by simply adding CSG to a geometry block within an outer CSG array.

Currently recognized CSG operations are add/union/or, subtract/not/andnot, intersect/intersection/and, and deintersect/difference/xor. CSG geometry is defined in the space of the object it is being applied to. In other words, position/scale/rotate applies to the whole object including CSG sub-geometries.

HACKING
=======

There is much which could be added, improved, or simplified. So jump in! I'm looking forward to seeing what others do with Pray.

This is my first Raku project, thus much of the code probably looks a lot like Perl. As a self-education project, I have been and continue to be learning and re-learning Raku over the course of development, small parts at a time. The numerous iterations over all of the major components still show through in some spots, and in some others it's just clear that my understanding is still incomplete. Even the situational use of bracketing and indenting is inconsistent; I do at least stick to 4-column tab indents, though. Patches and suggestions are welcome and appreciated for style and structure as much as functionality.

The class hierarchy is a little troubling in some ways, but should be generally simple to navigate and understand. More thought needs to go into the API in several ways before using Pray from your own scripts is advisable; that is why there is no direct support for loading scenes from anything other than a file: the tools are there to make it happen in a line or two of code, but it's a can of worms once people start trying to actually *use* all the classes in unforeseen ways, on top of dealing with the mess which seems to naturally arise from my creative rampages. Some of the classes should probably be roles, some of the separate classes might be combined into a single class with one or two extra properties or roles, and the story goes on. In short, this project is just too young to think about a "stable public API" just yet. After some polishing, this will be revisited.

If you want to add primitives, the convention so far is to define them as 1 unit in radius/apothem/whatever applies on all three axii. All of the transformations and CSG are handled by the Pray::Geometry::Object superclass, so a primitive is defined by only 2 methods: _ray_intersection and _contains_point, which take a single Pray::Geometry::Ray or Pray::Geometry::Vector3D, respectively, and returns results as checked against the unit primitive. As always, read the existing code for details.

The use of vectors vs matrices is also inconsistent: Pray originally had no matrix class. When the transformations were implemented, the pile of vector ops became too heavy, so the matrix class was created to allow the transformation pipeline to be flattened into a single matrix. There are more places where this approach would save cycles, but other than to keep it "usable" on my aging hardware, no attempt to profile or optimize has yet been made.

Rewriting much of the whole program as a single large matrix pipeline even occurred to me. Of course, with Rakudo JVM supporting concurrency, mutlithreading is one of the obvious low-hanging fruits in terms of performance. It is near the top of my list. Many other things could also be done to decrease runtime: many operations are needlessly creating and destroying objects instead of mutating them in place; there are several places where adding conditionals or rearranging the arithmetic should speed things up on average. Once we profile Pray, we'll have a better idea where to start with optimization. I'm open to radical changes in structure, just not if the only purpose is to shave 3% off of the execution time.

Generally, solidifying the structure in terms of "shaders" and "pipelines" and the traditional 3D graphics processing methods would likely provide many benefits, and is an overarching direction I plan to move everything towards.

Use of types and type constraints is spotty. All sorts of input validation and error checking is missing.

LIMITATIONS/BUGS/TODO
=====================

In no particular order: There is currently no internal reflection, subsurface scattering, volumetric lighting, global illumination, caustics, depth of field, anti-aliasing, or concurrency. Primitive choices are few (missing 4 of 5 platonic solids, among other things), and only the most basic transformations exist, and they are applied as a whole in only one fixed order.

There is no support for non-solid objects such as planes, polygons, or hollow surfaces, nor meshes whether open or closed. No procedural surfaces, textures of any kind, bump maps, or things which might be considered "effects" like motion blur or particle systems.

There's no support for fractals in any way shape or form, which is sad. Scene files feel crufty and fragile, and there is no way to re-use data in multiple places, forcing the same color to be applied for each material lighting type, for instance.

Scene files have to be created by hand in a text editor.

The API is not yet suitable for external use. Various naming and calling conventions all over the place are questionable. Performance is almost certainly much less than it could be, even given the present state of Rakudo. Repeating from above, all sorts of input validation and error checking is missing.

Documentation is lacking.

CREDITS
=======

Raku and its implementations are the tireless effort of many wonderful people around the world.

  * https://raku.org/

  * https://rakudo.org/

The scene loading code is forked from [JSON::Unmarshal](https://raku.land/zef:raku-community-modules/JSON::Unmarshal).

Parts of the matrix code are or were forked from or inspired by [Math::Vector](https://raku.land/zef:librasteve/Math::Vector).

AUTHOR
======

raydiak

COPYRIGHT AND LICENSE
=====================

Copyright 2014 - 2020 raydiak

Copyright 2025 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

