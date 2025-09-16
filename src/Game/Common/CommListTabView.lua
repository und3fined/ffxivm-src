---
--- Author: anypkvcai
--- DateTime: 2021-04-30 19:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

---@class CommListTabView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextChecked UTextBlock
---@field TextUnChecked UTextBlock
---@field ToggleButton UToggleButton
---@field TextContent text
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommListTabView = LuaClass(UIView, true)

function CommListTabView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	self.TextChecked = nil
	self.TextUnChecked = nil
	self.ToggleButton = nil
	self.TextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommListTabView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommListTabView:OnInit()

end

function CommListTabView:OnDestroy()

end

function CommListTabView:OnShow()
	local Params = self.Params
	if nil == Params then return end

	local Data = Params.Data
	if nil == Data then return end

	local Text = Data.Text
	if nil == Text then return end

	self:SetText(Text)
end

function CommListTabView:OnHide()

end

function CommListTabView:OnRegisterUIEvent()

end

function CommListTabView:OnRegisterGameEvent()

end

function CommListTabView:OnRegisterTimer()

end

function CommListTabView:OnRegisterBinder()

end

function CommListTabView:SetText(Text)
	self.TextChecked:SetText(Text)
	self.TextUnChecked:SetText(Text)
end


return CommListTabView