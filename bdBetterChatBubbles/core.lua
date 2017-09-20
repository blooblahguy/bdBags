local defaults = {}
defaults[#defaults+1] = {skinbubbles = {
	type = "checkbox",
	value = true,
	label = "Skin Chat Bubbles"
}}
defaults[#defaults+1] = {removebg  = {
	type = "checkbox",
	value = true,
	label = "Remove Background From Bubbles"
}}

local config = bdCore:addModule("Chat Bubbles",defaults)
local bubbleskin = CreateFrame("frame", nil, UIParent)
local chatstrings = {}
local newAddMsg = {}
local update = 0
local numkids = 0
local bubbles = {}
local printed = false
local function AddMessage(frame, text, ...)
	if (text) then
		bubbletext = gsub(text, "%[(%d0?)%. .-%]", "%1")
		bubbletext = gsub(bubbletext, "|Hplayer:([^%|]+)|h%[([^%]]+)%]|h", "|Hplayer:%1|h%2|h")
		
		if (string.match(bubbletext, " says:") ~= nil or string.match(bubbletext, " yells:") ~= nil) then
			bubbletext = gsub(bubbletext, "|Hplayer:([^%|]+)|h(.+)|h says:", "|Hplayer:%1|h%2|h:");
			bubbletext = gsub(bubbletext, "|Hplayer:([^%|]+)|h(.+)|h yells:", "|Hplayer:%1|h%2|h:");
			bubbletext = gsub(bubbletext, " yells:", ":");
			bubbletext = gsub(bubbletext, " says:", ":");
			
			bdCore.chatstrings[#bdCore.chatstrings] = bubble
			
		end

		return newAddMsg[frame:GetName()](frame, text, ...)
	end
end

for i = 1, NUM_CHAT_WINDOWS do
	if i ~= 2 then
		local f = _G[format("%s%d", "ChatFrame", i)]
		newAddMsg[format("%s%d", "ChatFrame", i)] = f.AddMessage
		f.AddMessage = AddMessage
	end
end
local function rawText(text)
	-- starting from the beginning, replace item and spell links with just their names
	text = gsub(text, "|r|h:(.+)|cff(.+)|H(.+)|h%[(.+)%]|h|r", "|r|h:%1%4");
	text = strtrim(text)

	return text
end

local function skinbubble(frame)
	for i=1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		if region:GetObjectType() == "Texture" then
			region:SetTexture(nil)
		elseif region:GetObjectType() == "FontString" then
			frame.text = region
		end
	end
	local scale = UIParent:GetEffectiveScale()*2
	
	if (config.skinbubbles) then
		frame.text:SetFont(bdCore.media.font, 13, "OUTLINE")
		if (config.removebg) then
			frame:SetBackdropColor(0,0,0,0)
			frame:SetBackdropBorderColor(0,0,0,0)
		else
			frame:SetBackdrop({
				bgFile = bdCore.media.flat,
				edgeFile = bdCore.media.flat,
				edgeSize = scale,
				insets = {left = scale, right = scale, top = scale, bottom = scale}
			})
			frame:SetBackdropColor(unpack(bdCore.media.backdrop))
			frame:SetBackdropBorderColor(unpack(bdCore.media.backdrop))
		end
	end
	
	frame:SetScript("OnUpdate",function()
		for k, v in pairs(bdCore.chatstrings) do
			local hay = rawText(v)
			local needle = rawText(frame.text:GetText())
			
			local s, e = string.find(hay, needle)

			if (s ~= nil) then
				local size = string.len(hay) - string.len(needle)
				frame.text:SetText(v)
				frame.text:SetWidth(frame.text:GetWidth() + (size*.85))
				chatstrings[k] = nil
			end
		end
	end)
	
	tinsert(bubbles, frame)
end

local function ischatbubble(frame)
	if frame:GetName() then return end
	if not frame:GetRegions() then return end
	return frame:GetRegions():GetTexture() == [[Interface\Tooltips\ChatBubble-Background]]
end

bubbleskin:SetScript("OnUpdate", function(bubbleskin, elapsed)
	update = update + elapsed
	if update > .05 then
		update = 0
		local newnumkids = WorldFrame:GetNumChildren()
		if newnumkids ~= numkids then
			for i=numkids + 1, newnumkids do
				local frame = select(i, WorldFrame:GetChildren())

				if ischatbubble(frame) then
					skinbubble(frame)
				end
			end
			numkids = newnumkids
		end
	end
end)