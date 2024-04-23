include "pgui.lua"

function _init()
	dbg = "<<<DEBUG>>>"	
	dbg2 = "<<<DEBUG2>>"
	
	check = false
	radiooptions = {"Radio 1","Radio 2","Radio 3"}
	selectedradio = 1
	multioptions = {"Multi 1","Multi 2","Multi 3"}
	selectedmulti = {true,true,false}
	slidervalue = 50
	pgui:set_store("disable_drop",false)
	inputtext = "Text input click!"
	colorselected = 1
	
	slidervalue = 10
end

function _update()
	pgui:refresh()
	
	--slidervalue = pgui:component("hslider",{pos=vec(190,20),value=slidervalue})
	full_test()
end

function full_test()
	local dropdown_options = {
		{"button",{text="DropButton 1",stroke=false}},
		{"button",{text="DropButton 2",stroke=false}},
		{"dropdown",{label="submenu",text="Submenu",stroke=true,contents={
				{"button",{text="SubButton 1",stroke=false}},
				{"button",{text="SubButton 2",stroke=false}},
				{"button",{text="SubButton 3",stroke=false}},
		}}}
	}
	
	local contents = {
		{"box",{size=vec(100,10),color={8,8,8,9,9,9}}},
		{"text",{text="Text"}},
		{"dropdown",{label="menu",text="Dropdown",contents=dropdown_options,disable=pgui:get_store("disable_drop")}},
		{"text_box",{text="This is a text box\nThis is a text box\nThis is a text box",margin=5}},
		{"button",{text="Button"}},
		{"hslider",{value=slidervalue}},
		{"checkbox",{value=check}},
		{"box",{size=vec(100,1),color={5}}}, --just a quick and dirty separator in the stack
		{"multi_select",{options=multioptions,selected=selectedmulti}},
		{"box",{size=vec(100,1),color={5}}},
		{"radio",{options=radiooptions,selected=selectedradio}},
		{"box",{size=vec(100,1),color={5}}},
		{"text",{text="Text input:"}},
		{"input",{label="myinput",text=inputtext}}
	}
		
	local stack = pgui:component("vstack",{pos=vec(10,20),contents=contents})
	
	--reinsert the outputs from the stack gui into the variables
	slidervalue = stack[6]
	check = stack[7]
	selectedmulti = stack[9]  
	selectedradio = stack[11]
	inputtext = stack[14]
	
	--see the output tree from the vstack
	dbg = stack
	
	local topbar_options = {
		{"button",{text="File",stroke=false}},
		{"button",{text="Edit",stroke=false}},
		{"dropdown",{label="top_help",text="Help",stroke=false,contents={
				{"button",{text="Top Button 1",stroke=false}},
				{"button",{text="Top Button 2",stroke=false}},
				{"button",{text="Top Button 3",stroke=false}},
				{"button",{text="Etc",stroke=false}},
		}}},
		{"dropdown",{label="palettemenu",text="Palette",stroke=false,contents={
			{"palette",{selected=colorselected}}
		}}}
	}
	
	local topbar = pgui:component("topbar",{contents=topbar_options})
	if topbar[4][1] != nil then
		colorselected = topbar[4][1]
	end

	pgui:set_store("disable_drop",#topbar[3] > 0) --to disable the menu dropdown when the overlapping topbar menu is open
	
	--see the output tree from the topbar
	dbg2 = topbar
end

function _draw()
	cls(6)
	rect(0,0,480,11,6)
	
	circfill(350,180,slidervalue,colorselected)
	pgui:draw()
	
	
	print("cpu: "..sub(tostring(stat(1)),1,6),400,18,10)
	print("SIDEBAR OUTPUT:\n"..table_tree(dbg),150,20,8)
	print("TOPBAR OUTPUT:\n"..table_tree(dbg2),300,20,8)	
end

function table_tree(table)
	--Get a string representing the tree structure of a table
	local level = 0
	local tree = ""

	if type(table) != "table" then
		return tostring(table)
	end
	
	local function recTree(table, level)
		local tabs = ""
		for i=1,level do tabs = tabs.."	" end	
		
		for k,v in pairs(table) do
			if type(v) == "table" then
				tree = tree..tabs.."<"..k..">\n"
				recTree(v, level + 1)
			else
				tree = tree..tabs.."["..k.."]: "..tostring(v).."\n"
			end
		end
	end
	
	recTree(table, level)
	return tree
end