# Glitch Weaving

Portfolio page: https://www.deannagelosi.com/#/glitch-weaving/

Blog post: https://medium.com/@deannagelosi/generating-glitched-textiles-6842fca2f92

This program generates weaving drafts as svg files based on defined parameters. It takes as input a known weaving structure, e.g. twill or satin, and glitches the design with increasing frequency. The glitches are shaped by a Perlin noise field which produces deterministic results. Drafts can be modified by panning and zooming around the noise field and increasing/decreasing a glitch modifier.


<p align="center">    
    <img src="img/rose-demo.gif" alt="generated weaving draft" style="width:80%">
</p>

<p align="center">
    <b>Example output of a glitched weave draft</b>
</p>


## Weave Structure Profiles

Weave structures are saved in `structures.json` file. To add additional structures, update this file.

## Keyboard Controls

* `g`: increase glitch modifier
* `d`: decrease glitch modifier
* `r`: show or hide row numbers
* `s`: save current draft as an svg to the drawdowns folder
* `up arrow`: zoom in, resulting in less variation in the noise field
* `down arrow`: zoom out, resulting in more variation in the noise field
* `left arrow`: pan noise field to the left to adjust the output at the same variation level
* `right arrow`: pan noise field to the right to adjust the output at the same variation level

## Variables

A Perlin noise field is a deterministic structured noise known for organic qualities. The zoom level determines its visible structure.

* `pan`: x-coordinate position on a Perlin nosie
* `pZoom`: zoom level on Perlin noise field
* `seed`: a numerical value for the Perlin noise field
* `glitchMod`: glitch modifier, adds or removes glitching based on keyboard input
* `glitchSectionSize`: defined in `structures.json` file for an individual weave structure, number of rows that is glitched incrementally

The result is a weaving draft with lift plan, tie ups, threading, and drawdown. The follow are variables that can be edited to control the draft output:

* `numShafts`: the total number of shafts on the loom
* `rectSize`: the size of each cell in the svg output
* `warpQuant`: the total number of warps (or columns)
* `weftQuant`: the total number of wefts (or rows)
* `cellSize`: pixel size of each cell in the draft grid

The following is generated by the program:

* `liftPlan`: a generated two-dimensional array containing data for the lifted shafts for each row
* `drawdown`: a generated two-dimensional array of the final warps lifted and lowered
* `threading`: a two-dimensional array describing how the shafts are tied up
* `rowFrequency`: analytics on glitch distribution across rows
