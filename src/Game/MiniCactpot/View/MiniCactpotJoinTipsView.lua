---
--- Author: chriswang
--- DateTime: 2022-09-23 14:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

---@class MiniCactpotJoinTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG CommMsgTipsView
---@field BtnPanelSwitcher UWidgetSwitcher
---@field Button UFCanvasPanel
---@field LeftBtnTwoOp CommBtnLView
---@field LeftMoneyText URichTextBox
---@field RichTextBox_Ask URichTextBox
---@field RightBtnTwoOp CommBtnLView
---@field TwoBtnPanel UFHorizontalBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MiniCactpotJoinTipsView = LuaClass(UIView, true)

function MiniCactpotJoinTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnPanelSwitcher = nil
	--self.Button = nil
	--self.LeftBtnTwoOp = nil
	--self.LeftMoneyText = nil
	--self.RichTextBox_Ask = nil
	--self.RightBtnTwoOp = nil
	--self.TwoBtnPanel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MiniCactpotJoinTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.LeftBtnTwoOp)
	self:AddSubView(self.RightBtnTwoOp)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MiniCactpotJoinTipsView:OnInit()

end

function MiniCactpotJoinTipsView:OnDestroy()

end

function MiniCactpotJoinTipsView:OnShow()
	local CostNum = _G.MiniCactpotMgr:GetCostValue()
	local HaveNum = _G.MiniCactpotMgr:GetCurOwnCostValue()

	if HaveNum >= CostNum then
		self.LeftMoneyText:SetText(string.format(LSTR(230009), HaveNum)) -- [所持金碟币：<span color=\"#CBB995FF\">%d</>]
	else
		self.LeftMoneyText:SetText(string.format(LSTR(230010), HaveNum)) -- [所持金碟币：<span color=\"#ff0000ff\">%d</>]
	end
	self.RichTextBox_Ask:SetText(string.format(LSTR(230011), CostNum)) -- 参加仙人微彩竞猜需要%d金碟币。\n确定要参加吗？
end

function MiniCactpotJoinTipsView:OnHide()

end

function MiniCactpotJoinTipsView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.LeftBtnTwoOp.Button, self.OnBtnCancelClicked, nil)
	UIUtil.AddOnClickedEvent(self, self.RightBtnTwoOp.Button, self.OnBtnYesClicked, nil)
end

function MiniCactpotJoinTipsView:OnRegisterGameEvent()

end

function MiniCactpotJoinTipsView:OnRegisterBinder()

end

function MiniCactpotJoinTipsView:OnBtnYesClicked()
	local CoinNum = _G.MiniCactpotMgr:GetCostValue()
	local HaveNum = _G.MiniCactpotMgr:GetCurOwnCostValue()
	if CoinNum > HaveNum then
		-- local Name = _G.MiniCactpotMgr:GetCostTypeName()
		local Str = string.format(LSTR(230005)) -- 金碟币不足
		MsgTipsUtil.ShowTips(Str)

		self:OnBtnCancelClicked()
	else
		self:Hide()
		_G.MiniCactpotMgr:SendMiniCactpotEnterReq()
	end
end

--取消或者金碟币不足
function MiniCactpotJoinTipsView:OnBtnCancelClicked()
	self:Hide()
end

return MiniCactpotJoinTipsView