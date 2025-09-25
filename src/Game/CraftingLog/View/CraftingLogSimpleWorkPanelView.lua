---
--- Author: v_vvxinchen
--- DateTime: 2024-07-03 12:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local SimpleVM = require("Game/CraftingLog/CraftingLogSimpleCraftWinVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local CraftingLogMgr = require("Game/CraftingLog/CraftingLogMgr")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local CraftingLogDefine = require("Game/CraftingLog/CraftingLogDefine")
local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")
local SCORE_TYPE = ProtoRes.SCORE_TYPE

---@class CraftingLogSimpleWorkPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose1 CommonCloseBtnView
---@field BtnFinish UFButton
---@field BtnStop UFButton
---@field CrafterTitleItem CrafterTitleItemView
---@field EFF_1 UFCanvasPanel
---@field HorizontalCost UFCanvasPanel
---@field ImgCoin UFImage
---@field MoneySlot CommMoneySlotView
---@field ProBar UProgressBar
---@field SlotItem CommBackpack96SlotView
---@field TextAmount UFTextBlock
---@field TextBtnL UFTextBlock
---@field TextBtnR UFTextBlock
---@field TextCost UFTextBlock
---@field TextName UFTextBlock
---@field TextQuantity UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimProgress UWidgetAnimation
---@field AnimProgressEvent UWidgetAnimation
---@field ValueProgressStart float
---@field ValueProgressEnd float
---@field CurveProgress CurveFloat
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CraftingLogSimpleWorkPanelView = LuaClass(UIView, true)

function CraftingLogSimpleWorkPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose1 = nil
	--self.BtnFinish = nil
	--self.BtnStop = nil
	--self.CrafterTitleItem = nil
	--self.EFF_1 = nil
	--self.HorizontalCost = nil
	--self.ImgCoin = nil
	--self.MoneySlot = nil
	--self.ProBar = nil
	--self.SlotItem = nil
	--self.TextAmount = nil
	--self.TextBtnL = nil
	--self.TextBtnR = nil
	--self.TextCost = nil
	--self.TextName = nil
	--self.TextQuantity = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimProgress = nil
	--self.AnimProgressEvent = nil
	--self.ValueProgressStart = nil
	--self.ValueProgressEnd = nil
	--self.CurveProgress = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CraftingLogSimpleWorkPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose1)
	self:AddSubView(self.CrafterTitleItem)
	self:AddSubView(self.MoneySlot)
	self:AddSubView(self.SlotItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

local ProfIconPath = {
	[28] = "Texture2D'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Second_DTJ.UI_Icon_Job_Second_DTJ'",
	[29] = "Texture2D'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Second_DuanJiaJiang.UI_Icon_Job_Second_DuanJiaJiang'",
	[30] = "Texture2D'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Second_KMG.UI_Icon_Job_Second_KMG'",
	[31] = "Texture2D'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Second_DiaoJinJiang.UI_Icon_Job_Second_DiaoJinJiang'",
	[32] = "Texture2D'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Second_ZYJ.UI_Icon_Job_Second_ZYJ'",
	[33] = "Texture2D'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Second_ZGJ.UI_Icon_Job_Second_ZGJ'",
	[34] = "Texture2D'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Second_LJSS.UI_Icon_Job_Second_LJSS'",
	[35] = "Texture2D'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Second_PTS.UI_Icon_Job_Second_PTS'",
}

function CraftingLogSimpleWorkPanelView:OnInit()
end

function CraftingLogSimpleWorkPanelView:OnDestroy()
end

function CraftingLogSimpleWorkPanelView:OnShow()
	if _G.CraftingLogMgr.NowPropData.FastCraft == 1 then
		self.CrafterTitleItem:SetTitle(_G.LSTR(80072)) --快速制作80072
	else
		self.CrafterTitleItem:SetTitle(_G.LSTR(80053)) --简易制作
	end
	self.TextQuantity:SetText(_G.LSTR(80055)) --制作数量
	self.TextBtnL:SetText(_G.LSTR(80056)) --停止制作
	self.TextBtnR:SetText(_G.LSTR(80057)) --立即完成
	
	local Params = self.Params
	local bIsReconnect = Params and Params.bIsReconnect or false
	self:InitPanel(bIsReconnect)
	self:StartMake()
	
	--关闭摇杆显示
	CommonUtil.DisableShowJoyStick(true)
	CommonUtil.HideJoyStick()
	self.CloseViewTimer = nil
end

function CraftingLogSimpleWorkPanelView:InitPanel(bIsReconnect)
	local ToMakeCount = _G.CrafterMgr.ReqMakeNum
	FLOG_INFO("Crafter OnShow-SimpleMake Counts:%d", ToMakeCount)
	local Data = CraftingLogMgr.NowPropData
	SimpleVM:OnShow(Data, ToMakeCount, bIsReconnect)
	self.ProBar:SetPercent(SimpleVM:GetProgress())
	--如果断线前立即完成的回包未收到，StartMake()中ToMake()重新执行立即完成
	if SimpleVM.IsClickRightAway and bIsReconnect then
		self.IsClickRightAwayMake = true
	end

	local TotalMakeCount = SimpleVM.TotalMakeCount
    if TotalMakeCount and TotalMakeCount < CraftingLogDefine.SimpleCraftMinTotalCount then
        self.BtnFinish:SetIsEnabled(false,false)
		UIUtil.SetIsVisible(self.HorizontalCost,false)
	else
		UIUtil.SetIsVisible(self.HorizontalCost,true)
		if _G.CraftingLogMgr.ScoreNotEnough then
			self.BtnFinish:SetIsEnabled(false,false)
		else
			self.BtnFinish:SetIsEnabled(true,true)
		end
	end
	self.BtnStop:SetIsEnabled(true,true)
	UIUtil.SetIsVisible(self.SlotItem.RichTextLevel, false)
	UIUtil.SetIsVisible(self.SlotItem.IconChoose, false)
	UIUtil.SetIsVisible(self.SlotItem.RichTextQuantity, false)
	UIUtil.SetIsVisible(self.EFF_1,false)
	local ProfID = MajorUtil.GetMajorProfID()
	UIUtil.ImageSetBrushFromAssetPath(self.IconProf, ProfIconPath[ProfID])
	self.MoneySlot:UpdateView(SCORE_TYPE.SCORE_TYPE_GOLD_CODE, false, nil, true)
end

function CraftingLogSimpleWorkPanelView:StartMake()
	SimpleVM.IsClickCloseBtn = false

	--需要延迟一点时间，以确保进入制作状态的表现完成
    local function EnterAnimFinish()
        self:ToMake()
		self.DelayMakeTimerID = nil
    end
    self.DelayMakeTimerID = self:RegisterTimer(EnterAnimFinish, _G.CrafterMgr.EnterStateTime, 1, 1)
end

function CraftingLogSimpleWorkPanelView:OnHide()
	--恢复摇杆显示
	CommonUtil.DisableShowJoyStick(false)
	CommonUtil.ShowJoyStick()
end

function CraftingLogSimpleWorkPanelView:OnRegisterBinder()
	self.Binders = {
		{"SlotItemImg", UIBinderSetBrushFromAssetPath.New(self, self.SlotItem.Icon)},
		{"ItemQualityImg", UIBinderSetBrushFromAssetPath.New(self, self.SlotItem.ImgQuanlity)},
		{"TextNameLabel", UIBinderSetText.New(self, self.TextName)},
		{"TextAmountLabel", UIBinderSetText.New(self, self.TextAmount)},
		{"TextCostLabel", UIBinderSetText.New(self, self.TextCost)},
		{"CostScoreColor", UIBinderSetColorAndOpacityHex.New(self, self.TextCost)},
		{"ProgressValue", UIBinderSetPercent.New(self, self.ProBar) },
	}

	self:RegisterBinders(SimpleVM, self.Binders)
end

function CraftingLogSimpleWorkPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnFinish, self.OnFinishBtnClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnStop, self.OnCloseBtnOnClicked)
	self.BtnClose1:SetCallback(self,self.OnCloseBtnOnClicked)
end

function CraftingLogSimpleWorkPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.CraftingSimpleRefreshUI, self.RefreshUI)
	self:RegisterGameEvent(_G.EventID.CraftingSimpleToMake, self.ToMake)
	self:RegisterGameEvent(_G.EventID.CraftingSimpleFinished, self.OnMakeFinished)
end

function CraftingLogSimpleWorkPanelView:RefreshUI()
	SimpleVM:Update()
	self.ProBar:SetPercent(SimpleVM:GetProgress())

	--制作完成或者结束了
	if SimpleVM:GetProgress() == 1 then
		self.BtnFinish:SetIsEnabled(false,false)
		UIUtil.SetIsVisible(self.HorizontalCost,false)
		SimpleVM:QuitSimpleMake()
	else
		--正在制作ing
		--立即完成按钮：先判断制作总数，在判断金币
		if SimpleVM.TotalMakeCount < CraftingLogDefine.SimpleCraftMinTotalCount then
			UIUtil.SetIsVisible(self.HorizontalCost,false)
		else
			if _G.CraftingLogMgr.ScoreNotEnough or self.IsClickRightAwayMake == true or SimpleVM.IsClickCloseBtn == true then
				self.BtnFinish:SetIsEnabled(false,false)
			else
				self.BtnFinish:SetIsEnabled(true,true)
			end
		end
		--作业中止按钮：只判断是否点击过
		if self.IsClickRightAwayMake == true or SimpleVM.IsClickCloseBtn == true then
			self.BtnStop:SetIsEnabled(false,false)
		else
			self.BtnStop:SetIsEnabled(true,true)
		end
	end
end

function CraftingLogSimpleWorkPanelView:ToMake()
	if self.IsClickRightAwayMake then
		self.IsClickRightAwayMake = false
		local ToMakeCountRightAway = SimpleVM:GetLeftNum()
		FLOG_INFO("Crafter SimpleMake Counts:%d RightAway", ToMakeCountRightAway)
		_G.CrafterMgr:SetSkillMakeCount(ToMakeCountRightAway)

		UIUtil.SetIsVisible(self.EFF_1,true)
		local Progress = SimpleVM:GetProgress()
		self:PlayAnimationTimeRange(self.AnimProgress, self.AnimProgress:GetEndTime() * Progress, 1, 1, nil, 1.0, false)
	else
		_G.CrafterMgr:SetSkillMakeCount(1)
	end

	--请求制作，释放制作技能
	_G.CrafterMgr:CastLifeSkill(0)
	_G.CrafterMgr.bResultShown = false

	self.IsInCD = true
	self:RegisterTimer(function ()
		self.IsInCD = false
	end, 0.5, 0, 1)
end

function CraftingLogSimpleWorkPanelView:OnAnimationFinished(Animation)
	if Animation == self.AnimProgress then
		--策划说可以直接预表现
		local Total = SimpleVM.TotalMakeCount
		self.TextAmount:SetText(string.format("%d/%d", Total, Total))
	end
end

function CraftingLogSimpleWorkPanelView:OnMakeFinished()
	local Total = SimpleVM.TotalMakeCount
	self.TextAmount:SetText(string.format("%d/%d", Total, Total))
	self:PlayAnimationTimeRange(self.AnimProgress, self.AnimProgress:GetEndTime(), 1, 1, nil, 1.0, false)
	SimpleVM:QuitSimpleMake()
end


--立即完成
function CraftingLogSimpleWorkPanelView:OnFinishBtnClicked()
	if self.IsInCD then
		_G.FLOG_INFO("CraftingLogSimpleWork CDing...")
		return
	end
	--判断金币
	if _G.CraftingLogMgr.ScoreNotEnough then
		_G.MsgTipsUtil.ShowTips(_G.LSTR(80046)) --金币不足
		return
	end

	self.BtnFinish:SetIsEnabled(false,false)
	self.BtnStop:SetIsEnabled(false,false)
	UIUtil.SetIsVisible(self.HorizontalCost,false)

	--如果技能还在施放中点击的立即完成只走协议
	local IsSkilling, SubSkillID = self:IsSkilling()
	if IsSkilling == true and SubSkillID ~= nil then
		SimpleVM.IsClickRightAway = true --回包之后再false，防止断线没发过去，重连后再来一次
		--加上已经释放技能的这次（放在这里加是因为大概率执行到OnSimpleMakeRltCounts时Msg被新的回包覆盖，就会少一次）
		SimpleVM:AddMakeCounts(1)
		local LeftNum = SimpleVM:GetLeftNum()
		_G.CrafterMgr:SendRightAwayReq(SubSkillID, LeftNum)
		--进度条先直接表现，但是SimpleVM的制作数量由后台消息同步
		UIUtil.SetIsVisible(self.EFF_1,true)
		local Progress = SimpleVM:GetProgress()
		self:PlayAnimationTimeRange(self.AnimProgress, self.AnimProgress:GetEndTime() * Progress, 1, 1, nil, 1.0, false)
		return
	end

	self.IsClickRightAwayMake = true
end

function CraftingLogSimpleWorkPanelView:IsSkilling()
	local CurSkillWeight = _G.SkillPreInputMgr:GetCurrentSkillWeight()
    if CurSkillWeight then
        local SubSkillID = _G.SkillLogicMgr:GetMultiSkillReplaceResult(0, MajorUtil.GetMajorEntityID())
        local ToCastSkillWeight = _G.SkillPreInputMgr:GetInputSkillWeight(SubSkillID)
        if ToCastSkillWeight and ToCastSkillWeight <= CurSkillWeight then
			return true, SubSkillID
		end
	end
	return false
end

--中止/关闭按钮
function CraftingLogSimpleWorkPanelView:OnCloseBtnOnClicked()
	--点击中止时，正在进入制作状态，还未开始制作，请求离开制作状态
	if self.DelayMakeTimerID then
		_G.TimerMgr:CancelTimer(self.DelayMakeTimerID)
		self.DelayMakeTimerID = nil
		SimpleVM:QuitSimpleMake()
	elseif self.CloseViewTimer == nil then
		SimpleVM.IsClickCloseBtn = true
		--如果没有在制作（卡住或上一个制作完了）直接退出制作状态，旨在让卡住后不要延时关闭
		local IsSkilling = self:IsSkilling()
		if not IsSkilling then
			SimpleVM:QuitSimpleMake()
		else
			--如果正在制作过程中
			--正常流程是当前这次制作结束后(OnSimpleMakeOver)或技能结束后(CrafterMgr:DoSkillEnd)，判断若点过关闭按钮就关闭界面并退出状态
			--兜底：定时3秒后，若还未退出制作状态，触发保护机制，强制关闭界面并退出状态
			self.CloseViewTimer = self:RegisterTimer( function ()
				if _G.CrafterMgr.IsMaking then
					_G.CrafterMgr:DelayShowLogView()
					_G.CrafterMgr.CrafterLogbAlreadyOpend = true
					self.CloseViewTimer = nil
					SimpleVM:QuitSimpleMake()
				end
			end, 3, 1, 1)
		end
	end

	self.BtnFinish:SetIsEnabled(false,false)
	self.BtnStop:SetIsEnabled(false,false)
	UIUtil.SetIsVisible(self.HorizontalCost,false)
end

return CraftingLogSimpleWorkPanelView