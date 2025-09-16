---
--- Author: peterxie
--- DateTime: 2024-05-14 15:50
--- Description: 地图标记tips列表项
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class WorldMapMarkerTipsListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field ImgLine UFImage
---@field SizeBox USizeBox
---@field TextContent UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapMarkerTipsListItemView = LuaClass(UIView, true)

function WorldMapMarkerTipsListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.ImgLine = nil
	--self.SizeBox = nil
	--self.TextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapMarkerTipsListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapMarkerTipsListItemView:OnInit()

end

function WorldMapMarkerTipsListItemView:OnDestroy()

end

function WorldMapMarkerTipsListItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local MapMarker = Params.Data
	if nil == MapMarker then
		return
	end

	local TipsName = MapMarker:GetTipsName()
	self.TextContent:SetText(TipsName)

	if string.isnilorempty(TipsName) then
		print("[WorldMapMarkerTipsListItemView:OnShow] TipsName is empty", MapMarker:ToString())
	end

	local ImagePath = MapMarker:GetIconPath()
	UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, ImagePath, false, true, true)
end

function WorldMapMarkerTipsListItemView:OnHide()

end

function WorldMapMarkerTipsListItemView:OnRegisterUIEvent()

end

function WorldMapMarkerTipsListItemView:OnRegisterGameEvent()

end

function WorldMapMarkerTipsListItemView:OnRegisterBinder()

end

return WorldMapMarkerTipsListItemView