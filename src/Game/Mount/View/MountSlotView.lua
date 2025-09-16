---
--- Author: chunfengluo
--- DateTime: 2023-08-03 11:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MountVM = require("Game/Mount/VM/MountVM")
local ProtoCS = require("Protocol/ProtoCS")
local MountCustomMadeVM = require("Game/Mount/VM/MountCustomMadeVM")

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class MountSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSlot UFButton
---@field ImgEmpty UFImage
---@field ImgFavorite UFImage
---@field ImgHide UImage
---@field ImgIcon UFImage
---@field ImgMask UFImage
---@field ImgNew UFImage
---@field ImgQuality UFImage
---@field ImgSelect UFImage
---@field ImgWearable UFImage
---@field PanelMount UFCanvasPanel
---@field RedDot CommonRedDotView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MountSlotView = LuaClass(UIView, true)

function MountSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSlot = nil
	--self.ImgEmpty = nil
	--self.ImgFavorite = nil
	--self.ImgHide = nil
	--self.ImgIcon = nil
	--self.ImgMask = nil
	--self.ImgNew = nil
	--self.ImgQuality = nil
	--self.ImgSelect = nil
	--self.ImgWearable = nil
	--self.PanelMount = nil
	--self.RedDot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MountSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MountSlotView:OnInit()
	self.Binders = {
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon, true) },
		{ "IsChecked", UIBinderSetIsVisible.New(self, self.ImgWearable) },
		{ "IsSelect", UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "IsMountLike", UIBinderSetIsVisible.New(self, self.ImgFavorite) },
		{ "IsMountNotOwn", UIBinderSetIsVisible.New(self, self.ImgMask) },
		{ "IsMountStory", UIBinderSetIsVisible.New(self, self.ImgHide) },
		{ "IsShowIcon", UIBinderSetIsVisible.New(self, self.ImgIcon) },
		{ "IconColor", UIBinderSetColorAndOpacityHex.New(self, self.ImgIcon) },
		{ "IsShowRedPoint", UIBinderValueChangedCallback.New(self, nil, self.OnRedPointChange)},
		{ "RedPointType", UIBinderValueChangedCallback.New(self, nil, self.OnRedPointTypeChange)},
	}
end

function MountSlotView:OnDestroy()

end

function MountSlotView:OnShow()
	--UIUtil.SetIsVisible(self.ImgIcon, true)
	UIUtil.SetIsVisible(self, true)
	UIUtil.SetIsVisible(self.BtnSlot, true, true)
	self.RedDot:SetRedDotText(LSTR("10030"))
end

function MountSlotView:OnHide()

end

function MountSlotView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSlot, self.OnClickButtonItem)

end

function MountSlotView:OnRegisterGameEvent()

end

function MountSlotView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function MountSlotView:OnClickButtonItem()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end
	local ViewModel = self.Params.Data
	local MountArchivePanel = UIViewMgr:FindView(_G.UIViewID.MountArchivePanel)
    if _G.MountMgr.AssembleID ~= 0 and MountArchivePanel then
		_G.MsgTipsUtil.ShowTips(LSTR(1050200))
		return
	end
	Adapter:OnItemClicked(self, Params.Index)
end

function MountSlotView:OnSelectChanged(IsSelected)
	local ViewModel = self.Params.Data
	if ViewModel and ViewModel.OnSelectedChange then
		ViewModel:OnSelectedChange(IsSelected)
	end
end

function MountSlotView:OnRedPointChange()
	local ViewModel = self.Params.Data
	if ViewModel then
		-- if _G.MountMgr:CheckMountLocalRedPoint(ViewModel.ResID) then
		-- 	return
		-- end
		if ViewModel.IsShowRedPoint ~= nil and ViewModel.IsShowRedPoint then
			local RedDotName = MountCustomMadeVM:GetRedDotName(ViewModel.ResID)
			if RedDotName == "" then
				RedDotName = MountVM:GetRedDotName(ViewModel.ResID)
			end
			self.RedDot:SetRedDotNameByString(RedDotName)
		else
			self.RedDot:SetRedDotNameByString("")
		end
	end
end

function MountSlotView:OnRedPointTypeChange()
	local ViewModel = self.Params.Data
	if ViewModel then
		self.RedDot:SetStyle(ViewModel.RedPointType)
	end
end
return MountSlotView