---
--- Author: Administrator
--- DateTime: 2023-12-20 14:02
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class FateItemSubmitInfoView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnUnselect UFButton
---@field ItemSlot CommBackpackSlotView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateItemSubmitInfoView = LuaClass(UIView, true)

function FateItemSubmitInfoView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnUnselect = nil
	--self.ItemSlot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateItemSubmitInfoView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ItemSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateItemSubmitInfoView:OnInit()

end

function FateItemSubmitInfoView:OnDestroy()

end

function FateItemSubmitInfoView:OnShow()

end

function FateItemSubmitInfoView:OnHide()

end

function FateItemSubmitInfoView:OnRegisterUIEvent()
	--暂时不需要选中的效果，bShowUnselect状态数据留着，后面加显示效果可再开
	--UIUtil.AddOnClickedEvent(self, self.BtnUnselect, self.OnClickedUnselect)
end

function FateItemSubmitInfoView:OnRegisterGameEvent()

end

function FateItemSubmitInfoView:OnRegisterBinder()
	if self.Params.Data == nil then return end

	--暂时不需要选中的效果，bShowUnselect状态数据留着，后面加显示效果可再开
	local Binders = {
		{ "bShowUnselect", UIBinderSetIsVisible.New(self, self.BtnUnselect, false, true) },
	}
	self:RegisterBinders(self.Params.Data, Binders)
end

function FateItemSubmitInfoView:OnSelectChanged(IsSelected)
	self.ItemSlot:OnSelectChanged(IsSelected)
end

function FateItemSubmitInfoView:OnClickedUnselect()
	local Adapter = self.Params.Adapter
	if Adapter and Adapter.OnClickedUnselect then
		Adapter:OnClickedUnselect(self.Params.Index, self.Params.Data, self)
	end
end

return FateItemSubmitInfoView