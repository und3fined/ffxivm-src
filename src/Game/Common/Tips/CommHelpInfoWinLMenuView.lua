---
--- Author: Administrator
--- DateTime: 2023-11-06 09:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local CommHelpInfoWinLMenuVM =  require("Game/Common/Tips/VM/CommHelpInfoWinLMenuVM")

---@class CommHelpInfoWinLMenuView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field CheckBoxNoReminder CommSingleBoxView
---@field LeftBtnOp CommBtnLView
---@field Menu CommMenuView
---@field Panel2Btns UFHorizontalBox
---@field RightBtnOp CommBtnLView
---@field SizeBox USizeBox
---@field SpacerMid USpacer
---@field TableViewContent UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommHelpInfoWinLMenuView = LuaClass(UIView, true)

function CommHelpInfoWinLMenuView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.CheckBoxNoReminder = nil
	--self.LeftBtnOp = nil
	--self.Menu = nil
	--self.Panel2Btns = nil
	--self.RightBtnOp = nil
	--self.SizeBox = nil
	--self.SpacerMid = nil
	--self.TableViewContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommHelpInfoWinLMenuView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.CheckBoxNoReminder)
	self:AddSubView(self.LeftBtnOp)
	self:AddSubView(self.Menu)
	self:AddSubView(self.RightBtnOp)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommHelpInfoWinLMenuView:OnInit()
	self.VM = CommHelpInfoWinLMenuVM.New()
	self.AdapterContentList = UIAdapterTableView.CreateAdapter(self, self.TableViewContent)
end

function CommHelpInfoWinLMenuView:OnDestroy()
end

function CommHelpInfoWinLMenuView:OnShow()
	UIUtil.SetIsVisible(self.Panel2Btns, false)
	UIUtil.SetIsVisible(self.CheckBoxNoReminder, false)

	if self.Params then
		self.VM:InitVM(self.Params)
		self.Menu:UpdateItems(self.Params.MenuList)
		self.Menu:SetSelectedIndex(1)
	end

end

function CommHelpInfoWinLMenuView:OnHide()

end

function CommHelpInfoWinLMenuView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.Menu, self.OnTabItemSelectChanged)
end

function CommHelpInfoWinLMenuView:OnRegisterGameEvent()

end

function CommHelpInfoWinLMenuView:OnRegisterBinder()
	local Binders = {
		{"Title", UIBinderSetText.New(self, self.BG.FText_Title)},
		{"TableViewContentList", UIBinderUpdateBindableList.New(self, self.AdapterContentList)},
	}

	self:RegisterBinders(self.VM, Binders)
end

function CommHelpInfoWinLMenuView:OnTabItemSelectChanged(Index)
	if self.VM == nil then
		return
	end

	self.VM:UpdateContentList(Index)
end



return CommHelpInfoWinLMenuView