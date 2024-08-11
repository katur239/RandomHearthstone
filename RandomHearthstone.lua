local addOnName = ...
local macroName = "RandomHearth"

local AceAddon = LibStub("AceAddon-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local AllHearthstoneToys = {} 
local CovenantHearthstones = {}
local UseableHearthstones = {}
local currentHearthstone

local HasDalaranHearthstone = false
local HasGarrisonHearthstone = false
local HasFlightWhistle = false

--AllHearthstoneToys[itemID] = SpellID
AllHearthstoneToys[166747] = 286353 --Brewfest Reveler’s Hearthstone
AllHearthstoneToys[165802] = 286031 --Noble Gardener’s Hearthstone
AllHearthstoneToys[165670] = 285424 --Peedlefeet’s Lovely Hearthstone	
AllHearthstoneToys[165669] = 285362 --Lunar Elder’s Hearthstone
AllHearthstoneToys[166746] = 286331 --Fire Eater’s Hearthstone
AllHearthstoneToys[163045] = 278559 --Headless Horseman’s Hearthstone
AllHearthstoneToys[162973] = 278244 --Greatfather Winter’s Hearthstone
AllHearthstoneToys[142542] = 231504 --Tome of Town Portal
AllHearthstoneToys[64488]  = 94719  --The Innkeeper's Daughter
AllHearthstoneToys[54452]  = 75136  --Ethereal Portal
AllHearthstoneToys[93672]  = 136508 --Dark Portal
AllHearthstoneToys[168907] = 298068 --Holographic Digitalization
AllHearthstoneToys[172179] = 308742 --Eternal Traveler’s Hearthstone
AllHearthstoneToys[182773] = 340200 --Necrolord Hearthstone
AllHearthstoneToys[180290] = 326064 --Night Fae Hearthstone
AllHearthstoneToys[184353] = 345393 --Kyrian Hearthstone
AllHearthstoneToys[183716] = 342122 --Venthyr Hearthstone
AllHearthstoneToys[188952] = 363799 --Dominated Hearthstone
AllHearthstoneToys[193588] = 375357 --Timewalker's Hearthstone
AllHearthstoneToys[190237] = 367013 --Broker Translocation Matrix
AllHearthstoneToys[190196] = 366945 --Enlightened Hearthstone
AllHearthstoneToys[200630] = 391042 --Ohn'ir Windsage's Hearthstone
AllHearthstoneToys[208704] = 420418 --Deepweller's Earth Hearthstone
AllHearthstoneToys[209035] = 422284 --Hearthstone of the Flame
AllHearthstoneToys[206195] = 412555 --Path of the Naaru
AllHearthstoneToys[212337] = 401802 --Stone of the Hearth

--Which toy belongs to which Covenant
CovenantHearthstones[184353] = 1 --Kyrian
CovenantHearthstones[183716] = 2 --Venthyr
CovenantHearthstones[180290] = 3 --Night Fae
CovenantHearthstones[182773] = 4 --Necrolord


HearthstoneToyNames = {}
HearthstoneToyNames[6948] = "Default Hearthstone"
HearthstoneToyNames[166747] = "Brewfest Reveler’s Hearthstone"
HearthstoneToyNames[165802] = "Noble Gardener’s Hearthstone"
HearthstoneToyNames[165670] = "Peedlefeet’s Lovely Hearthstone	"
HearthstoneToyNames[165669] = "Lunar Elder’s Hearthstone"
HearthstoneToyNames[166746] = "Fire Eater’s Hearthstone"
HearthstoneToyNames[163045] = "Headless Horseman’s Hearthstone"
HearthstoneToyNames[162973] = "Greatfather Winter’s Hearthstone"
HearthstoneToyNames[142542] = "Tome of Town Portal"
HearthstoneToyNames[64488]  = "The Innkeeper's Daughter"
HearthstoneToyNames[54452]  = "Ethereal Portal"
HearthstoneToyNames[93672]  = "Dark Portal"
HearthstoneToyNames[168907] = "Holographic Digitalization"
HearthstoneToyNames[172179] = "Eternal Traveler’s Hearthstone"
HearthstoneToyNames[182773] = "Necrolord Hearthstone"
HearthstoneToyNames[180290] = "Night Fae Hearthstone"
HearthstoneToyNames[184353] = "Kyrian Hearthstone"
HearthstoneToyNames[183716] = "Venthyr Hearthstone"
HearthstoneToyNames[188952] = "Dominated Hearthstone"
HearthstoneToyNames[193588] = "Timewalker's Hearthstone"
HearthstoneToyNames[190237] = "Broker Translocation Matrix"
HearthstoneToyNames[190196] = "Enlightened Hearthstone"
HearthstoneToyNames[200630] = "Ohn'ir Windsage's Hearthstone"
HearthstoneToyNames[208704] = "Deepweller's Earth Hearthstone"
HearthstoneToyNames[209035] = "Hearthstone of the Flame"
HearthstoneToyNames[206195] = "Path of the Naaru"
HearthstoneToyNames[212337] = "Stone of the Hearth"

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
	
	UseableHearthstones = {}

	if GetItemCount("item:6948") > 0 and RHTDB.profile[6948] then UseableHearthstones[6948] = 8690 else if UseableHearthstones[6948] ~= nil then table.remove(UseableHearthstones,6948) end end

	if PlayerHasToy(110560) then HasGarrisonHearthstone = true else HasGarrisonHearthstone = false end --Garrison Hearthstone
	if PlayerHasToy(140192) then HasDalaranHearthstone = true else HasDalaranHearthstone = false end --Dalaran Hearthstone
	
	if GetItemCount("item:141605") > 0 then HasFlightWhistle = true else HasFlightWhistle = false end --Flight Master's Whistle
	
	for k,_ in pairs(AllHearthstoneToys) do
		if PlayerHasToy(k) then
			if CovenantHearthstones[k] and CovenantHearthstones[k] ~= C_Covenants.GetActiveCovenantID() and not select(4,GetAchievementInfo(15241)) then
				--We cannot use this Hearthstone yet.
			else
				--local itemID, toyName, icon, isFavorite, hasFanfare, itemQuality = C_ToyBox.GetToyInfo(k)
				--print("Learned Toy: ", toyName)
				if RHTDB.profile[k] then
					UseableHearthstones[k] = AllHearthstoneToys[k]
				end
			end
		end
	end
end

function UpdateMacro(itemID)
	if InCombatLockdown() then return end

	--print("Updating macro, item ID: "..itemID)
	
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
        keys[#keys+1] = key --Store keys in another table.
    end
	
    return keys[math.random(1, #keys)]
end