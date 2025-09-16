---
--- Author: anypkvcai
--- DateTime: 2023-03-30 21:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class SampleTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CheckPanel UFCanvasPanel
---@field TextCheck UFTextBlock
---@field TextUncheck UFTextBlock
---@field UncheckPanel UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SampleTabItemView = LuaClass(UIView, true)

function SampleTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CheckPanel = nil
	--self.TextCheck = nil
	--self.TextUncheck = nil
	--self.UncheckPanel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SampleTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SampleTabItemView:OnInit()

end

function SampleTabItemView:OnDestroy()

end

function SampleTabItemView:OnShow()
	local Params = self.Params
	--if nil == Params then
	--	return
	--end

	local Data = Params.Data
	--if nil == Data then
	--	return
	--end

	self.TextCheck:SetText(Data.Name)
	self.TextUncheck:SetText(Data.Name)
end

function SampleTabItemView:OnHide()

end

function SampleTabItemView:OnRegisterUIEvent()

end

function SampleTabItemView:OnRegisterGameEvent()

end

function SampleTabItemView:OnRegisterBinder()

end

function SampleTabItemView:OnSelectChanged(IsSelected)
	UIUtil.SetIsVisible(self.CheckPanel, IsSelected)
	UIUtil.SetIsVisible(self.UncheckPanel, not IsSelected)

end

return SampleTabItemView