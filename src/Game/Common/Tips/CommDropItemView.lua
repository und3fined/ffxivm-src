---
--- Author: v_zanchang
--- DateTime: 2023-02-07 19:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")
local ScoreCfg = require("TableCfg/ScoreCfg")
local ColorDefine = require("Define/ColorDefine")
local ProtoCommon = require("Protocol/ProtoCommon")
local ItemCfg = require("TableCfg/ItemCfg")
local MajorUtil = require("Utils/MajorUtil")
local AudioUtil = require("Utils/AudioUtil")
local LOOT_TYPE = ProtoCS.LOOT_TYPE
local MusicPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/SYS/Play_SE_UI_itemdel.Play_SE_UI_itemdel'"

---@class CommDropItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field DropItem01 UFCanvasPanel
---@field FImg_HQ UFImage
---@field FImg_Quality UFImage
---@field Icon_Goods UFImage
---@field Text_GoodsName URichTextBox
---@field AnimDrop UWidgetAnimation
---@field AnimDropDownSpaceTime float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommDropItemView = LuaClass(UIView, true)

function CommDropItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.DropItem01 = nil
	--self.FImg_HQ = nil
	--self.FImg_Quality = nil
	--self.Icon_Goods = nil
	--self.Text_GoodsName = nil
	--self.AnimDrop = nil
	--self.AnimDropDownSpaceTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommDropItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommDropItemView:OnInit()

end

function CommDropItemView:OnDestroy()

end

function CommDropItemView:OnShow()
	UIUtil.SetIsVisible(self.DropItem01, false)
	if self.Params == nil then
		FLOG_ERROR("CommDropItemView LootItem Params Error")
		return
	end

	if self.Params.LootItem == nil then
		FLOG_ERROR("CommDropItemView LootItem Params LootItem Error")
		return
	end

	local LootItem = self.Params.LootItem--{ Type = 0, Score = { GID = 0, ResID = 19000002, Value = 1000 } }
	if LootItem.Type == LOOT_TYPE.LOOT_TYPE_ITEM then --物品
		-- local ad = BagVM:GetItemsVMByResID(59990054)[1]
		local Item = ItemCfg:FindCfgByKey(LootItem.Item.ResID)-- BagVM:GetItemVMByGID(LootItem.Item.GID) --LootItem.Item.GID
		if not Item then
			FLOG_ERROR("Item == nil Check LootItem.Item.ResID")
			print(LootItem.Item.ResID)
			return
		end
		local IconPath = UIUtil.GetIconPath(Item.IconID)

		UIUtil.ImageSetBrushFromAssetPath(self.Icon_Goods, IconPath)
		local GradeLevelInfo = self:GetItemGradeLevelInfo(Item.ItemColor)
		UIUtil.SetColorAndOpacityHex(self.FImg_Quality, GradeLevelInfo.IconColor)
		-- if Item.IsHQ > 0 then
		-- 	UIUtil.SetIsVisible(self.FImg_HQ, true)
		-- 	UIUtil.SetColorAndOpacityHex(self.FImg_HQ, GradeLevelInfo.IconColor)
		-- else
		-- 	UIUtil.SetIsVisible(self.FImg_HQ, false)
		-- end
		local Content =  "<span color="
		local FontColor = GradeLevelInfo.FontColor
		local Text
		local ItemName = string.format("%s", ItemCfg:GetItemName(LootItem.Item.ResID))
		if LootItem.Item.Value == 1 or LootItem.Item.Num == 1 then
			Text = ItemName
		else
			Text = string.format("%s%s%s", ItemName, " x", tostring(LootItem.Item.Value))
		end

		Content = string.format("%s%s%s%s%s%s", Content,  '"', FontColor, '">', Text, "</>") --装备名称
		self.Text_GoodsName:SetText(Content)
	elseif LootItem.Type == LOOT_TYPE.LOOT_TYPE_SCORE then -- 积分
		--UIUtil.SetIsVisible(self.FImg_HQ, false)
		local ScoreInfo = ScoreCfg:FindCfgByKey(LootItem.Score.ResID)
		if ScoreInfo == nil then
			FLOG_ERROR("ScoreInfo == nil Check LootItem.Score.ResID")
			return
		end
		-- ScoreCfg.Icon = string.split(ScoreInfo.IconName, ".")--"Texture2D'/Game/Assets/Icon/WP/MagicCard/UI_MC_Icon_JinDieBi.UI_MC_Icon_JinDieBi'"--tostring(ScoreInfo.IconName)--
		-- local s = string.format('"%s.%s"', ScoreCfg.Icon[1], ScoreCfg.Icon[2])
		UIUtil.ImageSetBrushFromAssetPath(self.Icon_Goods, ScoreInfo.IconName) -- 积分图标

		if ScoreInfo.ID == 19000099 and LootItem.Score.Percent ~= 0 then --经验有加成
			local ValueText = tostring(LootItem.Score.Value)
			local Text = string.format("%s %s  ( + %d%s)", ScoreInfo.NameText, ValueText, LootItem.Score.Percent, "%")
			self.Text_GoodsName:SetText(Text)
		else
			local ValueText = tostring(LootItem.Score.Value)
			local Text = string.format("%s %s", ScoreInfo.NameText, ValueText)
			self.Text_GoodsName:SetText(Text)
		end

	end
	UIUtil.SetIsVisible(self.DropItem01, true)
	AudioUtil.SyncLoadAndPlaySoundEvent(MajorUtil.GetMajorEntityID(), MusicPath, true)
end

function CommDropItemView:GetItemGradeLevelInfo(ItemColor)
	return {FontColor = ColorDefine.ItemGradeColor[ItemColor], IconColor = ColorDefine.ItemGradeColor[ItemColor]}
end

function CommDropItemView:OnHide()

end

function CommDropItemView:OnRegisterUIEvent()

end

function CommDropItemView:OnRegisterGameEvent()

end

function CommDropItemView:OnRegisterBinder()

end

function CommDropItemView:PlayDropAni()
	self:PlayAnimation(self.AnimDrop)
end

-- function CommDropItemView:OnAnimationFinished(Animation)
-- 	local Params = self.Params
-- 	if nil == Params then
-- 		return
-- 	end

-- 	Params.OnItemAnimationFinished(Params.View, self)
-- end

return CommDropItemView