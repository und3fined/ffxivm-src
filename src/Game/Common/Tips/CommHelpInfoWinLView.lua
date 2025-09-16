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
	UIUtil.SetIsVisible(self.Panel2Btns, false)
	UIUtil.SetIsVisible(self.CheckBoxNoReminder, false)

	if self.Params and self.Params.Cfgs then
		self.VM:InitVM(self.Params.Cfgs)
	end
end

function CommHelpInfoWinLView:OnHide()
end

function CommHelpInfoWinLView:OnRegisterUIEvent()
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

return CommHelpInfoWinLView