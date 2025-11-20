---
--- Author: v_vvxinchen
--- DateTime: 2025-07-28 14:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemUtil = require("Utils/ItemUtil")
local LSTR = _G.LSTR

---@class OpsLolitaGiftWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm2FrameL_UIBP Comm2FrameLView
---@field ImgAvatarFrame UFImage
---@field ImgDye UFImage
---@field ImgExpression1 UFImage
---@field ImgExpression2 UFImage
---@field ImgExpression3 UFImage
---@field ImgExpression4 UFImage
---@field ImgExpression5 UFImage
---@field ImgPhotoFrame UFImage
---@field LolitaGift1 OpsLolitaGiftItemView
---@field LolitaGift2 OpsLolitaGiftItemView
---@field LolitaGift3 OpsLolitaGiftItemView
---@field RichTextHint URichTextBox
---@field TextDyeQuantity UFTextBlock
---@field TextInclude1 UFTextBlock
---@field TextInclude2 UFTextBlock
---@field TextInclude3 UFTextBlock
---@field Textcontent1 UFTextBlock
---@field Textcontent2 UFTextBlock
---@field Textcontent3 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsLolitaGiftWinView = LuaClass(UIView, true)

function OpsLolitaGiftWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm2FrameL_UIBP = nil
	--self.ImgAvatarFrame = nil
	--self.ImgDye = nil
	--self.ImgExpression1 = nil
	--self.ImgExpression2 = nil
	--self.ImgExpression3 = nil
	--self.ImgExpression4 = nil
	--self.ImgExpression5 = nil
	--self.ImgPhotoFrame = nil
	--self.LolitaGift1 = nil
	--self.LolitaGift2 = nil
	--self.LolitaGift3 = nil
	--self.RichTextHint = nil
	--self.TextDyeQuantity = nil
	--self.TextInclude1 = nil
	--self.TextInclude2 = nil
	--self.TextInclude3 = nil
	--self.Textcontent1 = nil
	--self.Textcontent2 = nil
	--self.Textcontent3 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsLolitaGiftWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameL_UIBP)
	self:AddSubView(self.LolitaGift1)
	self:AddSubView(self.LolitaGift2)
	self:AddSubView(self.LolitaGift3)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsLolitaGiftWinView:OnInit()

end

function OpsLolitaGiftWinView:OnDestroy()

end

function OpsLolitaGiftWinView:OnShow()
	local ViewModel = self.Params and self.Params.Data
	if ViewModel == nil then
		return
	end
	self.Comm2FrameL_UIBP:SetTitleText(LSTR(100140)) --"购买加赠"
	--"购买洛丽塔商品满5件，立得全部奖励!（当前已购：%d/%d）"
	self.RichTextHint:SetText(string.format(LSTR(100141), ViewModel.PurchaseNum, ViewModel.TotalNum))

	local Rewards = ViewModel.Rewards
	if #Rewards >= 3 then
		for i = 1, 3 do
			self["LolitaGift"..i]:SetParams({Rewards = Rewards[i], Index = i})
			self["Textcontent"..i]:SetText(ItemCfg:GetItemDesc(Rewards[i].ItemID))
			self["TextInclude"..i]:SetText(LSTR(390029))--"包含："
		end

		self:SetIcon(self.ImgAvatarFrame, Rewards[1].LootProduce[1])
		self:SetIcon(self.ImgPhotoFrame, Rewards[1].LootProduce[2])
		for i = 1, 5 do
			local LootProduce = Rewards[2].LootProduce
			if LootProduce[i] ~= nil then
				self:SetIcon(self["ImgExpression"..i], LootProduce[i])
			end
		end
		self:SetIcon(self.ImgDye, Rewards[3].LootProduce[1])

		local Item3 = Rewards[3].LootProduce[1]
		if Item3 then
			self.TextDyeQuantity:SetText(string.format("x%d", Item3.Num or 0))
		end
	end
end

function OpsLolitaGiftWinView:SetIcon(Widget, Item)
	if Item == nil or Item.ResID == nil then
		return
	end
	local IconPath = UIUtil.GetIconPath((ItemUtil.GetItemIcon(Item.ResID)))
	UIUtil.ImageSetBrushFromAssetPath(Widget, IconPath)
end

function OpsLolitaGiftWinView:OnHide()

end

function OpsLolitaGiftWinView:OnRegisterUIEvent()

end

function OpsLolitaGiftWinView:OnRegisterGameEvent()

end

function OpsLolitaGiftWinView:OnRegisterBinder()

end

return OpsLolitaGiftWinView