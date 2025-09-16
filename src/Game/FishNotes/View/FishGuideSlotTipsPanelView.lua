---
--- Author: Administrator
--- DateTime: 2023-03-27 18:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

local FishGuideVM = require("Game/FishNotes/FishGuideVM")

---@class FishGuideSlotTipsPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnChat UFButton
---@field BtnInherit UFButton
---@field ClockEmpty CommEmptyView
---@field FishDetail UFCanvasPanel
---@field IconTips UFImage
---@field ImgFish UFImage
---@field ImgInch UFImage
---@field InheritTips UFCanvasPanel
---@field TableViewPlace UTableView
---@field TextCumulativeQuantity UFTextBlock
---@field TextFishDetail UFTextBlock
---@field TextFishName URichTextBox
---@field TextFishNumber UFTextBlock
---@field TextFishSeaboard UFTextBlock
---@field TextInch UFTextBlock
---@field TextLevel UFTextBlock
---@field TextMaxSize UFTextBlock
---@field TextNumber UFTextBlock
---@field TextQuantity UFTextBlock
---@field TextSize UFTextBlock
---@field TextTips UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimInheritTips UWidgetAnimation
---@field AnimUpdate UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishGuideSlotTipsPanelView = LuaClass(UIView, true)

function FishGuideSlotTipsPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnChat = nil
	--self.BtnInherit = nil
	--self.ClockEmpty = nil
	--self.FishDetail = nil
	--self.IconTips = nil
	--self.ImgFish = nil
	--self.ImgInch = nil
	--self.InheritTips = nil
	--self.TableViewPlace = nil
	--self.TextCumulativeQuantity = nil
	--self.TextFishDetail = nil
	--self.TextFishName = nil
	--self.TextFishNumber = nil
	--self.TextFishSeaboard = nil
	--self.TextInch = nil
	--self.TextLevel = nil
	--self.TextMaxSize = nil
	--self.TextNumber = nil
	--self.TextQuantity = nil
	--self.TextSize = nil
	--self.TextTips = nil
	--self.AnimIn = nil
	--self.AnimInheritTips = nil
	--self.AnimUpdate = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishGuideSlotTipsPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ClockEmpty)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishGuideSlotTipsPanelView:OnInit()
	self.PlaceListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewPlace, nil, false, false)

	self.Binders = {
		{"SelectFishName", UIBinderSetText.New(self, self.TextFishName)},
		{"SelectFishNameColor", UIBinderSetColorAndOpacityHex.New(self, self.TextFishName)},

		{"SelectFishLevel", UIBinderSetText.New(self, self.TextLevel)},
		{"SelectFishSeaboard", UIBinderSetText.New(self, self.TextFishSeaboard)},
		{"SelectFishNumberID", UIBinderSetText.New(self, self.TextNumber)},
		{"SelectFishDetail", UIBinderSetText.New(self, self.TextFishDetail)},
		{"SelectFishQuantity", UIBinderSetText.New(self, self.TextQuantity)},
		{"SelectFishSize", UIBinderSetText.New(self, self.TextSize)},
		{"bSelectFishDetailVisible", UIBinderSetIsVisible.New(self, self.FishDetail)},
		{"FishUnlockText", UIBinderSetText.New(self, self.ClockEmpty.Text_SearchAgain)},
		{"bInheritVisible", UIBinderSetIsVisible.New(self, self.BtnInherit, false, true)},
		{"bFishUnlockVisible", UIBinderSetIsVisible.New(self, self.ClockEmpty)},
		{"PrintingPicture", UIBinderSetBrushFromAssetPath.New(self, self.ImgFish)},

		{"SelectFishPlaceList", UIBinderUpdateBindableList.New(self, self.PlaceListAdapter)},
		{"bInheritTipsVisible", UIBinderSetIsVisible.New(self, self.InheritTips)},
		{"InheritTipsText", UIBinderSetText.New(self, self.TextTips)},
		
	}
end

function FishGuideSlotTipsPanelView:OnDestroy()

end

function FishGuideSlotTipsPanelView:OnShow()
	self.TextFishNumber:SetText(_G.LSTR(180058))--编号：
	self.TextCumulativeQuantity:SetText(_G.LSTR(180059))--累计数量：
	self.TextMaxSize:SetText(_G.LSTR(180060))--最大尺寸：
	self.TextInch:SetText(_G.LSTR(180061))--星寸
	----story=116392129 【系统】【留言板图鉴】屏蔽所有留言板功能的入口
	UIUtil.SetIsVisible(self.BtnChat,false)
end

function FishGuideSlotTipsPanelView:OnHide()

end

function FishGuideSlotTipsPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnChat, self.OnClickButtonComment)
	UIUtil.AddOnClickedEvent(self, self.BtnInherit, self.OnClickButtonInherit)
end

function FishGuideSlotTipsPanelView:OnRegisterGameEvent()
end

function FishGuideSlotTipsPanelView:OnRegisterBinder()
	self:RegisterBinders(FishGuideVM, self.Binders)
end

function FishGuideSlotTipsPanelView:OnClickButtonComment()
	FishGuideVM:CommentViewChanged(true)
end

function FishGuideSlotTipsPanelView:OnClickButtonInherit()
	FishGuideVM:ChangeInheritDisplayState()
	if FishGuideVM.bInheritTipsVisible then
		self:PlayAnimation(self.AnimInheritTips)
	end 
end

return FishGuideSlotTipsPanelView