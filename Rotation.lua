local DMW = DMW
local Shaman = DMW.Rotations.SHAMAN
local Rotation = DMW.Helpers.Rotation
local Setting = DMW.Helpers.Rotation.Setting
local Player, Pet, Buff, Debuff, Spell, Target, Talent, Item, GCD, CDs, HUD, Enemy40Y, Enemy40YC, ComboPoints, HP, Enemy8YC, Enemy8Y, Enemy60Y, Enemy60YC
local hasMainHandEnchant,_ ,_ , _, hasOffHandEnchant = GetWeaponEnchantInfo()

local function Locals()
    Player = DMW.Player
    Pet = DMW.Player.Pet
    Buff = Player.Buffs
	HP = Player.HP
    Debuff = Player.Debuffs
    Spell = Player.Spells
    Talent = Player.Talents
    Item = Player.Items
	Power = Player.PowerPct
    Target = Player.Target or false
    HUD = DMW.Settings.profile.HUD
    CDs = Player:CDs() and Target and Target.TTD > 5 and Target.Distance < 5
	Enemy60Y, Enemy60YC = Player:GetEnemies(60)
    Enemy40Y, Enemy40YC = Player:GetEnemies(40)
	Enemy8Y, Enemy8YC = Player:GetEnemies(8)
end
local function Totems()
	------------------
	--- Totems ---
	------------------
-- Stoneskin Totem for 2+ mobs	
	if Setting("Stoneskin Totem") and Player.Combat and GetTotemInfo(2) == false and Enemy8YC > 1 then 
		if Spell.StoneskinTotem:Cast(Player) then
		return true 
		end
	end
--Searing Totem
	if Setting("Searing Totem") and Player.Combat and GetTotemInfo(1) == false and Enemy8YC > 1 and Player.PowerPct > 50 then 
		if Spell.SearingTotem:Cast(Player) then
			return true
		end
	end
end
	
local function Utility()
	------------------
	--- Utility ---
	------------------
--Lightning Shield
    if Setting("Lightning Shield") and Spell.LightningShield:Known() then
        if Buff.LightningShield:Remain() < 30 and Spell.LightningShield:Cast(Player) then
            return true
        end
    elseif Setting("LightningShield") and Spell.ImprovedLightningShield:Known() then
        if Buff.ImprovedLightningShield:Remain() < 300 and Spell.ImprovedLightningShield:Cast(Player) then
            return true
        end
    end
--Weapon Enchant
    if Setting("Weapon Enchant") and  not GetWeaponEnchantInfo() then
        if Spell.WindfuryWeapon:Known() then 
			if Spell.WindfuryWeapon:Cast(Player) then 
				return true
            end
        elseif Spell.RockbiterWeapon:Cast(Player) then
            return true
        end
     end
			
-- Earth Shock Interrupt
if Setting("ES Interrupt") and	Target and Target.ValidEnemy and Target.Distance < 20 and Target:Interrupt() then
		if Spell.EarthShock:Cast(Target) then
			return
		end
	end			
end	
	
local function DEF()
	------------------
	--- Defensives ---
	------------------
	--In Combat healing
	if Setting("Healing Wave") and HP < Setting("Healing Wave Percent") and Player.Combat and not Player.Moving then
		if Spell.LesserHealingWave:Known() then 
			if Spell.LesserHealingWave:Cast(Player) then
				return true
		end
		elseif  Spell.HealingWave:Cast(Player) then
			return true
		end
	end	
	if Setting("OOC Healing") and not Player.Combat and not Player.Moving and HP < Setting("OOC Healing Percent HP") and PowerPct > Setting("OOC Healing Percent Mana") then
		if Spell.LesserHealingWave:Known() then 
			if Spell.LesserHealingWave:Cast(Player) then
			return true
		end
		elseif  Spell.HealingWave:Cast(Player) then
			return true
		end
	end
end


function Shaman.Rotation()
    Locals()
	if  Utility() then
		return true
	end
	if  Totems() then
		return true
	end
	if DEF() then
		return true
	end

	-----------------
	-- DPS --
	-----------------	
-- EarthShock
	if Setting("Earth Shock") and Target and Target.ValidEnemy and Target.Distance < 20 and Target.Facing and Player.PowerPct > Setting("Earth Shock Mana") and Target.TTD > 4 then
		if Spell.EarthShock:Cast(Target) then
			return
		end
	end
-- Flame Shock
	if Setting("Flame Shock") and Target and Target.ValidEnemy and Target.Distance < 20 and Target.Facing and Player.PowerPct > Setting("Flame Shock Mana") and Target.TTD > 8  and not Debuff.FlameShock:Exist(Target) and CreatureType ~= "Totem" and CreatureType ~= "Elemental" and Target.Facing then
		if Spell.FlameShock:Cast(Target) then
			return 
		end
	end
-- Stormstrike
    if Setting("Stormstrike") and Target and Target.ValidEnemy and Target.Distance <= 5 then
       if Spell.Stormstrike:Cast(Target) then
			return true
		end	
	end
	-- Autoattack
    if  Target and Target.ValidEnemy and Target.Distance <= 5 then
        StartAttack()
	end
	--Lightning Bolt
	if Setting("Lightning Bolt") and Target and Target.ValidEnemy and Target.Distance >= 20 and not Player.Moving and Target.Facing and not Spell.LightningBolt:LastCast() then 
		if Spell.LightningBolt:Cast(Target, 1) then
		return true
		end
	end	
end