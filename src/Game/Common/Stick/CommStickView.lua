---
--- Author: Administrator
--- DateTime: 2025-03-21 20:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local FVector2D = _G.UE.FVector2D
local MathUtil = require("Utils/MathUtil")

---@class CommStickView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDragStart UFButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommStickView = LuaClass(UIView, true)

function CommStickView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnDragStart = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommStickView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.StickItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommStickView:OnInit()
	self:InitStickTouchItem()

	self.DV = FVector2D(0,0)
	self.NDV = FVector2D(0,0)
	self.NormVec = FVector2D(0,0)
	self.ImgVec = FVector2D(0,0)
end

function CommStickView:OnDestroy()

end

function CommStickView:OnShow()

end

function CommStickView:OnHide()

end

function CommStickView:OnRegisterUIEvent()

end

function CommStickView:OnRegisterGameEvent()

end

function CommStickView:OnRegisterBinder()

end

function CommStickView:SetParams(StartCallbak, MoveCallbak, EndCallbak)
	self.OnStartCallback = StartCallbak
	self.OnMoveCallback = MoveCallbak
	self.OnEndCallback = EndCallbak
end

function CommStickView:LogPos(Key, Pos)
	if not Pos then
		return
	end

	print(string.format('testinfo LogPos %s Pos X = %s, Y = %s', tostring(Key), tostring(Pos.X), tostring(Pos.Y)))
end

function CommStickView:OnMoveEnable(IsMove)
	if self.IsMove == IsMove then
		return
	end

	self.IsMove = IsMove

	UIUtil.SetIsVisible(self.ImgWheelBright, IsMove)
	UIUtil.SetIsVisible(self.ImgWheel, not IsMove)
end

function CommStickView:InitStickTouchItem()
	self.StickItem.View = self
	self.StickItem.TouchStartCB = self.OnTouchStickStart
	self.StickItem.TouchMoveCB = self.OnTouchStickMove
	self.StickItem.TouchEndCB = self.OnTouchStickEnd

	self.StickOriPos = FVector2D(104, 104)
	self.StickRad = 35
	-- self:LogPos("InitStickTouchItem", self.StickOriPos)
end

function CommStickView:OnTouchStickStart(Pos)
	self:StartMoveTimer()
	self:OnStartInner()
	-- self.StickStartPos = Pos
	-- self:LogPos("OnTouchStickStart", Pos)
end

function CommStickView:UpdateOutLine(IsShow, Vec)
	UIUtil.SetIsVisible(self.ImgArrow, IsShow)

	if IsShow then
		local Ang = MathUtil.GetAngle(Vec.X, Vec.Y)
		Ang = (Ang + 90) % 360
		self.ImgArrow:SetRenderTransformAngle(Ang)
	end
end

local function VecMulNum(Ref, Vec, Num)
	Ref.X = Vec.X * Num
	Ref.Y = Vec.Y * Num
end

function CommStickView:OnTouchStickMove(Pos)
	-- self:LogPos('OnTouchStickMove Pos', Pos)
	local StickR = self.StickRad

	local DV = self.DV
	local NDV = self.NDV
	local NormVec = self.NormVec
	local ImgVec = self.ImgVec

	-- 防断触
	self:OnMoveEnable(true)

	self.StickCurPos = Pos

	DV.X = self.StickCurPos.X - self.StickOriPos.X
	DV.Y = self.StickCurPos.Y - self.StickOriPos.Y

	NDV.X = DV.X
	NDV.Y = DV.Y
	FVector2D.Normalize(NDV)

	local Len = FVector2D.Size(DV)
	local Rate = Len / StickR
	Rate = math.clamp(Rate, 0, 1)
	VecMulNum(NormVec, NDV, Rate)

	local IsOut = Rate == 1
	self:UpdateOutLine(IsOut, NormVec)

	self.TickMoveVec = NormVec
	
	VecMulNum(ImgVec, NormVec, StickR)
	UIUtil.CanvasSlotSetPosition(self.ImgWheelBright, ImgVec)
end

function CommStickView:OnTouchStickEnd(Pos)
	-- UIUtil.ImageSetBrushFromAssetPath(self.StickPt, STICK_IMG_NM)
	UIUtil.CanvasSlotSetPosition(self.ImgWheel, FVector2D(0, 0))
	self:UpdateOutLine(false, nil)
	self:OnMoveEnable(false)
	self:EndMoveTimer()
	self:OnEndInner()
	-- self.TickMoveVec = nil
end

function CommStickView:EndMoveTimer()
	if self.CamMoveHdl then
		self:UnRegisterTimer(self.CamMoveHdl)
	end
end

function CommStickView:StartMoveTimer()
	self:EndMoveTimer()
	self.CamMoveHdl = self:RegisterTimer(self.OnMoveTimer, 0, 0.01, 0)
end

function CommStickView:OnMoveTimer()
	if not self.TickMoveVec then return end
	self:OnMoveInner(self.TickMoveVec)
end

--

function CommStickView:OnStartInner()
	if self.OnStartCallback then
		self.OnStartCallback()
	end
end

function CommStickView:OnMoveInner(NormVec)
	if self.OnMoveCallback then
		self.OnMoveCallback(NormVec)
	end
end

function CommStickView:OnEndInner()
	if self.OnEndCallback then
		self.OnEndCallback()
	end
end

return CommStickView