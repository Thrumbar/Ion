--Ion Menu Bar, a World of Warcraft® user interface addon.
--Copyright© 2006-2014 Connor H. Chenoweth, aka Maul - All rights reserved.

--Most of this code is based off of the 7.0 version of Blizzard's
-- MainMenuBarMicroButtons.lua & MainMenuBarMicroButtons.xml files 


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


local ION, GDB, CDB, PEW = Ion

ION.MENUIndex = {}

local MENUIndex = ION.MENUIndex

local menubarsGDB, menubarsCDB, menubtnsGDB, menubtnsCDB

local ANCHOR = setmetatable({}, { __index = CreateFrame("Frame") })

local STORAGE = CreateFrame("Frame", nil, UIParent)

local L = LibStub("AceLocale-3.0"):GetLocale("Ion")

IonMenuGDB = {
	menubars = {},
	menubtns = {},
	scriptProfile = false,
	firstRun = true,
}

IonMenuCDB = {
	menubars = {},
	menubtns = {},
}

local gDef = {
	snapTo = false,
	snapToFrame = false,
	snapToPoint = false,
	point = "BOTTOMRIGHT",
	x = -154.5,
	y = 33,
}

local menuElements = {}
local addonData, sortData = {}, {}

local sort = table.sort
local format = string.format

local GetAddOnInfo = _G.GetAddOnInfo
local GetAddOnMemoryUsage = _G.GetAddOnMemoryUsage
local GetAddOnCPUUsage = _G.GetAddOnCPUUsage
local GetScriptCPUUsage = _G.GetScriptCPUUsage
local UpdateAddOnMemoryUsage = _G.UpdateAddOnMemoryUsage
local UpdateAddOnCPUUsage = _G.UpdateAddOnCPUUsage

local GetParentKeys = ION.GetParentKeys

local defGDB, defCDB = CopyTable(IonMenuGDB), CopyTable(IonMenuCDB)

local configData = {
	stored = false,
}


---  This replaces the Blizzard Flash function that causes massive taint when used.
-- pram: self  - the frame to create animation layer.  This layer should have a "$parentFlash" texture layer to it
function ION.CreateAnimationLayer(self)
	local frame = _G[self:GetName().."Flash"]
	frame:SetAlpha(0)
	frame:Show()

	local flasher = frame:CreateAnimationGroup()
	flasher:SetLooping("REPEAT")

	-- Flashing in
	local fade1 = flasher:CreateAnimation("Alpha")
	fade1:SetDuration(1)
	fade1:SetSmoothing("IN")
	--fade1:SetChange(1)
	fade1:SetFromAlpha(0)
	fade1:SetToAlpha(1)
	fade1:SetOrder(1)

	-- Holding it visible for 1 second
	--fade1:SetEndDelay(.5)

	-- Flashing out
	local fade2 = flasher:CreateAnimation("Alpha")
	fade2:SetDuration(1)
	fade2:SetSmoothing("OUT")
	--fade2:SetChange(-1)
	fade2:SetFromAlpha(1)
	fade2:SetToAlpha(0)
	fade2:SetOrder(3)

	-- Holding it for 1 second before calling OnFinished
	--fade2:SetEndDelay(.5)

	flasher:SetScript("OnFinished", function() f:SetAlpha(0) end)

	self.Animate = flasher
end


--- Toggle for the flash animation layer
-- pram: self - Layer contining the animation layer
-- pram: control - Stop- stops the animation, any other command start it
function IMicroButtonPulse(self, control)
	if control == "Stop" then
		self.Animate:Stop()
	else
		self.Animate:Play()
	end
end


--- Updates the microbuttons and sets the textures or if it is currently unavailable.
--   The :Enable() & :Disable() blocks have CombatLockdown tests to prevent taint.
local function updateMicroButtons()
	local playerLevel = _G.UnitLevel("player")
	local factionGroup = _G.UnitFactionGroup("player")

	if ( factionGroup == "Neutral" ) then
		IonGuildButton.factionGroup = factionGroup
		IonLFDButton.factionGroup = factionGroup
	else
		IonGuildButton.factionGroup = nil
		IonLFDButton.factionGroup = nil
	end

	if (IonCharacterButton and CharacterFrame:IsShown()) then
		IonCharacterButton:SetButtonState("PUSHED", true)
		ION.CharacterButton_SetPushed(IonCharacterButton)
	else
		IonCharacterButton:SetButtonState("NORMAL")
		ION.CharacterButton_SetNormal(IonCharacterButton)
	end

	if (SpellBookFrame and SpellBookFrame:IsShown()) then
		IonSpellbookButton:SetButtonState("PUSHED", true)
	else
		IonSpellbookButton:SetButtonState("NORMAL")
	end

	if (PlayerTalentFrame and PlayerTalentFrame:IsShown()) then
		IonTalentButton:SetButtonState("PUSHED", true)
		IMicroButtonPulse(IonTalentButton, "Stop")
		IonTalentMicroButtonAlert:Hide()
	else
		--if ( playerLevel < _G.SHOW_SPEC_LEVEL ) then
		if ( playerLevel < _G.SHOW_SPEC_LEVEL or (IsKioskModeEnabled() and select(2, UnitClass("player")) ~= "DEMONHUNTER") ) then

			if not InCombatLockdown() then 
				IonTalentButton:Disable() 
				if (IsKioskModeEnabled()) then
					SetKioskTooltip(TalentMicroButton);
				end
			end
		else
			if not InCombatLockdown() then IonTalentButton:Enable() end
			IonTalentButton:SetButtonState("NORMAL")
		end
	end

	if (  WorldMapFrame and WorldMapFrame:IsShown() ) then
		IonQuestLogButton:SetButtonState("PUSHED", true)
	else
		IonQuestLogButton:SetButtonState("NORMAL")
	end

	if ( ( GameMenuFrame and GameMenuFrame:IsShown() ) 
		or ( InterfaceOptionsFrame:IsShown()) 
		or ( KeyBindingFrame and KeyBindingFrame:IsShown()) 
		or ( MacroFrame and MacroFrame:IsShown()) ) then
		IonLatencyButton:SetButtonState("PUSHED", true)
		ION.LatencyButton_SetPushed(IonLatencyButton)
	else 
		IonLatencyButton:SetButtonState("NORMAL")
		ION.LatencyButton_SetNormal(IonLatencyButton)
	end

	ION.updateTabard()
	--if ( _G.IsTrialAccount() or (_G.IsVeteranTrialAccount() and not _G.IsInGuild()) or factionGroup == "Neutral" ) then
	if ( _G.IsTrialAccount() or (_G.IsVeteranTrialAccount() and not _G.IsInGuild()) or factionGroup == "Neutral" or _G.IsKioskModeEnabled() ) then
		IonGuildButton:Disable()
			if (_G.IsKioskModeEnabled()) then
			_G.SetKioskTooltip(GuildMicroButton);--Check
		end
	elseif ( ( GuildFrame and GuildFrame:IsShown() ) or ( LookingForGuildFrame and LookingForGuildFrame:IsShown() ) ) then
		if not InCombatLockdown() then
			IonGuildButton:Enable()
		end
		IonGuildButton:SetButtonState("PUSHED", true)
		IonGuildButtonTabard:SetPoint("TOPLEFT", -1, -1)
		IonGuildButtonTabard:SetAlpha(0.70)
	else
		if not InCombatLockdown() then
			IonGuildButton:Enable()
		end
		IonGuildButton:SetButtonState("NORMAL")
		IonGuildButtonTabard:SetPoint("TOPLEFT", 0, 0)
		IonGuildButtonTabard:SetAlpha(1)	
		if ( _G.IsInGuild() ) then
			IonGuildButton.tooltipText = MicroButtonTooltipText(_G.GUILD, "TOGGLEGUILDTAB")
			IonGuildButton.newbieText = _G.NEWBIE_TOOLTIP_GUILDTAB
		else
			IonGuildButton.tooltipText = MicroButtonTooltipText(_G.LOOKINGFORGUILD, "TOGGLEGUILDTAB")
			IonGuildButton.newbieText = _G.NEWBIE_TOOLTIP_LOOKINGFORGUILDTAB
		end
	end

	if ( PVEFrame and PVEFrame:IsShown() ) then
		IonLFDButton:SetButtonState("PUSHED", true)
	else
		--if ( playerLevel < IonLFDButton.minLevel or factionGroup == "Neutral" ) then
		if ( _G.IsKioskModeEnabled() or playerLevel < LFDMicroButton.minLevel or factionGroup == "Neutral" ) then
			if (IsKioskModeEnabled()) then
				SetKioskTooltip(LFDMicroButton);
			end
			if not InCombatLockdown() then IonLFDButton:Disable() end
		else
			if not InCombatLockdown() then IonLFDButton:Enable() end
			IonLFDButton:SetButtonState("NORMAL")
		end
	end

	if ( HelpFrame and HelpFrame:IsShown() ) then
		IonHelpButton:SetButtonState("PUSHED", true)
	else
		IonHelpButton:SetButtonState("NORMAL")
	end

	if ( AchievementFrame and AchievementFrame:IsShown() ) then
		IonAchievementButton:SetButtonState("PUSHED", true)
	else
		if ( ( _G.HasCompletedAnyAchievement() or _G.IsInGuild() ) and _G.CanShowAchievementUI() ) then
			if not InCombatLockdown() then IonAchievementButton:Enable() end
			IonAchievementButton:SetButtonState("NORMAL")
		else
			if not InCombatLockdown() then IonAchievementButton:Disable() end
		end
	end


--	EJMicroButton_UpdateDisplay();  --New??

	if ( EncounterJournal and EncounterJournal:IsShown() ) then
		IonEJButton:SetButtonState("PUSHED", true)
		IMicroButtonPulse(IonEJButton, "Stop")
		IonLFDMicroButtonAlert:Hide()
	else
		if ( playerLevel < IonEJButton.minLevel or factionGroup == "Neutral" ) then
			if not InCombatLockdown() then IonEJButton:Disable() end
			EJMicroButton_ClearNewAdventureNotice()  --CHECK
		else
			 if not InCombatLockdown() then IonEJButton:Enable() end
			IonEJButton:SetButtonState("NORMAL")
		end
	end

	if ( CollectionsJournal and CollectionsJournal:IsShown() ) then
		if not InCombatLockdown() then IonCollectionsButton:Enable() end
		IonCollectionsButton:SetButtonState("PUSHED", true)
		IMicroButtonPulse(IonCollectionsButton, "Stop")
		IonCollectionsMicroButtonAlert:Hide()
	else
		if not InCombatLockdown() then IonCollectionsButton:Enable() end
		IonCollectionsButton:SetButtonState("NORMAL")
	end

	if ( StoreFrame and StoreFrame_IsShown() ) then
		IonStoreButton:SetButtonState("PUSHED", true)
	else
		IonStoreButton:SetButtonState("NORMAL")
	end

	if ( C_StorePublic.IsEnabled() ) then
		IonLatencyButton:SetPoint("BOTTOMLEFT", IonStoreButton, "BOTTOMRIGHT", -3, 0)
		IonHelpButton:Hide()
		IonStoreButton:Show()
	else
		IonLatencyButton:SetPoint("BOTTOMLEFT", IonEJButton, "BOTTOMRIGHT", -3, 0)
		IonHelpButton:Show()
		IonStoreButton:Hide()
	end

	if (  _G.GameLimitedMode_IsActive() ) then
		IonStoreButton.disabledTooltip = _G.ERR_FEATURE_RESTRICTED_TRIAL
		if not InCombatLockdown() then IonStoreButton:Disable() end
	elseif (  _G.C_StorePublic.IsDisabledByParentalControls() ) then
		IonStoreButton.disabledTooltip =  _G.BLIZZARD_STORE_ERROR_PARENTAL_CONTROLS
		 if not InCombatLockdown() then IonStoreButton:Disable() end
	else
		IonStoreButton.disabledTooltip = nil
		if not InCombatLockdown() then IonStoreButton:Enable() end
	end
end
ION.updateMicroButtons = updateMicroButtons


function ION.AchievementButton_OnEvent(self, event, ...)
	if (IsKioskModeEnabled()) then
		return;
	end
	if ( event == "UPDATE_BINDINGS" ) then
		self.tooltipText = MicroButtonTooltipText(_G.ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT")
	else
		updateMicroButtons()
	end
end


function ION.GuildButton_OnEvent(self, event, ...)
	if (IsKioskModeEnabled()) then
		return;
	end

	if ( event == "UPDATE_BINDINGS" ) then
		if ( IsInGuild() ) then
			IonGuildButton.tooltipText = MicroButtonTooltipText(_G.GUILD, "TOGGLEGUILDTAB")
		else
			IonGuildButton.tooltipText = MicroButtonTooltipText(_G.LOOKINGFORGUILD, "TOGGLEGUILDTAB")
		end
	elseif ( event == "PLAYER_GUILD_UPDATE" or event == "NEUTRAL_FACTION_SELECT_RESULT" ) then
		IonGuildButtonTabard.needsUpdate = true
		updateMicroButtons()
	end
end


--- Updates the guild tabard icon on the menu bar
-- params: forceUpdate - (boolean) True- forces an update reguardless if has been set to need updateing
function ION.updateTabard(forceUpdate)
	local tabard = IonGuildButtonTabard
	if ( not tabard.needsUpdate and not forceUpdate ) then
		return
	end
	-- switch textures if the guild has a custom tabard	
	local emblemFilename = select(10, GetGuildLogoInfo())
	if ( emblemFilename ) then
		if ( not tabard:IsShown() ) then
			local button = IonGuildButton
			button:SetNormalTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Up")
			button:SetPushedTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Down")
			-- no need to change disabled texture, should always be available if you're in a guild
			tabard:Show()
		end
		SetSmallGuildTabardTextures("player", tabard.emblem, tabard.background)
	else
		if ( tabard:IsShown() ) then
			local button = IonGuildButton
			button:SetNormalTexture("Interface\\Buttons\\UI-MicroButton-Socials-Up")
			button:SetPushedTexture("Interface\\Buttons\\UI-MicroButton-Socials-Down")
			button:SetDisabledTexture("Interface\\Buttons\\UI-MicroButton-Socials-Disabled")
			tabard:Hide()
		end
	end
	tabard.needsUpdate = nil
end


function ION.CharacterButton_OnLoad(self)
	self:SetNormalTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Up")
	self:SetPushedTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Down")
	self:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight")
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE")
	self:RegisterEvent("UPDATE_BINDINGS")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.tooltipText = MicroButtonTooltipText(_G.CHARACTER_BUTTON, "TOGGLECHARACTER0")
	self.newbieText = _G.NEWBIE_TOOLTIP_CHARACTER

	menuElements[#menuElements+1] = self
end


function ION.CharacterButton_OnEvent(self, event, ...)
	if ( event == "UNIT_PORTRAIT_UPDATE" ) then
		local unit = ...
		if ( not unit or unit == "player" ) then
			_G.SetPortraitTexture(IonCharacterButtonPortrait, "player")
		end
		return
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		_G.SetPortraitTexture(IonCharacterButtonPortrait, "player")
	elseif ( event == "UPDATE_BINDINGS" ) then
		self.tooltipText = MicroButtonTooltipText(_G.CHARACTER_BUTTON, "TOGGLECHARACTER0")
	end
end


function ION.CharacterButton_SetPushed(self)
	IonCharacterButtonPortrait:SetTexCoord(0.2666, 0.8666, 0, 0.8333)
	IonCharacterButtonPortrait:SetAlpha(0.5)
end


function ION.CharacterButton_SetNormal(self)
	IonCharacterButtonPortrait:SetTexCoord(0.2, 0.8, 0.0666, 0.9)
	IonCharacterButtonPortrait:SetAlpha(1.0)
end




--[[New

function MainMenuMicroButton_SetPushed()
	MainMenuMicroButton:SetButtonState("PUSHED", true);
end

function MainMenuMicroButton_SetNormal()
	MainMenuMicroButton:SetButtonState("NORMAL");
end
--]]

function ION.TalentButton_OnEvent(self, event, ...)
	if (IsKioskModeEnabled()) then
		return;
	end
	if (event == "PLAYER_LEVEL_UP") then
		local level = ...
		if (level == _G.SHOW_SPEC_LEVEL) then
			IMicroButtonPulse(self)
			ION.MainMenuMicroButton_ShowAlert(IonTalentMicroButtonAlert, _G.TALENT_MICRO_BUTTON_SPEC_TUTORIAL)
		elseif (level == _G.SHOW_TALENT_LEVEL) then
			IMicroButtonPulse(self)
			ION.MainMenuMicroButton_ShowAlert(IonTalentMicroButtonAlert, _G.TALENT_MICRO_BUTTON_TALENT_TUTORIAL)
		end
	elseif ( event == "PLAYER_SPECIALIZATION_CHANGED") then
		-- If we just unspecced, and we have unspent talent points, it's probably spec-specific talents that were just wiped.  Show the tutorial box.
		local unit = ...
		if(unit == "player" and _G.GetSpecialization() == nil and _G.GetNumUnspentTalents() > 0) then
			ION.MainMenuMicroButton_ShowAlert(IonTalentMicroButtonAlert, _G.TALENT_MICRO_BUTTON_UNSPENT_TALENTS)
		end
	elseif ( event == "PLAYER_TALENT_UPDATE" or event == "NEUTRAL_FACTION_SELECT_RESULT" ) then
		updateMicroButtons()
		
		-- On the first update from the server, flash the button if there are unspent points
		-- Small hack: GetNumSpecializations should return 0 if talents haven't been initialized yet
		if (not self.receivedUpdate and _G.GetNumSpecializations(false) > 0) then
			self.receivedUpdate = true
			local shouldPulseForTalents = _G.GetNumUnspentTalents() > 0 and not _G.AreTalentsLocked()
			if (UnitLevel("player") >= _G.SHOW_SPEC_LEVEL and (not _G.GetSpecialization() or shouldPulseForTalents)) then
				IMicroButtonPulse(self)
			end
		end
	elseif ( event == "UPDATE_BINDINGS" ) then
		self.tooltipText =  MicroButtonTooltipText(_G.TALENTS_BUTTON, "TOGGLETALENTS")
	elseif ( event == "PLAYER_CHARACTER_UPGRADE_TALENT_COUNT_CHANGED" ) then
		local prev, current = ...
		if ( prev == 0 and current > 0 ) then
			IMicroButtonPulse(self)
			ION.MainMenuMicroButton_ShowAlert(IonTalentMicroButtonAlert,_G. TALENT_MICRO_BUTTON_TALENT_TUTORIAL)
		elseif ( prev ~= current ) then
			IMicroButtonPulse(self)
			ION.MainMenuMicroButton_ShowAlert	(IonTalentMicroButtonAlert, _G.TALENT_MICRO_BUTTON_UNSPENT_TALENTS)
		end
	elseif (event == "PLAYER_ENTERING_WORLD") then
		updateMicroButtons()
	end
end


do
	local function SafeSetCollectionJournalTab(tab)
		if  InCombatLockdown() then return end
		if CollectionsJournal_SetTab then
			CollectionsJournal_SetTab(CollectionsJournal, tab)
		else
			SetCVar("petJournalTab", tab)
		end
	end


	function ION.CollectionsButton_OnEvent(self, event, ...)
		if ( event == "HEIRLOOMS_UPDATED" ) then
			local itemID, updateReason = ...
			if itemID and updateReason == "NEW" then
				if _G.MainMenuMicroButton_ShowAlert(IonCollectionsMicroButtonAlert, _G.HEIRLOOMS_MICRO_BUTTON_SPEC_TUTORIAL, _G.LE_FRAME_TUTORIAL_HEIRLOOM_JOURNAL) then
					IMicroButtonPulse(self)
					SafeSetCollectionJournalTab(4)
				end
			end
		elseif ( event == "PET_JOURNAL_NEW_BATTLE_SLOT" ) then
			IMicroButtonPulse(self)
			_G.MainMenuMicroButton_ShowAlert(IonCollectionsMicroButtonAlert, _G.COMPANIONS_MICRO_BUTTON_NEW_BATTLE_SLOT)
			SafeSetCollectionJournalTab(2)
		elseif ( event == "TOYS_UPDATED" ) then
			local itemID, new = ...
			if itemID and new then		
				if _G.MainMenuMicroButton_ShowAlert(IonCollectionsMicroButtonAlert, _G.TOYBOX_MICRO_BUTTON_SPEC_TUTORIAL, _G.LE_FRAME_TUTORIAL_TOYBOX) then
					IMicroButtonPulse(self)
					SafeSetCollectionJournalTab(3)
				end
			end
		else
			self.tooltipText = MicroButtonTooltipText(_G.COLLECTIONS, "TOGGLECOLLECTIONS")
			self.newbieText = _G.NEWBIE_TOOLTIP_MOUNTS_AND_PETS
			updateMicroButtons()
		end
	end
	
end


-- Encounter Journal
function ION.EJButton_OnLoad(self)
	LoadMicroButtonTextures(self, "EJ")
	_G.SetDesaturation(self:GetDisabledTexture(), true)
	self.tooltipText = MicroButtonTooltipText(_G.ENCOUNTER_JOURNAL, "TOGGLEENCOUNTERJOURNAL")
	self.newbieText = _G.NEWBIE_TOOLTIP_ENCOUNTER_JOURNAL
	if (IsKioskModeEnabled()) then
		self:Disable();
	end

	self.minLevel = math.min(_G.SHOW_LFD_LEVEL, _G.SHOW_PVP_LEVEL);

	--events that can trigger a refresh of the adventure journal
	self:RegisterEvent("VARIABLES_LOADED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	ION.CreateAnimationLayer(self)
	menuElements[#menuElements+1] = self
end


function ION.EJButton_OnEvent(self, event, ...)
	if (IsKioskModeEnabled()) then
		return;
	end

	local arg1 = ...
	if( event == "UPDATE_BINDINGS" ) then
		self.tooltipText = MicroButtonTooltipText(_G.ADVENTURE_JOURNAL, "TOGGLEENCOUNTERJOURNAL")
		self.newbieText = _G.NEWBIE_TOOLTIP_ENCOUNTER_JOURNAL
		updateMicroButtons()
	elseif( event == "VARIABLES_LOADED" ) then
		self:UnregisterEvent("VARIABLES_LOADED");
		self.varsLoaded = true;
	
		local showAlert = GetCVarBool("showAdventureJournalAlerts")
		if( showAlert ) then
			local lastTimeOpened = tonumber(GetCVar("advJournalLastOpened"))
			if ( UnitLevel("player") >= IonEJButton.minLevel and _G.UnitFactionGroup("player") ~= "Neutral" ) then		
				if ( _G.GetServerTime() - lastTimeOpened > _G.EJ_ALERT_TIME_DIFF ) then
					IonEJMicroButtonAlert:Show()
					IMicroButtonPulse(IonEJButton)
				end
			
				if ( lastTimeOpened ~= 0 ) then
					SetCVar("advJournalLastOpened", GetServerTime() )
				end
			end
			
			EJMicroButton_UpdateAlerts(true)
		end
		
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD");
		self.playerEntered = true;
		-- _G.C_AdventureJournal.UpdateSuggestions()	
	elseif ( event == "UNIT_LEVEL" and arg1 == "player" ) then		
		EJMicroButton_UpdateNewAdventureNotice(true)  --Check
	elseif event == "PLAYER_AVG_ITEM_LEVEL_UPDATE" then
		local playerLevel = _G.UnitLevel("player")
		if ( playerLevel == _G.MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]) then
			EJMicroButton_UpdateNewAdventureNotice(false)--Check
		end
	elseif ( event == "ZONE_CHANGED_NEW_AREA" ) then
		self:UnregisterEvent("ZONE_CHANGED_NEW_AREA");
		self.zoneEntered = true;
	end

	if( event == "PLAYER_ENTERING_WORLD" or event == "VARIABLES_LOADED" or event == "ZONE_CHANGED_NEW_AREA" ) then
		if( self.playerEntered and self.varsLoaded and self.zoneEntered) then
			EJMicroButton_UpdateDisplay();
			if( self:IsEnabled() ) then
				C_AdventureJournal.UpdateSuggestions();
				
				local showAlert = not GetCVarBool("hideAdventureJournalAlerts");
				if( showAlert ) then
					-- display alert if the player hasn't opened the journal for a long time
					local lastTimeOpened = tonumber(GetCVar("advJournalLastOpened"));
					if ( GetServerTime() - lastTimeOpened > EJ_ALERT_TIME_DIFF ) then
						IonEJMicroButtonAlert:Show();
						IMicroButtonPulse(IonEJButton);
					end

					if ( lastTimeOpened ~= 0 ) then
						SetCVar("advJournalLastOpened", GetServerTime() );
					end
					
					EJMicroButton_UpdateAlerts(true);
				end
			end
		end
	end
end


local function EJMicroButton_UpdateNewAdventureNotice(levelUp)
	if ( IonEJButton:IsEnabled() and _G.C_AdventureJournal.UpdateSuggestions(levelUp) ) then
		if( not EncounterJournal or not EncounterJournal:IsShown() ) then
			IonEJButton.Flash:Show()
			IonEJButton.NewAdventureNotice:Show()
		end
	end
end


local function EJMicroButton_ClearNewAdventureNotice()
	IonEJButton.Flash:Hide()
	IonEJButton.NewAdventureNotice:Hide()
end

local function EJMicroButton_UpdateDisplay()
	local frame = EJMicroButton;
	if ( EncounterJournal and EncounterJournal:IsShown() ) then
		frame:SetButtonState("PUSHED", true);
	else
		local disabled = not C_AdventureJournal.CanBeShown();
		if ( IsKioskModeEnabled() or disabled ) then
			frame:Disable();
			if (IsKioskModeEnabled()) then
				SetKioskTooltip(frame);
			elseif ( disabled ) then
				frame.disabledTooltip = FEATURE_NOT_YET_AVAILABLE;
			end
			EJMicroButton_ClearNewAdventureNotice();
		else
			frame:Enable();
			frame:SetButtonState("NORMAL");
		end
	end
end

local function EJMicroButton_UpdateAlerts( flag )
	if ( flag ) then
		IonEJButton:RegisterEvent("UNIT_LEVEL")
		IonEJButton:RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE")
		EJMicroButton_UpdateNewAdventureNotice(false)
	else
		IonEJButton:UnregisterEvent("UNIT_LEVEL")
		IonEJButton:UnregisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE")
		EJMicroButton_ClearNewAdventureNotice()
	end
end


--- This adds a frame element to the table.
function ION.AddMenuElement(self)
	menuElements[#menuElements+1] = self
end


function ION.MainMenuMicroButton_ShowAlert(alert, text, tutorialIndex)
	if alert == TalentMicroButtonAlert then alert = IonTalentMicroButtonAlert end

	alert.Text:SetText(text)
	alert:SetHeight(alert.Text:GetHeight()+42)
	alert.tutorialIndex = tutorialIndex
	--LDB alert:Show()
	return alert:IsShown()
end


function ION.LatencyButton_OnLoad(self)
	self.overlay = _G[self:GetName().."Overlay"]
	self.overlay:SetWidth(self:GetWidth()+1)
	self.overlay:SetHeight(self:GetHeight())

	self.tooltipText = MicroButtonTooltipText(_G.MAINMENU_BUTTON, "TOGGLEGAMEMENU")
	self.newbieText = _G.NEWBIE_TOOLTIP_MAINMENU

	self.hover = nil
	self.updateInterval = 0
	--self.elapsed = 0

	self:RegisterForClicks("LeftButtonDown", "RightButtonDown", "LeftButtonUp", "RightButtonUp")
	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("UPDATE_BINDINGS")

	menuElements[#menuElements+1] = self

end


function ION.LatencyButton_OnEvent(self, event, ...)
	if (event == "ADDON_LOADED" and ...=="Ion-MenuBar") then
		self.lastStart = 0
		if (GDB) then
			self.enabled = GDB.scriptProfile
		end
		GameMenuFrame:HookScript("OnShow", ION.LatencyButton_SetPushed)
		GameMenuFrame:HookScript("OnHide", ION.LatencyButton_SetNormal)
	end

	self.tooltipText = MicroButtonTooltipText(_G.MAINMENU_BUTTON, "TOGGLEGAMEMENU")
end


function ION.LatencyButton_OnClick(self, button, down)
	if (button == "RightButton") then
		if (IsShiftKeyDown()) then
			if (GDB.scriptProfile) then
				SetCVar("scriptProfile", "0")
				GDB.scriptProfile = false
			else
				SetCVar("scriptProfile", "1")
				GDB.scriptProfile = true

			end

			ReloadUI()
		end

		if (not down) then
			if (self.alt_tooltip) then
				self.alt_tooltip = false
			else
				self.alt_tooltip = true
			end

			ION.LatencyButton_SetNormal()
		else
			ION.LatencyButton_SetPushed()
		end

		ION.LatencyButton_OnEnter(self)

	elseif (IsShiftKeyDown()) then
		ReloadUI()

	else
		if (self.down) then
			self.down = nil
			if (not GameMenuFrame:IsShown()) then
				CloseMenus()
				CloseAllWindows()
				PlaySound("igMainMenuOpen")
				ShowUIPanel(GameMenuFrame)
			else
				PlaySound("igMainMenuQuit")
				HideUIPanel(GameMenuFrame)
				ION.LatencyButton_SetNormal()
			end

			if (InterfaceOptionsFrame:IsShown()) then
				InterfaceOptionsFrameCancel:Click()
			end

			return
		end

		if (self:GetButtonState() == "NORMAL") then
			ION.LatencyButton_SetPushed()
			self.down = 1
		else
			self.down = 1
		end
	end
end


function ION.LatencyButton_OnEnter(self)
	self.hover = 1
	self.updateInterval = 0

	if (self.alt_tooltip and not IonMenuBarTooltip.wasShown) then
		ION.LatencyButton_AltOnEnter(self)
		IonMenuBarTooltip:AddLine("\nLatency Button by LedMirage of MirageUI")
		GameTooltip:Hide()
		IonMenuBarTooltip:Show()

	elseif (self:IsMouseOver()) then
		MainMenuBarPerformanceBarFrame_OnEnter(self)

		local objects = ION:GetParentKeys(GameTooltip)
		local foundion, text

		for k,v in pairs(objects) do
			if (_G[v]:IsObjectType("FontString")) then
				text = _G[v]:GetText()
				if (text) then
					foundion = text:match("%s+Ion$")
				end
			end
		end

		if (not foundion) then
			for i=1, GetNumAddOns() do
				if (select(1,GetAddOnInfo(i)) == "Ion") then
					local mem = GetAddOnMemoryUsage(i)
					if (mem > 1000) then
						mem = mem / 1000
					end
					GameTooltip:AddLine(format(ADDON_MEM_MB_ABBR, mem, select(1,GetAddOnInfo(i))), 1.0, 1.0, 1.0)
				end
			end
		end

		GameTooltip:AddLine("\nLatency Button by LedMirage of MirageUI")
		IonMenuBarTooltip:Hide()
		GameTooltip:Show()
	end
end


function ION.LatencyButton_AltOnEnter(self)
	if (not IonMenuBarTooltip:IsVisible()) then
		IonMenuBarTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
	end

	if (self.enabled) then
		IonMenuBarTooltip:SetText("Script Profiling is |cff00ff00Enabled|r", 1, 1, 1)
		IonMenuBarTooltip:AddLine("(Shift-RightClick to Disable)", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
		IonMenuBarTooltip:AddLine("\n|cfff00000Warning:|r Script Profiling Affects Game Performance\n", 1, 1, 1, 1)

		for i=1, GetNumAddOns() do
			local name,_,_,enabled = GetAddOnInfo(i)

			if (not addonData[i]) then
				addonData[i] = { name = name, enabled = enabled	}
			end

			local addon = addonData[i]

			addon.currMem = GetAddOnMemoryUsage(i)

			if (not addon.maxMem or addon.maxMem < addon.currMem) then
				addon.maxMem = addon.currMem
			end

			local currCPU = GetAddOnCPUUsage(i)

			if (addon.lastUsage) then
				addon.currCPU = (currCPU - addon.lastUsage)/2.5

				if (not addon.maxCPU or addon.maxCPU < addon.currCPU) then
					addon.maxCPU = addon.currCPU
				end
			else
				addon.currCPU = currCPU
			end

			if (self.usage > 0) then
				addon.percentCPU = addon.currCPU/self.usage * 100
			else
				addon.percentCPU = 0
			end

			addon.lastUsage = currCPU

			if (self.lastStart > 0) then
				addon.avgCPU = currCPU / self.lastStart
			end
		end

		if (self.usage) then
			IonMenuBarTooltip:AddLine("|cffffffff("..format("%.2f",(self.usage) / 2.5).."ms)|r Total Script CPU Time\n", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
		end

		wipe(sortData)

		for i,v in ipairs(addonData) do
			if (addonData[i].enabled) then
				local addLine = ""

				if (addonData[i].currCPU and addonData[i].currCPU > 0) then
					addLine = addLine..format("%.2f", addonData[i].currCPU).."ms/"..format("%.1f", addonData[i].percentCPU).."%)|r "

					local num = tonumber(addLine:match("^%d+"))

					if (num and num < 10) then
						addLine = "0"..addLine
					end

					if (addonData[i].name) then
						addLine = "|cffffffff("..addLine..addonData[i].name.." "
					end

					tinsert(sortData, addLine)
				end
			end
		end

		sort(sortData, function(a,b) return a>b end)

		for i,v in ipairs(sortData) do
			IonMenuBarTooltip:AddLine(v, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
		end
	else
		IonMenuBarTooltip:SetText("Script Profiling is |cfff00000Disabled|r", 1, 1, 1)
		IonMenuBarTooltip:AddLine("(Shift-RightClick to Enable)", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
		IonMenuBarTooltip:AddLine("\n|cfff00000Warning:|r Script Profiling Affects Game Performance\n", 1, 1, 1, 1)
	end
end


function ION.LatencyButton_OnLeave(self)
	self.hover = nil
	GameTooltip:Hide()
end


function ION.LatencyButton_SetPushed()
	IonLatencyButtonOverlay:SetPoint("CENTER", IonLatencyButton, "CENTER", -1, -2)
end


function ION.LatencyButton_SetNormal()
	IonLatencyButtonOverlay:SetPoint("CENTER", IonLatencyButton, "CENTER", 0, -0.5)
end


function ANCHOR:SetData(bar)
	if (bar) then
		self.bar = bar

		self:SetFrameStrata(bar.gdata.objectStrata)
		self:SetScale(bar.gdata.scale)
	end

	self:SetFrameLevel(4)
end


function ANCHOR:SaveData()
	-- empty
end


function ANCHOR:LoadData(spec, state)
	local id = self.id

	self.GDB = menubtnsGDB
	self.CDB = menubtnsCDB

	if (self.GDB and self.CDB) then
		if (not self.GDB[id]) then
			self.GDB[id] = {}
		end

		if (not self.GDB[id].config) then
			self.GDB[id].config = CopyTable(configData)
		end

		if (not self.CDB[id]) then
			self.CDB[id] = {}
		end

		if (not self.CDB[id].data) then
			self.CDB[id].data = {}
		end

		self.config = self.GDB [id].config
		self.data = self.CDB[id].data
	end
end


function ANCHOR:SetGrid(show, hide)
	--empty
end


function ANCHOR:SetAux()
	-- empty
end


function ANCHOR:LoadAux()
	-- empty
end


function ANCHOR:SetDefaults()
	-- empty
end


function ANCHOR:GetDefaults()
	--empty
end


function ANCHOR:SetType(save)
	if (menuElements[self.id]) then
		self:SetWidth(menuElements[self.id]:GetWidth()*0.90)
		self:SetHeight(menuElements[self.id]:GetHeight()/1.60)
		self:SetHitRectInsets(self:GetWidth()/2, self:GetWidth()/2, self:GetHeight()/2, self:GetHeight()/2)

		self.element = menuElements[self.id]

		local objects = ION:GetParentKeys(self.element)

		for k,v in pairs(objects) do
			local name = v:gsub(self.element:GetName(), "")
			self[name:lower()] = _G[v]
		end

		self.element.normaltexture = self.element:CreateTexture("$parentNormalTexture", "OVERLAY", "IonCheckButtonTextureTemplate")
		self.element.normaltexture:ClearAllPoints()
		self.element.normaltexture:SetPoint("CENTER", 0, 0)
		self.element.icontexture = self.element:GetNormalTexture()
		self.element:ClearAllPoints()
		self.element:SetParent(self)
		self.element:Show()
		self.element:SetPoint("BOTTOM", self, "BOTTOM", 0, -1)
		self.element:SetHitRectInsets(3, 3, 23, 3)
	end
end


local function controlOnEvent(self, event, ...)
	if (event == "ADDON_LOADED" and ... == "Ion-MenuBar") then
		hooksecurefunc("UpdateMicroButtons", updateMicroButtons)

		GDB = IonMenuGDB; CDB = IonMenuCDB

		for k,v in pairs(defGDB) do
			if (GDB[k] == nil) then
				GDB[k] = v
			end
		end

		for k,v in pairs(defCDB) do
			if (CDB[k] == nil) then
				CDB[k] = v
			end
		end

		menubarsGDB = GDB.menubars
		menubarsCDB = CDB.menubars

		menubtnsGDB = GDB.menubtns
		menubtnsCDB = CDB.menubtns

		ION:RegisterBarClass("menu", "Menu Bar", "Menu Button", menubarsGDB, menubarsCDB, MENUIndex, menubtnsGDB, "CheckButton", "IonAnchorButtonTemplate", { __index = ANCHOR }, #menuElements, false, STORAGE, gDef, nil, true)
		ION:RegisterGUIOptions("menu", { AUTOHIDE = true, SHOWGRID = false, SPELLGLOW = false, SNAPTO = true, DUALSPEC = false, HIDDEN = true, LOCKBAR = false, TOOLTIPS = true }, false, false)

		if (GDB.firstRun) then
			local bar, object = ION:CreateNewBar("menu", 1, true)

			for i=1,#menuElements do
				object = ION:CreateNewObject("menu", i)
				bar:AddObjectToList(object)
			end

			GDB.firstRun = false

		else
			local count = 0

			for id,data in pairs(menubarsGDB) do
				if (data ~= nil) then
					ION:CreateNewBar("menu", id)
				end
			end

			for id,data in pairs(menubtnsGDB) do
				if (data ~= nil) then
					ION:CreateNewObject("menu", id)
				end
				
				count = count + 1
			end
			
			if (count < #menuElements) then			
				for i=count+1, #menuElements do
					object = ION:CreateNewObject("menu", i)
				end
			end
		end
		STORAGE:Hide()
	elseif (event == "PLAYER_LOGIN") then

	elseif (event == "PLAYER_ENTERING_WORLD" and not PEW) then
		PEW = true
	end
end


--- This will check the position of the menu bar and move the alert below bar if 
-- to close to the top of the screen
-- Prams: self  - alert frame to be repositioned
-- Prams: parent - frame to be moved in relation to
function ION.CheckAlertPosition(self, parent)
	if not parent:GetTop() then return end

	if ( self:GetHeight() > UIParent:GetTop() - parent:GetTop() ) then
		self:ClearAllPoints()
		self:SetPoint("TOP", parent, "BOTTOM", 0, -16)
		self.Arrow:ClearAllPoints()
		self.Arrow:SetPoint("BOTTOM", self, "TOP", 0, -4)
		self.Arrow.Arrow:SetTexture("Interface\\AddOns\\Ion-MenuBar\\Images\\UpIndicator")
		self.Arrow.Arrow:SetTexCoord(0, 1, 0, 1)
		self.Arrow.Glow:Hide()
	end
end


local frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnEvent", controlOnEvent)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Hooks the Microbutton alerts that don't trigger of events  ie closing the talent frame
hooksecurefunc("MainMenuMicroButton_ShowAlert", ION.MainMenuMicroButton_ShowAlert)

-- Forces the default alert frames to auto hide if something tries to show them
TalentMicroButtonAlert:SetScript("OnShow", function(self) self:Hide() end)
CollectionsMicroButtonAlert:SetScript("OnShow", function(self) self:Hide() end)
EJMicroButtonAlert:SetScript("OnShow", function(self) self:Hide() end)