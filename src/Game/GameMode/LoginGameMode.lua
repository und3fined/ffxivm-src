--
-- Author: anypkvcai
-- Date: 2020-08-20 15:05:33
-- Description:
--



require "UnLua"
local CommonUtil = require("Utils/CommonUtil")
local GameplayStaticsUtil = require("Utils/GameplayStaticsUtil")
local ObjectGCType = require("Define/ObjectGCType")
local Class = _G.Class

-- local LoginGameMode = LuaUEClass()
local LoginGameMode = Class()

--function LoginGameMode:Initialize(Initializer)
--end

--function LoginGameMode:UserConstructionScript()
--end

function LoginGameMode:ReceiveBeginPlay()

end

-- function LoginGameMode:ReceiveEndPlay()
-- end

-- function LoginGameMode:ReceiveTick(DeltaSeconds)
-- end

--function LoginGameMode:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
--end

--function LoginGameMode:ReceiveActorBeginOverlap(OtherActor)
--end

--function LoginGameMode:ReceiveActorEndOverlap(OtherActor)
--end

return LoginGameMode
