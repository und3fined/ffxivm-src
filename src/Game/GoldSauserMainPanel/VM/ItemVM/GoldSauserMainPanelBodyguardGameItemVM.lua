---
--- Author: star
--- DateTime: 2024-01-16 10:41
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local BanbooSampleItemVM = require("Game/GoldSauserMainPanel/VM/ItemVM/BanbooSampleItemVM")
local BanbooStageItemVM = require("Game/GoldSauserMainPanel/VM/ItemVM/BanbooStageItemVM")
local LocalizationUtil = require("Utils/LocalizationUtil")
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local GoldSaucerBodyguardGameCfg = require("TableCfg/GoldSaucerBodyguardGameCfg")
local GoldSaucerBodyguardSampleCfg = require("TableCfg/GoldSaucerBodyguardSampleCfg")
local GoldSaucerMinigameCfg = require("TableCfg/GoldSaucerMinigameCfg")
local BodyGuardEnumStage = GoldSauserMainPanelDefine.BodyGuardEnumStage

local FLOG_ERROR = _G.FLOG_ERROR

---@class GoldSauserMainPanelBodyguardGameItemVM : UIViewModel
---@field ID number @条目ID
---@field DescriptionStr string @描述文本
---@field Num number @已完成进度
---@field MaxNum number @需要完成的数量
---@field RightWidgetIndex number @控件选择下标
local GoldSauserMainPanelBodyguardGameItemVM = LuaClass(UIViewModel)

function GoldSauserMainPanelBodyguardGameItemVM:Ctor()
    self.MiniGameType = nil
    self.Level = nil
    self.EntranceItemVM = nil
    --self.RoundIDList = nil -- 本地游戏关卡id列表
    self.RoundIndex = nil -- 总关卡轮数
    self.RememberLimitTimeText = "" -- 记忆限制时间初始文本显示
    self.RememberLimitTime = nil -- 记忆限制时间（秒）
    self.RememberBanbooListVM = UIBindableList.New(BanbooSampleItemVM)
    self.RoundStateListVM = UIBindableList.New(BanbooStageItemVM)
    self.RoundDrawLimitTime = nil -- 每轮绘制限制时间
    self:SetNoCheckValueChange("RoundDrawLimitTime", true)
    self.bCutDrawBtnVisible = false -- 划痕绘制响应按钮是否生效
    self.bRoundSuccess = nil -- 单次是否成功
    self:SetNoCheckValueChange("bRoundSuccess", true)
    self.RoundRltLock = false -- 
    self.CutSampleStageIdx = 1 -- 划痕绘制目标阶段数
    self.CutMarkSignList = nil-- 划痕需要判定标记列表

    self.bShowLongRoundBg = false -- 是否显示长的面板
end

function GoldSauserMainPanelBodyguardGameItemVM:OnInit()
    self.MiniGameType = nil
    self.MiniGameTime = 0
end

function GoldSauserMainPanelBodyguardGameItemVM:SetInfo(Info)
    self.MiniGameType = Info.MiniGameType
    local Level = Info.Level or 1
    self.Level = Level
    self.EntranceItemVM = Info.EntranceItemVM
   --[[local LevelCfgs = GoldSaucerBodyguardGameCfg:FindAllCfg(string.format("Level = %d", Level))
    if LevelCfgs and next(LevelCfgs) then
        local RoundIDList = {} -- 初始化轮次列表
        for _, Cfg in ipairs(LevelCfgs) do
            table.insert(RoundIDList, Cfg.ID)
        end
        self.RoundIDList = RoundIDList
    end--]]

    self.RoundIndex = 1

    self.RememberLimitTimeText = "" -- 记忆限制时间初始文本显示
    self.RememberLimitTime = nil -- 记忆限制时间（秒）
    self.RoundDrawLimitTime = nil -- 每轮绘制限制时间
    self.bCutDrawBtnVisible = false -- 划痕绘制响应按钮是否生效
    self.bRoundSuccess = nil -- 单次是否成功
    self.CutMarkSignList = nil-- 划痕需要判定标记列表
end

function GoldSauserMainPanelBodyguardGameItemVM:SetMiniGameType(InMiniGameType)
    self.MiniGameType = InMiniGameType
end

function GoldSauserMainPanelBodyguardGameItemVM:GetMiniGameType()
    return self.MiniGameType
end

function GoldSauserMainPanelBodyguardGameItemVM:OnReset()

end

function GoldSauserMainPanelBodyguardGameItemVM:OnBegin()

end

function GoldSauserMainPanelBodyguardGameItemVM:OnEnd()

end

function GoldSauserMainPanelBodyguardGameItemVM:OnShutdown()

end

--- 获取当前游戏状态下（关卡等级）的表格数据
function GoldSauserMainPanelBodyguardGameItemVM:GetGameCfg()
    local EntranceItemVM = self.EntranceItemVM
    if not EntranceItemVM then
        return
    end

    return EntranceItemVM:GetRoundTableCfg() -- 统一到EntranceVM里处理，因为还有随机逻辑
end

function GoldSauserMainPanelBodyguardGameItemVM:CreateRemeberBanbooList()
    local RememberBanbooListVM = self.RememberBanbooListVM
    if not RememberBanbooListVM then
        return
    end

    RememberBanbooListVM:Clear()

    local GameCfg = self:GetGameCfg()
    if not GameCfg then
        return
    end
    local TargetSample = GameCfg.TargetSample
    if not TargetSample then
        return
    end

    for Index, SampleIndex in ipairs(TargetSample) do
        if SampleIndex > 0 then
            local ItemVal = {
                Index = SampleIndex,
                ShowIndex = Index         
            }
            RememberBanbooListVM:AddByValue(ItemVal)
        end
    end

    local RememberLimitTime = GameCfg.RememberLimitTime or 1
    self.RememberLimitTimeText = LocalizationUtil.GetCountdownTime(RememberLimitTime, "mm:ss")
end

function GoldSauserMainPanelBodyguardGameItemVM:SetRememberLimitTime()
    local GameCfg = self:GetGameCfg()
    if not GameCfg then
        return
    end

    local RememberLimitTime = GameCfg.RememberLimitTime or 1
    --self.RememberLimitTimeText = LocalizationUtil.GetCountdownTime(RememberLimitTime, "mm:ss")
    self.RememberLimitTime = RememberLimitTime
end

function GoldSauserMainPanelBodyguardGameItemVM:CreateRoundStateList()
    local RoundStateListVM = self.RoundStateListVM
    if not RoundStateListVM then
        return
    end
    
    local RoundCfg = self:GetGameCfg()
    if not RoundCfg then
        return
    end

    local SampleListCfg = RoundCfg.TargetSample
    if not SampleListCfg then
        return
    end

    RoundStateListVM:Clear()
    local ActualIndex = 1
    for _, SampleIndex in ipairs(SampleListCfg) do
        if SampleIndex > 0 then
            RoundStateListVM:AddByValue({
                Index = ActualIndex
            })
            ActualIndex = ActualIndex + 1
        end
    end

    self.bShowLongRoundBg = ActualIndex > 3
    self.CutSampleStageIdx = 1
    self:UpdateRoundStateListStage()
end

function GoldSauserMainPanelBodyguardGameItemVM:UpdateRoundStateListStage()
    local RoundStateListVM = self.RoundStateListVM
    if not RoundStateListVM then
        return
    end
    local CurRoundIdx = self.CutSampleStageIdx or 1
    for Index = 1, RoundStateListVM:Length() do
        local StateItemVM = RoundStateListVM:Get(Index)
        if StateItemVM then
            if StateItemVM.Index == CurRoundIdx then
                StateItemVM:SetState(BodyGuardEnumStage.Running)
            elseif StateItemVM.Index < CurRoundIdx then
                StateItemVM:SetState(BodyGuardEnumStage.Finished)
            elseif StateItemVM.Index > CurRoundIdx then
                StateItemVM:SetState(BodyGuardEnumStage.NotStart)
            end
        end
    end
    self:InitStageSampleCutNum()
end

function GoldSauserMainPanelBodyguardGameItemVM:StartRoundCountDown()
    local RoundDrawLimitTimeCfg = GoldSaucerMinigameCfg:FindCfgByKey(GoldSauserMainPanelDefine.MiniGameEnum.BodyGuardInputTime)
    local LimitValue = RoundDrawLimitTimeCfg.Value[1] or 0
    local LimitTimeSecond = LimitValue / 1000
    self.RoundDrawLimitTime = LimitTimeSecond
    self:ReleaseTheRoundRltLock()
end

function GoldSauserMainPanelBodyguardGameItemVM:InitStageSampleCutNum()
    local SampleID = self:GetCurSampleID()
    if not SampleID then
        return
    end

    local SampleCfg = GoldSaucerBodyguardSampleCfg:FindCfgByKey(SampleID)
    if not SampleCfg then
        return
    end

    local CutMarkAngleList = SampleCfg.CutMarkAngle
    if not CutMarkAngleList or not next(CutMarkAngleList) then
        return
    end
    
    local CutMarkSignList = {}
    for Index, AngleStr in ipairs(CutMarkAngleList) do
        if AngleStr ~= "" then
            CutMarkSignList[Index] = tonumber(AngleStr)
        end
    end
    self.CutMarkSignList = CutMarkSignList
end

function GoldSauserMainPanelBodyguardGameItemVM:TriggerCurRoundSampleAnimWrong()
    local CurSampleID = self:GetCurSampleID()
    local RememberBanbooListVM = self.RememberBanbooListVM
    if not RememberBanbooListVM then
        return
    end
    local TargetSampleVM = RememberBanbooListVM:Find(function(E)
        return E.Index == CurSampleID
    end)
    if TargetSampleVM then
        TargetSampleVM:TriggerWrongAnimPlay()
    end
end

--- 进入下一个轮次
function GoldSauserMainPanelBodyguardGameItemVM:PushToNexRoundStage()
    local OldRoundIdx = self.CutSampleStageIdx or 1
    self.CutSampleStageIdx = OldRoundIdx + 1
    self:UpdateRoundStateListStage()
end

--- 设定单轮结果
function GoldSauserMainPanelBodyguardGameItemVM:SetRoundResult(bSuccess)
    if self.RoundRltLock then
        return
    end
    self.bRoundSuccess = bSuccess
    self.RoundRltLock = true
end

--- 清除结果设定锁
function GoldSauserMainPanelBodyguardGameItemVM:ReleaseTheRoundRltLock()
    self.RoundRltLock = false
end

--- 去除对应的一条划痕
function GoldSauserMainPanelBodyguardGameItemVM:MarkNeedListMinusOne(Idx)
    self.CutMarkSignList[Idx] = nil
end

--- 当前sample是否已经完成切割
function GoldSauserMainPanelBodyguardGameItemVM:IsSampleCutMarkFinished()
    local CutMarkSignList = self.CutMarkSignList
    if not CutMarkSignList then
        FLOG_ERROR("GoldSauserMainPanelBodyguardGameItemVM:IsSampleCutMarkFinished List is invalid")
        return
    end
    if not next(CutMarkSignList) then
        return true
    end
    return false
end

--- 是否当前的Sample全部完成
function GoldSauserMainPanelBodyguardGameItemVM:IsAllSampleFinished()
    local RememberBanbooListVM = self.RememberBanbooListVM
    if not RememberBanbooListVM then
        return false
    end

    local CurIdx = self.CutSampleStageIdx or 1
    return CurIdx >= RememberBanbooListVM:Length()
end

function GoldSauserMainPanelBodyguardGameItemVM:GetCurSampleID()
    local RoundCfg = self:GetGameCfg()
    if not RoundCfg then
        return
    end

    local SampleList = RoundCfg.TargetSample
    if not SampleList or not next(SampleList) then
        return
    end

    local CurRoundIdx = self.CutSampleStageIdx or 1
    return SampleList[CurRoundIdx]
end

return GoldSauserMainPanelBodyguardGameItemVM
