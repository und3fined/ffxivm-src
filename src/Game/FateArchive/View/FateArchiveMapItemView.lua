---
--- Author: guanjiewu
--- DateTime: 2023-12-25 17:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapMap2areaCfg = require("TableCfg/MapMap2areaCfg")
local LSTR = _G.LSTR
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")

---@class FateArchiveMapItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field ImgMap UFImage
---@field TextCompleteRate UFTextBlock
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateArchiveMapItemView = LuaClass(UIView, true)

function FateArchiveMapItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.ImgMap = nil
	--self.TextCompleteRate = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateArchiveMapItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateArchiveMapItemView:OnInit()

end

function FateArchiveMapItemView:OnDestroy()

end

function FateArchiveMapItemView:OnShow()
	local Params = self.Params
	if nil == Params then return end
	local MapItemInfo = Params.Data
	self.MapID = MapItemInfo.ResID
	self.TextCompleteRate:SetText(string.format(LSTR(190088), MapItemInfo.Percent)) 
	local MapCfg = MapMap2areaCfg:FindCfgByKey(MapItemInfo.ResID)
	self.TextName:SetText(MapCfg.MapName)
	--读取图标
	UIUtil.ImageSetBrushFromAssetPath(self.ImgMap, MapCfg.ScreenImage)
end

function FateArchiveMapItemView:OnHide()

end

function FateArchiveMapItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnBtnClicked)
end

function FateArchiveMapItemView:OnRegisterGameEvent()

end

function FateArchiveMapItemView:OnRegisterBinder()

end

function FateArchiveMapItemView:OnBtnClicked()
	_G.EventMgr:SendEvent(EventID.FateCloseStatisticsPanel)
	_G.EventMgr:SendEvent(EventID.FateOnMapSelected, self.MapID)
end

return FateArchiveMapItemView