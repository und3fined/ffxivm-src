---
--- Author: Administrator
--- DateTime: 2025-04-07 14:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")

local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class PVPInfoJobSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPInfoJobSlotView = LuaClass(UIView, true)

function PVPInfoJobSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPInfoJobSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPInfoJobSlotView:OnInit()

end

function PVPInfoJobSlotView:OnDestroy()

end

function PVPInfoJobSlotView:OnShow()

end

function PVPInfoJobSlotView:OnHide()

end

function PVPInfoJobSlotView:OnRegisterUIEvent()

end

function PVPInfoJobSlotView:OnRegisterGameEvent()

end

function PVPInfoJobSlotView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end

	local ViewModel = Params.Data
	if nil == ViewModel then return end

	local Binders = {
		{ "ProfID", UIBinderValueChangedCallback.New(self, nil, self.OnProfIDChanged) },
	}

	self:RegisterBinders(ViewModel, Binders)
end

function PVPInfoJobSlotView:OnProfIDChanged(NewValue, OldValue)
	if NewValue == nil or NewValue == 0 then return end

	local Cfg = RoleInitCfg:FindCfgByKey(NewValue)
	if Cfg == nil then return end

	UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, Cfg.SimpleIcon2)
end

return PVPInfoJobSlotView