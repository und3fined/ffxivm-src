---
--- Author: peterxie
--- DateTime: 2024-04-16 15:40
--- Description: 水晶传送列表地区项
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class WorldMapTransferAreaItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Textname UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapTransferAreaItemView = LuaClass(UIView, true)

function WorldMapTransferAreaItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Textname = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapTransferAreaItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapTransferAreaItemView:OnInit()
	self.Binders =
	{
		{ "AreaName", UIBinderSetText.New(self, self.Textname) },
	}
end

function WorldMapTransferAreaItemView:OnDestroy()

end

function WorldMapTransferAreaItemView:OnShow()

end

function WorldMapTransferAreaItemView:OnHide()

end

function WorldMapTransferAreaItemView:OnRegisterUIEvent()

end

function WorldMapTransferAreaItemView:OnRegisterGameEvent()

end

function WorldMapTransferAreaItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

return WorldMapTransferAreaItemView