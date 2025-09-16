--
-- Author: haialexzhou
-- Date: 2020-12-21
-- Description:副本进度管理
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")

local PworldStepCfg = require("TableCfg/PworldStepCfg")

---@class PWorldStageMgr : MgrBase
local PWorldStageMgr = LuaClass(MgrBase)

function PWorldStageMgr:OnInit()
    self:InitData()
end

function PWorldStageMgr:OnBegin()
end

function PWorldStageMgr:OnEnd()
end

function PWorldStageMgr:OnShutdown()
end

function PWorldStageMgr:InitData()
    self.StageInfoList = nil
    self.CurrStage = 1 --当前阶段
    self.CurrProcess = 0 --当前阶段的进度
    self.CurrIconPath = nil
end

function PWorldStageMgr:Reset()
    self:InitData()
end

function PWorldStageMgr:UpdateProcess(PWorldResID, NewStage, NewProcess)
    if (self.StageInfoList == nil) then
        self:InitPWorldStageInfo(PWorldResID)
    end
    self.CurrStage = NewStage
    self.CurrProcess = NewProcess

    _G.EventMgr:SendEvent(_G.EventID.PWorldStageInfoUpdate)
end


function PWorldStageMgr:InitPWorldStageInfo(PWorldResID)
    local PworldStepTableCfg = PworldStepCfg:FindCfgByKey(PWorldResID)
    if (PworldStepTableCfg == nil or PworldStepTableCfg.Steps == nil) then
        return
    end

    local StageUnitList = {}
    local StageCount = 10 --目前最多10个阶段
    for i = 1, StageCount do
        local PworldStepInfo = PworldStepTableCfg.Steps[i]
        if (PworldStepInfo ~= nil) then
            if (PworldStepInfo.Text ~= "" and PworldStepInfo.MaxProgress > 0) then
                local StageUnit = {}
                StageUnit.Text = PworldStepInfo.Text
                StageUnit.MaxProgress = PworldStepInfo.MaxProgress
                table.insert(StageUnitList, StageUnit)
            end
        end
    end

    self.CurrIconPath = PworldStepTableCfg.Icon
    self.StageInfoList = StageUnitList
end

return PWorldStageMgr