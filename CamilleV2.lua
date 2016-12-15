if myHero.charName ~= "Camille" then return end
require "VPrediction"
ultActive = false
qRange = 125
wRange = 600
eRange = 925
e2Range = 500
rRange = 475
SAC = false
OnWall = false
WCasting = false
WMagnet = false
IsDashing = false
QPriming = false
QCharged = false
MagnetBlock = false
local VP = VPrediction()

local targetTest
-- Bool if Camille follows her target for W
local follow
-- If she will follow for big radius
local big

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
    Config.settings:addParam("magW", "Magnet W To hit Target", SCRIPT_PARAM_ONOFF, true)
    Config.settings:addParam("comboE1", "Use E1 in combo", SCRIPT_PARAM_ONOFF, true)
    Config.settings:addParam("comboE2", "Use E2 in combo", SCRIPT_PARAM_ONOFF, true)
    Config.settings:addParam("gapE", "Save E for Gap Closer", SCRIPT_PARAM_ONOFF, false)
    Config.settings:addSubMenu("Hook Performance Settings", "hsettings")
    Config.settings.hsettings:addParam("dirchecks", "Num E Direction Checks", SCRIPT_PARAM_SLICE, 45, 0, 360, 1)
    Config.settings.hsettings:addParam("echecks", "Num E Depth Checks", SCRIPT_PARAM_SLICE, 10, 0, 60, 1)
    Config.settings.hsettings:addParam("drawDots", "Draw Wall Debug", SCRIPT_PARAM_ONOFF, false)
    Config:addParam("rangetest", "Champion Circle", SCRIPT_PARAM_SLICE, 500, 0, 2000, 1)
    targetSelector = TargetSelector(TARGET_LESS_CAST, 900, DAMAGE_PHYSICAL, true)

    if _G.Reborn_Loaded ~= nil then
    	SAC = true
    	print("Sac Found")
    end
end

function OnTick()
	--targetSelector:update()
	--Target = targetSelector.target
	Target = BestTarget(2000)
	if Target then	
		if SAC == true then
			_G.AutoCarry.Crosshair:ForceTarget(Target)
		end
	end
	controlOrb()
	if Config.shoot then
		Combo()
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
    		AR = enemy.armor/(100+enemy.armor)
    		HP = enemy.health
    		TargetValue = HP * 0.8 + AR * HP - (enemy.ap  * 2) - (enemy.addDamage* 3) + (GetDistance(enemy) * 0.5) - (myHero.level - enemy.level) * 50
			targetTest = TargetValue / 100 
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
function BestTargetDraw(Range)
	local BestValue = 1000000
	local BestEnemy = nil
	for i = 1, #GetEnemyHeroes() do
    	local enemy = GetEnemyHeroes()[i]
    	if enemy ~= nil and not enemy.dead and enemy.bInvulnerable == 0 and enemy.bTargetable and GetDistance(enemy) < Range and enemy.visible then
    		local AR = enemy.armor/(100+enemy.armor)
    		local HP = enemy.health
    		local TargetValue = HP * 0.8 + AR * HP - (enemy.ap  * 2) - (enemy.addDamage* 3) + (GetDistance(enemy) * 0.5) - (myHero.level - enemy.level) * 50
			DrawText3D(tostring(TargetValue), enemy.x-15, enemy.y-30, enemy.z, 15,ARGB(255,0,255,0))
    		if TargetValue < BestValue then
    			BestEnemy = enemy
    			BestValue = TargetValue
    		end
    	end
    end
    if BestEnemy then
    	DrawText3D("Target!!", BestEnemy.x-15, BestEnemy.y-60, BestEnemy.z, 25,ARGB(255,0,255,0))
    end
end


function OnDraw()
	if Config.settings.hsettings.drawDots then
		SurfBaby2Draw()
	end
	if WCasting == true or OnWall == true then
		DrawText3D("SAC Disabled",myHero.x, myHero.y, myHero.z,15,ARGB(255,0,0,255))
	else
		DrawText3D("SAC Enabled",myHero.x, myHero.y, myHero.z,15,ARGB(255,0,0,255))
	end
	if WCasting == true then
		DrawText3D("W Casting",myHero.x, myHero.y+35, myHero.z,15,ARGB(255,0,0,255))
	else
		DrawText3D("W Not Casting",myHero.x, myHero.y+35, myHero.z,15,ARGB(255,0,0,255))
	end
	if OnWall == true then
		DrawText3D("On A Wall",myHero.x, myHero.y+65, myHero.z,15,ARGB(255,0,0,255))
	else
		DrawText3D("Away From Wall",myHero.x, myHero.y+65, myHero.z,15,ARGB(255,0,0,255))
	end
	if IsDashing == true then
		DrawText3D("Dashing",myHero.x, myHero.y+95, myHero.z,15,ARGB(255,0,0,255))
	else
		DrawText3D("Not Dashing",myHero.x, myHero.y+95, myHero.z,15,ARGB(255,0,0,255))
	end
	if QPriming == true then
		DrawText3D("Q Priming",myHero.x, myHero.y+125, myHero.z,15,ARGB(255,0,0,255))
	else
		DrawText3D("Not Priming",myHero.x, myHero.y+125, myHero.z,15,ARGB(255,0,0,255))
	end
	if QCharged== true then
		DrawText3D("Q Charged",myHero.x, myHero.y+155, myHero.z,15,ARGB(255,0,0,255))
	else
		DrawText3D("Not Charged",myHero.x, myHero.y+155, myHero.z,15,ARGB(255,0,0,255))
	end

	DrawCircle(myHero.x, myHero.y, myHero.z, Config.rangetest, ARGB(255,255,255,255))
	if Target then 
		DrawCircle(Target.x, Target.y, Target.z, 50, ARGB(255,255,255,255))
	end
	BestTargetDraw(1000)	
end

function Combo()
	if Target then
		if Config.settings.magW then
			followTarget(Target)
		end
		if myHero:CanUseSpell(_Q) == READY and GetDistance(Target) < qRange and Config.settings.comboQ == true then	    
			CastQ(Target)		
		end
		if WCasting == false and myHero:CanUseSpell(_E) == READY and Config.settings.comboE1 == true then
			if GetDistance(Target) > 225 then
				if GetDistance(Target) < 550 and Target.ms < myHero.ms and Config.settings.gapE == true then

				else
					SurfBaby2(Target)
				end
			end
		end
		if myHero:CanUseSpell(_E) == READY then
			DelayAction(function() CheckWCast() end, 0.1)
		else
			CheckWCast()
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
			QPriming = false
	end
end
function CheckWCast()
	if myHero:CanUseSpell(_W) == READY and QPriming == false and QCharged == false and IsDashing == false and Config.settings.comboW == true then
		CastW(Target)
	end
end

function CastQ()
	if QPriming == false and Config.settings.comboQReset then
   		CastSpell(_Q)
    	ResetAA()
    end
end

function ResetAA()
	if SAC == true then
		_G.AutoCarry.Orbwalker:ResetAttackTimer()
	end
	if Target and Config.shoot then
		myHero:Attack(Target)
	end
end

-- Follow for _W
function followTarget(target)
	if WCasting == true then
		moveBig(target)
	end
end

-- Follow to hit with the big W
function moveBig(target)
	if GetDistance(target) > 225 and GetDistance(target) < 825 and OnWall == false and MagnetBlock == false then
		WMagnet = true
		HeroPos = Vector(myHero.x, myHero.z)
		TargetPos = Vector(target.x, target.z)
		MovePos = Vector(TargetPos - (TargetPos-HeroPos):normalized() * 410)
		myHero:MoveTo(MovePos.x, MovePos.y)
	else
		WMagnet = false
	end
end

function CastW(target)
	if GetDistance(target) > 300 then
		CastWBig(target)
	end
	if myHero:CanUseSpell(_E) ~= READY and myHero:CanUseSpell(_Q) ~= READY then
		CastWSmall(target)
	end 
end

function CastWSmall(target)
	if target ~= nil then
		local CastPosition, HitChance, Position = VP:GetLineCastPosition(target, 0, 750, 600, 800, myHero, false)
    	if CastPosition and HitChance >= 2 and GetDistance(CastPosition) < 600 then
        	CastSpell(_W, CastPosition.x, CastPosition.z)
        	MagnetBlock = true
		end
	end
end



function CastWBig(target)
	if target ~= nil then
		local CastPosition, HitChance, Position = VP:GetLineCastPosition(target, 0, 750, 600, 800, myHero, false)
    	if CastPosition and HitChance >= 2 and GetDistance(CastPosition) < 600 then
        	CastSpell(_W, CastPosition.x, CastPosition.z)
		end
	end
end


function CastE2(target)
	if target ~= nil then
    	local CastPosition, HitChance = VP:GetLineCastPosition(target, 0.25, 70, 1000, 1000, myHero, false)
    	if HitChance >= 1 then
      		CastSpell(_E, CastPosition.x, CastPosition.z)
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

function controlOrb()
	if WMagnet == true or OnWall == true then
		stopAll()
	else
		startAll()
	end 
end

function stopAll()
	--print("stopped")
	if SAC == true then
    	_G.AutoCarry.MyHero:AttacksEnabled(false)
    	_G.AutoCarry.MyHero:MovementEnabled(false)
    end
end

function startAll()
	--print("started")
	if SAC == true then
    	_G.AutoCarry.MyHero:AttacksEnabled(true)
    	_G.AutoCarry.MyHero:MovementEnabled(true)
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
	return GetWSmallDamage(target) + math.ceil(myHero:CalcDamage(target,target.maxHealth * (healthlevel + bonusAd)))
end

function OnAnimation(unit, animation)
    if unit.isMe then
        if animation == "Spell3" or animation == "Spell3_Dash1" or animation == "Spell3_Wall" or animation == "Spell3_Dash2_short" then
            IsDashing = true
        elseif IsDashing and (animation == "Idle1" or animation == "Run") then
            IsDashing = false
        end
    end
end

function OnUpdateBuff(Src, Buff, iStacks)
	if Src == myHero then
		--print(Buff.name)
	end
end

function OnApplyBuff(Src, Target, Buff)
	if Src == myHero then
		if Buff.name == "camilleeonwall" or Buff.name == "camilleedashtoggle" then
			OnWall = true
		end
		if Buff.name == "camilleqprimingstart" then
			QPriming = true
		end
		if Buff.name == "camilleqprimingcomplete" then
			QCharged = true
			QPriming = false
		end
		if Buff.name == "camillewconeslashcharge" then 
			WCasting = true
    	end
		--print(Buff.name)
	end
end

function OnRemoveBuff(Src, Buff)
	if Src == myHero then
		if Buff.name == "camilleeonwall" or Buff.name == "camilleedashtoggle"  then
			OnWall = false
		end
		-- If WCast is over
		if Buff.name == "camillewconeslashcharge" then 
			WCasting = false
			WMagnet = false
			MagnetBlock = false
    	end
    	if Buff.name == "CamilleQ2" then
    		QCharged = false
    	end
		--print(Buff.name)
	end
end

function OnCreateObj(obj)
	if GetDistance(obj) < 50 then
		--PrintChat(obj.name)
	end
end


function OnDeleteObj(obj)
	if GetDistance(obj) < 50 then
		--PrintChat(obj.name)
	end
end

function OnProcessSpell(unit, spell)
	if unit == myHero then
		--print(spell.name)
		if spell.name == "CamilleQ" then
			DelayAction(function() SaveQ() end, 2.9 - GetLatency() / 2000)
			QPriming = false
		end
		if spell.name == "CamilleQ2" then
			QPriming = false
			QCharged = false
		end
		if spell.name == "CamilleE" then
			IsDashing = true
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
