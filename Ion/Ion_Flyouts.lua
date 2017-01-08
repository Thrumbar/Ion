﻿--Ion, a World of Warcraft® user interface addon.
--Copyright© 2006-2014 Connor H. Chenoweth, aka Maul - All rights reserved.

--/flyout command based on Gello's addon "Select"

-------------------------------------------------------------------------------
-- Localized Lua globals.
-------------------------------------------------------------------------------
local _G = getfenv(0)

-- Functions
local next = _G.next
local pairs = _G.pairs
local tonumber = _G.tonumber
local tostring = _G.tostring
local type = _G.type

-- Libraries
local string = _G.string
local table = _G.table


-------------------------------------------------------------------------------
-- AddOn namespace.
-------------------------------------------------------------------------------

local ION, GDB, CDB, PEW, SPEC, btnGDB, btnCDB, control, A_UPDATE = Ion

local BAR, BUTTON = ION.BAR, ION.BUTTON

local STORAGE = CreateFrame("Frame", nil, UIParent)

local FOBARIndex, FOBTNIndex, ANCHORIndex = {}, {}, {}

local L = LibStub("AceLocale-3.0"):GetLocale("Ion")

local SKIN = LibStub("Masque", true)

local GetContainerNumSlots = _G.GetContainerNumSlots
local GetContainerItemLink = _G.GetContainerItemLink
local GetSpellBookItemName = _G.GetSpellBookItemName
local GetItemInfo = _G.GetItemInfo

local sIndex = ION.sIndex
local cIndex = ION.cIndex
local iIndex = ION.iIndex
local tIndex = ION.tIndex
local ItemCache = IonItemCache

local tooltipScan = IonTooltipScan
local tooltipScanTextLeft2 = IonTooltipScanTextLeft2
local tooltipStrings = {}

local BOOKTYPE_SPELL = _G.BOOKTYPE_SPELL
local BOOKTYPE_PET = _G.BOOKTYPE_PET

local itemTooltips, itemLinks, spellTooltips, companionTooltips = {}, {}, {}, {}
local needsUpdate, scanData = {}, {}
local iconlist = {}
local array = {}


local petIcons = {}


local f = {}  --flyout related helpers

f.rtable = {} -- reusable table where flyout button attributes are accumulated
local rtable = f.rtable

f.filter = {} -- table of search:keyword search functions (f.filter.item(arg))

-- adds a type/value attribute pair to rtable if it's not already there
local function addToTable(actionType,actionValue)
	--for i=1,#rtable,2 do
		--if rtable[i]==actionType and rtable[i+1]==actionValue then
			--return
		--end
	--end
	--tinsert(rtable,actionType)
	--tinsert(rtable,actionValue)
	scanData[actionValue:lower()] = actionType
end


-- returns true if arg and compareTo match. arg is a [Cc][Aa][Ss][Ee]-insensitive pattern
-- so we can't equate them and to get an exact match we need to append ^ and $ to the pattern
local function compare(arg,compareTo,exact)
	return compareTo:match(format("^%s$",arg)) and true
end


--[[ Timer Management ]]
f.timerFrame = CreateFrame("Frame") -- timer independent of main frame visibility
f.timerFrame:Hide()
f.timerTimes = {} -- indexed by arbitrary name, the duration to run the timer
f.timersRunning = {} -- indexed numerically, timers that are running

function f.StartTimer(duration,func)
	local timers = f.timersRunning
	f.timerTimes[func] = duration
	if not tContains(f.timersRunning,func) then
		tinsert(f.timersRunning,func)
	end
	f.timerFrame:Show()
end


f.timerFrame:SetScript("OnUpdate",function(self,elapsed)
	local tick
	local times = f.timerTimes
	local timers = f.timersRunning

	for i=#timers,1,-1 do
		local func = timers[i]
		times[func] = times[func] - elapsed
		if times[func] < 0 then
			tremove(timers,i)
			func()
		end
		tick = true
	end

	if not tick then
		self:Hide()
	end
end)


--[[ Item Cache ]]

f.itemCache = {}
f.bagsToCache = {[0]=true,[1]=true,[2]=true,[3]=true,[4]=true,["Worn"]=true}


local function addToCache(itemID)
	if itemID then
		local name = GetItemInfo(itemID)
		if name then
			f.itemCache[format("item:%d",itemID)] = name:lower()
		else
			f.StartTimer(0.05,f.CacheBags)
			return true
		end
	end
end


function f.CacheBags()
	local cacheComplete = true
	if not f.cacheTimeout or f.cacheTimeout < 10 then
		for bag in pairs(f.bagsToCache) do
			if bag=="Worn" then
				for slot=1,19 do
					local itemID = GetInventoryItemID("player",slot)
					if addToCache(itemID) then
						cacheComplete = false
					end
				end
			else
				for slot=1,GetContainerNumSlots(bag) do
					local itemID = GetContainerItemID(bag,slot)
					if addToCache(itemID) then
						cacheComplete = false
					end
				end
			end
		end
	end
	if cacheComplete then
		f.flyoutsNeedFilled = true
		wipe(f.bagsToCache)
		if f.firstLogin then
			f.firstLogin = nil
			f.FillAttributes()
		end
	else
		f.cacheTimeout = (f.cacheTimeout or 0)+1
	end
end


local exclusions = {}

--- Goes through a data table and removes any items that had been flagged as containing a exclusion keyword.
local function RemoveExclusions(data)
	for spellName,_ in pairs(exclusions) do
		data[spellName] = nil
	end
	wipe(exclusions)
	return data
end

--[[ Filters ]]

-- for arguments without a search, look for items or spells by that name
function f.filter.none(arg)
	-- if a regular item in bags/on person
	if GetItemCount(arg)>0 then
		local _, link = GetItemInfo(arg)
		if link then
			addToTable("item",(link:match("(item:%d+)")))
			return
		end
	end
	-- if a spell
	local spellName,subName = GetSpellInfo(arg)
	if spellName and spellName~="" then
		if subName and subName~="" then
			addToTable("spell",format("%s(%s)",spellName,subName)) -- for Polymorph(Turtle)
		else
			addToTable("spell",spellName)
		end
		return
	end
	-- if a toy
	local toyName = GetItemInfo(arg)
	if toyName and tIndex[toyName] then
		addToTable("item",toyName)
	end
end


--- Filter handler for items
-- item:id will get all items of that itemID
-- item:name will get all items that contain "name" in its name
function BUTTON:filter_item(data)
	local keys, found, mandatory, optional, excluded  = self.flyout.keys, 0, 0, 0
	for ckey in gmatch(keys, "[^,]+") do

		local cmd, arg = (ckey):match("%s*(%p*)(%P+)")
		local itemID = tonumber(arg)
		arg = arg:lower()

		if (cmd == "!") then
			excluded = true
		else
			excluded = false
		end

		if itemID and GetItemCount(itemID)>0 then
			data[itemID] = "item"---addToTable("item",format("item:%d",itemID))
			return
		end
		-- look for arg in itemCache
		for itemID,name in pairs(f.itemCache) do
			if (name:lower()):match(arg) and GetItemCount(name)>0 then
				data[itemID] = "item"--addToTable("item",itemID)
			end
		end
	end
end


--- Filter Handler for Spells
-- spell:id will get all spells of that spellID
-- spell:name will get all spells that contain "name" in its name or its flyout parent
function BUTTON:filter_spell(data)
	local keys, found, mandatory, optional, excluded  = self.flyout.keys, 0, 0, 0

	for ckey in gmatch(keys, "[^,]+") do
		local cmd, arg = (ckey):match("%s*(%p*)(%P+)")

		if (cmd == "!") then
			excluded = true
		else
			excluded = false
		end
--revisit
		if type(arg)=="number" and IsSpellKnown(arg) then
			local name = GetSpellInfo(arg)
			if name then
				data[name:lower()] = "spell"
				--addToTable("spell",name)
				return
			end
		end
		-- look for arg in the spellbook
		for i=1,2 do
			local _,_,offset,numSpells = GetSpellTabInfo(i)
			for j=offset+1, offset+numSpells do
				local spellType,spellID = GetSpellBookItemInfo(j,"spell")
				local name = (GetSpellBookItemName(j,"spell")):lower()
				local isPassive = IsPassiveSpell(j,"spell")
				if name and name:match(arg) and not isPassive then
					if spellType=="SPELL" and IsSpellKnown(spellID) then
						data[name] = "spell"--addToTable("spell",name)
					elseif spellType=="FLYOUT" then
						local _, _, numFlyoutSlots, isFlyoutKnown = GetFlyoutInfo(spellID)
						if isFlyoutKnown then
							for k=1,numFlyoutSlots do
								local _,_,flyoutSpellKnown,flyoutSpellName = GetFlyoutSlotInfo(spellID,k)
								if flyoutSpellKnown then
									addToTable("spell",flyoutSpellName)
								end
							end
						end
					end
				end
			end
		end
	end
	RemoveExclusions(data)
end


---Filter handler for item type
-- type:quest will get all quest items in bags, or those on person with Quest in a type field
-- type:name will get all items that have "name" in its type, subtype or slot name
function BUTTON:filter_type(data)
	local keys, found, mandatory, optional, excluded  = self.flyout.keys, 0, 0, 0

	for ckey in gmatch(keys, "[^,]+") do
		local cmd, arg = (ckey):match("%s*(%p*)(%P+)")
		arg = arg:lower()

		if (cmd == "!") then
			excluded = true
		else
			excluded = false
		end

		if ("quest"):match(arg) then
			-- many quest items don't have "Quest" in a type field, but GetContainerItemQuestInfo
			-- has them flagged as questf.  check those first
			for i=0,4 do
				for j=1,GetContainerNumSlots(i) do
					local isQuestItem, questID, isActive = GetContainerItemQuestInfo(i,j)
					if isQuestItem or questID or isActive then
						 data[(format("item:%d",GetContainerItemID(i,j))):lower()] = "item" --addToTable("item",format("item:%d",GetContainerItemID(i,j)))
					end
				end
			end
		end
		-- some quest items can be marked quest as an item type also
		for itemID,name in pairs(f.itemCache) do
			if GetItemCount(name)>0 then
				local _, _, _, _, _, itemType, itemSubType, _, itemSlot = GetItemInfo(itemID)
				if itemType and ((itemType:lower()):match(arg) or (itemSubType:lower()):match(arg) or (itemSlot:lower()):match(arg)) then
					 data[itemID:lower()] = "item" --addToTable("item",itemID)
				end
			end
		end
	end
	RemoveExclusions(data)
end


--- Filter handler for mounts
-- mount:any, mount:flying, mount:land, mount:favorite, mount:fflying, mount:fland
-- mount:arg filters mounts that include arg in the name or arg="flying" or arg="land" or arg=="any"
function BUTTON:filter_mount(data)
	local keys, found, mandatory, optional, excluded  = self.flyout.keys, 0, 0, 0

	for ckey in gmatch(keys, "[^,]+") do
		local cmd, arg = (ckey):match("%s*(%p*)(%P+)")
		local any = compare(arg,("Any"))
		local flying = compare(arg,"Flying")
		local land = compare(arg,"Land")
		local fflying = compare(arg,"FFlying") or compare(arg,"FavFlying")
		local fland = compare(arg,"FLand") or compare(arg,"FavLand")
		local favorite = compare(arg,"Favorite") or fflying or fland
		arg = arg:lower()

		if (cmd == "!") then
			excluded = true
		else
			excluded = false
		end

		for i,mountID in ipairs(C_MountJournal.GetMountIDs()) do
			local mountName, mountSpellId, mountTexture, _, canSummon, _, isFavorite = C_MountJournal.GetMountInfoByID(mountID)
			local spellName = GetSpellInfo(mountSpellId) -- sometimes mount name isn't same as spell name >:O
			mountName = mountName:lower()
			spellName = spellName:lower()
			if mountName and canSummon then
				local _,_,_,_,mountType = C_MountJournal.GetMountInfoExtraByID(mountID)
				local canFly = mountType==247 or mountType==248
				if (mountName:match(arg) or spellName:match(arg)) and excluded then
					exclusions[spellName] = true
				elseif favorite and isFavorite then
					if (fflying and canFly) or (fland and not canFly) or (not fflying and not fland) then
						data[spellName] = "spell"--addToTable("spell",spellName)
					end
				elseif (flying and canFly) or (land and not canFly) then
					data[spellName] = "spell"--addToTable("spell",spellName)
				elseif any or mountName:match(arg) or spellName:match(arg) then
					data[spellName] = "spell"
				end
			end
		end
		
	end
	RemoveExclusions(data)
end

-- runs func for each ...
local function RunForEach(func,...)
	for i=1,select("#",...) do
		func((select(i,...)))
	end
end

--- Filter handler for professions
-- profession:arg filters professions that include arg in the name or arg="primary" or arg="secondary" or arg="all"
function BUTTON:filter_profession(data)
	f.professions = f.professions or {}
	wipe(f.professions)

	local keys, found, mandatory, optional, excluded  = self.flyout.keys, 0, 0, 0
	local profSpells = {}

	for ckey in gmatch(keys, "[^,]+") do
		local cmd, arg = (ckey):match("%s*(%p*)(%P+)")

		if (cmd == "!") then
			excluded = true
		else
			excluded = false
		end

		RunForEach(function(entry) tinsert(f.professions,entry or false) end, GetProfessions())
		local any = compare(arg,"Any")
		local primaryOnly = compare(arg,"Primary")
		local secondaryOnly = compare(arg,"Secondary")
		arg = arg:lower()
		for index,profession in pairs(f.professions) do
			if profession then
				local name, _, _, _, numSpells, offset = GetProfessionInfo(profession)
				if (name:lower()):match(arg) and excluded then
					exclusions[name:lower()] = true

				elseif (index<3 and primaryOnly) or (index>2 and secondaryOnly) or any or (name:lower()):match(arg) then
					for i=1,numSpells do
						local _, spellID = GetSpellBookItemInfo(offset+i,"professions")
						local spellName = GetSpellInfo(spellID)
						local isPassive = IsPassiveSpell(offset+i,"professions")
						--print(spellName)
						--print(arg)
						if not isPassive then
						tinsert(profSpells, spellName:lower())
							data[spellName:lower()] = "spell"
						end
					end
				end
			end
		end
		--Check exclusions a second time for args that dont trigger earlier.
		for _,name in pairs(profSpells) do
			if (name:lower()):match(arg) and excluded then
				exclusions[name:lower()] = true
			end
		end
	end
	RemoveExclusions(data)
end


--- Filter handler for companion pets
-- pet:arg filters companion pets that include arg in the name or arg="any" or arg="favorite(s)"
function BUTTON:filter_pet(data, arg, rtable)
	local keys, found, mandatory, optional, excluded  = self.flyout.keys, 0, 0, 0
	for ckey in gmatch(keys, "[^,]+") do

		local cmd, arg = (ckey):match("%s*(%p*)(%P+)")
		local any = compare(arg,"Any")
		local favorite = compare(arg,"Favorite")

		if (cmd == "!") then
			excluded = true
		else
			excluded = false
		end


	-- the following can create 150-200k of garbage...why? pets are officially unsupported so this is permitted to stay
		for i=1,C_PetJournal.GetNumPets() do
			local petID,_,owned,customName,_,isFavorite,_,realName, icon = C_PetJournal.GetPetInfoByIndex(i)
			if petID and owned then
				if any or (favorite and isFavorite) or (customName and (customName:lower()):match(arg)) or (realName and (realName:lower()):match(arg)) then

					if ((customName and (customName:lower()):match(arg)) or (realName and (realName:lower()):match(arg))) and excluded then
						exclusions[realName] = true
					else
					--addToTable("macro",format("/summonpet %s",customName or realName))
						data[realName] = "companion"
						petIcons[realName] = icon
					end
				end
			end
		end
	end
	RemoveExclusions(data)
end


---Filter handler for toy items
-- toy:arg filters items from the toybox; arg="favorite" "any" or partial name
function BUTTON:filter_toy(data)
	local keys, found, mandatory, optional, excluded  = self.flyout.keys, 0, 0, 0

	for ckey in gmatch(keys, "[^,]+") do
		local cmd, arg = (ckey):match("%s*(%p*)(%P+)")
		local any = compare(arg,"Any")
		local favorite = compare(arg,"Favorite")
		arg = arg:lower()

		if (cmd == "!") then
			excluded = true
		else
			excluded = false
		end

		if excluded then
			for toyName in pairs(tIndex) do
				if toyName:match(arg) then
					exclusions[toyName:lower()] = true
				end
			end
		elseif favorite then -- toy:favorite
			for toyName,itemID in pairs(tIndex) do
				if C_ToyBox.GetIsFavorite(itemID) then
					data[toyName:lower()] = "item"--addToTable("item",toyName)
				end
			end
		elseif any then -- toy:any
			for toyName in pairs(tIndex) do
				data[toyName:lower()] = "item"--addToTable("item",toyName)
			end
		else -- toy:name
			for toyName in pairs(tIndex) do
				if toyName:match(arg) then
					data[toyName:lower()] = "item"--addToTable("item",toyName)
				end
			end
		end
	end
	RemoveExclusions(data)
end


 --- Sorting fuinction
local function keySort(list)
	wipe(array)

	local i = 0

	for n in pairs(list) do
		tinsert(array, n)
	end

	table.sort(array)

	local sorter = function()
		i = i + 1

		if (array[i] == nil) then
			return nil
		else
			return array[i], list[array[i]]
		end
	end

	return sorter
end


--- Handler for Blizzard flyout spells
function BUTTON:GetBlizzData(data)
	local visible, spellID, isKnown, petIndex, petName, spell, subName
	local _, _, numSlots = GetFlyoutInfo(self.flyout.keys)

	for i=1, numSlots do
		visible = true

		spellID, _, isKnown = GetFlyoutSlotInfo(self.flyout.keys, i)
		petIndex, petName = GetCallPetSpellInfo(spellID)

		if (petIndex and (not petName or petName == "")) then
			visible = false
		end

		if (isKnown and visible) then
			spell, subName = GetSpellInfo(spellID)

			if (subName and #subName > 0) then
				spell = spell.."("..subName..")"
			end

			data[spell] = "blizz"
		end
	end
	return data
end


--- Flyout type handler
function BUTTON:GetDataList(options)
	local tooltip

	wipe(scanData)

	for types in gmatch(self.flyout.types, "%a+[%+]*") do
		tooltip = types:match("%+")

		if (types:find("^b")) then  --Blizzard Flyout
			return self:GetBlizzData(scanData)
		elseif (types:find("^e")) then  --Equipment set
			return self:GetEquipSetData(scanData)
		elseif (types:find("^s")) then  --Spell
			self:filter_spell(scanData)
		elseif (types:find("^i")) then  --Item
			self:filter_item(scanData)
		elseif (types:find("^c")) then  --Companion
			self:filter_pet(scanData)
		elseif (types:find("^f")) then  --toy
			self:filter_toy(scanData)
		elseif (types:find("^m")) then  --Mount
			self:filter_mount(scanData)
		elseif (types:find("^p")) then  --Profession
			self:filter_profession(scanData)
		elseif (types:find("^t")) then  --Item Type
			self:filter_type(scanData)
		end
	end
	return scanData
end

local barsToUpdate = {}

local function updateFlyoutBars(self, elapsed)
	if (not InCombatLockdown()) then  --Workarout for protected taint if UI reload in combat
		local bar = tremove(barsToUpdate)

		if (bar) then
			bar:SetObjectLoc()
			bar:SetPerimeter()
			bar:SetSize()
		else
			self:Hide()
		end
	end
end


local flyoutBarUpdater = CreateFrame("Frame", nil, UIParent)
flyoutBarUpdater:SetScript("OnUpdate", updateFlyoutBars)
flyoutBarUpdater:Hide()


function BUTTON:Flyout_UpdateButtons(init)
	local slot
	local pet = false

	if (self.flyout) then
		local flyout, count, list, button, prefix, macroSet  = self.flyout, 0, ""
		local data = self:GetDataList(flyout.options)

		for _,button in pairs(flyout.buttons) do
			self:Flyout_ReleaseButton(button)
		end

		if (data) then
			for spell, source in keySort(data) do 
				button = self:Flyout_GetButton()

				if (source == "spell" or source =="blizz") then
					if (spell:find("%(")) then
						button.macroshow = spell
					else
						button.macroshow = spell.."()"
					end

					button:SetAttribute("prefix", "/cast ")
					button:SetAttribute("showtooltip", "#showtooltip "..button.macroshow.."\n")

					prefix = "/cast "

				elseif (source == "companion") then
					button.macroshow = ""
					button.macroicon = petIcons[spell]
					button:SetAttribute("prefix", "/summonpet ")
					button:SetAttribute("showtooltip", "")
					button.data.macro_Icon = petIcons[spell]
					button.data.macro_Name = spell
					button:SetAttribute("macro_Icon", petIcons[spell])
					button:SetAttribute("macro_Name", spell)
					prefix = "/summonpet "
					pet = spell

				elseif (source == "item") then
					button.macroshow = spell

					if (IsEquippableItem(spell)) then
						if (self.flyout.keys:find("#%d+")) then
							slot = self.flyout.keys:match("%d+").." "
						end

						if (slot) then
							prefix = "/equipslot "
							button:SetAttribute("slot", slot.." ")
						else
							prefix = "/equip "
						end
					else
						prefix = "/use "
					end

					button:SetAttribute("prefix", prefix)

					if (slot) then
						button:SetAttribute("showtooltip", "#showtooltip "..slot.."\n")
					else
						button:SetAttribute("showtooltip", "#showtooltip "..button.macroshow.."\n")
					end

				elseif (source:find("equipset")) then
					local _, icon = (";"):split(source)
					button.macroshow = spell
					button.data.macro_Equip = spell
					button:SetAttribute("prefix", "/equipset ")
					button:SetAttribute("showtooltip", "")

					prefix = "/equipset "

					if (icon) then
						button.data.macro_Icon = icon
					else
						button.data.macro_Icon = "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK"
					end
				else
					--should never get here
					button.macroshow = ""
					button:SetAttribute("prefix", "")
					button:SetAttribute("showtooltip", "")
				end

				if (slot) then
					button:SetAttribute("macro_Text", button:GetAttribute("prefix").."[nobtn:2] "..slot)
					button:SetAttribute("*macrotext1", prefix.."[nobtn:2] "..slot..button.macroshow)
					button:SetAttribute("flyoutMacro", button:GetAttribute("showtooltip")..button:GetAttribute("prefix").."[nobtn:2] "..slot.."\n/stopmacro [nobtn:2]\n/flyout "..flyout.options)
				elseif (pet) then
					button:SetAttribute("macro_Text", button:GetAttribute("prefix").."[nobtn:2] "..pet)
					button:SetAttribute("*macrotext1", prefix.."[nobtn:2] "..pet)
					button:SetAttribute("flyoutMacro", button:GetAttribute("showtooltip")..button:GetAttribute("prefix").."[nobtn:2] "..pet.."\n/stopmacro [nobtn:2]\n/flyout "..flyout.options)
				else
					button:SetAttribute("macro_Text", button:GetAttribute("prefix").."[nobtn:2] "..button.macroshow)
					button:SetAttribute("*macrotext1", prefix.."[nobtn:2] "..button.macroshow)
					button:SetAttribute("flyoutMacro", button:GetAttribute("showtooltip")..button:GetAttribute("prefix").."[nobtn:2] "..button.macroshow.."\n/stopmacro [nobtn:2]\n/flyout "..flyout.options)
				end

				if (not macroSet and not self.data.macro_Text:find("nobtn:2")) then
					self.data.macro_Text = button:GetAttribute("flyoutMacro"); macroSet = true
				end

				button.data.macro_Text = button:GetAttribute("macro_Text")
				button:MACRO_UpdateParse()
				button:MACRO_Reset()
				button:MACRO_UpdateAll(true)

				list = list..button.id..";"

				count = count + 1
			end
		end

		flyout.bar.objCount = count
		flyout.bar.gdata.objectList = list

		if (not init) then
			tinsert(barsToUpdate, flyout.bar)
			flyoutBarUpdater:Show()
		end
	end
end


function BUTTON:Flyout_UpdateBar()
	self.flyouttop:Hide()
	self.flyoutbottom:Hide()
	self.flyoutleft:Hide()
	self.flyoutright:Hide()

	local flyout, pointA, pointB, hideArrow, shape, columns, pad = self.flyout

	if (flyout.shape and flyout.shape:lower():find("^c")) then
		shape = 2
	else
		shape = 1
	end

	if (flyout.point) then
		pointA = flyout.point:match("%a+"):upper() pointA = ION.Points[pointA] or "RIGHT"
	end

	if (flyout.relPoint) then
		pointB = flyout.relPoint:upper() pointB = ION.Points[pointB] or "LEFT"
	end

	if (flyout.colrad and tonumber(flyout.colrad)) then
		if (shape == 1) then
			columns = tonumber(flyout.colrad)
		elseif (shape == 2) then
			pad = tonumber(flyout.colrad)
		end
	end

	if (flyout.mode and flyout.mode:lower():find("^m")) then
		flyout.mode = "mouse"
	else
		flyout.mode = "click"
	end

	if (flyout.hideArrow and flyout.hideArrow:lower():find("^h")) then
		hideArrow = true
	end

	if (shape) then
		flyout.bar.gdata.shape = shape
	else
		flyout.bar.gdata.shape = 1
	end

	if (columns) then
		flyout.bar.gdata.columns = columns
	else
		flyout.bar.gdata.columns = 12
	end

	if (pad) then
		flyout.bar.gdata.padH = pad
		flyout.bar.gdata.padV = pad
		flyout.bar.gdata.arcStart = 0
		flyout.bar.gdata.arcLength = 359
	else
		flyout.bar.gdata.padH = 0
		flyout.bar.gdata.padV = 0
		flyout.bar.gdata.arcStart = 0
		flyout.bar.gdata.arcLength = 359
	end
	flyout.bar:ClearAllPoints()
	flyout.bar:SetPoint(pointA, self, pointB, 0, 0)
	flyout.bar:SetFrameStrata(self:GetFrameStrata())
	flyout.bar:SetFrameLevel(self:GetFrameLevel()+1)

	if (not hideArrow) then
		if (pointB == "TOP") then
			self.flyout.arrowPoint = "TOP"
			self.flyout.arrowX = 0
			self.flyout.arrowY = 5
			self.flyout.arrow = self.flyouttop
			self.flyout.arrow:Show()
		elseif (pointB == "BOTTOM") then
			self.flyout.arrowPoint = "BOTTOM"
			self.flyout.arrowX = 0
			self.flyout.arrowY = -5
			self.flyout.arrow = self.flyoutbottom
			self.flyout.arrow:Show()
		elseif (pointB == "LEFT") then
			self.flyout.arrowPoint = "LEFT"
			self.flyout.arrowX = -5
			self.flyout.arrowY = 0
			self.flyout.arrow = self.flyoutleft
			self.flyout.arrow:Show()
		elseif (pointB == "RIGHT") then
			self.flyout.arrowPoint = "RIGHT"
			self.flyout.arrowX = 5
			self.flyout.arrowY = 0
			self.flyout.arrow = self.flyoutright
			self.flyout.arrow:Show()
		end
	end

	self:Anchor_Update()

	tinsert(barsToUpdate, flyout.bar)

	flyoutBarUpdater:Show()
end


function BUTTON:Flyout_RemoveButtons()
	for _,button in pairs(self.flyout.buttons) do
		self:Flyout_ReleaseButton(button)
	end
end

function BUTTON:Flyout_RemoveBar()
	self.flyouttop:Hide()
	self.flyoutbottom:Hide()
	self.flyoutleft:Hide()
	self.flyoutright:Hide()

	self:Anchor_Update(true)

	self:Flyout_ReleaseBar(self.flyout.bar)
end

function BUTTON:UpdateFlyout(init)
	local options = self.data.macro_Text:match("/flyout%s(%C+)")
	if (self.flyout) then
		self:Flyout_RemoveButtons()
		self:Flyout_RemoveBar()
	end

	if (options) then
		if (not self.flyout) then
			self.flyout = { buttons = {} }
		end

		local flyout = self.flyout
		flyout.bar = self:Flyout_GetBar()
		flyout.options = options
		flyout.types = select(1, (":"):split(options))
		flyout.keys = select(2, (":"):split(options))
		flyout.shape = select(3, (":"):split(options))
		flyout.point = select(4, (":"):split(options))
		flyout.relPoint = select(5, (":"):split(options))
		flyout.colrad = select(6, (":"):split(options))
		flyout.mode = select(7, (":"):split(options))
		flyout.hideArrow = select(8, (":"):split(options))

		self:Flyout_UpdateButtons(init)
		self:Flyout_UpdateBar()

		if (not self.bar.watchframes) then
			self.bar.watchframes = {}
		end

		self.bar.watchframes[flyout.bar.handler] = true

		ANCHORIndex[self] = true
	else
		ANCHORIndex[self] = nil; self.flyout = nil
	end
end


function BUTTON:Flyout_ReleaseButton(button)
	self.flyout.buttons[button.id] = nil

	button.stored = true

	button.data.macro_Text = ""
	button.data.macro_Equip = false
	button.data.macro_Icon = false

	button.macrospell = nil
	button.macroitem = nil
	button.macroshow = nil
	button.macroBtn = nil
	button.bar = nil

	button:SetAttribute("*macrotext1", nil)
	button:SetAttribute("flyoutMacro", nil)

	button:ClearAllPoints()
	button:SetParent(STORAGE)
	button:SetPoint("CENTER")
	button:Hide()
end


function BUTTON:Flyout_SetData(bar)
	if (bar) then

		self.bar = bar

		self.tooltips = true
		self.tooltipsEnhanced = true
		--self.tooltipsCombat = bar.cdata.tooltipsCombat
		--self:SetFrameStrata(bar.gdata.objectStrata)
		--self:SetScale(bar.gdata.scale)
	end

	self.hotkey:Hide()
	self.macroname:Hide()
	self.count:Show()

	self:RegisterForClicks("AnyUp")

	self.equipcolor = { 0.1, 1, 0.1, 1 }
	self.cdcolor1 = { 1, 0.82, 0, 1 }
	self.cdcolor2 = { 1, 0.1, 0.1, 1 }
	self.auracolor1 = { 0, 0.82, 0, 1 }
	self.auracolor2 = { 1, 0.1, 0.1, 1 }
	self.buffcolor = { 0, 0.8, 0, 1 }
	self.debuffcolor = { 0.8, 0, 0, 1 }
	self.manacolor = { 0.5, 0.5, 1.0 }
	self.rangecolor = { 0.7, 0.15, 0.15, 1 }

	self:SetFrameLevel(4)
	self.iconframe:SetFrameLevel(2)
	self.iconframecooldown:SetFrameLevel(3)
	self.iconframeaurawatch:SetFrameLevel(3)

	self:GetSkinned()
end


function BUTTON:Flyout_PostClick()
	button = self.anchor
	button.data.macro_Text = self:GetAttribute("flyoutMacro")
	button.data.macro_Icon = self:GetAttribute("macro_Icon") or false
	button.data.macro_Name = self:GetAttribute("macro_Name") or nil

	button:MACRO_UpdateParse()
	button:MACRO_Reset()
	button:MACRO_UpdateAll(true)

	self:MACRO_UpdateState()
end

function BUTTON:Flyout_GetButton()
	local id = 1

	for _,button in ipairs(FOBTNIndex) do
		if (button.stored) then
			button.anchor = self
			button.bar = self.flyout.bar
			button.stored = false

			self.flyout.buttons[button.id] = button

			button:Show()
			return button
		end

		id = id + 1
	end

	local button = CreateFrame("CheckButton", "IonFlyoutButton"..id, UIParent, "IonActionButtonTemplate")
	setmetatable(button, { __index = BUTTON })

	button.elapsed = 0

	local objects = ION:GetParentKeys(button)

	for k,v in pairs(objects) do
		local name = (v):gsub(button:GetName(), "")
		button[name:lower()] = _G[v]
	end

	button.class = "flyout"
	button.id = id
	button:SetID(0)
	button:SetToplevel(true)
	button.objTIndex = id
	button.objType = "FLYOUTBUTTON"
	button.data = { macro_Text = "" }

	button.anchor = self
	button.bar = self.flyout.bar
	button.stored = false

	SecureHandler_OnLoad(button)

	button:SetAttribute("type1", "macro")
	button:SetAttribute("*macrotext1", "")

	button:SetScript("PostClick", BUTTON.Flyout_PostClick)
	button:SetScript("OnEnter", function(self) BUTTON.MACRO_OnEnter(self) end)
	button:SetScript("OnLeave", BUTTON.MACRO_OnLeave)
	button:SetScript("OnEvent", self:GetScript("OnEvent"))
	--button:SetScript("OnUpdate", self:GetScript("OnUpdate"))

	button:HookScript("OnShow", function(self) self:MACRO_UpdateButton() self:MACRO_UpdateIcon(); self:MACRO_UpdateState() end)
	button:HookScript("OnHide", function(self) self:MACRO_UpdateButton() self:MACRO_UpdateIcon() self:MACRO_UpdateState() end)

	button:WrapScript(button, "OnClick", [[
			local button = self:GetParent():GetParent()
			button:SetAttribute("macroUpdate", true)
			button:SetAttribute("*macrotext*", self:GetAttribute("flyoutMacro"))
			self:GetParent():Hide()
	]])

	button.SetData = BUTTON.Flyout_SetData
	button:SetData(self.flyout.bar)
	button:SetSkinned(true)
	button:Show()

	self.flyout.buttons[id] = button

	FOBTNIndex[id] = button
	return button
end


function BUTTON:Flyout_ReleaseBar(bar)
	self.flyout.bar = nil

	bar.stored = true
	bar:SetWidth(43)
	bar:SetHeight(43)

	bar:ClearAllPoints()
	bar:SetParent(STORAGE)
	bar:SetPoint("CENTER")

	self.bar.watchframes[bar.handler] = nil
end


function BUTTON:Flyout_GetBar()
	local id = 1

	for _,bar in ipairs(FOBARIndex) do
		if (bar.stored) then
			bar.stored = false
			bar:SetParent(UIParent)
			return bar
		end

		id = id + 1
	end

	local bar = CreateFrame("CheckButton", "IonFlyoutBar"..id, UIParent, "IonBarTemplate")

	setmetatable(bar, { __index = BAR })

	bar.index = id
	bar.class = "bar"
	bar.elapsed = 0
	bar.gdata = { scale = 1 }
	bar.objPrefix = "IonFlyoutButton"

	bar.text:Hide()
	bar.message:Hide()
	bar.messagebg:Hide()

	bar:SetID(id)
	bar:SetWidth(43)
	bar:SetHeight(43)
	bar:SetFrameLevel(2)

	bar:RegisterEvent("PLAYER_ENTERING_WORLD")
	bar:SetScript("OnEvent", function(self) self:SetObjectLoc() self:SetPerimeter() self:SetSize() end)

	bar:Hide()

	bar.handler = CreateFrame("Frame", "IonFlyoutHandler"..id, UIParent, "SecureHandlerStateTemplate, SecureHandlerShowHideTemplate")
	bar.handler:SetAttribute("state-current", "homestate")
	bar.handler:SetAttribute("state-last", "homestate")
	bar.handler:SetAttribute("showstates", "homestate")
	bar.handler:SetScript("OnShow", function() end)
	bar.handler:SetAllPoints(bar)
	bar.handler.bar = bar
	bar.handler.elapsed = 0

	--bar.handler:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 12, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
	--bar.handler:SetBackdropColor(0,0,0,1)
	--bar.handler:SetBackdropBorderColor(0,0,0,1)

	bar.handler:Hide()

	FOBARIndex[id] = bar
	return bar
end


function BUTTON:Anchor_RemoveChild()
	local child = self.flyout.bar and self.flyout.bar.handler

	if (child) then
		self:UnwrapScript(self, "OnEnter")
		self:UnwrapScript(self, "OnLeave")
		self:UnwrapScript(self, "OnClick")
		self:SetAttribute("click-show", nil)

		child:SetAttribute("timedelay", nil)
		child:SetAttribute("_childupdate-onmouse", nil)
		child:SetAttribute("_childupdate-onclick", nil)

		child:UnwrapScript(child, "OnShow")
		child:UnwrapScript(child, "OnHide")
	end
end

function BUTTON:Anchor_UpdateChild()
	local child = self.flyout.bar and self.flyout.bar.handler

	if (child) then
		local mode, delay = self.flyout.mode

		if (mode == "click") then
			self:SetAttribute("click-show", "hide")
			self:WrapScript(self, "OnClick", [[
							if (button == "RightButton") then
								if (self:GetAttribute("click-show") == "hide") then
									self:SetAttribute("click-show", "show")
								else
									self:SetAttribute("click-show", "hide")
								end
								control:ChildUpdate("onclick", self:GetAttribute("click-show"))
							end
							]])

			child:WrapScript(child, "OnShow", [[
							if (self:GetAttribute("timedelay")) then
								self:RegisterAutoHide(self:GetAttribute("timedelay"))
							else
								self:UnregisterAutoHide()
							end
							]])

			child:WrapScript(child, "OnHide", [[ self:GetParent():SetAttribute("click-show", "hide") self:UnregisterAutoHide() ]])

			child:SetAttribute("timedelay", tonumber(delay) or 0)
			child:SetAttribute("_childupdate-onclick", [[ if (message == "show") then self:Show() else self:Hide() end ]] )

			child:SetParent(self)

		elseif (mode == "mouse") then
			self:WrapScript(self, "OnEnter", [[ control:ChildUpdate("onmouse", "enter") ]])
			self:WrapScript(self, "OnLeave", [[ if (not self:IsUnderMouse(true)) then control:ChildUpdate("onmouse", "leave") end ]])

			child:SetAttribute("timedelay", tonumber(delay) or 0)
			child:SetAttribute("_childupdate-onmouse", [[ if (message == "enter") then self:Show() elseif (message == "leave") then self:Hide() end ]] )

			child:WrapScript(child, "OnShow", [[
							if (self:GetAttribute("timedelay")) then
								self:RegisterAutoHide(self:GetAttribute("timedelay"))
							else
								self:UnregisterAutoHide()
							end
							]])

			child:WrapScript(child, "OnHide", [[ self:UnregisterAutoHide() ]])

			child:SetParent(self)
		end
	end
end


function BUTTON:Anchor_Update(reMove)
	if (reMove) then
		self:Anchor_RemoveChild()
	else
		self:Anchor_UpdateChild()
	end
end

local function updateAnchors(self, elapsed)
	if (not InCombatLockdown()) then
		local anchor = tremove(needsUpdate)

		if (anchor) then
			anchor:Flyout_UpdateButtons(nil)
		else
			--collectgarbage() not really needed, but some users complain about memory usage and if they go wild in changing
			--their inventory often and have an item-based flyout then see the huge memory usage spike, they will holler
			--without this call, the Lua garbage collector takes care of the garbage in short time, but a user watching will see it
			self:Hide(); collectgarbage()
		end
	end
end


local anchorUpdater = CreateFrame("Frame", nil, UIParent)
anchorUpdater:SetScript("OnUpdate", updateAnchors)
anchorUpdater:Hide()

local function linkScanOnUpdate(self, elapsed)
	self.elapsed = self.elapsed + elapsed

	-- scan X items per frame draw, where X is the for limit
	for i=1,2 do
		self.link = itemLinks[self.index]
		if (self.link) then
			local name = GetItemInfo(self.link)

			if (name) then
				local tooltip, text = " "
				tooltipScan:SetOwner(control,"ANCHOR_NONE")
				tooltipScan:SetHyperlink(self.link)

				for i,string in ipairs(tooltipStrings) do
					text = string:GetText()
					if (text) then
						tooltip = tooltip..text..","
					end
				end

				itemTooltips[name:lower()] = tooltip:lower()
				self.count = self.count + 1
			end
		end

		self.index = next(itemLinks, self.index)

		if not (self.index) then
			--print("Scanned "..self.count.." items in "..self.elapsed.." seconds")
			self:Hide(); anchorUpdater:Show()
		end
	end
end


local itemScanner = CreateFrame("Frame", nil, UIParent)
itemScanner:SetScript("OnUpdate", linkScanOnUpdate)
itemScanner:Hide()


local function button_PostClick(self,button,down)
	self.macroBtn.config.macro = self:GetAttribute("newMacro")
	self.macroBtn.config.macroIcon = "INTERFACE\\ICONS\\Ability_Ambush"
	self.macroBtn.macroparse = self:GetAttribute("newMacro")
	self.macroBtn.update(self.macroBtn)
end


local function command_flyout(options)
	if (true) then return end

	if (InCombatLockdown()) then
		return
	end

	local button = ION.ClickedButton

	if (button) then
		if (not button.options or button.options ~= options) then
			button:UpdateFlyout(options)
		end
	end
end


local extensions = {
	["/flyout"] = command_flyout,
}


local function ANCHOR_DelayedUpdate(self, elapsed)
	self.elapsed = self.elapsed + elapsed

	if (self.elapsed > 10) then
		for anchor in pairs(ANCHORIndex) do
			tinsert(needsUpdate, anchor)
		end

		anchorUpdater:Show()
		self:Hide()
	end
end


local ANCHOR_LOGIN_Updater = CreateFrame("Frame", nil, UIParent)
ANCHOR_LOGIN_Updater:SetScript("OnUpdate", ANCHOR_DelayedUpdate)
ANCHOR_LOGIN_Updater:Hide()
ANCHOR_LOGIN_Updater.elapsed = 0


---  On event handler
local function controlOnEvent(self, event, ...)
	local unit = ...

	if (event == "EXECUTE_CHAT_LINE") then
		local command, options = (...):match("(/%a+)%s(.+)")

		if (extensions[command]) then extensions[command](options) end

	elseif ((event == "BAG_UPDATE" and PEW )or event =="PLAYER_INVENTORY_CHANGED" and PEW) then
		local bag = ...
		if bag>=0 and bag<=4 then
			f.bagsToCache[bag] = true
			f.StartTimer(0.05,f.CacheBags)
		end

		for anchor in pairs(ANCHORIndex) do
			for types in gmatch(anchor.flyout.types, "%a+[%+]*") do
				if (types:find("^i")) then
					tinsert(needsUpdate, anchor)
				end
			end
		end
		ANCHOR_LOGIN_Updater:Show()

	elseif (event == "LEARNED_SPELL_IN_TAB" or
			event == "CHARACTER_POINTS_CHANGED" or
			event == "PET_STABLE_UPDATE" and PEW) then

		for anchor in pairs(ANCHORIndex) do
			for types in gmatch(anchor.flyout.types, "%a+[%+]*") do
				if (types:find("^s") or types:find("^b")) then
					tinsert(needsUpdate, anchor)
				end
			end
		end

		anchorUpdater:Show()
	elseif (event == "COMPANION_LEARNED" or event == "COMPANION_UPDATE" and PEW) then
		for anchor in pairs(ANCHORIndex) do
			for types in gmatch(anchor.flyout.types, "%a+[%+]*") do
				if (types:find("^c")) then
					tinsert(needsUpdate, anchor)
				end
			end
		end

		anchorUpdater:Show()
	elseif (event == "EQUIPMENT_SETS_CHANGED" and PEW) then
		for anchor in pairs(ANCHORIndex) do
			for types in gmatch(anchor.flyout.types, "%a+[%+]*") do
				if (types:find("^e")) then
					tinsert(needsUpdate, anchor)
				end
			end
		end

		anchorUpdater:Show()
	elseif (event == "ADDON_LOADED" and ... == "Ion") then
		local strings = { tooltipScan:GetRegions() }

		for k,v in pairs(strings) do
			if (v:GetObjectType() == "FontString") then
				tinsert(tooltipStrings, v)
			end
		end

		STORAGE:Hide()
	elseif (event == "PLAYER_LOGIN") then
		--f.TOYS_UPDATED() -- update toy cache
		f.CacheBags()
	
	elseif (event == "PLAYER_ENTERING_WORLD" and not PEW) then
		PEW = true

	--try to delay item flyouts as late as possible so items are recognized as being in inventory
	elseif (event == "UPDATE_INVENTORY_DURABILITY" and not A_UPDATE) then
		ANCHOR_LOGIN_Updater:Show()
		A_UPDATE = true

	elseif ( event == "PLAYER_EQUIPMENT_CHANGED" )then
		local slot, equipped = ...
		if equipped then
			f.bagsToCache.Worn = true
			f.StartTimer(0.05,f.CacheBags)
		end
		ANCHOR_LOGIN_Updater:Show()
	elseif ( event == "TOYS_UPDATED" )then
		--f.TOYS_UPDATED()

		for anchor in pairs(ANCHORIndex) do
			for types in gmatch(anchor.flyout.types, "%a+[%+]*") do
				if (types:find("^f")) then
					tinsert(needsUpdate, anchor)
				end
			end
		end
		ANCHOR_LOGIN_Updater:Show()
	end
end


control = CreateFrame("Frame", nil, UIParent)
control:SetScript("OnEvent", controlOnEvent)
control:RegisterEvent("ADDON_LOADED")
control:RegisterEvent("PLAYER_LOGIN")
control:RegisterEvent("PLAYER_ENTERING_WORLD")
control:RegisterEvent("EXECUTE_CHAT_LINE")
control:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
control:RegisterEvent("BAG_UPDATE")
control:RegisterEvent("PLAYER_INVENTORY_CHANGED")  --outdated?
control:RegisterEvent("UNIT_INVENTORY_CHANGED")
control:RegisterEvent("COMPANION_LEARNED")
control:RegisterEvent("SKILL_LINES_CHANGED")
control:RegisterEvent("LEARNED_SPELL_IN_TAB")
control:RegisterEvent("CHARACTER_POINTS_CHANGED")
control:RegisterEvent("PET_STABLE_UPDATE")
control:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
control:RegisterEvent("EQUIPMENT_SETS_CHANGED")



control:RegisterEvent("SPELLS_CHANGED")
control:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
control:RegisterEvent("TOYS_UPDATED")


--[[


/flyout command -

	This command allows for the creation of a popup menu of items/spells for flyoution to be used by the macro button

		Format -

			/flyout <types>:<keys>:<shape>:<attach point>:<relative point>:<columns|radius>:<click|mouse>

			/flyout s+,i+:teleport,!drake:linear:top:bottom:1:click

		Examples -

			/flyout item:quest item:linear:right:left:6:mouse

			/flyout item+:quest item:circular:center:center:15:click

			/flyout companion:mount:linear:right:left:6

			Most options may be abbreviated -

			/flyout i+:quest item:c:c:c:15:c

		Types:

			item
			spell
			companion

			add + to scan the type's tooltip instead of the type's data

		Keys:

			Comma deliminate as many keys as you want (ex: "quest item,use")

			The "companion" type must have "critter" or "mount" in the key list

			! before a key excludes that key

			~ before a key makes the key optional

		Shapes:

			linear
			circular

		Points:

			left
			right
			top
			bottom
			topleft
			topright
			bottomleft
			bottomright
			center

radius can be negative number
]]--
