---
--- Author: Administrator
--- DateTime: 2024-02-20 17:02
--- Description:庆典开启提示
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class FashionEvaluationGrandCeremonyTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Text UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionEvaluationGrandCeremonyTipsItemView = LuaClass(UIView, true)

function FashionEvaluationGrandCeremonyTipsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Text = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionEvaluationGrandCeremonyTipsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionEvaluationGrandCeremonyTipsItemView:OnInit()

end

function FashionEvaluationGrandCeremonyTipsItemView:OnDestroy()

end

function FashionEvaluationGrandCeremonyTipsItemView:OnShow()
	self.Text:SetText(_G.LSTR(1120033)) --1120033("时尚品鉴庆典开始")
end

function FashionEvaluationGrandCeremonyTipsItemView:OnHide()

end

function FashionEvaluationGrandCeremonyTipsItemView:OnRegisterUIEvent()

end

function FashionEvaluationGrandCeremonyTipsItemView:OnRegisterGameEvent()

end

function FashionEvaluationGrandCeremonyTipsItemView:OnRegisterBinder()

end

return FashionEvaluationGrandCeremonyTipsItemView