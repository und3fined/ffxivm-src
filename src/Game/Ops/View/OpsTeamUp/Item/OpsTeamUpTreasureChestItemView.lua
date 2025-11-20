---
--- Author: Administrator
--- DateTime: 2025-05-30 18:56
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local OpsTeamUpTreasureChestItemVM = require("Game/Ops/VM/OpsTeamUp/ItemVM/OpsTeamUpTreasureChestItemVM")

---@class OpsTeamUpTreasureChestItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field GoldChestEffect UFCanvasPanel
---@field ImgBG UFImage
---@field ImgDeco3 UFImage
---@field PanelYellowDeco UFCanvasPanel
---@field TableViewSlot UTableView
---@field TextTitle UFTextBlock
---@field Imgyellowdeco bool
---@field ImgBGColor SlateBrush
---@field Text SlateFontInfo
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsTeamUpTreasureChestItemView = LuaClass(UIView, true)

function OpsTeamUpTreasureChestItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.GoldChestEffect = nil
	--self.ImgBG = nil
	--self.ImgDeco3 = nil
	--self.PanelYellowDeco = nil
	--self.TableViewSlot = nil
	--self.TextTitle = nil
	--self.Imgyellowdeco = nil
	--self.ImgBGColor = nil
	--self.Text = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsTeamUpTreasureChestItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsTeamUpTreasureChestItemView:OnInit()
	self.RewardList = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot)
	self.RewardList:SetOnClickedCallback(self.OnRewardListItemClicked)
	self.Binders = {
		{ "Title", UIBinderSetText.New(self, self.TextTitle) },
		{ "RewardItemVMList", UIBinderUpdateBindableList.New(self, self.RewardList) },
        { "bGoldChestEffect", UIBinderSetIsVisible.New(self, self.GoldChestEffect)},
	}
	self.ItemVM = OpsTeamUpTreasureChestItemVM.New()
end

function OpsTeamUpTreasureChestItemView:OnDestroy()

end

function OpsTeamUpTreasureChestItemView:SetData(NodeID)
	self.ItemVM:SetVMData(NodeID)
end

function OpsTeamUpTreasureChestItemView:OnShow()

end

function OpsTeamUpTreasureChestItemView:OnHide()

end

function OpsTeamUpTreasureChestItemView:OnRegisterUIEvent()

end

function OpsTeamUpTreasureChestItemView:OnRegisterGameEvent()

end

function OpsTeamUpTreasureChestItemView:OnRegisterBinder()
	if self.ItemVM == nil then
		return
	end
	self:RegisterBinders(self.ItemVM, self.Binders)
end

function OpsTeamUpTreasureChestItemView:OnRewardListItemClicked(Index, ItemVM, ItemView)
	if ItemVM and ItemView then
		ItemTipsUtil.ShowTipsByResID(ItemVM.ResID, ItemView)
	end
end

return OpsTeamUpTreasureChestItemView