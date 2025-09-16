---
--- Author: Administrator
--- DateTime: 2024-04-24 15:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBindableList = require("UI/UIBindableList")
local GuideAwardItemVM = require("Game/Guide/VM/ItemVM/GuideAwardItemVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

local LSTR = _G.LSTR

---@class GuideAwardWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CloseBtn CommonCloseBtnView
---@field RetainerBoxMask URetainerBox
---@field SwitchCategory UFWidgetSwitcher
---@field TableViewTab UTableView
---@field TextCurrent UFTextBlock
---@field TextPlace UFTextBlock
---@field TextQuantity UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimMainLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GuideAwardWinView = LuaClass(UIView, true)

function GuideAwardWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CloseBtn = nil
	--self.RetainerBoxMask = nil
	--self.SwitchCategory = nil
	--self.TableViewTab = nil
	--self.TextCurrent = nil
	--self.TextPlace = nil
	--self.TextQuantity = nil
	--self.AnimIn = nil
	--self.AnimMainLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GuideAwardWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GuideAwardWinView:OnInit()
	self.AwardAdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewTab, self.OnCardAwardSelectChanged, true, false)
	self.CategoryWidgetIndex = {
		[UIViewID.MagicCardCollectionMainPanel] = 0, --幻卡图鉴
		[UIViewID.FateArchiveMainPanel] = 1,  -- 临危受命图鉴
		[UIViewID.ChocoboCodexArmorPanelView] = 2, -- 陆行鸟图鉴
		[UIViewID.MusicAtlasMainView] = 3, --乐谱图鉴
	}
end

function GuideAwardWinView:OnDestroy()

end

function GuideAwardWinView:RefreshData(InParams)
	self.Params = InParams
	if (self.Params == nil) then
		FLOG_ERROR("传入的数据为空，请检查")
		return
	end
	self.AwardList = self.Params.AwardList
	if (self.AwardVMList ~= nil) then
		for Index = 1, #self.AwardVMList.Items do
			self.AwardVMList.Items[Index]:UpdateVM(self.Params.AwardList[Index])
		end
	end
end

function GuideAwardWinView:RefreshTitle()
	local CurCollectNum = self.Params.CollectedNum
	local MaxCollectNum = self.Params.MaxCollectNum
	if CurCollectNum then
		local CollectProgressText 
		if MaxCollectNum then
			CollectProgressText = string.format("%s / %s", CurCollectNum, MaxCollectNum)
		else
			CollectProgressText = tostring(CurCollectNum)
		end
		self.TextQuantity:SetText(CollectProgressText)
	end
end

function GuideAwardWinView:OnShow()
	self:UpdateEffect()
	if self.Params == nil then
		return
	end

	local ModuleID = self.Params.ModuleID
	UIUtil.SetIsVisible(self.SwitchCategory, ModuleID ~= nil)
	if ModuleID then
		local WidgetIndex = self.CategoryWidgetIndex[ModuleID]
		if WidgetIndex then
			self.SwitchCategory:SetActiveWidgetIndex(self.CategoryWidgetIndex[ModuleID])
		end
	end

	local CurCollectNum = self.Params.CollectedNum
	local MaxCollectNum = self.Params.MaxCollectNum
	if CurCollectNum then
		local CollectProgressText 
		if MaxCollectNum then
			CollectProgressText = string.format("%s / %s", CurCollectNum, MaxCollectNum)
		else
			CollectProgressText = tostring(CurCollectNum)
		end
		self.TextQuantity:SetText(CollectProgressText)
	end

	self.AwardList = self.Params.AwardList
	if self.AwardList then
		if (self.Params.ItemClickCallback ~= nil) then
			local ClickCallback = self.Params.ItemClickCallback
			for Index = 1, #self.AwardList do
				self.AwardList[Index].ItemClickCallback = function(InCallbackView, InItemView)
					ClickCallback(Index, self.AwardList[Index], InItemView)
				end
			end
		end
		self.AwardVMList = UIBindableList.New(GuideAwardItemVM)
		self.AwardVMList:UpdateByValues(self.AwardList, nil)
		self.AwardAdapterTableView:UpdateAll(self.AwardVMList)
		self.AwardAdapterTableView:SetScrollEnabled(not (#self.AwardList < 6))
		self.AwardSelectIndex = self.Params.AwardSelectIndex
		self.AwardAdapterTableView:ScrollToIndex(self.AwardSelectIndex)
	end

	local AreaName = self.Params.AreaName
	if not string.isnilorempty(AreaName) then
		UIUtil.SetIsVisible(self.TextPlace, true)
		self.TextPlace:SetText(AreaName)
	else
		UIUtil.SetIsVisible(self.TextPlace, false)
	end

	local CurrentName = self.Params.TextCurrent
	if not string.isnilorempty(CurrentName) then
		self.TextCurrent:SetText(CurrentName)
	else
		self.TextCurrent:SetText(LSTR(1180002))
	end

	self.OnGetAwardCallBack = self.Params.OnGetAwardCallBack
	self.IgnoreIsGetProgress = self.Params.IgnoreIsGetProgress
	self.bCancelAutoGet = self.Params.bCancelAutoGet
end

function GuideAwardWinView:OnHide()

end

function GuideAwardWinView:OnRegisterUIEvent()
	
end

function GuideAwardWinView:OnRegisterGameEvent()

end

function GuideAwardWinView:OnRegisterBinder()
end

function GuideAwardWinView:OnCardAwardSelectChanged(Index, ItemData, ItemView)
	if self.AwardList == nil then
		return
	end

	if self.OnGetAwardCallBack then
		self.OnGetAwardCallBack(Index, ItemData, ItemView)
	end
	
	if (not self.bCancelAutoGet) then
		if ItemData.IsGetProgress and not self.IgnoreIsGetProgress then
			local SelectAward = self.AwardList[Index]
			SelectAward.IsGetProgress = false
			SelectAward.IsCollectedAward = true
			self.AwardVMList:UpdateByValues(self.AwardList, nil)
			self.AwardAdapterTableView:UpdateAll(self.AwardVMList)
		end
	end
end

function GuideAwardWinView:UpdateEffect()
	local Animation = self:GetAnimIn()
	if self.AnimMainLoop == nil then
		return
	end

	if Animation == nil then
		return
	end

	local EndTime = Animation:GetEndTime()
	self:RegisterTimer(
		function()
			self:PlayAnimation(self.AnimMainLoop, 0, 0)
		end,
	EndTime, 0, 1)
end

return GuideAwardWinView