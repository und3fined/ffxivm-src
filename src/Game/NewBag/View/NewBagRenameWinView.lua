---
--- Author: Administrator
--- DateTime: 2023-09-07 19:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local DepotVM = require("Game/Depot/DepotVM")

local UIAdapterToggleGroup = require("UI/Adapter/UIAdapterToggleGroup")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetCheckedIndex = require("Binder/UIBinderSetCheckedIndex")
local DepotRenameWinVM = require("Game/NewBag/VM/DepotRenameWinVM")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UTF8Util = require("Utils/UTF8Util")
local DepotMgr = _G.DepotMgr
local MAX_NAME_LENGTH = 8

local LSTR = _G.LSTR
---@class NewBagRenameWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRename CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field InputBox CommInputBoxView
---@field TextDefault UFTextBlock
---@field TextNew UFTextBlock
---@field ToggleGroupDynamic UToggleGroupDynamic
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewBagRenameWinView = LuaClass(UIView, true)

function NewBagRenameWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRename = nil
	--self.Comm2FrameM_UIBP = nil
	--self.InputBox = nil
	--self.TextDefault = nil
	--self.TextNew = nil
	--self.ToggleGroupDynamic = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewBagRenameWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnRename)
	self:AddSubView(self.Comm2FrameM_UIBP)
	self:AddSubView(self.InputBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewBagRenameWinView:OnInit()
	self.AdapterTabToggleGroup = UIAdapterToggleGroup.CreateAdapter(self, self.ToggleGroupDynamic)
	DepotRenameWinVM:UpdateListInfo()
	self.InputBox:SetCallback(self, self.OnTextChangedName)
	self.InputBox:SetMaxNum(MAX_NAME_LENGTH)

	self.Binders = {
		{ "DepotIconBindableList", UIBinderUpdateBindableList.New(self, self.AdapterTabToggleGroup) },
		{ "CurrentIndex", UIBinderSetCheckedIndex.New(self, self.ToggleGroupDynamic) },
		{ "BtnRenameEnabled", UIBinderSetIsEnabled.New(self, self.BtnRename) },
	}
end

function NewBagRenameWinView:OnDestroy()

end

function NewBagRenameWinView:OnShow()
	self.InputBox:SetText(DepotVM.PageName)

	local ViewModel = DepotVM:FindDepotPageVM(DepotVM.CurrentPage)
	if nil ~= ViewModel then
		local Index = ViewModel.PageType
		DepotRenameWinVM:SetSelectedIndex(Index + 1)
	end
end


function NewBagRenameWinView:OnHide()

end


function NewBagRenameWinView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleGroupDynamic, self.OnToggleGroupStateChanged)
	UIUtil.AddOnClickedEvent(self, self.BtnRename, self.OnClickedRename)
end

function NewBagRenameWinView:OnRegisterGameEvent()
end

function NewBagRenameWinView:OnRegisterBinder()
	self:RegisterBinders(DepotRenameWinVM, self.Binders)

	self.TextNew:SetText(LSTR(990064))
	self.TextDefault:SetText(LSTR(990065))
	self.Comm2FrameM_UIBP:SetTitleText(LSTR(990066))
	self.BtnRename:SetButtonText(LSTR(990068))
	self.InputBox:SetHintText(LSTR(990067))
end

function NewBagRenameWinView:OnToggleGroupStateChanged(ToggleGroup, ToggleButton, Index, State)
	DepotRenameWinVM:SetSelectedIndex(Index + 1)

	local ViewModel = DepotVM:FindDepotPageVM(DepotVM.CurrentPage)
	if ViewModel == nil  then
		return
	end
	local Name = self.InputBox:GetText()
	if string.isnilorempty(Name) or (DepotVM.PageName == Name and ViewModel.PageType == DepotRenameWinVM.CurrentIndex-1)then
		DepotRenameWinVM.BtnRenameEnabled = false
	else
		DepotRenameWinVM.BtnRenameEnabled = true
	end
end

function NewBagRenameWinView:OnClickedRename()
	local Index = DepotVM:GetCurDepotIndex()
	local Name = self.InputBox:GetText()

	_G.JudgeSearchMgr:QueryTextIsLegal(Name, function( IsLegal )
		if not IsLegal then
			_G.MsgTipsUtil.ShowTips(LSTR(10057)) 
			self.InputBox:SetText("")
		else
			DepotMgr:SendMsgDepotRename(Index, DepotRenameWinVM.CurrentIndex - 1, Name)
			self:Hide()
		end
	end)

	
end

function NewBagRenameWinView:OnTextChangedName(Text)
	local ViewModel = DepotVM:FindDepotPageVM(DepotVM.CurrentPage)
	if ViewModel == nil  then
		return
	end

	if string.isnilorempty(Text) or (DepotVM.PageName == Text and ViewModel.PageType == DepotRenameWinVM.CurrentIndex-1)then
		DepotRenameWinVM.BtnRenameEnabled = false
	else
		DepotRenameWinVM.BtnRenameEnabled = true
	end

end

return NewBagRenameWinView