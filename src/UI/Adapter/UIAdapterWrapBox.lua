---
--- Author: anypkvcai
--- DateTime: 2021-08-09 20:47
--- Description:
---



local LuaClass = require("Core/LuaClass")
local UIAdapterPanelWidget = require("UI/Adapter/UIAdapterPanelWidget")

---@class UIAdapterWrapBox : UIAdapterPanelWidget
local UIAdapterWrapBox = LuaClass(UIAdapterPanelWidget, true)

---CreateAdapter
---@param View UIView
---@param Widget UWrapBox
---@return UIView
function UIAdapterWrapBox.CreateAdapter(View, Widget)
	local Adapter = UIAdapterWrapBox.New()
	Adapter:InitAdapter(View, Widget)
	return Adapter
end

---Ctor
function UIAdapterWrapBox:Ctor()

end

return UIAdapterWrapBox