local version = "0.6"

if myHero.charName ~= "Fizz" then return end

AUTOUPDATE = true

local lib_Required = {
	["SOW"]			= "https://raw.githubusercontent.com/Hellsing/BoL/master/common/SOW.lua",
	["VPrediction"]	= "https://raw.githubusercontent.com/Hellsing/BoL/master/common/VPrediction.lua"
}

local lib_downloadNeeded, lib_downloadCount = false, 0

function AfterDownload()
	lib_downloadCount = lib_downloadCount - 1
	if lib_downloadCount == 0 then
		lib_downloadNeeded = false
		print("<font color=\"#FF0000\">Fizz God mode:</font> <font color=\"#FFFFFF\">Required libraries downloaded successfully, please reload (double F9).</font>")
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
local UPDATE_PATH = "/bobczanki/B0L/edit/master/Fizz%20God%20mode.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = BOL_PATH.."Scripts\\Fizz God mode.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function _AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>Fizz God mode:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/bobczanki/B0L/master/Fizz%20God%20mode.version")
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		if ServerVersion then
			if tonumber(version) < ServerVersion then
				_AutoupdaterMsg("New version available"..ServerVersion)
				_AutoupdaterMsg("Updating, please don't press F9")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () _AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
			else
				_AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
			end
		end
	else
		_AutoupdaterMsg("Error downloading version info")
	end
end



function OnLoad()
	Variables()
	
	Menu = scriptConfig("Fizz God mode", "FizzScript")
	
	ts.name = "Focus"
	Menu:addTS(ts)
	
	Menu:addParam("useCombo", "Combo!", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Menu:addParam("useHarass", "Harass!", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))
	Menu:addParam("useFarm", "Farm! (SOW)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	Menu:addSubMenu("Drawings", "drawings")
		Menu.drawings:addSubMenu("Self", "drawingsSLF")
			Menu.drawings.drawingsSLF:addParam("SLFrangeAA", "Draw AA's range", SCRIPT_PARAM_ONOFF, false)
			Menu.drawings.drawingsSLF:addParam("SLFrangeAAcol", "Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
			Menu.drawings.drawingsSLF:addParam("spi", "", SCRIPT_PARAM_INFO, "")
			Menu.drawings.drawingsSLF:addParam("SLFrangeQ", "Draw Q's range", SCRIPT_PARAM_ONOFF, true)
			Menu.drawings.drawingsSLF:addParam("SLFrangeQcol", "Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
			Menu.drawings.drawingsSLF:addParam("spi", "", SCRIPT_PARAM_INFO, "")
			Menu.drawings.drawingsSLF:addParam("SLFrangeE", "Draw E's range", SCRIPT_PARAM_ONOFF, false)
			Menu.drawings.drawingsSLF:addParam("SLFrangeEcol", "Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
			Menu.drawings.drawingsSLF:addParam("spi", "", SCRIPT_PARAM_INFO, "")
			Menu.drawings.drawingsSLF:addParam("SLFrangeR", "Draw R's range", SCRIPT_PARAM_ONOFF, false)
			Menu.drawings.drawingsSLF:addParam("SLFrangeRcol", "Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
		Menu.drawings:addSubMenu("Target", "drawingsTRGT")
			Menu.drawings.drawingsTRGT:addParam("comboKillMRK", "Mark combo killable enemy", SCRIPT_PARAM_ONOFF, true)
			Menu.drawings.drawingsTRGT:addParam("comboKillMRKcol", "Color", SCRIPT_PARAM_COLOR, {255, 112, 0, 0})
		Menu:addSubMenu("Addons", "ads")
			Menu.ads:addParam("autoIGN", "Auto ignite killable enemy", SCRIPT_PARAM_ONOFF, true)
			Menu.ads:addParam("spellLVL", "Leveling spells mode", SCRIPT_PARAM_LIST, 1, {"none", "E > W", "E > Q", "W > Q", "W > E", "Q > E", "Q > W"})
			
		Menu:permaShow("useCombo")
		Menu:permaShow("useHarass")
		Menu:permaShow("useFarm")
end

function Variables()
	VP = VPrediction(true)
	SOWi = SOW(VP)
	ignite = nil
	DFG = nil
	ReadyDFG = false
	afterCombo = true
	tsDistance = 0
	Rcheck = 0
	Wcheck = 0
	Qcheck = 0
	Echeck = 0
	AAcheckY = 0
	AAcheckZ = 0
	DFGdmg = 0
	cmbo1 = 0
	cmbo2 = 0
	
	maxNone = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	maxQWE = {3,2,1,1,1,4,1,2,1,2,4,2,2,3,3,4,3,3}
	maxQEW = {3,2,1,1,1,4,1,3,1,3,4,3,3,2,2,4,2,2}
	maxWQE = {3,2,1,2,2,4,2,1,2,1,4,1,1,3,3,4,3,3}
	maxWEQ = {3,2,1,2,2,4,2,3,2,3,4,3,3,1,1,4,1,1}
	maxEQW = {3,2,1,3,3,4,3,1,3,1,4,1,1,2,2,4,2,2}
	maxEWQ = {3,2,1,3,3,4,3,2,3,2,4,2,2,1,1,4,1,1}
	
	ts = TargetSelector(TARGET_LESS_CAST,1275)
	enemyHeroes = GetEnemyHeroes()
	EnemyMinions = minionManager(MINION_ENEMY, 2000, myHero, MINION_SORT_MAXHEALTH_ASC)
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end
end

function OnTick()
	Initiate()
	MaxSpells()
	
	if Menu.ads.autoIGN then AutoIGN() end 
	if Menu.useCombo then
		Combo()
		return
	end
	if Menu.useHarass then
		Harass()
		return
	end
	if Menu.useFarm then
		EnemyMinions:update()
		local target = SOWKillableMinion()
		SOWOrbWalk(target) 
	end
end

function Combo()
	DMGcalc()
	if ts.target ~= nil then
		if Ready(DFG) and tsDistance < 750 then
			CastSpell(DFG, ts.target)
		end
		if Ready(_R) and tsDistance < 1000 then
			afterCombo = false
			CastR(ts.target)
			Rcheck = os.clock()
		end
		if tsDistance < 175 and os.clock() < Rcheck + 1 and ts.target.health > cmbo2 then
			if Ready(_W) then CastSpell(_W) end
				AAcheckY = os.clock()
				SOWi:Attack(ts.target)
		end
		if Ready(_E) and tsDistance > 600 and tsDistance < 800 and os.clock() < Rcheck + 1 and ts.target.health > cmbo2 then
			CastE(ts.target)
		end
		if Ready(_W) and tsDistance < 550 and os.clock() < Rcheck + 2 then
			CastSpell(_W)
			Wcheck = os.clock()
		end
		if tsDistance < 175 and os.clock() < Wcheck + 1 and ts.target.health > cmbo2 then
			AAcheckY = os.clock()
			SOWi:Attack(ts.target)
		end
		if Ready(_Q) and tsDistance < 550 and os.clock() > AAcheckY + 0.5 and os.clock() < AAcheckY + 1 then
			CastSpell(_Q, ts.target)
			Qcheck = os.clock()
		end
		if os.clock() < Qcheck + 1 and ts.target.health > cmbo2 and SOWi:CanAttack() and SOWi:ValidTarget(ts.target) and not SOWi:BeforeAttack(ts.target) then
			AAcheckZ = os.clock()
			SOWi:Attack(ts.target)
		end
		if Ready(_E) and tsDistance < 800 and os.clock() > AAcheckZ + 0.5 and os.clock() < AAcheckZ + 1 and ts.target.health > cmbo2 then
			CastE(ts.target)
		end
		
		if SOWi:CanMove() then
			local Mv = Vector(myHero) + 400 * (Vector(mousePos) - Vector(myHero)):normalized()
			SOWi:MoveTo(Mv.x, Mv.z)
		end
		if not Ready(_Q) and not Ready(_E) and not Ready(_R) then
			afterCombo = true
		end
		if afterCombo and not Ready(_R) then
			if Ready(_W) and (tsDistance < 175 or (Ready(_W) and Ready(_Q) and tsDistance < 550)) then
				CastSpell(_W)
			end
			if Ready(_Q) and tsDistance < 550 then
				CastSpell(_Q, ts.target)
			end
			if Ready(_E) and tsDistance < 850 and tsDistance > 200 then
				CastE(ts.target)
			end
			SOWOrbWalk(ts.target)
		end
	end
	if ts.target == nil then
		player:MoveTo(mousePos.x, mousePos.z)
	end
end

function Harass()
	local needMana = 40+(45+5*myHero:GetSpellData(_Q).level)+(80+10*myHero:GetSpellData(_E).level)
	if ts.target ~= nil then
		if myHero.mana < needMana then
			PrintFloatText(myHero,0,"Not enough mana")
		end
		if myHero.mana > needMana then
			if Ready(_W) and tsDistance < 551 then
				CastSpell(_W)
			end
			if Ready(_Q) and tsDistance < 550 then
				CastSpell(_Q, ts.target)
			end
		end
		SOWOrbWalk(ts.target)
	end
	if ts.target == nil then player:MoveTo(mousePos.x, mousePos.z) end
end

function DMGcalc()
	if ts.target ~= nil then
		local Qdmg = getDmg("Q",ts.target,myHero)
		local Rdmg = getDmg("R",ts.target,myHero)
		local Edmg = getDmg("E",ts.target,myHero)
		local ADdmg = getDmg("AD",ts.target,myHero)
		local Wdmg = getDmg("W",ts.target,myHero,1)
		if Ready(DFG) then
			DFGdmg = getDmg("DFG",ts.target,myHero)
		else
			DFGdmg = 0
		end
		cmbo1 = Qdmg + Rdmg + Edmg + DFGdmg + Wdmg + ADdmg
		cmbo2 = Qdmg + Rdmg + DFGdmg + Wdmg
	end
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
	DMGcalc()
	if Menu.drawings.drawingsSLF.SLFrangeAA then
		DrawCircle(myHero.x, myHero.y, myHero.z, 175, RGBColor(Menu.drawings.drawingsSLF.SLFrangeAAcol))
	end
	if Menu.drawings.drawingsSLF.SLFrangeQ then
		DrawCircle(myHero.x, myHero.y, myHero.z, 550, RGBColor(Menu.drawings.drawingsSLF.SLFrangeQcol))
	end
	if Menu.drawings.drawingsSLF.SLFrangeE then
		DrawCircle(myHero.x, myHero.y, myHero.z, 400, RGBColor(Menu.drawings.drawingsSLF.SLFrangeEcol))
		DrawCircle(myHero.x, myHero.y, myHero.z, 800, RGBColor(Menu.drawings.drawingsSLF.SLFrangeEcol))
	end
	if Menu.drawings.drawingsSLF.SLFrangeR then
		DrawCircle(myHero.x, myHero.y, myHero.z, 1275, RGBColor(Menu.drawings.drawingsSLF.SLFrangeRcol))
	end
	if Menu.drawings.drawingsTRGT.comboKillMRK and ts.target ~= nil then
		if ts.target.health < cmbo1 then
			PrintFloatText(ts.target,0,"Combo killable")
			for i = 0, 20 do
				DrawCircle(ts.target.x, ts.target.y, ts.target.z, 50 + i, RGBColor(Menu.drawings.drawingsTRGT.comboKillMRKcol))
			end
		end
	end
end

function MaxSpells()
	if Menu.ads.spellLVL == 1 then autoLevelSetSequence(maxNone) end
	if Menu.ads.spellLVL == 2 then autoLevelSetSequence(maxEWQ) end
	if Menu.ads.spellLVL == 3 then autoLevelSetSequence(maxEQW) end
	if Menu.ads.spellLVL == 4 then autoLevelSetSequence(maxWQE) end
	if Menu.ads.spellLVL == 5 then autoLevelSetSequence(maxWEQ) end
	if Menu.ads.spellLVL == 6 then autoLevelSetSequence(maxQEW) end
	if Menu.ads.spellLVL == 7 then autoLevelSetSequence(maxQWE) end
end

function AutoIGN()
	local igniteDMG = 50 + 20 * myHero.level
	for _, enemy in pairs(enemyHeroes) do
		if enemy.health <= igniteDMG and GetDistance(enemy) < 600 and Ready(ignite) then
			CastSpell(ignite, enemy)
		end
	end
end

function enemiesClose(range)
	enmsClose = 0
	for _, enemy in pairs(enemyHeroes) do
		if not enemy.dead and GetDistance(enemy) < range then enmsClose = enmsClose + 1 end
	end
	return enmsClose
end

function Initiate()
	ts:update()
	DFG = GetInventorySlotItem(3128)
	if ts.target ~= nil then tsDistance = GetDistance(ts.target) end
end

function Ready(spell)
	if spell ~= nil then 
		return myHero:CanUseSpell(spell) == READY 
	else
		return false
	end
end

function CastR(unit)
	local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, 0.5, 80, 1275, 1200, myHero, false) -- ?
	if CastPosition and HitChance >= 2 then
		CastSpell(_R, CastPosition.x, CastPosition.z)
	end
end

function CastE(unit)
	local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, 0.5, 330, 400, 1200, myHero, false) -- ?
	if CastPosition and HitChance >= 2 then
		CastSpell(_E, CastPosition.x, CastPosition.z)
	end
end

function RGBColor(menu)
        return ARGB(menu[1], menu[2], menu[3], menu[4])
end
