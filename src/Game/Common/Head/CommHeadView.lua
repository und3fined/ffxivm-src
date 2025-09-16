---
--- Author: anypkvcai
--- DateTime: 2022-04-27 11:00
--- Description
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PersonPortraitHeadHelper = require("Game/PersonPortraitHead/PersonPortraitHeadHelper")
local MajorUtil = require("Utils/MajorUtil")

---@class CommHeadView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field HeadSize USizeBox
---@field IconSilhouette UFImage
---@field ImageIcon UImage
---@field ImgNormalFrame UFImage
---@field ImgFrame UFImage
---@field SpecialFrameSize USizeBox
---@field HeadSide CommHeadSize
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommHeadView = LuaClass(UIView, true)

function CommHeadView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClick = nil
	--self.HeadSize = nil
	--self.IconSilhouette = nil
	--self.ImageIcon = nil
	--self.ImgNormalFrame = nil
	--self.ImgFrame = nil
	--self.SpecialFrameSize = nil
	--self.HeadSide = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommHeadView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommHeadView:OnInit()
	self.IsHideFrame = false
end

function CommHeadView:OnDestroy()

end

function CommHeadView:OnShow()
	UIUtil.SetIsVisible(self.BtnClick, self.IsTriggerClick == true, true)
end

function CommHeadView:OnHide()
	self.Source = nil
	self.RoleVM = nil
end

function CommHeadView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnClickButtonClick)
end

function CommHeadView:OnRegisterGameEvent()

end

function CommHeadView:OnRegisterBinder()

end

-------------------------------------------------------------------------------------------------------
--- inf

---@param RoleID number @角色ID 
---@param Source PersonInfoDefine.SimpleViewSource @来源，默认SimpleViewSource.Default
function CommHeadView:SetInfo(RoleID, Source)

	self.RoleID = RoleID
	self:UpdateIcon(RoleID)
	self:UpdateFrame(RoleID)
	self.Source = Source

	local IsMajor = MajorUtil.GetMajorRoleID() == RoleID

	UIUtil.SetIsVisible(self.BtnClick, IsMajor, true)
end

---@param RoleID number @角色ID 
---@param Source PersonInfoDefine.SimpleViewSource @来源，默认SimpleViewSource.Default
function CommHeadView:SetBaseInfo(RoleID, Source)
	self.RoleID = RoleID
	self.Source = Source
end

-- 兼容之前版本
function CommHeadView:SetIcon( HeadIcon, IsGrey )
	if HeadIcon then
		UIUtil.ImageSetMaterialTextureFromAssetPathSync(self.ImageIcon, HeadIcon, "Texture")
	end

	self:SetIsGreyIcon(IsGrey)
end

function CommHeadView:SetClickCB( CB )
    self.CustCB = CB
end

function CommHeadView:SetClickEnable( Val )
    UIUtil.SetIsVisible(self.BtnClick, Val, true)
end

function CommHeadView:SetIsGreyIcon( IsGrey )
	UIUtil.SetImageDesaturate(self.ImageIcon, nil, IsGrey and 1 or 0)
end


-------------------------------------------------------------------------------------------------------
--- inner

function CommHeadView:GetRoleVM(RoleID)
	RoleID = RoleID or self.RoleID
	local RoleVM = (self.Params or {}).ViewModel or _G.RoleInfoMgr:FindRoleVM(RoleID)
	self.RoleVM = RoleVM
	return RoleVM
end

function CommHeadView:UpdateIcon(RoleID, IsGrey)
	local RoleVM = self:GetRoleVM(RoleID)
	if nil == RoleVM  then
		_G.FLOG_ERROR('[PersonHead] CommHeadView:UpdateIcon RoleVM = nil')
		return
	end

	PersonPortraitHeadHelper.SetHeadByRoleVM(self.ImageIcon, RoleVM)
	self:SetIsGreyIcon(IsGrey)
end

---@param Source PersonInfoDefine.SimpleViewSource @来源，默认SimpleViewSource.Default
function CommHeadView:SetSource(Source)
	self.Source = Source
end

function CommHeadView:UpdateFrame(RoleID, IsGrey)
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

	local IsDefault = HeadFrameID == 1

	if not IsDefault then
		PersonPortraitHeadHelper.SetFrame(self.ImgFrame, HeadFrameID)
	end

	UIUtil.SetIsVisible(self.ImgNormalFrame, IsDefault and (not self.IsHideFrame))
	UIUtil.SetIsVisible(self.ImgFrame, not IsDefault and (not self.IsHideFrame))
end

function CommHeadView:SetIsTriggerClick(IsTriggerClick)
	self.IsTriggerClick = IsTriggerClick
end

function CommHeadView:SetIsHideFrame( V )
	self.IsHideFrame = V
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function CommHeadView:OnClickButtonClick()
	if nil == self.RoleVM or nil == self.RoleVM.RoleID then
		return
	end

	if self.CustCB and type(self.CustCB) == "function" then
		self.CustCB()
		return
	end

	_G.PersonInfoMgr:ShowPersonalSimpleInfoView(self.RoleVM.RoleID, self.Source)
end

return CommHeadView