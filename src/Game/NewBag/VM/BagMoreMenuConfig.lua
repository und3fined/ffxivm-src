local LSTR = _G.LSTR
local ProtoCommon = require("Protocol/ProtoCommon")

local DropConfig = {
	Name = LSTR(990054),
}

function DropConfig:Check(Item, ShowTips)
	if _G.BagMgr:IsTimeLimitItem(Item) and _G.BagMgr:TimeLimitItemExpired(Item) == false then
		_G.MsgTipsUtil.ShowTipsByID(100028)
		return false
	end
	return true
end

function DropConfig:OnClicked(Item)
	if not self:Check(Item, true) then
		return false
	end

	_G.BagMgr:DropItem(Item)
	return false
end

local InlayConfig = {
	Name = LSTR(990055),
}

function InlayConfig:Check(Item, ShowTips)
	return true
end

function InlayConfig:OnClicked(Item)
	if not _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDGemInfo) then
		_G.MsgTipsUtil.ShowTips(LSTR(1050222))
		return
	end

	if not self:Check(Item, true) then
		return false
	end

	local Param = {GID = Item.GID, ResID = Item.ResID, Tag = "Bag"}
	_G.EquipmentMgr:TryInlayMagicspar(Param)
	return false
end


local WardrobeConfig = {
	Name = LSTR(990097),
}

function WardrobeConfig:Check(Item, ShowTips)
	return true
end

function WardrobeConfig:OnClicked(Item)
	if not self:Check(Item, true) then
		return false
	end
	local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
	local AppearanceID = WardrobeUtil.IsAppearanceByItemID(Item.ResID)
	if AppearanceID and AppearanceID > 0 then
		_G.WardrobeMgr:OpenWardrobeUnlockPanel(AppearanceID)
	end
	return false
end

local DegradationConfig = {
	Name = LSTR(990056),
}

function DegradationConfig:Check(Item, ShowTips)
	return true
end

function DegradationConfig:OnClicked(Item)
	if not self:Check(Item, true) then
		return false
	end
	_G.BagMgr:ToNQItem(Item)
	return false
end

local ImproveConfig = {
	Name = LSTR(990057),
}

function ImproveConfig:Check(Item, ShowTips)
	return true
end

function ImproveConfig:OnClicked(Item)
	if not self:Check(Item, true) then
		return false
	end
	if not _G.EquipmentMgr:CheckCanOperate(LSTR(1050176)) then
		return false
	end
	_G.UIViewMgr:ShowView(_G.UIViewID.EuipmentImproveWinView, {EquipID = Item.ResID, GID = Item.GID, OpenType = 2})
	return false
end

local RareTaskConfig = {
	Name = LSTR(1160078),
}

function RareTaskConfig:Check(Item, ShowTips)
	return true
end

function RareTaskConfig:OnClicked(Item)
	if not self:Check(Item, true) then
		return false
	end

	_G.UIViewMgr:ShowView(_G.UIViewID.CompanySealMainPanelView, {GID = Item.GID})
	return false
end

local BagMoreMenuConfig = {
	DropConfig,
	InlayConfig,
	DegradationConfig,
	ImproveConfig,
	WardrobeConfig,
	RareTaskConfig,
}

return BagMoreMenuConfig