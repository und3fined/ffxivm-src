---
--- Author: Administrator
--- DateTime: 2025-07-07 14:05
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

---@class PVPCrystallineRankRewardItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBg UFImage
---@field ImgFlame1 UFImage
---@field ImgFlame2 UFImage
---@field ImgFlame3 UFImage
---@field TableViewReward UTableView
---@field TextDesc UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPCrystallineRankRewardItemView = LuaClass(UIView, true)

function PVPCrystallineRankRewardItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBg = nil
	--self.ImgFlame1 = nil
	--self.ImgFlame2 = nil
	--self.ImgFlame3 = nil
	--self.TableViewReward = nil
	--self.TextDesc = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPCrystallineRankRewardItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPCrystallineRankRewardItemView:OnInit()
	self.RewardList = UIAdapterTableView.CreateAdapter(self, self.TableViewReward)
	self.RewardList:SetOnClickedCallback(self.OnClickReward)
	self.Binders = {
		{ "BG", UIBinderSetBrushFromAssetPath.New(self, self.ImgBg) },
		{ "FrameBG", UIBinderSetBrushFromAssetPath.New(self, self.ImgFlame1) },
		{ "FrameBorder", UIBinderSetBrushFromAssetPath.New(self, self.ImgFlame2) },
		{ "FrameIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgFlame3) },
		{ "Desc", UIBinderSetText.New(self, self.TextDesc) },
		{ "RewardVMList", UIBinderUpdateBindableList.New(self, self.RewardList) },
	}
end

function PVPCrystallineRankRewardItemView:OnDestroy()

end

function PVPCrystallineRankRewardItemView:OnShow()

end

function PVPCrystallineRankRewardItemView:OnHide()

end

function PVPCrystallineRankRewardItemView:OnRegisterUIEvent()

end

function PVPCrystallineRankRewardItemView:OnRegisterGameEvent()

end

function PVPCrystallineRankRewardItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then return end

	local ViewModel = Params.Data
	if ViewModel == nil then return end

	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

function PVPCrystallineRankRewardItemView:OnClickReward(Index, ItemData, ItemView)
	if ItemData and ItemData.ResID then
    	ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView)
	end
end

return PVPCrystallineRankRewardItemView