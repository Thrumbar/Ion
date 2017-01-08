﻿--Ion, a World of Warcraft® user interface addon.
--Copyright© 2006-2014 Connor H. Chenoweth, aka Maul - All rights reserved.

--English spelling validated by Eledryn

local L = LibStub("AceLocale-3.0"):NewLocale("Ion", "enUS", true)

L.ION = "Ion"

L.DEFAULT = "Default"

L.SLASH1 = "/ion"
L.SLASH_HINT1 = "\n/ion |cff00ff00<command>|r <options>"
L.SLASH_HINT2 = "\nCommand List -\n"

L.SLASH_CMD1 = "Menu"
L.SLASH_CMD1_DESC = "Open the main menu"

L.SLASH_CMD2 = "Create"
L.SLASH_CMD2_DESC = "Create a blank bar of the given type (|cffffff00/ion create <type>|r)\n    Type |cffffff00/ion bartypes|r for available types"

L.SLASH_CMD3 = "Delete"
L.SLASH_CMD3_DESC = "Delete the currently selected bar"

L.SLASH_CMD4 = "Config"
L.SLASH_CMD4_DESC = "Toggle configuration mode for all bars"

L.SLASH_CMD5 = "Add"
L.SLASH_CMD5_DESC = "Adds buttons to the currently selected bar (|cffffff00add|r or |cffffff00add #|r)"

L.SLASH_CMD6 = "Remove"
L.SLASH_CMD6_DESC = "Removes buttons from the currently selected bar (|cffffff00remove|r or |cffffff00remove #|r)"

L.SLASH_CMD7 = "Edit"
L.SLASH_CMD7_DESC = "Toggle edit mode for all buttons"

L.SLASH_CMD8 = "Bind"
L.SLASH_CMD8_DESC = "Toggle binding mode for all buttons"

L.SLASH_CMD9 = "Scale"
L.SLASH_CMD9_DESC = "Scale a bar to the desired size"

L.SLASH_CMD10 = "SnapTo"
L.SLASH_CMD10_DESC = "Toggle SnapTo for current bar"

L.SLASH_CMD11 = "AutoHide"
L.SLASH_CMD11_DESC = "Toggle AutoHide for current bar"

L.SLASH_CMD12 = "Conceal"
L.SLASH_CMD12_DESC = "Toggle if current bar is shown or concealed at all times"

L.SLASH_CMD13 = "Shape"
L.SLASH_CMD13_DESC = "Change current bar's shape"

L.SLASH_CMD14 = "Name"
L.SLASH_CMD14_DESC = "Change current bar's name"

L.SLASH_CMD15 = "Strata"
L.SLASH_CMD15_DESC = "Change current bar's frame strata"

L.SLASH_CMD16 = "Alpha"
L.SLASH_CMD16_DESC = "Change current bar's alpha (transparency)"

L.SLASH_CMD17 = "AlphaUp"
L.SLASH_CMD17_DESC = "Set current bar's conditions to 'alpha up'"

L.SLASH_CMD18 = "ArcStart"
L.SLASH_CMD18_DESC = "Set current bar's starting arc location (in degrees)"

L.SLASH_CMD19 = "ArcLen"
L.SLASH_CMD19_DESC = "Set current bar's arc length (in degrees)"

L.SLASH_CMD20 = "Columns"
L.SLASH_CMD20_DESC = "Set the number of columns for the current bar (for shape Multi-Column)"

L.SLASH_CMD21 = "PadH"
L.SLASH_CMD21_DESC = "Set current bar's horizontal padding"

L.SLASH_CMD22 = "PadV"
L.SLASH_CMD22_DESC = "Set current bar's vertical padding"

L.SLASH_CMD23 = "PadHV"
L.SLASH_CMD23_DESC = "Adjust both horizontal and vertical padding of the current bar incrementally"

L.SLASH_CMD24 = "X"
L.SLASH_CMD24_DESC = "Change current bar's horizontal axis position"

L.SLASH_CMD25 = "Y"
L.SLASH_CMD25_DESC = "Change current bar's vertical axis position"

L.SLASH_CMD26 = "State"
L.SLASH_CMD26_DESC = "Toggle an action state for the current bar (|cffffff00/ion state <state>|r).\n    Type |cffffff00/ion statelist|r for valid states"

L.SLASH_CMD27 = "Vis"
L.SLASH_CMD27_DESC = "Toggle visibility states for the current bar (|cffffff00/ion vis <state> <index>|r)\n|cffffff00<index>|r = \"show\" | \"hide\" | <num>.\nExample: |cffffff00/ion vis paged hide|r will toggle hide for all paged states\nExample: |cffffff00/ion vis paged 1|r will toggle show/hide for when the state manager is on page 1"

L.SLASH_CMD28 = "ShowGrid"
L.SLASH_CMD28_DESC = "Toggle the current bar's showgrid flag"

L.SLASH_CMD29 = "Lock"
L.SLASH_CMD29_DESC = "Toggle bar lock. |cffffff00/lock <mod key>|r to enable/disable removing abilities while that <mod key> is down (ex: |cffffff00/lock shift|r)"

L.SLASH_CMD30 = "Tooltips"
L.SLASH_CMD30_DESC = "Toggle tooltips for the current bar's action buttons"

L.SLASH_CMD31 = "SpellGlow"
L.SLASH_CMD31_DESC = "Toggle spell activation animations on the current bar"

L.SLASH_CMD32 = "BindText"
L.SLASH_CMD32_DESC = "Toggle keybind text on the current bar"

L.SLASH_CMD33 = "MacroText"
L.SLASH_CMD33_DESC = "Toggle macro name text on the current bar"

L.SLASH_CMD34 = "CountText"
L.SLASH_CMD34_DESC = "Toggle spell/item count text on the current bar"

L.SLASH_CMD35 = "CDText"
L.SLASH_CMD35_DESC = "Toggle cooldown counts text on the current bar"

L.SLASH_CMD36 = "CDAlpha"
L.SLASH_CMD36_DESC = "Toggle a button's transparancy while on cooldown"

L.SLASH_CMD37 = "AuraText"
L.SLASH_CMD37_DESC = "Toggle aura watch text on the current bar"

L.SLASH_CMD38 = "AuraInd"
L.SLASH_CMD38_DESC = "Toggle aura button indicators on the current bar"

L.SLASH_CMD39 = "UpClick"
L.SLASH_CMD39_DESC = "Toggle if buttons on the current bar respond to up clicks"

L.SLASH_CMD40 = "DownClick"
L.SLASH_CMD40_DESC = "Toggle if buttons on the current bar respond to down clicks"

L.SLASH_CMD41 = "TimerLimit"
L.SLASH_CMD41_DESC = "Sets the minimum time in seconds to begin showing text timers"

L.SLASH_CMD42 = "StateList"
L.SLASH_CMD42_DESC = "Print a list of valid states"

L.SLASH_CMD43 = "BarTypes"
L.SLASH_CMD43_DESC = "Print a list of available bar types to make"

L.SLASH_CMD44 = "BlizzBar"
L.SLASH_CMD44_DESC = "Toggle Blizzard's Action Bar"

L.SLASH_CMD45 = "VehicleBar"
L.SLASH_CMD45_DESC = "Toggle Blizzard's Vehicle Bar"

L.SLASH_CMD46 = "Animate"
L.SLASH_CMD46_DESC = "Toggle Ion's Orb Animation"

--L.SLASH_CMD47 = "DraenorBar"
--L.SLASH_CMD47_DESC = "Toggle Draenor Garrison Bar"

L.SLASH_CMD48 = "Debug"
L.SLASH_CMD48_DESC = "Degutool"

L.SLASH_CMD47 = "MoveSpecButtons"
L.SLASH_CMD47_DESC = "Copies the buttons from one spec to a second(|cffffff00/ion MoveSpecButtons <Old_Spec#> <New_Spec#>|r)"

L.BARTYPES_USAGE = "Usage: |cffffff00/ion create <type>|r\n"
L.BARTYPES_TYPES = "     Types -\n"
L.BARTYPES_LINE = "Creates a bar for %ss"

L.SELECT_BAR = "No bar selected or command invalid"

L.CUSTOM_OPTION = "\n\nFor custom states, add a desired state string (|cffffff00/ion state custom <state string>|r) where <state string> is a semicolon seperated list of state conditions\n\n|cff00ff00Example:|r [actionbar:1];[stance:1];[stance3,stealth];[mounted]\n\n|cff00ff00Note:|r the first state listed will be considered the \"home state\". If the state manager ever gets confused, that is the state it will default to."

L.VALIDSTATES = "\n|cff00ff00Valid states:|r "
L.INVALID_INDEX = "Invalid index"
L.STATE_HIDE = "hide"
L.STATE_SHOW = "show"

L.HOMESTATE = "Home State"
L.LASTSTATE = "Should not see!"

L.PAGED = "paged" -- keep in lower case
L.STANCE = "stance" -- keep in lower case
L.PET = "pet" -- keep in lower case
L.ALT = "alt" -- keep in lower case
L.CTRL = "ctrl" -- keep in lower case
L.SHIFT = "shift" -- keep in lower case
L.STEALTH = "stealth" -- keep in lower case
L.PROWL = "prowl" -- keep in lower case
L.REACTION = "reaction" -- keep in lower case
L.COMBAT = "combat" -- keep in lower case
L.GROUP = "group" -- keep in lower case
L.FISHING = "fishing" -- keep in lower case
L.VEHICLE = "vehicle" -- keep in lower case
L.CUSTOM = "custom" -- keep in lower case
L.POSSESS = "possess" -- keep in lower case
L.OVERRIDE = "override" -- keep in lower case
L.EXTRABAR = "extrabar" -- keep in lower case

L.PAGED1 = "Page 1"
L.PAGED2 = "Page 2"
L.PAGED3 = "Page 3"
L.PAGED4 = "Page 4"
L.PAGED5 = "Page 5"
L.PAGED6 = "Page 6"

L.PET0 = "No Pet"
L.PET1 = "Pet Exists"

L.ALT0 = "Alt Up"
L.ALT1 = "Alt Down"
L.CTRL0 = "Control Up"
L.CTRL1 = "Control Down"
L.SHIFT0 = "Shift Up"
L.SHIFT1 = "Shift Down"

L.STEALTH0 = "No Stealth"
L.STEALTH1 = "Stealth"
L.PROWL0 = "No Prowl"
L.PROWL1 = "Prowl"
L.REACTION0 = "Friendly"
L.REACTION1 = "Hostile"
L.COMBAT0 = "No Combat"
L.COMBAT1 = "Combat"

L.GROUP0 = "No Group"
L.GROUP1 = "Group: Raid"
L.GROUP2 = "Group: Party"
L.FISHING0 = "No Fishing Pole"
L.FISHING1 = "Fishing Pole"

L.VEHICLE0 = "No Vehicle"
L.VEHICLE1 = "Vehicle"
L.POSSESS0 = "No Possess"
L.POSSESS1 = "Possess"
L.OVERRIDE0 = "No Override Bar"
L.OVERRIDE1 = "Override Bar"
L.EXTRABAR0 = "No Extra Bar"
L.EXTRABAR1 = "Extra Bar"

L.CUSTOM0 = "Custom States"

--class specific state names
L.DRUID_CASTER = "Caster Form"
L.DRUID_PROWL = "Prowl"
L.PRIEST_HEALER = "Healer Form"
L.ROGUE_MELEE = "Melee"
L.WARLOCK_CASTER = "Caster Form"

L.MINIMAP_TOOLTIP1 = "Left-Click to Configure Bars"
L.MINIMAP_TOOLTIP2 = "Right-Click to Edit Buttons"
L.MINIMAP_TOOLTIP3 = "Middle-Click or Alt-Click to Edit Key Bindings"
L.MINIMAP_TOOLTIP4 = "Shift-Click for Main Menu"

L.KEYBIND_TOOLTIP1 = "\nHit a key to bind it to"
L.KEYBIND_TOOLTIP2 = "Left-Click to |cfff00000LOCK|r this %s's bindings\n\nRight-Click to make this %s's bindings a |cff00ff00PRIORITY|r bind\n\nHit |cfff00000ESC|r to clear this %s's current binding(s)"
L.KEYBIND_TOOLTIP3 = "Current Binding(s):"

L.EDITFRAME_EDIT = "edit"

L.EMPTY_BUTTON = "Empty Button"
L.EDIT_BINDINGS = "Edit Bindings"
L.KEYBIND_NONE = "none"

L.BINDFRAME_BIND = "bind"
L.BINDFRAME_LOCKED = "locked"
L.BINDFRAME_PRIORITY = "priority"
L.BINDINGS_LOCKED	= "This button's bindings are locked.\nLeft-Click button to unlock."
L.BINDER_NOTICE = "Ion Key Binder\n|cffffffffThe Original Mouseover Binding System|r\nDeveloped by Maul"

L.OFF = "Off"
L.ALPHAUP_BATTLE = "Combat"
L.ALPHAUP_MOUSEOVER = "Mouseover"
L.ALPHAUP_BATTLEMOUSE = "Combat+Mouseover"
L.ALPHAUP_RETREAT = "Retreat"
L.ALPHAUP_RETREATMOUSE = "Retreat+Mouseover"

L.BAR_SHAPES = "\n1=Linear\n2=Circle\n3=Circle+One"
L.BAR_SHAPE1 = "Linear"
L.BAR_SHAPE2 = "Circle"
L.BAR_SHAPE3 = "Circle+One"
L.BAR_STRATAS = "\n1=BACKGROUND\n2=LOW\n3=MEDIUM\n4=HIGH\n5=DIALOG"
L.BAR_ALPHA = "Alpha value must be between zero(0) and one(1)"
L.BAR_ARCSTART = "Arc start must be between 0 and 359"
L.BAR_ARCLENGTH = "Arc length must be between 0 and 359"
L.BAR_COLUMNS = "Enter a number of desired columns for the bar higher than zero(0)\nOmit number to turn off columns"
L.BAR_PADH = "Enter a valid number for desired horizontal button padding"
L.BAR_PADV = "Enter a valid number for desired vertical button padding"
L.BAR_PADHV = "Enter a valid number to increase/decrease both the horizontal and vertical button padding"
L.BAR_XPOS = "Enter a valid number for desired x position offset"
L.BAR_YPOS = "Enter a valid number for desired y position offset"

L.BARLOCK_MOD = "Valid mod keys:\n\n|cff00ff00alt|r: unlock bar when the <alt> key is down\n|cff00ff00ctrl|r: unlock bar when the <ctrl> key is down\n|cff00ff00shift|r: unlock bar when the <shift> key is down"
L.TOOLTIPS = "Valid options:\n\n|cff00ff00enhanced|r: display additional ability info\n|cff00ff00combat|r: hide/show tooltips while in combat"
L.SPELLGLOWS = "Valid options:\n\n|cff00ff00default|r: use Blizzard default spell glow animation\n|cff00ff00alt|r: use alternate subdued spell glow animation"
L.TIMERLIMIT_SET = "Timer limit set to %d seconds"
L.TIMERLIMIT_INVALID = "Invalid timer limit"

L.PETATTACK = "Attack"
L.PETFOLLOW = "Follow"
L.PETMOVETO = "Move To"
L.PETASSIST = "Assist"
L.PETDEFENSIVE = "Defensive"
L.PETPASSIVE = "Passive"

L.APPLY = "Apply"
L.CANCEL = "Cancel"
L.DONE = "Done"
L.CREATE_BAR = "Create New Bar"
L.DELETE_BAR = "Delete Current Bar"
L.SELECT_BAR_TYPE = "- Select Bar Type -"
L.CONFIRM = "- Confirm -"
L.CONFIRM_YES = "Yes"
L.CONFIRM_NO = "No"
L.GENERAL = "General Options"
L.BAR_STATES = "Bar States"
L.OBJECTS = "Object Editor"
L.MACRO = "Macro Data"
L.ACTION = "Action Data"
L.OPTIONS = "Options"

L.MACRO_NAME = "-macro name-"
L.MACRO_EDITNOTE = "Click here to edit macro note"
L.MACRO_USENOTE = "Use macro note as button tooltip"

L.COUNT = "Count"
L.SEARCH = "Search"
L.CUSTOM_ICON = "Custom Icon"
L.PATH = "path"

L.AUTOHIDE = "Auto Hide"
L.SHOWGRID = "Show Grid"
L.SNAPTO = "Snap To"
L.HIDDEN = "Hidden"
L.UPCLICKS = "Up Clicks"
L.DOWNCLICKS = "Down Clicks"
L.DUALSPEC = "Dual Spec"
L.SPELLGLOW = "Spell Alerts"
L.SPELLGLOW_DEFAULT = " - Default Alert"
L.SPELLGLOW_ALT = " - Subdued Alert"
L.LOCKBAR = "Lock Actions"
L.LOCKBAR_SHIFT = " - Unlock on SHIFT"
L.LOCKBAR_CTRL = " - Unlock on CTRL"
L.LOCKBAR_ALT = " - Unlock on ALT"
L.TOOLTIPS_OPT = "Enable Tooltips"
L.TOOLTIPS_ENH = " - Enhanced"
L.TOOLTIPS_COMBAT = " - Hide in Combat"

L.PRESET_STATES = "Preset Action States"
L.CUSTOM_STATES = "Custom Action States"

L.GUI_PAGED = "Paged"
L.GUI_STANCE = "Stance"
L.GUI_PET = "Pet"
L.GUI_ALT = "Alt"
L.GUI_CTRL = "Ctrl"
L.GUI_SHIFT = "Shift"
L.GUI_STEALTH = "Stealth"
L.GUI_REACTION = "Reaction"
L.GUI_COMBAT = "Combat"
L.GUI_GROUP = "Group"
L.GUI_FISHING = "Fishing"
L.GUI_VEHICLE = "Vehicle"
L.GUI_POSSESS = "Possess"
L.GUI_OVERRIDE = "Override"
L.GUI_EXTRABAR = "Extra Bar"
L.GUI_CUSTOM = "Custom"
L.GUI_PROWL = "Prowl"



L.REMAP = "Primary State to Remap"
L.REMAPTO = "Remap State To"

L.SCALE = "Scale"
L.ALPHA = "Alpha"
L.ALPHAUP = "Alpha Up"
L.ALPHAUP_SPEED = "A/U Speed"
L.STRATA = "Strata"
L.SHAPE = "Shape"
L.HPAD = "Horiz Pad"
L.VPAD = "Vert Pad"
L.HVPAD = "H + V Pad"
L.COLUMNS = "Columns"
L.ARCSTART = "Arc Start"
L.ARCLENGTH = "Arc Length"

L.BINDTEXT = "Bind Text"
L.MACROTEXT = "Macro Text"
L.COUNTTEXT = "Count Text"
L.RANGEIND = "Range Ind"
L.CDTEXT = "Cooldown Text"
L.CDALPHA = "Cooldown Alpha"
L.AURATEXT = "Aura Watch Text"
L.AURAIND = "Aura Watch Ind"

L.POINT = "Point"
L.XPOS = "X Pos"
L.YPOS = "Y Pos"

L.BOUND_SPELL_KEYBIND = "Enable Spell Binding Mode"
L.BOUND_TOGGLE_SPELL_KEYBIND = "Toggle Spell Binding Mode"
L.BOUND_MACRO_KEYBIND = "Enable Macro Binding Mode"
L.BOUND_TOGGLE_MACRO_KEYBIND = "Toggle Macro Binding Mode"



L.BETA_WARNING = [[Thank you for installing Ion!!!

Ion is currently in a "|cffffff00beta testing|r" state.

Sadly, I was not able to get a release version done for patch 5.0.4. A release version should be ready for the Mists of Pandaria Expansion, though!

What this means is that not all features are in and there may be bugs. But, largely, Ion is in a usable and stable state.

Only use Ion right now if you do not mind the occasional bug and not being able to do everything you did with Macaroon =)

-Maul]]

--NEW

L.HE_UPDATE_WARNING = [[Thank you for updateing Ion!!!

Ion is now in a "|cffffff00release|r" state. Woot!  =)

A lot of functionality has been added with this version and a few things have changed slightly.
Please take a moment to look over the change log to famalariaze your self with the changes.

Hope that you enjoy the addon and thanks for being patient with the wait.

-Maul & SLOKnightfall]]

L.OPTIONS_BLIZZBAR = "Show Blizzard's Action Bar"
L.OPTIONS_ANIMATE = "Enable Ion's Orb Animation"
L.OPTIONS_DRAENORBAR = "Show the Draenor Garrison Action Icon"

L.BAR_VISABLE_STATES = "Bar Visibility Toggles"
L.TARGET = "Target"
L.TARGET1 = "Has Target"
L.TARGET0 = "No Target"
L.GUI_TARGET = "Target"
L.GUI_INDOORS = "Indoors"
L.GUI_OUTDOORS = "Outdoors"
L.GUI_MOUNTED = "Mounted"
L.GUI_FLYING = "Flying"
L.GUI_RESTING = "Resting"
L.GUI_SWIMMING = "Swimming"
L.GUI_HARM = "Harm"
L.GUI_HELP = "Help"
L.GUI_SPEC1 = "Display button for spec 1"
L.GUI_SPEC2 = "Display button for spec 2"
L.GUI_SPEC3 = "Display button for spec 3"
L.GUI_SPEC4 = "Display button for spec 4"


L.SPELL_TARGETING_OPTIONS = "Spell Target Options"

L.SPELL_TARGETING_SELF_CAST_MODIFIER = "Self-Cast by modifier"
L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE = "Toggle the use of the modifier-based self-cast functionality."
L.SPELL_TARGETING_SELF_CAST_MODIFIER_SELECT = "Select the Self-Cast Modifier"

L.SPELL_TARGETING_FOCUS_CAST_MODIFIER ="Focus-Cast by modifier"
L.SPELL_TARGETING_FOCUS_CAST_MODIFIER_TOGGLE = "Toggle the use of the modifier-based focus-cast functionality."
L.SPELL_TARGETING_FOCUS_CAST_MODIFIER_SELECT = "Select the Focus-Cast Modifier"

L.SPELL_TARGETING_SELF_CAST_RIGHTCLICK = "Right-click Self-Cast"
L.SPELL_TARGETING_SELF_CAST_RIGHTCLICK_TOGGLE = "Toggle the use of the right-click self-cast functionality."

L.SPELL_TARGETING_MOUSEOVER_CAST = "Mouse-Over Casting"
L.SPELL_TARGETING_MOUSEOVER_CAST_MODIFIER_TOGGLE = "Toggle the use of the modifier-based mouse-over cast functionality."
L.SPELL_TARGETING_MOUSEOVER_CAST_MODIFIER_SELECT = "Select a modifier for Mouse-Over Casting"
L.SPELL_TARGETING_MOUSEOVER_CAST_MODIFIER = "Mouse-Over Casting Modifier"

L.SPELL_TARGETING_SELF_CAST_RIGHTCLICK_SELECT = "Select the Self-Cast Modifier"

L.SPELL_TARGETING_MODIFIER_NONE_REMINDER = "\"None\" as modifier for Self & Focus Casting means its disabled. \nFor Mouse-Over Casting it means its always active, and no modifier is required."

L.ZONEABILITY_BAR_BORDER = "Show Bar Border"