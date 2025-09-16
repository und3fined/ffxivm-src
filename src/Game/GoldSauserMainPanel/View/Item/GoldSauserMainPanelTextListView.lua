---
--- Author: Administrator
--- DateTime: 2024-01-08 21:05
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require(("Binder/UIBinderSetText"))

---@class GoldSauserMainPanelTextListView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextContent UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainPanelTextListView = LuaClass(UIView, true)

function GoldSauserMainPanelTextListView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelTextListView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelTextListView:OnInit()

end

function GoldSauserMainPanelTextListView:OnDestroy()

end

function GoldSauserMainPanelTextListView:OnShow()

end

function GoldSauserMainPanelTextListView:OnHide()

end

function GoldSauserMainPanelTextListView:OnRegisterUIEvent()

end

function GoldSauserMainPanelTextListView:OnRegisterGameEvent()

end

function GoldSauserMainPanelTextListView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	local Binders = {
		{ "DescriptionStr", UIBinderSetText.New(self, self.TextContent) },	
	}
	self:RegisterBinders(VM, Binders)
end

return GoldSauserMainPanelTextListView