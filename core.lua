local name, core = ...
core.addon = CreateFrame("frame",nil,UIParent)
local defaults = {}
defaults[#defaults+1] = {buttonsize = {
	type="slider",
	label="Bag Buttons Size",
	value=32,
	step=2,
	min=20,
	max=40,
	callback=function() core:redraw() end
}}
defaults[#defaults+1] = {buttonsperrow = {
	type="slider",
	value=16,
	min=8,
	max=30,
	step=1,
	label="Bag Buttons Per Row",
	callback = function() core:redraw() end
}}
defaults[#defaults+1] = {bankbuttonsize = {
	type="slider",
	label="Bank Buttons Size",
	value=30,
	step=2,
	min=20,
	max=50,
	callback=function() core:redraw() end
}}
defaults[#defaults+1] = {bankbuttonsperrow = {
	type="slider",
	value=16,
	min=8,
	max=30,
	step=1,
	label="Bank Buttons Per Row",
	callback = function() core:redraw() end
}}
defaults[#defaults+1] = {autorepair = {
	type="checkbox",
	value=true,
	label="Automatically repair",
}}
defaults[#defaults+1] = {sellgreys = {
	type="checkbox",
	value=true,
	label="Automatically sell trash at vendor.",
}}
defaults[#defaults+1] = {fastloot = {
	type="checkbox",
	value=true,
	label="Fast Loot",
	tooltip="Loots items automatically and much faster than the default UI.",
}}

bdCore:addModule("Bags", defaults)
local config = bdCore.config.profile['Bags']
local bordersize = bdCore.config.persistent['General'].border

core.bagslots = {
	CharacterBag0Slot,
	CharacterBag1Slot,
	CharacterBag2Slot,
	CharacterBag3Slot
}
core.bank = {}

-- Set Up Frames
core.bags = CreateFrame("frame","bdBags",UIParent)
core.bags:SetPoint("BOTTOMRIGHT", UIParent,"BOTTOMRIGHT", -20, 20)
core.bank = CreateFrame("frame","bdBank",UIParent)
core.bank:SetPoint("LEFT", UIParent,"LEFT", 20, 40)


function core:redraw()
	if (core.bags:IsShown()) then
		core:bagGenerate()
	end
	if (core.bank:IsShown()) then
		if (core.onreagents) then
			core:quickreagent(true)
		else		
			core:bankGenerate()
		end
	end
end
bdCore:hookEvent("bd_reconfig", function() core:redraw() end)

function core:Setup(frame)
	frame:SetWidth(config.buttonsize*config.buttonsperrow+20)
	frame:SetFrameStrata("HIGH")
	frame:SetFrameLevel(2)
	bdCore:setBackdrop(frame)
	frame:SetClampedToScreen(true)
	frame:SetMovable(true)
	frame:SetUserPlaced(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton","RightButton")
	frame:RegisterForDrag("LeftButton","RightButton")
	frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
	frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	frame:Hide()
	
	frame.sort = CreateFrame("frame", nil, frame)
	frame.sort:SetHeight(20)
	frame.sort:SetWidth(20)
	frame.sort:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -26, -6)
	frame.sort:SetScript("OnEnter", function()
		frame.sort.text:SetTextColor(1,1,1)
	end)
	frame.sort:SetScript("OnLeave", function()
		frame.sort.text:SetTextColor(.4,.4,.4)
	end)
	frame.sort:SetScript("OnMouseDown", function(self, delta)
		if (frame:GetName() == "bdBags") then 
			SortBags();
		else
			BankItemAutoSortButton:Click()
		end
	end)
	frame.sort.text = frame.sort:CreateFontString(nil, "OVERLAY")
	frame.sort.text:SetPoint("CENTER", frame.sort, "CENTER")
	frame.sort.text:SetFont(bdCore.media.font, 12, "OUTLINE")
	frame.sort.text:SetText("S")
	frame.sort.text:SetTextColor(.4,.4,.4)	
	
	frame.bags = CreateFrame('Frame', nil, frame)
	frame.bags:SetWidth(180)
	frame.bags:SetHeight(40)
	frame.bags:SetFrameLevel(27)
	frame.bags:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, -2)
	frame.bags:Hide()
	
	bdCore:setBackdrop(frame.bags)
	
	frame.bags.toggle = CreateFrame('Frame', nil, frame)
	frame.bags.toggle:SetHeight(20)
	frame.bags.toggle:SetWidth(20)
	frame.bags.toggle:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -6, -6)
	frame.bags.toggle:EnableMouse(true)
	
	frame.bags.toggle.text = frame.bags.toggle:CreateFontString("button")
	frame.bags.toggle.text:SetPoint("CENTER", frame.bags.toggle, "CENTER")
	frame.bags.toggle.text:SetFont(bdCore.media.font, 12, "OUTLINE")
	frame.bags.toggle.text:SetText("B")
	frame.bags.toggle.text:SetTextColor(.4,.4,.4)
	frame.bags.toggle:SetScript('OnMouseUp', function()
		if (togglebag ~= 1) then
			togglebag = 1
			frame.bags:Show()
			frame.bags.toggle.text:SetTextColor(1,1,1)
		else
			togglebag= 0
			frame.bags:Hide()
			frame.bags.toggle.text:SetTextColor(.4,.4,.4)
		end
	end)
	
	frame.bags.toggle:SetScript("OnEnter", function(self)
		self.text:SetTextColor(1,1,1)
	end)
	frame.bags.toggle:SetScript("OnLeave", function(self)
		self.text:SetTextColor(.4,.4,.4)
	end)
end
core:Setup(core.bags)
core:Setup(core.bank)

-- rare/epic border
function core:IconBorder(border)
	local parent = border:GetParent()
	local count = _G[parent:GetName().."Count"]
	local cooldown = _G[parent:GetName().."Cooldown"]
	local quest = _G[parent:GetName().."IconQuestTexture"] or parent.IconQuestTexture
	local flash = border.flashAnim;
	local glow = border.newitemglowAnim;
	local newitem = parent.NewItemTexture;
	local battlepay = parent.BattlepayItemTexture;
	local r, g, b = border:GetVertexColor()
	r, g, b = round(r, 1), round(g, 1), round(b, 1)
	
	-- set everything to the bottom of the frame
	border:SetTexture(bdCore.media.flat)
	border:ClearAllPoints()
	border:SetPoint("BOTTOMLEFT",parent,"BOTTOMLEFT", bordersize, bordersize)
	border:SetPoint("TOPRIGHT",parent,"BOTTOMRIGHt", -bordersize, bordersize+3)
	if (not border.top) then
		border.top = parent:CreateTexture(nil)
		border.top:SetTexture(bdCore.media.flat)
		border.top:SetVertexColor(unpack(bdCore.media.backdrop))
		border.top:SetPoint("BOTTOMLEFT",parent, "BOTTOMLEFT", 2, 5)
		border.top:SetPoint("TOPRIGHT",parent, "BOTTOMRIGHT", -2, 6)
	end
	
	-- flash/glow/newitem are a pain
	core:killShowable(flash)
	core:killShowable(glow)
	core:killShowable(newitem)
	core:killShowable(battlepay)
	parent.hover:SetTexture(bdCore.media.flat)
	parent.hover:SetVertexColor(1, 1, 1, .1)
	
	-- quest
	if (quest) then
		quest:SetTexture(bdCore.media.flat)
		quest:SetVertexColor(1,1,0)
		quest.SetTexture = function() return end
		quest.SetVertexColor = function() return end
		quest:ClearAllPoints()
		quest:SetPoint("BOTTOMLEFT",parent,"BOTTOMLEFT", bordersize, bordersize)
		quest:SetPoint("TOPRIGHT",parent,"BOTTOMRIGHt", -bordersize, bordersize+3)
	end
	
	-- hide depending on rarity
	local color = r..g..b
	if (color == "111" or color == "0.70.70.7" or color == "000") then
		border:Hide()
		border.top:Hide()
		count:SetPoint("BOTTOMRIGHT",parent,"BOTTOMRIGHT",-1, 1)
	else
		border:Show()
		border.top:Show()
		count:SetPoint("BOTTOMRIGHT",parent,"BOTTOMRIGHT",-1, 5)
	end
end

function core:SkinEditBox(frame)
	frame.Left:Hide()
	frame.Right:Hide()
	frame.Middle:Hide()
	local icon = _G[frame:GetName().."SearchIcon"]
	icon:ClearAllPoints()
	icon:SetPoint("LEFT",frame,"LEFT",4,-1)

	frame.Instructions:SetFont(bdCore.media.font,12)
	frame.Instructions:ClearAllPoints()
	frame.Instructions:SetPoint("LEFT",frame,"LEFT",18,0)
	
	frame.SetHeight = function() return end
	frame.SetWidth = function() return end
	frame.SetSize = function() return end
	
	bdCore:setBackdrop(frame)
end

function core:Skin(frame)
	local aurora = select(1,IsAddOnLoaded("Aurora"))
	if (aurora) then
		local F, C = unpack(Aurora or FreeUI)
		C.defaults['bags'] = false
	end
	if (frame.skinned) then return end
	
	frame:SetFrameStrata("HIGH")
	frame:SetFrameLevel(6)

	local normal = _G[frame:GetName().."NormalTexture"]
	local count = _G[frame:GetName().."Count"]
	local cooldown = _G[frame:GetName().."Cooldown"]
	local icon = _G[frame:GetName().."IconTexture"]
	local flash = frame.flash
	normal:SetAllPoints(frame)
	--[[if (flash) then
		flash:SetAllPoints(parent)
	end--]]
	frame:SetAlpha(1)
	
	frame:SetNormalTexture("")
	frame:SetPushedTexture("")
	count:SetFont(bdCore.media.font,13,"THINOUTLINE")
	count:SetJustifyH("RIGHT")
	count:SetAlpha(.9)
	
	-- button textures
	local hover = frame:CreateTexture()
	hover:SetTexture(bdCore.media.flat)
	hover:SetVertexColor(1, 1, 1, .1)
	hover:SetPoint("TOPLEFT",frame,"TOPLEFT",2,-2)
	hover:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-2,2)
	frame.hover = hover
	frame:SetHighlightTexture(hover)
	frame.SetHighlightTexture = function() return end
	
	frame:SetBackdrop({bgFile = bdCore.media.flat, edgeFile = bdCore.media.flat, edgeSize = 2})
	frame:SetBackdropColor(unpack(bdCore.media.backdrop))
	frame:SetBackdropBorderColor(unpack(bdCore.media.border))
	
	icon:SetAllPoints(frame)
	icon:SetPoint("TOPLEFT", frame, 2, -2)
	icon:SetPoint("BOTTOMRIGHT", frame, -2, 2)
	icon:SetTexCoord(.1, .9, .1, .9)
	
	cooldown:GetRegions():SetFont(bdCore.media.font, 14, "OUTLINE")
	cooldown:GetRegions():SetJustifyH("Center")
	cooldown:GetRegions():ClearAllPoints()
	cooldown:GetRegions():SetAllPoints(cooldown)
	cooldown:SetParent(frame)
	cooldown:SetAllPoints(frame)
	
	hooksecurefunc(frame.IconBorder,"SetVertexColor", function() core:IconBorder(frame.IconBorder) end)
	core:IconBorder(frame.IconBorder)
	frame.skinned = true
end

function core:killShowable(frame)
	if (not frame) then return end
	frame:Hide()
	frame.Show = function() return end
	frame.Hide = function() return end
	frame.SetAlpha = function() return end
	frame.SetTextColor = function() return end
	frame.SetVertexColor = function() return end
end

-- Calls when each bag is opened
function core:Draw(frame,size,id)

	frame.size = size;
	for i = 1, size do
		local index = size - i + 1;
		local itemButton = _G[frame:GetName().."Item"..i];
		itemButton:SetID(index);
		itemButton:Show();
	end
	frame:SetID(id);
	frame:Show()
	
	--print(id)
	if (id == 0) then
		core:bagGenerate(frame,size,id)
	elseif (id == 5) then
		core:bankGenerate(frame,size,id)
	end
	
	-- hide everything that shouldn't be there
	for i = 1, 12 do
		local frame = _G['ContainerFrame'..i]
		local closebutton = _G[frame:GetName().."CloseButton"]
		local portrait = _G[frame:GetName().."PortraitButton"]
		local background = _G[frame:GetName().."BackgroundTop"]

		frame:SetFrameStrata("HIGH")
		frame:SetFrameLevel(3)
		frame:EnableMouse(false)
		frame:DisableDrawLayer("BACKGROUND")
		frame:DisableDrawLayer("BORDER")
		frame:DisableDrawLayer("ARTWORK")
		frame:DisableDrawLayer("OVERLAY")
		frame:DisableDrawLayer("HIGHLIGHT")

		core:killShowable(frame.FilterIcon)
		core:killShowable(frame.ClickableTitleFrame)
		core:killShowable(closebutton)
		core:killShowable(portrait)
		core:killShowable(background)
		for p = 1, 7 do
			select(p, _G["ContainerFrame"..i]:GetRegions()):SetAlpha(0)
		end
	end
	for i = 1, 5 do				
		select(i, _G['BankFrame']:GetRegions()):Hide()
	end
	_G["BackpackTokenFrame"]:GetRegions():SetAlpha(0)
	
	
	BankFrameCloseButton:Hide()
	BankFrameMoneyFrame:Hide()
	bdCore:StripTextures(BankFrameMoneyFrameInset)
	bdCore:StripTextures(BankFrameMoneyFrameBorder)
	bdCore:StripTextures(BankFrameMoneyFrame)
	bdCore:StripTextures(BankFrame)
	bdCore:StripTextures(BankSlotsFrame,true)
	BankSlotsFrame:SetFrameStrata("HIGH")
	BankSlotsFrame:SetFrameLevel(3)
	BankSlotsFrame:SetParent(core.bank)
	ReagentBankFrame:SetFrameStrata("HIGH")
	ReagentBankFrame:SetFrameLevel(3)
	ReagentBankFrame:SetParent(core.bank)
	bdCore:StripTextures(ReagentBankFrame)
	ReagentBankFrame:DisableDrawLayer("BACKGROUND")
	ReagentBankFrame:DisableDrawLayer("ARTWORK")
	BankPortraitTexture:Hide()
	BankFrame:EnableMouse(false)
	BankSlotsFrame:EnableMouse(false)
	core:killShowable(BagHelpBox)
end

-- Make entire bags show or hide when the main bag closes
ContainerFrame1Item1:HookScript("OnHide",function() core.bags:Hide() end)
ContainerFrame1Item1:HookScript("OnShow",function() core.bags:Show() end)
BankFrame:HookScript("OnHide",function() ToggleAllBags() end)
BankFrame:HookScript("OnShow",function() ToggleAllBags() end)
hooksecurefunc(BankFrame,"Show",function() ToggleAllBags() end)
hooksecurefunc(BankFrame,"Hide",function() ToggleAllBags() end)

-- Hijack blizzard functions
function ToggleBag() return end
function ToggleBackpack() return end
function OpenBackpack() return end
function CloseBackpack() return end
function updateContainerFrameAnchors() return end
function ContainerFrame_GenerateFrame(frame, size, id) core:Draw(frame, size, id) end
function OpenAllBags(frame) ToggleAllBags("open") end

-- Open all Bags
local togglemain, togglebank = 0,0
function ToggleAllBags(func)
	-- show all bags
	if (BankFrame:IsShown()) then
		core.bank:Show()
		core.bags:Show()
		for i=0, NUM_CONTAINER_FRAMES, 1 do OpenBag(i) end
	else -- show only main backpack
		if (core.bags:IsShown() and (not func or not func == "open")) then
			for i=0, NUM_CONTAINER_FRAMES, 1 do CloseBag(i) end
			core.bags:Hide()
			core.bank:Hide()
			CloseBankFrame()
		else
			for i=0, NUM_CONTAINER_FRAMES, 1 do OpenBag(i) end
			core.bags:Show()
		end
	end
end
BackpackTokenFrame:Hide();