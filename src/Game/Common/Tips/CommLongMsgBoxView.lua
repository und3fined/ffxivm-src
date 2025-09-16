---
--- Author: moodliu
--- DateTime: 2023-05-09 10:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonBoxDefine = require("Game/CommMsg/CommonBoxDefine")
local UIViewMgr = _G.UIViewMgr
local GetServerTime = _G.TimeUtil.GetServerTime

---@class CommLongMsgBoxView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG CommMsgTipsView
---@field BtnPanelSwitcher UWidgetSwitcher
---@field Button UFCanvasPanel
---@field EditableTextRename UMultiLineEditableText
---@field LeftBtnThreeOp Comm2BtnMView
---@field LeftBtnTwoOp Comm2BtnLView
---@field MiddleBtnThreeOp Comm2BtnMView
---@field RichTextBox_Desc URichTextBox
---@field RichTextTips URichTextBox
---@field RightBtnRightOp Comm2BtnMView
---@field RightBtnTwoOp Comm2BtnLView
---@field ThreeBtnPanel UCanvasPanel
---@field TipsPanel UHorizontalBox
---@field ToggleButtonCheck UToggleButton
---@field TwoBtnPanel UFHorizontalBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommLongMsgBoxView = LuaClass(UIView, true)

function CommLongMsgBoxView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnPanelSwitcher = nil
	--self.Button = nil
	--self.EditableTextRename = nil
	--self.LeftBtnThreeOp = nil
	--self.LeftBtnTwoOp = nil
	--self.MiddleBtnThreeOp = nil
	--self.RichTextBox_Desc = nil
	--self.RichTextTips = nil
	--self.RightBtnRightOp = nil
	--self.RightBtnTwoOp = nil
	--self.ThreeBtnPanel = nil
	--self.TipsPanel = nil
	--self.ToggleButtonCheck = nil
	--self.TwoBtnPanel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommLongMsgBoxView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.LeftBtnThreeOp)
	self:AddSubView(self.LeftBtnTwoOp)
	self:AddSubView(self.MiddleBtnThreeOp)
	self:AddSubView(self.RightBtnRightOp)
	self:AddSubView(self.RightBtnTwoOp)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommLongMsgBoxView:OnInit()

end

function CommLongMsgBoxView:OnDestroy()

end

function CommLongMsgBoxView:OnShow()
	self:UpdateView(self.Params)
end

function CommLongMsgBoxView:OnHide()

end

function CommLongMsgBoxView:OnRegisterUIEvent()
	--
end

function CommLongMsgBoxView:OnRegisterGameEvent()

end

function CommLongMsgBoxView:OnRegisterBinder()

end

local BtnPanelIndex = {
	Two = 0,
	Three = 1
}

local BtnStyleAnim = {
	[CommonBoxDefine.BtnStyleType.Blue] = "AnimState01",
	[CommonBoxDefine.BtnStyleType.Red] = "AnimState03",
	[CommonBoxDefine.BtnStyleType.Yellow] = "AnimState02",
}

function CommLongMsgBoxView:UpdateView(Info)
	if nil == Info then
		return
	end

	self.RichTextBox_Desc:SetText(Info.Message or "")
	self.BG.RichTextBox_Title:SetText(Info.Title or "")

	local bTipsVisible = Info.bUseTips or false
	UIUtil.SetIsVisible(self.TipsPanel, bTipsVisible)
	self.RichTextTips:SetText(Info.TipsText or "")

	if nil == Info.BtnUniformType then
		return
	end

	self.BtnMap = {}
	self.BtnMap[CommonBoxDefine.BtnType.Middle] = self.MiddleBtnThreeOp
	self.BtnMap[CommonBoxDefine.BtnType.Right] = self.RightBtnTwoOp
	self.BtnMap[CommonBoxDefine.BtnType.Left] = self.LeftBtnTwoOp
	local ActiveBtnPanelIndex= BtnPanelIndex.Two

	if Info.BtnUniformType == CommonBoxDefine.BtnUniformType.ThreeOp then
		self.BtnMap[CommonBoxDefine.BtnType.Right] = self.RightBtnRightOp
		self.BtnMap[CommonBoxDefine.BtnType.Left] = self.LeftBtnThreeOp
		ActiveBtnPanelIndex = BtnPanelIndex.Three
	end
	self.BtnPanelSwitcher:SetActiveWidgetIndex(ActiveBtnPanelIndex)


	self:UnRegisterAllUIEvent()

	for BtnType, Btn in pairs(self.BtnMap) do
        local Flag = 1 << BtnType
		local bVisible = (Info.BtnUniformType & Flag) == Flag
		UIUtil.SetIsVisible(Btn, bVisible)
		UIUtil.AddOnClickedEvent(self, Btn.Button, self.OnBtnClick, BtnType)
		local BtnName = CommonBoxDefine.BtnInitialName[BtnType]
		if nil ~= Info.BtnInfo and nil ~= Info.BtnInfo.Name then
			BtnName = Info.BtnInfo.Name[BtnType] or BtnName
		end

		local StyleAnim = BtnStyleAnim[Info.BtnInfo.Style[BtnType]]
		Btn:PlayAnimation(Btn[StyleAnim])

		Btn.TextButton:SetText(BtnName)
	end

	if nil ~= Info.MaskClickCB then
		UIUtil.AddOnClickedEvent(self, self.BG.PopUpBG.ButtonMask, self.OnMaskBtnClick)
	end

	if nil ~= Info.HyperlinkClicked then
		UIUtil.AddOnHyperlinkClickedEvent(self, self.RichTextBox_Desc, Info.HyperlinkClicked)
	end

	if nil ~= Info.bHideOnClickBG then
		self.BG.PopUpBG:SetHideOnClick(Info.bHideOnClickBG)
	end
end

function CommLongMsgBoxView:OnTimer()
	local LeftTime = (self.ExpdTime - GetServerTime())
	LeftTime = math.floor(LeftTime + 0.5)
	if LeftTime < 0 then
		if self.Params and self.Params.OnLeftTimeCB and self.Params.UIView and self.hasOnLeftTime ~= true then
			self.Params.OnLeftTimeCB(self.Params.UIView)
			self.hasOnLeftTime = true
		end

		if self.Params and self.Params.bUseOnLeftTimeClose == true then
			UIViewMgr:HideView(self.ViewID)
		end
		return
	end
end

function CommLongMsgBoxView:OnBtnClick(BtnType)
	if self.Params and self.Params.BtnInfo and self.Params.BtnInfo.Callback and self.Params.UIView then
		local Callback = self.Params.BtnInfo.Callback[BtnType]
		if nil ~= Callback then
			Callback(self.Params.UIView)
		end
	end

	if self.Params and self.Params.bUseOnLeftTimeClose == true then
		UIViewMgr:HideView(self.ViewID)
	end
end

function CommLongMsgBoxView:OnMaskBtnClick()
	if self.Params and self.Params.MaskClickCB and self.Params.UIView then
		self.Params.MaskClickCB(self.Params.UIView)

		if self.Params.bUseCloseOnClick == true then
			UIViewMgr:HideView(self.ViewID)
		end
	end
end

return CommLongMsgBoxView