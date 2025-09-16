---
--- Author: Administrator
--- DateTime: 2024-06-21 20:38
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local LSTR = _G.LSTR
local JumpUtil = require("Utils/JumpUtil")
---@class MarketIncreaseWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel CommBtnLView
---@field BtnGoto CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field RichTextCurrentQuantity URichTextBox
---@field RichTextHint URichTextBox
---@field RichTextincreaseto URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MarketIncreaseWinView = LuaClass(UIView, true)

function MarketIncreaseWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.BtnGoto = nil
	--self.Comm2FrameM_UIBP = nil
	--self.RichTextCurrentQuantity = nil
	--self.RichTextHint = nil
	--self.RichTextincreaseto = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MarketIncreaseWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnGoto)
	self:AddSubView(self.Comm2FrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MarketIncreaseWinView:OnInit()

end

function MarketIncreaseWinView:OnDestroy()

end

function MarketIncreaseWinView:OnShow()

end

function MarketIncreaseWinView:OnHide()

end

function MarketIncreaseWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel.Button, self.OnClickedBtnCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnGoto.Button, self.OnClickedBtnGoto)
end

function MarketIncreaseWinView:OnRegisterGameEvent()

end

function MarketIncreaseWinView:OnRegisterBinder()
	self.Comm2FrameM_UIBP:SetTitleText(LSTR(1010058))
	self.RichTextCurrentQuantity:SetText(LSTR(1010059))
	self.RichTextincreaseto:SetText(LSTR(1010060))
	self.RichTextHint:SetText(LSTR(1010061))
	self.BtnCancel:SetText(LSTR(10003))
	self.BtnGoto:SetText(LSTR(1010062))
end

function MarketIncreaseWinView:OnClickedBtnCancel()
	self:Hide()
end

function MarketIncreaseWinView:OnClickedBtnGoto()
	if not _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMonthCard) then
		_G.MsgTipsUtil.ShowTips(LSTR(1010033))
		return
	end
	local ProtoRes = require("Protocol/ProtoRes")
	if not _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_MONTHLY_CARD) then
		_G.MsgTipsUtil.ShowTips(LSTR(1010033))
		return
	end

	_G.OpsActivityMgr:JumpToMonthCard()
	self:Hide()
end

return MarketIncreaseWinView