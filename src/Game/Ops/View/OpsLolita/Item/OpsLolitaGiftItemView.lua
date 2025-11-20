--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2025-07-31 15:11:46
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-07-31 20:29:32
FilePath: \Client\Source\Script\Game\Ops\View\OpsLolita\Item\OpsLolitaGiftItemView.lua
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
local ItemUtil = require("Utils/ItemUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class OpsLolitaGiftItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm126Slot CommBackpack126SlotView
---@field TextGift UFTextBlock
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsLolitaGiftItemView = LuaClass(UIView, true)

function OpsLolitaGiftItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm126Slot = nil
	--self.TextGift = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsLolitaGiftItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm126Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsLolitaGiftItemView:OnInit()

end

function OpsLolitaGiftItemView:OnDestroy()

end

function OpsLolitaGiftItemView:OnShow()
	local Index = self.Params.Index
	self.TextGift:SetText(string.format(_G.LSTR(100142), Index)) --" · 赠礼%d"
	local Rewards = self.Params.Rewards
	local ItemID = Rewards and Rewards.ItemID
	if ItemID then
		self.ItemID = ItemID
		local Name = ItemUtil.GetItemName(ItemID)
		self.TextName:SetText(Name)
		local IconPath = UIUtil.GetIconPath((ItemUtil.GetItemIcon(ItemID)))
		UIUtil.ImageSetBrushFromAssetPath(self.Comm126Slot.Icon, IconPath)
	end
	UIUtil.SetIsVisible(self.Comm126Slot.IconChoose, false)
	UIUtil.SetIsVisible(self.Comm126Slot.RichTextQuantity, false)
	UIUtil.SetIsVisible(self.Comm126Slot.RichTextLevel, false)
end

function OpsLolitaGiftItemView:OnHide()

end

function OpsLolitaGiftItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Comm126Slot.Btn, self.OnClickedBtnSlot)
end

function OpsLolitaGiftItemView:OnClickedBtnSlot()
	ItemTipsUtil.ShowTipsByResID(self.ItemID, self.Comm126Slot, {X = 0,Y = 0}, nil)
end

function OpsLolitaGiftItemView:OnRegisterGameEvent()

end

function OpsLolitaGiftItemView:OnRegisterBinder()

end

return OpsLolitaGiftItemView