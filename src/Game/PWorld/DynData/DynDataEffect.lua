--
-- Author: haialexzhou
-- Date: 2021-9-16
-- Description:动态物件特效
--
local ProtoCommon = require("Protocol/ProtoCommon")
local LuaClass = require("Core/LuaClass")
local DynDataBase = require("Game/PWorld/DynData/DynDataBase")
local ContentSgMgr = _G.UE.UContentSgMgr
---@class DynDataEffect
local DynDataEffect = LuaClass(DynDataBase, true)

local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_INFO = _G.FLOG_INFO

function DynDataEffect:Ctor()
    self.MapDynamicAssetModel = nil
    self.bCurrIsInit = false
    self.DataType = ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE
end


function DynDataEffect:Destroy()
    if self.Super ~= nil then
        self.Super:Destroy()
    end
    
    self.MapDynamicAssetModel = nil
    self.bCurrIsInit = false
end

function DynDataEffect:SetPlayRate(PlayRate)
    if (self.MapDynamicAssetModel ~= nil) then        
        local DynamicAssetActor = self.MapDynamicAssetModel:Cast(_G.UE.AMapDynamicAssetBase)
        if (DynamicAssetActor ~= nil) then
            PlayRate = PlayRate / 100
            DynamicAssetActor:SetPlayRate(PlayRate)
        end
    end
end

function DynDataEffect:SetIsInit(bInit)
    self.bCurrIsInit = bInit
end

function DynDataEffect:UpdateState(NewState)
    -- FLOG_INFO("DynDataEffect:UpdateState for id [%d], new [%d]", self.ID, NewState)
    if (self.MapDynamicAssetModel ~= nil) then
        local DynamicAssetActor = self.MapDynamicAssetModel:Cast(_G.UE.AMapDynamicAssetBase)
        if (DynamicAssetActor ~= nil and self.State ~= NewState) then
            DynamicAssetActor:UpdateState(NewState, self.bCurrIsInit)
        end

        local SgActor = self.MapDynamicAssetModel:Cast(_G.UE.ASgLayoutActorBase)
        if (SgActor ~= nil) then
            -- 不判断NewState是否和旧state一致
            -- FLOG_INFO("  SgActor [%d] UpdateState: old [%d] new [%d]", self.ID, self.State, NewState)
            ---SgActor:UpdateState(NewState)
            local ContentSgMgrInstance = ContentSgMgr:Get()
            if ContentSgMgrInstance ~= nil then
                ContentSgMgrInstance:PlayManagedSGWithIndex(SgActor,NewState)
            end
        end
    end

    self.Super:UpdateState(NewState)

    --针对一些没有marklabel的sequence
    -- if (self.State > 0) then
    --     self:Show()
    -- end
end


function DynDataEffect:Show()
    if (self.MapDynamicAssetModel ~= nil) then
        local DynamicAssetActor = self.MapDynamicAssetModel:Cast(_G.UE.AMapDynamicAssetBase)
        if (DynamicAssetActor ~= nil) then
            DynamicAssetActor:PlayAnim()
        end
    end
end

return DynDataEffect