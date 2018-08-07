local addon, core = ...
local config = bdCore.config.profile['Bags']
local bordersize = bdCore.config.persistent['General'].border

-- reagent tabs
for i = 1, 2 do
	local tab = _G["BankFrameTab"..i]
	bdCore:StripTextures(tab)
	tab:ClearAllPoints()
	tab:Hide()
end

-- place bag slots in bag container
for k, f in pairs(core.bagslots) do
	local count = _G[f:GetName().."Count"]
	local icon = _G[f:GetName().."IconTexture"]
	local norm = _G[f:GetName().."NormalTexture"]
	f:SetParent(core.bags.bags)
	
	--f:GetChildren():Hide()
	f:ClearAllPoints()
	f:SetWidth(24)
	f:SetHeight(24)
	
	norm:SetAllPoints(f)
	if lastbutton then
		f:SetPoint("LEFT", lastbutton, "RIGHT", bordersize, 0)
	else
		f:SetPoint("TOPLEFT", core.bags.bags, "TOPLEFT", 8, -8)
	end
	count.Show = function() end
	count:Hide()
	
	bdCore:setBackdrop(f)
	bdCore:StripTextures(f)
	f:SetNormalTexture("")
	f:SetPushedTexture("")
	f:SetHighlightTexture("")
	f.IconBorder:SetTexture("")
	--f:GetRegions():Hide()

	icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

	lastbutton = f
	core.bags.bags:SetWidth((24+bordersize)*(getn(core.bagslots))+16)
	core.bags.bags:SetHeight(40)
end

-- set the search box every time it tries to move
hooksecurefunc("ContainerFrame_Update", function(frame, id)
	BagItemSearchBox:ClearAllPoints()
	BagItemSearchBox:SetParent(core.bags)
	BagItemSearchBox:SetPoint("TOPRIGHT", core.bags.sort, "TOPLEFT", -8, -0)
	BagItemSearchBox:SetPoint("BOTTOMLEFT", ContainerFrame1MoneyFrame, "BOTTOMRIGHT", 8, -2)
	--BagItemSearchBoxClearButton:SetPoint("RIGHT", BagItemSearchBox, "RIGHT", -4, 0)
	
	BagItemAutoSortButton:Hide();
	
	core:SkinEditBox(BagItemSearchBox)
end)

BackpackTokenFrameToken1:ClearAllPoints()
BackpackTokenFrameToken1:SetPoint("BOTTOMLEFT", core.bags, "BOTTOMLEFT", 0, 8)
for i = 1, 3 do
	_G["BackpackTokenFrameToken"..i]:SetFrameStrata("TOOLTIP")
	_G["BackpackTokenFrameToken"..i]:SetFrameLevel(5)
	_G["BackpackTokenFrameToken"..i.."Icon"]:SetSize(12,12) 
	_G["BackpackTokenFrameToken"..i.."Icon"]:SetTexCoord(.1,.9,.1,.9) 
	_G["BackpackTokenFrameToken"..i.."Icon"]:SetPoint("LEFT", _G["BackpackTokenFrameToken"..i], "RIGHT", -8, 2) 
	_G["BackpackTokenFrameToken"..i.."Count"]:SetFont(bdCore.media.font, 14)
	if (i ~= 1) then
		_G["BackpackTokenFrameToken"..i]:SetPoint("LEFT", _G["BackpackTokenFrameToken"..(i-1)], "RIGHT", 10, 0)
	end
end
	
ContainerFrame1MoneyFrame:ClearAllPoints()
ContainerFrame1MoneyFrame:Show()
ContainerFrame1MoneyFrame:SetPoint("TOPLEFT", core.bags, "TOPLEFT", 11, -8)
ContainerFrame1MoneyFrame:SetParent(core.bags)

ContainerFrame1MoneyFrame:SetScript("OnEnter", function(self) 
	ShowUIPanel(GameTooltip)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -147, 10)
	
	local total = 0;
	for name, stored in pairs(bdCore.config.persistent.goldtrack) do
		local money, cc = unpack(stored)
		total = total + money
	end
	total = ContainerFrame1MoneyFrame:returnMoney(total)
	GameTooltip:AddDoubleLine("Total Gold",total,1,1,1, 1,1,1)
	GameTooltip:AddLine(" ")
	for name, stored in pairs(bdCore.config.persistent.goldtrack) do
		local money, cc = unpack(stored)
		local moneystring = ContainerFrame1MoneyFrame:returnMoney(money)
		GameTooltip:AddDoubleLine("|c"..cc..name.."|r ",moneystring,1,1,1, 1,1,1)
	end	

	GameTooltip:Show()
end)
ContainerFrame1MoneyFrame:SetScript("OnLeave", function()
	GameTooltip:Hide()
end)

function ContainerFrame1MoneyFrame:returnMoney(money)
	local gold = floor(abs(money / 10000))
	local silver = floor(abs(mod(money / 100, 100)))
	local copper = floor(abs(mod(money, 100)))
	

	local moneyString = "";
	if (gold > 0) then
		moneyString = comma_value(gold).."|cffF0D440g|r";
	end
	if (silver > 0) then
		moneyString = moneyString.." "..silver.."|cffC0C0C0s|r"
	end
	if (copper > 0) then
		moneyString = moneyString.." "..copper.."|cffFF8F32c|r"
	end
	
	return moneyString;
end

function ContainerFrame1MoneyFrame:Update()
	local money = GetMoney()
	local name, r = UnitName("player")
	local class, classFileName = UnitClass("player")
	local color = RAID_CLASS_COLORS[classFileName]
	moneyString = ContainerFrame1MoneyFrame:returnMoney(money)
	
	--bdCore.config.persistent.goldtrack = bdCore.config.persistent.goldtrack or {}
	bdCore.config.persistent.goldtrack[name] = {money, color.colorStr}
end

ContainerFrame1MoneyFrame:SetFrameLevel(10)
ContainerFrame1MoneyFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
ContainerFrame1MoneyFrame:RegisterEvent("PLAYER_MONEY")
ContainerFrame1MoneyFrame:HookScript("OnEvent", function() 
	ContainerFrame1MoneyFrame:Update()
end)

local money = {"Gold","Silver","Copper"}
for k, v in pairs(money) do
	_G["ContainerFrame1MoneyFrame"..v.."ButtonText"]:SetFont(bdCore.media.font,14)
	_G["ContainerFrame1MoneyFrame"..v.."Button"]:EnableMouse(false)
	_G["ContainerFrame1MoneyFrame"..v.."Button"]:SetFrameLevel(8)
end

function core:bagSort()
	
end

SetSortBagsRightToLeft(false)
SetInsertItemsLeftToRight(true)

function core:bagGenerateNew()
	local config = bdCore.config.profile['Bags']


	-- First, let's configure the bags and buttons
	-- for bagID = 0, 4 do
	-- 	local frame = _G["ContainerFrame"..(bagID+1)]
	-- 	local numSlots = GetContainerNumSlots(bagID)
	-- 	for slot = 1, numSlots do
	-- 		local itemButton = _G[frame:GetName().."Item"..slot];
	-- 		itemButton:SetID(slot);
	-- 	end

	-- 	frame:SetID(bagID);
	-- 	frame:Show()
	-- end


	-- todo: expand drastically
	local bagSlots = {}
	local openSlots = {}
	local usedSlots = {}

	for bagID = 4, 0, -1 do
		local numSlots = GetContainerNumSlots(bagID)
		for slot = numSlots, 1, -1 do
			-- local texture, itemCount, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(bagID, numSlots-slot+1);
			local texture, itemCount, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(bagID, numSlots-slot+1);
			local item = _G["ContainerFrame"..(bagID+1).."Item"..slot]
			
			item:ClearAllPoints()
			if (itemLink == nil) then
				openSlots[#openSlots + 1] = {bagID, slot}
				if (bagID == 3) then
					-- print(itemLink, bagID, slot)
				end
			else
				usedSlots[#usedSlots + 1] = {bagID, slot}
			end
		end
	end

	-- merge results now
	for k, v in pairs(usedSlots) do openSlots[(k+#openSlots)] = v end
	bagSlots = openSlots

	-- now loop and display
	local numrows, lastrowitem, numitems, lastitem = 0, nil, 0, nil
	for key, info in pairs(bagSlots) do
		local bagID, slot = unpack(info)
		-- local numSlots = GetContainerNumSlots(bagID)
		-- slot = numSlots - slot + 1

		local item = _G["ContainerFrame"..(bagID+1).."Item"..slot]
		item:SetWidth(config.buttonsize)
		item:SetHeight(config.buttonsize)
		core:Skin(item)
		-- item.text:SetText(bagID..":"..slot)

		-- print(bagID, slot)
		-- 
		if (not lastitem) then
			item:SetPoint("TOPLEFT", core.bags, "TOPLEFT", 10, -30)
			lastrowitem = item
		else
			item:SetPoint("LEFT", lastitem, "RIGHT", -bordersize,0)
			if (numitems == config.buttonsperrow) then
				item:ClearAllPoints()
				item:SetPoint("TOP", lastrowitem, "BOTTOM", 0, bordersize)
				lastrowitem = item
				numrows = numrows + 1
				numitems = 0
			end
		end
		numitems = numitems + 1
		lastitem = item
	end

	-- set bag and bank height
	core.bags:SetHeight(64+(config.buttonsize-bordersize)*(numrows+1))
	core.bags:SetWidth(20+(config.buttonsize-bordersize)*(config.buttonsperrow))
end





function core:bagGenerate(...)
	local config = bdCore.config.profile['Bags']

	local numrows, lastrowitem, numitems, lastitem = 0, nil, 0, nil
	for bagID = 0, 4 do
		local numSlots = GetContainerNumSlots(bagID)
		for slot = 1, numSlots do
			local texture, itemCount, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(bagID, slot);
			-- print(bagID, slot, texture, itemLink)

			local item = _G["ContainerFrame"..(bagID+1).."Item"..slot]
			item:ClearAllPoints()
			-- item:Hide()
			-- local texture, itemCount, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(id, slot);

			-- if (quality == nil or quality > 0) then
			-- 	corePack[#corePack+1] = item
			-- else
			-- 	trashPack[#trashPack+1] = item
			-- end

			item:SetWidth(config.buttonsize)
			item:SetHeight(config.buttonsize)
			core:Skin(item)
			
			if (not lastitem) then
				item:SetPoint("TOPLEFT", core.bags, "TOPLEFT", 10, -30)
				lastrowitem = item
			else
				item:SetPoint("LEFT", lastitem, "RIGHT", -bordersize,0)
				if (numitems == config.buttonsperrow) then
					item:ClearAllPoints()
					item:SetPoint("TOP", lastrowitem, "BOTTOM", 0, bordersize)
					lastrowitem = item
					numrows = numrows + 1
					numitems = 0
				end
			end
			numitems = numitems + 1
			lastitem = item
		end
	end

	-- local numrows, lastrowitem, numitems, lastitem = 0, nil, 0, nil
	-- for slot, item in pairs(corePack) do
	-- -- 	-- print(item:GetName())
	-- -- 	item:Show()
	-- -- 	item:ClearAllPoints()
		
	-- end
	
	-- set bag and bank height
	core.bags:SetHeight(64+(config.buttonsize-bordersize)*(numrows+1))
	core.bags:SetWidth(20+(config.buttonsize-bordersize)*(config.buttonsperrow))
end

