---
--- Author: v_hggzhang
--- DateTime: 2023-08-10 10:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local ItemUtil = require("Utils/ItemUtil")
local ScoreMgr = require("Game/Score/ScoreMgr")
local CommonBoxDefine = require("Game/CommMsg/CommonBoxDefine")
local UIViewMgr = _G.UIViewMgr
local GetServerTime = _G.TimeUtil.GetServerTime
local UIDefine = require("Define/UIDefine")
local CommBtnColorType = UIDefine.CommBtnColorType

---@class CommMsgBoxNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field BtnItem UFButton
---@field CheckBoxNoReminder CommSingleBoxView
---@field Comm58Slot CommBackpack58SlotView
---@field CommMoney CommMoneyBarView
---@field CommonTips CommonTipsView
---@field Icon UFImage
---@field ImgSpent UFImage
---@field LeftBtnOp CommBtnLView
---@field LeftBtnThreeOp CommBtnMView
---@field MiddleBtnThreeOp CommBtnMView
---@field Panel2Btns UFHorizontalBox
---@field Panel3Btns UCanvasPanel
---@field PanelConsume UFHorizontalBox
---@field PanelSpent UFHorizontalBox
---@field PopUpBG CommonPopUpBGView
---@field RichTextBoxDesc URichTextBox
---@field RichTextBoxTitle URichTextBox
---@field RichTextExtraHint URichTextBox
---@field RightBtnOp CommBtnLView
---@field RightBtnThreeOp CommBtnMView
---@field SpacerMid USpacer
---@field TextQuantity URichTextBox
---@field TextSpentTotal UFTextBlock
---@field Textconsume UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommMsgBoxNewView = LuaClass(UIView, true)

function CommMsgBoxNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnItem = nil
	--self.CheckBoxNoReminder = nil
	--self.Comm58Slot = nil
	--self.CommMoney = nil
	--self.CommonTips = nil
	--self.Icon = nil
	--self.ImgSpent = nil
	--self.LeftBtnOp = nil
	--self.LeftBtnThreeOp = nil
	--self.MiddleBtnThreeOp = nil
	--self.Panel2Btns = nil
	--self.Panel3Btns = nil
	--self.PanelConsume = nil
	--self.PanelSpent = nil
	--self.PopUpBG = nil
	--self.RichTextBoxDesc = nil
	--self.RichTextBoxTitle = nil
	--self.RichTextExtraHint = nil
	--self.RightBtnOp = nil
	--self.RightBtnThreeOp = nil
	--self.SpacerMid = nil
	--self.TextQuantity = nil
	--self.TextSpentTotal = nil
	--self.Textconsume = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommMsgBoxNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CheckBoxNoReminder)
	self:AddSubView(self.Comm58Slot)
	self:AddSubView(self.CommMoney)
	self:AddSubView(self.CommonTips)
	self:AddSubView(self.LeftBtnOp)
	self:AddSubView(self.LeftBtnThreeOp)
	self:AddSubView(self.MiddleBtnThreeOp)
	self:AddSubView(self.PopUpBG)
	self:AddSubView(self.RightBtnOp)
	self:AddSubView(self.RightBtnThreeOp)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommMsgBoxNewView:OnInit()
	self:SetSoundPathOnClick()
end

function CommMsgBoxNewView:OnDestroy()

end

function CommMsgBoxNewView:OnShow()
	self:UpdateView(self.Params)
end

function CommMsgBoxNewView:OnHide()
	self.bStartTimer = false

	if self.Params and self.Params.CallbackOnHide then
		self.Params.CallbackOnHide(self)
	end
end

function CommMsgBoxNewView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.CheckBoxNoReminder, 			self.OnNoRemindCheck)

	UIUtil.AddOnClickedEvent(self, self.LeftBtnOp, 			self.OnBtnClickL)
	UIUtil.AddOnClickedEvent(self, self.RightBtnOp, 		self.OnBtnClickR)
	UIUtil.AddOnClickedEvent(self, self.LeftBtnThreeOp, 	self.OnBtnClickL)
	UIUtil.AddOnClickedEvent(self, self.RightBtnThreeOp, 	self.OnBtnClickR)
	UIUtil.AddOnClickedEvent(self, self.MiddleBtnThreeOp, 	self.OnBtnClickM)
	UIUtil.AddOnClickedEvent(self, self.PopUpBG.ButtonMask, self.OnMaskBtnClick)
	UIUtil.AddOnClickedEvent(self, self.Comm58Slot.Btn, 	self.OnClickItemTips)

	self.BtnClose:SetCallback(self, self.OnBtnClickClose)
end

function CommMsgBoxNewView:OnRegisterGameEvent()
	
end

function CommMsgBoxNewView:OnRegisterBinder()

end

local function GetItemNum(ItemID)
	return _G.BagMgr:GetItemNum(ItemID)
end

local function GetItemName(ItemID)
	return ItemUtil.GetItemName(ItemID)
end

function CommMsgBoxNewView:UpdateView(Info)
	if nil == Info then
		return
	end

	self.CheckBoxNoReminder:SetText(Info.NeverMindText or "")

	self.RichTextBoxDesc:SetText(Info.Message or "")
	self.RichTextBoxTitle:SetText(Info.Title or "")

	local bTipsVisible = Info.bUseTips or false
	self.RichTextExtraHint:SetText(Info.TipsText or "")

	if (Info.CloseBtnCallback ~= nil) then
		self.BtnClose:SetCallback(self, Info.CloseBtnCallback)
	end

	if Info.HideCloseBtn then
		UIUtil.SetIsVisible(self.BtnClose,false)
	end

	UIUtil.SetIsVisible(self.RichTextExtraHint, (bTipsVisible or Info.bUseLeftTime == true))

	if Info.CostNum and Info.CostItemID then
		UIUtil.SetIsVisible(self.PanelSpent,true)
		UIUtil.SetIsVisible(self.ImgSpent,true)
		UIUtil.SetIsVisible(self.TextSpentTotal,true)
		local Icon = ScoreMgr:GetScoreIconName(Info.CostItemID)--GetItemIcon(self.Params.CostItemID)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgSpent, Icon)
		local Num = GetItemNum(Info.CostItemID)
		local ReqNum = Info.CostNum
		self.TextSpentTotal:SetText(ReqNum)
		if Info.CostColor then
			local LinearColor = _G.UE.FLinearColor.FromHex(Info.CostColor)
			if LinearColor then
				self.TextSpentTotal:SetColorAndOpacity(LinearColor)
			end
		end
	elseif Info.TextSpentTotal then	
		UIUtil.SetIsVisible(self.PanelSpent,true)
		UIUtil.SetIsVisible(self.ImgSpent,false)
		UIUtil.SetIsVisible(self.TextSpentTotal,true)
		self.TextSpentTotal:SetText(Info.TextSpentTotal)
		if Info.TextSpentTotalColor then
			local LinearColor = _G.UE.FLinearColor.FromHex(Info.TextSpentTotalColor)
			if LinearColor then
				self.TextSpentTotal:SetColorAndOpacity(LinearColor)
			end
		end
	else 
		UIUtil.SetIsVisible(self.PanelSpent,false)
		UIUtil.SetIsVisible(self.ImgSpent,false)
		UIUtil.SetIsVisible(self.TextSpentTotal,false)
	end

	if Info.bUseLeftTime and not Info.bRightBtnBeginCountDown then
		self:StartTimer(Info.LeftTime)
	end

	if nil == Info.BtnUniformType then
		return
	end

	self.BtnMap = {}
	self.BtnMap[CommonBoxDefine.BtnType.Middle] = self.MiddleBtnThreeOp
	self.BtnMap[CommonBoxDefine.BtnType.Right] = self.RightBtnOp
	self.BtnMap[CommonBoxDefine.BtnType.Left] = self.LeftBtnOp

	if Info.BtnUniformType == CommonBoxDefine.BtnUniformType.ThreeOp then
		self.BtnMap[CommonBoxDefine.BtnType.Right] = self.RightBtnThreeOp
		self.BtnMap[CommonBoxDefine.BtnType.Left] = self.LeftBtnThreeOp
	end

	UIUtil.SetIsVisible(self.Panel2Btns, Info.BtnUniformType ~= CommonBoxDefine.BtnUniformType.ThreeOp and Info.BtnUniformType ~= CommonBoxDefine.BtnUniformType.NoOp)
	UIUtil.SetIsVisible(self.Panel3Btns, Info.BtnUniformType == CommonBoxDefine.BtnUniformType.ThreeOp)


	for BtnType, Btn in pairs(self.BtnMap) do
        local Flag = 1 << BtnType
		local bVisible = (Info.BtnUniformType & Flag) == Flag
		UIUtil.SetIsVisible(Btn, bVisible)

		local BtnName = CommonBoxDefine.BtnInitialName[BtnType]
		if nil ~= Info.BtnInfo and nil ~= Info.BtnInfo.Name then
			BtnName = Info.BtnInfo.Name[BtnType] or BtnName
		end
		Btn:SetText(BtnName)
		Btn:SetColorType(Info.BtnInfo.Style[BtnType])

		if Info.BtnInfo.CounterDown[BtnType] then
			Btn:SetCounterdown(Info.BtnInfo.CounterDown[BtnType])
		end
	end

	UIUtil.SetIsVisible(self.SpacerMid, (UIUtil.IsVisible(self.LeftBtnOp) == UIUtil.IsVisible(self.RightBtnOp)))

	UIUtil.SetIsVisible(self.CheckBoxNoReminder, Info.bUseNever ~= nil)
	self.CheckBoxNoReminder:SetChecked(false)
	self.bUseNever = Info.bUseNever
	self.IsNeverAgain = nil

	
	self.RichTextBoxDesc.Font.Size = Info.FontSize
	self.RichTextBoxDesc:SetFont(self.RichTextBoxDesc.Font)

	UIUtil.SetIsVisible(self.PanelConsume, Info.ItemResID ~= nil)
	if Info.ItemResID then
		self:SetItemIcon(Info.ItemResID)
		self.TextQuantity:SetText(Info.TextQuantity)
		self.Textconsume:SetText(_G.LSTR(620107))
	end

	if Info.RightBtnOpState then
		self:SetBtnTypeByState(self.RightBtnOp, Info.RightBtnOpState)
	end
	self:SetMoneyBar(Info)
end

function CommMsgBoxNewView:SetMoneyBar(Info)
	if Info == nil then
		return
	end
	local MoneyData = Info.MoneyData or {}
	UIUtil.SetIsVisible(self.CommMoney, next(MoneyData) and true or false)
	local Widget = self.CommMoney
	if Widget == nil or MoneyData == nil then
		return
	end
	UIUtil.SetIsVisible(Widget.Money1,  MoneyData.Money1 and true or false)
	UIUtil.SetIsVisible(Widget.Money2,  MoneyData.Money2 and true or false)
	UIUtil.SetIsVisible(Widget.Money3,  MoneyData.Money3 and true or false)

	if MoneyData and MoneyData.Money1 then
		Widget.Money1:UpdateView(MoneyData.Money1.ScoreType, MoneyData.Money1.UIView ~= nil, MoneyData.Money1.UIView, true)
	end

	if MoneyData and MoneyData.Money2 then
		Widget.Money2:UpdateView(MoneyData.Money2.ScoreType, MoneyData.Money2.UIView ~= nil, MoneyData.Money2.UIView, true)
	end

	if MoneyData and MoneyData.Money3 then
		Widget.Money3:UpdateView(MoneyData.Money3.ScoreType, MoneyData.Money3.UIView ~= nil, MoneyData.Money3.UIView, true)
	end
end

function CommMsgBoxNewView:SetBtnTypeByState(Widget, State)
	if State == CommBtnColorType.Disable then
		Widget:SetIsDisabledState(true, true)
	elseif State == CommBtnColorType.Done then
		Widget:SetIsDoneState(true)
	elseif State == CommBtnColorType.Recommend then
		Widget:SetIsRecommendState(true)
	else
		Widget:SetIsNormalState(true)
	end
end

function CommMsgBoxNewView:StartTimer(LeftTime)
	local LeftTime = tonumber(LeftTime) or 0
	self.ExpdTime = GetServerTime() + LeftTime
	self:RegisterTimer(self.OnTimer, 0, 1, 0)
	self.hasOnLeftTime = nil
	self:OnTimer()
	self.bStartTimer = true
end

function CommMsgBoxNewView:OnTimer()
	local LeftTime = (self.ExpdTime - GetServerTime())
	LeftTime = math.floor(LeftTime + 0.5)
	if LeftTime < 0 then
		if self.Params and self.Params.OnLeftTimeCB and self.hasOnLeftTime ~= true then
			self.Params.OnLeftTimeCB(self.Params.UIView)
			self.hasOnLeftTime = true
		end

		if self.Params and self.Params.bRightBtnBeginCountDown then
			if self.Params.BtnInfo and self.Params.BtnInfo.Callback then
				local Callback = self.Params.BtnInfo.Callback[CommonBoxDefine.BtnType.Right]
				if nil ~= Callback then
					--点了RightBtn，并且是点击才开始倒计时的，这个时候只是触发倒计时
					--但是当倒计时结束了，就会触发RightBtn的响应逻辑
					Callback(self.Params.UIView, {IsNeverAgain = self.IsNeverAgain})
				end
			end
		end

		if self.Params and self.Params.bUseOnLeftTimeClose == true then
			UIViewMgr:HideView(self.ViewID)
		end
		return
	end
	LeftTime = math.max(LeftTime, 0)
	local Fmt = self.Params and self.Params.LeftTimeStrFmt or "" -- "(%d)s"
	self.RichTextExtraHint:SetText(string.format(Fmt, LeftTime))
end

function CommMsgBoxNewView:OnBtnClick(BtnType)
	if self.Params and self.Params.BtnInfo and self.Params.BtnInfo.Callback then
		local Callback = self.Params.BtnInfo.Callback[BtnType]
		if nil ~= Callback then
			--点了RightBtn，并且是点击才开始倒计时的，这个时候只是触发倒计时
			if CommonBoxDefine.BtnType.Right == BtnType and self.Params.bRightBtnBeginCountDown then
				if not self.bStartTimer then
					self:StartTimer(self.Params.LeftTime)
				end
				
				return 
			end
			Callback(self.Params.UIView, {IsNeverAgain = self.IsNeverAgain})
		end
	end

	if self.Params and self.Params.bUseOnLeftTimeClose == true then
		UIViewMgr:HideView(self.ViewID)
	end
end

function CommMsgBoxNewView:OnBtnClickL()
	self:OnBtnClick(CommonBoxDefine.BtnType.Left)
end

function CommMsgBoxNewView:OnBtnClickM()
	self:OnBtnClick(CommonBoxDefine.BtnType.Middle)
end

function CommMsgBoxNewView:OnBtnClickR()
	self:OnBtnClick(CommonBoxDefine.BtnType.Right)
end

function CommMsgBoxNewView:OnMaskBtnClick()
	if self.Params and self.Params.MaskClickCB then
		self.Params.MaskClickCB(self.Params.UIView)

		if self.Params.bUseCloseOnClick == true then
			UIViewMgr:HideView(self.ViewID)
		end
	end
end

function CommMsgBoxNewView:OnClickItemTips()
	if self.Params and self.Params.ItemResID then
		local ItemTipsUtil = require("Utils/ItemTipsUtil")
		ItemTipsUtil.ShowTipsByResID(self.Params.ItemResID , self.Comm58Slot)
	end
end

function CommMsgBoxNewView:OnBtnClickClose()
	if self.Params and self.Params.CloseClickCB then
		self.Params.CloseClickCB(self.Params.UIView)
	end
	UIViewMgr:HideView(self.ViewID)
end

function CommMsgBoxNewView:OnNoRemindCheck(_, Stat)
	self.IsNeverAgain = UIUtil.IsToggleButtonChecked(Stat)
end

function CommMsgBoxNewView:SetSoundPathOnClick()
	local SoftPath = _G.UE.FSoftObjectPath()
	
	SoftPath:SetPath("/Game/WwiseAudio/Events/UI/UI_SYS/New/Play_FM_Cancel.Play_FM_Cancel")
	self.LeftBtnOp.Button.SoundPathOnClick = SoftPath
	self.LeftBtnThreeOp.Button.SoundPathOnClick = SoftPath

	SoftPath:SetPath("/Game/WwiseAudio/Events/UI/UI_SYS/New/Play_FM_Function.Play_FM_Function")
	self.RightBtnOp.Button.SoundPathOnClick = SoftPath
	self.RightBtnThreeOp.Button.SoundPathOnClick = SoftPath
	self.MiddleBtnThreeOp.Button.SoundPathOnClick = SoftPath
end

function CommMsgBoxNewView:SetItemIcon(ResID)
	local ItemCfg = require("TableCfg/ItemCfg")
	local ItemUtil = require("Utils/ItemUtil")
	local Cfg = ItemCfg:FindCfgByKey(ResID)
	local ImgPath = ItemCfg.GetIconPath(Cfg.IconID or 0) or ""
	self.Comm58Slot:SetIconImg(ImgPath)
	self.Comm58Slot:SetQualityImg(ItemUtil.GetItemColorIcon(ResID))
	self.Comm58Slot:SetNumVisible(false)
	UIUtil.SetIsVisible(self.Comm58Slot.IconChoose, false)
	UIUtil.SetIsVisible(self.Comm58Slot.RichTextLevel, false)
end

return CommMsgBoxNewView