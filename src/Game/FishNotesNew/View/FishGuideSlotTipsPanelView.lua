---
--- Author: v_vvxinchen
--- DateTime: 2025-01-06 10:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TipsUtil = require("Utils/TipsUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local FishGuideVM = require("Game/FishNotes/FishGuideVM")
local ProtoRes = require("Protocol/ProtoRes")

---@class FishGuideSlotTipsPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnChat UFButton
---@field BtnFishSwitch UFButton
---@field BtnInherit UFButton
---@field ClockEmpty CommBackpackEmptyView
---@field FishDetail UFCanvasPanel
---@field FishGuidePlaceI FishGuidePlaceItemView
---@field IconTips UFImage
---@field ImgFish UFImage
---@field ImgFish2 UFImage
---@field ImgFishBg1 UFImage
---@field ImgFishBg2 UFImage
---@field ImgFishDetailBg UFImage
---@field ImgInch UFImage
---@field InheritTips UFCanvasPanel
---@field PanelFish1 UFCanvasPanel
---@field PanelFish2 UFCanvasPanel
---@field TextFishDetail UFTextBlock
---@field TextFishName URichTextBox
---@field TextFishNumber UFTextBlock
---@field TextFishSeaboard UFTextBlock
---@field TextInherit UFTextBlock
---@field TextLevel UFTextBlock
---@field TextMaxSize UFTextBlock
---@field TextNumber UFTextBlock
---@field TextSize UFTextBlock
---@field TextTime UFTextBlock
---@field TextTips UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimInheritTips UWidgetAnimation
---@field AnimSwitchOff UWidgetAnimation
---@field AnimSwitchOn UWidgetAnimation
---@field AnimUpdate UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishGuideSlotTipsPanelView = LuaClass(UIView, true)

function FishGuideSlotTipsPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnChat = nil
	--self.BtnFishSwitch = nil
	--self.BtnInherit = nil
	--self.ClockEmpty = nil
	--self.FishDetail = nil
	--self.FishGuidePlaceI = nil
	--self.IconTips = nil
	--self.ImgFish = nil
	--self.ImgFish2 = nil
	--self.ImgFishBg1 = nil
	--self.ImgFishBg2 = nil
	--self.ImgFishDetailBg = nil
	--self.ImgInch = nil
	--self.InheritTips = nil
	--self.PanelFish1 = nil
	--self.PanelFish2 = nil
	--self.TextFishDetail = nil
	--self.TextFishName = nil
	--self.TextFishNumber = nil
	--self.TextFishSeaboard = nil
	--self.TextInherit = nil
	--self.TextLevel = nil
	--self.TextMaxSize = nil
	--self.TextNumber = nil
	--self.TextSize = nil
	--self.TextTime = nil
	--self.TextTips = nil
	--self.AnimIn = nil
	--self.AnimInheritTips = nil
	--self.AnimSwitchOff = nil
	--self.AnimSwitchOn = nil
	--self.AnimUpdate = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishGuideSlotTipsPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ClockEmpty)
	self:AddSubView(self.FishGuidePlaceI)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishGuideSlotTipsPanelView:OnInit()
	--self.PlaceListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewPlace, nil, false, false)

	self.Binders = {
		{"SelectFishName", UIBinderSetText.New(self, self.TextFishName)},
		--{"SelectFishNameColor", UIBinderSetColorAndOpacityHex.New(self, self.TextFishName)},
		{"SelectFishLevel", UIBinderSetText.New(self, self.TextLevel)},
		{"SelectFishSeaboard", UIBinderSetText.New(self, self.TextFishSeaboard)},
		{"SelectFishNumberID", UIBinderSetText.New(self, self.TextNumber)},
		{"SelectFishDetail", UIBinderSetText.New(self, self.TextFishDetail)},
		{"SelectFishNumber", UIBinderSetText.New(self, self.TextFishNumber)},
		{"SelectFishSize", UIBinderSetText.New(self, self.TextSize)},
		{"SelectFishSizeTime", UIBinderSetText.New(self, self.TextTime)},
		{"bSelectFishDetailVisible", UIBinderSetIsVisible.New(self, self.FishDetail)},
		{"FishUnlockText", UIBinderSetText.New(self, self.ClockEmpty.RichTextNoneBright)},
		{"bInheritVisible", UIBinderSetIsVisible.New(self, self.BtnInherit, false, true)},
		{"bInheritVisible", UIBinderSetIsVisible.New(self, self.TextInherit)},
		{"bFishUnlockVisible", UIBinderSetIsVisible.New(self, self.ClockEmpty)},
		{"FishIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgFish)},
		{"QualityIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgFishBg1)},
		{"PrintingPicture", UIBinderSetBrushFromAssetPath.New(self, self.ImgFishBg2)},
		{"bInheritTipsVisible", UIBinderSetIsVisible.New(self, self.InheritTips)},
		{"InheritTipsText", UIBinderSetText.New(self, self.TextTips)},
		{"InchIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgInch)},
		--{"FishSwitchState", UIBinderValueChangedCallback.New(self, nil, self.OnFishSwitchState)},
	}
end

function FishGuideSlotTipsPanelView:OnDestroy()

end

function FishGuideSlotTipsPanelView:OnShow()
	self.TextInherit:SetText(_G.LSTR(180089))--"传承录："
	self.TextMaxSize:SetText(_G.LSTR(180060))--最大尺寸：
	self.FishGuidePlaceI.TextPlace:SetText(_G.LSTR(1120059))--"获取途径"
	UIUtil.SetIsVisible(self.BtnChat, false)
	UIUtil.SetIsVisible(self.ImgFish2, false)
	UIUtil.SetIsVisible(self.BtnFishSwitch, false)
end

function FishGuideSlotTipsPanelView:OnHide()

end

function FishGuideSlotTipsPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnChat, self.OnClickButtonComment)
	UIUtil.AddOnClickedEvent(self, self.BtnInherit, self.OnClickButtonInherit)
	UIUtil.AddOnClickedEvent(self, self.BtnFishSwitch, self.OnClickButtonFishSwitch)
	UIUtil.AddOnClickedEvent(self, self.FishGuidePlaceI.BtnPlace, self.OnClickButtonPlace)
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

function FishGuideSlotTipsPanelView:OnClickButtonFishSwitch()
	FishGuideVM.FishSwitchState = not FishGuideVM.FishSwitchState
end

function FishGuideSlotTipsPanelView:OnFishSwitchState(FishSwitchState)
	if FishSwitchState == true then
		self:PlayAnimation(self.AnimSwitchOff)
	else
		self:PlayAnimation(self.AnimSwitchOn)
	end
end

function FishGuideSlotTipsPanelView:OnClickButtonPlace()
	local HauntList = FishGuideVM.HauntList
	local DataList = {}
	for _, Place in pairs(HauntList) do
		local bLock = _G.FishNotesMgr:CheckFishLocationbLock(Place.ID)
		if not bLock then
			table.insert(DataList, {
				FunIcon = _G.FishNotesMgr:GetFactionIconByLocationID(Place.ID),
				FunDesc = Place.Name,
				IsUnLock = true,
				IsRedirect = 1,
				ItemID = FishGuideVM.SelectFishItemID,
				LocationInfo = Place,
				ItemAccessFunType = ProtoRes.ItemAccessFunType.Fun_Fishing,
				CanRevealPlot = true
			})
		end
	end
	table.sort(DataList, function(a, b)
		return a.IsRedirect > b.IsRedirect
	end)
	local Len = #DataList
    local Num = Len >= 6 and 5.5 or Len
	local Y = Len > 4 and -100 * (Num - 4) or 0
	local TipsWayView = TipsUtil.ShowGetWayTips(FishGuideVM, nil, self.FishGuidePlaceI, _G.UE.FVector2D(2, Y - 2))
	TipsWayView:UpdateView(DataList)
end

return FishGuideSlotTipsPanelView