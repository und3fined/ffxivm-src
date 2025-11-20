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

---@class CommHelpInfoWinLView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field CheckBoxNoReminder CommSingleBoxView
---@field CommMoneyBar CommMoneyBarView
---@field CommTipsBtn1 CommTipsBtnItemView
---@field CommTipsBtn2 CommTipsBtnItemView
---@field Panel2Btns UFHorizontalBox
---@field RightBtnOp CommBtnLView
---@field SizeBox USizeBox
---@field SpacerMoneyTips USpacer
---@field TableViewContent UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommHelpInfoWinLView = LuaClass(UIView, true)

function CommHelpInfoWinLView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.CheckBoxNoReminder = nil
	--self.CommMoneyBar = nil
	--self.CommTipsBtn1 = nil
	--self.CommTipsBtn2 = nil
	--self.Panel2Btns = nil
	--self.RightBtnOp = nil
	--self.SizeBox = nil
	--self.SpacerMoneyTips = nil
	--self.TableViewContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommHelpInfoWinLView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.CheckBoxNoReminder)
	self:AddSubView(self.CommMoneyBar)
	self:AddSubView(self.CommTipsBtn1)
	self:AddSubView(self.CommTipsBtn2)
	self:AddSubView(self.RightBtnOp)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommHelpInfoWinLView:OnInit()
	self.VM = CommHelpInfoWinVM.New()
	self.TableViewContentAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewContent)
	self.Binders = {}
end

function CommHelpInfoWinLView:OnDestroy()
end

function CommHelpInfoWinLView:OnShow()
    if self.Params then
        if self.Params.Cfgs then
            self.VM:InitVM(self.Params.Cfgs)
        end
        UIUtil.SetIsVisible(self.SpacerMoneyTips, false)
        UIUtil.SetIsVisible(self.Panel2Btns, true)
        UIUtil.SetIsVisible(self.RightBtnOp, false, false)
        UIUtil.SetIsVisible(self.CheckBoxNoReminder, false, false)
        UIUtil.SetIsVisible(self.CommTipsBtn1, false, false)
        UIUtil.SetIsVisible(self.CommTipsBtn2, false, false)
        UIUtil.SetIsVisible(self.CommTipsBtn1.PanelText, false, false)
        UIUtil.SetIsVisible(self.CommTipsBtn2.PanelText, false, false)

        local ExtraParam = self.Params.ExtraParam
        if ExtraParam == nil then
            return
        end

        if ExtraParam.CheckBoxNoReminderStr ~= nil then
			self.CheckBoxNoReminder.Content = ExtraParam.CheckBoxNoReminderStr
            -- self.CheckBoxNoReminder:SetText(ExtraParam.CheckBoxNoReminderStr)
            UIUtil.SetIsVisible(self.CheckBoxNoReminder, true, true)
        end

        if ExtraParam.CommTipsBtn1Str ~= nil then
            self.CommTipsBtn1.Btn:SetBtnName(ExtraParam.CommTipsBtn1Str)
            UIUtil.SetIsVisible(self.CommTipsBtn1.PanelMoney, false)
            UIUtil.SetIsVisible(self.CommTipsBtn1, true, true)

        end
        if ExtraParam.CommTipsBtn2Str ~= nil then
            self.CommTipsBtn2.Btn:SetBtnName(ExtraParam.CommTipsBtn2Str)
            UIUtil.SetIsVisible(self.CommTipsBtn2.PanelMoney, false)
            UIUtil.SetIsVisible(self.CommTipsBtn2, true, true)
            local IsDisabledState = ExtraParam.CheckBoxNoReminderStr ~= nil and not self.CheckBoxNoReminder:GetChecked()
            self.CommTipsBtn2.Btn:SetIsDisabledState(IsDisabledState,true)
        end

        if ExtraParam.CostNum ~= nil and ExtraParam.CostItemID ~= nil then
            UIUtil.SetIsVisible(self.CommTipsBtn2.PanelMoney, true)
            self.CommTipsBtn2.Money1:SetMoneyNum(ExtraParam.CostNum)
            self.CommTipsBtn2.Money1:SetMoneyIconByID(ExtraParam.CostItemID)

            local ScoreValue = _G.ScoreMgr:GetScoreValueByID(ExtraParam.CostItemID)
            local CostColor = ScoreValue >= ExtraParam.CostNum and "FFFFFFFF" or "FF0000FF"
            local LinearColor = _G.UE.FLinearColor.FromHex(CostColor)
            if LinearColor then
                self.CommTipsBtn2.Money1:SetTextMoneyColorAndOpacity(LinearColor)
            end
            
            if ExtraParam.CheckBoxNoReminderStr then
                UIUtil.SetIsVisible(self.SpacerMoneyTips, true)
            end
        end

    end
end








function CommHelpInfoWinLView:OnHide()
end

function CommHelpInfoWinLView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommTipsBtn1.Btn, self.OnCommTipsBtn1Clicked)
	UIUtil.AddOnClickedEvent(self, self.CommTipsBtn2.Btn, self.OnCommTipsBtn2Clicked)
	UIUtil.AddOnStateChangedEvent(self, self.CheckBoxNoReminder, self.OnNoReminderChanged)
end

function CommHelpInfoWinLView:OnRegisterGameEvent()
end

function CommHelpInfoWinLView:OnRegisterBinder()
	local Binders = {
		{"TextTitle", UIBinderSetText.New(self, self.BG.FText_Title)},
		{"TableViewContentList", UIBinderUpdateBindableList.New(self, self.TableViewContentAdapter)},
	}

	self:RegisterBinders(self.VM, Binders)
end

function CommHelpInfoWinLView:OnCommTipsBtn1Clicked()
    if self.Params and self.Params.ExtraParam and self.Params.ExtraParam.Btn1Callback ~= nil then
        self.Params.Btn1Callback()
    else
        self:Hide()
    end
end

function CommHelpInfoWinLView:OnCommTipsBtn2Clicked()
    if self.Params and self.Params.ExtraParam then
        if not self.CheckBoxNoReminder:GetChecked() and self.Params.ExtraParam.NoReminderTips then
            _G.MsgTipsUtil.ShowTips(self.Params.ExtraParam.NoReminderTips)
        elseif self.Params.ExtraParam.Btn2Callback ~= nil then
            self.Params.ExtraParam.Btn2Callback(self)
        else
            self:Hide()
        end
    end
end





function CommHelpInfoWinLView:OnNoReminderChanged(ToggleButton, State)
    if self.Params and self.Params.ExtraParam then
        local IsChecked = UIUtil.IsToggleButtonChecked(State)
        if self.Params.ExtraParam.OnNoReminderChanged ~= nil then
            self.Params.OnToggleStateChanged(IsChecked)
        end
        local IsDisabledState = self.Params.ExtraParam.CheckBoxNoReminderStr ~= nil and not IsChecked
        self.CommTipsBtn2.Btn:SetIsDisabledState(IsDisabledState, true)
    end
end



return CommHelpInfoWinLView