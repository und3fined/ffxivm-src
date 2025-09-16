local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local FateMainCfgTable = require("TableCfg/FateMainCfg")
local FateTargetCfgTable = require("TableCfg/FateTargetCfg")
local FateTextCfgTable = require("TableCfg/FateTextCfg")
local FateDefine = require("Game/Fate/FateDefine")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local TimeUtil = require("Utils/TimeUtil")
local FateHighRiskCfg = require("TableCfg/FateHighRiskCfg")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local LSTR = _G.LSTR

local FateStageInfoVM = LuaClass(UIViewModel)

function FateStageInfoVM:Ctor()
    self.FateID = 0
    self.EndTimeMS = 0
    self.Progress = 0
    self.LevelSyncState = 0
    self.Level = 0
    self.TargetName = ""
    self.Description = ""
    self.IconPath = ""
    self.ProgressTitleText = ""
    self.bIsExpanded = true
    self.bHighRisk = false
    self.HighRiskFateTtitle = ""
    self.HighRiskFateDesc = ""
    self.TipsIconPath = ""
    self.bShowPanelFateArchive = true
end

function FateStageInfoVM:OnBegin()
end

function FateStageInfoVM:GetFateID()
    return self.FateID
end

function FateStageInfoVM:IsEqualVM(Value)
    return self.FateID == Value.FateID
end

function FateStageInfoVM:UpdateVM(Value)
    local TargetFate = Value.TargetFate
    self.FateID = TargetFate.ID
    self.LevelSyncState = Value.LevelSyncState
    local FateMainCfg = FateMainCfgTable:FindCfgByKey(self.FateID)
    local FateTargetCfg = FateTargetCfgTable:FindCfgByKey(self.FateID)
    local FateTextCfg = FateTextCfgTable:FindCfgByKey(self.FateID)
    self.bHighRisk = TargetFate.HighRiskState ~= nil and TargetFate.HighRiskState > 0
    self.EndTimeMS = TargetFate.EndTime
    self.bShowPanelFateArchive = true
    if FateMainCfg then
        self.bShowPanelFateArchive = FateMainCfg.IsCelebrateFate == nil or FateMainCfg.IsCelebrateFate <= 0
        local Level = FateMainCfg.Level or 0
        self.Level = string.format(LSTR(10031), Level)
        self.ProgressTitleText = FateMainCfg.ProgressTitle
        self.IconPath = FateDefine.GetIconByFateID(self.FateID)
    end
    if FateTargetCfg then
        if FateTargetCfg.TargetScore ~= nil and FateTargetCfg.TargetScore ~= 0 then
            self.Progress = TargetFate.Progress / FateTargetCfg.TargetScore
        else
            self.Progress = TargetFate.Progress / 100
        end
    end
    if FateTextCfg then
        if (_G.FateMgr.CurrentFate ~= nil) then
            local HighRiskState = _G.FateMgr.CurrentFate.HighRiskState
            if (HighRiskState ~= nil and HighRiskState > 0) then
                local TableData = FateHighRiskCfg:FindCfgByKey(HighRiskState)
                if (TableData ~= nil) then
                    self.TargetName = string.format(LSTR(190138), TableData.ShortTitle, FateTextCfg.NameCh) -- %s·%s 2字词条名字加FATE名字
                    self.HighRiskFateTtitle = string.format(LSTR(190139), TableData.ShortTitle)
                    self.HighRiskFateDesc = TableData.Desc
                    self.TipsIconPath = TableData.TipsIcon
                else
                    self.TargetName = FateTextCfg.NameCh or ""
                    _G.FLOG_ERROR("无法找到高危词条表格数据，ID是：%s", HighRiskState)
                end
            else
                self.TargetName = FateTextCfg.NameCh or ""
            end
        else
            self.TargetName = FateTextCfg.NameCh or ""
        end

        self.Description = FateTextCfg.StoryCh or ""
    else
        _G.FLOG_ERROR("FateTextCfg 为空，请检查")
    end
    self.bIsExpanded = Value.bIsExpanded
end

return FateStageInfoVM
