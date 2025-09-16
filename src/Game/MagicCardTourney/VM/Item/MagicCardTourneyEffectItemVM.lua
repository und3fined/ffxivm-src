--
-- Author: Carl
-- Date: 2023-11-08 16:57:14
-- Description:幻卡大赛效果ItemVM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local ProtoRes = require("Protocol/ProtoRes")
local MagicCardTourneyDefine = require("Game/MagicCardTourney/MagicCardTourneyDefine")
local TourneyVMUtils = require("Game/MagicCardTourney/MagicCardTourneyVMUtils")

---@class MagicCardTourneyEffectItemVM : UIViewModel
---@field EffectID string @效果ID
---@field EffectTitle string @效果名称
---@field EffectInstruction string @效果介绍
---@field IsGetEffect boolean @是否达成效果
---@field CurEffectProgress number @当前效果进度
---@field ProgressText string @当前进度文本
---@field EffectGoal number @效果达成目标
---@field IsEffectStart boolean @是否开启阶段效果
---@field ResultText string @结果
---@field IsCurStageIndex boolean @是否当前阶段
---
local MagicCardTourneyEffectItemVM = LuaClass(UIViewModel)

function MagicCardTourneyEffectItemVM:Ctor()
    self.EffectID = ""
    --self.CurEffectProgress = 0
    self.EffectGoal = 0
    self.EffectTitle = ""
    self.EffectInstruction = ""
    self.ResultText = ""
    self.ProgressText = ""
    self.IsEffectStart = false
    self.IsCurStageIndex = false
    self.StageIndex = 1
    self.Reroll = 0
    self.RerollEnabled = true
    self.EffectIndex = -1
    self.RiskLevelBGPath = ""
    self.EffectIconPath = ""
    -- self.EffectProgressText = MagicCardTourneyDefine.EffectOngoingText
end

function MagicCardTourneyEffectItemVM:IsEqualVM(Value)
	return Value.EffectInfo and Value.EffectInfo.EffectIndex == self.EffectIndex
end

function MagicCardTourneyEffectItemVM:GetKey(Value)
	return self.EffectIndex
end

function MagicCardTourneyEffectItemVM:UpdateVM(Data)
    if Data == nil then
        return
    end

    self.StageIndex = Data.StageIndex
    local EffectInfo = Data.EffectInfo
    if EffectInfo then
        self.IsEffectStart = true
        self.EffectIndex = EffectInfo.EffectIndex
        self.EffectID = EffectInfo.EffectID
        local ViewIndex = self.EffectIndex and self.EffectIndex + 1 or 0
        self.RiskLevelBGPath = MagicCardTourneyDefine.RiskLevelBGPath[ViewIndex]
        self.Reroll = EffectInfo.Reroll
        self.RerollEnabled = self.Reroll and self.Reroll > 0
        local EffectCfg = TourneyVMUtils.GetEffectInfoByEffectID(self.EffectID)
        if EffectCfg == nil then
            return
        end

        self.EffectIconPath = EffectCfg.IconPath
        self.EffectTitle = EffectCfg.EffectName or ""
        self.EffectGoal = EffectCfg.Arg
        self.EffectInstruction = EffectCfg.Desc or ""
        self.CurEffectProgress = EffectInfo.Progress
        self.CurStageIndex = EffectInfo.CurStage

        if self.CurStageIndex and self.StageIndex then
            local IsTourneyEnd = _G.MagicCardTourneyMgr:IsFinishedTourney()
            self.IsLastStage = self.CurStageIndex > self.StageIndex or EffectInfo.IsEffectEnd or IsTourneyEnd
        end
     
        self.ScoreChange = EffectInfo.ScoreChange
        if self.ScoreChange then
            if self.ScoreChange >= 0 then
                self.ResultText = string.format(MagicCardTourneyDefine.ScoreAddText, self.ScoreChange)
            else
                self.ResultText = string.format(MagicCardTourneyDefine.ScoreText, self.ScoreChange)
            end
        end
        
        if TourneyVMUtils.IsNeedShowEfectProgress(self.EffectID) then
            if self.CurEffectProgress and self.EffectGoal ~= 0 then
                if self.CurEffectProgress < self.EffectGoal then
                    self.ProgressText = string.format("(%d/%d)", self.CurEffectProgress, self.EffectGoal)
                else
                    self.ProgressText = self.ResultText -- 阶段效果提前完成，直接显示阶段积分
                end
            end
        else
            local EffectType = EffectCfg.Type
            local BattleFlipType = ProtoRes.Game.fantasy_tournament_effect_type.FANTASY_TOURNAMENT_EFFECT_TYPE_BATTLE_FLIP
            if EffectType == BattleFlipType then
                self.ProgressText = self.ResultText  -- 单局翻牌特殊，直接显示累计积分
            else
                self.ProgressText = MagicCardTourneyDefine.EffectOngoingText
            end
        end
    else -- 未开始阶段
        self.IsEffectStart = false
        self.IsLastStage = false
        self.RiskLevelBGPath = MagicCardTourneyDefine.RiskLevelBGPath[0]
    end

    
end

return MagicCardTourneyEffectItemVM