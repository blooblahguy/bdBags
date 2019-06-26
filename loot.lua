local name, core = ...
local config = bdConfigLib:GetSave('Bags')
local bordersize = bdConfigLib:GetSave('bdAddons').border

function core:SkinLoot()
	if (not config.skinloot) then return end
	_G["LootFrameCloseButton"]:Hide() -- cba lol
	_G["LootFramePortraitOverlay"]:SetAlpha(0)

	bdCore:StripTextures(LootFrame, true)
	for i = 1, 50 do
		local frame = _G['LootButton'..i]
		if (not frame) then break end
		if (i ~= 1) then
			frame:ClearAllPoints()
			frame:SetPoint("TOPLEFT",_G['LootButton'..i-1],"BOTTOMLEFT",0,-2)
		end
		if (not frame.skinned) then
			local font = _G['LootButton'..i..'Text']
			local count = _G['LootButton'..i..'Count']
			local icon = _G['LootButton'..i..'IconTexture']
			local nf = _G['LootButton'..i..'NameFrame']
			local quality = frame.IconBorder
			
			quality:SetTexture("")
			quality:Hide()
			quality:SetAlpha(0)
			
			font:SetFont(bdCore.media.font, 14)
			count:SetFont(bdCore.media.font, 14, 'OUTLINE')
			
			frame:SetNormalTexture("")
			frame:SetPushedTexture("")
			local hover = frame:CreateTexture()
			hover:SetTexture(bdCore.media.flat)
			hover:SetVertexColor(1, 1, 1, 0.1)
			hover:SetAllPoints(frame)
			frame.hover = hover
			frame:SetHighlightTexture(hover)
			icon:SetTexCoord(.1, .9, .1, .9)

			bdCore:setBackdrop(frame)
			nf:SetAlpha(0)
			
			frame.skinned = true
		end
	end

	local i, t = 1, "Interface\\LootFrame\\UI-LootPanel"

	local regions = {LootFrame:GetRegions()}
	local children = {LootFrame:GetChildren()}

	for k, c in pairs(children) do
		if (not c:GetName()) then
			bdCore:StripTextures(c, true)
		end
	end
	for k, r in pairs(regions) do
		if r then
			if r.GetText and r:GetText() == ITEMS then
				r:ClearAllPoints()
				r:SetPoint("TOP", -12, -19.5)
			elseif (r.GetTexture) then
				-- print(r:GetTexture())
				r:Hide()
			end
		end
	end

	-- while true do
	-- 	local r = select(i, LootFrame:GetRegions())

		
	-- 	-- i = i + 1
	-- end
end
core:SkinLoot()


local p, r, x, y = "TOP", "BOTTOM", 0, -4
local buttonHeight = LootButton1:GetHeight() + abs(y)
local baseHeight = LootFrame:GetHeight() - (buttonHeight * LOOTFRAME_NUMBUTTONS)

LootFrame.OverflowText = LootFrame:CreateFontString(nil, "OVERLAY", "GameFontRedSmall")
local OverflowText = LootFrame.OverflowText

OverflowText:SetPoint("TOP", LootFrame, "TOP", 0, -26)
OverflowText:SetPoint("LEFT", LootFrame, "LEFT", 60, 0)
OverflowText:SetPoint("RIGHT", LootFrame, "RIGHT", -8, 0)
OverflowText:SetPoint("BOTTOM", LootFrame, "TOP", 0, -65)
OverflowText:SetSize(1, 1)
OverflowText:SetJustifyH("LEFT")
OverflowText:SetJustifyV("TOP")
OverflowText:SetText("Hit 50-mob limit! Take some, then re-loot for more.")
OverflowText:Hide()

local t = {}
local function CalculateNumMobsLooted()
	wipe(t)

	for i = 1, GetNumLootItems() do
		for n = 1, select("#", GetLootSourceInfo(i)), 2 do
			local GUID, num = select(n, GetLootSourceInfo(i))
			t[GUID] = true
		end
	end

	local n = 0
	for k, v in pairs(t) do
		n = n + 1
	end

	return n
end

local old_LootFrame_Show = LootFrame_Show
function LootFrame_Show(self, ...)
	LootFrameInset:Hide()
	local maxButtons = floor(UIParent:GetHeight()/LootButton1:GetHeight() * 0.7)
	
	local num = GetNumLootItems()
	
	num = min(num, maxButtons)

	LootFrame:SetHeight(baseHeight + (num * buttonHeight))
	for i = 1, num do
		local button
		if i > LOOTFRAME_NUMBUTTONS then
			button = _G["LootButton"..i] or CreateFrame("Button", "LootButton"..i, LootFrame, "LootButtonTemplate", i)
			LOOTFRAME_NUMBUTTONS = i
		end
		if i > 1 then
			button = _G["LootButton"..i]
			button:ClearAllPoints()
			button:SetPoint(p, "LootButton"..(i-1), r, x, y)
		end
	end
	
	core:SkinLoot()

	if CalculateNumMobsLooted() >= 50 then
		OverflowText:Show()
	else
		OverflowText:Hide()
	end

	return old_LootFrame_Show(self, ...)
end

hooksecurefunc("LootFrame_UpdateButton", function(index)
	local texture, item, quantity, quality, locked, isQuestItem, questId, isActive = GetLootSlotInfo(index)
	local frame = _G["LootButton"..index]
	if (config.skinloot) then
		_G["LootButton"..index.."IconQuestTexture"]:SetAlpha(0) -- hide quest item texture
		_G["LootButton"..index.."NameFrame"]:SetAlpha(0) -- hide sucky drops :D
	end
	if isQuestItem then
		frame.background:SetVertexColor(1.0, 0.82, 0)
	else
		frame.background:SetVertexColor(unpack(bdCore.media.backdrop))
	end	
end)

local LootTargetPortrait = CreateFrame("PlayerModel", nil, LootFrame)
LootTargetPortrait:SetPoint("BOTTOMLEFT", LootFrame, "TOPLEFT", 9, -66)
LootTargetPortrait:SetSize(187, 34)
bdCore:setBackdrop(LootTargetPortrait)

LootPortraitFrame = CreateFrame("Frame")
LootPortraitFrame:RegisterEvent("LOOT_OPENED")
LootPortraitFrame:SetScript("OnEvent", function(self, event, id)
    if event == "LOOT_OPENED" then
        if UnitExists("target") then
            LootTargetPortrait:SetUnit("target")
            LootTargetPortrait:SetCamera(0)
        else
            LootTargetPortrait:ClearModel()
            LootTargetPortrait:SetModel("PARTICLES\\Lootfx.m2")
        end
	end
end)


local qol = CreateFrame('frame',nil)
qol:RegisterEvent('MERCHANT_SHOW')
qol:SetScript("OnEvent", function()
	if (config.autorepair) then
		if CanMerchantRepair() then
			local cost = GetRepairAllCost()
			if GetGuildBankWithdrawMoney() >= cost then
				RepairAllItems(1)
			elseif GetMoney() >= cost then
				RepairAllItems()
			end
		end
	end
	if (config.sellgreys) then
		local profit = 0
		for bag=0, 4 do
			for slot=0,GetContainerNumSlots(bag) do
				local link = GetContainerItemLink(bag, slot)
				if link and select(3, GetItemInfo(link)) == 0 then
					local price = select(11,GetItemInfo(link))
					profit = profit + price
					--ShowMerchantSellCursor(1)
					UseContainerItem(bag, slot)
				end
			end
		end
		if (profit > 0) then
			print(("Sold all trash for %d|cFFF0D440"..GOLD_AMOUNT_SYMBOL.."|r %d|cFFC0C0C0"..SILVER_AMOUNT_SYMBOL.."|r %d|cFF954F28"..COPPER_AMOUNT_SYMBOL.."|r"):format(profit / 100 / 100, (profit / 100) % 100, profit % 100));
		end
	end
end)

local fastloot = CreateFrame("frame",nil)
fastloot:RegisterEvent("LOOT_OPENED")
fastloot:SetScript("OnEvent",function()
	local autoLoot = GetCVar("autoLootDefault") == "0" or true

	if (config.fastloot and (IsShiftKeyDown() == useShift)) then	
		-- SetCVar("autoLootDefault", "0")
		local numitems = GetNumLootItems()
        for i = 1, numitems do
            LootSlot(i)
        end
	end
end)