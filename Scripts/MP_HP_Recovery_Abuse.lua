--<<Drop all hp/mp adding items and also use acrane, bottle, etc. Also has key for dropping tranquil boots and blink.>>
--===By Blaxpirit===--

require("libs.Utils")
require("libs.ScriptConfig")

config = ScriptConfig.new()
config:SetParameter("Hotkey", "B", config.TYPE_HOTKEY)
config:SetParameter("DropTBorBlink", "N", config.TYPE_HOTKEY)
config:SetParameter("Turnflag", false)
config:Load()

local toggleKey = config.Hotkey
local droptbandblink = config.DropTBorBlink
local turnflag = config.Turnflag
local reg = false
local active = false
local activated = false

sleepTick = nil
sleepTick2 = nil

function Key(msg,code)
	if not PlayingGame() or client.chat then return end
	
	if msg == KEY_DOWN then
		if active then
			if code == toggleKey then
				DropItems()
			end
		end
		if code == droptbandblink then
			ProDrop()
		end
	end	
	if msg == KEY_UP then
		if code == toggleKey then
			PickUpItems()
		end
		if code == droptbandblink then
			PickUpItems()
		end
	end
end
	
function Tick( tick )
	if not PlayingGame() then return end	
	if not me then return end
	
	if sleepTick and sleepTick > tick then
		active = false 
	else
		active = true
	end
	
	if sleepTick2 and sleepTick2 > tick then
		client:ExecuteCmd("dota_player_units_auto_attack_after_spell 0")
	else
		client:ExecuteCmd("dota_player_units_auto_attack_after_spell 1")
	end
end	
	
function DropItems()
	if me.alive and (me.mana ~= me.maxMana or me.health ~= me.maxHealth) then
		sleepTick2 = GetTick() + 3250
		mp:HoldPosition()
		local aboots = me:FindItem("item_arcane_boots")
		local soulring = me:FindItem("item_soul_ring")
		local lowstick = me:FindItem("item_magic_stick")
		local gradestick = me:FindItem("item_magic_wand")
		local mek = me:FindItem("item_mekansm")
		local bottle = me:FindItem("item_bottle")
		local invis = me:IsInvisible()
		local chanel = me:IsChanneling()
		local cuseitems = me:CanUseItems()
		
		for i,v in ipairs(me.items) do	
			local bonusStrength = v:GetSpecialData("bonus_strength")
			local bonusMana = v:GetSpecialData("bonus_mana")
			local bonusHealth = v:GetSpecialData("bonus_health")
			local bonusIntellect = v:GetSpecialData("bonus_intellect")
			local bonusAll = v:GetSpecialData("bonus_all_stats")
			local treads = me:FindItem("item_power_treads")
			
			if not chanel then
				if v.name  == "item_power_treads" and treads and ((treads.bootsState == 0 and me.health ~= me.maxHealth) or (treads.bootsState == 1 and me.mana ~= me.maxMana)) then
					mp:DropItem(treads,me.position,turnflag)
				end
				if v.name == "item_refresher" and me.mana ~= me.maxMana then
					mp:DropItem(v,me.position,turnflag)
				end
				if v.name == "item_ancient_janggo" then
					mp:DropItem(v,me.position,turnflag)
				end
				if bonusMana or bonusIntellect or bonusAll and me.mana ~= me.maxMana then
					if aboots and aboots.cd == 0 then
						if v.name ~= "item_arcane_boots" then
							mp:DropItem(v,me.position,turnflag)
						end
					elseif gradestick and gradestick.charges > 0 and gradestick.cd == 0 then
						if bottle and bottle.charges > 0 and bottle.cd == 0 then 
							mp:DropItem(v,me.position,turnflag)
						else 
							if v.name ~= "item_magic_wand" then
								mp:DropItem(v,me.position,turnflag)
							end
						end
					else 
						mp:DropItem(v,me.position,turnflag)
					end
				end
				if bonusStrength or bonusHealth or bonusAll and me.health ~= me.maxHealth then
					if mek and mek.cd == 0 then
						if v.name ~= "item_mekansm" then
								mp:DropItem(v,me.position,turnflag)
						end 
					elseif gradestick and gradestick.charges > 0 and gradestick.cd == 0 then
						if bottle and bottle.charges > 0 and bottle.cd == 0 then 
							mp:DropItem(v,me.position,turnflag)
						else 
							if v.name ~= "item_magic_wand" then
								mp:DropItem(v,me.position,turnflag)
							end
						end
					else 
						mp:DropItem(v,me.position,turnflag)
					end
				end
			end
		end

		if cuseitems and not (invis and chanel) then
			if aboots and aboots.cd == 0 and me.mana ~= me.maxMana then
				me:SafeCastItem("item_arcane_boots")
				sleepTick = GetTick() + 1000
			elseif mek and mek.cd == 0 and me.health ~= me.maxHealth then
				me:SafeCastItem("item_mekansm")
				sleepTick = GetTick() + 1000
			elseif soulring and soulring.cd == 0 and me.mana ~= me.maxMana then
				me:SafeCastItem("item_soul_ring")
				sleepTick = GetTick() + 0
			elseif bottle and bottle.charges > 0 and bottle.cd == 0 then
				me:SafeCastItem("item_bottle")
				sleepTick = GetTick() + 3000
			elseif lowstick and lowstick.charges > 0 and lowstick.cd == 0 then
				me:SafeCastItem("item_magic_stick")
				sleepTick = GetTick() + 0
			elseif gradestick and gradestick.charges > 0 and gradestick.cd == 0 then
				me:SafeCastItem("item_magic_wand")
				sleepTick = GetTick() + 1000
			end
		end
	end	
end

function ProDrop()	
	local blink  = me:FindItem("item_blink")
	local tranquilboots = me:FindItem("item_tranquil_boots")
	local chanel = me:IsChanneling()
	if me.alive and not chanel then
		sleepTick2 = GetTick() + 1000
		mp:HoldPosition()
		if tranquilboots then 
			mp:DropItem(tranquilboots,me.position,turnflag)
		end
		if blink then
			mp:DropItem(blink,me.position,turnflag)
		end
	end
end

function PickUpItems()
	local DroppedItems = entityList:FindEntities({type=LuaEntity.TYPE_ITEM_PHYSICAL})
	for i,v in ipairs(DroppedItems) do
		mp:TakeItem(v,turnflag)
	end
	mp:Move(client.mousePosition)
	sleepTick2 = GetTick() + 500
end

function Load()
	if PlayingGame() then
		me = entityList:GetMyHero()
		mp = entityList:GetMyPlayer()
		if not me then 
			script:Disable()
		else
			reg = true
			script:RegisterEvent(EVENT_TICK,Tick)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(Load)
		end
	end
end

function GameClose()
	collectgarbage("collect")
	if reg then
		script:UnregisterEvent(Tick)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
		reg = false
	end
end 
 
script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Load)
