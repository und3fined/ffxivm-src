---
--- Author: xingcaicao
--- DateTime: 2023-05-18 21:33
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")

---@class TeamRecruitTypeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field LightPanel UFCanvasPanel
---@field PanelContentListItem UFCanvasPanel
---@field TextName UFTextBlock
---@field TextNameLight UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamRecruitTypeItemView = LuaClass(UIView, true)

function TeamRecruitTypeItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.LightPanel = nil
	--self.PanelContentListItem = nil
	--self.TextName = nil
	--self.TextNameLight = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamRecruitTypeItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamRecruitTypeItemView:OnInit()

end

function TeamRecruitTypeItemView:OnDestroy()

end

function TeamRecruitTypeItemView:OnShow()

end

function TeamRecruitTypeItemView:OnHide()

end

function TeamRecruitTypeItemView:OnRegisterUIEvent()

end

function TeamRecruitTypeItemView:OnRegisterGameEvent()

end

function TeamRecruitTypeItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	self.ViewModel = Params.Data

	local Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "Name", UIBinderSetText.New(self, self.TextNameLight) },
		{ "Icon", UIBinderSetImageBrush.New(self, self.ImgIcon) },
	}

	self:RegisterBinders(self.ViewModel, Binders)
end

function TeamRecruitTypeItemView:OnSelectChanged(IsSelected)
	UIUtil.SetIsVisible(self.LightPanel, IsSelected)
	UIUtil.SetIsVisible(self.TextName, not IsSelected)
end

return TeamRecruitTypeItemView