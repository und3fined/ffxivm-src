---
--- Author: usakizhang
--- DateTime: 2025-03-06 15:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class OpsConcertSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCheck UFButton
---@field Comm96Slot CommBackpack96SlotView
---@field EffectCostly UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsConcertSlotView = LuaClass(UIView, true)

function OpsConcertSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCheck = nil
	--self.Comm96Slot = nil
	--self.EffectCostly = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsConcertSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm96Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsConcertSlotView:OnInit()
	self.Binders = {
		{"BtnCheck",UIBinderSetIsVisible.New(self, self.BtnCheck, false, true)},
		{"BtnCheck",UIBinderSetIsVisible.New(self, self.EffectCostly)}
	}
end

function OpsConcertSlotView:OnDestroy()

end

function OpsConcertSlotView:OnShow()

end

function OpsConcertSlotView:OnHide()

end

function OpsConcertSlotView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.BtnCheck, self.OnClickBtnCheck)
end

function OpsConcertSlotView:OnRegisterGameEvent()

end

function OpsConcertSlotView:OnClickBtnCheck()
    if self.Params == nil or self.Params.Data == nil then return end
    _G.PreviewMgr:OpenPreviewView(self.Params.Data.ItemID)
end

function OpsConcertSlotView:OnRegisterBinder()
	local Params = self.Params
    if nil == Params then return end

    local ViewModel = Params.Data
    if nil == ViewModel or nil == ViewModel.RegisterBinder then
        return
    end
	self:RegisterBinders(ViewModel, self.Binders)
end

return OpsConcertSlotView