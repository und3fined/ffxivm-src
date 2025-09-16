--[[
Date: 2023-03-08 15:34:20
LastEditors: moody
LastEditTime: 2023-03-08 15:34:20
--]]
require "UnLua"
local CommonUtil = require("Utils/CommonUtil")
local GameplayStaticsUtil = require("Utils/GameplayStaticsUtil")
local ObjectGCType = require("Define/ObjectGCType")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local Class = _G.Class

-- local SDKGameMode = LuaUEClass()
local SDKGameMode = Class()

function SDKGameMode:Initialize(Initializer)
	self.MainPanel = nil
end

--function SDKGameMode:UserConstructionScript()
--end

function SDKGameMode.Get()
	return _G.UE.UGameplayStatics.GetGameMode(GameplayStaticsUtil:GetWorld())
end

function SDKGameMode:LuaInit()
	self.MainPanel = UIViewMgr:ShowView(UIViewID.SDKMainPanel)
end

function SDKGameMode:ReceiveEndPlay()
	UIViewMgr:HideView(UIViewID.SDKMainPanel)
	self.MainPanel = nil
end

function SDKGameMode:AppendInfo(Log)
	self.MainPanel:AppendInfo(Log)
end

function SDKGameMode:AppendWarn(Log)
	self.MainPanel:AppendWarn(Log)
end

function SDKGameMode:AppendError(Log)
	self.MainPanel:AppendError(Log)
end

-- function SDKGameMode:ReceiveTick(DeltaSeconds)
-- end

--function SDKGameMode:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
--end

--function SDKGameMode:ReceiveActorBeginOverlap(OtherActor)
--end

--function SDKGameMode:ReceiveActorEndOverlap(OtherActor)
--end

return SDKGameMode