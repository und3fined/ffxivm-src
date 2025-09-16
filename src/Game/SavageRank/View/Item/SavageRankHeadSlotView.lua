---
--- Author: Administrator
--- DateTime: 2024-12-25 15:56
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetProfIconSimple2nd = require("Binder/UIBinderSetProfIconSimple2nd")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MajorUtil = require("Utils/MajorUtil")
local PersonInfoVM = require("Game/PersonInfo/VM/PersonInfoVM")


---@class SavageRankHeadSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommPlayerHeadSlot CommPlayerHeadSlotView
---@field ImgJobIcon UFImage
---@field PanelJob UFCanvasPanel
---@field PanelSelect UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SavageRankHeadSlotView = LuaClass(UIView, true)

function SavageRankHeadSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommPlayerHeadSlot = nil
	--self.ImgJobIcon = nil
	--self.PanelJob = nil
	--self.PanelSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SavageRankHeadSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommPlayerHeadSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SavageRankHeadSlotView:OnInit()
	self.Binders = {
		{ "Prof",  UIBinderSetProfIconSimple2nd.New(self, self.ImgJobIcon) },
		{ "IsSelect", UIBinderSetIsVisible.New(self, self.PanelSelect) },	
	}

	self.BindersRoleVM = {
		{ "HeadInfo", 	UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedHeadInfo) },
		{ "HeadFrameID", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedHeadFrameID) },
	}
	self.CommPlayerHeadSlot:SetIsTriggerClick(true)
end

function SavageRankHeadSlotView:OnDestroy()

end

function SavageRankHeadSlotView:OnShow()
	local function SetHeadClick()
		local MajorRoleID = MajorUtil.GetMajorRoleID()
		if MajorRoleID == self.ViewModel.RoleID then
			--自身头像不可点击
			MsgTipsUtil.ShowTipsByID(356001)
		else
			_G.PersonInfoMgr:ShowPersonalSimpleInfoView(self.ViewModel.RoleID)
		end
	end

	self.CommPlayerHeadSlot:SetClickCB(SetHeadClick)
end

function SavageRankHeadSlotView:OnHide()

end

function SavageRankHeadSlotView:OnRegisterUIEvent()

end

function SavageRankHeadSlotView:OnRegisterGameEvent()

end

function SavageRankHeadSlotView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end
	self.ViewModel = ViewModel
	local RoleID = ViewModel.RoleID
	if RoleID then
		_G.RoleInfoMgr:QueryRoleSimple(RoleID, function(_, RoleVM)
			PersonInfoVM:UpdateRoleInfo(RoleVM)
		end, nil, false)
		self.CommPlayerHeadSlot:SetInfo(RoleID)
	end
	local RoleVM = _G.RoleInfoMgr:FindRoleVM(RoleID)
	if RoleVM then
		self:RegisterBinders(RoleVM, self.BindersRoleVM)
	end
	self:RegisterBinders(ViewModel, self.Binders)
end

-- function SavageRankHeadSlotView:OnValueChangedHead(NewValue)
-- 	local RoleID = NewValue
-- 	self.CommPlayerHeadSlot:SetBaseInfo(RoleID)
-- end

function SavageRankHeadSlotView:OnValueChangedHeadInfo(NewValue)
	if NewValue then
		self.CommPlayerHeadSlot:UpdateIcon()
	end
end

function SavageRankHeadSlotView:OnValueChangedHeadFrameID(NewValue)
	self.CommPlayerHeadSlot:UpdateFrame()
end


return SavageRankHeadSlotView