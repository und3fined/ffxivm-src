---
--- Author: Administrator
--- DateTime: 2025-08-13 10:36
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local StarlightCelebrationTaskPanelVM = require("Game/StarlightCelebration/VM/StarlightCelebrationTaskPanelVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class StarlightCelebrationTaskPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field CloseBtn CommonCloseBtnView
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field FImage_339 UFImage
---@field PanelNormal UFCanvasPanel
---@field PanelUnLock UFCanvasPanel
---@field TableViewReward UTableView
---@field TableViewTab UTableView
---@field TextContent UFTextBlock
---@field TextNormal UFTextBlock
---@field TextReward UFTextBlock
---@field TextTitle UFTextBlock
---@field Textunlock UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StarlightCelebrationTaskPanelView = LuaClass(UIView, true)

function StarlightCelebrationTaskPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.CloseBtn = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.FImage_339 = nil
	--self.PanelNormal = nil
	--self.PanelUnLock = nil
	--self.TableViewReward = nil
	--self.TableViewTab = nil
	--self.TextContent = nil
	--self.TextNormal = nil
	--self.TextReward = nil
	--self.TextTitle = nil
	--self.Textunlock = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StarlightCelebrationTaskPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StarlightCelebrationTaskPanelView:OnInit()
	self.ViewModel = StarlightCelebrationTaskPanelVM.New()
	self.TaskListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTab, self.OnClickTaskItem, false)

	self.RewardListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewReward)
	self.RewardListAdapter:SetOnClickedCallback(self.onClickRewardIcon)

	self.Binders = {
		{"TaskListList", UIBinderUpdateBindableList.New(self, self.TaskListAdapter)},
		{"RewardList", UIBinderUpdateBindableList.New(self, self.RewardListAdapter)},
		
        {"TitleText", UIBinderSetText.New(self, self.TextTitle)},
       	{"TaskDescText", UIBinderSetText.New(self, self.TextContent)},
		{"RewardTitleText", UIBinderSetText.New(self, self.TextReward)},

		{"UnlockText", UIBinderSetText.New(self, self.Textunlock)},
		{"NormalText", UIBinderSetText.New(self, self.TextNormal)},

		{"BannerImg", UIBinderSetBrushFromAssetPath.New(self, self.FImage_339)},
		
		{"NormalVisible", UIBinderSetIsVisible.New(self, self.PanelNormal)},
		{"UnLockVisible", UIBinderSetIsVisible.New(self, self.PanelUnLock)},
    }
end

function StarlightCelebrationTaskPanelView:OnDestroy()

end

function StarlightCelebrationTaskPanelView:OnShow()
	if self.Params == nil then
		return
	end

	self.ViewModel:Update(self.Params)

	local CurIndex = 1
	for i = 1, #self.Params do
		local Node =  self.Params[i]
		CurIndex = i
		if Node.Head.Finished == false then
			break
		end
    end
	self.TaskListAdapter:SetSelectedIndex(CurIndex)
end

function StarlightCelebrationTaskPanelView:OnHide()

end

function StarlightCelebrationTaskPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickGotoBtn)
end

function StarlightCelebrationTaskPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.MapFollowAdd, self.Hide)
	self:RegisterGameEvent(_G.EventID.CrystalTransferReq, self.Hide)
end

function StarlightCelebrationTaskPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function StarlightCelebrationTaskPanelView:OnClickTaskItem(Index, ItemData, ItemView)
	local PreNode = Index > 1 and self.Params[Index -1] or nil
	self.ViewModel:SetTaskTabSelected(Index)
	self.ViewModel:SetTaskInfo(Index, self.Params[Index], PreNode)
end

function StarlightCelebrationTaskPanelView:onClickRewardIcon(Index, ItemData, ItemView)
	if ItemData.ResID ~= nil then
		local ItemTipsUtil = require("Utils/ItemTipsUtil")
		ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView)
	end
end

function StarlightCelebrationTaskPanelView:OnClickGotoBtn()
	self.ViewModel:JumpTo()
end

return StarlightCelebrationTaskPanelView