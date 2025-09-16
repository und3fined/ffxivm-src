---
--- Author: xingcaicao
--- DateTime: 2023-05-18 21:33
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class TeamRecruitProfSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ContentNode UFCanvasPanel
---@field ImgProf UFImage
---@field ImgReady UFImage
---@field ImgSelect UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamRecruitProfSlotView = LuaClass(UIView, true)

function TeamRecruitProfSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ContentNode = nil
	--self.ImgProf = nil
	--self.ImgReady = nil
	--self.ImgSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamRecruitProfSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamRecruitProfSlotView:OnInit()

end

function TeamRecruitProfSlotView:OnDestroy()

end

function TeamRecruitProfSlotView:OnShow()

end

function TeamRecruitProfSlotView:OnHide()

end

function TeamRecruitProfSlotView:OnRegisterUIEvent()

end

function TeamRecruitProfSlotView:OnRegisterGameEvent()

end

function TeamRecruitProfSlotView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	local ViewModel = Params.Data

	local Binders = {
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgProf) },
		{ "HasRole", UIBinderSetIsVisible.New(self, self.ImgReady) },
	}

	self:RegisterBinders(ViewModel, Binders)
end

function TeamRecruitProfSlotView:OnSelectChanged(IsSelected)
	UIUtil.SetIsVisible(self.ImgSelect, IsSelected)
end

function TeamRecruitProfSlotView:GetViewportPosition()
	local LocalPos = UIUtil.CanvasSlotGetPosition(self.ImgProf)
	local Pos = UIUtil.LocalToViewport(self.ContentNode, LocalPos)
	return Pos
end

return TeamRecruitProfSlotView