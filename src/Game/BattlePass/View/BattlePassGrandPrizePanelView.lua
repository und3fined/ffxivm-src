---
--- Author: Administrator
--- DateTime: 2025-05-22 15:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local BattlePassMainVM = require("Game/BattlePass/VM/BattlePassMainVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class BattlePassGrandPrizePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnInfoTips UFButton
---@field BtnView UFButton
---@field CanvasPanel_0 UCanvasPanel
---@field ImgGrandPrize UFImage
---@field PanelGrandPrize UFCanvasPanel
---@field PanelReward UFCanvasPanel
---@field Reward01 BattlePassPrizeViewItemView
---@field Reward02 BattlePassPrizeViewItemView
---@field Reward03 BattlePassPrizeViewItemView
---@field Reward04 BattlePassPrizeViewItemView
---@field Reward05 BattlePassPrizeViewItemView
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BattlePassGrandPrizePanelView = LuaClass(UIView, true)

function BattlePassGrandPrizePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnInfoTips = nil
	--self.BtnView = nil
	--self.CanvasPanel_0 = nil
	--self.ImgGrandPrize = nil
	--self.PanelGrandPrize = nil
	--self.PanelReward = nil
	--self.Reward01 = nil
	--self.Reward02 = nil
	--self.Reward03 = nil
	--self.Reward04 = nil
	--self.Reward05 = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BattlePassGrandPrizePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Reward01)
	self:AddSubView(self.Reward02)
	self:AddSubView(self.Reward03)
	self:AddSubView(self.Reward04)
	self:AddSubView(self.Reward05)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BattlePassGrandPrizePanelView:OnInit()
	self.ViewModel = BattlePassMainVM
end

function BattlePassGrandPrizePanelView:OnDestroy()

end

function BattlePassGrandPrizePanelView:OnShow()
	self.ViewModel:InitGrandPrize()
end

function BattlePassGrandPrizePanelView:OnHide()

end

function BattlePassGrandPrizePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnView, self.OnClickedGotoPreview)
	UIUtil.AddOnClickedEvent(self, self.BtnInfoTips, self.OnClickedItemTips)
end

function BattlePassGrandPrizePanelView:OnRegisterGameEvent()

end

function BattlePassGrandPrizePanelView:OnRegisterBinder()
	local Binders = {
		{"GrandPrizeImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgGrandPrize)},
		{"GrandPrizeName", UIBinderSetText.New(self, self.TextName)},
	}
	self:RegisterBinders(BattlePassMainVM, Binders)
	self.Reward01:SetParams({Data = self.ViewModel.GrandPrize1})
	self.Reward02:SetParams({Data = self.ViewModel.GrandPrize2})
	self.Reward03:SetParams({Data = self.ViewModel.GrandPrize3})
	self.Reward04:SetParams({Data = self.ViewModel.GrandPrize4})
	self.Reward05:SetParams({Data = self.ViewModel.GrandPrize5})
end

function BattlePassGrandPrizePanelView:OnClickedGotoPreview()
	if self.ViewModel and self.ViewModel.GrandPrizeJumpID ~= nil then
		_G.PreviewMgr:OpenPreviewView(self.ViewModel.GrandPrizeJumpID)
		return
	end
end

function BattlePassGrandPrizePanelView:OnClickedItemTips()
	if self.ViewModel and self.ViewModel.GrandPrizeID ~= nil and self.ViewModel.GrandPrizeID ~= 0 then
		ItemTipsUtil.ShowTipsByResID(self.ViewModel.GrandPrizeID , self.BtnInfoTips)
		return
	end
end

return BattlePassGrandPrizePanelView