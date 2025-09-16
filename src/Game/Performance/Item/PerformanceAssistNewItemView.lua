---
--- Author: moodliu
--- DateTime: 2024-05-11 16:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderCanvasSlotSetPosition = require("Binder/UIBinderCanvasSlotSetPosition")
local UIBinderCanvasSlotSetSize = require("Binder/UIBinderCanvasSlotSetSize")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")

---@class PerformanceAssistNewItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgAllBlack UFImage
---@field ImgAllBlackLong UFImage
---@field ImgAllBlackLong2 UFImage
---@field ImgAllWhite UFImage
---@field ImgAllWhiteLong UFImage
---@field ImgAllWhiteLong2 UFImage
---@field ImgUPLongBarB UFImage
---@field ImgUPLongBarB2 UFImage
---@field ImgUPLongBarW UFImage
---@field ImgUPLongBarW2 UFImage
---@field ImgUpPointB UFImage
---@field ImgUpPointW UFImage
---@field PanelAllBlackLong_1 UFCanvasPanel
---@field PanelAllWhiteLong UFCanvasPanel
---@field PerformanceNewEffectKeyItem_UIBP PerformanceNewEffectKeyItemView
---@field AnimEliminate UWidgetAnimation
---@field AnimRecover UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceAssistNewItemView = LuaClass(UIView, true)

function PerformanceAssistNewItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgAllBlack = nil
	--self.ImgAllBlackLong = nil
	--self.ImgAllBlackLong2 = nil
	--self.ImgAllWhite = nil
	--self.ImgAllWhiteLong = nil
	--self.ImgAllWhiteLong2 = nil
	--self.ImgUPLongBarB = nil
	--self.ImgUPLongBarB2 = nil
	--self.ImgUPLongBarW = nil
	--self.ImgUPLongBarW2 = nil
	--self.ImgUpPointB = nil
	--self.ImgUpPointW = nil
	--self.PanelAllBlackLong_1 = nil
	--self.PanelAllWhiteLong = nil
	--self.PerformanceNewEffectKeyItem_UIBP = nil
	--self.AnimEliminate = nil
	--self.AnimRecover = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceAssistNewItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PerformanceNewEffectKeyItem_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceAssistNewItemView:OnInit()
	self.BottomOffset1 = 0
	self.BottomOffset2 = 0
	self.EffectOffset = 0
	self.SizeYOffset = 0
	self.MinSizeY = 0

	self.IsShowPanels = nil
	self.Timer = nil
	self.LastEffectAnimName = nil
end

function PerformanceAssistNewItemView:OnDestroy()

end

function PerformanceAssistNewItemView:OnShow()

end

function PerformanceAssistNewItemView:OnHide()

end

function PerformanceAssistNewItemView:OnCostTimeChanged(NewValue)
	local Unit = MPDefines.AssistantFallingDownConfig.UnitPerMs * NewValue
	local EarlyAppearOffsetUnit = MPDefines.AssistantFallingDownConfig.EarlyAppearOffsetMS * MPDefines.AssistantFallingDownConfig.UnitPerMs

	local CurPositionX, CurPositionY = self.VM.Position:GetValue()
	local MoveUnit = math.min(Unit - EarlyAppearOffsetUnit, 0)		-- min避免超出界限
	local NewPositionY = (self.BottomOffset1 + MoveUnit )
	self.VM.Position:SetValue(CurPositionX, NewPositionY)

	local CurPositionX2, CurPositionY2 = self.VM.Position2:GetValue()
	local NewPositionY2 = (self.BottomOffset2 + MoveUnit)
	self.VM.Position2:SetValue(CurPositionX2, NewPositionY2)

	local CurEffectPositionX, CurEffectPositionY = self.VM.EffectPosition:GetValue()
	local NewEffectPositionY = (self.EffectOffset + MoveUnit)
	self.VM.EffectPosition:SetValue(CurEffectPositionX, NewEffectPositionY)
end

function PerformanceAssistNewItemView:OnDurationChanged(NewValue)
	local NewSizeY = math.max(self.MinSizeY, self.SizeYOffset + MPDefines.AssistantFallingDownConfig.UnitPerMs * NewValue)
	
	self.VM.Size:SetValue(MPDefines.AssistantFallingDownConfig.BarNormalSizeX, NewSizeY)
end

function PerformanceAssistNewItemView:OnUIStateChanged(NewValue)
	local bShow = false
	self:StopAllEffectAnim()
	if NewValue == MPDefines.AssistantFallingDownConfig.UIStates.Miss then
		
	elseif NewValue == MPDefines.AssistantFallingDownConfig.UIStates.None then
		bShow = true
	elseif NewValue == MPDefines.AssistantFallingDownConfig.UIStates.Falling then
		bShow = true
	elseif NewValue == MPDefines.AssistantFallingDownConfig.UIStates.Press then
		bShow = true
		self:PlayEffectAnim(self:GetPressAnim())
		if not self.VM.IsLongClick then
			-- 先播动画，延迟隐藏
			local DelayTime = self:GetPressAnimEndTime()
			self.Timer = self:RegisterTimer(self.OnTimer, DelayTime)
		end
	elseif NewValue == MPDefines.AssistantFallingDownConfig.UIStates.WaitDestory then
		if self.VM.IsLongClick then
			self:StopAllEffectAnim()
		end
	end
	self:ShowPanels(bShow)
end

function PerformanceAssistNewItemView:ShowPanels(bShow)
	if self.IsShowPanels == bShow then
		return
	end
	self.IsShowPanels = bShow
	if bShow then
		self:PlayAnimation(self.AnimRecover)
	else
		self:PlayAnimation(self.AnimEliminate)
	end
end

function PerformanceAssistNewItemView:OnTimer()
	self:StopAllEffectAnim()
	self:ShowPanels(false)
end

function PerformanceAssistNewItemView:ClearTimer()
	if self.Timer then
		self:UnRegisterTimer(self.Timer)
		self.Timer = nil
	end
end

function PerformanceAssistNewItemView:PlayEffectAnim(AnimName, IsLoop)
	local EffectItem = self.PerformanceNewEffectKeyItem_UIBP
	if EffectItem then
		EffectItem:PlayAnimation(EffectItem[AnimName], 0, IsLoop and 0 or 1)
		self.LastEffectAnimName = AnimName
	end
end

function PerformanceAssistNewItemView:StopAllEffectAnim()
	local EffectItem = self.PerformanceNewEffectKeyItem_UIBP
	if EffectItem then
		if self.LastEffectAnimName then
 			EffectItem:StopAnimation(EffectItem[self.LastEffectAnimName])
			self.LastEffectAnimName = nil
		end
		EffectItem:PlayAnimation(EffectItem["AnimUnChick"])
	end
end

--- 返回Anim名和是否Loop
function PerformanceAssistNewItemView:GetPressAnim()
	local EffItem = self.PerformanceNewEffectKeyItem_UIBP
 	if EffItem then
		if not self.VM.IsLongClick then
			if self.VM.KeyOffset == 0 then
 				return "AnimComChick"
			elseif self.VM.KeyOffset > 0 then
				return "AnimHighChick"
			else
 				return "AnimLowChick"
			end
		else
			if self.VM.KeyOffset == 0 then
				return "AnimComLoop", true
		   elseif self.VM.KeyOffset > 0 then
			   return "AnimHighLoop", true
		   else
				return "AnimLowLoop", true
		   end
		end
 	end
end

function PerformanceAssistNewItemView:GetPressAnimEndTime()
	local EffectItem = self.PerformanceNewEffectKeyItem_UIBP
	if EffectItem then
		local AnimName = self:GetPressAnim()
		local AnimEndTime = EffectItem[AnimName] and EffectItem[AnimName]:GetEndTime()
		return AnimEndTime
	end
	return 0
end

function PerformanceAssistNewItemView:OnRegisterUIEvent()

end

function PerformanceAssistNewItemView:OnRegisterGameEvent()

end

function PerformanceAssistNewItemView:InitParams()
	local IsAllKey = self.VM.IsAllKey
	local IsBlackKey = self.VM.IsBlackKey
	local IsLongClick = self.VM.IsLongClick
	self.VM.ImgAllBlackVisible = IsAllKey and IsBlackKey and not IsLongClick
	self.VM.ImgAllBlackLongVisible = IsAllKey and IsBlackKey and IsLongClick
	self.VM.ImgAllBlackLong2Visible = IsAllKey and IsBlackKey and IsLongClick

	self.VM.ImgAllWhiteVisible = IsAllKey and not IsBlackKey and not IsLongClick
	self.VM.ImgAllWhiteLongVisible = IsAllKey and not IsBlackKey and IsLongClick
	self.VM.ImgAllWhiteLong2Visible = IsAllKey and not IsBlackKey and IsLongClick

	self.VM.ImgUPLongBarBVisible = not IsAllKey and IsBlackKey and IsLongClick
	self.VM.ImgUPLongBarB2Visible = not IsAllKey and IsBlackKey and IsLongClick

	self.VM.ImgUPLongBarWVisible = not IsAllKey and not IsBlackKey and IsLongClick
	self.VM.ImgUPLongBarW2Visible = not IsAllKey and not IsBlackKey and IsLongClick
	
	self.VM.ImgUpPointBVisible = not IsAllKey and IsBlackKey and not IsLongClick
	self.VM.ImgUpPointWVisible = not IsAllKey and not IsBlackKey and not IsLongClick

	local Path1, Path2 = MusicPerformanceUtil.GetAssistantImgPath(IsAllKey, IsLongClick, IsBlackKey, self.VM.KeyOffset)
	local AssistantFallingDownConfig = MPDefines.AssistantFallingDownConfig
	self.EffectOffset = AssistantFallingDownConfig.BottomOffsets.EffectOffset
	if IsLongClick then
		self.BottomOffset1 = IsAllKey 
			and AssistantFallingDownConfig.BottomOffsets.AllLongOffset1
			or AssistantFallingDownConfig.BottomOffsets.LongOffset1
		self.BottomOffset2 = AssistantFallingDownConfig.BottomOffsets.LongOffset2

		if IsAllKey and IsBlackKey then
			self.VM.ImgAllBlackImgPath = Path1
			self.VM.ImgAllBlack2ImgPath = Path2
			self.SizeYOffset = AssistantFallingDownConfig.SizeOffsets.All_Black
			self.MinSizeY = AssistantFallingDownConfig.MinSize.All_Black
		elseif IsAllKey and not IsBlackKey then
			self.VM.ImgAllWhiteLongImgPath = Path1
			self.VM.ImgAllWhiteLong2ImgPath = Path2
			self.SizeYOffset = AssistantFallingDownConfig.SizeOffsets.All_White
			self.MinSizeY = AssistantFallingDownConfig.MinSize.All_White
		elseif not IsAllKey and IsBlackKey then
			self.VM.ImgUPLongBarBImgPath = Path1
			self.VM.ImgUPLongBarB2ImgPath = Path2
			self.SizeYOffset = AssistantFallingDownConfig.SizeOffsets.Black
			self.MinSizeY = AssistantFallingDownConfig.MinSize.Black
		else
			self.VM.ImgUPLongBarWImgPath = Path1
			self.VM.ImgUPLongBarW2ImgPath = Path2
			self.SizeYOffset = AssistantFallingDownConfig.SizeOffsets.White
			self.MinSizeY = AssistantFallingDownConfig.MinSize.White
		end
	else
		self.BottomOffset1 = AssistantFallingDownConfig.BottomOffsets.ShortOffset
		if IsAllKey and IsBlackKey then
			self.VM.ImgAllBlackImgPath = Path1
		elseif IsAllKey and not IsBlackKey then
			self.VM.ImgAllWhiteImgPath = Path1
		elseif not IsAllKey and IsBlackKey then
			self.VM.ImgUpPointBImgPath = Path1
		else
			self.VM.ImgUpPointWImgPath = Path1
		end
	end
end

function PerformanceAssistNewItemView:OnRegisterBinder()
	self.VM = self.Params and self.Params.Data or nil
	self.Binders = self.Binders or {
		{ "ImgAllBlackVisible" , UIBinderSetIsVisible.New(self, self.ImgAllBlack) },
		{ "ImgAllBlackLongVisible" , UIBinderSetIsVisible.New(self, self.ImgAllBlackLong) },
		{ "ImgAllBlackLong2Visible" , UIBinderSetIsVisible.New(self, self.ImgAllBlackLong2) },
		{ "ImgAllWhiteVisible" , UIBinderSetIsVisible.New(self, self.ImgAllWhite) },
		{ "ImgAllWhiteLongVisible" , UIBinderSetIsVisible.New(self, self.ImgAllWhiteLong) },
		{ "ImgAllWhiteLong2Visible" , UIBinderSetIsVisible.New(self, self.ImgAllWhiteLong2) },
		{ "ImgUPLongBarBVisible" , UIBinderSetIsVisible.New(self, self.ImgUPLongBarB) },
		{ "ImgUPLongBarB2Visible" , UIBinderSetIsVisible.New(self, self.ImgUPLongBarB2) },
		{ "ImgUPLongBarWVisible" , UIBinderSetIsVisible.New(self, self.ImgUPLongBarW) },
		{ "ImgUPLongBarW2Visible" , UIBinderSetIsVisible.New(self, self.ImgUPLongBarW2) },
		{ "ImgUpPointBVisible" , UIBinderSetIsVisible.New(self, self.ImgUpPointB) },
		{ "ImgUpPointWVisible" , UIBinderSetIsVisible.New(self, self.ImgUpPointW) },

		{ "ImgAllBlackImgPath" , UIBinderSetImageBrush.New(self, self.ImgAllBlack) },
		{ "ImgAllBlackLongImgPath" , UIBinderSetImageBrush.New(self, self.ImgAllBlackLong) },
		{ "ImgAllBlackLong2ImgPath" , UIBinderSetImageBrush.New(self, self.ImgAllBlackLong2) },
		{ "ImgAllWhiteImgPath" , UIBinderSetImageBrush.New(self, self.ImgAllWhite) },
		{ "ImgAllWhiteLongImgPath" , UIBinderSetImageBrush.New(self, self.ImgAllWhiteLong) },
		{ "ImgAllWhiteLong2ImgPath" , UIBinderSetImageBrush.New(self, self.ImgAllWhiteLong2) },
		{ "ImgUPLongBarBImgPath" , UIBinderSetImageBrush.New(self, self.ImgUPLongBarB) },
		{ "ImgUPLongBarB2ImgPath" , UIBinderSetImageBrush.New(self, self.ImgUPLongBarB2) },
		{ "ImgUPLongBarWImgPath" , UIBinderSetImageBrush.New(self, self.ImgUPLongBarW) },
		{ "ImgUPLongBarW2ImgPath" , UIBinderSetImageBrush.New(self, self.ImgUPLongBarW2) },
		{ "ImgUpPointBImgPath" , UIBinderSetImageBrush.New(self, self.ImgUpPointB) },
		{ "ImgUpPointWImgPath" , UIBinderSetImageBrush.New(self, self.ImgUpPointW) },

		{ "Size" , UIBinderCanvasSlotSetSize.New(self, self.ImgAllBlackLong) },
		{ "Size" , UIBinderCanvasSlotSetSize.New(self, self.ImgAllWhiteLong) },
		{ "Size" , UIBinderCanvasSlotSetSize.New(self, self.ImgUPLongBarB) },
		{ "Size" , UIBinderCanvasSlotSetSize.New(self, self.ImgUPLongBarW) },

		{ "Position" , UIBinderCanvasSlotSetPosition.New(self, self.ImgAllBlack) },
		{ "Position" , UIBinderCanvasSlotSetPosition.New(self, self.ImgAllBlackLong) },
		{ "Position" , UIBinderCanvasSlotSetPosition.New(self, self.ImgAllWhite) },
		{ "Position" , UIBinderCanvasSlotSetPosition.New(self, self.ImgAllWhiteLong) },
		{ "Position" , UIBinderCanvasSlotSetPosition.New(self, self.ImgUPLongBarB) },
		{ "Position" , UIBinderCanvasSlotSetPosition.New(self, self.ImgUPLongBarW) },
		{ "Position" , UIBinderCanvasSlotSetPosition.New(self, self.ImgUpPointB) },
		{ "Position" , UIBinderCanvasSlotSetPosition.New(self, self.ImgUpPointW) },

		{ "Position2" , UIBinderCanvasSlotSetPosition.New(self, self.ImgAllBlackLong2) },
		{ "Position2" , UIBinderCanvasSlotSetPosition.New(self, self.ImgAllWhiteLong2) },
		{ "Position2" , UIBinderCanvasSlotSetPosition.New(self, self.ImgUPLongBarB2) },
		{ "Position2" , UIBinderCanvasSlotSetPosition.New(self, self.ImgUPLongBarW2) },
		{ "EffectPosition" , UIBinderCanvasSlotSetPosition.New(self, self.PerformanceNewEffectKeyItem_UIBP) },

		{ "CostTime" , UIBinderValueChangedCallback.New(self, nil, self.OnCostTimeChanged) },
		{ "Duration" , UIBinderValueChangedCallback.New(self, nil, self.OnDurationChanged) },
		-- { "IsAllKey" , UIBinderValueChangedCallback.New(self, nil, self.OnImgTypeChanged) },
		-- { "IsBlackKey" , UIBinderValueChangedCallback.New(self, nil, self.OnImgTypeChanged) },
		-- { "IsLongClick" , UIBinderValueChangedCallback.New(self, nil, self.OnImgTypeChanged) },
		-- { "KeyOffset" , UIBinderValueChangedCallback.New(self, nil, self.OnImgTypeChanged) },
		{ "UIState" , UIBinderValueChangedCallback.New(self, nil, self.OnUIStateChanged) },
	}

	if self.VM then
		self:InitParams()
		self:RegisterBinders(self.VM, self.Binders)
	end
end

return PerformanceAssistNewItemView