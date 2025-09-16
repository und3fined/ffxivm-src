---
--- Author: Administrator
--- DateTime: 2024-02-04 11:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class GoldSaucerGameCuffAwardItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm96Slot CommBackpack96SlotView
---@field TextQuantity UFTextBlock
---@field AnimCriticalIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerGameCuffAwardItemView = LuaClass(UIView, true)

function GoldSaucerGameCuffAwardItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm96Slot = nil
	--self.TextQuantity = nil
	--self.AnimCriticalIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerGameCuffAwardItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm96Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerGameCuffAwardItemView:OnInit()

end

function GoldSaucerGameCuffAwardItemView:OnDestroy()

end

function GoldSaucerGameCuffAwardItemView:OnShow()
	-- local CoinID = ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE -- 金碟币ID
	-- local IconPath = _G.ScoreMgr:GetScoreIconName(CoinID)
    -- if nil == IconPath then
    --     return
    -- end
    -- UIUtil.ImageSetBrushFromAssetPath(self.Widget, IconPath)
	local CoinWidget = self.Comm96Slot
	if not CoinWidget then
		return
	end
	CoinWidget:SetNumVisible(false)
	CoinWidget:SetIconChooseVisible(false)
	self:RegisterTimer(self.SetTip, 1)
	
end

function GoldSaucerGameCuffAwardItemView:OnHide()
	self:ResetTip()
end

function GoldSaucerGameCuffAwardItemView:OnRegisterUIEvent()

end

function GoldSaucerGameCuffAwardItemView:OnRegisterGameEvent()

end

function GoldSaucerGameCuffAwardItemView:OnRegisterBinder()

end

function GoldSaucerGameCuffAwardItemView:SetTip()
	self.Comm96Slot:SetClickButtonCallback(self.Comm96Slot, function(TargetItemView)
		ItemTipsUtil.CurrencyTips(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE, false, TargetItemView)
	end)
end

function GoldSaucerGameCuffAwardItemView:ResetTip()
	self.Comm96Slot:SetClickButtonCallback(self.Comm96Slot, nil)
end

return GoldSaucerGameCuffAwardItemView