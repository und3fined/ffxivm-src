---
--- Author: Administrator
--- DateTime: 2025-07-21 17:02
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonBoxDefine = require("Game/CommMsg/CommonBoxDefine")
local ScoreMgr = require("Game/Score/ScoreMgr")
local GetServerTime = _G.TimeUtil.GetServerTime
local UIViewMgr = _G.UIViewMgr
local UIDefine = require("Define/UIDefine")
local CommBtnColorType = UIDefine.CommBtnColorType


---@class CommTextWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm2FrameS_UIBP Comm2FrameSView
---@field CommMoney CommMoneyBarView
---@field ImgSpent UFImage
---@field PanelSpent UFHorizontalBox
---@field RichText URichTextBox
---@field TextSpentTotal UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommTextWinView = LuaClass(UIView, true)

function CommTextWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm2FrameS_UIBP = nil
	--self.CommMoney = nil
	--self.ImgSpent = nil
	--self.PanelSpent = nil
	--self.RichText = nil
	--self.TextSpentTotal = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommTextWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameS_UIBP)
	self:AddSubView(self.CommMoney)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommTextWinView:OnInit()
	self.LeftBtnOp = self.Comm2FrameS_UIBP.Ben2Left
	self.RightBtnOp = self.Comm2FrameS_UIBP.Btn2Right
	self.OneBtnOp = self.Comm2FrameS_UIBP.Btn1
	self.PopUpBG = self.Comm2FrameS_UIBP.PopUpBG
	self:SetSoundPathOnClick()
end

function CommTextWinView:OnDestroy()

end

function CommTextWinView:OnShow()
	self:UpdateView(self.Params)
end

function CommTextWinView:OnHide()
	self.bStartTimer = false

	if self.Params and self.Params.CallbackOnHide then
		self.Params.CallbackOnHide(self)
	end
end

function CommTextWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.LeftBtnOp, 			self.OnBtnClickL)
	UIUtil.AddOnClickedEvent(self, self.RightBtnOp, 		self.OnBtnClickR)
	UIUtil.AddOnClickedEvent(self, self.OneBtnOp, 			self.OnBtnClickOne)
	UIUtil.AddOnClickedEvent(self, self.PopUpBG.ButtonMask, self.OnMaskBtnClick)
	UIUtil.AddOnClickedEvent(self, self.Comm2FrameS_UIBP.ButtonClose, self.OnBtnClickClose)

end

function CommTextWinView:OnRegisterGameEvent()

end

function CommTextWinView:OnRegisterBinder()

end

function CommTextWinView:UpdateView(Info)
	if nil == Info then
		return
	end

	self.RichText:SetJustification(Info.TextAlignment)
	self.RichText:SetText(Info.Message or "")
	self.Comm2FrameS_UIBP:SetTitleText(Info.Title or "")

	if Info.HideCloseBtn then
		UIUtil.SetIsVisible(self.Comm2FrameS_UIBP.ButtonClose,false)
	end

	if Info.CostNum and Info.CostItemID then
		UIUtil.SetIsVisible(self.PanelSpent,true)
		UIUtil.SetIsVisible(self.ImgSpent,true)
		UIUtil.SetIsVisible(self.TextSpentTotal,true)
		local Icon = ScoreMgr:GetScoreIconName(Info.CostItemID)--GetItemIcon(self.Params.CostItemID)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgSpent, Icon)
		--local Num = GetItemNum(Info.CostItemID)
		local ReqNum = Info.CostNum
		self.TextSpentTotal:SetText(ReqNum)
		if Info.CostColor then
			local LinearColor = _G.UE.FLinearColor.FromHex(Info.CostColor)
			if LinearColor then
				self.TextSpentTotal:SetColorAndOpacity(LinearColor)
			end
		else
			self.TextSpentTotal:SetColorAndOpacity(_G.UE.FLinearColor.FromHex("D5D5D5FF"))
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
		else
			self.TextSpentTotal:SetColorAndOpacity(_G.UE.FLinearColor.FromHex("D5D5D5FF"))
		end
	else 
		UIUtil.SetIsVisible(self.PanelSpent,false)
		UIUtil.SetIsVisible(self.ImgSpent,false)
		UIUtil.SetIsVisible(self.TextSpentTotal,false)
	end

	if Info.bUseLeftTime and not Info.bRightBtnBeginCountDown then
		self:StartTimer(Info.LeftTime)
	end

	self:SetMoneyBar(Info)

	if nil == Info.BtnUniformType then
		return
	end

	self.BtnMap = {}
	self.BtnMap[CommonBoxDefine.BtnType.Right] = self.RightBtnOp
	self.BtnMap[CommonBoxDefine.BtnType.Left] = self.LeftBtnOp
	self.BtnMap[CommonBoxDefine.BtnType.One] = self.OneBtnOp

	UIUtil.SetIsVisible(self.Comm2FrameS_UIBP.Panel2Btn, Info.BtnUniformType == CommonBoxDefine.BtnUniformType.TwoOp)


	for BtnType, Btn in pairs(self.BtnMap) do
        local Flag = 1 << BtnType
		local bVisible = (Info.BtnUniformType & Flag) == Flag
		UIUtil.SetIsVisible(Btn, bVisible)

		local BtnName = CommonBoxDefine.BtnInitialName[BtnType]
		if nil ~= Info.BtnInfo and nil ~= Info.BtnInfo.Name then
			BtnName = Info.BtnInfo.Name[BtnType] or BtnName
		end
		Btn:SetText(BtnName)
		if Info.BtnInfo and Info.BtnInfo.Style then
			Btn:SetColorType(Info.BtnInfo.Style[BtnType])
		end

		if Info.BtnInfo and Info.BtnInfo.CounterDown and Info.BtnInfo.CounterDown[BtnType] then
			Btn:SetCounterdown(Info.BtnInfo.CounterDown[BtnType])
		end
	end

    self.CheckBoxSetRightBtnDisableState = Info.CheckBoxSetRightBtnDisableState
	 if self.CheckBoxSetRightBtnDisableState and self.RightBtnOp then
        self.RightBtnOp:SetIsDisabledState(true, true)
	end

	if Info.FontSize then
		self.RichText.Font.Size = Info.FontSize
		self.RichText:SetFont(self.RichText.Font)
	end


	if Info.RightBtnOpState then
		self:SetBtnTypeByState(self.RightBtnOp, Info.RightBtnOpState)
	end

end

---按钮音效设置
function CommTextWinView:SetSoundPathOnClick()
	local SoftPath = _G.UE.FSoftObjectPath()
	
	SoftPath:SetPath("/Game/WwiseAudio/Events/UI/UI_SYS/New/Play_FM_Cancel.Play_FM_Cancel")
	self.LeftBtnOp.Button.SoundPathOnClick = SoftPath

	SoftPath:SetPath("/Game/WwiseAudio/Events/UI/UI_SYS/New/Play_FM_Function.Play_FM_Function")
	self.RightBtnOp.Button.SoundPathOnClick = SoftPath
end

function CommTextWinView:StartTimer(LeftTime)
	local LeftTime = tonumber(LeftTime) or 0
	self.ExpdTime = GetServerTime() + LeftTime
	self:RegisterTimer(self.OnTimer, 0, 1, 0)
	self.hasOnLeftTime = nil
	self:OnTimer()
	self.bStartTimer = true
end

function CommTextWinView:OnTimer()
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
					----view存在且失效时会返回false
					local IsViewValid = self:CheckViewValid()
					if IsViewValid then
						Callback(self.Params.UIView)
					end
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
	--self.RichTextExtraHint:SetText(string.format(Fmt, LeftTime))
end

----顶部货币设置
function CommTextWinView:SetMoneyBar(Info)
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

function CommTextWinView:SetBtnTypeByState(Widget, State)
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


----按钮点击处理
function CommTextWinView:OnBtnClick(BtnType)
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
			----view存在且失效时会返回false
			local IsViewValid = self:CheckViewValid()
			if IsViewValid then
				Callback(self.Params.UIView)
			end
		end
	end

	if self.Params and self.Params.bUseOnLeftTimeClose == true then
		UIViewMgr:HideView(self.ViewID)
	end
end

----检查View是否失效
function CommTextWinView:CheckViewValid()
	----当view失效时，不触发回调函数/有部分调用传入的不是view,只对有IsValid函数的类做判断/View可能为nil，为nil的情况也返回true
	local IsViewValid = true
	if self.Params.UIView and self.Params.UIView.IsValid and not self.Params.UIView:IsValid() then
		IsViewValid = false
	end
	return IsViewValid
end

function CommTextWinView:OnBtnClickL()
	self:OnBtnClick(CommonBoxDefine.BtnType.Left)
end

function CommTextWinView:OnBtnClickR()
	self:OnBtnClick(CommonBoxDefine.BtnType.Right)
end

function CommTextWinView:OnBtnClickOne()
	self:OnBtnClick(CommonBoxDefine.BtnType.One)
end

function CommTextWinView:OnMaskBtnClick()
	if self.Params and self.Params.MaskClickCB then
		self.Params.MaskClickCB(self.Params.UIView)

		if self.Params.bUseCloseOnClick == true then
			UIViewMgr:HideView(self.ViewID)
		end
	end
end

--[sammrli] 动态设置切图时是否关闭
function CommTextWinView:GetConfigDontHideWhenLoadMap()
	if self.Params and self.Params.DontHideWhenLoadMap ~= nil then
		return self.Params.DontHideWhenLoadMap
	end
	return self.Super:GetConfigDontHideWhenLoadMap()
end

function CommTextWinView:OnBtnClickClose()
	if self.CloseBtnCallback ~= nil then
		self.CloseBtnCallback(self, self.CloseBtnCallback)
	elseif self.Params and self.Params.CloseClickCB then
		self.Params.CloseClickCB(self.Params.UIView)
	end
	--UIViewMgr:HideView(self.ViewID)
end

return CommTextWinView