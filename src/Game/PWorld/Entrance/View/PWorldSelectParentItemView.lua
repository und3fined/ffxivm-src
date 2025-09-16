---
--- Author: v_hggzhang
--- DateTime: 2022-11-25 14:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class PWorldSelectParentItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgMatching UFImage
---@field TextLevelCheck UFTextBlock
---@field TextPLevelUnCheck UFTextBlock
---@field TextVersionCheck UFTextBlock
---@field TextVersionUnCheck UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldSelectParentItemView = LuaClass(UIView, true)

function PWorldSelectParentItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgMatching = nil
	--self.TextLevelCheck = nil
	--self.TextPLevelUnCheck = nil
	--self.TextVersionCheck = nil
	--self.TextVersionUnCheck = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldSelectParentItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldSelectParentItemView:OnInit()

end

function PWorldSelectParentItemView:OnDestroy()

end

function PWorldSelectParentItemView:OnShow()

end

function PWorldSelectParentItemView:OnHide()

end

function PWorldSelectParentItemView:OnRegisterUIEvent()

end

function PWorldSelectParentItemView:OnRegisterGameEvent()

end

function PWorldSelectParentItemView:OnRegisterBinder()
	local Params = self.Params
    if nil == Params then
        return
    end
	local Type = Params.Data.Type
	local VM = _G.PWorldEntVM:FindItem(Type)
	if not VM then
		return
	end

	local Binders = {
		{ "IsMatching",    	UIBinderSetIsVisible.New(self, self.ImgMatching) },
	}
	self:RegisterBinders(VM, Binders)
end

return PWorldSelectParentItemView