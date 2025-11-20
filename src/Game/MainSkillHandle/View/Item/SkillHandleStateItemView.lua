---
--- Author: henghaoli
--- DateTime: 2025-05-23 14:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class SkillHandleStateItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgHandleNormal UFImage
---@field ImgHandleSelect UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillHandleStateItemView = LuaClass(UIView, true)

function SkillHandleStateItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgHandleNormal = nil
	--self.ImgHandleSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillHandleStateItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillHandleStateItemView:OnInit()

end

function SkillHandleStateItemView:OnDestroy()

end

function SkillHandleStateItemView:OnShow()

end

function SkillHandleStateItemView:OnHide()

end

function SkillHandleStateItemView:OnRegisterUIEvent()

end

function SkillHandleStateItemView:OnRegisterGameEvent()

end

function SkillHandleStateItemView:OnRegisterBinder()

end

function SkillHandleStateItemView:SetIsSelect(Value)
	if Value then
		UIUtil.SetIsVisible(self.ImgHandleSelect, true)
	else
		UIUtil.SetIsVisible(self.ImgHandleSelect, false)
	end
end

return SkillHandleStateItemView