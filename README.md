# PGUI

An immediate Mode GUI Library for [Picotron](https://www.lexaloffle.com/picotron.php)

![Preview](/imgs/pguiclip.gif)

Consider a donation!

Through Ko-fi:

<a href='https://ko-fi.com/H2H8X903V' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi3.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>

Through Buy me a coffee:

[buymeacoffee.com/srsergior](buymeacoffee.com/srsergior)

# Table of contents
- [PGUI](#pgui)
- [Table of contents](#table-of-contents)
  - [Installation](#installation)
  - [General usage](#general-usage)
  - [List of components](#list-of-components)
    - [Basic components](#basic-components)
      - [Box](#box)
      - [Text box](#text-box)
      - [Sprite box](#sprite-box)
      - [Input](#input)
      - [Button](#button)
      - [Horizontal slider](#horizontal-slider)
      - [Radio buttons](#radio-buttons)
      - [Multiple selection buttons](#multiple-selection-buttons)
      - [Checkbox](#checkbox)
      - [Palette](#palette)
    - [Layout components](#layout-components)
      - [Horizontal stack](#horizontal-stack)
      - [Top menu bar](#top-menu-bar)
      - [Vertical stack](#vertical-stack)
      - [Dropdown](#dropdown)
      - [Scrollable](#scrollable)
      - [Line](#line)
  - [Examples](#examples)
  - [Color Palette](#color-palette)
  - [Future expansions](#future-expansions)
  - [Limitations](#limitations)
  - [Support my work!](#support-my-work)
  - [Changelog](#changelog)
    - [1.0.1](#101)
    - [1.0.2](#102)
    - [1.0.3](#103)
    - [1.0.4](#104)

## Installation

Just copy the the source code, a file called `pgui.lua` from the src folder in this repository, into your Picotron project folder.

Then include the file in your main Picotron code with `include "pgui.lua"`

## General usage

Because this this GUI library follows the [Immediate Mode](https://en.wikipedia.org/wiki/Immediate_mode_GUI) pattern, all GUI components are updated and rendered each frame in the program. The code execution is divided in two parts, following the game loop used in Picotron: an update part, where most calculations for the GUI are made and you get return values from the components, and a draw part, where the graphical elements of the components are rendered.

For pgui to work, you have two put two basic functions:

`pgui:refresh()` at the beginning of your _update function. This will restart the list of components to render and make some general calculations.

`pgui:draw()` in your _draw function. This will render the components. If you pass a function as argument, it will call it before rendering layer 4 (usually not necessary).

Additionally, in _update, after the refresh function, you put all the components that are part of your desired GUI. There is a set of basic components like buttons, text input boxes, radio buttons, checkboxes, sliders, and others, and there are some layout components that can nest other components and are useful for grouping and organizing, like dropdowns, vertical and horizontal stacks, a covenience top menu bar, and a scrollable container.

All components are created by using the component function. The first argument is the name of component, and the second is a table containing options and values:

`pgui:component(NAME, {OPTIONS})`

Components return values that you can use as you like in your code. In most cases, you have to feed the return value back into a particular option of the component so it can keep track of its state.

This is a simple example of a slider controlling the size of a circle:

```Lua
include "pgui.lua"

function _init()
  -- Define the initial value of the slider
  slidervalue = 10
end

function _update()
  -- Refresh pgui each frame
  pgui:refresh()
  
  -- Create a slider and set its value back from its return value
  slidervalue = pgui:component("hslider",{pos=vec(190,20),value=slidervalue})
end

function _draw()
  cls(5)
	
  -- Draw the circle, its size is based on the return value of the slider
  circfill(240,140,slidervalue,8)
  
  -- Draw all pgui components	
  pgui:draw()
end
```

## List of components

This is the detailed list of component available in the library, their options with default values and return values. 

NOTE 1: If you want to use default values, you can omit them in the options table you pass to the component function.

NOTE 2: Some components need to store some persistent information. To achieve this, an internal dictionary keeps track of the state of the component. For these components you need to include a unique label in the options. Specially if you have more than one of the same component, so the library can differentiate between them.

NOTE 3: There are a couple of options that ALL components have, so they will not be listed but you can set them:

- **pos**. vector. The position of the component relative to its container (or to the app's window if it has no container). Default: `pos=vec(0,0)`.
- **color**. table. The color palette used. Default: `color= {7,18,12,0}`. See the palette section below.
- **layer**. number. Order of rendering. Default: `layer=0`. pgui normally just renders the components in the order they are created, and that's enough for most cases. However, if you want more control over it, you can set a higher layer number. pgui always renders dropdowns contents one layer higher than its parent toggle button.

### Basic components

#### Box

Just a filled rectangle with a border

`pgui:component("box",{size=vec(16,16),stroke=true,active=false,hover=false})`

Options:
- **size**. vector. Size of the component in width and height.
- **stroke**. boolean. Show border or not.
- **active**. boolean. Change color when clicked.
- **hover**. boolean. Change color when hovered on.

Returns: "box". string.

#### Text box

A box with text inside

`pgui:component("text_box",{text="TEXTBOX",margin=2,stroke=true,active=false,hover=false})`

Options:
- **text**. string. Text inside the box.
- **margin**. number. Margin separating text from border from all sides.
- **stroke**. boolean. Show border or not.
- **active**. boolean. Change color when clicked.
- **hover**. boolean. Change color when hovered on.

Returns: "text_box". string.

#### Sprite box

A box with a sprite inside

`pgui:component("sprite_box",{sprite=0,margin=2,stroke=true,active=false,hover=false,fn=function() end}})`

Options:
- **sprite**. number. Number of sprite in spritesheet.
- **margin**. number. Margin separating sprite from border from all sides.
- **stroke**. boolean. Show border or not.
- **active**. boolean. Change color of box when clicked.
- **hover**. boolean. Change color of box when hovered on.
- **fn**. function. Function to run before drawing the sprite. This can be used to set colors transparence with `palt()` before drawing the sprite. 

Returns: if was clicked. boolean.

#### Input

A text input box with a cursor

`pgui:component("input",{label="input",text="INPUT",margin=2,charlen=16})`

Options:
- **label**. string. REQUIRED. Unique name for keeping internal state.
- **text**. string. Text inside the box.
- **margin**. number. Margin separating text from border from all sides.
- **charlen**. number. Maximum characters allowed.
  
Returns: text. string.

#### Button

A button

`pgui:component("button",{text="BUTTON",margin=2,stroke=true,disable=false})`

Options:
- **text**. string. Text inside the box.
- **margin**. number. Margin separating text from border from all sides.
- **stroke**. boolean. Show border or not.
- **disable**. boolean. Disable clicking

Returns: if was clicked. boolean.

Note: when clicked, it will return true for just one frame!

#### Horizontal slider

A horizontal slider

`pgui:component("hslider",{min=0,max=100,value=50,size=vec(100,10),stroke=true,format=function(v) return v end,flr=false}})`

options:
- **min**. number. Minimum value allowed.
- **max**. number. Maximum value allowed.
- **value**. number. Current value of slider.
- **size**. vector. Size of the component. Width and height.
- **format**. function. Function to format the value display inside the slider.
- **flr**. boolean. floor / snap value to an integer

Returns: value. number.

#### Radio buttons

Radio buttons for selecting one of multiple options in a list

`pgui:component("radio",{gap=3,r=3,sep=4,selected=1,options={}})`

Options:
- **gap**. number. Vertical gap between options.
- **r**. number. Radius of selector.
- **sep**. number. Separation between selector and option text.
- **selected**. number. Index of currently selected option.
- **options**. table of strings. Text for each one of the options

Returns: selected. number.

#### Multiple selection buttons

Buttons for selecting multiple options in a list

`pgui:component("multi_select",{gap=3,box_size=7,sep=4,options={},selected={}})`

Options:
- **gap**. number. Vertical gap between options.
- **box_size**. number. Size of selector button. Just one number for width and height because it's a square.
- **sep**. number. Separation between selector and option text.
- **options**. table of strings. Text for each one of the options
- **selected**. table of booleans. for each option, true indicates it is selected, false indicates it is not.

Returns: selected. table of booleans.

#### Checkbox

A toggle button with text

`pgui:component("checkbox",{text="CHECKBOX",box_size=8,sep=4,value=false})`

Options:
- **text**. string. Descriptive text for the checkbox.
- **box_size**. number. Size of selector button. Just one number for width and height because it's a square.
- **sep**. number. Separation between selector and option text.
- **value**. boolean. If the checkbox is activated or not.

returns: value. boolean.

#### Palette

Shows selectable sample boxes from a list of colors

`pgui:component("palette",{columns=4,gap=3,box_size=10,colors={0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15},selected=0})`

Options:
- **columns**. numbers. Max number of samples per rows.
- **gap**. number. Vertical and horizontal gap between samples.
- **box_size**. number. Size of each sample. Just one number for width and height because it's a square.
- **colors**. table of numbers. Indexes of colors to include in the palett.
- **selected**. number. number code of currently selected color.

Returns: selected. number. currently selected color

### Layout components

Layout components are used to group and organize basic components or other layout components.

#### Horizontal stack

Groups a list of components horizontally. Its size will adapt to the size of the stacked contents.

`pgui:component("hstack",{stroke=true,width=0,margin=3,gap=3,box=true,contents={}})`

Options:
- **stroke**. boolean. Show border or not.
- **width**. number. If 0, the width of the stack wil adapt to its contents, if > 0 it will be set to the value specified.
- **margin**. number. Margin separating contents from border from all sides.
- **gap**. number. Horizontal gap between components.
- **box**. boolean. Draw containing box.
- **contents**. list of tables. A list of tables, each subtable represents a component to put inside the stack and must contain: `{NAME_OF_COMPONENT, {OPTIONS_OF_COMPONENT}}`

Returns. Table containing the return values of the contained components, in order. Table.

#### Top menu bar

A convenient horizontal stack formatted as a top menu bar. It will be positioned in vec(0,0)

`pgui:component("topbar",{width=479,gap=3,contents={}})`

Options:
- **width**. number. If 0, the width of the stack wil adapt to its contents, if > 0 it will be set to the value specified.
- **gap**. number. horizontal gap between components.
- **contents**. list of tables. A list of tables, each subtable represents a component to put inside the stack and must contain: `{NAME_OF_COMPONENT, {OPTIONS_OF_COMPONENT}}`

Returns: Table containing the return values of the contained components, in order. Table.

#### Vertical stack

Groups a list of components vertically. Its size will adapt to the size of the stacked contents.

`pgui:component("vstack",{stroke=true,height=0,margin=3,gap=3,box=true,contents={}})`

Options:
- **stroke**. boolean. Show border or not.
- **height**. number. If 0, the height of the stack wil adapt to its contents, if > 0 it will be set to the value specified.
- **margin**. number. Margin separating contents from border from all sides.
- **gap**. number. horizontal gap between components.
- **box**. boolean. Draw containing box.
- **contents**. list of tables. A list of tables, each subtable represents a component to put inside the stack and must contain: `{NAME_OF_COMPONENT, {OPTIONS_OF_COMPONENT}}`

Returns: Table containing the return values of the contained components, in order. Table.

#### Dropdown

A vertical stack with a button that toggles the display of it's contents
`pgui:component("dropdown",{label="dd",text="DROPDOWN",stroke=true,margin=2,gap=3,contents={},disable=false})`

Options:
- **label**. string. REQUIRED. Unique name for keeping internal state.
- **text**. string. Text inside the button.
- **stroke**. boolean. Show border or not.
- **margin**. number. Margin separating contents from border from all sides.
- **gap**. number. Vertical gap between components in vstack.
- **contents**. list of tables. A list of tables, each subtable represents a component to put inside the vstack and must contain: `{NAME_OF_COMPONENT, {OPTIONS_OF_COMPONENT}}`. See vstack.
- **disable**. boolean. disable dropdown button

Returns: Table containing the return values of the contained components in its stack, in order. Table.

NOTE: if you want to close the dropdown with code, for instance after clicking a button inside, you can use `pgui:close_dropdown(LABEL_OF_DROPDOWN)`, by replacing "LABEL_OF_DROPDOWN" with the label you used for your dropdown. This will set the store that keeps track of the internal state of the dropdown to false and will effectively close it.

#### Scrollable

A container box that clips the content that exceeds its size and can be scrolled with the mousewheel or a trackpad gesture. 

To use this component, you must run the function `pgui:activate_clipping()` in your _init function first.

`pgui:component("scrollable",label="scrll",scroll_x=true,scroll_y=false,size=vec(50,50),sensibility=4,content={}})`

Options:
- **label**. string. REQUIRED. Unique name for keeping internal state.
- **size**. vector. Desired size of scrollable area. If any dimension is bigger than content, it will shrink to content's size. If you see undesired clipping in a dimesion you don't want to scroll, set it to a big number (to be safe, 500)
- **scroll_x**. boolean. Allow x axis scrolling.
- **scroll_y**. boolean. Allow y axis scrolling.
- **content**. table. A table representing the data of a component to put inside the scrollable area, it must contain: `{NAME_OF_COMPONENT, {OPTIONS_OF_COMPONENT}}`.

Returns: Return value of content component.

#### Line

There's also a line component that can be used as a separator in stacks.

`pgui:component("line",{size=vec(100,0)})`
- **size**. vector. x and y positions with respect to **pos**.

## Examples

Check out the examples folder to see some ways to use the library

## Color Palette

pgui uses a table to store a color palette of four colors. This palette is used in all of the components by default, unless you specify a different palette for a particular component.

The colors in the palette are used in components as follows:

| Index in table | Used for                                              | Default value |
|---             |---                                                    |---            |
|1               |fill color for boxes, buttons, etc.                    |7              |
|2               |on hover fill for buttons                              |18             |
|3               |active color for buttons, checkboxes, sliders, etc.    |12             |
|4               |stroke colors for borders and text                     |0              |

You can set a new table for your general palette with the function `pgui:set_palette(TABLE)`.

## Future expansions

In the future, I would like to add a couple of extra components: a text area, a typewritter text effect, an xy kaoss style pad box , a knob, a plot and oscilloscope...

Text input is very simple, it doesn't respond to double clicking or to supr key, only to backspace.

## Limitations

I tried to make the library efficient, but depending on the number of components you use, it can still can become resource intensive. There are two tricks you can use to consume less cpu:

- Clipping of components is disabled by default, you can keep it like this if you are not using any scrollable component. This will reduce computations a little bit.
- You can refresh and update your components every other frame by using a counter and a modulo operator.

If the library is too heavy and you need space, you can delete the components that you are not using, just take into account that some components require others (mostly text, boxes, text boxes and buttons, so don't delete those!)

## Support my work!

This library was made by Sergio Rodríguez Gómez

If you like this library please consider supporting my work!

You can use this Ko-fi button:

<a href='https://ko-fi.com/H2H8X903V' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi3.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>

Or go to my Buy me a coffee page: [buymeacoffee.com/srsergior](buymeacoffee.com/srsergior)

Everything counts. I want to develop other cool tools and games.

You can also check some of my other work on [itch](https://srsergior.itch.io/) or in this github account, like my Pico-8 games or [bebop](https://srsergior.itch.io/bebop), a music generator for games and video soundtracks.

## Changelog

### 1.0.1

- Minor performance improvements
- Implemented layering

### 1.0.2

- Fixed offset error in scrollable and fixed button response miscalculations inside scrollable
- Added flr option to hslider
- Fixed minor layout adjustments
- Added sprite_box component based on @MaddoScientisto's suggestion
- Fixed color palette not being passed to children components

### 1.0.3

- Performance update, now components consume less cpu
- Refactored codebase to make it cleaner and easier to expand
- Minor display improvements in hslider


### 1.0.4

- Sprite component now returns if it was clicked so it can act like a button
- Fixed set_palette function
- Added close_dropdown function
- Minor ajustments on multiselect and radio buttons
- Added better support for special characters, based on @yeetree's suggestion