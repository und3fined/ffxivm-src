local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local FateMainCfgTable = require("TableCfg/FateMainCfg")
local FateTargetCfgTable = require("TableCfg/FateTargetCfg")
local FateTextCfgTable = require("TableCfg/FateTextCfg")
local FateDefine = require("Game/Fate/FateDefine")
local NpcCfgTable = require("TableCfg/NpcCfg")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local ColorUtil = require("Utils/ColorUtil")

local LSTR = _G.LSTR

local FateStageMapItemVM = LuaClass(UIViewModel)

function FateStageMapItemVM:Ctor()
    self.FateID = 0
    self.EndTimeMS = 0
    self.Progress = 0
    self.TargetName = ""
    self.TextWaiting = ""
    self.IsDetailVisible = false
    self.IsNPCWaitingVisible = false
    self.IsShowTrack = false
    self.bSameMap = true
end

function FateStageMapItemVM:OnBegin()
end

function FateStageMapItemVM:SetFateID(FateID)
    self.FateID = FateID
end

function FateStageMapItemVM:GetFateID()
    return self.FateID
end

function FateStageMapItemVM:IsEqualVM(Value)
    return self.FateID == Value.FateID
end

function FateStageMapItemVM.CreateVM(Params)
    local VM = FateStageMapItemVM.New()
    VM:UpdateVM(Params)
    return VM
end

function FateStageMapItemVM:UpdateVM(Value)
    if Value == nil then
        return
    end

    self.FateID = Value.MapMarker.ID
    self.EndTimeMS = Value.EndTimeMS
    self.Progress = Value.MapMarker.Progress
    self.TargetName = Value.MapMarker.Name

    local FateMainCfg = FateMainCfgTable:FindCfgByKey(self.FateID)
    local FateTargetCfg = FateTargetCfgTable:FindCfgByKey(self.FateID)
    local FateTextCfg = FateTextCfgTable:FindCfgByKey(self.FateID)
    if FateMainCfg then
        NpcCfgCfg = NpcCfgTable:FindCfgByKey(FateMainCfg.TriggerNPC)
        Level = FateMainCfg.Level
    end
    if FateTargetCfg then
        if FateTargetCfg.TargetScore ~= nil and FateTargetCfg.TargetScore ~= 0 then
            local Progress = (Value.Progress / FateTargetCfg.TargetScore * 100) or 0
            self.TextProgress = string.format(LSTR(190079), math.min(math.floor(Progress), 100))
        else
            local Progress = Value.Progress or 0
            self.TextProgress = string.format(LSTR(190079), math.min(math.floor(Progress), 100))
        end
    end

    local bIsInProgress = Value.State == ProtoCS.FateState.FateState_InProgress
    local bIsEndSubmit = Value.State == ProtoCS.FateState.FateState_EndSubmitItem
    local bIsWaitTrigger = Value.State == ProtoCS.FateState.FateState_WaitNPCTrigger
    local TargetFate = _G.FateMgr:GetActiveFate(self.FateID)
    local bIsFateExist = TargetFate ~= nil and TargetFate.State ~= ProtoCS.FateState.FateState_Finished
    if (bIsFateExist) then
        self.IsShowTrack = true
        if (bIsWaitTrigger) then
            self.IsNPCWaitingVisible = true
            self.IsDetailVisible = false
            self.TextWaiting = LSTR(190081)
        else
            local bShowDetail = bIsInProgress or bIsEndSubmit
            if (bShowDetail) then
                self.IsDetailVisible = true
                self.IsNPCWaitingVisible = false
            else
                self.IsDetailVisible = false
                self.IsNPCWaitingVisible = false
            end
        end
    else
        -- 这里先判断一下，看这个FATE是不是在当前的地图
        -- 如果不是当前地图，那么显示的提示修改一下
        local _, Fate2MapTable = _G.FateMgr:GatherMapFateStageInfo()
        local FateMapID = Fate2MapTable[self.FateID]
        local CurMapID = PWorldMgr:GetCurrMapResID()
        local bIsSameMap = FateMapID == CurMapID
        self.IsDetailVisible = false
        self.IsNPCWaitingVisible = true
        self.IsShowTrack = false

        if (bIsSameMap) then
            self.bSameMap = true
            self.TextWaiting = LSTR(190081)
        else
            self.bSameMap = false
            self.TextWaiting = LSTR(190082)
        end
    end
end

return FateStageMapItemVM
