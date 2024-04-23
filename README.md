# PGUI
## An Immediate Mode GUI Library For Picotron

## Installation

Just copy the the source code, a file called `pgui.lua` from the src folder in this repository, into your Picotron project folder.

Then include the file in your main Picotron code with `include "pgui.lua"`

## General usage

Because this this GUI library follows the [Immediate Mode](https://en.wikipedia.org/wiki/Immediate_mode_GUI) pattern, all GUI components are updated and rendered each frame in the program. The code execution is divided in two parts, following the game loop used in Picotron: an update part, where most calculations for the gui are made and you get return values from the components, and a draw part, where the graphical elements of the components are rendered.

For pgui to work, you have two put two basic functions:

`pgui:refresh()` at the beginning of your _update function. This will restart the list of components to render and make some general calculations.

`pgui:draw()` at your _draw function. This will render the components.

Additionally, in _update, after the refresh function, you put all the components that are part of your desired GUI. There is a set of basic components like buttons, text input boxes, radio buttons, checkboxes, sliders, and others, and there are some layout components that can nest other components and are useful for grouping and organizing, like dropdowns, vertical and horizontal stacks, a covenience top menu bar, and a scrollable container.

All components are created by using the component function. The first argument is the name of component, and the second is a table containing options and values:

`pgui:component(NAME, {OPTIONS})`

Components return values that you can use as like in your code. In most cases, you have to feed the return value back into the component so it can keep track of its state.

Some components need to store some persistent information. To achieve this, an internal dictionary keeps track of the state of the component. For this components you need to include a unique label in the options. Specially if you have more than one of the same component.

## List of components

This is the detailed list of component available in the library, their options with default values and return values. If you want to use default values, you can omit them in the options table you pass to the component function.

NOTE: There are a couple of options that ALL components have, so they will not be listed:

- *pos*. vector. The position of the component relative to its container (or to the display if it has no container). Default: `pos=vec(0,0)`.
- *color*. table. The color palette used. Default: `color= {7,18,12,0,7,6}`. See the palette section below.

### Box

Just a filled rectangle with a border
`pgui:component("box",{size=vec(16,16),stroke=true,active=false,hover=false})`

Options:
- *size*. vector. Size of the component in width and height.
- *stroke*. boolean. Show border or not.
- *active*. boolean. Change color when clicked.
- *hover*. boolean. Change color when hovered on.

Returns: "box". string.

### Text box

A box with text inside
`pgui:component("text_box",{text="TEXTBOX",margin=2,stroke=true,active=false,hover=false})`

Options:
- *text*. string. Text inside the box.
- *margin*. number. Margin separating text from border from all sides.
- *stroke*. boolean. Show border or not.
- *active*. boolean. Change color when clicked.
- *hover*. boolean. Change color when hovered on.

Returns: "text_box". string.

### Input

A text input box with a cursor.
`pgui:component("input",{label="input",text="INPUT",margin=2,charlen=16})`

Options:
- *label*. string. REQUIRED. Unique name for keeping internal state.
- *text*. string. Text inside the box.
- *margin*. number. Margin separating text from border from all sides.
- *charlen*. number. Maximum characters allowed.
  
Returns: text. string.

### Button

A button
`pgui:component("button",{text="BUTTON",margin=2,stroke=true,disable=false})`

Options:
- *text*. string. Text inside the box.
- *margin*. number. Margin separating text from border from all sides.
- *stroke*. boolean. Show border or not.
- *disable*. boolean. Disable clicking

Returns: if was clicked. boolean.

### Horizontal slider

A horizontal slider
`pgui:component("hslider",{min=0,max=100,value=50,size=vec(100,10),stroke=true,format=function(v) return v end}})`

options:
- *min*. number. Minimum value allowed.
- *max*. number. Maximum value allowed.
- *value*. number. Current value of slider.
- *size*. vector. Size of the component. Width and height.
- *format*. function. Function to format the value display inside the slider.

Returns: value. number.

### Radio buttons

Radio buttons for selecting one of multiple options in a list
`pgui:component("radio",{gap=3,r=3,sep=4,selected=1,options={}})`

Options:
- *gap*. number. Vertical gap between options.
- *r*. number. Radius of selector.
- *sep*. number. Separation between selector and option text.
- *selected*. number. Index of currently selected option.
- *options*. list of strings. Text for each one of the options

Returns: selected. number.

### Multiple selection buttons

Buttons for selecting multiple options in a list
`pgui:component("multi_select",{gap=3,box_size=7,sep=4,options={},selected={}})`

Options:
- *gap*. number. Vertical gap between options.
- *box_size*. number. Size of selector button. Just one number for width and height because it's a square.
- *sep*. number. Separation between selector and option text.
- *options*. list of strings. Text for each one of the options
- *selected*. list of booleans. for each option, true indicates it is selected, false indicates it is not.

Returns: selected. list of booleans.

### Checkbox

A toggle button with text
`pgui:component("checkbox",{text="CHECKBOX",box_size=8,sep=4,value=false})`

Options:
- *text*. string. Descriptive text for the checkbox.
- *box_size*. number. Size of selector button. Just one number for width and height because it's a square.
- *sep*. number. Separation between selector and option text.
- *value*. boolean. If the checkbox is activated or not.

returns: value. boolean.

### Palette

Shows selectable sample boxes from a list of colors
`pgui:component("palette",{columns=4,gap=3,box_size=10,colors={0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15},selected=1})`

Options:
- *columns*. numbers. Max number of samples per rows.
- *gap*. number. Vertical and horizontal gap between samples.
- *box_size*. number. Size of each sample. Just one number for width and height because it's a square.
- *colors*. list of numbers. Indexes of colors to include in the palett.
- *selected*. number. Index of currently selected color.

Returns: selected. number.

## List of layout components

Layout components are used to group and organize basic components or other layout components.

### Horizontal stack

Groups a list of components horizontally
`pgui:component("hstack",{stroke=true,width=0,margin=3,gap=3,contents={}})`

### Top menu bar

A convenient horizontal stack formatted as a top menu bar
`pgui:component("checkbox",{text="CHECKBOX",box_size=8,sep=4,value=false})`

### Vertical stack

Groups a list of components vertically
`pgui:component("vstack",{stroke=true,height=0,margin=3,gap=3,contents={}})`

### Dropdown

A vertical stack with a button that toggles the display of it's contents
`pgui:component("dropdown",{text="CHECKBOX",box_size=8,sep=4,value=false})`

### Scrollable

A container box that allows its content to be scrolled
`pgui:component("scrollable",label="scrll",scroll_x=true,scroll_y=false,size=vec(50,50),sensibility=4,content={}})`

## Examples

Check out the examples folder to see some ways to use the library

## Color Palette

pgui uses a table to store a color palette of six colors. This palette is used in all of the components by default, unless you specify a different palette for a particular component.

The colors in the palette are used in components as follows:

| Index in table | Used for                                              | Default value |
|---             |---                                                    |---            |
|1               |fill color for boxes, buttons, etc.                    |7              |
|2               |on hover fill for buttons                              |18             |
|3               |active color for buttons, checkboxes, sliders, etc.    |12             |
|4               |stroke colors for borders and text                     |0              |
|5               |not used yet                                           |7              |
|6               |not used yet                                           |6              |

### Topbar menu

### hstack with sliders

## Optimizations

I tried to make the library efficient, but depending on the number of components you use, it can still can become resource intensive. There are two tricks you can use to consume less cpu:

- You can deactivate the clipping of components, if you are not using any scrollable component. This will reduce computations a little bit.
- You can refresh and update your components every other frame. One example on how to do that is this:

## Support my work!

If you like this library please consider supporting it.


You can also check some of my other work on itch or in this github account, like my Pico-8 games or bebop, my music generator for games and video