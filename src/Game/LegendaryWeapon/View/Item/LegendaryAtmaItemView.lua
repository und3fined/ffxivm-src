---
--- Author: guanjiewu
--- DateTime: 2024-01-29 11:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local BagMgr = _G.BagMgr
local EventID = require("Define/EventID")
local MainPanelVM = require("Game/LegendaryWeapon/VM/LegendaryWeaponMainPanelVM")
---@class LegendaryAtmaItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field ImageSelect UFImage
---@field ImgAtma UFImage
---@field TextAmount UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LegendaryAtmaItemView = LuaClass(UIView, true)

function LegendaryAtmaItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.ImageSelect = nil
	--self.ImgAtma = nil
	--self.TextAmount = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LegendaryAtmaItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LegendaryAtmaItemView:OnInit()

end

function LegendaryAtmaItemView:OnDestroy()

end

function LegendaryAtmaItemView:OnShow()
	local Params = self.Params
	if nil == Params then return end
	local AtmaInfo = Params.Data
	self.ResID = AtmaInfo.ResID
	local Cfg = ItemCfg:FindCfgByKey(AtmaInfo.ResID)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgAtma, UIUtil.GetIconPath(Cfg.IconID))
	local CurNumber = BagMgr:GetItemNum(AtmaInfo.ResID)
	self.TextAmount:SetText(string.format("%d/%d", CurNumber, AtmaInfo.Num))
	UIUtil.SetIsVisible(self.ImageSelect, self.ResID == MainPanelVM.SelectItemID)
end

function LegendaryAtmaItemView:OnHide()

end

function LegendaryAtmaItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnBtnClick)
end

function LegendaryAtmaItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.LegendaryInnerMatClick, self.OnInnerMatClick)
end

function LegendaryAtmaItemView:OnInnerMatClick(ResID)
	UIUtil.SetIsVisible(self.ImageSelect, self.ResID == ResID)
end

function LegendaryAtmaItemView:OnRegisterBinder()

end

function LegendaryAtmaItemView:OnBtnClick()
	_G.EventMgr:SendEvent(EventID.LegendaryInnerMatClick, self.ResID)
--	_G.EventMgr:SendEvent(_G.EventID.LegendaryUpdateEquipTips, {IsActive = false})
end

return LegendaryAtmaItemView