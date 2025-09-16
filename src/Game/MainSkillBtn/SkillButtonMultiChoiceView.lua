---
--- Author: chaooren
--- DateTime: 2022-03-01 15:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local SkillUtil = require("Utils/SkillUtil")


local CDNormalColor = "FFFBCBFF"
local CDDisableColor = "999891FF"


---@class SkillButtonMultiChoiceView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EFF_Loop_Color_Inst_2 UFImage
---@field EFF_Loop_Color_Inst_3 UFImage
---@field EFF_Loop_Color_Inst_4 UFImage
---@field FImg_2Ready1 UFImage
---@field FImg_2Ready2 UFImage
---@field FImg_3Ready1 UFImage
---@field FImg_3Ready2 UFImage
---@field FImg_3Ready3 UFImage
---@field FImg_4Ready1 UFImage
---@field FImg_4Ready2 UFImage
---@field FImg_4Ready3 UFImage
---@field FImg_4Ready4 UFImage
---@field FImg_Touch UFImage
---@field FImg_Touch_1 UFImage
---@field ImgMultiBkg UFImage
---@field MultiChoiceBkg UFCanvasPanel
---@field MultiChoiceBkg_1 UFCanvasPanel
---@field MultiChoiceCDSwitcher UWidgetSwitcher
---@field SkillCD_2_1 UFImage
---@field SkillCD_2_2 UFImage
---@field SkillCD_3_1 UFImage
---@field SkillCD_3_2 UFImage
---@field SkillCD_3_3 UFImage
---@field SkillCD_4_1 UFImage
---@field SkillCD_4_2 UFImage
---@field SkillCD_4_3 UFImage
---@field SkillCD_4_4 UFImage
---@field AnimFinish2_1 UWidgetAnimation
---@field AnimFinish2_2 UWidgetAnimation
---@field AnimFinish3_1 UWidgetAnimation
---@field AnimFinish3_2 UWidgetAnimation
---@field AnimFinish3_3 UWidgetAnimation
---@field AnimFinish4_1 UWidgetAnimation
---@field AnimFinish4_2 UWidgetAnimation
---@field AnimFinish4_3 UWidgetAnimation
---@field AnimFinish4_4 UWidgetAnimation
---@field AnimRelease2_1 UWidgetAnimation
---@field AnimRelease2_2 UWidgetAnimation
---@field AnimRelease3_1 UWidgetAnimation
---@field AnimRelease3_2 UWidgetAnimation
---@field AnimRelease3_3 UWidgetAnimation
---@field AnimRelease4_1 UWidgetAnimation
---@field AnimRelease4_2 UWidgetAnimation
---@field AnimRelease4_3 UWidgetAnimation
---@field AnimRelease4_4 UWidgetAnimation
---@field AnimSelect2_1 UWidgetAnimation
---@field AnimSelect2_2 UWidgetAnimation
---@field AnimSelect3_1 UWidgetAnimation
---@field AnimSelect3_2 UWidgetAnimation
---@field AnimSelect3_3 UWidgetAnimation
---@field AnimSelect4_1 UWidgetAnimation
---@field AnimSelect4_2 UWidgetAnimation
---@field AnimSelect4_3 UWidgetAnimation
---@field AnimSelect4_4 UWidgetAnimation
---@field AnimSelectNull UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillButtonMultiChoiceView = LuaClass(UIView, true)

function SkillButtonMultiChoiceView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EFF_Loop_Color_Inst_2 = nil
	--self.EFF_Loop_Color_Inst_3 = nil
	--self.EFF_Loop_Color_Inst_4 = nil
	--self.FImg_2Ready1 = nil
	--self.FImg_2Ready2 = nil
	--self.FImg_3Ready1 = nil
	--self.FImg_3Ready2 = nil
	--self.FImg_3Ready3 = nil
	--self.FImg_4Ready1 = nil
	--self.FImg_4Ready2 = nil
	--self.FImg_4Ready3 = nil
	--self.FImg_4Ready4 = nil
	--self.FImg_Touch = nil
	--self.FImg_Touch_1 = nil
	--self.ImgMultiBkg = nil
	--self.MultiChoiceBkg = nil
	--self.MultiChoiceBkg_1 = nil
	--self.MultiChoiceCDSwitcher = nil
	--self.SkillCD_2_1 = nil
	--self.SkillCD_2_2 = nil
	--self.SkillCD_3_1 = nil
	--self.SkillCD_3_2 = nil
	--self.SkillCD_3_3 = nil
	--self.SkillCD_4_1 = nil
	--self.SkillCD_4_2 = nil
	--self.SkillCD_4_3 = nil
	--self.SkillCD_4_4 = nil
	--self.AnimFinish2_1 = nil
	--self.AnimFinish2_2 = nil
	--self.AnimFinish3_1 = nil
	--self.AnimFinish3_2 = nil
	--self.AnimFinish3_3 = nil
	--self.AnimFinish4_1 = nil
	--self.AnimFinish4_2 = nil
	--self.AnimFinish4_3 = nil
	--self.AnimFinish4_4 = nil
	--self.AnimRelease2_1 = nil
	--self.AnimRelease2_2 = nil
	--self.AnimRelease3_1 = nil
	--self.AnimRelease3_2 = nil
	--self.AnimRelease3_3 = nil
	--self.AnimRelease4_1 = nil
	--self.AnimRelease4_2 = nil
	--self.AnimRelease4_3 = nil
	--self.AnimRelease4_4 = nil
	--self.AnimSelect2_1 = nil
	--self.AnimSelect2_2 = nil
	--self.AnimSelect3_1 = nil
	--self.AnimSelect3_2 = nil
	--self.AnimSelect3_3 = nil
	--self.AnimSelect4_1 = nil
	--self.AnimSelect4_2 = nil
	--self.AnimSelect4_3 = nil
	--self.AnimSelect4_4 = nil
	--self.AnimSelectNull = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillButtonMultiChoiceView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillButtonMultiChoiceView:OnInit()
	self.MultiChoiceCount = 1
	self.FinishStatus = {}
	self.CDValidList = {}

	self.SkillCD_Count_Index = {
		[2] = {[1] = self.SkillCD_2_1, [2] = self.SkillCD_2_2},
		[3] = {[1] = self.SkillCD_3_1, [2] = self.SkillCD_3_2, [3] = self.SkillCD_3_3},
		[4] = {[1] = self.SkillCD_4_1, [2] = self.SkillCD_4_2, [3] = self.SkillCD_4_3, [4] = self.SkillCD_4_4},
	}

	self.ImgReady_Count_Index = {
		[2] = {[1] = self.FImg_2Ready1, [2] = self.FImg_2Ready2},
		[3] = {[1] = self.FImg_3Ready1, [2] = self.FImg_3Ready2, [3] = self.FImg_3Ready3},
		[4] = {[1] = self.FImg_4Ready1, [2] = self.FImg_4Ready2, [3] = self.FImg_4Ready3, [4] = self.FImg_4Ready4},
	}

	self.AnimFinish_Count_Index = {
		[2] = {[1] = self.AnimFinish2_1, [2] = self.AnimFinish2_2},
		[3] = {[1] = self.AnimFinish3_1, [2] = self.AnimFinish3_2, [3] = self.AnimFinish3_3},
		[4] = {[1] = self.AnimFinish4_1, [2] = self.AnimFinish4_2, [3] = self.AnimFinish4_3, [4] = self.AnimFinish4_4},
	}

	self.AnimSelect_Count_Index = {
		[2] = {[1] = self.AnimSelect2_1, [2] = self.AnimSelect2_2},
		[3] = {[1] = self.AnimSelect3_1, [2] = self.AnimSelect3_2, [3] = self.AnimSelect3_3},
		[4] = {[1] = self.AnimSelect4_1, [2] = self.AnimSelect4_2, [3] = self.AnimSelect4_3, [4] = self.AnimSelect4_4},
	}

	self.AnimRelease_Count_Index = {
		[2] = {[1] = self.AnimRelease2_1, [2] = self.AnimRelease2_2},
		[3] = {[1] = self.AnimRelease3_1, [2] = self.AnimRelease3_2, [3] = self.AnimRelease3_3},
		[4] = {[1] = self.AnimRelease4_1, [2] = self.AnimRelease4_2, [3] = self.AnimRelease4_3, [4] = self.AnimRelease4_4},
	}
end

function SkillButtonMultiChoiceView:OnDestroy()

end

function SkillButtonMultiChoiceView:OnShow()
	self:UpdateView(self.Params)
end

function SkillButtonMultiChoiceView:UpdateView(Params)
	local IDList = Params.IDList
	local MultiChoiceCount = Params.MultiChoiceCount
	self.MultiChoiceCount = MultiChoiceCount
	self.ButtonIndex = Params.ButtonIndex
	self.MultiChoiceCDSwitcher:SetActiveWidgetIndex(MultiChoiceCount - 2)
	UIUtil.SetIsVisible(self.MultiChoiceBkg, false)
	UIUtil.SetIsVisible(self.MultiChoiceBkg_1, false)
	for i = 1, MultiChoiceCount do
		self.FinishStatus[i] = true
	end
	local FLinearColor = _G.UE.FLinearColor
	self.CDValidList = {}
	for i = 1, MultiChoiceCount do
		local SkillCDWidget = self.SkillCD_Count_Index[MultiChoiceCount][i]
		UIUtil.SetIsVisible(SkillCDWidget, false)

		local ReadyBg = self.ImgReady_Count_Index[MultiChoiceCount][i]
		local SkillID = IDList[i]
		local bSkillLearned = true
		if Params.bMajor then
			bSkillLearned = SkillUtil.IsMajorSkillLearned(SkillID.ID)
		end
		self.CDValidList[i] = bSkillLearned
		UIUtil.SetIsVisible(ReadyBg, true)

		local HexColor = bSkillLearned and CDNormalColor or CDDisableColor
		local LinearColor = FLinearColor.FromHex(HexColor)
		ReadyBg:SetColorAndOpacity(LinearColor)
	end
end

function SkillButtonMultiChoiceView:OnHide()

end

function SkillButtonMultiChoiceView:OnRegisterUIEvent()

end

function SkillButtonMultiChoiceView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.SkillSystemMultiChoiceFinish, self.OnSkillSystemMultiChoiceFinish)
end

function SkillButtonMultiChoiceView:OnRegisterBinder()

end

function SkillButtonMultiChoiceView:SetBkgVisibility(bBisibility)
	UIUtil.SetIsVisible(self.MultiChoiceBkg, bBisibility)
	UIUtil.SetIsVisible(self.MultiChoiceBkg_1, false)
end

function SkillButtonMultiChoiceView:OnMultiChoiceFinish(SelectIndex)
	local _ <close> = CommonUtil.MakeProfileTag("SkillButtonMultiChoiceView:OnMultiChoiceFinish")
	if SelectIndex and SelectIndex > 0 and SelectIndex <= self.MultiChoiceCount then
		--local SelectAnim = self.AnimSelect_Count_Index[self.MultiChoiceCount][SelectIndex]
		local SelectAnim = self.AnimRelease_Count_Index[self.MultiChoiceCount][SelectIndex]
		self:PlayAnimation(SelectAnim)
	end
	self:SetBkgVisibility(false)
end

function SkillButtonMultiChoiceView:ClearSelectedEffect()
	for i = 2, 4 do
		UIUtil.SetIsVisible(self[string.format("EFF_Loop_Color_Inst_%d", i)], false)
	end
end

function SkillButtonMultiChoiceView:GetHoverButtonIndex(MousePosition, bCalculateCenter, WidgetCenter)
	if bCalculateCenter then
		self.WidgetCenter = WidgetCenter
	end

	if self.MultiChoiceCount <= 1 then
		return 0
	end

	local MinDistanceSquared = 500
	local SelfGeometry = _G.UE.UWidgetLayoutLibrary.GetViewportWidgetGeometry(self)
	local CurPos = _G.UE.USlateBlueprintLibrary.AbsoluteToLocal(SelfGeometry, MousePosition)
	local OffPos = CurPos - self.WidgetCenter

	local NormalOffPos = _G.UE.FVector2D()
	NormalOffPos.X = OffPos.X
	NormalOffPos.Y = OffPos.Y
	_G.UE.FVector2D.Normalize(NormalOffPos)
	local Radius = UIUtil.CanvasSlotGetSize(self.ImgMultiBkg).X / 2
	local RadiusSquared = Radius * Radius
	local DistSquared = OffPos:SizeSquared()

	local ValidTouch = UIUtil.IsVisible(self.MultiChoiceBkg) and self.FImg_Touch or self.FImg_Touch_1

	if DistSquared < RadiusSquared then
		UIUtil.CanvasSlotSetPosition(ValidTouch, OffPos)
	else
		UIUtil.CanvasSlotSetPosition(ValidTouch, NormalOffPos * Radius)
	end

	local VecSize = OffPos:SizeSquared()
	if VecSize < MinDistanceSquared then
		return 0
	end

	local CosAngle = _G.UE.FVector2D.Cross(_G.UE.FVector2D(0, 1), NormalOffPos)
	local Angle = _G.UE.UKismetMathLibrary.DegAsin(CosAngle)
	if NormalOffPos.Y >= 0 then
		Angle = 180 - Angle
	elseif NormalOffPos.X > 0 then
		Angle = Angle + 360
	end
	Angle = 360 - Angle
	local Index = 0
	if self.MultiChoiceCount ~= 4 then
		Index = math.ceil(Angle / (360 / self.MultiChoiceCount))
	else
		Angle = Angle + 45
		if Angle > 360 then Angle = Angle - 360 end
		Index = math.ceil(Angle / 90)
	end

	--最边界的情况
	if Index == 0 then Index = 1 end

	return Index
end

function SkillButtonMultiChoiceView:OnUpdateSelectCD(Index, Rate)
	--未解锁技能不响应
	if not self.CDValidList[Index] then
		return
	end

	local MultiChoiceCount = self.MultiChoiceCount
	local SkillCDWidget = self.SkillCD_Count_Index[MultiChoiceCount][Index]
	local ReadyBg = self.ImgReady_Count_Index[MultiChoiceCount][Index]
	if SkillCDWidget and ReadyBg then
		if Rate < 0.001 then
			UIUtil.SetIsVisible(SkillCDWidget, false)
			UIUtil.SetIsVisible(ReadyBg, true)
			if self.FinishStatus[Index] == false then
				local FinishAnim = self.AnimFinish_Count_Index[MultiChoiceCount][Index]
				self:PlayAnimation(FinishAnim, 0, 1, nil, 1, true)
				self.FinishStatus[Index] = true
			end
		else
			UIUtil.SetIsVisible(SkillCDWidget, true)
			local DynamicMaterial = SkillCDWidget:GetDynamicMaterial()
			if DynamicMaterial then
				DynamicMaterial:SetScalarParameterValue("Progress", 1 - Rate)
			end
			UIUtil.SetIsVisible(ReadyBg, false)
			self.FinishStatus[Index] = false
			local FinishAnim = self.AnimFinish_Count_Index[MultiChoiceCount][Index]
			if self:IsAnimationPlaying(FinishAnim) then
				self:StopAnimation(FinishAnim)
			end
		end
	end
end

function SkillButtonMultiChoiceView:OnSelectedCancelChange(bCancel)
	UIUtil.SetIsVisible(self.MultiChoiceBkg, not bCancel)
	UIUtil.SetIsVisible(self.MultiChoiceBkg_1, bCancel)
end

function SkillButtonMultiChoiceView:OnSkillSystemMultiChoiceFinish(Index)
	if Index == self.ButtonIndex then
		self:OnMultiChoiceFinish()
	end
end

function SkillButtonMultiChoiceView:OnSkillCastSuccess(Index)

end

return SkillButtonMultiChoiceView