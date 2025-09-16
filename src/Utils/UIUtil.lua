--
-- Author: anypkvcai
-- Date: 2020-08-05 14:31:31
-- Description:
--

local GameplayStaticsUtil = require("Utils/GameplayStaticsUtil")
local ObjectGCType = require("Define/ObjectGCType")
local TimeUtil = require("Utils/TimeUtil")
local CommonUtil = require("Utils/CommonUtil")
local UTF8Util = require("Utils/UTF8Util")
local UUIUtil = _G.UE.UUIUtil
local ESlateVisibility = _G.UE.ESlateVisibility
--local USlateBlueprintLibrary = _G.UE.USlateBlueprintLibrary
local UWidgetBlueprintLibrary = _G.UE.UWidgetBlueprintLibrary
local UWidgetLayoutLibrary = _G.UE.UWidgetLayoutLibrary
local EToggleButtonState = _G.UE.EToggleButtonState
local FVector2D = _G.UE.FVector2D
local FLinearColor = _G.UE.FLinearColor

local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_ERROR = _G.FLOG_ERROR
local BottomMargin = 12

local GrayMask = "Texture2D'/Game/UMG/UI_Effect/Textures/Basic/T_DX_Basic_2.T_DX_Basic_2'"	--方形

---@class UIUtil
local UIUtil = {
	DesignedSize = nil

}

function UIUtil.GetDesignedSize()
	if nil == UIUtil.DesignedSize then
		UIUtil.DesignedSize = _G.UE.UFDPICustomScalingRule.GetDesignedSize()
	end

	return UIUtil.DesignedSize
end

---SetIsVisible
---@param Widget UWidget
---@param bVisible boolean @是否可见
---@param IsHitTestVisible boolean  @为true时 可见性设置为ESlateVisibility.Visible 主要是按钮这种需要响应事件的
---@param IsHidden boolean @为true时 可见性设置为ESlateVisibility.Hidden 主要用在隐藏是仍需要占用空间的情况
function UIUtil.SetIsVisible(Widget, bVisible, IsHitTestVisible, IsHidden)
	if nil == Widget then
		FLOG_WARNING("UIUtil.SetIsVisible Widget is nil traceback=%s", debug.traceback())
		return
	end

	if not Widget:IsValid() then
		return
	end

	if bVisible then
		local Visibility = IsHitTestVisible and ESlateVisibility.Visible or ESlateVisibility.SelfHitTestInvisible
		Widget:SetVisibility(Visibility)
	else
		local Visibility = IsHidden and ESlateVisibility.Hidden or ESlateVisibility.Collapsed
		Widget:SetVisibility(Visibility)
	end

	--[[
	-- 隐藏会播放AnimOut动画后才隐藏 正在播放隐藏动画时判断可见性是否相同不准确
	local OldVisibility = Widget:GetVisibility()

	if bVisible then
		local Visibility = IsHitTestVisible and ESlateVisibility.Visible or ESlateVisibility.SelfHitTestInvisible
		if Visibility ~= OldVisibility then
			Widget:SetVisibility(Visibility)
		end
	else
		local Visibility = ESlateVisibility.Collapsed
		if Visibility ~= OldVisibility then
			Widget:SetVisibility(Visibility)
		end
	end
	--]]
end

---CheckVisible
---@param Visibility ESlateVisibility
function UIUtil.CheckVisible(Visibility)

	if ESlateVisibility.Visible == Visibility then
		return true
	end

	if ESlateVisibility.SelfHitTestInvisible == Visibility then
		return true
	end

	return false
end

---IsVisible
---@param Widget UWidget
function UIUtil.IsVisible(Widget)
	if nil == Widget or not Widget:IsValid() then
		return false
	end

	local Visibility = Widget:GetVisibility()

	return UIUtil.CheckVisible(Visibility)
end

---SetColorAndOpacity
---@param InObject UTextBlock | UImage| UButton
---@param InR number            @0~1
---@param InG number            @0~1
---@param InB number            @0~1
---@param InA number            @0~1
function UIUtil.SetColorAndOpacity(InObject, InR, InG, InB, InA)
	if nil == InObject then
		FLOG_WARNING("UIUtil.SetColorAndOpacity Object is nil")
		return
	end

	local LinearColor = FLinearColor(InR, InG, InB, InA)
	InObject:SetColorAndOpacity(LinearColor)
end

---SetBackgroundColor
---@param InObject UButton
---@param InR number            @0~1
---@param InG number            @0~1
---@param InB number            @0~1
---@param InA number            @0~1
function UIUtil.SetBackgroundColor(InObject, InR, InG, InB, InA)
	if nil == InObject then
		FLOG_WARNING("UIUtil.SetBackgroundColor Object is nil")
		return
	end

	local LinearColor = FLinearColor(InR, InG, InB, InA)
	InObject:SetBackgroundColor(LinearColor)
end

---SetColorAndOpacityHex
---@param InObject UTextBlock | UImage| UButton
---@param InColorHex string     @"RGBA" example: Red="ff0000ff" Green="00ff00ff" Blue="0000ffff"
function UIUtil.SetColorAndOpacityHex(InObject, InColorHex)
	if nil == InObject then
		FLOG_WARNING("UIUtil.SetColorAndOpacityHex InObject is nil")
		return
	end

	local LinearColor = FLinearColor.FromHex(InColorHex)
	InObject:SetColorAndOpacity(LinearColor)
end

---SetOpacity
---@param InObject UTextBlock | UImage| UButton
---@param InOpacity number @0~1
function UIUtil.SetOpacity(InObject, InOpacity)
	if nil == InObject then
		FLOG_WARNING("UIUtil.SetOpacity InOpacity is nil")
		return
	end

	InObject:SetOpacity(InOpacity)
end

function UIUtil.SetRenderOpacity(InObject, InOpacity)
	if nil == InObject then
		FLOG_WARNING("UIUtil.SetRenderOpacity obj is nil")
		return
	end

	InObject:SetRenderOpacity(InOpacity)
end

---ImageSetBrushFromAssetPathSync
---@param InImage UImage
---@param InAssetPath string
---@param bIsMatchSize boolean
---@param bNoCache boolean
function UIUtil.ImageSetBrushFromAssetPathSync(InImage, InAssetPath, bIsMatchSize, bNoCache)
	bIsMatchSize = bIsMatchSize or false    --默认参数为false
	if nil == bNoCache then
		bNoCache  = true
	end
	return UUIUtil.ImageSetBrushFromAssetPathSync(InImage, InAssetPath, bIsMatchSize, bNoCache)
end

function UIUtil.AddLongPressFinishTimeEvent(View, Widget, PressFinishCallBack, PressCallBack, LongPressFinishTime)
	local PresStatusType = { Hover = 1, Press = 2, NoPress = 3, None = 4 }
	local PressStatus = PresStatusType.None
	local PressStartTime = 0
	local PressCurrentTime = 0
	local TimeID = 0
	local PressHandleEvent = function()
		PressCurrentTime = TimeUtil.GetLocalTime()
		local PressTime = PressCurrentTime - PressStartTime
		PressCallBack(View, PressTime)
		if PressTime >= LongPressFinishTime then
			PressFinishCallBack(View)
			_G.TimerMgr:CancelTimer(TimeID)
		end
	end
	local PressedEvent = function()
		PressStatus = PresStatusType.Press
		PressStartTime = TimeUtil.GetLocalTime()
		TimeID = _G.TimerMgr:AddTimer(View, PressHandleEvent, 0, 0.3, 0)
	end
	local ReleasedEvent = function()
		PressStatus = PresStatusType.NoPress
		_G.TimerMgr:CancelTimer(TimeID)
	end
	local UnhoveredEvent = function()
		PressStatus = PresStatusType.NoPress
		_G.TimerMgr:CancelTimer(TimeID)
	end
	UIUtil.AddOnPressedEvent(View, Widget, PressedEvent)
	UIUtil.AddOnReleasedEvent(View, Widget, ReleasedEvent)
	UIUtil.AddOnUnhoveredEvent(View, Widget, UnhoveredEvent)
end

---ImageSetBrushFromAssetPath : async load
---@param InImage UImage
---@param InAssetPath string
---@param bIsMatchSize boolean
---@param bNoCache boolean
---@param HideIfAssetPathIsInvalid boolean
function UIUtil.ImageSetBrushFromAssetPath(InImage, InAssetPath, bIsMatchSize, bNoCache, HideIfAssetPathIsInvalid)
	local IsInvalid = nil == InAssetPath or #InAssetPath <= 0
	if HideIfAssetPathIsInvalid then
		UIUtil.SetIsVisible(InImage, not IsInvalid)
	end

	if IsInvalid then
		return
	end

	bIsMatchSize = bIsMatchSize or false    --默认参数为false
	if nil == bNoCache then
		bNoCache  = true
	end
	return UUIUtil.ImageSetBrushFromAssetPath(InImage, InAssetPath, bIsMatchSize, bNoCache)
end

---ImageSetBrushResourceObject : async load
---@param InImage UImage
---@param InResourceObject UObject
---@param bIsMatchSize boolean
function UIUtil.ImageSetBrushResourceObject(InImage, InResourceObject, bIsMatchSize)
	bIsMatchSize = bIsMatchSize or false    --默认参数为false
	return UUIUtil.ImageSetBrushResourceObject(InImage, InResourceObject, bIsMatchSize)
end

---ProjectWorldLocationToScreen
function UIUtil.ProjectWorldLocationToScreen(InWorldLocation, OutScreenLocation
, bPlayerViewportRelative, PlayerIndex)

	bPlayerViewportRelative = bPlayerViewportRelative or false    --默认参数为false
	PlayerIndex = PlayerIndex or 0    --默认参数为false

	return UUIUtil.ProjectWorldLocationToScreen(InWorldLocation, OutScreenLocation
	, bPlayerViewportRelative, PlayerIndex)
end

---DeprojectScreenToWorld
function UIUtil.DeprojectScreenToWorld(ScreenPosition, WorldPosition
, WorldDirection, PlayerIndex)
	PlayerIndex = PlayerIndex or 0    --默认参数为false

	return UUIUtil.DeprojectScreenToWorld(ScreenPosition, WorldPosition
	, WorldDirection, PlayerIndex)
end

---ImageSetMaterialTextureFromAssetPathSync
---@param InImage UImage
---@param InAssetPath string
function UIUtil.ImageSetMaterialTextureFromAssetPathSync(InImage, InAssetPath, MaterialTextureParamName)
	return UUIUtil.ImageSetMaterialTextureFromAssetPathSync(InImage, InAssetPath, MaterialTextureParamName)
end

---ImageSetColorAndOpacity
---@param InImage UImage
---@param InR number            @0~1
---@param InG number            @0~1
---@param InB number            @0~1
---@param InA number            @0~1
function UIUtil.ImageSetColorAndOpacity(InImage, InR, InG, InB, InA)
	return UUIUtil.ImageSetColorAndOpacity(InImage, InR, InG, InB, InA)
end

---ImageSetColorAndOpacityHex
---@param InImage UImage
---@param InColorHex string     @"RGBA" example: Red="ff0000ff" Green="00ff00ff" Blue="0000ffff"
function UIUtil.ImageSetColorAndOpacityHex(InImage, InColorHex)
	return UUIUtil.ImageSetColorAndOpacityHex(InImage, InColorHex)
end

---ImageSetBrushTintColor
---@param InImage UImage
---@param InR number            @0~1
---@param InG number            @0~1
---@param InB number            @0~1
---@param InA number            @0~1
function UIUtil.ImageSetBrushTintColor(InImage, InR, InG, InB, InA)
	return UUIUtil.ImageSetBrushTintColor(InImage, InR, InG, InB, InA)
end

---ImageSetBrushTintColorHex
---@param InImage UImage
---@param InColorHex string     @"RGBA" example: Red="ff0000ff" Green="00ff00ff" Blue="0000ffff"
function UIUtil.ImageSetBrushTintColorHex(InImage, InColorHex)
	return UUIUtil.ImageSetBrushTintColorHex(InImage, InColorHex)
end

---ImageSetMaterialScalarParameterValue
---@param InImage UImage
---@param InParameterName string
---@param InValue number
function UIUtil.ImageSetMaterialScalarParameterValue(InImage, InParameterName, InValue)
	return UUIUtil.ImageSetMaterialScalarParameterValue(InImage, InParameterName, InValue)
end

---ImageSetMaterialSetVectorParameterValue
---@param InImage UImage
---@param InParameterName string
---@param InValue FLinearColor
function UIUtil.ImageSetMaterialSetVectorParameterValue(InImage, InParameterName, InValue)
	return UUIUtil.ImageSetMaterialSetVectorParameterValue(InImage, InParameterName, InValue)
end

---ImageSetMaterialTextureParameterValue
---@param InImage UImage
---@param InParameterName string
---@param InValue UTexture
function UIUtil.ImageSetMaterialTextureParameterValue(InImage, InParameterName, InValue)
	return UUIUtil.ImageSetMaterialTextureParameterValue(InImage, InParameterName, InValue)
end

---TextBlockSetColorAndOpacity
---@param InTextBlock UTextBlock
---@param InR number            @0~1
---@param InG number            @0~1
---@param InB number            @0~1
---@param InA number            @0~1
function UIUtil.TextBlockSetColorAndOpacity(InTextBlock, InR, InG, InB, InA)
	--return UUIUtil.TextBlockSetColorAndOpacity(InTextBlock, InR, InG, InB, InA)
	if nil == InTextBlock then
		FLOG_WARNING("UIUtil.TextBlockSetColorAndOpacity TextBlock is nil")
		return
	end

	local LinearColor = FLinearColor(InR, InG, InB, InA)
	InTextBlock:SetColorAndOpacity(LinearColor)
end

---TextBlockSetColorAndOpacityHex
---@param InTextBlock UTextBlock
---@param InColorHex string     @"RGBA" example: Red="ff0000ff" Green="00ff00ff" Blue="0000ffff"
function UIUtil.TextBlockSetColorAndOpacityHex(InTextBlock, InColorHex)
	--return UUIUtil.TextBlockSetColorAndOpacityHex(InTextBlock, InColorHex)
	if nil == InTextBlock then
		FLOG_WARNING("UIUtil.TextBlockSetColorAndOpacityHex TextBlock is nil")
		return
	end

	local LinearColor = FLinearColor.FromHex(InColorHex)
	InTextBlock:SetColorAndOpacity(LinearColor)
end

---TextBlockSetShadowColorAndOpacity
---@param InTextBlock UTextBlock
---@param InR number            @0~1
---@param InG number            @0~1
---@param InB number            @0~1
---@param InA number            @0~1
function UIUtil.TextBlockSetShadowColorAndOpacity(InTextBlock, InR, InG, InB, InA)
	--return UUIUtil.TextBlockSetShadowColorAndOpacity(InTextBlock, InR, InG, InB, InA)
	if nil == InTextBlock then
		FLOG_WARNING("UIUtil.TextBlockSetShadowColorAndOpacity TextBlock is nil")
		return
	end

	local LinearColor = FLinearColor(InR, InG, InB, InA)
	InTextBlock:SetShadowColorAndOpacity(LinearColor)
end

---TextBlockSetShadowColorAndOpacityHex
---@param InTextBlock UTextBlock
---@param InColorHex string     @"RGBA" example: Red="ff0000ff" Green="00ff00ff" Blue="0000ffff"
function UIUtil.TextBlockSetShadowColorAndOpacityHex(InTextBlock, InColorHex)
	--return UUIUtil.TextBlockSetShadowColorAndOpacityHex(InTextBlock, InColorHex)
	if nil == InTextBlock then
		FLOG_WARNING("UIUtil.TextBlockSetShadowColorAndOpacityHex TextBlock is nil")
		return
	end

	local LinearColor = FLinearColor.FromHex(InColorHex)
	InTextBlock:SetShadowColorAndOpacity(LinearColor)
end

---TextBlockSetOutlineColorAndOpacity
---@param InTextBlock UTextBlock
---@param InR number            @0~1
---@param InG number            @0~1
---@param InB number            @0~1
---@param InA number            @0~1
function UIUtil.TextBlockSetOutlineColorAndOpacity(InTextBlock, InR, InG, InB, InA)
	--return UUIUtil.TextBlockSetOutlineColorAndOpacity(InTextBlock, InR, InG, InB, InA)
	if nil == InTextBlock then
		FLOG_WARNING("UIUtil.TextBlockSetOutlineColorAndOpacity TextBlock is nil")
		return
	end

	local LinearColor = FLinearColor(InR, InG, InB, InA)
	InTextBlock.Font.OutlineSettings.OutlineColor = LinearColor
	InTextBlock:SetFont(InTextBlock.Font)
end

---TextBlockSetOutlineColorAndOpacityHex
---@param InTextBlock UTextBlock
---@param InColorHex string     @"RGBA" example: Red="ff0000ff" Green="00ff00ff" Blue="0000ffff"
function UIUtil.TextBlockSetOutlineColorAndOpacityHex(InTextBlock, InColorHex)
	--return UUIUtil.TextBlockSetOutlineColorAndOpacityHex(InTextBlock, InColorHex)
	if nil == InTextBlock then
		FLOG_WARNING("UIUtil.TextBlockSetOutlineColorAndOpacityHex TextBlock is nil")
		return
	end

	local LinearColor = FLinearColor.FromHex(InColorHex)
	InTextBlock.Font.OutlineSettings.OutlineColor = LinearColor
	InTextBlock:SetFont(InTextBlock.Font)
end

---TextBlockSetOutlineSize
---@param InTextBlock UTextBlock
---@param Size number
function UIUtil.TextBlockSetOutlineSize(InTextBlock, Size)
	if nil == InTextBlock then
		FLOG_WARNING("UIUtil.TextBlockSetOutlineSize TextBlock is nil")
		return
	end

	InTextBlock.Font.OutlineSettings.OutlineSize = Size or 0 
	InTextBlock:SetFont(InTextBlock.Font)
end

---TextBlockSetFontSize
---@param InTextBlock UTextBlock
---@param InFontSize number
function UIUtil.TextBlockSetFontSize(InTextBlock, InFontSize)
	if nil == InTextBlock then
		FLOG_WARNING("UIUtil.TextBlockSetFontSize TextBlock is nil")
		return
	end

	InTextBlock.Font.Size = InFontSize
	InTextBlock:SetFont(InTextBlock.Font)
end

---ButtonSetBrush
---@param InButton UButton
---@param InAssetPath string
---@param BrushName string | nil @["Normal", "Hovered", "Pressed", "Pressed", nil]
function UIUtil.ButtonSetBrush(InButton, InAssetPath, BrushName)
	local function OnLoadComplete()
		if _G.UE.UCommonUtil.IsObjectValid(InButton) then
			if nil == BrushName then
				UUIUtil.SetBrushFromAssetPath(InButton.WidgetStyle.Normal, InAssetPath, true)
				UUIUtil.SetBrushFromAssetPath(InButton.WidgetStyle.Hovered, InAssetPath, true)
				UUIUtil.SetBrushFromAssetPath(InButton.WidgetStyle.Pressed, InAssetPath,  true)
				UUIUtil.SetBrushFromAssetPath(InButton.WidgetStyle.Disabled, InAssetPath,  true)
			else
				local Brush = InButton.WidgetStyle[BrushName]
				UUIUtil.SetBrushFromAssetPath(Brush, InAssetPath,  true)
			end
		end
	end

	_G.ObjectMgr:LoadObjectAsync(InAssetPath, OnLoadComplete)
end

function UIUtil.ButtonSetBrushSync(InButton, InAssetPath, BrushName)
	if _G.UE.UCommonUtil.IsObjectValid(InButton) then
		if nil == BrushName then
			UUIUtil.SetBrushFromAssetPath(InButton.WidgetStyle.Normal, InAssetPath,  true)
			UUIUtil.SetBrushFromAssetPath(InButton.WidgetStyle.Hovered, InAssetPath,  true)
			UUIUtil.SetBrushFromAssetPath(InButton.WidgetStyle.Pressed, InAssetPath,  true)
			UUIUtil.SetBrushFromAssetPath(InButton.WidgetStyle.Disabled, InAssetPath,  true)
		else
			local Brush = InButton.WidgetStyle[BrushName]
			UUIUtil.SetBrushFromAssetPath(Brush, InAssetPath,  true)
		end
	end
end

---ProgressBarSetFillColorAndOpacity
---@param InProgressBar UProgressBar
---@param InR number                @0~1
---@param InG number                @0~1
---@param InB number                @0~1
---@param InA number                @0~1
function UIUtil.ProgressBarSetFillColorAndOpacity(InProgressBar, InR, InG, InB, InA)
	return UUIUtil.ProgressBarSetFillColorAndOpacity(InProgressBar, InR, InG, InB, InA)
end

---ProgressBarSetFillColorAndOpacityHex
---@param InProgressBar UProgressBar
---@param InColorHex string         @"RGBA" example: Red="ff0000ff" Green="00ff00ff" Blue="0000ffff"
function UIUtil.ProgressBarSetFillColorAndOpacityHex(InProgressBar, InColorHex)
	return UUIUtil.ProgressBarSetFillColorAndOpacityHex(InProgressBar, InColorHex)
end

---ProgressBarSetBackgroundColorAndOpacity
---@param InProgressBar UProgressBar
---@param InR number                @0~1
---@param InG number                @0~1
---@param InB number                @0~1
---@param InA number                @0~1
function UIUtil.ProgressBarSetBackgroundColorAndOpacity(InProgressBar, InR, InG, InB, InA)
	if _G.UE.UCommonUtil.IsObjectValid(InProgressBar) then
		return UUIUtil.SetBrushTintColor(InProgressBar.WidgetStyle.BackgroundImage, InR, InG, InB, InA)
	end
end

---ProgressBarSetBackgroundColorAndOpacityHex
---@param InProgressBar UProgressBar
---@param InColorHex string         @"RGBA" example: Red="ff0000ff" Green="00ff00ff" Blue="0000ffff"
function UIUtil.ProgressBarSetBackgroundColorAndOpacityHex(InProgressBar, InColorHex)
	if _G.UE.UCommonUtil.IsObjectValid(InProgressBar) then
		return UUIUtil.SetBrushTintColorHex(InProgressBar.WidgetStyle.BackgroundImage, InColorHex)
	end
end

---ProgressBarSetFillImage
---@param InProgressBar UProgressBar
---@param InAssetPath string
function UIUtil.ProgressBarSetFillImage(InProgressBar, InAssetPath)
	local function OnLoadComplete()
		if _G.UE.UCommonUtil.IsObjectValid(InProgressBar) then
			UUIUtil.SetBrushFromAssetPath(InProgressBar.WidgetStyle.FillImage, InAssetPath,  true)
		end
	end

	_G.ObjectMgr:LoadObjectAsync(InAssetPath, OnLoadComplete)
end

---ProgressBarSetBackgroundImage
---@param InProgressBar UProgressBar
---@param InAssetPath string
function UIUtil.ProgressBarSetBackgroundImage(InProgressBar, InAssetPath)
	local function OnLoadComplete()
		if _G.UE.UCommonUtil.IsObjectValid(InProgressBar) then
			UUIUtil.SetBrushFromAssetPath(InProgressBar.WidgetStyle.BackgroundImage, InAssetPath, true)
		end
	end

	_G.ObjectMgr:LoadObjectAsync(InAssetPath, OnLoadComplete)
end

--region UCanvasPanelSlot
-- Slot类型为UCanvasPanelSlot 才会调用

---CanvasSlotSetLayout
---@param Widget UWidget
---@param InLayoutData FAnchorData
function UIUtil.CanvasSlotSetLayout(Widget, InLayoutData)
	UUIUtil.CanvasSlotSetLayout(Widget, InLayoutData)
end

---CanvasSlotGetLayout
---@param Widget UWidget
---@return FAnchorData
function UIUtil.CanvasSlotGetLayout(Widget)
	return UUIUtil.CanvasSlotGetLayout(Widget)
end

---CanvasSlotSetPosition Sets the position of the slot
---@param Widget UWidget
---@param InPosition FVector2D
function UIUtil.CanvasSlotSetPosition(Widget, InPosition)
	UUIUtil.CanvasSlotSetPosition(Widget, InPosition)
end

---CanvasSlotGetPosition Gets the position of the slot
---@param Widget UWidget
---@return FVector2D
function UIUtil.CanvasSlotGetPosition(Widget)
	return UUIUtil.CanvasSlotGetPosition(Widget)
end

---CanvasSlotSetSize Sets the size of the slot
---@param Widget UWidget
---@param InSize FVector2D
function UIUtil.CanvasSlotSetSize(Widget, InSize)
	UUIUtil.CanvasSlotSetSize(Widget, InSize)
end

---CanvasSlotGetSize Gets the size of the slot
---@param Widget UWidget
---@return FVector2D
function UIUtil.CanvasSlotGetSize(Widget)
	return UUIUtil.CanvasSlotGetSize(Widget)
end

---CanvasSlotSetOffsets Sets the Offset data of the slot, which could be position and size, or margins depending on the anchor points
---@param Widget UWidget
---@param InOffset FMargin
function UIUtil.CanvasSlotSetOffsets(Widget, InOffset)
	UUIUtil.CanvasSlotSetOffsets(Widget, InOffset)
end

---CanvasSlotGetOffsets Gets the Offset data of the slot, which could be position and size, or margins depending on the anchor points
---@param Widget UWidget
---@return FMargin
function UIUtil.CanvasSlotGetOffsets(Widget)
	return UUIUtil.CanvasSlotGetOffsets(Widget)
end

---CanvasSlotSetAnchors sets the anchors on the slot
---@param Widget UWidget
---@param InAnchors FAnchors
function UIUtil.CanvasSlotSetAnchors(Widget, InAnchors)
	UUIUtil.CanvasSlotSetAnchors(Widget, InAnchors)
end

---CanvasSlotGetAnchors Gets the anchors on the slot
---@param Widget UWidget
---@return FAnchors
function UIUtil.CanvasSlotGetAnchors(Widget)
	return UUIUtil.CanvasSlotGetAnchors(Widget)
end

---CanvasSlotSetAlignment Sets the alignment on the slot
---@param Widget UWidget
---@param InAlignment FVector2D
function UIUtil.CanvasSlotSetAlignment(Widget, InAlignment)
	UUIUtil.CanvasSlotSetAlignment(Widget, InAlignment)
end

---CanvasSlotGetAlignment Gets the alignment on the slot
---@param Widget UWidget
---@return FVector2D
function UIUtil.CanvasSlotGetAlignment(Widget)
	return UUIUtil.CanvasSlotGetAlignment(Widget)
end

---CanvasSlotSetAutoSize Sets if the slot to be auto-sized
---@param Widget UWidget
---@param InbAutoSize boolean
function UIUtil.CanvasSlotSetAutoSize(Widget, InbAutoSize)
	UUIUtil.CanvasSlotSetAutoSize(Widget, InbAutoSize)
end

---CanvasSlotGetAutoSize Gets if the slot to be auto-sized
---@param Widget UWidget
---return boolean
function UIUtil.CanvasSlotGetAutoSize(Widget)
	return UUIUtil.CanvasSlotGetAutoSize(Widget)
end

---CanvasSlotSetZOrder Sets the z-order on the slot
---@param Widget UWidget
---@param InZOrder number
function UIUtil.CanvasSlotSetZOrder(Widget, InZOrder)
	UUIUtil.CanvasSlotSetZOrder(Widget, InZOrder)
end

---CanvasSlotGetZOrder Gets the z-order on the slot
---@param Widget UWidget
---@return boolean
function UIUtil.CanvasSlotGetZOrder(Widget)
	return UUIUtil.CanvasSlotGetZOrder(Widget)
end

--endregion UCanvasPanelSlot

--region UISlot

---SlotAsBorderSlot
---@param Widget UWidget
---@return UBorderSlot
function UIUtil.SlotAsBorderSlot(Widget)
	return UWidgetLayoutLibrary.SlotAsBorderSlot(Widget)
end

---SlotAsCanvasSlot
---@param Widget UWidget
---@return UCanvasPanelSlot
function UIUtil.SlotAsCanvasSlot(Widget)
	local Slot = UWidgetLayoutLibrary.SlotAsCanvasSlot(Widget)
	if nil == Slot then
		FLOG_ERROR("UIUtil.SlotAsCanvasSlot Slot is nil")
	end

	return Slot
end

---SlotAsGridSlot
---@param Widget UWidget
---@return UGridSlot
function UIUtil.SlotAsGridSlot(Widget)
	return UWidgetLayoutLibrary.SlotAsGridSlot(Widget)
end

---SlotAsHorizontalBoxSlot
---@param Widget UWidget
---@return UHorizontalBoxSlot
function UIUtil.SlotAsHorizontalBoxSlot(Widget)
	return UWidgetLayoutLibrary.SlotAsHorizontalBoxSlot(Widget)
end

---SlotAsOverlaySlot
---@param Widget UWidget
---@return UOverlaySlot
function UIUtil.SlotAsOverlaySlot(Widget)
	return UWidgetLayoutLibrary.SlotAsOverlaySlot(Widget)
end

---SlotAsUniformGridSlot
---@param Widget UWidget
---@return UUniformGridSlot
function UIUtil.SlotAsUniformGridSlot(Widget)
	return UWidgetLayoutLibrary.SlotAsUniformGridSlot(Widget)
end

---SlotAsVerticalBoxSlot
---@param Widget UWidget
---@return UVerticalBoxSlot
function UIUtil.SlotAsVerticalBoxSlot(Widget)
	return UWidgetLayoutLibrary.SlotAsVerticalBoxSlot(Widget)
end

---SlotAsScrollBoxSlot
---@param Widget UWidget
---@return UScrollBoxSlot
function UIUtil.SlotAsScrollBoxSlot(Widget)
	return UWidgetLayoutLibrary.SlotAsScrollBoxSlot(Widget)
end

---SlotSlotAsSafeBoxSlotsCanvasSlot
---@param Widget UWidget
---@return USafeZoneSlot
function UIUtil.SlotAsSafeBoxSlot(Widget)
	return UWidgetLayoutLibrary.SlotAsSafeBoxSlot(Widget)
end

---SlotAsScaleBoxSlot
---@param Widget UWidget
---@return UScaleBoxSlot
function UIUtil.SlotAsScaleBoxSlot(Widget)
	return UWidgetLayoutLibrary.SlotAsScaleBoxSlot(Widget)
end

---SlotAsSizeBoxSlot
---@param Widget UWidget
---@return USizeBoxSlot
function UIUtil.SlotAsSizeBoxSlot(Widget)
	return UWidgetLayoutLibrary.SlotAsSizeBoxSlot(Widget)
end

---SlotAsWrapBoxSlot
---@param Widget UWidget
---@return UWrapBoxSlot
function UIUtil.SlotAsWrapBoxSlot(Widget)
	return UWidgetLayoutLibrary.SlotAsWrapBoxSlot(Widget)
end

---SlotAsWidgetSwitcherSlot
---@param Widget UWidget
---@return UWidgetSwitcherSlot
function UIUtil.SlotAsWidgetSwitcherSlot(Widget)
	return UWidgetLayoutLibrary.SlotAsWidgetSwitcherSlot(Widget)
end

--endregion UISlot


--region UI Event

---AddOnClickedEvent
---UButton DECLARE_DYNAMIC_MULTICAST_DELEGATE(FOnButtonClickedEvent)
---@param View UIView
---@param Widget UButton
---@param Callback function
---@param Params any
function UIUtil.AddOnClickedEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnClicked", Callback, Params)
end

---AddOnDoubleClickedEvent
---UButton DECLARE_DYNAMIC_MULTICAST_DELEGATE(FOnButtonDoubleClickedEvent)
---@param View UIView
---@param Widget UButton
---@param Callback function
---@param Params any
function UIUtil.AddOnDoubleClickedEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnDoubleClicked", Callback, Params)
end

---AddOnLongClickedEvent
---UButton DECLARE_DYNAMIC_MULTICAST_DELEGATE(FOnButtonLongClickedEvent);
---@param View UIView
---@param Widget UButton
---@param Callback function
---@param Params any
function UIUtil.AddOnLongClickedEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnLongClicked", Callback, Params)
end

---AddOnLongClickReleasedEvent
---UButton DECLARE_DYNAMIC_MULTICAST_DELEGATE(FOnButtonLongClickedEvent);
---@param View UIView
---@param Widget UButton
---@param Callback function
---@param Params any
function UIUtil.AddOnLongClickReleasedEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnLongClickReleased", Callback, Params)
end
---AddOnPressedEvent
---UButton DECLARE_DYNAMIC_MULTICAST_DELEGATE(FOnButtonPressedEvent)
---@param View UIView
---@param Widget UButton
---@param Callback function
---@param Params any
function UIUtil.AddOnPressedEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnPressed", Callback, Params)
end

---AddOnReleasedEvent
---UButton DECLARE_DYNAMIC_MULTICAST_DELEGATE(FOnButtonReleasedEvent)
---@param View UIView
---@param Widget UButton
---@param Callback function
---@param Params any
function UIUtil.AddOnReleasedEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnReleased", Callback, Params)
end

---AddOnHoveredEvent
---UButton DECLARE_DYNAMIC_MULTICAST_DELEGATE(FOnButtonHoverEvent)
---@param View UIView
---@param Widget UButton
---@param Callback function
---@param Params any
function UIUtil.AddOnHoveredEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnHovered", Callback, Params)
end

---AddOnUnhoveredEvent
---UButton DECLARE_DYNAMIC_MULTICAST_DELEGATE(FOnButtonHoverEvent)
---@param View UIView
---@param Widget UButton
---@param Callback function
---@param Params any
function UIUtil.AddOnUnhoveredEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnUnhovered", Callback, Params)
end

---@param View UIView
---@param CommBtn CommBtnLView
---@param Callback function
---@param Params any
function UIUtil.AddOnLongPressedEvent(View, CommBtn, Callback, Params)
	return View:RegisterUIEvent(CommBtn, "OnLongPressed", Callback, Params)
end

---AddOnStateChangedEvent
---UToggleButton DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FOnToggleStateChanged, EToggleButtonState, NewState, EToggleButtonState,LastState)Slot
---UToggleGroup UToggleGroupDynamic DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FOnToggleGroupStateChanged, int, Index, EToggleButtonState, State)
---@param View UIView
---@param Widget UToggleButton | UToggleGroup | UToggleGroupDynamic | CommSingleBoxView | CommCheckBoxView
---@param Callback function
---@param Params any
function UIUtil.AddOnStateChangedEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnStateChanged", Callback, Params)
end

---AddOnCheckStateChangedEvent
---UCheckBox DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam( FOnCheckBoxComponentStateChanged, bool, bIsChecked )
---@param View UIView
---@param Widget UCheckBox
---@param Callback function
---@param Params any
function UIUtil.AddOnCheckStateChangedEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnCheckStateChanged", Callback, Params)
end

---AddOnMouseCaptureBeginEvent
---USlider DECLARE_DYNAMIC_MULTICAST_DELEGATE(FOnMouseCaptureBeginEvent)
---@param View UIView
---@param Widget USlider
---@param Callback function
---@param Params any
function UIUtil.AddOnMouseCaptureBeginEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnMouseCaptureBegin", Callback, Params)
end

---AddOnMouseCaptureEndEvent
---USlider DECLARE_DYNAMIC_MULTICAST_DELEGATE(FOnMouseCaptureEndEvent)
---@param View UIView
---@param Widget USlider
---@param Callback function
---@param Params any
function UIUtil.AddOnMouseCaptureEndEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnMouseCaptureEnd", Callback, Params)
end

---AddOnControllerCaptureBeginEvent
---USlider DECLARE_DYNAMIC_MULTICAST_DELEGATE(FOnControllerCaptureBeginEvent)
---@param View UIView
---@param Widget USlider
---@param Callback function
---@param Params any
function UIUtil.AddOnControllerCaptureBeginEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnControllerCaptureBegin", Callback, Params)
end

---AddOnControllerCaptureEndEvent
---USlider DECLARE_DYNAMIC_MULTICAST_DELEGATE(FOnControllerCaptureEndEvent)
---@param View UIView
---@param Widget USlider
---@param Callback function
---@param Params any
function UIUtil.AddOnControllerCaptureEndEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnControllerCaptureEnd", Callback, Params)
end

---AddOnValueChangedEvent
---USlider DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnFloatValueChangedEvent, float, Value)
---USpinBox DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnSpinBoxValueChangedEvent, float, InValue)
---@param View UIView
---@param Widget USlider | USpinBox
---@param Callback function
---@param Params any
function UIUtil.AddOnValueChangedEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnValueChanged", Callback, Params)
end

---AddOnHyperlinkClickedEvent
---URichTextBox DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnRichTextHyperlinkClicked, const TArray<FString>&, Metadata)
---@param View UIView
---@param Widget URichTextBox
---@param Callback function
---@param Params any
function UIUtil.AddOnHyperlinkClickedEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnHyperlinkClicked", Callback, Params)
end

---AddOnDynamicTextAppendedEvent
---URichTextBox DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnDynamicTextAppendedEvent, const FString&, AppendString)
---@param View UIView
---@param Widget URichTextBox
---@param Callback function
---@param Params any
function UIUtil.AddOnDynamicTextAppendedEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnDynamicTextAppended", Callback, Params)
end

---AddOnRichTextBoxClippedEvent
---URichTextBox DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnRichTextBoxClippedEvent, bool, IsClipped)
---@param View UIView
---@param Widget URichTextBox
---@param Callback function
---@param Params any
function UIUtil.AddOnRichTextBoxClippedEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnRichTextBoxClipped", Callback, Params)
end

---AddOnTextBlockClippedEvent
---UFTextBox DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnFTextBlockClippedEvent, bool, IsClipped)
---@param View UIView
---@param Widget UFTextBlock
---@param Callback function
---@param Params any
function UIUtil.AddOnTextBlockClippedEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnFTextBlockClipped", Callback, Params)
end

---AddOnSelectionChangedEvent
---UComboBoxString DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FOnSelectionChangedEvent, FString, SelectedItem, ESelectInfo::Type, SelectionType)
---@param View UIView
---@param Widget UComboBoxString
---@param Callback function
---@param Params any
function UIUtil.AddOnSelectionChangedEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnSelectionChanged", Callback, Params)
end

---AddOnOpeningEvent
---UComboBoxString DECLARE_DYNAMIC_MULTICAST_DELEGATE(FOnOpeningEvent)
---@param View UIView
---@param Widget UComboBoxString
---@param Callback function
---@param Params any
function UIUtil.AddOnOpeningEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnOpening", Callback, Params)
end

---AddOnTextChangedEvent
---UEditableText DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnEditableTextChangedEvent, const FText&, Text)
---UMultiLineEditableText DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnMultiLineEditableTextChangedEvent, const FText&, Text)
---UEditableTextBox DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnEditableTextBoxChangedEvent, const FText&, Text)
---UMultiLineEditableTextBox DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnMultiLineEditableTextBoxChangedEvent, const FText&, Text)
---@param View UIView
---@param Widget UEditableText | UMultiLineEditableText | UEditableTextBox | UMultiLineEditableTextBox
---@param Callback function
---@param Params any
function UIUtil.AddOnTextChangedEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnTextChanged", Callback, Params)
end

---AddOnTextCommittedEvent
---UEditableText DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FOnEditableTextCommittedEvent, const FText&, Text, ETextCommit::Type, CommitMethod)
---UMultiLineEditableText DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FOnMultiLineEditableTextCommittedEvent, const FText&, Text, ETextCommit::Type, CommitMethod)
---UEditableTextBox DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FOnEditableTextBoxCommittedEvent, const FText&, Text, ETextCommit::Type, CommitMethod)
---UMultiLineEditableTextBox DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FOnMultiLineEditableTextBoxCommittedEvent, const FText&, Text, ETextCommit::Type, CommitMethod)
---@param View UIView
---@param Widget UEditableText | UMultiLineEditableText | UEditableTextBox | UMultiLineEditableTextBox
---@param Callback function
---@param Params any
function UIUtil.AddOnTextCommittedEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnTextCommitted", Callback, Params)
end

---AddOnValueCommittedEvent
---USpinBox DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FOnSpinBoxValueCommittedEvent, float, InValue, ETextCommit::Type, CommitMethod)
---@param View UIView
---@param Widget USpinBox
---@param Callback function
---@param Params any
function UIUtil.AddOnValueCommittedEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnValueCommitted", Callback, Params)
end

---AddOnFocusReceivedEvent
---@param View UIView
---@param Widget UEditableText
---@param Callback function
---@param Params any
function UIUtil.AddOnFocusReceivedEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnFocusReceived", Callback, Params)
end

---AddOnFocusLostEvent
---@param View UIView
---@param Widget UEditableText
---@param Callback function
---@param Params any
function UIUtil.AddOnFocusLostEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnFocusLost", Callback, Params)
end

---AddOnBeginSliderMovementEvent
---USpinBox DECLARE_DYNAMIC_MULTICAST_DELEGATE(FOnSpinBoxBeginSliderMovement)
---@param View UIView
---@param Widget USpinBox
---@param Callback function
---@param Params any
function UIUtil.AddOnBeginSliderMovementEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnBeginSliderMovement", Callback, Params)
end

---AddOnEndSliderMovementEvent
---USpinBox DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnSpinBoxValueChangedEvent, float, InValue)
---@param View UIView
---@param Widget USpinBox
---@param Callback function
---@param Params any
function UIUtil.AddOnEndSliderMovementEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnEndSliderMovement", Callback, Params)
end

---AddOnPageChangedEvent
---UTableView DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnTableViewPageChanged, int32, Page);
---@param View UIView
---@param Widget UTableView
---@param Callback function
---@param Params any
function UIUtil.AddOnPageChangedEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnPageChanged", Callback, Params)
end

---AddOnPageChangedEvent
--UTableView DECLARE_DYNAMIC_MULTICAST_DELEGATE(FOnTableViewScrolledToEnd);
---@param View UIView
---@param Widget UTableView
---@param Callback function
---@param Params any
function UIUtil.AddOnScrolledToEndEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnScrolledToEnd", Callback, Params)
end

---AddOnScrolledEvent
--UTableView DECLARE_DELEGATE_OneParam(FOnTableViewScrolled, float)
---@param View UIView
---@param Widget UTableView
---@param Callback function
---@param Params any
function UIUtil.AddOnScrolledEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "OnScrolled", Callback, Params)
end

function UIUtil.AddOnItemShowEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "BP_OnItemShow", Callback, Params)
end

function UIUtil.AddOnItemHideEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "BP_OnItemHide", Callback, Params)
end

function UIUtil.AddOnScrollToFirstItemEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "BP_OnScrollToFirstItem", Callback, Params)
end

function UIUtil.AddOnScrollToLastItemEvent(View, Widget, Callback, Params)
	return View:RegisterUIEvent(Widget, "BP_OnScrollToLastItem", Callback, Params)
end

--endregion Event



---WidgetLocalToViewport
---@param InWidget UWidget
---@param X number
---@param X number
---@return FVector2D,FVector2D
function UIUtil.WidgetLocalToViewport(InWidget, X, Y)
	return UIUtil.LocalToViewport(InWidget, FVector2D(X, Y))
end

function UIUtil.SetInputMode_UIOnly(InWidgetToFocus, InMouseLockMode)
	local PlayerController = GameplayStaticsUtil.GetPlayerController()
	if nil == PlayerController then
		return
	end

	UWidgetBlueprintLibrary.SetInputMode_UIOnlyEx(PlayerController, InWidgetToFocus, InMouseLockMode)
end

function UIUtil.SetInputMode_GameOnly()
	local PlayerController = GameplayStaticsUtil.GetPlayerController()
	if nil == PlayerController then
		return
	end
	UWidgetBlueprintLibrary.SetInputMode_GameOnly(PlayerController)
end

function UIUtil.SetInputMode_GameAndUI(InWidgetToFocus, InMouseLockMode, bHideCursorDuringCapture)
	local PlayerController = GameplayStaticsUtil.GetPlayerController()
	if nil == PlayerController then
		return
	end
	UWidgetBlueprintLibrary.SetInputMode_GameAndUIEx(PlayerController, InWidgetToFocus, InMouseLockMode, bHideCursorDuringCapture)
end

---GetScreenSize
---@return FVector2D
function UIUtil.GetScreenSize()
	local Scale = UUIUtil.GetViewportScale()
	local Size = UUIUtil.GetViewportSize()

	--print("UIUtil.GetScreenSize", Scale, Size)
	return Size / Scale
end

---GetViewportScale
---@return number @float
function UIUtil.GetViewportScale()
	return UUIUtil.GetViewportScale()
end

---GetViewportSize
---@return FVector2D
function UIUtil.GetViewportSize()
	return UUIUtil.GetViewportSize()
end

---GetLocalTopLeft
---@param InWidget UWidget
---@return FVector2D
function UIUtil.GetLocalTopLeft(InWidget)
	return UUIUtil.GetLocalTopLeft(InWidget)
end

---GetLocalSize
---@param InWidget UWidget
---@return FVector2D
function UIUtil.GetLocalSize(InWidget)
	return UUIUtil.GetLocalSize(InWidget)
end

---GetAbsoluteSize
---@param InWidget UWidget
---@return FVector2D
function UIUtil.GetAbsoluteSize(InWidget)
	return UUIUtil.GetAbsoluteSize(InWidget)
end

---GetWidgetSize 手动计算size,可以在onShow时机调用
---@param InWidget UWidget
---@return FVector2D
function UIUtil.GetWidgetSize(InWidget)
	return UUIUtil.GetWidgetSize(InWidget)
end

---GetWidgetAbsoluteTopLeft 手动计算Location,可以在OnShow时机调用
---@param InWidget UWidget
---@return FVector2D
function UIUtil.GetWidgetAbsoluteTopLeft(InWidget)
	return UUIUtil.GetWidgetAbsoluteTopLeft(InWidget)
end

---IsUnderLocation
---@param InWidget UWidget
---@param AbsoluteCoordinate FVector2D
---@return boolean
function UIUtil.IsUnderLocation(InWidget, AbsoluteCoordinate)
	return UUIUtil.IsUnderLocation(InWidget, AbsoluteCoordinate)
end

---AbsoluteToLocal
---@param InWidget UWidget
---@param AbsoluteCoordinate FVector2D
---@return FVector2D
function UIUtil.AbsoluteToLocal(InWidget, AbsoluteCoordinate)
	return UUIUtil.AbsoluteToLocal(InWidget, AbsoluteCoordinate)
end

---LocalToAbsolute
---@param InWidget UWidget
---@param LocalCoordinate FVector2D
---@return FVector2D
function UIUtil.LocalToAbsolute(InWidget, LocalCoordinate)
	return UUIUtil.LocalToAbsolute(InWidget, LocalCoordinate)
end

---LocalToViewport
---@param InWidget UWidget
---@param LocalCoordinate FVector2D
---@return FVector2D, FVector2D
function UIUtil.LocalToViewport(InWidget, LocalCoordinate)
	local PixelPosition = FVector2D(0, 0)
	local ViewportPosition = FVector2D(0, 0)

	UUIUtil.LocalToViewport(InWidget, LocalCoordinate, PixelPosition, ViewportPosition)

	return ViewportPosition, PixelPosition
end

---ViewportToLocal
---@param InWidget UWidget
---@param ViewportPosition FVector2D
---@return FVector2D
function UIUtil.ViewportToLocal(InWidget, ViewportPosition)
	local LocalCoordinate = FVector2D(0, 0)

	UUIUtil.ViewportToLocal(InWidget, ViewportPosition, LocalCoordinate)

	return LocalCoordinate
end

---AbsoluteToViewport
---@param AbsoluteDesktopCoordinate FVector2D
---@return FVector2D, FVector2D
function UIUtil.AbsoluteToViewport(AbsoluteDesktopCoordinate)
	local PixelPosition = FVector2D(0, 0)
	local ViewportPosition = FVector2D(0, 0)

	UUIUtil.AbsoluteToViewport(AbsoluteDesktopCoordinate, PixelPosition, ViewportPosition)

	return PixelPosition, ViewportPosition
end

---ScreenToWidgetLocal
---@param InWidget UWidget
---@param ScreenPosition FVector2D
---@param bIncludeWindowPosition boolean
---@return FVector2D
function UIUtil.ScreenToWidgetLocal(InWidget, ScreenPosition, bIncludeWindowPosition)
	local LocalCoordinate = FVector2D(0, 0)

	UUIUtil.ScreenToWidgetLocal(InWidget, ScreenPosition, LocalCoordinate, bIncludeWindowPosition)

	return LocalCoordinate
end

---ScreenToWidgetAbsolute
---@param ScreenPosition FVector2D
---@param bIncludeWindowPosition boolean
---@return FVector2D
function UIUtil.ScreenToWidgetAbsolute(ScreenPosition, bIncludeWindowPosition)
	local AbsoluteCoordinate = FVector2D(0, 0)

	UUIUtil.ScreenToWidgetAbsolute(ScreenPosition, AbsoluteCoordinate, bIncludeWindowPosition)

	return AbsoluteCoordinate
end

---ScreenToViewport
---@param ScreenPosition FVector2D
---@return FVector2D
function UIUtil.ScreenToViewport(ScreenPosition)
	local ViewportPosition = FVector2D(0, 0)

	UUIUtil.ScreenToViewport(ScreenPosition, ViewportPosition)

	return ViewportPosition
end

---GetWidgetAbsolutePosition
---@param InWidget UWidget
---@return FVector2D
function UIUtil.GetWidgetAbsolutePosition(InWidget)
	return UUIUtil.GetWidgetAbsolutePosition(InWidget)
end

function UIUtil.GetWidgetPosition(InWidget)
	if nil == InWidget then
		return _G.UE.FVector2D(0, 0)
	end

	local ZeroFVector = _G.UE.FVector2D(0, 0)
	local LocalPosition = _G.UE.FVector2D(0, 0)
	--参数要传齐
	UUIUtil.ScreenToWidgetLocal(InWidget, ZeroFVector, LocalPosition, false)

	return LocalPosition * -1
end


---AdjustTipsPosition @ TipsUtil有新的适配规则，尽量使用TipsUtil.AdjustTipsPosition接口
---@param InTipsWidget table
---@param InTargetWidget table
---@param InOffset table
---@deprecated
function UIUtil.AdjustTipsPosition(InTipsWidget, InTargetWidget, InOffset)
	if nil == InTipsWidget then
		return
	end
	if nil == InTargetWidget then
		return
	end

	local ScreenSize = UIUtil.GetScreenSize()
	local TargetWidgetSize = UUIUtil.GetLocalSize(InTargetWidget)
	local TargetWidgetPosition = UIUtil.GetWidgetPosition(InTargetWidget)

	local TipsWidgetSize
	local IsAutoSize = UIUtil.CanvasSlotGetAutoSize(InTipsWidget) -- BP资源中勾选SizeToContent
	if IsAutoSize then
		InTipsWidget:ForceLayoutPrepass()
		TipsWidgetSize = InTipsWidget:GetDesiredSize()
	else
		TipsWidgetSize = UIUtil.CanvasSlotGetSize(InTipsWidget)
	end

	local Position = _G.UE.FVector2D(0, 0)

	local Slot = UIUtil.SlotAsCanvasSlot(InTipsWidget)
	Position = Slot:GetPosition()
	local Alignment = FVector2D(0, 0)

	if TargetWidgetPosition.X + TargetWidgetSize.X / 2 <= ScreenSize.X / 2 then
		Position.X = TargetWidgetPosition.X + TargetWidgetSize.X

		if nil ~= InOffset and nil ~= InOffset.X then
			Position.X = Position.X + InOffset.X
		end
	else
		Position.X = TargetWidgetPosition.X
		Alignment.X = 1

		if nil ~= InOffset and nil ~= InOffset.X then
			Position.X = Position.X - InOffset.X
		end
	end

	Position.Y = TargetWidgetPosition.Y

	if nil ~= InOffset and nil ~= InOffset.Y then
		Position.Y = Position.Y + InOffset.Y
	end

	if ScreenSize.Y - BottomMargin - Position.Y < TipsWidgetSize.Y then
		Position.Y = ScreenSize.Y - BottomMargin - TipsWidgetSize.Y
	end

	if nil == Slot then
		return
	end

	Slot:SetAlignment(Alignment)
	Slot:SetPosition(Position)
end

---第二种适配方法，解决使用了scale组件计算位置不对的情况
function UIUtil.AdjustTipsPosition2(InTipsWidget, InTargetWidget, InOffset)
	if nil == InTipsWidget then
		return
	end
	if nil == InTargetWidget then
		return
	end

	local ScreenSize = UIUtil.GetScreenSize()
	local ViewportSize = UIUtil.GetViewportSize()
	local TargetWidgetSize = UUIUtil.GetLocalSize(InTargetWidget)
	-- local TipsWidgetSize = UIUtil.CanvasSlotGetSize(InTipsWidget)
	
	local TipsWidgetSize = nil
	local IsAutoSize = UIUtil.CanvasSlotGetAutoSize(InTipsWidget) -- BP资源中勾选SizeToContent
	if IsAutoSize then
		InTipsWidget:ForceLayoutPrepass()
		TipsWidgetSize = InTipsWidget:GetDesiredSize()
	else
		TipsWidgetSize = UIUtil.CanvasSlotGetSize(InTipsWidget)
	end


	local TargetWidgetPosition = {}

	local TragetAbsolute = UIUtil.GetWidgetAbsolutePosition(InTargetWidget)
	local TipsAbsolute = UIUtil.AbsoluteToLocal(InTipsWidget, TragetAbsolute)
	local WindowAbsolute = UIUtil.ScreenToWidgetAbsolute(_G.UE.FVector2D(0, 0), false)
	TargetWidgetPosition.X = (TipsAbsolute.X - WindowAbsolute.X) * ScreenSize.X / ViewportSize.X
	TargetWidgetPosition.Y = (TipsAbsolute.Y - WindowAbsolute.Y) * ScreenSize.Y / ViewportSize.Y

	local Position = _G.UE.FVector2D(0, 0)
	local Alignment = FVector2D(0, 0)

	if TargetWidgetPosition.X + TargetWidgetSize.X / 2 <= ScreenSize.X / 2 then
		Position.X = TargetWidgetPosition.X + TargetWidgetSize.X

		if nil ~= InOffset and nil ~= InOffset.X then
			Position.X = Position.X + InOffset.X
		end
	else
		Position.X = TargetWidgetPosition.X
		Alignment.X = 1

		if nil ~= InOffset and nil ~= InOffset.X then
			Position.X = Position.X - InOffset.X
		end
	end

	Position.Y = TargetWidgetPosition.Y

	if nil ~= InOffset and nil ~= InOffset.Y then
		Position.Y = Position.Y + InOffset.Y
	end

	if ScreenSize.Y - BottomMargin - Position.Y < TipsWidgetSize.Y then
		Position.Y = ScreenSize.Y - BottomMargin - TipsWidgetSize.Y
	end

	local Slot = UIUtil.SlotAsCanvasSlot(InTipsWidget)
	if nil == Slot then
		return
	end

	Slot:SetAlignment(Alignment)
	Slot:SetPosition(Position)
end

--- 适配Tips位置（适配规则：Tips顶部和目标对齐）
---@param TipsWidget UWidget @Tips节点
---@param TargetWidget UWidget @目标节点
---@param InOffset _G.UE.FVector2D @偏移位置
function UIUtil.AdjustTipsPosition_Top(TipsWidget, TargetWidget, InOffset)
	if nil == TipsWidget or nil == TargetWidget then
		return
	end

	local TargetSlot = UIUtil.SlotAsCanvasSlot(TargetWidget)
	if nil == TargetSlot then
		return
	end

	local TargetParent = TargetSlot.Parent
	if nil == TargetParent then
		return
	end

	local TargetLocalPos = UIUtil.CanvasSlotGetPosition(TargetWidget)
	local ViewportPos = UIUtil.LocalToViewport(TargetParent, TargetLocalPos)

	local TipsSlot = UIUtil.SlotAsCanvasSlot(TipsWidget)
	if nil == TipsSlot then
		return
	end

	local TipsWidgetSize = nil
	local IsAutoSize = UIUtil.CanvasSlotGetAutoSize(TipsWidget) -- BP资源中勾选SizeToContent
	if IsAutoSize then
		TipsWidget:ForceLayoutPrepass()
		TipsWidgetSize = TipsWidget:GetDesiredSize()
	else
		TipsWidgetSize = UIUtil.CanvasSlotGetSize(TipsWidget)
	end

	local BottomShrink = 0
	local ScreenSize = UIUtil.GetScreenSize()
	local OverHeight = (ViewportPos.Y + TipsWidgetSize.Y) - ScreenSize.Y
	if OverHeight > 0 then
		ViewportPos.Y = ViewportPos.Y - OverHeight
		BottomShrink = BottomMargin
	end

	local TipsParent = TipsSlot.Parent
	if nil == TipsParent then
		return
	end

	local LocalPos = UIUtil.ViewportToLocal(TipsParent, ViewportPos)
	if InOffset then
		LocalPos.X = LocalPos.X + InOffset.X
	end

	if InOffset then
		LocalPos.Y = LocalPos.Y + InOffset.Y - BottomShrink

	else
		LocalPos.Y = LocalPos.Y - BottomShrink
	end

	UIUtil.CanvasSlotSetPosition(TipsWidget, LocalPos)
end

---IsToggleButtonChecked
---@param State EToggleButtonState
---@return boolean
function UIUtil.IsToggleButtonChecked(State)
	return EToggleButtonState.Checked == State
end

---IsToggleButtonLocked
---@param State EToggleButtonState
---@return boolean
function UIUtil.IsToggleButtonLocked(State)
	return EToggleButtonState.Locked == State
end

function UIUtil.SetImageDesaturate(image, ImgPath, Desaturation, bNoMask)
	if not Desaturation then
		Desaturation = 0
	end

	local IsDirty = false
	local DynamicMat = image:GetDynamicMaterial()
	if not DynamicMat then
		--FLOG_ERROR("UIUtil.SetImageDesaturate， but image No Material")
		return
	end

	local SetMat = function(bDirty)
		if Desaturation then
			DynamicMat:SetScalarParameterValue("Desaturation", Desaturation)
			bDirty = true
		end
		if bDirty then
			image:SetBrushFromMaterial(DynamicMat)
		end
	end

	if ImgPath and ImgPath ~= "" then
		local Tex = _G.ObjectMgr:GetObject(ImgPath)
		if Tex then
			DynamicMat:SetTextureParameterValue("Texture", Tex)
			if bNoMask then
				local Tex2 = _G.ObjectMgr:LoadObjectSync(GrayMask)
				DynamicMat:SetTextureParameterValue("Mask", Tex2)
			end
			IsDirty = true
		else
			_G.ObjectMgr:LoadObjectAsync(ImgPath, function()
				Tex = _G.ObjectMgr:GetObject(ImgPath)
				DynamicMat:SetTextureParameterValue("Texture", Tex)
				if bNoMask then
					local Tex2 = _G.ObjectMgr:LoadObjectSync(GrayMask)
					DynamicMat:SetTextureParameterValue("Mask", Tex2)
				end
				IsDirty = true
				SetMat(IsDirty)
			end, ObjectGCType.LRU)
		end
	end

	SetMat(IsDirty)
end

function UIUtil.SetToggleButtonSlotType(Widget, ToggleButtonState)
	UUIUtil.SetToggleButtonSlotType(Widget, ToggleButtonState)
end

function UIUtil.SetToggleButtonState(Widget, ToggleButtonState)
	UUIUtil.SetToggleButtonState(Widget, ToggleButtonState)
end


---QInterpTo
---@param Current FRotator
---@param Target FRotator
---@param DeltaTime float
---@param InterpSpeed float
---@return FRotator
function UIUtil.QInterpTo(Current, Target, DeltaTime, InterpSpeed)
	return UUIUtil.QInterpTo(Current, Target, DeltaTime, InterpSpeed)
end

---PlayAnimationTimePoint 定格在动画的某个时刻。
---@param Widget UUserWidget 控件
---@param Anim UWidgetAnimation 动画
---@param Time float 定格时间点
---@param NumLoopsToPlay int 循环次数
---@param PlayMode EUMGSequencePlayMode 模式
---@param PlaybackSpeed float 播放速度
---@param bRestoreState bool 停止播放是否保存播放进度
---@return UUMGSequencePlayer
function UIUtil.PlayAnimationTimePoint(Widget, Anim, Time, NumLoopsToPlay, PlayMode, PlaybackSpeed, bRestoreState)
	--[[
		- 没找到引擎定格在动画的某个时刻的方法。
		- 动画的处理逻辑是异步的，在Tick里，PlayAnimation后立即Stop行不通。
		- PlayAnimationTimeRange的参数StartTime = EndTime也不行，在计时器自增和处理逻辑前就被干掉了。
		- 是否到达EndTime是在计数器自增之前进行的，所以稍微给个Time偏移就可以让动画只有肉眼难以察觉的偏移，达到定格在动画的某个时刻效果。
	]]
	return Widget:PlayAnimationTimeRange(Anim, Time, Time + 0.01, NumLoopsToPlay, PlayMode, PlaybackSpeed, bRestoreState)
end

---PlayAnimationTimePoint 定格在动画的某个时刻Pct。
---@param Widget UUserWidget 控件
---@param Anim UWidgetAnimation 动画
---@param Pct float 定格时间点百分比取值[0-1]
---@param NumLoopsToPlay int 循环次数
---@param PlayMode EUMGSequencePlayMode 模式
---@param PlaybackSpeed float 播放速度
---@param bRestoreState bool 停止播放是否保存播放进度
---@return UUMGSequencePlayer
function UIUtil.PlayAnimationTimePointPct(Widget, Anim, Pct, NumLoopsToPlay, PlayMode, PlaybackSpeed, bRestoreState)
	Pct = math.min(math.max(Pct, 0), 1.0)
	local StartTime = Anim:GetStartTime()
	local EndTime = Anim:GetEndTime()
	local DeltaTime = EndTime - StartTime
	local Time = StartTime + Pct * DeltaTime
	return UIUtil.PlayAnimationTimePoint(Widget, Anim, Time, NumLoopsToPlay, PlayMode, PlaybackSpeed, bRestoreState)
end

---GetIconPath 根据IconID获取图标资源路径
---@param IconID number
---@return string
function UIUtil.GetIconPath(IconID)
	local Folder = IconID // 1000 * 1000
	local path = string.format("Texture2D'/Game/Assets/Icon/ItemIcon/%06d/UI_Icon_%06d.UI_Icon_%06d'", Folder, IconID, IconID)
	--TODO(loiafeng): 到多语言模块查找
	-- if not _G.UPathMgr.ExistFile(path) then
	-- end
	return path
end

--根据IconID获取图标资源路径,  仅仅是数字的文件夹，不包括类似ItemIcon的那种
function UIUtil.GetCommonIconPath(IconID)
	local Folder = IconID // 1000 * 1000
	local path = string.format("Texture2D'/Game/Assets/Icon/%06d/UI_Icon_%06d.UI_Icon_%06d'", Folder, IconID, IconID)
	return path
end

---ProjectWorldLocationToScreenCaptureScene
---@param SceneCaptureComponent2D USceneCaptureComponent2D
---@param InWorldLocation FVector
---@param OutScreenLocation FVector2D
---@return boolean
function UIUtil.ProjectWorldLocationToScreenCaptureScene(SceneCaptureComponent2D, InWorldLocation, OutScreenLocation)
	return UUIUtil.ProjectWorldLocationToScreenCaptureScene(SceneCaptureComponent2D, InWorldLocation, OutScreenLocation)
end

--- 当文本框只有两个字符时，自动在中间添加空格，仅在中日韩语言下生效，目前仅在弹窗标题和按钮中使用
--- @param TextWidget UFTextBlock
function UIUtil.AutoAddSpaceForTwoWords(TextWidget)
	if (CommonUtil.IsCurCultureChinese() or CommonUtil.IsCurCultureJapanese() or CommonUtil.IsCurCultureKorean()) then
		local Text = TextWidget:GetText()
		local Length = UTF8Util.Len(Text)
		if Text and Length == 2 then
			local NewText = UTF8Util.Sub(Text, 1, 1) .. "  " .. UTF8Util.Sub(Text, 2, 2)
			TextWidget:SetText(NewText)
		elseif Text and Length == 3 and UTF8Util.Sub(Text, 2, 2) == " " then
			local NewText = UTF8Util.Sub(Text, 1, 1) .. "  " .. UTF8Util.Sub(Text, 3, 3)
			TextWidget:SetText(NewText)
		end
	end
end

---PlayVideo
---@param BPPath string UI_BP的路径（如"/Game/UI/BP/UMGVideoPlayer/UMGVideoPlayer_UIBP.UMGVideoPlayer_UIBP_C"）
---@param VideoPath string Video路径（如"./Movies/logo.mp4"）
function UIUtil.PlayVideo(BPPath, VideoPath)
	local VideoPlayerActor = _G.CommonUtil.SpawnActor(_G.UE.AUMGVideoPlayer.StaticClass())
	if nil ~= VideoPlayerActor then
		VideoPlayerActor:ShowWidget(BPPath,
	 		"FileMediaSource'/Game/Movies/MediaAssets/UMGVideo.UMGVideo'",
	 		VideoPath,
	 		"MediaPlayer'/Game/Movies/MediaAssets/UMGVideo_MP.UMGVideo_MP'")
	end
end

--- 删掉前后空白字符
function UIUtil:Trim(Str)
	return (string.gsub(Str, "^%s*(.-)%s*$", "%1"))
end

return UIUtil

