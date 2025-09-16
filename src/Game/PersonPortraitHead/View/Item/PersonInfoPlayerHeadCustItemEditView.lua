---
--- Author: Administrator
--- DateTime: 2024-08-16 16:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")


local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local PersonPortraitVM = require("Game/PersonPortrait/VM/PersonPortraitVM")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local PersonPortraitHeadHelper = require("Game/PersonPortraitHead/PersonPortraitHeadHelper")

---@class PersonInfoPlayerHeadCustItemEditView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDelete UFButton
---@field BtnPlayer UFButton
---@field DeleteNode UFCanvasPanel
---@field IconCheck UFImage
---@field ImgAdd UFImage
---@field ImgBkg UFImage
---@field ImgBlack UFImage
---@field ImgFrame UFImage
---@field ImgPlayer UFImage
---@field ImgSelect UFImage
---@field PanelAdd UFCanvasPanel
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoPlayerHeadCustItemEditView = LuaClass(UIView, true)

function PersonInfoPlayerHeadCustItemEditView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnDelete = nil
	--self.BtnPlayer = nil
	--self.DeleteNode = nil
	--self.IconCheck = nil
	--self.ImgAdd = nil
	--self.ImgBkg = nil
	--self.ImgBlack = nil
	--self.ImgFrame = nil
	--self.ImgPlayer = nil
	--self.ImgSelect = nil
	--self.PanelAdd = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoPlayerHeadCustItemEditView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoPlayerHeadCustItemEditView:OnInit()
	self.Binders = {
		-- { "IsSelt", 	UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "IsInUse", 	UIBinderSetIsVisible.New(self, self.IconCheck) },
		-- { "HeadIcon", 	UIBinderSetBrushFromAssetPath.New(self, self.ImgFrame) },
		-- { "IsEmpty", 	UIBinderSetIsVisible.New(self, self.PanelAdd) },
		{ "IsEmpty", 	UIBinderSetIsVisible.New(self, self.ImgPlayer, true) },
		{ "IsEmpty", 	UIBinderValueChangedCallback.New(self, nil, self.OnValChgShowDelete) },

		{ "IsEmpty", 	UIBinderSetIsVisible.New(self, self.ImgFrame, true) },
		{ "IsEmpty", 	UIBinderSetIsVisible.New(self, self.ImgBkg, true) },
		{ "IsEmpty", 	UIBinderSetIsVisible.New(self, self.ImgBkg2) },
		
		{ "HeadIconUrl", 	UIBinderValueChangedCallback.New(self, nil, self.OnValChgUrl) },
	}

	self.EditBinders = {
		{ "IsEditShowDelete", 	UIBinderValueChangedCallback.New(self, nil, self.OnValChgShowDelete) },
		-- { "IsEditShowDelete", 	UIBinderSetIsVisible.New(self, self.DeleteNode) },
	}
end

function PersonInfoPlayerHeadCustItemEditView:OnDestroy()

end

function PersonInfoPlayerHeadCustItemEditView:OnShow()

end

function PersonInfoPlayerHeadCustItemEditView:OnHide()

end

function PersonInfoPlayerHeadCustItemEditView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnDelete, self.OnBtnDelete)
end

function PersonInfoPlayerHeadCustItemEditView:OnRegisterGameEvent()

end

function PersonInfoPlayerHeadCustItemEditView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	self.VM = Params.Data
	self:RegisterBinders(self.VM, self.Binders)
	local EditVM = _G.PersonPortraitHeadVM
	self:RegisterBinders(EditVM, self.EditBinders)
end

function PersonInfoPlayerHeadCustItemEditView:OnValChgUrl(Val)
	if string.isnilorempty(Val) then
		return
	end

	PersonPortraitHeadHelper.SetHeadByUrl(self.ImgPlayer, Val, 'HeadCustItem::OnValChgUrl')
end


function PersonInfoPlayerHeadCustItemEditView:OnValChgShowDelete(_)
	local Val = _G.PersonPortraitHeadVM.IsEditShowDelete
	local IsShow = Val and (self.VM) and (not self.VM.IsEmpty)
	UIUtil.SetIsVisible(self.DeleteNode, IsShow)
end

-- function PersonInfoPlayerHeadCustItemEditView:OnSelectChanged(IsSelected)
-- 	local Params = self.Params
-- 	if nil == Params then
-- 		return
-- 	end

-- 	local VM = Params.Data
-- 	if nil == VM then
-- 		return
-- 	end

-- 	VM.IsSelt = IsSelected
-- end


function PersonInfoPlayerHeadCustItemEditView:OnBtnDelete()
	local Idx = (self.VM or {}).HeadCustID
	if not Idx then return end
	_G.PersonPortraitHeadMgr:TryDeleteCustHead(Idx)
	_G.PersonPortraitHeadVM.IsEditShowDelete = false
end

return PersonInfoPlayerHeadCustItemEditView