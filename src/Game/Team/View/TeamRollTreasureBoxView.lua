
local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local LuaClass = require("Core/LuaClass")
local UIViewMgr = require("UI/UIViewMgr")
local EventMgr = require("Event/EventMgr")
local UIViewID = require("Define/UIViewID")
local RollMgr = require("Game/Roll/RollMgr")
local TeamRollItemVM = require("Game/Team/VM/TeamRollItemVM")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local DataReportUtil = require("Utils/DataReportUtil")
local ReportButtonType = require("Define/ReportButtonType")
local AudioUtil = require("Utils/AudioUtil")
local MainPanelVM = require("Game/Main/MainPanelVM")

local SoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/New/Play_FM_Dice.Play_FM_Dice'"

---@class TeamRollTreasureBoxView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBox UFButton
---@field BtnCloss UFButton
---@field BtnNeed UFButton
---@field ImgBox UFImage
---@field ImgNeed UFImage
---@field PanelBtnRandom UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field PanelTreasureBox UFCanvasPanel
---@field TextAll UFTextBlock
---@field TextCountDown UFTextBlock
---@field AnimBoxEFFIn UWidgetAnimation
---@field AnimBoxEFFOut UWidgetAnimation
---@field AnimBoxUpEFFIn UWidgetAnimation
---@field AnimBoxUpEFFOut UWidgetAnimation
---@field AnimBtnRollLoop UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimMiniMapIn UWidgetAnimation
---@field AnimMiniMapOut UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimPanelTipsIn UWidgetAnimation
---@field AnimPanelTipsOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamRollTreasureBoxView = LuaClass(UIView, true)

function TeamRollTreasureBoxView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBox = nil
	--self.BtnCloss = nil
	--self.BtnNeed = nil
	--self.ImgBox = nil
	--self.ImgNeed = nil
	--self.PanelBtnRandom = nil
	--self.PanelTips = nil
	--self.PanelTreasureBox = nil
	--self.TextAll = nil
	--self.TextCountDown = nil
	--self.AnimBoxEFFIn = nil
	--self.AnimBoxEFFOut = nil
	--self.AnimBoxUpEFFIn = nil
	--self.AnimBoxUpEFFOut = nil
	--self.AnimBtnRollLoop = nil
	--self.AnimIn = nil
	--self.AnimMiniMapIn = nil
	--self.AnimMiniMapOut = nil
	--self.AnimOut = nil
	--self.AnimPanelTipsIn = nil
	--self.AnimPanelTipsOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamRollTreasureBoxView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamRollTreasureBoxView:OnInit()
end

function TeamRollTreasureBoxView:OnDestroy()

end

function TeamRollTreasureBoxView:OnShow()
	self.TextAll:SetText(LSTR(480004))
	--UIUtil.CanvasSlotSetPosition(self.PanelTreasureBox, _G.UE.FVector2D(-352, 300))
	-- self:OnPlayBoxEFFAnimation(true)
	-- self:OnShowRollTipsIsShow(TeamRollItemVM.IsAllOperated)
	if not RollMgr:HasAssignedReward() or UIViewMgr:IsViewVisible(UIViewID.TeamRollValuablesTips) then
		UIUtil.SetIsVisible(self.PanelTips, false)
		print("队伍分配  PanelTips 11  false")
	end
end

function TeamRollTreasureBoxView:OnHide()
end

function TeamRollTreasureBoxView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBox, self.OnTreasureBtnClick)
	UIUtil.AddOnClickedEvent(self, self.BtnCloss, self.OnClickBtnAllGiveUp)
	UIUtil.AddOnClickedEvent(self, self.BtnNeed, self.OnClickBtnAllRandom)
end

function TeamRollTreasureBoxView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.TeamRollBoxEFFEvent, self.OnPlayBoxEFFAnimation)
	self:RegisterGameEvent(EventID.TeamRollItemViewShowStatus, 	self.OnTeamRollItemViewShowStatus)
	self:RegisterGameEvent(EventID.TeamRollBoxTipsVisibleEvent, 	self.OnPlayPanelTipsAnimation)
	self:RegisterGameEvent(EventID.TeamRollEndEvent, function()
		UIUtil.SetIsVisible(self.TextCountDown, false)
		self:OnPlayBoxEFFAnimation({IsIn = false})
	end)
end

--- 点击宝箱按钮打开roll点分配界面
function TeamRollTreasureBoxView:OnTreasureBtnClick()
	if not UIViewMgr:IsViewVisible(UIViewID.TeamRollPanel) then
		RollMgr.IsPopWindow = false
		RollMgr.TeamPanelVisible = true
        UIViewMgr:ShowView(UIViewID.TeamRollPanel)
    end
end

function TeamRollTreasureBoxView:OnTeamRollItemViewShowStatus(IsOpen)
	if not IsOpen and not RollMgr:HasAssignedReward() then
		UIUtil.SetIsVisible(self.PanelTips, false)
		print("队伍分配  PanelTips 222  false")
	elseif IsOpen then
		UIUtil.SetIsVisible(self.PanelTips, false)
		print("队伍分配  PanelTips 333  false")
	else
		if not TeamRollItemVM.IsAllOperated and RollMgr.IsPopWindow then
			UIUtil.SetIsVisible(self.PanelTips, true)
			print("队伍分配  PanelTips  11 true")
		end
	end
end

function TeamRollTreasureBoxView:OnPlayBoxEFFAnimation(Params)
	local IsIn = Params.IsIn
	local IsHaveHighValue = Params.IsHaveHighValue
	UIUtil.SetIsVisible(self.ImgNeed, not IsIn)
	UIUtil.SetIsVisible(self.PanelBtnRandom, IsIn)
	if IsIn then
		self:PlayAnimation(IsHaveHighValue and self.AnimBoxUpEFFIn or self.AnimBoxEFFIn, 0, 1)
		self:PlayAnimation(self.AnimBtnRollLoop, 0, 0)
	else
		self:PlayAnimation(self.AnimBoxEFFOut, 0, 1)
		self:PlayAnimation(self.AnimBoxUpEFFOut, 0, 1)
	end
end

function TeamRollTreasureBoxView:OnPlayPanelTipsAnimation(IsIn)
	print("队伍分配  IsIn == ", IsIn)
	if IsIn then
		UIUtil.SetIsVisible(self.PanelTips, true)
		self:PlayAnimation(self.AnimPanelTipsIn, 0, 1)
	else
		UIUtil.SetIsVisible(self.PanelTips, false)
		self:PlayAnimation(self.AnimPanelTipsOut,0, 1)
	end
end

function TeamRollTreasureBoxView:OnRegisterBinder()
	local MultiBinders = {
		{
			ViewModel = TeamRollItemVM,
			Binders = {
				{"CurrentCountDownNum", UIBinderValueChangedCallback.New(self, nil, self.OnCurrentValueChanged)},
				{"IsAllOperated", UIBinderValueChangedCallback.New(self, nil, self.UpdateRollTipsIsShow)}
			}
		},
		{
			ViewModel = MainPanelVM,
			Binders = {
				{"MiniMapPanelVisible", UIBinderValueChangedCallback.New(self, nil, self.OnMiniMapPanelVisibleChanged)},
			}
		},
	}
	self:RegisterMultiBinders(MultiBinders)

end

-- 宝箱倒计时
function TeamRollTreasureBoxView:OnCurrentValueChanged(NewValue)
	local CurrentCountDownNum = NewValue
	if CurrentCountDownNum == nil or tonumber(CurrentCountDownNum) <= 0.1 then
		if RollMgr.IsTreasureHuntRoll then
			self:Hide()
		else
			UIUtil.SetIsVisible(self.TextCountDown, false)
		end
		return
	end
	if not UIUtil.IsVisible(self.TextCountDown) and not TeamRollItemVM.IsAllOperated then
		UIUtil.SetIsVisible(self.TextCountDown, true)
	end
	self.TextCountDown:SetText(_G.LocalizationUtil.GetCountdownTimeForShortTime(math.floor(CurrentCountDownNum), "mm:ss") or 0)
end

function TeamRollTreasureBoxView:OnShowRollTipsIsShow(NewValue)
	if not UIViewMgr:IsViewVisible(UIViewID.TeamRollPanel) and not UIViewMgr:IsViewVisible(UIViewID.TeamRollValuablesTips) then
		self:OnPlayPanelTipsAnimation(not NewValue)
	end
	-- UIUtil.SetIsVisible(self.PanelTips, not NewValue)
	if NewValue and RollMgr:HasAssignedReward() then
		UIUtil.SetIsVisible(self.TextCountDown, true)
	else
		UIUtil.SetIsVisible(self.TextCountDown, not NewValue)
	end
end

function TeamRollTreasureBoxView:OnMiniMapPanelVisibleChanged(NewValue)
	if NewValue then
		self:PlayAnimation(self.AnimMiniMapIn)
	else
		self:PlayAnimation(self.AnimMiniMapOut)
	end
end

function TeamRollTreasureBoxView:UpdateRollTipsIsShow(NewValue)
	if NewValue then
		self:PlayAnimation(self.AnimBoxEFFOut, 0, 1)
		self:PlayAnimation(self.AnimBoxUpEFFOut, 0, 1)
	end

	self:OnShowRollTipsIsShow(NewValue)
	
    if RollMgr.IsTreasureHuntRoll then 
		UIUtil.SetIsVisible(self.TextCountDown, false)
	end
end

function TeamRollTreasureBoxView:OnClickBtnAllGiveUp()
	--全部放弃
	DataReportUtil.ReportButtonClickData(tostring(ReportButtonType.TeamRollTreasureBox), "0")
	EventMgr:SendEvent(EventID.TeamRollAllGiveUp)
end

function TeamRollTreasureBoxView:OnClickBtnAllRandom()
	--全部需求
	AudioUtil.LoadAndPlayUISound(SoundPath)
	FLOG_INFO("TeamRoll PlayUISound Box  Path ==  " .. SoundPath)
	DataReportUtil.ReportButtonClickData(tostring(ReportButtonType.TeamRollTreasureBox), "1")
	EventMgr:SendEvent(EventID.TeamRollAllRandom)
end
return TeamRollTreasureBoxView