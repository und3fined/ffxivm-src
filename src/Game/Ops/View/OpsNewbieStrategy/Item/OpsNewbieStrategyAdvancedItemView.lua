---
--- Author: Administrator
--- DateTime: 2024-11-18 14:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ProtoCS = require("Protocol/ProtoCS")
local ActivityRewardStatus = ProtoCS.Game.Activity.RewardStatus
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeRewardType = ProtoRes.Game.ActivityNodeRewardType
local ItemUtil = require("Utils/ItemUtil")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")


---@class OpsNewbieStrategyAdvancedItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose UFButton
---@field IconTitle UFImage
---@field ImgCover UFImage
---@field PanelCategory UFCanvasPanel
---@field PanelFinish UFCanvasPanel
---@field PanelList UFCanvasPanel
---@field PanelLock UFCanvasPanel
---@field PanelSize UFCanvasPanel
---@field TableViewList UTableView
---@field TableViewSlot UTableView
---@field TextFinish UFTextBlock
---@field TextHint UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimFold UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimUnfold UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsNewbieStrategyAdvancedItemView = LuaClass(UIView, true)

function OpsNewbieStrategyAdvancedItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.IconTitle = nil
	--self.ImgCover = nil
	--self.PanelCategory = nil
	--self.PanelFinish = nil
	--self.PanelList = nil
	--self.PanelLock = nil
	--self.PanelSize = nil
	--self.TableViewList = nil
	--self.TableViewSlot = nil
	--self.TextFinish = nil
	--self.TextHint = nil
	--self.TextTitle = nil
	--self.AnimFold = nil
	--self.AnimIn = nil
	--self.AnimUnfold = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsNewbieStrategyAdvancedItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsNewbieStrategyAdvancedItemView:OnInit()
	self.TableViewActiveNodeAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
	self.TableViewActiveRewardSlotAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot)
	self.TableViewActiveRewardSlotAdapter:SetOnClickedCallback(self.OnRewardItemClicked)
	self.Binders = 
	{
		--{ "InfoDesc", UIBinderSetText.New(self, self.TextHint)},
		{ "Icon", UIBinderSetImageBrush.New(self, self.ImgCover)},
		{ "Title", UIBinderSetText.New(self, self.TextTitle)},
		{ "NumText", UIBinderSetText.New(self, self.TextHint)},
		{ "ActiveNodeList", UIBinderUpdateBindableList.New(self, self.TableViewActiveNodeAdapter) },
		{ "IsExpand", UIBinderValueChangedCallback.New(self, nil, self.OnIsExpandChanged) },
		{ "IsFinished", UIBinderSetIsVisible.New(self, self.PanelFinish) },
		{ "IsShowTextHint", UIBinderSetIsVisible.New(self, self.TextHint) },
		{ "IsUnLock", UIBinderSetIsVisible.New(self, self.PanelLock, true) },
		{ "RewardItemList", UIBinderUpdateBindableList.New(self, self.TableViewActiveRewardSlotAdapter) },
	}
	---GetDesiredSize()第一次获取的数值不对，先写死
	self.MaxSize = _G.UE.FVector2D(1278,776)
	self.MinSize =  _G.UE.FVector2D(304,776)
	--self.SizeFVector2D = _G.UE.FVector2D(0,0)
end

function OpsNewbieStrategyAdvancedItemView:OnRewardItemClicked(Index, ItemData, ItemView)
	if ItemData:GetRewardStatus() ==  ActivityRewardStatus.RewardStatusWaitGet then
		local NodeID = ItemData:GetNodeID()
		if NodeID then
			_G.OpsNewbieStrategyMgr:GetRewardByNodeID(NodeID)
		end
	else
		local ItemType = ItemData.Type
		local ItemID = ItemData.ItemID
		if ItemType == ActivityNodeRewardType.ActivityNodeRewardTypeLoot then
			--掉落
			local RewardItemList = ItemUtil.GetLootItems(ItemID)	
			if RewardItemList and #RewardItemList > 0 then
				ItemID = RewardItemList[1].ResID
			end
		end
		ItemTipsUtil.ShowTipsByResID(ItemID, ItemView, {X = 0,Y = 0}, nil)
	end
end

function OpsNewbieStrategyAdvancedItemView:OnDestroy()

end

function OpsNewbieStrategyAdvancedItemView:OnShow()
	-- LSTR string:已完成
	self.TextFinish:SetText(LSTR(920012))

end

function OpsNewbieStrategyAdvancedItemView:OnHide()
end

function OpsNewbieStrategyAdvancedItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.BtnClose, self.OnBtnCloseClick)
end

function OpsNewbieStrategyAdvancedItemView:OnRegisterGameEvent()

end

function OpsNewbieStrategyAdvancedItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end
	local VM = Params.Data
	if VM == nil then
		return
	end
	self:RegisterBinders(VM, self.Binders)
end

function OpsNewbieStrategyAdvancedItemView:OnBtnCloseClick()
	local Params = self.Params
	if nil == Params then
		return
	end
	-- local VM = Params.Data
	-- if VM == nil then
	-- 	return
	-- end
	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end
	Adapter:OnItemClicked(self, Params.Index)
	--VM:SetItemExpand(false)
end

function OpsNewbieStrategyAdvancedItemView:OnIsExpandChanged(IsExpand, OldIsExpand)
	--if self.MaxSize == nil then
		--self.MaxSize = self.PanelSize:GetDesiredSize()
	--end
	--if self.MinSize == nil then
		--self.MinSize = self.PanelCategory:GetDesiredSize()
	--end
	---列表初始化进来的时候，不播动画
	if IsExpand == nil or (IsExpand == false and OldIsExpand == nil) then
		---怀疑出现自动开启的情况是动效还在播，导致隐藏失败了
		UIUtil.PlayAnimationTimePointPct(self, self.AnimUnfold, 0, 1, _G.UE.EUMGSequencePlayMode.Forward, 1, true)
		UIUtil.PlayAnimationTimePointPct(self, self.Animfold, 1, 1, _G.UE.EUMGSequencePlayMode.Forward, 1, true)
		--UIUtil.SetIsVisible(self.PanelList, false)
		return
	end
	local Params = self.Params
	if nil == Params then
		return
	end
	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end

	if IsExpand then
		self:PlayAnimation(self.AnimUnfold, 0, 1)
	else
		self:PlayAnimation(self.Animfold, 0, 1)
	end
	--UIUtil.CanvasSlotSetSize(self.PanelSize, self.SizeFVector2D)

end

function OpsNewbieStrategyAdvancedItemView:GetAnimUnfoldEndTime()
	return self.AnimUnfold:GetEndTime()
end

function OpsNewbieStrategyAdvancedItemView:GetAnimfoldEndTime()
	return self.Animfold:GetEndTime()
end

return OpsNewbieStrategyAdvancedItemView