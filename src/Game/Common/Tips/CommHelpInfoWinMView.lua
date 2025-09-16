---
--- Author: Administrator
--- DateTime: 2023-09-13 09:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local CommHelpInfoWinVM =  require("Game/Common/Tips/VM/CommHelpInfoWinVM")
local UIDefine = require("Define/UIDefine")
local CommBtnColorType = UIDefine.CommBtnColorType

---@class CommHelpInfoWinMView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field CheckBoxNoReminder CommSingleBoxView
---@field CommMoneyBar CommMoneyBarView
---@field CommTipsBtn1 CommTipsBtnItemView
---@field CommTipsBtn2 CommTipsBtnItemView
---@field Panel2Btns UFHorizontalBox
---@field SizeBox USizeBox
---@field SpacerMoneyTips USpacer
---@field TableViewContent UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommHelpInfoWinMView = LuaClass(UIView, true)

function CommHelpInfoWinMView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.CheckBoxNoReminder = nil
	--self.CommMoneyBar = nil
	--self.CommTipsBtn1 = nil
	--self.CommTipsBtn2 = nil
	--self.Panel2Btns = nil
	--self.SizeBox = nil
	--self.SpacerMoneyTips = nil
	--self.TableViewContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommHelpInfoWinMView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.CheckBoxNoReminder)
	self:AddSubView(self.CommMoneyBar)
	self:AddSubView(self.CommTipsBtn1)
	self:AddSubView(self.CommTipsBtn2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommHelpInfoWinMView:OnInit()
	self.VM = CommHelpInfoWinVM.New()
	self.TableViewContentAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewContent)
	self.Binders = {}
	self.LeftBtnOp = self.CommTipsBtn1.Btn
	self.RightBtnOp = self.CommTipsBtn2.Btn
end

function CommHelpInfoWinMView:OnDestroy()
end

function CommHelpInfoWinMView:OnShow()
	local Params = self.Params or {}
	UIUtil.SetIsVisible(self.Panel2Btns, Params.ShowBtn == true )
	UIUtil.SetIsVisible(self.CommTipsBtn1, Params.ShowBtn == true )
	UIUtil.SetIsVisible(self.CommTipsBtn2, Params.ShowBtn == true )
	UIUtil.SetIsVisible(self.CheckBoxNoReminder, false)
	-- 先暂时隐藏  等后面CommTipsBtnItemView处理了 再调接口
	UIUtil.SetIsVisible(self.CommMoneyBar, Params.MoneyElement == true)
	UIUtil.SetIsVisible(self.CommTipsBtn1.PanelMoney, Params.MoneyElement == true)
	UIUtil.SetIsVisible(self.CommTipsBtn2.PanelMoney, Params.MoneyElement == true)
	UIUtil.SetIsVisible(self.CommTipsBtn1.PanelText, Params.MoneyElement == true)
	UIUtil.SetIsVisible(self.CommTipsBtn2.PanelText, Params.MoneyElement == true)

	if Params.IsMentorResign then
		self.LeftBtnOp:SetIsNormalState(true)
	end
	
	if Params.LeftBtnText ~= nil then
		self.LeftBtnOp:SetText(Params.LeftBtnText)
	end
	if Params.RightBtnText ~= nil then
		self.RightBtnOp:SetText(Params.RightBtnText)
	end
	if Params.RightBtnCB ~= nil then
		self.RightBtnCB = Params.RightBtnCB
	end
	if Params.LeftBtnCB ~= nil then
		self.LeftBtnCB = Params.LeftBtnCB
	end
	if Params.CloseBtnCB ~= nil then
		self.CloseBtnCB = Params.CloseBtnCB
	end
	if Params.View ~= nil then
		self.View = Params.View
	end
	if self.Params and self.Params.Cfgs then
		self.VM:InitVM(self.Params.Cfgs)
	end

	if self.Params and self.Params.WarningText then
		UIUtil.SetIsVisible(self.CommTipsBtn2.PanelText, true)
		self.CommTipsBtn2.RichTextTips:SetText(self.Params.WarningText)
	end

	if self.Params and self.Params.CostNum and self.Params.CostItemID then
		UIUtil.SetIsVisible(self.CommTipsBtn2.PanelMoney, true)
		self.CommTipsBtn2.Money1:SetMoneyNum(self.Params.CostNum)
		self.CommTipsBtn2.Money1:SetMoneyIconByID(self.Params.CostItemID)
		if self.Params.CostColor then
			local LinearColor = _G.UE.FLinearColor.FromHex(self.Params.CostColor)
			if LinearColor then
				self.CommTipsBtn2.Money1:SetTextMoneyColorAndOpacity(LinearColor)
			end
		end
	end

	if self.Params and self.Params.RightBtnOpState then
		self:SetBtnTypeByState(self.RightBtnOp, self.Params.RightBtnOpState)
	end
	if self.Params and self.Params.LeftBtnOpState then
		self:SetBtnTypeByState(self.LeftBtnOp, self.Params.LeftBtnOpState)
	end
end

function CommHelpInfoWinMView:SetBtnTypeByState(Widget, State)
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

function CommHelpInfoWinMView:OnHide()

end

function CommHelpInfoWinMView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.LeftBtnOp, self.OnClickLeftBtnOp)
	UIUtil.AddOnClickedEvent(self, self.RightBtnOp, self.OnClickRightBtnOp)
	UIUtil.AddOnClickedEvent(self, self.BG.ButtonClose, self.OnClickCloseBtn)
end

function CommHelpInfoWinMView:OnClickLeftBtnOp()
	if self.LeftBtnCB ~= nil then
		self.LeftBtnCB(self.View)
	end 
end

function CommHelpInfoWinMView:OnClickRightBtnOp()
	if self.RightBtnCB ~= nil then
		self.RightBtnCB(self.View)
	end 
end

function CommHelpInfoWinMView:OnClickCloseBtn()
	if self.CloseBtnCB ~= nil then
		self.CloseBtnCB(self.View)
	end 
end

function CommHelpInfoWinMView:OnRegisterGameEvent()

end

function CommHelpInfoWinMView:OnRegisterBinder()
	local Binders = {
		{"TextTitle", UIBinderSetText.New(self, self.BG.FText_Title)},
		{"TableViewContentList", UIBinderUpdateBindableList.New(self, self.TableViewContentAdapter)},
	}

	self:RegisterBinders(self.VM, Binders)
end

return CommHelpInfoWinMView