---
--- Author: enqingchen
--- DateTime: 2022-03-28 19:41
--- Description:
--- Refactoring By v_hggzhang at 22.06
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonBoxDefine = require("Game/CommMsg/CommonBoxDefine")
local UIViewMgr = _G.UIViewMgr
local GetServerTime = _G.TimeUtil.GetServerTime

---@class CommMsgBoxView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG CommMsgTipsView
---@field BtnPanelSwitcher UWidgetSwitcher
---@field Button UFCanvasPanel
---@field EditableTextRename UMultiLineEditableText
---@field LeftBtnThreeOp Comm2BtnMView
---@field LeftBtnTwoOp Comm2BtnLView
---@field LeftTimeText URichTextBox
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
local CommMsgBoxView = LuaClass(UIView, true)

function CommMsgBoxView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnPanelSwitcher = nil
	--self.Button = nil
	--self.EditableTextRename = nil
	--self.LeftBtnThreeOp = nil
	--self.LeftBtnTwoOp = nil
	--self.LeftTimeText = nil
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

function CommMsgBoxView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.LeftBtnThreeOp)
	self:AddSubView(self.LeftBtnTwoOp)
	self:AddSubView(self.MiddleBtnThreeOp)
	self:AddSubView(self.RightBtnRightOp)
	self:AddSubView(self.RightBtnTwoOp)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommMsgBoxView:OnInit()

end

function CommMsgBoxView:OnDestroy()

end

function CommMsgBoxView:OnShow()
	self:UpdateView(self.Params)
end

function CommMsgBoxView:OnHide()

end

function CommMsgBoxView:OnRegisterUIEvent()
	--
end

function CommMsgBoxView:OnRegisterGameEvent()

end

function CommMsgBoxView:OnRegisterBinder()

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

function CommMsgBoxView:UpdateView(Info)
	if nil == Info then
		return
	end

	self.RichTextBox_Desc:SetText(Info.Message or "")
	self.BG.RichTextBox_Title:SetText(Info.Title or "")

	local bTipsVisible = Info.bUseTips or false
	UIUtil.SetIsVisible(self.TipsPanel, bTipsVisible)
	self.RichTextTips:SetText(Info.TipsText or "")

	UIUtil.SetIsVisible(self.LeftTimeText, Info.bUseLeftTime == true)
	if Info.bUseLeftTime then
		local LeftTime = tonumber(Info.LeftTime) or 0
		self.ExpdTime = GetServerTime() + LeftTime
		self:RegisterTimer(self.OnTimer, 0, 1, 0)
		self.hasOnLeftTime = nil
		self:OnTimer()
	end

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
		UIUtil.AddOnClickedEvent(self, self.PopUpBG.ButtonMask, self.OnMaskBtnClick)
	end

end

function CommMsgBoxView:OnTimer()
	local LeftTime = (self.ExpdTime - GetServerTime())
	LeftTime = math.floor(LeftTime + 0.5)
	if LeftTime < 0 then
		if self.Params and self.Params.OnLeftTimeCB and self.hasOnLeftTime ~= true then
			self.Params.OnLeftTimeCB(self.Params.UIView)
			self.hasOnLeftTime = true
		end

		if self.Params and self.Params.bUseOnLeftTimeClose == true then
			UIViewMgr:HideView(self.ViewID)
		end
		return
	end
	LeftTime = math.max(LeftTime, 0)
	local Fmt = self.Params.LeftTimeStrFmt or "" -- "(%d)s"
	self.LeftTimeText:SetText(string.format(Fmt, LeftTime))
end

function CommMsgBoxView:OnBtnClick(BtnType)
	if self.Params and self.Params.BtnInfo and self.Params.BtnInfo.Callback then
		local Callback = self.Params.BtnInfo.Callback[BtnType]
		if nil ~= Callback then
			Callback(self.Params.UIView)
		end
	end

	if self.Params and self.Params.bUseOnLeftTimeClose == true then
		UIViewMgr:HideView(self.ViewID)
	end
end

function CommMsgBoxView:OnBtnClickL()
	self:OnBtnClick(CommonBoxDefine.BtnType.Left)
end

function CommMsgBoxView:OnBtnClickM()
	self:OnBtnClick(CommonBoxDefine.BtnType.Middle)
end

function CommMsgBoxView:OnBtnClickR()
	self:OnBtnClick(CommonBoxDefine.BtnType.Right)
end

function CommMsgBoxView:OnMaskBtnClick()
	if self.Params and self.Params.MaskClickCB then
		self.Params.MaskClickCB(self.Params.UIView)

		if self.Params.bUseCloseOnClick == true then
			UIViewMgr:HideView(self.ViewID)
		end
	end
end

return CommMsgBoxView