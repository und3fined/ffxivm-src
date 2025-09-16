---
--- Author: peterxie
--- DateTime: 2024-08-30 09:58
--- Description: 水晶传送列表的tab界面在通用tab界面上包装了一层
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class WorldMapTransferTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommTabItem CommVerIconTabItemView
---@field ImgSelect UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapTransferTabItemView = LuaClass(UIView, true)

function WorldMapTransferTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommTabItem = nil
	--self.ImgSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapTransferTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommTabItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapTransferTabItemView:OnInit()

end

function WorldMapTransferTabItemView:OnDestroy()

end

function WorldMapTransferTabItemView:OnShow()

end

function WorldMapTransferTabItemView:OnHide()

end

function WorldMapTransferTabItemView:OnRegisterUIEvent()

end

function WorldMapTransferTabItemView:OnRegisterGameEvent()

end

function WorldMapTransferTabItemView:OnRegisterBinder()

end


function WorldMapTransferTabItemView:OnSelectChanged(IsSelected)
	UIUtil.SetIsVisible(self.ImgSelect, IsSelected)
end

return WorldMapTransferTabItemView