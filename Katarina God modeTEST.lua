local version = "1.0"

if myHero.charName ~= "Katarina" then return end

local lib_Required = {
	["SOW"]			= "https://raw.githubusercontent.com/Hellsing/BoL/master/common/SOW.lua",
	["VPrediction"]	= "https://raw.githubusercontent.com/Hellsing/BoL/master/common/VPrediction.lua"
}

local lib_downloadNeeded, lib_downloadCount = false, 0

function AfterDownload()
	lib_downloadCount = lib_downloadCount - 1
	if lib_downloadCount == 0 then
		lib_downloadNeeded = false
		print("<font color=\"#FF0000\">Katarina God mode:</font> <font color=\"#FFFFFF\">Required libraries downloaded successfully, please reload (double F9).</font>")
	end
end

for lib_downloadName, lib_downloadUrl in pairs(lib_Required) do
	local lib_fileName = LIB_PATH .. lib_downloadName .. ".lua"

	if FileExist(lib_fileName) then
		require(lib_downloadName)
	else
		lib_downloadNeeded = true
		lib_downloadCount = lib_downloadCount and lib_downloadCount + 1 or 1
		DownloadFile(lib_downloadUrl, lib_fileName, function() AfterDownload() end)
	end
end

if lib_downloadNeeded then return end
 

local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/bobczanki/B0L/master/Katarina%20God%20mode.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH .. GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>Katarina God mode:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end

local ServerData = GetWebResult(UPDATE_HOST, "/bobczanki/B0L/master/Katarina%20God%20mode.version")

if ServerData then
	ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
	if ServerVersion then
		if tonumber(version) < ServerVersion then
			AutoupdaterMsg("New version available ("..ServerVersion..")")
			AutoupdaterMsg("Updating, please don't press F9")
			DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
		else
			AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
		end
	end
else
	AutoupdaterMsg("Error downloading version info")
end

--------------------------------------------------------

function OnLoad()
	Variables()
	
	Menu = scriptConfig("Katarina God mode", "KatScript")
	
	ts.name = "Focus"
	Menu:addTS(ts)
	
	Menu:addSubMenu("Combo", "combo")
		Menu.combo:addParam("useCombo", "Combo!", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		Menu.combo:addParam("allowE", "Allow E first", SCRIPT_PARAM_ONOFF, true)
	Menu:addSubMenu("Harass", "harass")
		Menu.harass:addParam("useHarass", "Harass!", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))
	Menu:addSubMenu("Farm", "farm")
		Menu.farm:addParam("useFarm", "Farm!", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
		Menu.farm:addParam("farmAA", "Farm with AA", SCRIPT_PARAM_ONOFF, true)
		Menu.farm:addParam("farmQ", "Farm with Q", SCRIPT_PARAM_ONOFF, true)
		Menu.farm:addParam("farmW", "Farm with W", SCRIPT_PARAM_ONOFF, true)
	Menu:addSubMenu("Drawings", "drawings")
		Menu.drawings:addParam("selfDraw", "Self", SCRIPT_PARAM_ONOFF, true)
		Menu.drawings:addParam("targetMRK", "Target", SCRIPT_PARAM_ONOFF, false)
		Menu.drawings:addParam("enemyMRK", "Enemies", SCRIPT_PARAM_ONOFF, true)
		Menu.drawings:addParam("minionMRK", "Minions", SCRIPT_PARAM_ONOFF, true)
		Menu.drawings:addSubMenu("Self", "drawingsSLF")
			Menu.drawings.drawingsSLF:addParam("SLFrangeWard", "Draw Ward's range", SCRIPT_PARAM_ONOFF, false)
			Menu.drawings.drawingsSLF:addParam("SLFrangeWardcol", "Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
			Menu.drawings.drawingsSLF:addParam("spi", "", SCRIPT_PARAM_INFO, "")
			Menu.drawings.drawingsSLF:addParam("SLFrangeAA", "Draw AA's range", SCRIPT_PARAM_ONOFF, false)
			Menu.drawings.drawingsSLF:addParam("SLFrangeAAcol", "Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
			Menu.drawings.drawingsSLF:addParam("spi", "", SCRIPT_PARAM_INFO, "")
			Menu.drawings.drawingsSLF:addParam("SLFrangeQ", "Draw Q's range", SCRIPT_PARAM_ONOFF, false)
			Menu.drawings.drawingsSLF:addParam("SLFrangeQcol", "Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
			Menu.drawings.drawingsSLF:addParam("spi", "", SCRIPT_PARAM_INFO, "")
			Menu.drawings.drawingsSLF:addParam("SLFrangeW", "Draw W's range", SCRIPT_PARAM_ONOFF, true)
			Menu.drawings.drawingsSLF:addParam("SLFrangeWcol", "Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
			Menu.drawings.drawingsSLF:addParam("spi", "", SCRIPT_PARAM_INFO, "")
			Menu.drawings.drawingsSLF:addParam("SLFrangeE", "Draw E's range", SCRIPT_PARAM_ONOFF, true)
			Menu.drawings.drawingsSLF:addParam("SLFrangeEcol", "Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
			Menu.drawings.drawingsSLF:addParam("spi", "", SCRIPT_PARAM_INFO, "")
			Menu.drawings.drawingsSLF:addParam("SLFrangeR", "Draw R's range", SCRIPT_PARAM_ONOFF, false)
			Menu.drawings.drawingsSLF:addParam("SLFrangeRcol", "Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
		
		Menu.drawings:addSubMenu("Target", "drawingsTRGT")
			Menu.drawings.drawingsTRGT:addParam("TRcol", "Color of the mark", SCRIPT_PARAM_COLOR, {255, 15, 112, 0})

		
		Menu.drawings:addSubMenu("Enemies", "drawingsENMS")
			Menu.drawings.drawingsENMS:addParam("Rkill", "Mark when QWE + 1/2 R killable", SCRIPT_PARAM_ONOFF, true)
			Menu.drawings.drawingsENMS:addParam("RkillCol", "Color", SCRIPT_PARAM_COLOR, {255, 0, 105, 112})
			Menu.drawings.drawingsENMS:addParam("spi", "", SCRIPT_PARAM_INFO, "")
			Menu.drawings.drawingsENMS:addParam("noRkill", "Mark when QWE killable", SCRIPT_PARAM_ONOFF, true)
			Menu.drawings.drawingsENMS:addParam("noRkillCol", "Color", SCRIPT_PARAM_COLOR, {255, 112, 0, 0})
		
		
		Menu.drawings:addSubMenu("Minions", "minionMRK")
			Menu.drawings.minionMRK:addParam("MNkillQ", "Q killable", SCRIPT_PARAM_ONOFF, true)
			Menu.drawings.minionMRK:addParam("MNkillQcol", "Color", SCRIPT_PARAM_COLOR, {255, 15, 112, 0})
			Menu.drawings.minionMRK:addParam("spi", "", SCRIPT_PARAM_INFO, "")
			Menu.drawings.minionMRK:addParam("MNkillW", "W killable", SCRIPT_PARAM_ONOFF, true)
			Menu.drawings.minionMRK:addParam("MNkillWcol", "Color", SCRIPT_PARAM_COLOR, {255, 15, 112, 0})
			Menu.drawings.minionMRK:addParam("spi", "", SCRIPT_PARAM_INFO, "")
			Menu.drawings.minionMRK:addParam("MNkillE", "E killable", SCRIPT_PARAM_ONOFF, true)
			Menu.drawings.minionMRK:addParam("MNkillEcol", "Color", SCRIPT_PARAM_COLOR, {255, 15, 112, 0})
			Menu.drawings.minionMRK:addParam("spi", "", SCRIPT_PARAM_INFO, "")
			Menu.drawings.minionMRK:addParam("MNkillAA", "AA killable", SCRIPT_PARAM_ONOFF, true)
			Menu.drawings.minionMRK:addParam("MNkillAAcol", "Color", SCRIPT_PARAM_COLOR, {255, 15, 112, 0})
			Menu.drawings.minionMRK:addParam("MNkillAArng", "in range", SCRIPT_PARAM_SLICE, 125, 125, 1000, 0)
			
		Menu:addSubMenu("Addons", "ads")
			Menu.ads:addParam("wardJump", "Jump to ward", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
			Menu.ads:addParam("autoKS", "Auto KS", SCRIPT_PARAM_ONOFF, true)
			Menu.ads:addParam("human", "Humanization level", SCRIPT_PARAM_SLICE, 0, 0, 9, 0)
			Menu.ads:addParam("autoIGN", "Auto ignite killable enemy", SCRIPT_PARAM_ONOFF, true)
			Menu.ads:addParam("spellLVL3", "Leveling spells mode 1-3", SCRIPT_PARAM_LIST, 1, {"none", "Q-E-W", "E-Q-W"})
			Menu.ads:addParam("spellLVL", "Leveling spells mode 3-18", SCRIPT_PARAM_LIST, 1, {"none", "Q > W", "W > Q"})
		
	Menu.combo:permaShow("useCombo")
	Menu.harass:permaShow("useHarass")
	Menu.farm:permaShow("useFarm")
end

function Variables()
	VP = VPrediction(true)
	SOWi = SOW(VP)
	
	castAt, lastE, LastWard, tsDistance, qMark, checkQ, checkW, checkE, checkDFG = 0, 0, 0, 0, 0, 0, 0, 0, 0
	ward, ignite, DFG = nil, nil, nil

	ulting = false

	maxQEW3 = {1,3,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	maxEQW3 = {3,1,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	maxNone = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	maxQWE = {0,0,0,1,1,4,1,2,1,2,4,2,2,3,3,4,3,3}
	maxWQE = {0,0,0,2,2,4,2,1,2,1,4,1,1,3,3,4,3,3}
	
	ts = TargetSelector(TARGET_LESS_CAST,700)
	enemyHeroes = GetEnemyHeroes()
	EnemyMinions = minionManager(MINION_ENEMY, 2000, myHero, MINION_SORT_MAXHEALTH_ASC)
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end
end

function OnTick()
	Initiate()

	if Menu.ads.autoIGN then AutoIGN() end 
	if Menu.ads.wardJump then WardJump() end
	if Menu.combo.useCombo then
		Combo()
		return
	end
	if Menu.ads.autoKS then AutoKS() end
	if Menu.harass.useHarass then
		Harass()
		return
	end
	if Menu.farm.useFarm then Farm() end
end

function Combo()
	if ts.target ~= nil then
		if not ulting then SOWOrbWalk(ts.target) end
		if ulting and (qweDMG(ts.target) > ts.target.health or ts.target.dead) then ulting = false end
		if tsDistance < 700 and not ts.target.dead and not ulting then
			if Ready(DFG) then 
				CastSpell(DFG, ts.target)
				checkDFG = os.clock()
			end
			if os.clock() > checkDFG + Menu.ads.human * 0.1 and Ready(_Q) and tsDistance < 675 then 
				CastSpell(_Q, ts.target)
				checkQ = os.clock()
			end
			if os.clock() > checkQ + Menu.ads.human * 0.1 and (Menu.combo.allowE or tsDistance < 674) and Ready(_E) then
				CastSpell(_E, ts.target)
				checkE = os.clock()
			end
			if os.clock() > checkE + Menu.ads.human * 0.1 and Ready(_W) and (os.clock() < qMark + 1 or (Ready(_Q) == false and os.clock() > checkQ + 1)) and tsDistance < 400 then
				CastSpell(_W) 
				checkW = os.clock()
			end
			if os.clock() > checkW + Menu.ads.human * 0.1 and Ready(_R) and tsDistance < 400 and not Ready(DFG) and not Ready(_Q) and not Ready(_W) and not Ready(_E) then --and not SOWi:BeforeAttack(ts.target) 
				CastSpell(_R) 
				ulting = true
			end	
		end
	end
	if ts.target == nil and not ulting then player:MoveTo(mousePos.x, mousePos.z) end
end

function Harass()
	if ts.target ~= nil then
		SOWOrbWalk(ts.target)
		if tsDistance < 675 and tsDistance > 400 then
			if Ready(_Q) then
				CastSpell(_Q, ts.target) 
				checkQ = os.clock()
			end
			if Ready(_E) and os.clock() > checkW + 3 then CastSpell(_E, ts.target) end	
		end
		if tsDistance < 400 then
			if Ready(_Q) then 
			CastSpell(_Q, ts.target) 
			checkQ = os.clock()
			end
			if Ready(_W) and (os.clock() < qMark + 1 or (Ready(_Q) == false and os.clock() > checkQ + 1)) then
				CastSpell(_W)
				checkW = os.clock()
			end
		end
	end
	if ts.target == nil then player:MoveTo(mousePos.x, mousePos.z) end
end

function Farm()
	EnemyMinions:update()
	for _, minion in pairs(EnemyMinions.objects) do
		local qDMG = getDmg("Q",minion,myHero)
		local wDMG = getDmg("W",minion,myHero)
		if not minion.dead then
			if Menu.farm.farmQ and (GetDistance(minion) > 400 or not Ready(_W) or not Menu.farm.farmW) and GetDistance(minion) < 675 and qDMG > minion.health and Ready(_Q) and (GetDistance(minion) > 195 or (Menu.farm.farmAA == false or not SOWi:CanAttack())) then CastSpell(_Q, minion) end
			if Menu.farm.farmW and (GetDistance(minion) > 195 or (Menu.farm.farmAA == false or not SOWi:CanAttack())) and GetDistance(minion) < 400 and wDMG > minion.health and Ready(_W) then CastSpell(_W) end
		end
	end
	if Menu.farm.farmAA then
		local target = SOWKillableMinion() or SOWi:GetTarget()
		SOWOrbWalk(target)
	else
		player:MoveTo(mousePos.x, mousePos.z)
	end
end

function AutoKS()
	if ts.target ~= nil then
		for _, enemy in pairs(enemyHeroes) do
			if not enemy.dead and GetDistance(enemy) < 700 and qweDMG(enemy) > enemy.health then 
				if Ready(_Q) and GetDistance(enemy) < 675 then CastSpell(_Q, enemy) end
				if Ready(_E) then CastSpell(_E, enemy) end
				if Ready(_W) and os.clock() < qMark + 1 and GetDistance(enemy) < 375 then CastSpell(_W, enemy) end
			end
		end
	end
end

function MaxSpells()
	if myHero.level > 3 then
		if Menu.ads.spellLVL == 1 then autoLevelSetSequence(maxNone) end
		if Menu.ads.spellLVL == 2 then autoLevelSetSequence(maxQWE) end
		if Menu.ads.spellLVL == 3 then autoLevelSetSequence(maxWQE) end
	end
	
	if myHero.level <= 3 then
		if Menu.ads.spellLVL3 == 1 then autoLevelSetSequence(maxNone) end
		if Menu.ads.spellLVL3 == 2 then autoLevelSetSequence(maxQEW3) end
		if Menu.ads.spellLVL3 == 3 then autoLevelSetSequence(maxEQW3) end
	end
end

function Initiate()
	ts:update()
	MaxSpells()
	DFG = GetInventorySlotItem(3128)

	if ts.target ~= nil then 
		tsDistance = GetDistance(ts.target)
	end
end

function WardJump()
	player:MoveTo(mousePos.x, mousePos.z)
	if ward and GetTickCount() < castAt + 1000 and Ready(_E) and (Menu.ads.human == 0 or GetTickCount() > castAt + 50) then
CastSpell(_E, ward)
end
	if GetTickCount() > LastWard + 3000 then
	local slot = GetWardSlot()
	if slot then
		if GetDistance(mousePos) <= 600 then
			CastSpell(slot, mousePos.x, mousePos.z)
		else
			local MyPos = Vector(myHero.x, myHero.y, myHero.z)
			local MousePos = Vector(mousePos.x, mousePos.y, mousePos.z)
			local pos = MyPos - (MyPos - MousePos):normalized() * 600
			CastSpell(slot, pos.x, pos.z)
		end
		castAt = GetTickCount()
	end
	end
end

function GetWardSlot()
	if not Ready(_E) then return end
	local wards = { 2044, 2043, 2049, 2045, 3154, 3340, 3350, 3361, 3362 }
	for _, ward in ipairs(wards) do
		if GetInventorySlotItem(ward) and myHero:CanUseSpell(GetInventorySlotItem(ward)) == READY then
			return GetInventorySlotItem(ward)
		end
	end
	return nil
end

function AutoIGN()
	if Ready(ignite) then
		local ignitedmg = 0    
		for i = 1, heroManager.iCount, 1 do
		local enemyhero = heroManager:getHero(i)
			if ValidTarget(enemyhero,600) then
				ignitedmg = 50 + 20 * myHero.level
				if enemyhero.health <= ignitedmg then
					CastSpell(ignite, enemyhero)
				end
			end
		end
	end
end

function qweDMG(enemy)
	local distanceenemy = GetDistance(enemy)
	local qdamage = getDmg("Q",enemy,myHero)
	local qdamage2 = getDmg("Q",enemy,myHero,2)
	local wdamage = getDmg("W",enemy,myHero)
	local edamage = getDmg("E",enemy,myHero)
	local combo5 = 0
	if Ready(_Q) then
		combo5 = combo5 + qdamage
		if Ready(_E) or (tsDistance<375 and Ready(_W)) then
			combo5 = combo5 + qdamage2
		end
	end
	if Ready(_W) and (Ready(_E) or tsDistance<375) then
		combo5 = combo5 + wdamage
	end
	if Ready(_E) then
		combo5 = combo5 + edamage
	end
	return combo5
end

function SOWOrbWalk(target)
	if SOWi:CanAttack() and SOWi:ValidTarget(target) and not SOWi:BeforeAttack(target) then
		SOWi:Attack(target)
	elseif SOWi:CanMove() then
		local Mv = Vector(myHero) + 400 * (Vector(mousePos) - Vector(myHero)):normalized()
		SOWi:MoveTo(Mv.x, Mv.z)
	end
end

function SOWKillableMinion()
	local result
	for i, minion in ipairs(EnemyMinions.objects) do
		local time = SOWi:WindUpTime(true) + GetDistance(minion.visionPos, myHero.visionPos) / SOWi.ProjectileSpeed - 0.07
		local PredictedHealth = SOWi.VP:GetPredictedHealth(minion, time, GetSave("SOW").FarmDelay / 1000)
		if SOWi:ValidTarget(minion) and PredictedHealth < SOWi.VP:CalcDamageOfAttack(myHero, minion, {name = "Basic"}, 0) + SOWi:BonusDamage(minion) and PredictedHealth > -40 then
			result = minion
			break
		end
	end
	return result
end

function OnDraw()
	if myHero.dead then return end
	if Menu.drawings.selfDraw then
		if Menu.drawings.drawingsSLF.SLFrangeWard then
			DrawCircle(myHero.x, myHero.y, myHero.z, 600, RGBColor(Menu.drawings.drawingsSLF.SLFrangeWardcol))
		end
		if Menu.drawings.drawingsSLF.SLFrangeAA then
			DrawCircle(myHero.x, myHero.y, myHero.z, 190, RGBColor(Menu.drawings.drawingsSLF.SLFrangeAAcol))
		end
		if Menu.drawings.drawingsSLF.SLFrangeQ then
			DrawCircle(myHero.x, myHero.y, myHero.z, 675, RGBColor(Menu.drawings.drawingsSLF.SLFrangeQcol))
		end
		if Menu.drawings.drawingsSLF.SLFrangeW then
			DrawCircle(myHero.x, myHero.y, myHero.z, 400, RGBColor(Menu.drawings.drawingsSLF.SLFrangeWcol))
		end
		if Menu.drawings.drawingsSLF.SLFrangeE then
			DrawCircle(myHero.x, myHero.y, myHero.z, 700, RGBColor(Menu.drawings.drawingsSLF.SLFrangeEcol))
		end
		if Menu.drawings.drawingsSLF.SLFrangeR then
			DrawCircle(myHero.x, myHero.y, myHero.z, 550, RGBColor(Menu.drawings.drawingsSLF.SLFrangeRcol))
		end
	end

	if Menu.drawings.targetMRK and ts.target ~= nil then
		for i = 0, 10 do
			DrawCircle(ts.target.x, ts.target.y, ts.target.z, 50 + i, RGBColor(Menu.drawings.drawingsTRGT.TRcol))
		end
	end

	if Menu.drawings.enemyMRK then
		for _, enemy in pairs(enemyHeroes) do
		local qDMG = getDmg("Q",enemy,myHero, 2)
		local wDMG = getDmg("W",enemy,myHero)
		local eDMG = getDmg("E",enemy,myHero)
		local rDMG = getDmg("R",enemy,myHero)
		local hfRcmb = qDMG + wDMG + eDMG + rDMG * 0.5
		local noRcmb = qDMG + wDMG + eDMG
			if ts.target ~= nil and Menu.drawings.drawingsENMS.Rkill and enemy.health < hfRcmb and enemy.health > noRcmb then
				for i = 0, 10 do
					DrawCircle(enemy.x, enemy.y, enemy.z, 70 + i, RGBColor(Menu.drawings.drawingsENMS.RkillCol))
				end
			end
			if ts.target ~= nil and Menu.drawings.drawingsENMS.noRkill and enemy.health < noRcmb and not enemy.dead then
				for i = 0, 10 do
					DrawCircle(enemy.x, enemy.y, enemy.z, 70 + i, RGBColor(Menu.drawings.drawingsENMS.noRkillCol))
					DrawCircle(enemy.x, enemy.y, enemy.z, 90 + i, RGBColor(Menu.drawings.drawingsENMS.noRkillCol))
				end
			end
		end
	end

	if Menu.drawings.minionMRK then
		for _, minion in pairs(EnemyMinions.objects) do
			local qDMG = getDmg("Q",minion,myHero)
			local wDMG = getDmg("W",minion,myHero)
			local eDMG = getDmg("E",minion,myHero)
			local aaDMG = getDmg("AD",minion,myHero)
			if Menu.drawings.minionMRK.MNkillQ then
				if not minion.dead and GetDistance(minion) > 375 and GetDistance(minion) < 675 and minion.health < qDMG then
					for i = 0, 10 do
						DrawCircle(minion.x, minion.y, minion.z, 70 + i, RGBColor(Menu.drawings.minionMRK.MNkillQcol))
					end
				end
			end

			if Menu.drawings.minionMRK.MNkillW then
				if not minion.dead and GetDistance(minion) < 375 and minion.health < wDMG then
					for i = 0, 10 do
						DrawCircle(minion.x, minion.y, minion.z, 70 + i, RGBColor(Menu.drawings.minionMRK.MNkillWcol))
					end
				end
			end

			if Menu.drawings.minionMRK.MNkillE then
				if not minion.dead and GetDistance(minion) > 675 and GetDistance(minion) < 700 and minion.health < eDMG then
					for i = 0, 10 do
						DrawCircle(minion.x, minion.y, minion.z, 70 + i, RGBColor(Menu.drawings.minionMRK.MNkillEcol))
					end
				end
			end

			if Menu.drawings.minionMRK.MNkillAA then
				if not minion.dead and GetDistance(minion) < Menu.drawings.minionMRK.MNkillAArng  and minion.health < aaDMG then
					for i = 0, 10 do
						DrawCircle(minion.x, minion.y, minion.z, 50 + i, RGBColor(Menu.drawings.minionMRK.MNkillAAcol))
					end
				end
			end
		end
	end
end

function Ready(spell)
	if spell ~= nil then 
		return myHero:CanUseSpell(spell) == READY 
	else
		return false
	end
end

function OnCreateObj(obj)
	if obj.name:find("katarina_daggered") then qMark = os.clock() end
	if (obj.name:find("Ward") or obj.name:find("Trinket")) and GetTickCount() < castAt + 1000 and GetTickCount() > lastE + 1000 then		
		LastWard = GetTickCount()
		lastE = GetTickCount()
		ward = obj
	end
end

function RGBColor(menu)
        return ARGB(menu[1], menu[2], menu[3], menu[4])
end

function OnAnimation(unit, animationName)
	if unit == myHero then
		if animationName == "Spell4" then 
			ulting = true
		else
			ulting = false
		end
	end
end

function OnProcessSpell(object,spell)
	if object == myHero then
		if spell.name:lower():find("katarinar") then
			ulting = true
		end
		if spell.name:lower():find("katarinae") then
			ward = nil
		end
	end
end
