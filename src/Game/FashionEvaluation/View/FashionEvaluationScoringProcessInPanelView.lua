---
--- Author: Administrator
--- DateTime: 2024-02-20 16:53
--- Description:评分过程界面
---

local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")
local LuaClass = require("Core/LuaClass")
local FMath = _G.UE.UMathUtil
local AudioUtil = require("Utils/AudioUtil")
local FashionEvaluationVM = require("Game/FashionEvaluation/VM/FashionEvaluationVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local FashionEvaluationMgr = require("Game/FashionEvaluation/FashionEvaluationMgr")
local FashionEvaluationDefine = require("Game/FashionEvaluation/FashionEvaluationDefine")
local FashionEvaluationVMUtils = require("Game/FashionEvaluation/FashionEvaluationVMUtils")
local DurationStage1 = 2.0
local DurationStage2 = 1.5
local LSTR = _G.LSTR
---@class FashionEvaluationScoringProcessInPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelProgress UFCanvasPanel
---@field ProgressBarFull UProgressBar
---@field ProgressScore FashionEvaluationProgressScoreItemView
---@field ScoreTips FashionEvaluationScoreTipsView
---@field TableViewInfo UTableView
---@field TextHint UFTextBlock
---@field AnimIn_1 UWidgetAnimation
---@field AnimIn_2 UWidgetAnimation
---@field AnimIn_3 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionEvaluationScoringProcessInPanelView = LuaClass(UIView, true)

function FashionEvaluationScoringProcessInPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelProgress = nil
	--self.ProgressBarFull = nil
	--self.ProgressScore = nil
	--self.ScoreTips = nil
	--self.TableViewInfo = nil
	--self.TextHint = nil
	--self.AnimIn_1 = nil
	--self.AnimIn_2 = nil
	--self.AnimIn_3 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionEvaluationScoringProcessInPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ProgressScore)
	self:AddSubView(self.ScoreTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionEvaluationScoringProcessInPanelView:OnInit()
	self.CommentAdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewInfo, self.OnThemePartSelected, true, false)
	self.Binders = {
		{"CommentVMList", UIBinderUpdateBindableList.New(self, self.CommentAdapterTableView)},
		{"CurScore", UIBinderSetText.New(self, self.ProgressScore.TextQuantity)},
	}

	self.ScoreEffectAnimList = {
		[1] = self.AnimIn_1,
		[2] = self.AnimIn_2,
		[3] = self.AnimIn_3,
	}
	
	self.IsEndEvaluation = false
	self.EffectDuration = 3.77 --氛围动效表演时间
	self.PerformSpeed = 1 -- 打分进度条速度

	self.ScoreDuration = DurationStage1  --分数从0到最终分数的表演时间
	self.EvaluationAnimIndex = 1 --评分动作索引
	self.ScoreStage1 = 0 -- 阶段一进度条表现分数
	self.ScoreStage2 = 0 -- 阶段二进度条表现分数
	self.OwnScore = 0
	self.MatchNum = 0
	self.OwnNum = 0
end

function FashionEvaluationScoringProcessInPanelView:OnDestroy()

end

function FashionEvaluationScoringProcessInPanelView:OnShow()
	if self.TextHint then
		--self.TextHint:SetText(_G.LSTR(1120047))--1120047("动画制作中，敬请期待")
		UIUtil.SetIsVisible(self.TextHint, false)
	end
	UIUtil.SetIsVisible(self.ProgressScore, false)
	UIUtil.SetIsVisible(self.ScoreTips, false)

	FashionEvaluationMgr:UpdateComment()
	self:OnFashionEvaluationStart()
end

function FashionEvaluationScoringProcessInPanelView:OnHide()

end

function FashionEvaluationScoringProcessInPanelView:OnRegisterUIEvent()

end

function FashionEvaluationScoringProcessInPanelView:OnRegisterGameEvent()

end

function FashionEvaluationScoringProcessInPanelView:OnRegisterBinder()
	self:RegisterBinders(FashionEvaluationVM, self.Binders)
end

function FashionEvaluationScoringProcessInPanelView:OnFashionEvaluationStart()
	self.CurScore = FashionEvaluationVM.CurScore
	local PerformInfo = FashionEvaluationVMUtils.GetScorePerformInfo(self.CurScore)
	if PerformInfo then
		self.PerformSpeed = PerformInfo.ScoreEffectSpeedScale
		DurationStage1 = PerformInfo.ScoreDurationStageOne
		DurationStage2 = PerformInfo.ScoreDurationStageTwo
	end
	self.IsEndEvaluation = false
	self.EvaluationAnimIndex = 1
	self.ScoreDuration = DurationStage1
	self.ScoreLevel = FashionEvaluationVMUtils.GetScoreLevelForAnim(self.CurScore)
	local ScoreInfo = FashionEvaluationVM:GetScoreInfo()
	if ScoreInfo then
		self.ScoreStage1 = ScoreInfo.BaseScore + ScoreInfo.MatchScore + ScoreInfo.SuperMatchScore -- 阶段一进度条表现分数
		self.ScoreStage2 = self.CurScore -- 阶段二进度条表现分数
		self.OwnScore = ScoreInfo.OwnScore or 0
		self.MatchNum = ScoreInfo.MatchNum + ScoreInfo.SuperMatchNum
		self.OwnNum = ScoreInfo.OwnNum
	end
	self.StartPerformScore = 0
	self.StageCount = 0
	self:UpdateScoreEffect(self.CurScore)
	self:OnPlayEvaluationAnim()
end

---@type 分数条运动
function FashionEvaluationScoringProcessInPanelView:UpdateScoreBarPerform(Score)
	self.EndTime = self.EndTime - 0.05 
	self.PerformPercent = self.PerformPercent + 0.05 * self.Forward * self.PerformSpeed
	if self.PerformPercent > 1 then
		self.Forward = -1
	elseif self.PerformPercent < 0 then
		self.Forward = 1
	end

	if self.EndTime <= 0 then
		if self.ProgressTimer then
			self:UnRegisterTimer(self.ProgressTimer)
		end
		self:OnEvaluateProgressEnd(self.ScoreStage1)
	end

	self.ProgressBarFull:SetPercent(self.PerformPercent)
end

---@type 评分氛围动效
function FashionEvaluationScoringProcessInPanelView:UpdateScoreEffect(Score)
	if self.ScoreEffectAnimList == nil then
		return
	end

	local Level = FashionEvaluationVMUtils.GetScoreLevelForUIType(Score)
	if self.EffectAnim then
		self:PlayAnimationTimeRange(self.EffectAnim, 0.0, 0.01, 1, nil, 1.0, false)
	end

	self.EffectAnim = self.ScoreEffectAnimList[Level]

	if self.EffectAnim then
		self:PlayAnimation(self.EffectAnim)
	end
	
	self.EndTime = self.EffectDuration -- 为了和氛围动效中的分数弹出动效配合，需要提前结束分数条运动，用于播放分数过渡动效
	self.PerformPercent = 0
	self.Forward = 1
	if self.ProgressTimer then
		self:UnRegisterTimer(self.ProgressTimer)
	end
	self.ProgressTimer = self:RegisterTimer(self.UpdateScoreBarPerform, 0, 0.05, 0, Score)
end

---@type 评分过程结束
function FashionEvaluationScoringProcessInPanelView:OnEvaluateProgressEnd(Score)
	local EndTime = self.ProgressScore:PlayAnimationByScoreLevel(self.ScoreLevel)
	local Rate = 0
	local ActualScore = 0
	local TargetScore = Score
	self:UpdateScoreTipsWidget(true)
	--从表现百分位置到实际分位值
	local function SetActualPercent()
		Rate = Rate + 0.05
		ActualScore = FMath.Lerp(self.StartPerformScore, TargetScore, Rate/self.ScoreDuration)
		self.ProgressBarFull:SetPercent(ActualScore/100.0)
		AudioUtil.LoadAndPlayUISound(FashionEvaluationDefine.AudioPath.ScoreUP)
		if Rate >= self.ScoreDuration then
			self.StageCount = self.StageCount + 1
			Rate = 0
			if self.StageCount < 2 then
				TargetScore = self.ScoreStage2
				self.ScoreDuration = DurationStage2
				self.StartPerformScore = self.ScoreStage1
				self:UpdateScoreTipsWidget(false)
			else
				self.IsEndEvaluation = true
				UIUtil.SetIsVisible(self.ProgressScore, true)
				UIUtil.SetIsVisible(self.ScoreTips, false)
				--延迟N秒后正式结束打分进度表现，进入下一个流程
				local function EnterResult()
					-- FashionEvaluationMgr:OnEvaluateEnd()
					-- self:Hide()
				end
				self:RegisterTimer(EnterResult, EndTime + 1)
				if self.ScoreTimer then
					self:UnRegisterTimer(self.ScoreTimer)
					self.ScoreTimer = nil
				end
			end
		end
	end

	self.ScoreTimer = self:RegisterTimer(SetActualPercent, 0, 0.05,0)
end

---@type 设置分数提示
function FashionEvaluationScoringProcessInPanelView:UpdateScoreTipsWidget(IsFirstStage)
	if self.ScoreTips then
		UIUtil.SetIsVisible(self.ScoreTips, true)

		local PanelProgressSize = UIUtil.GetWidgetSize(self.PanelProgress)
		local ProBarSize = UIUtil.GetWidgetSize(self.ProgressBarFull)
		local Percent = IsFirstStage and (self.ScoreStage1 / 2) / 100 or (self.ScoreStage1 + (self.OwnScore / 2)) / 100
		local PanelProgressPosition = UIUtil.CanvasSlotGetPosition(self.PanelProgress)
		local ScoreTipsPosition = UIUtil.CanvasSlotGetPosition(self.ScoreTips)
		local StartPosY = PanelProgressPosition.Y + PanelProgressSize.Y/2 - 23 -- 往上移23，适配进度条底部位置
		local NewPosition = UE.FVector2D(ScoreTipsPosition.X, StartPosY - (Percent * ProBarSize.Y))
		UIUtil.CanvasSlotSetPosition(self.ScoreTips, NewPosition)

		local MatchContent = string.format(LSTR(FashionEvaluationDefine.MatchThemeUKey), self.MatchNum)
		local OwnContent = string.format(LSTR(FashionEvaluationDefine.OwnAppearanceUKey), self.OwnNum)
		local Content = IsFirstStage and MatchContent or OwnContent
		local Score = IsFirstStage and self.ScoreStage1 or self.OwnScore
		self.ScoreTips:UpdateScoreDetail(Content, Score, IsFirstStage)
	end
end

---@type 评分过程动作
function FashionEvaluationScoringProcessInPanelView:OnPlayEvaluationAnim()
	if self.IsEndEvaluation then
		return
	end
	local AnimList = FashionEvaluationDefine.EvaluationAnim
	if AnimList == nil then
		return
	end
	local Anim = AnimList[self.EvaluationAnimIndex]
	if Anim == nil then
		return
	end
	local TimelineID = Anim.TimelineID
	local Delay = Anim.Delay
	local AnimDuration = FashionEvaluationMgr:PlayMajorAnimByTimeline(TimelineID, true)
	self:RegisterTimer(self.OnPlayEvaluationAnim, Delay + AnimDuration, 0, 1)
	self.EvaluationAnimIndex = self.EvaluationAnimIndex + 1
end

return FashionEvaluationScoringProcessInPanelView