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
	local ExtraParam = Params.ExtraParam or {}
	UIUtil.SetIsVisible(self.Panel2Btns, Params.ShowBtn == true or ExtraParam.ShowBtn == true)
	UIUtil.SetIsVisible(self.CommTipsBtn1, Params.ShowBtn == true or ExtraParam.ShowBtn == true)
	UIUtil.SetIsVisible(self.CommTipsBtn2, Params.ShowBtn == true or ExtraParam.ShowBtn == true)
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
	
	if Params.LeftBtnText or ExtraParam.CommTipsBtn1Str then
		self.LeftBtnOp:SetText(Params.LeftBtnText or ExtraParam.CommTipsBtn1Str)
	end
	if Params.RightBtnText or ExtraParam.CommTipsBtn2Str then
		self.RightBtnOp:SetText(Params.RightBtnText or ExtraParam.CommTipsBtn2Str)
	end
	if Params.RightBtnCB or ExtraParam.Btn2Callback then
		self.RightBtnCB = Params.RightBtnCB or ExtraParam.Btn2Callback
	end
	if Params.LeftBtnCB or ExtraParam.Btn1Callback  then
		self.LeftBtnCB = Params.LeftBtnCB or ExtraParam.Btn1Callback 
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

	local CostNum = Params.CostNum or ExtraParam.CostNum
	local CostItemID = Params.CostItemID or ExtraParam.CostItemID
	local CostColor = Params.CostColor or ExtraParam.CostColor
	if CostNum and CostItemID then
		UIUtil.SetIsVisible(self.CommTipsBtn2.PanelMoney, true)
		self.CommTipsBtn2.Money1:SetMoneyNum(CostNum)
		self.CommTipsBtn2.Money1:SetMoneyIconByID(CostItemID)
		if CostColor then
			local LinearColor = _G.UE.FLinearColor.FromHex(CostColor)
			if LinearColor then
				self.CommTipsBtn2.Money1:SetTextMoneyColorAndOpacity(LinearColor)
			end
		end
	end

	local RightBtnOpState = Params.RightBtnOpState or ExtraParam.RightBtnOpState
	if RightBtnOpState then
		self:SetBtnTypeByState(self.RightBtnOp, RightBtnOpState)
	end

	local LeftBtnOpState = Params.LeftBtnOpState or ExtraParam.LeftBtnOpState
	if LeftBtnOpState then
		self:SetBtnTypeByState(self.LeftBtnOp, LeftBtnOpState)
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