---
--- Author: v_vvxinchen
--- DateTime: 2025-07-28 14:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local OPS_JUMP_TYPE = ProtoRes.Game.OPS_JUMP_TYPE

---@class OpsLolitaSuitItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field BtnCheck UFButton
---@field IconHave UFImage
---@field IconTeleport UFImage
---@field ImgSlot UFImage
---@field PanelTeleportText UFCanvasPanel
---@field SizeBox USizeBox
---@field TextTeleport UFTextBlock
---@field ImgProps SlateBrush
---@field IconSizeW float
---@field iconSizeH float
---@field ItemType int
---@field Teleport bool
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsLolitaSuitItemView = LuaClass(UIView, true)

function OpsLolitaSuitItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.BtnCheck = nil
	--self.IconHave = nil
	--self.IconTeleport = nil
	--self.ImgSlot = nil
	--self.PanelTeleportText = nil
	--self.SizeBox = nil
	--self.TextTeleport = nil
	--self.ImgProps = nil
	--self.IconSizeW = nil
	--self.iconSizeH = nil
	--self.ItemType = nil
	--self.Teleport = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsLolitaSuitItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsLolitaSuitItemView:OnInit()
	self.TextTeleport:SetText(_G.LSTR(100136)) --"带传送特效"
end

function OpsLolitaSuitItemView:OnDestroy()

end

function OpsLolitaSuitItemView:OnShow()
	--IsBuy
	local SuitDataList = self.Params.SuitDataList
	self:SetBuyState(SuitDataList)
end

function OpsLolitaSuitItemView:SetBuyState(SuitDataList)
	local SuitData = SuitDataList[self.ItemType]
	if SuitData == nil then
		return
	end
	self.SuitData = SuitData
	UIUtil.SetIsVisible(self.IconHave, SuitData.IsBuy)
end

function OpsLolitaSuitItemView:OnHide()

end

function OpsLolitaSuitItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickBtnCheck)
end

function OpsLolitaSuitItemView:OnClickBtnCheck()
	if self.SuitData == nil then
		return
	end
	local JumpID = self.SuitData.JumpID
	if JumpID ~= "" then
		_G.OpsActivityMgr:Jump(OPS_JUMP_TYPE.TABLE_JUMP, JumpID)
	else
		--不可预览时，弹出详情
		local ResID = self.SuitData.GoodsItemID
		if ResID and ResID > 0 then
			ItemTipsUtil.ShowTipsByResID(ResID, self.BtnCheck, {X = 0,Y = 0}, nil)
		end
	end
end

function OpsLolitaSuitItemView:OnRegisterGameEvent()

end

function OpsLolitaSuitItemView:OnRegisterBinder()

end

return OpsLolitaSuitItemView