---
--- Author: Administrator
--- DateTime: 2024-02-22 19:23
--- Description:NPC索引下标Item
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class FashionEvaluationDropItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgNormal UFImage
---@field ImgSelect UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionEvaluationDropItemView = LuaClass(UIView, true)

function FashionEvaluationDropItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgNormal = nil
	--self.ImgSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionEvaluationDropItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionEvaluationDropItemView:OnInit()

end

function FashionEvaluationDropItemView:OnDestroy()

end

function FashionEvaluationDropItemView:OnShow()
	UIUtil.SetIsVisible(self.ImgSelect, false)
end

function FashionEvaluationDropItemView:OnHide()

end

function FashionEvaluationDropItemView:OnRegisterUIEvent()

end

function FashionEvaluationDropItemView:OnRegisterGameEvent()

end

function FashionEvaluationDropItemView:OnRegisterBinder()

end

function FashionEvaluationDropItemView:OnSelectChanged(IsSelected)
	UIUtil.SetIsVisible(self.ImgSelect, IsSelected)
end

return FashionEvaluationDropItemView