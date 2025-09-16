---
--- Author: Administrator
--- DateTime: 2024-02-22 15:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local WardrobeAppearancePanelVM = require("Game/Wardrobe/VM/WardrobeAppearancePanelVM")
local WardrobeMgr = require("Game/Wardrobe/WardrobeMgr")
local UKismetInputLibrary = _G.UE.UKismetInputLibrary

local EventID = _G.EventID

---@class WardrobeAppearancePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field BtnInfo CommInforBtnView
---@field BtnTreasure UFButton
---@field CommonBkg CommonBkg01View
---@field EFF_ProBar UFCanvasPanel
---@field EFF_Treasure UFCanvasPanel
---@field ImgBg UFImage
---@field ImgCharm UFImage
---@field ImgCollectBg UFImage
---@field ImgTreasure UFImage
---@field MI_DX_Common_Wardrobe_9 UFImage
---@field M_DX_Wardrobe_3 UFImage
---@field PanelBg UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field ProgressBar_67 UProgressBar
---@field ScaleBox UScaleBox
---@field TableViewBag UTableView
---@field TableViewBox UTableView
---@field TextCharm UFTextBlock
---@field TextCharmNum UFTextBlock
---@field TextCharmNum2 UFTextBlock
---@field TextCollect UFTextBlock
---@field TextSubtitle URichTextBox
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeAppearancePanelView = LuaClass(UIView, true)

function WardrobeAppearancePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.BtnInfo = nil
	--self.BtnTreasure = nil
	--self.CommonBkg = nil
	--self.EFF_ProBar = nil
	--self.EFF_Treasure = nil
	--self.ImgBg = nil
	--self.ImgCharm = nil
	--self.ImgCollectBg = nil
	--self.ImgTreasure = nil
	--self.MI_DX_Common_Wardrobe_9 = nil
	--self.M_DX_Wardrobe_3 = nil
	--self.PanelBg = nil
	--self.PanelTips = nil
	--self.ProgressBar_67 = nil
	--self.ScaleBox = nil
	--self.TableViewBag = nil
	--self.TableViewBox = nil
	--self.TextCharm = nil
	--self.TextCharmNum = nil
	--self.TextCharmNum2 = nil
	--self.TextCollect = nil
	--self.TextSubtitle = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeAppearancePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.BtnInfo)
	self:AddSubView(self.CommonBkg)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeAppearancePanelView:OnInit()
	-- 装备菜单列表
	self.VM = WardrobeAppearancePanelVM.New()
	self.BoxListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewBox)
	self.RewardListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewBag, self.OnSelectedItem, true)

	self.Binders = {
		{ "BoxList",  UIBinderUpdateBindableList.New(self, self.BoxListAdapter)},
		{ "RewardList", UIBinderUpdateBindableList.New(self, self.RewardListAdapter)},
		{ "CurCharismNum", UIBinderSetText.New(self, self.TextCharmNum2)},
		{ "TotalCharismNum", UIBinderSetText.New(self, self.TextCharmNum)},
		{ "CharismPercent", UIBinderSetPercent.New(self, self.ProgressBar_67)},
		{ "TipsPanelVisible", UIBinderSetIsVisible.New(self, self.PanelTips)},
		{ "ProgressBarEff", UIBinderSetIsVisible.New(self, self.EFF_ProBar)},
		{ "TreasureEff", UIBinderSetIsVisible.New(self, self.EFF_Treasure)},
	}
end

function WardrobeAppearancePanelView:OnDestroy()

end

function WardrobeAppearancePanelView:OnShow()

	self.VM.TipsPanelVisible = false
	self.VM:UpdateBoxList()
	self.VM:UpdateRewardList(WardrobeMgr:GetClaimedCharismReward() + 1)

	self.BtnBack:AddBackClick(self, function ()  self:Hide() end)

	self.VM:UpdateReward()
	self.VM:UpdateBaseInfo()

	self:InitText()
end

function WardrobeAppearancePanelView:InitText()
	self.TextCollect:SetText(_G.LSTR(1080097))
	self.TextCharm:SetText(_G.LSTR(1080096))
	self.TextTitle:SetText(_G.LSTR(1080095))
end

function WardrobeAppearancePanelView:OnHide()

end

function WardrobeAppearancePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnTreasure, self.OnClickedBtnTreasure)
	-- UIUtil.AddOnClickedEvent(self, self.BtnInfo, self.OnClickedBtnInfo)
end

function WardrobeAppearancePanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.WardrobeCollectReward, self.OnWardrobeCollectReward)
	self:RegisterGameEvent(EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
	self:RegisterGameEvent(EventID.WardrobeCharismValueUpdate, self.OnWardrobeCharismValueUpdate)
end

function WardrobeAppearancePanelView:OnRegisterBinder()
	self:RegisterBinders(self.VM, self.Binders)
end

function WardrobeAppearancePanelView:OnSelectedItem(Index, ItemData, ItemView)
	local ID = ItemData.ResID
	-- self:RegisterTimer( function ()
		ItemTipsUtil.ShowTipsByResID(ID, self.PanelTips, _G.UE.FVector2D(11, 0))
	-- end, 0.3, 0, 1)
end

function WardrobeAppearancePanelView:OnClickedBtnTreasure()
	local CharismValue = WardrobeMgr:GetCharismNum()
	local CharismTotalValue = WardrobeMgr:GetCharismTotalNum() 
	if CharismValue < CharismTotalValue then
		self.VM.TipsPanelVisible = not self.VM.TipsPanelVisible
	else
		if not WardrobeMgr:IsExceedCfgLevel() then
			local CurRewardID = WardrobeMgr:GetClaimedCharismReward()
			WardrobeMgr:SendClosetCharismRewardReq(CurRewardID + 1)
		end
	end
end

function WardrobeAppearancePanelView:OnClickedBtnInfo()
end

function WardrobeAppearancePanelView:OnWardrobeCollectReward()
	self.VM:UpdateRewardList(WardrobeMgr:GetClaimedCharismReward() + 1)
	self.VM:UpdateReward()
end

function WardrobeAppearancePanelView:OnWardrobeCharismValueUpdate()
	self.VM:UpdateBaseInfo()
end 

function  WardrobeAppearancePanelView:OnPreprocessedMouseButtonDown(MouseEvent)
	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.PanelTips, MousePosition) == false then
		self.VM.TipsPanelVisible = false
	end
end

return WardrobeAppearancePanelView