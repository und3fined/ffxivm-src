---
--- Author: yutingzhan
--- DateTime: 2024-11-14 16:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local OpsActivityPrizePoolWinVM = require("Game/Ops/VM/OpsActivityPrizePoolWinVM")
local OpsActivityTreasureChestPanelVM = require("Game/Ops/VM/OpsActivityTreasureChestPanelVM")
local LSTR = _G.LSTR

---@class OpsActivityPrizePoolWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCheck UFButton
---@field BtnPoster UFButton
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field ImgMask UFImage
---@field ImgPoster UFImage
---@field OwnedText UFTextBlock
---@field TableViewSlot UTableView
---@field TextProbability UFTextBlock
---@field TextRewardName UFTextBlock
---@field TextState UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsActivityPrizePoolWinView = LuaClass(UIView, true)

function OpsActivityPrizePoolWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCheck = nil
	--self.BtnPoster = nil
	--self.Comm2FrameM_UIBP = nil
	--self.ImgMask = nil
	--self.ImgPoster = nil
	--self.OwnedText = nil
	--self.TableViewSlot = nil
	--self.TextProbability = nil
	--self.TextRewardName = nil
	--self.TextState = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsActivityPrizePoolWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsActivityPrizePoolWinView:OnInit()
	self.ViewModel = OpsActivityPrizePoolWinVM.New()
	self.AwardTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot, self.OnClickedSelectMemberItem, true)
	self.Binders = {
        {"FinalRewardName", UIBinderSetText.New(self, self.TextRewardName)},
		{"FinalRewardProbability", UIBinderSetText.New(self, self.TextState)},
		{"TextDesc", UIBinderSetText.New(self, self.TextProbability)},
		{"OwnedText", UIBinderSetIsVisible.New(self, self.OwnedText)},
		{"FinalRewardPoster", UIBinderSetImageBrush.New(self, self.ImgPoster)},
		{"AwardVMList", UIBinderUpdateBindableList.New(self, self.AwardTableViewAdapter)},
		{"FinalRewardProbabilityColor",UIBinderSetColorAndOpacityHex.New(self, self.TextState)},
    }
end

function OpsActivityPrizePoolWinView:OnDestroy()
end

function OpsActivityPrizePoolWinView:OnShow()
    self.Comm2FrameM_UIBP.FText_Title:SetText(LSTR(100021))
	self.OwnedText:SetText(LSTR(100015))
	if self.Params == nil then
		return
	end
	self.ViewModel:UpdatePrizePool(self.Params)

end

function OpsActivityPrizePoolWinView:OnHide()
end

function OpsActivityPrizePoolWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.BtnPoster, self.OnImgPosterClick)
	UIUtil.AddOnClickedEvent(self, self.BtnCheck, self.OnBtnCheckClick)
end

function OpsActivityPrizePoolWinView:OnRegisterGameEvent()
end

function OpsActivityPrizePoolWinView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function OpsActivityPrizePoolWinView:OnClickedSelectMemberItem(Index, ItemData, ItemView)
	if ItemData == nil or ItemData.ItemID == nil then
		return
	end
	ItemTipsUtil.ShowTipsByResID(ItemData.ItemID, ItemView, nil, nil, 30)
end

function OpsActivityPrizePoolWinView:OnImgPosterClick()
	if OpsActivityTreasureChestPanelVM and OpsActivityTreasureChestPanelVM.FinalAwardItemID then
		ItemTipsUtil.ShowTipsByResID(OpsActivityTreasureChestPanelVM.FinalAwardItemID, self.ImgPoster, {X = 0, Y = 0})
	end
end

function OpsActivityPrizePoolWinView:OnBtnCheckClick()
	local ViewModel = OpsActivityTreasureChestPanelVM
	if ViewModel.VideoNode then
        _G.UIViewMgr:ShowView(_G.UIViewID.CommonVideoPlayerView, {VideoPath = ViewModel.VideoNode.StrParam})
    else
		if ViewModel.FinalAwardSuitID and ViewModel.FinalAwardSuitID ~= 0 then
			_G.PreviewMgr:OpenPreviewView(ViewModel.FinalAwardSuitID)
		else
			_G.PreviewMgr:OpenPreviewView(ViewModel.FinalAwardItemID)
		end
	end
end


return OpsActivityPrizePoolWinView