## Marvel Universe Social Network

Visualization of [the Social characteristics of the Marvel Universe](http://bioinfo.uib.es/~joemiro/marvel.html) using [the Javascript Infovis Toolkit](http://thejit.org/) (JIT).

**See the Visualization: [Marvel Social Network Graph](http://stungeye.com/viz/marvel/marvel.html).**

The provided Ruby script takes the data provided by [Joe Miro, Cesc Rosselló, Ricardo Alberich](http://bioinfo.uib.es/~joemiro/marvel.html) and the [Marvel Chronology Project](http://www.chronologyproject.com/) and formats it for use with a [JIT Force-Directed Graph](http://thejit.org/static/v20/Jit/Examples/ForceDirected/example1.html).

The graph shows the "social network" of characters from the Marvel comic book universe. The lines (edges) between characters nodes represent shared comic-book apperances.

## Examples

[Example screen capture](https://github.com/stungeye/marvel_social_network/raw/master/examples/example1.png) with the constants in prep_data.rb set to:

APPEARANCE_THRESHOLD = 600        
SHARED_APPERANCE_THRESHOLD = 0    
FRIEND_TO_LINEWIDTH_SCALE = 1000 

Change SHARED_APPERANCE_THRESHOLD to 600 and you get [this screen capture](https://github.com/stungeye/marvel_social_network/raw/master/examples/example2.png).

In both cases I have manually tweaked the positions of the nodes.

## Files

* names.txt - Marvel comic character IDs and names found [here](http://bioinfo.uib.es/~joemiro/marvel.html).
* vertext.txt - Marvel comic-book apperance by character found [here](http://bioinfo.uib.es/~joemiro/marvel.html).
* prep_data.rb - Ruby script to massage the *.txt data into JSON graph structure.
* marvel.html - JIT force-directed sample HTML found [here](http://thejit.org/static/v20/Jit/Examples/ForceDirected/example1.html).
* resources/force.js - JIT force-directed sample JS found [here](http://thejit.org/static/v20/Jit/Examples/ForceDirected/example1.html).
* resource/json.js - JSON data produced by the prep_data.rb script.
* resource/* - JIT JS & CSS.

## Instructions

* Change the constants in the prep_data.rb file.
* Execute the prep_data.rb script. (The output will be saved to resources/json.js.)
* Open marvel.html in your web-browser. (For IE < 9 [excanvas.js](http://excanvas.sourceforge.net/) is provided.)

## License

This is free and unencumbered software released into the public domain.  See LICENSE for details.