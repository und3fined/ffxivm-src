---
--- Author: Administrator
--- DateTime: 2025-01-16 19:55
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class ArmyJoinInfoActivityItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyJoinInfoActivityItemView = LuaClass(UIView, true)

function ArmyJoinInfoActivityItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyJoinInfoActivityItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyJoinInfoActivityItemView:OnInit()
    self.Binders = {
		{"Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon)},
    }
end

function ArmyJoinInfoActivityItemView:OnDestroy()

end

function ArmyJoinInfoActivityItemView:OnShow()

end

function ArmyJoinInfoActivityItemView:OnHide()

end

function ArmyJoinInfoActivityItemView:OnRegisterUIEvent()

end

function ArmyJoinInfoActivityItemView:OnRegisterGameEvent()

end

function ArmyJoinInfoActivityItemView:OnRegisterBinder()
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

return ArmyJoinInfoActivityItemView