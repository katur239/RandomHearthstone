local addOnName, addon = ...
local macroName = "RandomHearth"

local AceAddon = LibStub("AceAddon-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local UseableHearthstones = {}
local currentHearthstone

local HasDalaranHearthstone = false
local HasGarrisonHearthstone = false
local HasFlightWhistle = false

local AllHearthstoneToys = addon.Toys
local HearthstoneToyNames = addon.ToyNames
local CovenantHearthstones = addon.CovenantToys

local frame, events = CreateFrame("Frame"), {};

frame.defaults = { }
frame.defaults.ToyEnabled = { }
for k,value in pairs(AllHearthstoneToys) do
	frame.defaults.ToyEnabled[k] = true
end

frame:SetScript("OnEvent", function(self, event, ...)
	events[event](self, ...);
end);

function frame:InitializeDB()
	local defaults = {
		profile = {}
	}
	for key, _ in pairs(HearthstoneToyNames) do
		defaults.profile[key] = true
	end
	RHTDB = LibStub("AceDB-3.0"):New("RHTDB", defaults, true)
end

function frame:InitializeOptions()
	self:InitializeDB()

	local options = {
		name = "Random Hearthstone",
		type = "group",
		args = {}
	}

	for k, v in pairs(HearthstoneToyNames) do
		options.args["hearthstone" .. k] = {
				type = "toggle",
				name = tostring(v),
				desc = "Toggle " .. tostring(v),
				get = function() return RHTDB.profile[k] end,
				set = function(_, value) RHTDB.profile[k] = value; GetLearnedStones() end,
		}
	end

	-- Register your options table with AceConfig
	AceConfig:RegisterOptionsTable("RHT", options)

	-- Add the options table to the Blizzard Interface Options
	AceConfigDialog:AddToBlizOptions("RHT", "Random Hearthstone")
end

function events:ADDON_LOADED(...)
	if select(1,...) == addOnName then
		frame:InitializeOptions()
	end
end

function events:PLAYER_ENTERING_WORLD(...)
	SetRandomHearthstone()
end

function events:PLAYER_REGEN_ENABLED(...)

end

function events:UNIT_SPELLCAST_START(...) --UNIT_SPELLCAST_SUCCEEDED
	if InCombatLockdown() then return end
	
	--print(select(3,...))
	if select(1,...) == "player" and select(3,...) == currentHearthstone then
		SetRandomHearthstone()
	end
end

for k, v in pairs(events) do
	frame:RegisterEvent(k);
end

function SetRandomHearthstone()
	if next(UseableHearthstones) == nil then
		GetLearnedStones()
	end
	
	local itemID = RandomItemID(UseableHearthstones)
	
	UpdateMacro(itemID)
	
	currentHearthstone = UseableHearthstones[itemID]
	
	UseableHearthstones[itemID] = nil
	--table.remove(UseableHearthstones, itemID)
end

function GetLearnedStones()
	
	wipe(UseableHearthstones)

	if C_Item.GetItemCount("item:6948") > 0 and RHTDB.profile[6948] then UseableHearthstones[6948] = 8690 else if UseableHearthstones[6948] ~= nil then table.remove(UseableHearthstones,6948) end end

	if PlayerHasToy(110560) then HasGarrisonHearthstone = true else HasGarrisonHearthstone = false end --Garrison Hearthstone
	if PlayerHasToy(140192) then HasDalaranHearthstone = true else HasDalaranHearthstone = false end --Dalaran Hearthstone
	
	if C_Item.GetItemCount("item:141605") > 0 then HasFlightWhistle = true else HasFlightWhistle = false end --Flight Master's Whistle
	
	for k,_ in pairs(AllHearthstoneToys) do
		if PlayerHasToy(k) and RHTDB.profile[k] then
			if CovenantHearthstones[k] and CovenantHearthstones[k] ~= C_Covenants.GetActiveCovenantID() and not select(4,GetAchievementInfo(15241)) then
				--We cannot use this Hearthstone yet.
			else
				UseableHearthstones[k] = AllHearthstoneToys[k]
			end
		end
	end
end

function UpdateMacro(itemID)
	if InCombatLockdown() then return end
	
	local macroBody = "#showtooltip"
	macroBody = macroBody.."\r/stopcasting"
	
	if HasDalaranHearthstone then macroBody = macroBody.."\r/use [mod:shift] item:140192;" end --Dalaran Hearthstone
	if HasGarrisonHearthstone then macroBody = macroBody.."\r/use [mod:ctrl] item:110560;" end --Garrison Hearthstone
	if HasFlightWhistle then macroBody = macroBody.."\r/use [mod:alt] item:141605;" end --Flight Master's Whistle
	
	macroBody = macroBody.."\r/use "
	
	if HasDalaranHearthstone or HasGarrisonHearthstone or HasFlightWhistle then
		macroBody = macroBody.."[nomod:"
		local modifiers = {}
		if HasDalaranHearthstone then modifiers[#modifiers + 1] = "shift" end --Dalaran Hearthstone
		if HasGarrisonHearthstone then modifiers[#modifiers + 1] = "ctrl" end --Garrison Hearthstone
		if HasFlightWhistle then modifiers[#modifiers + 1] = "alt" end --Flight Master's Whistle
		macroBody = macroBody .. table.concat(modifiers, "/") .. "] "
	end
		
	macroBody = macroBody.."item:" ..itemID..";"
	
	if GetMacroInfo(macroName) ~=nil then
		EditMacro(macroName, nil, nil, macroBody)
	else
		CreateMacro(macroName, "INV_Misc_QuestionMark", macroBody)
	end
end

function RandomItemID(t)
    local keys = {}
	
    for key, value in pairs(t) do
        keys[#keys+1] = key
    end
	
    return keys[math.random(1, #keys)]
end