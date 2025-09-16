---
--- Author: Administrator
--- DateTime: 2023-08-14 16:49
--- Description: 地图下拉列表
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

---@class WorldMapTabDropDownListView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field DropListPanel UFCanvasPanel
---@field SizeBox_0 USizeBox
---@field TableViewItemList UTableView
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapTabDropDownListView = LuaClass(UIView, true)

function WorldMapTabDropDownListView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.DropListPanel = nil
	--self.SizeBox_0 = nil
	--self.TableViewItemList = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapTabDropDownListView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapTabDropDownListView:OnInit()

end

function WorldMapTabDropDownListView:OnDestroy()

end

function WorldMapTabDropDownListView:OnShow()
	self:PlayAnimation(self.AnimIn)
end

function WorldMapTabDropDownListView:OnHide()

end

function WorldMapTabDropDownListView:OnRegisterUIEvent()

end

function WorldMapTabDropDownListView:OnRegisterGameEvent()

end

function WorldMapTabDropDownListView:OnRegisterBinder()

end

return WorldMapTabDropDownListView