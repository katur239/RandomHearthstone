local addOnName = ...

local macroName = "RandomHearth"

local AllHearthstoneToys = {} 
local CovenantHearthstones = {}
local UseableHearthstones = {}
local currentHearthstone

local HasDalaranHearthstone = false
local HasGarrisonHearthstone = false
local HasFlightWhistle = false

local delayedLoad = false

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
AllHearthstoneToys[182773] = 340200 --Necrolord Hearthstone	     346060
AllHearthstoneToys[180290] = 326064 --Night Fae Hearthstone
AllHearthstoneToys[184353] = 345393 --Kyrian Hearthstone
AllHearthstoneToys[183716] = 342122 --Venthyr Hearthstone
AllHearthstoneToys[188952] = 363799 --Dominated Hearthstone
AllHearthstoneToys[193588] = 375357 --Timewalker's Hearthstone
AllHearthstoneToys[190237] = 367013 --Broker Translocation Matrix
AllHearthstoneToys[190196] = 366945 --Enlightened Hearthstone
AllHearthstoneToys[200630] = 391042 --Ohn'ir Windsage's Hearthstone
AllHearthstoneToys[208704] = 420418 --Deepweller's Earth Hearthstone

--Which toy belongs to which Covenant
CovenantHearthstones[184353] = 1 --Kyrian
CovenantHearthstones[183716] = 2 --Venthyr
CovenantHearthstones[180290] = 3 --Night Fae
CovenantHearthstones[182773] = 4 --Necrolord


local frame, events = CreateFrame("Frame"), {};

frame.defaults = { }
frame.defaults.ToyEnabled = { }
for k,value in pairs(AllHearthstoneToys) do
	frame.defaults.ToyEnabled[k] = true
end

frame:SetScript("OnEvent", function(self, event, ...)
	events[event](self, ...);
end);

function frame:InitializeOptions()
	self.panel = CreateFrame("Frame")
	self.panel.name = addOnName
	
	local title = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 10, -15)
	title:SetText("Random Hearthstone Options..... This doesn't work yet.")

	local cb = {}
	x = 20
	y = 40
	
	for k,_ in pairs(AllHearthstoneToys) do
	
		itemID, toyName, icon, isFavorite, hasFanfare, itemQuality = C_ToyBox.GetToyInfo(k)
		
		cb[k] = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
		cb[k]:SetPoint("TOPLEFT", x, -y)
		cb[k].Text:SetText(toyName)
		cb[k].itemID = k
		cb[k].SetValue = function(_, value)
			frame.db.ToyEnabled[self.itemID] = (value == "1") -- value can be either "0" or "1"
		end
		cb[k]:SetChecked(frame.db.ToyEnabled[k]) -- set the initial checked state
		
		y = y+22
	end

	InterfaceOptions_AddCategory(self.panel)
end

function events:ADDON_LOADED(...)
	if select(1,...) == addOnName then
		RHTDB = RHTDB or CopyTable(frame.defaults)
		frame.db = RHTDB
		--frame:InitializeOptions()
	end
end

function events:PLAYER_ENTERING_WORLD(...)
	if UnitAffectingCombat("player") and not delayedLoad then 
		delayedLoad = true 
		return
	else
		delayedLoad = false
		frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
		frame:UnregisterEvent("PLAYER_REGEN_ENABLED")
		SetRandomHearthstone()
	end	
end

function events:PLAYER_REGEN_ENABLED(...)
	if delayedLoad then
		events:PLAYER_ENTERING_WORLD(...)
	end
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
	if InCombatLockdown() then return end

	if next(UseableHearthstones) == nil then
		GetLearnedStones()
	end
	
	local itemID = RandomItemID(UseableHearthstones)
	
	UpdateMacro(itemID)
	
	currentHearthstone = UseableHearthstones[itemID]
	
	table.remove(UseableHearthstones, itemID)
end

function GetLearnedStones()
	
	UseableHearthstones = {}

	if GetItemCount("item:6948") > 0 then UseableHearthstones[6948] = 8690 else if UseableHearthstones[6948] ~= nil then table.remove(UseableHearthstones,6948) end end

	if PlayerHasToy(110560) then HasGarrisonHearthstone = true else HasGarrisonHearthstone = false end --Garrison Hearthstone
	if PlayerHasToy(140192) then HasDalaranHearthstone = true else HasDalaranHearthstone = false end --Dalaran Hearthstone
	
	if GetItemCount("item:141605") > 0 then HasFlightWhistle = true else HasFlightWhistle = false end --Flight Master's Whistle
	
	for k,_ in pairs(AllHearthstoneToys) do
		if PlayerHasToy(k) then
			if CovenantHearthstones[k] and CovenantHearthstones[k] ~= C_Covenants.GetActiveCovenantID() and not select(4,GetAchievementInfo(15241)) then
				print("You must be a member or have reached Renowned 80 with this Covenant.")
			else
				--itemID, toyName, icon, isFavorite, hasFanfare, itemQuality = C_ToyBox.GetToyInfo(k)
				--print("Learned Toy: ", toyName)
				UseableHearthstones[k] = AllHearthstoneToys[k]
			end
		end
	end
end

function UpdateMacro(itemID)
	if InCombatLockdown() then return end

	--print("Updating macro, item ID: "..itemID)
	
	local macroBody = "#showtooltip"
	
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