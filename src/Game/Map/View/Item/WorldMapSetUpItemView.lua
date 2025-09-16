---
--- Author: Administrator
--- DateTime: 2023-08-14 16:26
--- Description: 地图设置列表项
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapSetting = require("Game/Map/MapSetting")

---@class WorldMapSetUpItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field SingleBox CommSingleBoxView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapSetUpItemView = LuaClass(UIView, true)

function WorldMapSetUpItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.SingleBox = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapSetUpItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapSetUpItemView:OnInit()

end

function WorldMapSetUpItemView:OnDestroy()

end

function WorldMapSetUpItemView:OnShow()
	local Params = self.Params
	if nil == Params or nil == Params.Data or Params.Data.SettingType == nil then
		return
	end

	local SettingType = Params.Data.SettingType
	self.SettingType = SettingType
	self.SingleBox:SetChecked(MapSetting.GetSettingValue(SettingType) > 0)
	self.SingleBox:SetText(MapSetting.GetTipsText(SettingType))
end

function WorldMapSetUpItemView:OnHide()

end

function WorldMapSetUpItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.SingleBox, self.OnStateChangeSingleBox)
end

function WorldMapSetUpItemView:OnRegisterGameEvent()

end

function WorldMapSetUpItemView:OnRegisterBinder()

end

function WorldMapSetUpItemView:OnStateChangeSingleBox(Params, ToggleButton, ButtonState)
	local Type = self.SettingType
	if nil ~= Type then
		local IsChecked = UIUtil.IsToggleButtonChecked(ToggleButton)
		MapSetting.SetSettingValue(Type, IsChecked and 1 or 0)
	end
end

return WorldMapSetUpItemView