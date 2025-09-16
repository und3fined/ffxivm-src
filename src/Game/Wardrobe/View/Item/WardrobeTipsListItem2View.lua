---
--- Author: Administrator
--- DateTime: 2025-03-04 16:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")

---@class WardrobeTipsListItem2View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelList UFCanvasPanel
---@field TextName UFTextBlock
---@field TextNum UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeTipsListItem2View = LuaClass(UIView, true)

function WardrobeTipsListItem2View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelList = nil
	--self.TextName = nil
	--self.TextNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeTipsListItem2View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeTipsListItem2View:OnInit()
	self.Binders = {
		{"ProfName", UIBinderSetText.New(self, self.TextName)},
		{"Progress", UIBinderSetText.New(self, self.TextNum)},
	}
end

function WardrobeTipsListItem2View:OnDestroy()

end

function WardrobeTipsListItem2View:OnShow()

end

function WardrobeTipsListItem2View:OnHide()

end

function WardrobeTipsListItem2View:OnRegisterUIEvent()

end

function WardrobeTipsListItem2View:OnRegisterGameEvent()

end

function WardrobeTipsListItem2View:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

return WardrobeTipsListItem2View