---
--- Author: v_vvxinchen
--- DateTime: 2025-01-14 20:12
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class FishIngholeBaitItem2View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FishNotesSlot2 FishNotesSlotItemView
---@field IconSkill2 UFImage
---@field ImgArrow2 UFImage
---@field ImgPoint2 UFImage
---@field PanelSlot2 UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishIngholeBaitItem2View = LuaClass(UIView, true)

function FishIngholeBaitItem2View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FishNotesSlot2 = nil
	--self.IconSkill2 = nil
	--self.ImgArrow2 = nil
	--self.ImgPoint2 = nil
	--self.PanelSlot2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishIngholeBaitItem2View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.FishNotesSlot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishIngholeBaitItem2View:OnInit()
	self.Binders = {
		{ "SkillIcon", UIBinderSetBrushFromAssetPath.New(self, self.IconSkill2) },
		{ "PointIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgPoint2) }
	}
end

function FishIngholeBaitItem2View:OnDestroy()

end

function FishIngholeBaitItem2View:OnShow()

end

function FishIngholeBaitItem2View:OnHide()

end

function FishIngholeBaitItem2View:OnRegisterUIEvent()

end

function FishIngholeBaitItem2View:OnRegisterGameEvent()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
    self.FishNotesSlot2:SetParams({Data = ViewModel.FishSlot})
end

function FishIngholeBaitItem2View:OnRegisterBinder()

end

return FishIngholeBaitItem2View