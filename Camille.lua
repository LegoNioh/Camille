if myHero.charName ~= "Camille" then return end
require "VPrediction"
ultActive = false
qRange = 125
wRange = 600
eRange = 925
e2Range = 500
rRange = 475
CanQ = true
canW = true
CanE = true
local VP = VPrediction()

-- Bool if Camille follows her target for W
local follow
-- If she will follow for big radius
local big
-- If she will follow for small radius
local small

local numbers = {["W"] = {name = "CamilleW",rangeBig = 600, rangesmall = 300, projectileSpeed = 800, radiusBig = 750,radiusSmall = 380}};

function OnLoad()
    Config = scriptConfig("Cam 6.22", "KK")
    Config:addParam("shoot", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
    Config:addParam("ult", "Cast R On Target", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("R"))
    Config:addParam("flee", "Flee", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
    Config:addSubMenu("Combo Settings", "settings")
    Config.settings:addParam("comboQ", "Start With Q in combo", SCRIPT_PARAM_ONOFF, false)
    Config.settings:addParam("comboQReset", "Reset AA With Q", SCRIPT_PARAM_ONOFF, true)
    Config.settings:addParam("comboW", "Use W in combo", SCRIPT_PARAM_ONOFF, true)
    Config.settings:addParam("comboE1", "Use E1 in combo", SCRIPT_PARAM_ONOFF, true)
    Config.settings:addParam("comboE2", "Use E2 in combo", SCRIPT_PARAM_ONOFF, true)
    Config.settings:addSubMenu("Hook Settings", "hsettings")
    Config.settings.hsettings:addParam("dirchecks", "Num E Direction Checks", SCRIPT_PARAM_SLICE, 45, 0, 360, 1)
    Config.settings.hsettings:addParam("echecks", "Num E Depth Checks", SCRIPT_PARAM_SLICE, 10, 0, 60, 1)
    Config.settings.hsettings:addParam("drawDots", "Draw Wall Debug", SCRIPT_PARAM_ONOFF, false)
    Config:addParam("rangetest", "Champion Circle", SCRIPT_PARAM_SLICE, 500, 0, 2000, 1)
    targetSelector = TargetSelector(TARGET_LESS_CAST, 900, DAMAGE_PHYSICAL, true)
end

function OnTick()
	targetSelector:update()
	Target = targetSelector.target
	--Target = BestTarget(900)
	if Target then
		_G.AutoCarry.Crosshair:ForceTarget(Target)
	end 
	--print((GetSpellData(_E).cd + GetSpellData(_E).cd*myHero.cdr)-GetSpellData(_E).currentCd)
	--print(GetSpellData(_E).name)
	--print(GetSpellData(_E).currentCd)
	if Config.shoot then
		Combo()
	end
	if myHero:CanUseSpell(_Q) ~= READY then
		canW = true
	end
	if Config.ult and Target then
		if GetDistance(Target) < rRange then
			CastSpell(_R, Target)
		end
	end
end

function BestTarget(Range)
	BestValue = 1000000
	BestEnemy = nil
	OrbTargetChosen = false
	for i = 1, #GetEnemyHeroes() do
    	local enemy = GetEnemyHeroes()[i]
    	if enemy ~= nil and not enemy.dead and enemy.bInvulnerable == 0 and enemy.bTargetable and GetDistance(enemy) < Range and enemy.visible then
    		MR = enemy.magicArmor/(100+enemy.magicArmor)
    		HP = enemy.health
    		TargetValue = HP + MR*HP - (enemy.ap) - (enemy.addDamage*1.2) + (GetDistance(enemy))
    		if TargetValue < BestValue then
    			BestEnemy = enemy
    			BestValue = TargetValue
    		end
    	end
    end
    if BestEnemy then
    		return BestEnemy
	else
    	return nil
    end
end

function ResetAA()
	_G.AutoCarry.Orbwalker:ResetAttackTimer()
	if Target and Config.shoot then
		myHero:Attack(Target)
	end
end

function OnDraw()
		if Config.settings.hsettings.drawDots then
			SurfBaby2Draw()
		end
		DrawCircle(myHero.x, myHero.y, myHero.z, Config.rangetest, ARGB(255,255,255,255))
		if Target then 
			DrawCircle(Target.x, Target.y, Target.z, 50, ARGB(255,255,255,255))
		end
		for i = 1, #GetEnemyHeroes() do
    		local enemy = GetEnemyHeroes()[i]
    		if enemy ~= nil and not enemy.dead and enemy.bInvulnerable == 0 and enemy.bTargetable then
    		local MR = enemy.magicArmor/(100+enemy.magicArmor)
    		local HP = enemy.health
    		local TargetValue = HP + MR*HP - (enemy.ap) - (enemy.addDamage*1.2) - (GetDistance(enemy))
			DrawText3D(tostring(TargetValue), enemy.x-15, enemy.y-30, enemy.z, 15,ARGB(255,0,255,0))
    	end
    end
end

function SurfBaby2Draw()
	local Distance = 1000
	local Checks = Config.settings.hsettings.echecks
	local Directions = Config.settings.hsettings.dirchecks
	local DirAdd = 360/Directions
	local CheckD = math.ceil(Distance/Checks)
	local StartPoint= Vector(myHero.x+50, myHero.y, myHero.z)
	local MousePos = Vector(mousePos.x, mousePos.y, mousePos.z)
	local CheckPoint =  nil
	local WallPoint = false
	local Direction = nil
	local SurfPoint = nil
	local SecondPoint = nil
	local PickedPointD = nil
	--GetDirectionFrom(FromPos, TooPos, Angle)
	for i = 1, Directions, 1 do
		Direction = GetDirectionFrom(myHero, StartPoint, i*DirAdd)
		for j = 1, Checks, 1 do
			CheckPoint = myHero + Direction * CheckD*j
			WallPoint = IsWall(D3DXVECTOR3(CheckPoint.x, CheckPoint.y, CheckPoint.z))
			if WallPoint then
				DrawCircle(CheckPoint.x, CheckPoint.y, CheckPoint.z, 12, ARGB(255,255,255,255))
				break
			end
		end
	end
end

function SurfBaby2(Target)
	local Distance = 1000
	local Checks = Config.settings.hsettings.echecks
	local Directions = Config.settings.hsettings.dirchecks
	local DirAdd = 360/Directions
	local CheckD = math.ceil(Distance/Checks)
	local StartPoint= Vector(myHero.x+50, myHero.y, myHero.z)
	local MousePos = Vector(mousePos.x, mousePos.y, mousePos.z)
	local CheckPoint =  nil
	local WallPoint = false
	local Direction = nil
	local SurfPoint = nil
	local SecondPoint = nil
	local PickedPointD = nil
	local ClosePoint = nil
	--GetDirectionFrom(FromPos, TooPos, Angle)
	for i = 1, Directions, 1 do
		Direction = GetDirectionFrom(myHero, StartPoint, DirAdd*i)
		for j = 1, Checks, 1 do
			CheckPoint = myHero + Direction * CheckD*j
			WallPoint = IsWall(D3DXVECTOR3(CheckPoint.x, CheckPoint.y, CheckPoint.z))
			if WallPoint then
				if GetDistance(Target, CheckPoint) < GetDistance(Target, ClosePoint) or ClosePoint == nil then
					ClosePoint = CheckPoint
				end 
				break
			end
		end
	end

	if GetSpellData(_E).name == "CamilleE" and ClosePoint and GetDistance(Target, ClosePoint) < 750 then
		CastSpell(_E, ClosePoint.x, ClosePoint.z)
	end
end

function GetDirectionFrom(FromPos, TooPos, Angle)
	FirstPos = Vector(FromPos.x, FromPos.y, FromPos.z)
	SecondPos = Vector(TooPos.x, FromPos.y, TooPos.z)
	InitalDirection = Vector((FirstPos-SecondPos):normalized())
	RotatedDirection = InitalDirection:rotated(0, math.rad(Angle), 0)
	if RotatedDirection then
		return RotatedDirection
	else
		return nil
	end
end


function MoveToOrb()
		return mousePos
end


function Combo()
	if Target then
		if myHero:CanUseSpell(_Q) == READY and GetDistance(Target) < qRange and Config.settings.comboQ == true then
			CastQ(Target)
		end
		if myHero:CanUseSpell(_W) == READY and canW == true and Config.settings.comboW == true and GetSpellData(_E).currentCd > 0 and (GetSpellData(_E).cd + GetSpellData(_E).cd*myHero.cdr)-GetSpellData(_E).currentCd > 1 then
			CastW(Target)
			followTarget(Target)
		end
		if CanE == true and myHero:CanUseSpell(_E) == READY and Config.settings.comboE1 == true and canW == true then
			SurfBaby2(Target)
		end
		if myHero:CanUseSpell(_E) == READY and GetSpellData(_E).name == "CamilleEDash2" and Config.settings.comboE2 == true then
			CastE2(Target)
		end
	end
end

function SaveQ() 
	if GetSpellData(_Q).name == "CamilleQ2" and myHero:CanUseSpell(_Q) == READY then
			--print("saved Q")
			CastSpell(_Q)
			ResetAA()
	end
end


function CastQ()
	if CanQ == true and Config.settings.comboQReset then
   		CastSpell(_Q)
    	ResetAA()
    end
end

-- Follow for _W
function followTarget(target)
if not follow then return end
moveBig(ts.target)
moveSmall(ts.target)
end

-- Decides which one deals more damage
function CastW(target)

    if GetWBigDamage(target) > GetWSmallDamage(target) then
        big = true
        CastWBig(target)
        else
        small = true
        CastWSmall(target)
    end
	
end

function CastWBig(target)


 local CastPosition, HitChance, Position = VP:GetLineCastPosition(target, 0, 750, 600, 800, myHero, false)
     if CastPosition and HitChance >= 2 and GetDistance(CastPosition) < 600 then
         CastSpell(_W, CastPosition.x, CastPosition.z)
end
end

function CastWSmall(target)


 local CastPosition, HitChance, Position = VP:GetLineCastPosition(target, 0, 380, 600, 800, myHero, false)
     if CastPosition and HitChance >= 2 and GetDistance(CastPosition) < 600 then
         CastSpell(_W, CastPosition.x, CastPosition.z)
end
end

-- WSCALE 60%AD
-- WBASE 65
-- WPERLEVEL 30

function GetWSmallDamage(target)

if (myHero:CanUseSpell(_W) ~= READY) then return 0 end

local lvl = myHero:GetSpellData(_W).level

local scale = lvl * 30 + 35
local bonusAd = myHero.addDamage * 0.6

return math.ceil(myHero:CalcDamage(target,scale + bonusAd))

end


-- DMGPERLIFELEVEL 0.5%
-- PERLIFE BASE 6
-- 3% per 100 ad
function GetWBigDamage(target)

if (myHero:CanUseSpell(_W) ~= READY) then return 0 end

local lvl = myHero:GetSpellData(_W).level

local healthlevel = (lvl * 0.5 + 5.5) / 100
local bonusAd = (math.ceil(myHero.addDamage / 100) * 3) / 100

return math.ceil(myHero:CalcDamage(target,target.maxHealth * (healthlevel + bonusAd)))

end

-- Follow to hit with the big W
function moveBig(target)

if not follow and not big then return end

--_G.AutoCarry.MyHero:AttacksEnabled(false)
--_G.AutoCarry.MyHero:MovementEnabled(false)
	
if GetDistance(target) < 300 then

local vec = Vector(target.x - myHero.x,target.y - myHero.y,target.z - myHero.z)
vec:normalize()

vec = LenVector(vec,301 - GetDistance(target))

myHero:MoveTo(vec.x + myHero.x,vec.z + myHero.z)

elseif GetDistance(target) > 600 then

myHero:MoveTo(target.x,target.z)

end

-- _G.AutoCarry.MyHero:AttacksEnabled(true)
--_G.AutoCarry.MyHero:MovementEnabled(true)
	
end

-- Follow to hit with the big W
function moveSmall(target)

if not follow and not small then return end

--_G.AutoCarry.MyHero:AttacksEnabled(false)
--_G.AutoCarry.MyHero:MovementEnabled(false)

if GetDistance(target) > 300 then

myHero:MoveTo(target.x,target.z)

end

-- _G.AutoCarry.MyHero:AttacksEnabled(true)
--_G.AutoCarry.MyHero:MovementEnabled(true)
end

function CastE2(target)
	if target ~= nil then
    	local CastPosition, HitChance = VP:GetLineCastPosition(target, 0.25, 70, 1000, 1500, myHero, false)
    	if HitChance >= 1 then
      		CastSpell(_E, CastPosition.x, CastPosition.z)
    	end
	end
end

function stopAll()
	print("stopped")
    _G.AutoCarry.MyHero:AttacksEnabled(false)
    _G.AutoCarry.MyHero:MovementEnabled(false)
	DelayAction(function() startAll() end, 1.5)
end

function startAll()
	print("started")
    _G.AutoCarry.MyHero:AttacksEnabled(true)
    _G.AutoCarry.MyHero:MovementEnabled(true)
end


function OnUpdateBuff(Src, Buff, iStacks)
	if Src == myHero then
		--print(Buff.name)
	end
end

function OnApplyBuff(Src, Target, Buff)
	if Src == myHero then
		if Buff.name == "camilleeonwall" or Buff.name == "camilleedashtoggle" then
			if Config.shoot and myHero:CanUseSpell(_W) == READY then
				--print("should cast W")
				--CastW(Target)
			end
			stopAll()
		end
		if Buff.name == "camilleqprimingstart" then
			CanQ = false
		end
		if Buff.name == "camilleqprimingcomplete" then
			CanW = false
			CanQ = true
		end
		--print(Buff.name)
	end
end

function OnRemoveBuff(Src, Buff)
	if Src == myHero then
		if Buff.name == "camilleeonwall" or Buff.name == "camilleedashtoggle"  then
			startAll()
		end
	end
end

function OnCreateObj(obj)
	if GetDistance(obj) < 1000 then
		--PrintChat(obj.name)
	end
end


function OnDeleteObj(obj)
	if GetDistance(obj) < 1000 then
		--PrintChat(obj.name)
	end
	-- If WCast is over
    if obj.valid and obj.name:find("Indicator_ally.troy") then 

    follow = false
    big = false
    small = false

    end
end

function OnProcessSpell(unit, spell)
	if unit == myHero then
		
		if spell.name == "CamilleW" then
			follow = true
		end
		if spell.name == "CamilleQ" then
			DelayAction(function() SaveQ() end, 2.9 - GetLatency() / 2000)
		end
		if spell.name == "CamilleQ2" then
			CanQ = true
		end
		if spell.name == "CamilleE" then
			stopAll()
		end
		if spell.name == "CamilleEDash2" then
			startAll()
		end
	end
end

function OnProcessAttack(unit, attack)
	if unit == myHero then
		--print(attack.name)
		--print(attack.windUpTime- GetLatency() / 2000)
	end
	if unit == myHero and Config.shoot then
		if myHero:CanUseSpell(_Q) == READY then
			DelayAction(function() CastQ() end, attack.windUpTime - GetLatency() / 2000)
		end
	end
end

-- Lengthens a vector
function LenVector(vector,mod)

return Vector(vector.x * mod,vector.y * mod,vector.z * mod)

end
