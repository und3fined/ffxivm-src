---
--- Author: Administrator
--- DateTime: 2024-09-06 20:52
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local NewBagRecycleWinVM = require("Game/NewBag/VM/NewBagRecycleWinVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local LSTR = _G.LSTR
---@class NewBagRecycleWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel CommBtnLView
---@field BtnUse CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field RichTextHint URichTextBox
---@field TableViewMultiLineItem UTableView
---@field TableViewSingleLineItem UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewBagRecycleWinView = LuaClass(UIView, true)

function NewBagRecycleWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.BtnUse = nil
	--self.Comm2FrameM_UIBP = nil
	--self.RichTextHint = nil
	--self.TableViewMultiLineItem = nil
	--self.TableViewSingleLineItem = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewBagRecycleWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnUse)
	self:AddSubView(self.Comm2FrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewBagRecycleWinView:OnInit()
	self.MultiTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewMultiLineItem)
	self.SingleTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSingleLineItem)

	self.Binders = {
		{ "MultiTableBindableList", UIBinderUpdateBindableList.New(self, self.MultiTableViewAdapter) },
		{ "SingleTableBindableList", UIBinderUpdateBindableList.New(self, self.SingleTableViewAdapter) },
		{ "TipsText", UIBinderSetText.New(self, self.RichTextHint) },
		{ "MultiItemVisible", UIBinderSetIsVisible.New(self, self.TableViewMultiLineItem) },
		{ "SingleItemVisible", UIBinderSetIsVisible.New(self, self.TableViewSingleLineItem) },
	}
end

function NewBagRecycleWinView:OnDestroy()

end

function NewBagRecycleWinView:OnShow()
	if nil == self.Params then
		return
	end

	NewBagRecycleWinVM:UpdateVM(self.Params)
	if not string.isnilorempty(self.Params.Title) then
		self.Comm2FrameM_UIBP:SetTitleText(self.Params.Title)
	end
end

function NewBagRecycleWinView:OnHide()

end

function NewBagRecycleWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel.Button, self.OnClickedCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnUse.Button, self.OnClickedOK)
end

function NewBagRecycleWinView:OnRegisterGameEvent()

end

function NewBagRecycleWinView:OnRegisterBinder()
	self:RegisterBinders(NewBagRecycleWinVM, self.Binders)

	self.Comm2FrameM_UIBP:SetTitleText(LSTR(990047))
	self.BtnCancel:SetButtonText(LSTR(10003))
	self.BtnUse:SetButtonText(LSTR(10002))
end

function NewBagRecycleWinView:OnClickedCancel()
	self:Hide()
end


function NewBagRecycleWinView:OnClickedOK()
	self:Hide()
	if nil == self.Params then
		return
	end

	local ClickedOkAction = self.Params.ClickedOkAction
	if ClickedOkAction ~= nil then
		ClickedOkAction()
	end
end

return NewBagRecycleWinView