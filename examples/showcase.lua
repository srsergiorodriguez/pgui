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
	inputtext = "click'n'write!"
	colorselected = 1
end

function _update()
	pgui:refresh()
	full_test()
end

function full_test()
	local dropdown_options = {
		{"button",{text="DropButton 1",stroke=false}},
		{"button",{text="DropButton 2",stroke=false}},
		{"dropdown",{label="submenu",text="Submenu",stroke=false,contents={
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
		{"line",{size=vec(100,0)}}, --just a quick and dirty separator in the stack
		{"multi_select",{options=multioptions,selected=selectedmulti}},
		{"line",{size=vec(100,0)}},
		{"radio",{options=radiooptions,selected=selectedradio}},
		{"line",{size=vec(100,0)}},
		{"text",{text="Text input:"}},
		{"input",{label="myinput",text=inputtext}}
	}
		
	local stack = pgui:component("vstack",{pos=vec(180,20),contents=contents})
	
	--reinsert the outputs from the stack gui into the variables
	slidervalue = stack[6]
	check = stack[7]
	selectedmulti = stack[9]  
	selectedradio = stack[11]
	inputtext = stack[14]
	
	--see the output tree from the vstack
	dbg = stack
	
	local topbar_options = {
		{"button",{text="Btn",stroke=false}},
		{"button",{text="Btn2",stroke=false}},
		{"dropdown",{label="topdrop",text="Drop",stroke=false,contents={
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
	if topbar[3][1] or topbar[3][2] or topbar[3][3] or topbar[3][4] then
		pgui:close_dropdown("topdrop")
	end
	pgui:set_store("disable_drop",#topbar[3] > 0) --to disable the menu dropdown when the overlapping topbar menu is open
	
	--see the output tree from the topbar
	dbg2 = topbar
end

function _draw()
	cls(6)	
	print("cpu: "..sub(tostring(stat(1)),1,6),400,18,10)
	print("SIDEBAR OUTPUT:\n"..table_tree(dbg),300,20,8)
	print("TOPBAR OUTPUT:\n"..table_tree(dbg2),20,100,8)	
	pgui:draw()
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