--
-- Author: anypkvcai
-- Date: 2020-11-10 21:41:45
-- Description:
--

--[[

local LuaClass = require("Core/LuaClass")
local UIAdapterListView = require("UI/Adapter/UIAdapterListView")

---@class UIAdapterTileView : UIAdapterListView
local UIAdapterTileView = LuaClass(UIAdapterListView, true)

---CreateAdapter
---@param View UIView
---@param Widget UUserWidget
---@param OnSelectChanged function
---@return UIView
function UIAdapterTileView.CreateAdapter(View, Widget, OnSelectChanged)
	local Adapter = UIAdapterTileView.New()
	Adapter:InitAdapter(View, Widget, OnSelectChanged)
	return Adapter
end

---Ctor
function UIAdapterTileView:Ctor()
	--print("UIAdapterTileView:Ctor")
end

return UIAdapterTileView

--]]