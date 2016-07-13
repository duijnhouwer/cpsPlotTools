# Capsaicin Plot Tools for Matlab 

Capsaicin (CPS) Plot Tools facilitate many common tasks in the creation of scientific figures, often with no more than a single command. Examples are lettering multi-panel figures, scaling panel axis limits to a global minimum and maximum, and adding reference lines.

The toolbox has a consistent syntax and nomenclature throughout and is designed to be as no-nonsense as possible, i.e., to not override or clash with any default Matlab styles and functions.

For convenience, all files start with `cps`. This aids recognition and has the added benefit that typing `cps` followed by the Tab-key will bring up a list of all available cpsPlotTools functions on your path. Provided, of course, that Tab-completion is enabled in Matlab's preferences.

The following is an alphabetical list of the most important functions with a short description. This overview 
can be brought up in the Matlab command window with `help cpsPlotTools`. Each function has an extensive help-text for use in the command window (for instance, type `help cpsRefLine`).

|Function (alphabetical) |Short description|
|------------------------|----------------|
| cpsArrange     | Rearrange the occlusion in the current Axes|
| cpsFindFig     | Create or find a figure-window by name|
| cpsGetAxes     | Return handles to Axes-objects|
| cpsLabelPanels | Add lettering to multipart figures|
| cpsLimits      | Selectively set axis limits|
| cpsRefLine     | Draw reference lines|
| cpsText        | Add text in standard locations|
| cpsTileFigs    | Tile all open figure windows on the screen|
| cpsUnifyAxes   | Unify axes limits within or between (sub)plots|

After install, run `showdemo cpsDemo` to see a few illustrated examples.
 
Copyright 2016 Jacob Duijnhouwer
