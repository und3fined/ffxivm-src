---
--- Author: Administrator
--- DateTime: 2024-09-18 16:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local ProtoRes = require("Protocol/ProtoRes")

local NumColor = {
	Succ = "D5D5D5FF",
	Fail = "DC5868FF",
}

---@class WardrobeTipsWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm2FrameS_UIBP Comm2FrameSView
---@field ImgSpent UFImage
---@field LeftBtnOp CommBtnLView
---@field MoneySlot CommMoneySlotView
---@field Panel2Btns UFHorizontalBox
---@field PanelSpent UFHorizontalBox
---@field RichTextBoxDesc URichTextBox
---@field RightBtnOp CommBtnLView
---@field SpacerMid USpacer
---@field TextSpentTotal UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeTipsWinView = LuaClass(UIView, true)

function WardrobeTipsWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm2FrameS_UIBP = nil
	--self.ImgSpent = nil
	--self.LeftBtnOp = nil
	--self.MoneySlot = nil
	--self.Panel2Btns = nil
	--self.PanelSpent = nil
	--self.RichTextBoxDesc = nil
	--self.RightBtnOp = nil
	--self.SpacerMid = nil
	--self.TextSpentTotal = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeTipsWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameS_UIBP)
	self:AddSubView(self.LeftBtnOp)
	self:AddSubView(self.MoneySlot)
	self:AddSubView(self.RightBtnOp)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeTipsWinView:OnInit()

end

function WardrobeTipsWinView:OnDestroy()
end

function WardrobeTipsWinView:OnShow()
	self:UpdateView(self.Params)
	self.MoneySlot:UpdateView(ProtoRes.SCORE_TYPE.SCORE_TYPE_STAMPS, true, nil, true)

	self.Comm2FrameS_UIBP:SetTitleText(_G.LSTR(1080045))
	self.LeftBtnOp:SetText(_G.LSTR(10003))
	self.RightBtnOp:SetText(_G.LSTR(10002))
end

function WardrobeTipsWinView:OnHide()

end

function WardrobeTipsWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.LeftBtnOp, 			self.OnBtnClickL)
	UIUtil.AddOnClickedEvent(self, self.RightBtnOp, 		self.OnBtnClickR)
end

function WardrobeTipsWinView:OnRegisterGameEvent()
end

function WardrobeTipsWinView:OnRegisterBinder()
end

function WardrobeTipsWinView:UpdateView(Info)
	if nil == Info then
		return
	end

	self.View = Info.UIView

	self.RichTextBoxDesc:SetText(Info.Message or "")


	if (Info.CloseBtnCallback ~= nil) then
		self.BtnClose:SetCallback(self, Info.CloseBtnCallback)
	end

	if Info.Params.CostNum and Info.Params.CostItemID then
		UIUtil.SetIsVisible(self.PanelSpent, true)
		UIUtil.SetIsVisible(self.MoneySlot, true)
		local Icon = _G.ScoreMgr:GetScoreIconName(Info.Params.CostItemID)--GetItemIcon(self.Params.CostItemID)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgSpent, Icon)
		-- local Num = ItemUtil.GetItemName(Info.Params.CostItemID)
		local ReqNum = Info.Params.CostNum
		self.TextSpentTotal:SetText(ReqNum)
		local Num =  _G.ScoreMgr:GetScoreValueByID(Info.Params.CostItemID)
		local IsSucc = 	Num >= ReqNum
		local Color = IsSucc and NumColor.Succ or NumColor.Fail
		UIUtil.SetColorAndOpacityHex(self.TextSpentTotal, Color)
		-- self.RightBtnOp:SetColorType( IsSucc and CommBtnColorType.Recommend or  CommBtnColorType.Normal )
		self.LeftBtnOp:SetIsDisabledState(true, true)
		if IsSucc then
			self.RightBtnOp:SetIsNormalState(true)
		else
			self.RightBtnOp:SetIsDisabledState(true, true)
		end
		-- self.MoneySlot:UpdateView(Info.Params.CostItemID, false, nil, true)
	end

	
end

function WardrobeTipsWinView:OnBtnClickL()
	local Params = self.Params
	if Params ~= nil then
		local Callback = Params.LeftCB
		local UIView = Params.View
		if Callback ~= nil then
			Callback(UIView)
		end
	end
	self:Hide()
end

function WardrobeTipsWinView:OnBtnClickR()
	local Params = self.Params
	if Params ~= nil then
		local Callback = Params.RightCB
		local UIView = Params.View
		if Callback ~= nil then
			Callback(UIView)
			
		end
	end
	self:Hide()
end

return WardrobeTipsWinView