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

---@class TeamRecruitContentTypeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field ImgSelect UFImage
---@field LightPanel UFCanvasPanel
---@field PanelType UFCanvasPanel
---@field TextName UFTextBlock
---@field TextNameLight UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamRecruitContentTypeItemView = LuaClass(UIView, true)

function TeamRecruitContentTypeItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.ImgSelect = nil
	--self.LightPanel = nil
	--self.PanelType = nil
	--self.TextName = nil
	--self.TextNameLight = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamRecruitContentTypeItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamRecruitContentTypeItemView:OnInit()

end

function TeamRecruitContentTypeItemView:OnDestroy()

end

function TeamRecruitContentTypeItemView:OnShow()

end

function TeamRecruitContentTypeItemView:OnHide()

end

function TeamRecruitContentTypeItemView:OnRegisterUIEvent()

end

function TeamRecruitContentTypeItemView:OnRegisterGameEvent()

end

function TeamRecruitContentTypeItemView:OnRegisterBinder()
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

function TeamRecruitContentTypeItemView:OnSelectChanged(IsSelected)
	UIUtil.SetIsVisible(self.LightPanel, IsSelected)
	UIUtil.SetIsVisible(self.TextName, not IsSelected)
end

return TeamRecruitContentTypeItemView