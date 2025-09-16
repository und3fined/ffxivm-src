---
--- Author: anypkvcai
--- DateTime: 2021-01-22 14:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapItemIconCfg = require("TableCfg/MapItemIconCfg")

---@class MainMiniMapItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImageIcon UImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainMiniMapItemView = LuaClass(UIView, true)

function MainMiniMapItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	self.ImageIcon = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainMiniMapItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainMiniMapItemView:OnInit()

end

function MainMiniMapItemView:OnDestroy()

end

function MainMiniMapItemView:OnShow()

end

function MainMiniMapItemView:OnHide()

end

function MainMiniMapItemView:OnRegisterUIEvent()

end

function MainMiniMapItemView:OnRegisterGameEvent()

end

function MainMiniMapItemView:OnRegisterTimer()

end

function MainMiniMapItemView:OnRegisterBinder()

end

function MainMiniMapItemView:SetImageIcon(Type)
	local IconPath = MapItemIconCfg:FindValue(Type, "IconPath")

	UIUtil.ImageSetBrushFromAssetPath(self.ImageIcon, IconPath, true)
end

return MainMiniMapItemView