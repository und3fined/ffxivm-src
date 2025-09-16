---
--- Author: Administrator
--- DateTime: 2024-04-01 09:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetOutlineColor = require("Binder/UIBinderSetOutlineColor")
local FootPrintDefine = require("Game/FootPrint/FootPrintDefine")
local FootPrintMgr = require("Game/FootPrint/FootPrintMgr")
local FootPrintVM = require("Game/FootPrint/FootPrintVM")
local ScheduleTextContent = FootPrintDefine.ScheduleTextContent

---@class FootPrintBottleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FCanvasPanel_1 UFCanvasPanel
---@field Icon UFImage
---@field Icon2 UFImage
---@field ImgArea UFImage
---@field ImgBG UFImage
---@field ImgStamp UFImage
---@field PanelLighted UFCanvasPanel
---@field PanelSchedule UFCanvasPanel
---@field RedDot CommonRedDotView
---@field TextTime UFTextBlock
---@field TextTitle UFTextBlock
---@field TexxtSchedule UFTextBlock
---@field AnimBack UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimInLoop UWidgetAnimation
---@field AnimLight UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FootPrintBottleItemView = LuaClass(UIView, true)

function FootPrintBottleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FCanvasPanel_1 = nil
	--self.Icon = nil
	--self.Icon2 = nil
	--self.ImgArea = nil
	--self.ImgBG = nil
	--self.ImgStamp = nil
	--self.PanelLighted = nil
	--self.PanelSchedule = nil
	--self.RedDot = nil
	--self.TextTime = nil
	--self.TextTitle = nil
	--self.TexxtSchedule = nil
	--self.AnimBack = nil
	--self.AnimIn = nil
	--self.AnimInLoop = nil
	--self.AnimLight = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FootPrintBottleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FootPrintBottleItemView:OnInit()
	self.Binders = {
		{"bMajorAtThisMap", UIBinderSetIsVisible.New(self, self.Icon2)},
		{"RegionName", UIBinderSetText.New(self, self.TextTitle)},
		{"bLighted", UIBinderSetIsVisible.New(self, self.PanelLighted)},
		{"ScheduleText", UIBinderSetText.New(self, self.TexxtSchedule)},
		{"RegionPhotoPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgArea)},
		{"RegionColorPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgBG)},
		{"bShowPanelSchedule", UIBinderSetIsVisible.New(self, self.PanelSchedule)},
		{"RedDotName", UIBinderValueChangedCallback.New(self, nil, self.OnSetItemRedDotName)},
		{"IsRegionUnlock", UIBinderValueChangedCallback.New(self, nil, self.OnLockStateChanged)},
		{"CompleteTimeText", UIBinderSetText.New(self, self.TextTime)},
		{"CompleteIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgStamp)},
		{"CompleteTimeTextOutlineColor", UIBinderSetOutlineColor.New(self, self.TextTime)},
		--{"bLighted", UIBinderValueChangedCallback.New(self, nil, self.OnPlayRegionLightedAnim)},
		--{"IsRegionUnlock", UIBinderSetIsVisible.New(self, self.ImgArea, true)}, -- 添加未解锁的绑定
	}
end

function FootPrintBottleItemView:OnDestroy()

end

function FootPrintBottleItemView:OnShow()

end

function FootPrintBottleItemView:OnHide()

end

function FootPrintBottleItemView:OnRegisterUIEvent()
	
end

function FootPrintBottleItemView:OnRegisterGameEvent()

end

function FootPrintBottleItemView:OnRegisterBinder()
	local Params = self.Params
	if not Params then
		return
	end

	local ViewModel = Params.Data
	if not ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function FootPrintBottleItemView:OnLockStateChanged(NewState)
	local TextFormatInfo = NewState and ScheduleTextContent.Unlock or ScheduleTextContent.Locked
	UIUtil.SetColorAndOpacityHex(self.TexxtSchedule, TextFormatInfo.Color)
	UIUtil.ImageSetBrushFromAssetPath(self.Icon, TextFormatInfo.Icon)
end

function FootPrintBottleItemView:OnSetItemRedDotName(Name, OldValue)
	if Name == OldValue then
		return
	end
	self.RedDot:SetRedDotNameByString(Name)
end

--- 是否需要播放AnimBack动画
---@return boolean@是否播放成功
function FootPrintBottleItemView:OnPlayRegionLightedAnim()
	local Params = self.Params
	if not Params then
		return
	end

	local ViewModel = Params.Data
	if not ViewModel then
		return
	end

	local bLighted = ViewModel.bLighted
	if not bLighted then
		return
	end--]]

	local CurLightRegionID = FootPrintMgr.CurLightRegionID
	if not CurLightRegionID or CurLightRegionID ~= ViewModel.RegionID then
		return
	end

	self:PlayAnimation(self.AnimBack)
	FootPrintMgr.CurLightRegionID = nil
	return true
end

--- 重写AnimIn方法，控制播放时机
function FootPrintBottleItemView:PlayAnimIn()
	local AnimIn = self.AnimIn
	if not AnimIn then
		return
	end

	local Params = self.Params
	if not Params then
		return
	end

	local ViewModel = Params.Data
	if not ViewModel then
		return
	end

	local bNeed = ViewModel.bNeedPlayAnimIn
	local bAnimBackPlayed = self:OnPlayRegionLightedAnim()
	if bNeed and not bAnimBackPlayed then
		self.Super:PlayAnimIn()
	end
end

return FootPrintBottleItemView