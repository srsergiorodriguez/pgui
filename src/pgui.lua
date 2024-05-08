--[[
	pgui - an Immediate Mode GUI library for Picotron
	v1.0.3
	By Sergio Rodriguez Gomez
	https://srsergior.itch.io/ | https://srsergiorodriguez.github.io/code?lang=en
	MIT License
	Donate:
	https://ko-fi.com/srsergior | https://buymeacoffee.com/srsergior
]]--

pgui_components = {}

pgui_components.unknown = {fns={}, data={text="?",_id="unknown"}}
pgui_components.unknown.fns.draw = function(self) print("[?]", self.pos.x, self.pos.y, 8) end

pgui_components.placeholder = {fns={}, data={_id="placeholder",visible=false}}
pgui_components.placeholder.fns.draw = function(self) if (self.visible) print("[x]", self.pos.x, self.pos.y, 8) end

pgui_components.text = {fns={}, data={_id="text",text="TEXT",size=vec(0,7)}}
pgui_components.text.fns.update = function(self)
	return self.text
end
pgui_components.text.fns.draw = function(self)
	pgui:_text(self.text,self,self.color[4])
end

pgui_components.rect = {fns={}, data={_id="rect",size=vec(16,16)}}
pgui_components.rect.fns.draw = function(self)
	pgui:_rect(self.pos.x+self.offset.x,self.pos.y+self.offset.y,self.size.x,self.size.y,self.color[4],false)
end

pgui_components.line = {fns={}, data={_id="rect",size=vec(16,16)}}
pgui_components.line.fns.draw = function(self)
	local x = self.pos.x+self.offset.x
	local y = self.pos.y+self.offset.y
	line(x,y,x+self.size.x,y+self.size.y,self.color[4])
end

pgui_components.radiocircle = {fns={}, data={_id="radiocircle",r=4,on=false}}
pgui_components.radiocircle.fns.update = function(self)
	self.size = vec(self.r*2,self.r*2)
end
pgui_components.radiocircle.fns.draw = function(self)
	local fill = self.color[3]
	local stroke = self.color[4]
	pgui:_radiocirc(self,self.r,fill,stroke,self.on)
end

pgui_components.multibox = {fns={}, data={_id="multibox",size=vec(8,8),on=false}}
pgui_components.multibox.fns.draw = function(self)
	--this is a single box, but used for multiple selection components!
	local fill = self.color[3]
	local stroke = self.color[4]
	local pos = self.pos+self.offset
	if (self.on) pgui:_rect(pos.x,pos.y,self.size.x,self.size.y,fill,true)
	pgui:_rect(pos.x,pos.y,self.size.x,self.size.y,stroke,false)
end

pgui_components.box = {fns={}, data={_id="box",size=vec(16,16),stroke=true,active=false,hover=false}}
pgui_components.box.fns.draw = function(self)
	local fill = self.color[1]
	local mouse_events = pgui:mouse_events(self)
	if (mouse_events.over and self.hover) fill = self.color[2]
	if (mouse_events.left_btn and self.active) fill = self.color[3]
	local stroke = self.stroke and self.color[4] or fill
	pgui:_box(self, self.size.x, self.size.y, fill, stroke)
end

pgui_components.text_box = {fns={}, data={_id="text_box",text="TEXTBOX",margin=2,stroke=true,active=false,hover=false}}
pgui_components.text_box.fns.update = function(self,offset)
	if pgui.stats.memos.text_width[self.text] == nil then
		pgui.stats.memos.text_width[self.text] = pgui:get_text_width(self.text)
	end
	local text_width = pgui.stats.memos.text_width[self.text]
	local lines = #split(self.text,"\n")
	local text_height = lines == 1 and 6 or lines * 9
	self.size = vec(text_width+(self.margin*2),(self.margin*2)+text_height)
	pgui:component("box",{size=self.size,hover=self.hover,active=self.active,stroke=self.stroke}, self)
	pgui:component("text",{pos=vec(self.margin,self.margin),active=self.active,text=self.text}, self)
	return self.text
end

pgui_components.sprite = {fns={}, data={_id="sprite",sprite=0,size=vec(0,7),fn=function() end, reset_palt=true}}
pgui_components.sprite.fns.draw = function(self)
	self.fn()
	pgui:_sprite(self.sprite,self)
	if (self.reset_palt) palt()
end

pgui_components.sprite_box = {fns={}, data={_id="sprite_box",sprite=0,margin=2,stroke=true,active=false,hover=false,fn=function() end}}
pgui_components.sprite_box.fns.update = function(self,offset)
	local sprite_width = get_spr(self.sprite):width() - 1
	local sprite_height = get_spr(self.sprite):height() - 1
	self.size = vec(sprite_width+(self.margin*2),(self.margin*2)+sprite_height)
	pgui:component("box",{size=self.size,hover=self.hover,active=self.active,stroke=self.stroke},self)
	pgui:component("sprite",{pos=vec(self.margin,self.margin),active=self.active,sprite=self.sprite,p=self.p},self)
	return self.sprite
end

pgui_components.input = {fns={}, data={label="input",_id="input",text="INPUT",charlen=16,margin=2}}
pgui_components.input.fns.update = function(self,offset)
	if (pgui:get_store(self.label,true) == nil) then
		local text_width = pgui:get_text_width(self.text)
		pgui:set_store(self.label,{
			cursor_pos = self.margin+text_width,
			cursor_idx = 0,
			active = false,
		},true)
	end
	
	local text_box = pgui:precomponent("text_box",{text=self.text,margin=self.margin},self)
	text_box:_update()
	text_box.size.x = (6 * self.charlen) + (self.margin * 2)
	self.size = text_box.size:copy()
	
	local mouse_events = pgui:mouse_events(text_box)
	local store = pgui:get_store(self.label,true)
	if mouse_events.clicked then
		local relx = mouse_events.rel_pos.x
		local cursor_pos = pgui:get_cursor_pos(self.margin,self.text,relx)
		store.cursor_pos = cursor_pos[1]
		store.cursor_idx = cursor_pos[2]
		store.cursor_line = 0
		store.active = true
	elseif pgui:get_mouse().mb == 1 and not mouse_events.left_btn then
		store.active = false
	end
	
	if store.active then
		local lines = #split(self.text,"\n")
		local col = self.color[3]
		if pgui.stats.blink then
			pgui:component("box",{
				pos=vec(store.cursor_pos,self.margin-1+(store.cursor_line*9)),
				size=vec(1,8),color={col,0,0,col,0,0}
			},self)
		end
		if keyp("backspace") and store.cursor_idx > 0 then
			local removed = sub(self.text,store.cursor_idx,store.cursor_idx)
			self.text = sub(self.text,0,store.cursor_idx-1)..sub(self.text,store.cursor_idx+1)
			store.cursor_pos -= pgui:get_text_width(removed)
			store.cursor_idx -= 1
		elseif keyp("left") and store.cursor_idx > 0 then
			local prevchar = sub(self.text,store.cursor_idx,store.cursor_idx)
			store.cursor_pos -= pgui:get_text_width(prevchar)
			store.cursor_idx -= 1
		elseif keyp("right") and store.cursor_idx < #self.text then
			local nextchar = sub(self.text,store.cursor_idx+1,store.cursor_idx+1)
			store.cursor_pos += pgui:get_text_width(nextchar)
			store.cursor_idx += 1
		end
		local is_shift = false
		if (key("shift")) is_shift = true
		for scancode in all(pgui.stats.scancodes) do
			if keyp(scancode) and self.charlen > #self.text then
				local str = scancode == "space" and " " or scancode
				--str = str == "enter" and "\n" or str --for future text field
				str = str == "enter" and "" or str
				str = is_shift and str:upper() or str
				self.text = sub(self.text,0,store.cursor_idx)..str..sub(self.text,store.cursor_idx+1)
				store.cursor_pos += pgui:get_text_width(str)
				store.cursor_idx += 1
			end
		end
		
		--this will help to create a text field component in the future
		--store.cursor_line += #split(self.text,"\n") - lines
		
		store.cursor_pos = max(0,store.cursor_pos)
		store.cursor_idx = max(0,store.cursor_idx)
	end
	
	return self.text
end

pgui_components.button = {fns={}, data={_id="button",text="BUTTON",margin=2,stroke=true,disable=false}}
pgui_components.button.fns.update = function(self,offset)
	local text_box = pgui:precomponent("text_box",{text=self.text,hover=not self.disable,active=not self.disable,stroke=self.stroke,margin=self.margin},self)
	text_box:_update()
	local mouse_events = pgui:mouse_events(text_box)
	self.size = text_box.size:copy()
	return mouse_events.clicked
end

pgui_components.vstack = {fns={}, data={_id="vstack",stroke=true,height=0,margin=3,gap=3,contents={},box=true}}
pgui_components.vstack.fns.update = function(self,offset)
	self.size = vec(0,self.margin*2)
	local y = self.margin
	if (self.box) pgui:component("box",{size=self.size,stroke=self.stroke},self)
	local upds = {}
	for content in all(self.contents) do
		local com = pgui:precomponent(content[1],content[2],self)
		com.pos = vec(self.margin+com.pos.x,y+com.pos.y)
		if (com._id == "dropdown") com.grow = true
		local upd = com:_update()
		add(upds,upd)
		self.size.x = com.size.x > self.size.x and com.size.x + com.pos.x or self.size.x
		self.size.y += com.size.y + self.gap
		y += (com.size.y + self.gap)
	end
	self.size.x += self.margin*2
	self.size.y = self.height != 0 and self.height or self.size.y - self.gap
	return upds	
end

pgui_components.hstack = {fns={}, data={_id="hstack",stroke=true,width=0,margin=3,gap=3,contents={},box=true}}
pgui_components.hstack.fns.update = function(self,offset)
	self.size = vec(self.margin*2,0)
	local x = self.margin
	if (self.box) pgui:component("box",{size=self.size,stroke=self.stroke}, self)
	local upds = {}
	for content in all(self.contents) do
		local com = pgui:precomponent(content[1],content[2],self)
		com.pos = vec(x+com.pos.x,self.margin+com.pos.y)
		if (com._id == "dropdown") com.grow = false
		local upd = com:_update()
		add(upds,upd)
		self.size.y = com.size.y > self.size.y and com.size.y + com.pos.y or self.size.y
		self.size.x += com.size.x + self.gap
		x += (com.size.x + self.gap)
	end
	self.size.y += self.margin*2
	self.size.x = self.width > 0 and self.width or self.size.x - self.gap
	return upds
end

pgui_components.topbar = {fns={}, data={_id="topbar",width=479,gap=3,contents={}}}
pgui_components.topbar.fns.update = function(self)
	return pgui:component("hstack",{gap=self.gap,width=self.width,stroke=false,margin=0,contents=self.contents},self)
end

pgui_components.dropdown = {fns={}, data={label="dd",_id="dropdown",grow=false,text="DROPDOWN",stroke=true,margin=2,gap=3,contents={},disable=false}}
pgui_components.dropdown.fns.update = function(self,offset)
  if (pgui:get_store(self.label,true) == nil) pgui:set_store(self.label,false,true)
	local button = pgui:precomponent("button",{size=self.size,stroke=self.stroke,text=self.text,margin=self.margin,disable=self.disable},self)
	local clicked = button:_update()
	self.size = button.size:copy()
	pgui:component("line",{pos=vec(0,button.size.y),size=vec(self.size.x,0)},self)
	if clicked and not self.disable then
		local toggle = not pgui:get_store(self.label,true)
		pgui:set_store(self.label,toggle,true)
	end
	if pgui:get_store(self.label,true) then
		local y = button.size.y
		local vstack = pgui:precomponent("vstack",{layer=self.layer+1,pos=vec(0,y),margin=self.margin,gap=self.gap,contents=self.contents},self)
		local upd = vstack:_update()
		if (self.grow) self.size.y += vstack.size.y
		return upd
	end
	return {}
end

pgui_components.scrollable = {fns={}, data={label="scrll",_id="scrollable",scroll_x=false,scroll_y=true,size=vec(50,50),sensibility=4,content={"text_box",{text="scrollable",margin=50}}}}
pgui_components.scrollable.fns.update = function(self,offset)
	if (pgui:get_store(self.label,true) == nil) pgui:set_store(self.label,{scrolling = vec(0,0)},true)
	local store = pgui:get_store(self.label,true)
	local com = pgui:precomponent(self.content[1],self.content[2],self)
	com.pos = store.scrolling
	com.clip = {self.pos.x+self.offset.x,self.pos.y+self.offset.y,self.size.x,self.size.y}
	local upd = com:_update()
	if (not self.scroll_x or (com.size.x < self.size.x)) self.size.x = com.size.x
	if (not self.scroll_y or (com.size.y < self.size.y)) self.size.y = com.size.y
			
	function limit(com,scroller)
		if com.size.y - scroller.size.y + com.pos.y <= 0 then
			com.pos.y = scroller.size.y - com.size.y
		elseif com.pos.y > 0 then
			com.pos.y = 0
		end
		if com.size.x - scroller.size.x + com.pos.x <= 0 then
			com.pos.x = scroller.size.x - com.size.x
		elseif com.pos.x > 0 then
			com.pos.x = 0
		end
	end	

	local mouse_events = pgui:mouse_events(self)
	if mouse_events.over then
		if (self.scroll_y) store.scrolling.y += mouse_events.vs*self.sensibility
		if (self.scroll_x) store.scrolling.x += mouse_events.hs*self.sensibility
		limit(com,self)
	end
	return upd
end

pgui_components.hslider = {fns={}, data={_id="hslider",format=function(v) return v end,min=0,max=100,value=50,size=vec(100,10),stroke=true,flr=false}}
pgui_components.hslider.fns.update = function(self,offset)
	local box = pgui:precomponent("box",{size=self.size,stroke=self.stroke},self)
	box:_update()
	local mouse_events = pgui:mouse_events(box)
	local range = self.max - self.min
	if mouse_events.left_btn then
		self.value = self.min + (mouse_events.rel_pos.x / self.size.x) * range
	end
	self.value = mid(self.min, self.value, self.max)
	local width = ((self.value - self.min) / range)*self.size.x
	if (self.flr) self.value = flr(self.value)
	local s = vec(width,self.size.y)
	local col = {self.color[3],0,0,0,0,0}
	if (width > 0) pgui:component("box",{size=s,stroke=self.stroke,color=col},self)
	local text_pos = vec(2,(self.size.y - 6) / 2)
	pgui:component("text",{text=self.format(self.value),pos=text_pos},self)
	return self.value
end

pgui_components.radio = {fns={}, data={_id="radio",gap=3,r=3,sep=4,selected=1,options={}}}
pgui_components.radio.fns.update = function(self,offset)
	local y = 0
	local i = 1
	local d = self.r * 2
	local tw = 0
	for opt in all(self.options) do
		if pgui.stats.memos.text_width[opt] == nil then
			pgui.stats.memos.text_width[opt] = pgui:get_text_width(opt)
		end
		local text_width = pgui.stats.memos.text_width[opt]
		tw =  text_width > tw and text_width or tw 
		local pos = vec(0, y)
		local on  = self.selected == i
		local radiocircle = pgui:precomponent("radiocircle",{pos=pos,r=self.r,on=on},self)
		radiocircle:_update()
		local text_pos = pos+vec(d+self.sep,(d - 7) / 2)
		pgui:component("text",{text=opt,pos=text_pos},self)
		y += d + self.gap
		local clicked = pgui:mouse_events(radiocircle).clicked
		if (clicked) self.selected = i 
		i += 1
	end	
	self.size = vec(tw + self.sep + d,y - self.gap)
	return self.selected
end

pgui_components.multi_select = {fns={}, data={_id="multi_select",gap=3,box_size=7,sep=4,selected={},options={}}}
pgui_components.multi_select.fns.update = function(self,offset)
	if (#self.selected < #self.options) then
		notify("#options and #selected do not match in multi_select")
		return
	end
	local y = 0
	local i = 1
	local d = self.box_size
	local tw = 0
	local selected = pgui:copy_table(self.selected)
	for opt in all(self.options) do
		if pgui.stats.memos.text_width[opt] == nil then
			pgui.stats.memos.text_width[opt] = pgui:get_text_width(opt)
		end
		local text_width = pgui.stats.memos.text_width[opt]
		tw =  text_width > tw and text_width or tw 
		local pos = vec(0, y)
		local on  = selected[i]
		local multibox = pgui:precomponent("multibox",{pos=pos,size=vec(d,d),on=on},self)
		multibox:_update()
		local text_pos = pos+vec(d+self.sep,(d - 7) / 2)
		pgui:component("text",{text=opt,pos=text_pos},self)
		y += d + self.gap
		local clicked = pgui:mouse_events(multibox).clicked
		if (clicked) selected[i] = not selected[i]
		i += 1
	end	
	self.size = vec(tw + self.sep + d,y - self.gap)
	return selected
end

pgui_components.checkbox = {fns={}, data={_id="checkbox",text="CHECKBOX",value=false,box_size=8,sep=4}}
pgui_components.checkbox.fns.update = function(self,offset)
	local select = pgui:precomponent("multi_select",{sep=self.sep,selected={self.value},options={self.text},box_size=self.box_size},self)
	local upd = select:_update()
	self.size = select.size
	return upd[1]
end

pgui_components.palette = {fns={}, data={_id="palette",columns=4,gap=3,box_size=10,colors={0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15},selected=1}}
pgui_components.palette.fns.update = function(self,offset)
	local i = 0
  local memo_code = self.columns.."_"..self.box_size.."_"..self.gap
  if pgui.stats.memos.palette_pos[memo_code] == nil then
    pgui.stats.memos.palette_pos[memo_code] = {}
  end
  local pos = pgui.stats.memos.palette_pos[memo_code]
	for col in all(self.colors) do
		local new_palette = pgui:copy_table(self.color)
		new_palette[1] = col
		new_palette[4] = self.selected == col and new_palette[3] or new_palette[4]
    
    if pos[i] == nil then
		  pos[i] = vec((i % self.columns), flr(i / self.columns))
		  pos[i] = pos[i] * (self.box_size+self.gap)
    end
    
		local box = pgui:precomponent("box",{pos=pos[i],size=vec(self.box_size,self.box_size),stroke=true,color=new_palette},self)
		box:_update()
		if (pgui:mouse_events(box).clicked) self.selected = col
		i += 1
	end
  pgui.stats.memos.palette_pos[memo_code] = pos
  
	self.size = vec(
		((self.box_size + self.gap)*self.columns)-self.gap,
		((self.box_size+self.gap)*ceil(#self.colors / self.columns))-self.gap
	)
	return self.selected
end

------ end of components -------

pgui_methods =  {}

--CYCLE METHODS
function pgui_methods:refresh()
	self.components = {}
	self.stats.t += 1
	self.stats.blink = flr(self.stats.t / 20 % 2) == 1
	self.stats.prev_mouse = self:copy_table(self.stats.mouse)
	self.stats.mouse = self:get_mouse()
end

function pgui_methods:draw(callback)
	callback = callback and callback or function() end
	self:sort_table(self.components,"layer")
	for component in all(self.components) do
		if self.components.layer == 4 then
			callback()
		end
		if self.stats.clipping and #component.clip == 4 then
			clip(component.clip[1],component.clip[2],component.clip[3],component.clip[4]+1)
			component:draw()
			clip()
		else
			component:draw()
		end
	end	
end

--COMPONENT METHODS

function pgui_methods:component(name, opts, parent_opts)
	local template = pgui_components[name]
	if not template then
		notify("ERROR: pgui component '"..tostring(name).."' does not exist")
    local component = self:new_component(pgui_components["unknown"],{})
		return component:_update()
	else
    local component = self:new_component(template, opts, parent_opts)
		return component:_update()
	end
end

function pgui_methods:precomponent(name, opts, parent_opts)
	local template = pgui_components[name]
  return self:new_component(template, opts, parent_opts)
end

function pgui_methods:new_component(template, opts, parent_opts)
	local base_data = {pos=vec(0,0),size=vec(0,0),offset=vec(0,0),color=pgui_methods:copy_table(self.stats.palette),clip={},layer=0}
	local data = {}
	for k,v in pairs(base_data) do
		local value = v
    if parent_opts then
      if (k == "layer") value = parent_opts.layer
      if (k == "clip") value = parent_opts.clip
      if (k == "color") value = parent_opts.color
      if (k == "offset") value = parent_opts.children_offset
    end
		if (opts[k] != nil) value = opts[k]
		data[k] = value
	end
	for k,v in pairs(template.data) do
		local value = v
		if (opts[k] != nil) value = opts[k]
		data[k] = value
	end
			
	local fns = template.fns
	function fns:_update()
		if (self.draw) addcomponent(self)
		if (self.update) then
			self.children_offset = self.pos + self.offset
			local upd = self:update(self.children_offset)
			return upd == nil and self._id or upd
		else
			return self._id
		end
	end
		
	function addcomponent(component)
		add(self.components, component)
	end
		
	local component = setmetatable(data, {__index=template.fns})	
	return component
end

--UPDATE METHODS

function pgui_methods:close_dropdown(label)
	self:set_store(label,false,true)
end

function pgui_methods:get_mouse()
	local mx,my,mb,hs,vs = mouse()
	return {mx=mx,my=my,mb=mb,hs=hs,vs=vs}
end

function pgui_methods:get_text_width(str)
	local lines = split(str,"\n")
	
	function tw(text)
		local sum = 0
		local charlist = split(text,"")
		for ch in all(charlist) do
			if ch == "I" or ch == "i" or ch == "l" or ch == "1" then
				sum += 4
			elseif ch == "M" or ch == "T" or ch == "W" or ch == "m" or ch == "w" then
				sum += 6
			else
				sum += 5
			end
		end
		return sum
	end
	
	if (#lines == 1) return tw(str)
	
	local width = 0
	for text in all(lines) do
		local w = tw(text)
		width = width > w and width or w
	end
	
	return width
end

function pgui_methods:get_cursor_pos(margin,text,relx)
	local sum = margin
	local i = 0
	for ch in all(text) do
		local v = 0	
		if ch == "I" or ch == "i" or ch == "l" or ch == "1" then
			v = 4
		elseif ch == "M" or ch == "T" or ch == "W" or ch == "m" or ch == "w" then
			v += 6
		else
			v += 5
		end
		if (sum + v > relx) return {sum,i}
		sum += v
		i += 1
	end
	return {sum,i}
end

function pgui_methods:get_scancodes()
	local scancodes = {
		--"~","!","@","#","$","%","^","&","*","(",")",
		--"_","-","+","=","[","]","{","}","|",":",";",
		--"'",",",".","<",">","/","?","`",
		"0","1","2","3","4","5","6","7","8","9",
		"a","b","c","d","e","f","g","h",
		"i","j","k","l","m","n","o","p",
		"q","r","s","t","u","v","w","x",
		"y","z","space","enter"
	}
	return scancodes
end

function pgui_methods:copy_table(table)
	local new_table = {}
	for k,v in pairs(table) do
		if type(v) == "table" then
			new_table[k] = self:copy_table(v)
		else
			new_table[k] = v
		end
	end
	return new_table
end

function pgui_methods:mouse_events(data)
	local mx = self.stats.mouse.mx
	local my = self.stats.mouse.my
	local mb = self.stats.mouse.mb
	local hs = self.stats.mouse.hs
	local vs = self.stats.mouse.vs
	local pmb = self.stats.prev_mouse.mb
	
	--adjust response to clipping
	local colrect = data.pos+data.offset --collision rectangle position
	local colsize = data.size:copy() --collision rectangle size
	
	if self.stats.clipping then
		if #data.clip == 4 then
			local cx = data.clip[1]
			local cw = data.clip[3]
			local cy = data.clip[2]
			local ch = data.clip[4]
			
			if colrect.x < cx then
				colsize.x = (colrect.x + colsize.x) - cx
				colrect.x = cx
			elseif colrect.x + data.size.x > cx + cw then
				colsize.x = colsize.x - ((colrect.x + colsize.x) - (cx +  cw))
			end 
			if colrect.y < cy then
				colsize.y = (colrect.y + colsize.y) - cy
				colrect.y = cy
			elseif colrect.y + data.size.y > cy + ch then
				colsize.y = colsize.y - ((colrect.y + colsize.y) - (cy +  ch))
			end
		end
	end
	---
	
	local collision = self:rect_collision(colrect,{x=mx,y=my},colsize,{x=1,y=1})
	local lb = collision and mb == 1
	local rb = collision and mb == 2
	local clicked = pmb == 0 and lb
	local released = pmb == 1 and collision and mb == 0
	return {over=collision,left_btn=lb,right_btn=rb,clicked=clicked,released=released,rel_pos=vec(mx,my)-data.offset-data.pos,hs=hs,vs=vs}
end

function pgui_methods:rect_collision(apos, bpos, as, bs)
	--check if two rectangles are colliding
	local colliding = true
	if (apos.x + as.x < bpos.x or
		apos.x > bpos.x + bs.x or
		apos.y + as.y < bpos.y or
		apos.y > bpos.y + bs.y) then
		colliding = false
	end 
	return colliding
end

--RENDER METHODS

function pgui_methods:set_palette(palette)
	if (#palette == 6) then
		self.stats.palette = palette
	else
		notify("Palette must be a table with 6 indexes")
	end
end

function pgui_methods:activate_clipping()
	self.stats.clipping = true
end

function pgui_methods:_text(text,com,col)
	local x = com.pos.x+com.offset.x
	local y = com.pos.y+com.offset.y
	print(tostring(text),x,y,col)
end

function pgui_methods:_rect(x,y,w,h,c,f)
	palt(0,true)
	line(x+1,y,x+w-1,y,c)
	line(x,y+1,x,y+h-1,c)
	line(x+1,y+h,x+w-1,y+h,c)
	line(x+w,y+1,x+w,y+h-1,c)
	if f then
		rectfill(x+1,y+1,x+w-1,y+h-1)
	end
end

function pgui_methods:_box(com,w,h,fill,stroke)
	local x = com.pos.x+com.offset.x
	local y = com.pos.y+com.offset.y
	self:_rect(x,y,w,h,fill,true)
	self:_rect(x,y,w,h,stroke,false)
end

function pgui_methods:_radiocirc(com,r,fill,stroke,f)
	local x = com.pos.x+com.offset.x+r
	local y = com.pos.y+com.offset.y+r
	if (f) circfill(x,y,r,fill)
	circ(x,y,r,stroke)
end

function pgui_methods:_sprite(sprite,com)
	local x = com.pos.x+com.offset.x
	local y = com.pos.y+com.offset.y
	spr(sprite,x,y)
end

--STORE METHODS

function pgui_methods:uid()
	local uid = split(date()," ")
	uid = table.concat(split(uid[1],"-"),"")..table.concat(split(uid[2],":"),"")..sub(tostring(rnd() * 1000),0,3)
	return uid
end

function pgui_methods:set_store(id,data,alt)
	if not alt then
		self.store[id] = data
	else
		self.alt_store[id] = data
	end
end

function pgui_methods:get_store(id,alt)
	if not alt then
		return self.store[id]
	else
		return self.alt_store[id]
	end
end

function pgui_methods:sort_table(tbl, key)
	local n = #tbl
	local sorted = false
	
	while not sorted do
		sorted = true
		for i = 1, n - 1 do
			if tbl[i][key] > tbl[i + 1][key] then
				tbl[i], tbl[i + 1] = tbl[i + 1], tbl[i]
				sorted = false
			end
		end
		n = n - 1
	end
end

pgui = setmetatable({
		components={},
		store={},
		alt_store={},
		stats={
			t = 0,
			blink = false,
			palette = {7,18,12,0,7,6},
			clipping = false,
			memos = {text_width={},palette_pos={}},
			scancodes=pgui_methods:get_scancodes(),
			mouse=pgui_methods:get_mouse(),
			prev_mouse=pgui_methods:get_mouse()
		}
	},
	{__index=pgui_methods}
)