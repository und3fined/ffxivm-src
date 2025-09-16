---
--- Author: Administrator
--- DateTime: 2025-01-16 19:55
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class ArmyJoinInfoViewJobItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgJob01 UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyJoinInfoViewJobItemView = LuaClass(UIView, true)

function ArmyJoinInfoViewJobItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgJob01 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyJoinInfoViewJobItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyJoinInfoViewJobItemView:OnInit()
    self.Binders = {
		{"Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgJob01)},
    }
end

function ArmyJoinInfoViewJobItemView:OnDestroy()

end

function ArmyJoinInfoViewJobItemView:OnShow()

end

function ArmyJoinInfoViewJobItemView:OnHide()

end

function ArmyJoinInfoViewJobItemView:OnRegisterUIEvent()

end

function ArmyJoinInfoViewJobItemView:OnRegisterGameEvent()

end

function ArmyJoinInfoViewJobItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
    self:RegisterBinders(self.ViewModel, self.Binders)
end

return ArmyJoinInfoViewJobItemView