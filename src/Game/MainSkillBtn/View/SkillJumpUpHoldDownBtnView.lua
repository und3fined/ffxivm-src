---
--- Author: henghaoli
--- DateTime: 2025-03-13 19:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local KML = _G.UE.UKismetMathLibrary

---@class SkillJumpUpHoldDownBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnMove UFButton
---@field FCanvasPanel_54 UFCanvasPanel
---@field ImgNormal UFImage
---@field ImgRevolve UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillJumpUpHoldDownBtnView = LuaClass(UIView, true)

function SkillJumpUpHoldDownBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnMove = nil
	--self.FCanvasPanel_54 = nil
	--self.ImgNormal = nil
	--self.ImgRevolve = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillJumpUpHoldDownBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillJumpUpHoldDownBtnView:OnInit()
	self.WidgetCenter = _G.UE.FVector2D(0, 0)
end

function SkillJumpUpHoldDownBtnView:OnDestroy()

end

function SkillJumpUpHoldDownBtnView:OnShow()

end

function SkillJumpUpHoldDownBtnView:OnHide()

end

function SkillJumpUpHoldDownBtnView:OnRegisterUIEvent()

end

function SkillJumpUpHoldDownBtnView:OnRegisterGameEvent()

end

function SkillJumpUpHoldDownBtnView:OnRegisterBinder()

end

function SkillJumpUpHoldDownBtnView:InitGeometryData()
	local Geometry = self:GetCachedGeometry()
	local _, BasePos = _G.UE.USlateBlueprintLibrary.LocalToViewport(self, Geometry, _G.UE.FVector2D(0,0))
	self.RenderTransformScale = self.RenderTransform.Scale
	local BaseSize = UIUtil.CanvasSlotGetSize(self.FCanvasPanel_54) * self.RenderTransformScale

	self.WidgetCenter = BaseSize * 0.5 + BasePos
	self.RadiusXY = BaseSize * 0.5
	self.RadiusSquared = self.RadiusXY.X * self.RadiusXY.X--假设X==Y，用于拖拽最大值，拖拽超出该范围后视为最大距离
	-- print("SkillJumpUpHoldDownBtnView:InitGeometryData", self.WidgetCenter)
end

--获取选点角度，该角度以UI控件X轴向上为0，顺时针旋转（为什么不以水平向右为0呢）
local function GetAngle(NormalVec, TargetVec)
	local CosAngle = _G.UE.FVector2D.Cross(NormalVec, TargetVec)
	local Angle = KML.DegAsin(CosAngle)
	if TargetVec.Y >= 0 then
		Angle = 180 - Angle
	elseif TargetVec.X > 0 then
		Angle = Angle + 360
	end
	Angle = 360 - Angle
	return Angle
end

function SkillJumpUpHoldDownBtnView:GetAngle()
	return self.Angle or 0
end

function SkillJumpUpHoldDownBtnView:GetPercent()
	return self.Percent or 0
end

function SkillJumpUpHoldDownBtnView:OnJoyStickMove(MousePosition)
	local SelfGeometry = _G.UE.UWidgetLayoutLibrary.GetViewportWidgetGeometry(self)
	local CurMousePosition = _G.UE.USlateBlueprintLibrary.AbsoluteToLocal(SelfGeometry, MousePosition)

	local DistSquared = _G.UE.FVector2D.DistSquared(CurMousePosition, self.WidgetCenter)
	self.Percent = 1	--拖拽距离百分比，1为最大距离
	if DistSquared < self.RadiusSquared then
		self.Percent = DistSquared / self.RadiusSquared
	end

	--计算输入偏移角度
	local NormalDirVec = _G.UE.FVector2D(0, 1)
	local LocalDir = CurMousePosition - self.WidgetCenter
	_G.UE.FVector2D.Normalize(LocalDir)
	self.Angle = GetAngle(NormalDirVec, LocalDir)

	--指示器不超过外层圈范围
	if self.Percent < 1 then
		UIUtil.CanvasSlotSetPosition(self.BtnMove, (CurMousePosition - self.WidgetCenter) / self.RenderTransformScale)
	else
		UIUtil.CanvasSlotSetPosition(self.BtnMove, self.RadiusXY * LocalDir / self.RenderTransformScale)
	end
	-- print("SkillJumpUpHoldDownBtnView:OnJoyStickMove", CurMousePosition, DistSquared, self.Percent, self.Angle)
end

return SkillJumpUpHoldDownBtnView