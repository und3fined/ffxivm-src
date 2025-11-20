--[[
Author: luojiewen_ds luojiewen@dasheng.tv
Date: 2024-07-18 20:49:09
LastEditors: luojiewen_ds luojiewen@dasheng.tv
LastEditTime: 2024-09-28 23:34:47
FilePath: \Script\Game\Hotel\UIShadowMgr.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local CommonUtil = require("Utils/CommonUtil")
local ObjectGCType = require("Define/ObjectGCType")
local SaveKey = require("Define/SaveKey")

-- @class UIShadowMgr : MgrBase
local UIShadowMgr = LuaClass(MgrBase)

function UIShadowMgr:Ctor()

end

function UIShadowMgr:OnInit()
    self.ShadowActor = nil
    self.ShadowCount = 0
end

function UIShadowMgr:OnRegisterGameEvent()

end

function UIShadowMgr:OnGameEventLoginRes(Params)

end

function UIShadowMgr:GetUIActorShandow(WorldContextObject, TargetActor, InImage, Location, Type, IsComplexActor)
    if not self.ShadowActor then
        if not WorldContextObject or not TargetActor or not InImage then
            FLOG_ERROR("[UIActorShandow] Param Is Nil! Please Check")
            return
	    end
	    --低，极低画质关闭阴影
	    local QualityLevel = _G.UE.USaveMgr.GetInt(SaveKey.QualityLevel, _G.SettingsMgr.DefauleValueNotSave, false)
	    if QualityLevel <= 2 then
            FLOG_INFO("[UIActorShandow] QualityLevel Low")
            return
	    end
	    local AllActor = _G.UE.TArray(_G.UE.AActor)
	    if IsComplexActor then
            for _, value in pairs(TargetActor) do
                AllActor:Add(value)
            end
	    else
            AllActor:Add(TargetActor)
	    end
        local Path = "Class'/Game/MaterialLibrary/Blueprint/PlaneShadow/BP_Character_PlaneShadow.BP_Character_PlaneShadow_C'"
	    local Class = _G.ObjectMgr:LoadClassSync(Path, ObjectGCType.NoCache)
        Location = Location or _G.UE.FVector(-50, 0, 100002)
        local ShandowActor = CommonUtil.SpawnActor(Class, Location)
	    if not ShandowActor then return end
        ShandowActor:UseSetting(Type or "Role")
        local CaptureComp2D = ShandowActor.SceneCaptureComponent2D
	    if CaptureComp2D then
            --默认256x256
            CaptureComp2D.bCaptureEveryFrame = true
            CaptureComp2D:ClearShowOnlyComponents()
            CaptureComp2D:SetVisibility(true)
            CaptureComp2D.ShowOnlyActors = AllActor
	    end
        --持有的引用各个模块自行销毁
        self.ShadowActor = ShandowActor
    end
    self.ShadowCount = self.ShadowCount + 1
    FLOG_INFO("[UIShadowMgr]GetUIActorShandow ShadowCount ========="..self.ShadowCount)
	return self.ShadowActor
end

function UIShadowMgr:ReleaseShadowActor()
    self.ShadowCount = self.ShadowCount - 1
    FLOG_INFO("[UIShadowMgr] ReleaseShadowActor ShadowCount ========="..self.ShadowCount)
    if self.ShadowCount <= 0 then
        self:DestoryShadowActor()
    end
end

function UIShadowMgr:DestoryShadowActor()
    if not self.ShadowActor then return end
    _G.CommonUtil.DestroyActor(self.ShadowActor)
    self.ShadowActor = nil
end

function UIShadowMgr:UpdateActorList(ActorList)
    if self.ShadowActor and self.ShadowActor.SceneCaptureComponent2D then
        self.ShadowActor.SceneCaptureComponent2D:ClearShowOnlyComponents()
	    self.ShadowActor.SceneCaptureComponent2D.ShowOnlyActors = ActorList
    end
end

function UIShadowMgr:UpdateCompnent(Component)
    local AllActor = _G.UE.TArray(_G.UE.AActor)
	self.ShadowActor.SceneCaptureComponent2D.ShowOnlyActors= AllActor
	self.ShadowActor.SceneCaptureComponent2D:ClearShowOnlyComponents()
	self.ShadowActor.SceneCaptureComponent2D:ShowOnlyActorComponents(Component)
end

return UIShadowMgr