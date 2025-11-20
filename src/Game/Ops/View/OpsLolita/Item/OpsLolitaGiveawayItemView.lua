--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2025-08-21 17:55:33
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-08-22 09:39:59
FilePath: \Client\Source\Script\Game\Ops\View\OpsLolita\Item\OpsLolitaGiveawayItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
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
local OPS_JUMP_TYPE = ProtoRes.Game.OPS_JUMP_TYPE

---@class OpsLolitaGiveawayItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field Icon UFImage
---@field ImgSlot UFImage
---@field PanelReceive UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsLolitaGiveawayItemView = LuaClass(UIView, true)

function OpsLolitaGiveawayItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.Icon = nil
	--self.ImgSlot = nil
	--self.PanelReceive = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsLolitaGiveawayItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsLolitaGiveawayItemView:OnInit()

end

function OpsLolitaGiveawayItemView:OnDestroy()

end

function OpsLolitaGiveawayItemView:OnShow()
	local Rewards = self.Params.Rewards
	if Rewards == nil or Rewards.LootProduce == nil or #Rewards.LootProduce == 0 then
		return
	end
	local Item = Rewards.LootProduce[1]
	if Item == nil or Item.ResID == nil then
		return
	end
	--Icon
	local Cfg = ItemCfg:FindCfgByKey(Item.ResID)
	local IconID = Cfg and Cfg.IconID or 0
	local IconPath = UIUtil.GetIconPath(IconID)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgSlot, IconPath)

	--BookVisible
	local ItemType = Cfg and Cfg.ItemType or 0
	local IsBook = ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_ACTINGBOOK
	UIUtil.SetIsVisible(self.Icon, IsBook)
end

function OpsLolitaGiveawayItemView:SetReceiveVisible(bReceive)
	UIUtil.SetIsVisible(self.PanelReceive, bReceive)
end

function OpsLolitaGiveawayItemView:OnHide()

end

function OpsLolitaGiveawayItemView:OnRegisterUIEvent()

end

function OpsLolitaGiveawayItemView:OnRegisterGameEvent()
	
end

function OpsLolitaGiveawayItemView:OnRegisterBinder()

end

return OpsLolitaGiveawayItemView