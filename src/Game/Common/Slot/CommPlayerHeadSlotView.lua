---
--- Author: anypkvcai
--- DateTime: 2022-04-27 11:00
--- Description
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PersonPortraitHeadHelper = require("Game/PersonPortraitHead/PersonPortraitHeadHelper")

---@class CommPlayerHeadSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field ImageIcon UImage
---@field ImgBkg UFImage
---@field ImgFrame UFImage
---@field TextLevel UTextBlock
---@field IsTriggerClick bool
---@field IsHideBg bool
---@field IsHideFrame bool
---@field IsHideLevel bool
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommPlayerHeadSlotView = LuaClass(UIView, true)

function CommPlayerHeadSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClick = nil
	--self.ImageIcon = nil
	--self.ImgBkg = nil
	--self.ImgFrame = nil
	--self.TextLevel = nil
	--self.IsTriggerClick = nil
	--self.IsHideBg = nil
	--self.IsHideFrame = nil
	--self.IsHideLevel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommPlayerHeadSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommPlayerHeadSlotView:OnInit()

end

function CommPlayerHeadSlotView:OnDestroy()

end

function CommPlayerHeadSlotView:OnShow()
	UIUtil.SetIsVisible(self.BtnClick, self.IsTriggerClick == true, true)
end

function CommPlayerHeadSlotView:OnHide()
	self.Source = nil
	self.RoleVM = nil
end

function CommPlayerHeadSlotView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnClickButtonClick)
end

function CommPlayerHeadSlotView:OnRegisterGameEvent()

end

function CommPlayerHeadSlotView:OnRegisterBinder()

end

-------------------------------------------------------------------------------------------------------
--- inf

---@param RoleID number @角色ID 
---@param Source PersonInfoDefine.SimpleViewSource @来源，默认SimpleViewSource.Default
function CommPlayerHeadSlotView:SetInfo(RoleID, Source)

	self.RoleID = RoleID
	self:UpdateIcon(RoleID)
	self:UpdateFrame(RoleID)
	self.Source = Source
end

---@param RoleID number @角色ID 
---@param Source PersonInfoDefine.SimpleViewSource @来源，默认SimpleViewSource.Default
function CommPlayerHeadSlotView:SetBaseInfo(RoleID, Source)
	self.RoleID = RoleID
	self.Source = Source
end

-- 兼容之前版本
function CommPlayerHeadSlotView:SetIcon( HeadIcon, IsGrey )
	if HeadIcon then
		UIUtil.ImageSetMaterialTextureFromAssetPathSync(self.ImageIcon, HeadIcon, "Texture")
	end

	self:SetIsGreyIcon(IsGrey)
end

function CommPlayerHeadSlotView:SetClickCB( CB )
    self.CustCB = CB
end

function CommPlayerHeadSlotView:SetClickEnable( Val )
    UIUtil.SetIsVisible(self.BtnClick, Val, true)
end

function CommPlayerHeadSlotView:SetIsGreyIcon( IsGrey )
	UIUtil.SetImageDesaturate(self.ImageIcon, nil, IsGrey and 1 or 0)
end


-------------------------------------------------------------------------------------------------------
--- inner

function CommPlayerHeadSlotView:GetRoleVM(RoleID)
	RoleID = RoleID or self.RoleID
	local RoleVM = (self.Params or {}).ViewModel or _G.RoleInfoMgr:FindRoleVM(RoleID)
	self.RoleVM = RoleVM
	return RoleVM
end

function CommPlayerHeadSlotView:UpdateIcon(RoleID, IsGrey)
	local RoleVM = self:GetRoleVM(RoleID)
	if nil == RoleVM  then
		_G.FLOG_ERROR('[PersonHead] CommPlayerHeadSlotView:UpdateIcon RoleVM = nil')
		return
	end

	PersonPortraitHeadHelper.SetHeadByRoleVM(self.ImageIcon, RoleVM)
	self:SetIsGreyIcon(IsGrey)
end

---@param Source PersonInfoDefine.SimpleViewSource @来源，默认SimpleViewSource.Default
function CommPlayerHeadSlotView:SetSource(Source)
	self.Source = Source
end

function CommPlayerHeadSlotView:UpdateFrame(RoleID, IsGrey)
	if self.IsHideFrame then
		return
	end

	local RoleVM = self:GetRoleVM(RoleID)
	if nil == RoleVM then
		return
	end

	local HeadFrameID = RoleVM.HeadFrameID
	if HeadFrameID == 0 then
		HeadFrameID = 1
	end

	PersonPortraitHeadHelper.SetFrame(self.ImgFrame, HeadFrameID or 1)
end

function CommPlayerHeadSlotView:SetIsTriggerClick(IsTriggerClick)
	self.IsTriggerClick = IsTriggerClick
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function CommPlayerHeadSlotView:OnClickButtonClick()
	if nil == self.RoleVM or nil == self.RoleVM.RoleID then
		return
	end

	if self.CustCB and type(self.CustCB) == "function" then
		self.CustCB()
		return
	end

	_G.PersonInfoMgr:ShowPersonalSimpleInfoView(self.RoleVM.RoleID, self.Source)
end

return CommPlayerHeadSlotView
