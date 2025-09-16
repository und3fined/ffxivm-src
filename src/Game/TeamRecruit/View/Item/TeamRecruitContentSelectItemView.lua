---
--- Author: xingcaicao
--- DateTime: 2023-05-18 21:33
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@deprecated
---@class TeamRecruitContentSelectItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field LightPanel UFCanvasPanel
---@field PanelContent UFCanvasPanel
---@field TextContent UFTextBlock
---@field TextContentLight UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamRecruitContentSelectItemView = LuaClass(UIView, true)

function TeamRecruitContentSelectItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.LightPanel = nil
	--self.PanelContent = nil
	--self.TextContent = nil
	--self.TextContentLight = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamRecruitContentSelectItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamRecruitContentSelectItemView:OnInit()

end

function TeamRecruitContentSelectItemView:OnDestroy()

end

function TeamRecruitContentSelectItemView:OnShow()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	local Content = Params.Data.TaskName or ""
	self.TextContentLight:SetText(Content)
	self.TextContent:SetText(Content)
end

function TeamRecruitContentSelectItemView:OnHide()

end

function TeamRecruitContentSelectItemView:OnRegisterUIEvent()

end

function TeamRecruitContentSelectItemView:OnRegisterGameEvent()

end

function TeamRecruitContentSelectItemView:OnRegisterBinder()

end

function TeamRecruitContentSelectItemView:OnSelectChanged(IsSelected)
	UIUtil.SetIsVisible(self.LightPanel, IsSelected)
	UIUtil.SetIsVisible(self.TextContent, not IsSelected)
end

return TeamRecruitContentSelectItemView