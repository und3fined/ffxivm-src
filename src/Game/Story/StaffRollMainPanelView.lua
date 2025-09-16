---
--- Author: ashyuan
--- DateTime: 2024-03-20 15:06
--- Description:
---

local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")
local LuaClass = require("Core/LuaClass")
local SequencePlayerVM = require("Game/Story/SequencePlayerVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

--local FMath = _G.UE.UKismetMathLibrary

---@class StaffRollMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Img01 UFImage
---@field Img02 UFImage
---@field Img03 UFImage
---@field Img04 UFImage
---@field Img05 UFImage
---@field Img06 UFImage
---@field Img07 UFImage
---@field Img08 UFImage
---@field Img09 UFImage
---@field Img10 UFImage
---@field Img11 UFImage
---@field Img12 UFImage
---@field Img13 UFImage
---@field Img14 UFImage
---@field Img15 UFImage
---@field Img16 UFImage
---@field Img17 UFImage
---@field Img18 UFImage
---@field Img19 UFImage
---@field Img20 UFImage
---@field ImgBG01 UFImage
---@field ImgBG02 UFImage
---@field ImgDeco01 UFImage
---@field ImgDeco02 UFImage
---@field ImgDeco03 UFImage
---@field ImgDeco04 UFImage
---@field ImgDeco05 UFImage
---@field ImgDeco06 UFImage
---@field ImgDeco07 UFImage
---@field ImgDeco08 UFImage
---@field ImgDeco09 UFImage
---@field ImgDeco10 UFImage
---@field ImgDeco11 UFImage
---@field ImgDeco12 UFImage
---@field ImgDeco13 UFImage
---@field ImgDeco14 UFImage
---@field ImgDeco15 UFImage
---@field ImgDeco16 UFImage
---@field ImgDeco17 UFImage
---@field ImgDeco18 UFImage
---@field ImgDeco19 UFImage
---@field ImgDeco20 UFImage
---@field ImgDeco21 UFImage
---@field ImgDeco22 UFImage
---@field ImgDeco23 UFImage
---@field ImgDeco24 UFImage
---@field ImgDeco25 UFImage
---@field ImgDeco26 UFImage
---@field ImgDeco27 UFImage
---@field ImgDeco28 UFImage
---@field ImgDeco29 UFImage
---@field ImgDeco30 UFImage
---@field ImgDeco31 UFImage
---@field ImgDeco32 UFImage
---@field ImgDeco33 UFImage
---@field ImgDeco34 UFImage
---@field ImgDeco35 UFImage
---@field ImgDeco36 UFImage
---@field ImgDeco37 UFImage
---@field ImgDeco38 UFImage
---@field ImgDeco39 UFImage
---@field ImgDeco40 UFImage
---@field ImgDeco41 UFImage
---@field ImgDeco42 UFImage
---@field ImgDeco43 UFImage
---@field ImgDeco44 UFImage
---@field ImgDeco45 UFImage
---@field ImgDeco46 UFImage
---@field ImgDeco47 UFImage
---@field ImgDeco48 UFImage
---@field PanelMask UFCanvasPanel
---@field PanelText01 UOverlay
---@field PanelText02 UOverlay
---@field PanelText03 UOverlay
---@field PanelText04 UOverlay
---@field PanelText05 UOverlay
---@field PanelText06 UOverlay
---@field PanelText07 UOverlay
---@field PanelText08 UOverlay
---@field PanelText09 UOverlay
---@field PanelText10 UOverlay
---@field PanelText11 UOverlay
---@field PanelText12 UOverlay
---@field PanelText13 UOverlay
---@field PanelText14 UOverlay
---@field PanelText15 UOverlay
---@field PanelText16 UOverlay
---@field PanelText17 UOverlay
---@field PanelText18 UOverlay
---@field PanelText19 UOverlay
---@field PanelText20 UOverlay
---@field PanelText21 UOverlay
---@field PanelText22 UOverlay
---@field PanelText23 UOverlay
---@field PanelText24 UOverlay
---@field PanelText25 UOverlay
---@field PanelText26 UOverlay
---@field PanelText27 UOverlay
---@field PanelText28 UOverlay
---@field PanelText29 UOverlay
---@field PanelText30 UOverlay
---@field PanelText31 UOverlay
---@field PanelText32 UOverlay
---@field PanelText33 UOverlay
---@field PanelText34 UOverlay
---@field PanelText35 UOverlay
---@field PanelText36 UOverlay
---@field PanelText37 UOverlay
---@field PanelText38 UOverlay
---@field PanelText39 UOverlay
---@field PanelText40 UOverlay
---@field PanelText41 UOverlay
---@field PanelText42 UOverlay
---@field PanelText43 UOverlay
---@field PanelText44 UOverlay
---@field PanelText45 UOverlay
---@field PanelText46 UOverlay
---@field PanelText47 UOverlay
---@field PanelText48 UOverlay
---@field ScaleBox_0 UScaleBox
---@field ScaleBox_1 UScaleBox
---@field Text01 UFTextBlock
---@field Text02 UFTextBlock
---@field Text03 UFTextBlock
---@field Text04 UFTextBlock
---@field Text05 UFTextBlock
---@field Text06 UFTextBlock
---@field Text07 UFTextBlock
---@field Text08 UFTextBlock
---@field Text09 UFTextBlock
---@field Text10 UFTextBlock
---@field Text11 UFTextBlock
---@field Text12 UFTextBlock
---@field Text13 UFTextBlock
---@field Text14 UFTextBlock
---@field Text15 UFTextBlock
---@field Text16 UFTextBlock
---@field Text17 UFTextBlock
---@field Text18 UFTextBlock
---@field Text19 UFTextBlock
---@field Text20 UFTextBlock
---@field Text21 UFTextBlock
---@field Text22 UFTextBlock
---@field Text23 UFTextBlock
---@field Text24 UFTextBlock
---@field Text25 UFTextBlock
---@field Text26 UFTextBlock
---@field Text27 UFTextBlock
---@field Text28 UFTextBlock
---@field Text29 UFTextBlock
---@field Text30 UFTextBlock
---@field Text31 UFTextBlock
---@field Text32 UFTextBlock
---@field Text33 UFTextBlock
---@field Text34 UFTextBlock
---@field Text35 UFTextBlock
---@field Text36 UFTextBlock
---@field Text37 UFTextBlock
---@field Text38 UFTextBlock
---@field Text39 UFTextBlock
---@field Text40 UFTextBlock
---@field Text41 UFTextBlock
---@field Text42 UFTextBlock
---@field Text43 UFTextBlock
---@field Text44 UFTextBlock
---@field Text45 UFTextBlock
---@field Text46 UFTextBlock
---@field Text47 UFTextBlock
---@field Text48 UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StaffRollMainPanelView = LuaClass(UIView, true)

-- 端游默认移到屏幕外60像素
local OUTDISP_OFFSET = 60

local function SetPosIntY(Widget, NewY)
	if Widget == nil then
		return
	end
	local Position = UIUtil.CanvasSlotGetPosition(Widget)
	Position.Y = NewY
	UIUtil.CanvasSlotSetPosition(Widget, Position)
end

local function SetPosIntXY(Widget, NewX, NewY)
	if Widget == nil then
		return
	end
	local Position = UIUtil.CanvasSlotGetPosition(Widget)
	Position.X = NewX
	Position.Y = NewY
	UIUtil.CanvasSlotSetPosition(Widget, Position)
end

local function MovePosIntY(Widget, OffsetY)
	local Position = UIUtil.CanvasSlotGetPosition(Widget)
	Position.Y = Position.Y + OffsetY
	UIUtil.CanvasSlotSetPosition(Widget, Position)
	return Position.Y
end

local function MovePosIntXY(Widget, OffsetX, OffsetY)
	local Position = UIUtil.CanvasSlotGetPosition(Widget)
	Position.X = Position.X + OffsetX
	Position.Y = Position.Y + OffsetY
	UIUtil.CanvasSlotSetPosition(Widget, Position)
	return Position
end

function StaffRollMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Img01 = nil
	--self.Img02 = nil
	--self.Img03 = nil
	--self.Img04 = nil
	--self.Img05 = nil
	--self.Img06 = nil
	--self.Img07 = nil
	--self.Img08 = nil
	--self.Img09 = nil
	--self.Img10 = nil
	--self.Img11 = nil
	--self.Img12 = nil
	--self.Img13 = nil
	--self.Img14 = nil
	--self.Img15 = nil
	--self.Img16 = nil
	--self.Img17 = nil
	--self.Img18 = nil
	--self.Img19 = nil
	--self.Img20 = nil
	--self.ImgBG01 = nil
	--self.ImgBG02 = nil
	--self.ImgDeco01 = nil
	--self.ImgDeco02 = nil
	--self.ImgDeco03 = nil
	--self.ImgDeco04 = nil
	--self.ImgDeco05 = nil
	--self.ImgDeco06 = nil
	--self.ImgDeco07 = nil
	--self.ImgDeco08 = nil
	--self.ImgDeco09 = nil
	--self.ImgDeco10 = nil
	--self.ImgDeco11 = nil
	--self.ImgDeco12 = nil
	--self.ImgDeco13 = nil
	--self.ImgDeco14 = nil
	--self.ImgDeco15 = nil
	--self.ImgDeco16 = nil
	--self.ImgDeco17 = nil
	--self.ImgDeco18 = nil
	--self.ImgDeco19 = nil
	--self.ImgDeco20 = nil
	--self.ImgDeco21 = nil
	--self.ImgDeco22 = nil
	--self.ImgDeco23 = nil
	--self.ImgDeco24 = nil
	--self.ImgDeco25 = nil
	--self.ImgDeco26 = nil
	--self.ImgDeco27 = nil
	--self.ImgDeco28 = nil
	--self.ImgDeco29 = nil
	--self.ImgDeco30 = nil
	--self.ImgDeco31 = nil
	--self.ImgDeco32 = nil
	--self.ImgDeco33 = nil
	--self.ImgDeco34 = nil
	--self.ImgDeco35 = nil
	--self.ImgDeco36 = nil
	--self.ImgDeco37 = nil
	--self.ImgDeco38 = nil
	--self.ImgDeco39 = nil
	--self.ImgDeco40 = nil
	--self.ImgDeco41 = nil
	--self.ImgDeco42 = nil
	--self.ImgDeco43 = nil
	--self.ImgDeco44 = nil
	--self.ImgDeco45 = nil
	--self.ImgDeco46 = nil
	--self.ImgDeco47 = nil
	--self.ImgDeco48 = nil
	--self.PanelMask = nil
	--self.PanelText01 = nil
	--self.PanelText02 = nil
	--self.PanelText03 = nil
	--self.PanelText04 = nil
	--self.PanelText05 = nil
	--self.PanelText06 = nil
	--self.PanelText07 = nil
	--self.PanelText08 = nil
	--self.PanelText09 = nil
	--self.PanelText10 = nil
	--self.PanelText11 = nil
	--self.PanelText12 = nil
	--self.PanelText13 = nil
	--self.PanelText14 = nil
	--self.PanelText15 = nil
	--self.PanelText16 = nil
	--self.PanelText17 = nil
	--self.PanelText18 = nil
	--self.PanelText19 = nil
	--self.PanelText20 = nil
	--self.PanelText21 = nil
	--self.PanelText22 = nil
	--self.PanelText23 = nil
	--self.PanelText24 = nil
	--self.PanelText25 = nil
	--self.PanelText26 = nil
	--self.PanelText27 = nil
	--self.PanelText28 = nil
	--self.PanelText29 = nil
	--self.PanelText30 = nil
	--self.PanelText31 = nil
	--self.PanelText32 = nil
	--self.PanelText33 = nil
	--self.PanelText34 = nil
	--self.PanelText35 = nil
	--self.PanelText36 = nil
	--self.PanelText37 = nil
	--self.PanelText38 = nil
	--self.PanelText39 = nil
	--self.PanelText40 = nil
	--self.PanelText41 = nil
	--self.PanelText42 = nil
	--self.PanelText43 = nil
	--self.PanelText44 = nil
	--self.PanelText45 = nil
	--self.PanelText46 = nil
	--self.PanelText47 = nil
	--self.PanelText48 = nil
	--self.ScaleBox_0 = nil
	--self.ScaleBox_1 = nil
	--self.Text01 = nil
	--self.Text02 = nil
	--self.Text03 = nil
	--self.Text04 = nil
	--self.Text05 = nil
	--self.Text06 = nil
	--self.Text07 = nil
	--self.Text08 = nil
	--self.Text09 = nil
	--self.Text10 = nil
	--self.Text11 = nil
	--self.Text12 = nil
	--self.Text13 = nil
	--self.Text14 = nil
	--self.Text15 = nil
	--self.Text16 = nil
	--self.Text17 = nil
	--self.Text18 = nil
	--self.Text19 = nil
	--self.Text20 = nil
	--self.Text21 = nil
	--self.Text22 = nil
	--self.Text23 = nil
	--self.Text24 = nil
	--self.Text25 = nil
	--self.Text26 = nil
	--self.Text27 = nil
	--self.Text28 = nil
	--self.Text29 = nil
	--self.Text30 = nil
	--self.Text31 = nil
	--self.Text32 = nil
	--self.Text33 = nil
	--self.Text34 = nil
	--self.Text35 = nil
	--self.Text36 = nil
	--self.Text37 = nil
	--self.Text38 = nil
	--self.Text39 = nil
	--self.Text40 = nil
	--self.Text41 = nil
	--self.Text42 = nil
	--self.Text43 = nil
	--self.Text44 = nil
	--self.Text45 = nil
	--self.Text46 = nil
	--self.Text47 = nil
	--self.Text48 = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StaffRollMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StaffRollMainPanelView:OnInit()
	-- company Icon
	self.IconList = {
		self.Img01,
		self.Img02,
		self.Img03,
		self.Img04,
		self.Img05,
		self.Img06,
		self.Img07,
		self.Img08,
		self.Img09,
		self.Img10,
		self.Img11,
		self.Img12,
		self.Img13,
		self.Img14,
		self.Img15,
		self.Img16,
		self.Img17,
		self.Img18,
		self.Img19,
		self.Img20
	}
	-- staff second
	-- self.TextSecList = {
	-- 	self.CenterText_0, self.CenterText_1, self.CenterText_2, self.CenterText_3, self.CenterText_4, self.CenterText_5, 
	-- 	self.CenterText_6, self.CenterText_7, self.CenterText_8, self.CenterText_9, self.CenterText_10, self.CenterText_11, 
	-- 	self.CenterText_12, self.CenterText_13, self.CenterText_14, self.CenterText_15, self.CenterText_16, self.CenterText_17, 
	-- 	self.CenterText_18, self.CenterText_19, self.CenterText_20, self.CenterText_21, self.CenterText_22, self.CenterText_23 
	-- }
	-- staff part
	-- self.TextPartList = {
	-- 	self.LeftText_0, self.LeftText_1, self.LeftText_2, self.LeftText_3, self.LeftText_4, self.LeftText_5,
	-- 	self.LeftText_6, self.LeftText_7, self.LeftText_8, self.LeftText_9, self.LeftText_10, self.LeftText_11,
	-- 	self.LeftText_12, self.LeftText_13, self.LeftText_14, self.LeftText_15, self.LeftText_16, self.LeftText_17,
	-- 	self.LeftText_18, self.LeftText_19, self.LeftText_20, self.LeftText_21, self.LeftText_22, self.LeftText_23
	-- }
	-- staff name
	-- self.TextNameList = {
	-- 	self.RightText_0, self.RightText_1, self.RightText_2, self.RightText_3, self.RightText_4, self.RightText_5, 
	-- 	self.RightText_6, self.RightText_7, self.RightText_8, self.RightText_9, self.RightText_10, self.RightText_11,  
	-- 	self.RightText_12, self.RightText_13, self.RightText_14, self.RightText_15, self.RightText_16, self.RightText_17, 
	-- 	self.RightText_18, self.RightText_19, self.RightText_20, self.RightText_21, self.RightText_22, self.RightText_23, 
	-- 	self.RightText_24, self.RightText_25, self.RightText_26, self.RightText_27, self.RightText_28, self.RightText_29, 
	-- 	self.RightText_30, self.RightText_31, self.RightText_32, self.RightText_33, self.RightText_34, self.RightText_35, 
	-- 	self.RightText_36, self.RightText_37, self.RightText_38, self.RightText_39, self.RightText_40, self.RightText_41, 
	-- 	self.RightText_42,self.RightText_43, self.RightText_44, self.RightText_45, self.RightText_46, self.RightText_47 
	-- }
	self.StaffUIList = {
		{Panel = self.PanelText01, Text = self.Text01, Img = self.ImgDeco01},
		{Panel = self.PanelText02, Text = self.Text02, Img = self.ImgDeco02},
		{Panel = self.PanelText03, Text = self.Text03, Img = self.ImgDeco03},
		{Panel = self.PanelText04, Text = self.Text04, Img = self.ImgDeco04},
		{Panel = self.PanelText05, Text = self.Text05, Img = self.ImgDeco05},
		{Panel = self.PanelText06, Text = self.Text06, Img = self.ImgDeco06},
		{Panel = self.PanelText07, Text = self.Text07, Img = self.ImgDeco07},
		{Panel = self.PanelText08, Text = self.Text08, Img = self.ImgDeco08},
		{Panel = self.PanelText09, Text = self.Text09, Img = self.ImgDeco09},
		{Panel = self.PanelText10, Text = self.Text10, Img = self.ImgDeco10},
		{Panel = self.PanelText11, Text = self.Text11, Img = self.ImgDeco11},
		{Panel = self.PanelText12, Text = self.Text12, Img = self.ImgDeco12},
		{Panel = self.PanelText13, Text = self.Text13, Img = self.ImgDeco13},
		{Panel = self.PanelText14, Text = self.Text14, Img = self.ImgDeco14},
		{Panel = self.PanelText15, Text = self.Text15, Img = self.ImgDeco15},
		{Panel = self.PanelText16, Text = self.Text16, Img = self.ImgDeco16},
		{Panel = self.PanelText17, Text = self.Text17, Img = self.ImgDeco17},
		{Panel = self.PanelText18, Text = self.Text18, Img = self.ImgDeco18},
		{Panel = self.PanelText19, Text = self.Text19, Img = self.ImgDeco19},
		{Panel = self.PanelText20, Text = self.Text20, Img = self.ImgDeco20},
		{Panel = self.PanelText21, Text = self.Text21, Img = self.ImgDeco21},
		{Panel = self.PanelText22, Text = self.Text22, Img = self.ImgDeco22},
		{Panel = self.PanelText23, Text = self.Text23, Img = self.ImgDeco23},
		{Panel = self.PanelText24, Text = self.Text24, Img = self.ImgDeco24},
		{Panel = self.PanelText25, Text = self.Text25, Img = self.ImgDeco25},
		{Panel = self.PanelText26, Text = self.Text26, Img = self.ImgDeco26},
		{Panel = self.PanelText27, Text = self.Text27, Img = self.ImgDeco27},
		{Panel = self.PanelText28, Text = self.Text28, Img = self.ImgDeco28},
		{Panel = self.PanelText29, Text = self.Text29, Img = self.ImgDeco29},
		{Panel = self.PanelText30, Text = self.Text30, Img = self.ImgDeco30},
		{Panel = self.PanelText31, Text = self.Text31, Img = self.ImgDeco31},
		{Panel = self.PanelText32, Text = self.Text32, Img = self.ImgDeco32},
		{Panel = self.PanelText33, Text = self.Text33, Img = self.ImgDeco33},
		{Panel = self.PanelText34, Text = self.Text34, Img = self.ImgDeco34},
		{Panel = self.PanelText35, Text = self.Text35, Img = self.ImgDeco35},
		{Panel = self.PanelText36, Text = self.Text36, Img = self.ImgDeco36},
		{Panel = self.PanelText37, Text = self.Text37, Img = self.ImgDeco37},
		{Panel = self.PanelText38, Text = self.Text38, Img = self.ImgDeco38},
		{Panel = self.PanelText39, Text = self.Text39, Img = self.ImgDeco39},
		{Panel = self.PanelText40, Text = self.Text40, Img = self.ImgDeco40},
		{Panel = self.PanelText41, Text = self.Text41, Img = self.ImgDeco41},
		{Panel = self.PanelText42, Text = self.Text42, Img = self.ImgDeco42},
		{Panel = self.PanelText43, Text = self.Text43, Img = self.ImgDeco43},
		{Panel = self.PanelText44, Text = self.Text44, Img = self.ImgDeco44},
		{Panel = self.PanelText45, Text = self.Text45, Img = self.ImgDeco45},
		{Panel = self.PanelText46, Text = self.Text46, Img = self.ImgDeco46},
		{Panel = self.PanelText47, Text = self.Text47, Img = self.ImgDeco47},
		{Panel = self.PanelText48, Text = self.Text48, Img = self.ImgDeco48}
	}
end

function StaffRollMainPanelView:Tick(_, InDeltaTime)
	if self.PlayerTime == 0 then
		self.PlayerTime = InDeltaTime
		return
	end

	local DeltaTime = InDeltaTime - self.PlayerTime
	if not self.bIsPlaying then
		-- 这里的InDeltaTime是总的时间，所以即使暂停了也需要继续更新
		self.PlayerTime = InDeltaTime
		return
	end

	self:UpdateImageShow(DeltaTime)
	self:UpdateImageHide(DeltaTime)

	-- 更新字幕滚动
	self:UpdateStaffRoll(DeltaTime)

	self.PlayerTime = InDeltaTime
end

function StaffRollMainPanelView:UpdateImageShow(DeltaTime)
	-- 处理图像显示
	if self.ShowImage and self.ShowInfo then
		-- 淡入处理
		if self.FadeInTime < self.ShowInfo.FadeTime then
			self.FadeInTime = self.FadeInTime + DeltaTime
			local Alpha = self.FadeInTime / self.ShowInfo.FadeTime
			local NewColor = self.ShowImage.ColorAndOpacity
			NewColor.A = Alpha
			if NewColor.A > 1.0 then
				NewColor.A = 1.0
			end
			--print("ShowImage Fade", NewColor.A, "FadeInTime", self.FadeInTime, "DeltaTime", DeltaTime)
			self.ShowImage:SetColorAndOpacity(NewColor)
		end

		-- 图像拉伸
		local Scaleofs = DeltaTime / self.ShowTime * (self.ShowInfo.TargetScale - 1.0)
		self.CurrentScale = self.CurrentScale + Scaleofs

		if Scaleofs > 0 and self.CurrentScale > self.ShowInfo.TargetScale then
			self.CurrentScale = self.ShowInfo.TargetScale
		end

		if Scaleofs < 0 and self.CurrentScale < self.ShowInfo.TargetScale then
			self.CurrentScale = self.ShowInfo.TargetScale
		end

		--print("ShowImage CurrentScale", self.CurrentScale, "Scaleofs", Scaleofs, "DeltaTime", DeltaTime)
		self.ShowImage:SetRenderScale(_G.UE.FVector2D(self.CurrentScale, self.CurrentScale))

		-- 图像平移
		local offsetX = (self.ImageSpeedX * DeltaTime)
		local offsetY = (self.ImageSpeedY * DeltaTime)
		MovePosIntXY(self.ImageSlot, offsetX, offsetY)

		-- self.MoveAlpha = self.MoveAlpha + DeltaTime / self.ShowTime
        -- local NewPosition = FMath.Vector2DInterpTo(self.ShowInfo.StartPosOffset, self.ShowInfo.EndPosOffset, self.MoveAlpha, 1.0)
		-- SetPosIntXY(self.ShowImage, NewPosition.X, NewPosition.Y)
	end
end

function StaffRollMainPanelView:UpdateImageHide(DeltaTime)
	-- 处理图像隐藏
	if self.HideImage and self.HideInfo then
		-- 淡出处理
		if self.FadeOutTime < self.HideInfo.FadeTime then
			self.FadeOutTime = self.FadeOutTime + DeltaTime
			local Alpha = self.FadeOutTime / self.HideInfo.FadeTime
			local NewColor = self.HideImage.ColorAndOpacity
			NewColor.A = 1.0 - Alpha
			if NewColor.A < 0.0 then
				-- 隐藏背景
				UIUtil.SetIsVisible(self.HideImage, false)
				self.HideImage = nil
				self.HideInfo = nil
				return
			end
			--print("HideImage Fade", NewColor.A, "FadeOutTime", self.FadeOutTime, "DeltaTime", DeltaTime)
			self.HideImage:SetColorAndOpacity(NewColor)
		end
		-- 理论上HideImage不用处理缩放
	end
end

function StaffRollMainPanelView:OnShowBackImage(Image)
	if self.CurrentImage then
		self.ShowImage = self.CurrentImage
		self.ImageSlot = self.CurrentSlot
		self.ShowInfo = Image

		-- 显示背景
		UIUtil.SetIsVisible(self.ShowImage, true)
		self.CurrentImage:SetBrushFromTexture(self.ShowInfo.BackImage)

		-- 开始淡入处理
		local NewColor = self.ShowImage.ColorAndOpacity
		NewColor.A = 0.0
		self.ShowImage:SetColorAndOpacity(NewColor)
		self.FadeInTime = 0.0

		-- 开始缩放处理
		self.ShowImage:SetRenderScale(_G.UE.FVector2D(1.0, 1.0))
		self.ShowTime = self.ShowInfo.EndTime - self.ShowInfo.StartTime
		self.CurrentScale = 1.0

		-- 开始平移处理
		SetPosIntXY(self.ImageSlot, self.ShowInfo.StartPosOffset.X, self.ShowInfo.StartPosOffset.Y)
		self.ImageSpeedX = (self.ShowInfo.EndPosOffset.X - self.ShowInfo.StartPosOffset.X) / self.ShowTime
		self.ImageSpeedY = (self.ShowInfo.EndPosOffset.Y - self.ShowInfo.StartPosOffset.Y) / self.ShowTime
		--self.MoveAlpha = 0.0
	end
end

function StaffRollMainPanelView:OnHideBackImage(Image)
	if self.CurrentImage then
		self.HideImage = self.CurrentImage
		self.HideInfo = Image

		-- 开始淡出处理
		self.FadeOutTime = 0.0

		-- 理论上HideImage不用处理缩放
		-- self.HideImage:SetRenderScale(_G.UE.FVector2D(1.0, 1.0))

		-- 每次背景切换后，CurrentImage会换成另一张
		self:SwithBackImage()
	end
end

function StaffRollMainPanelView:UpdateStaffRoll(DeltaTime)
	if self.StaffTable == nil then
		return
	end

	while self.CreditIndex <= #self.StaffTable do
		local Data = self.StaffTable[self.CreditIndex]
		local Space = self.Height * Data.Space
		if self.ExecCount + Space <= self.SecCount then
			local isLast = self.CreditIndex == #self.StaffTable
			self:StartCredit(Data, isLast, self.SecCount - (self.ExecCount + Space))
		else
			break
		end
	end

	local fps = self.Height / self.ScrollTime
	local dt = DeltaTime + self.DeltaTimeRest
	local offset = math.floor(fps * dt)
	self.DeltaTimeRest = dt - (offset / fps)
	
	for i = 1, #self.ExecuteNodes do
		local pNode = self.ExecuteNodes[i].pNode
		if pNode then
			-- 手游的锚点在正中间，所以要加上半个屏幕高度，才是屏幕坐标
			local PosY = MovePosIntY(pNode, -offset) + self.Height / 2
			local Size = UIUtil.GetWidgetSize(pNode)
			if PosY < -Size.Y then
				self:ReleaseNode(pNode)
				self.ExecuteNodes[i].pNode = nil
			end
		end
	end

	self.SecCount = self.SecCount + offset
end

function StaffRollMainPanelView:StartCredit(Data, isLast, ofs)

	local pNode
	local isStr = Data.Icon == nil

	if isStr then
		-- if Data.Layout == 0 then		--Left
		-- 	pNode = self:GetEmptyPartNode()
		-- elseif Data.Layout == 1 then	--Right
		-- 	pNode = self:GetEmptyNameNode()
		-- elseif Data.Layout == 2 then	--Center
		-- 	pNode = self:GetEmptySecNode()
		-- end
		pNode = self:GetEmptyStaffNode()

		local IsTitle = Data.Layout == 2 and true or false

		if pNode then
			-- 设置Panel
			SetPosIntY(pNode.Panel, self.Height + OUTDISP_OFFSET - ofs )
			UIUtil.SetIsVisible(pNode.Panel, true)

			-- 设置Text
			pNode.Text:SetText(Data.Text)
			UIUtil.SetIsVisible(pNode.Text, true)

			local Font = pNode.Text.Font
			Font.Size = Data.FontSize
			pNode.Text:SetFont(Font)

			local HexColor = Data.FontColor:ToHex()
	        local LinearColor = _G.UE.FLinearColor.FromHex(HexColor)
			pNode.Text:SetColorAndOpacity(LinearColor)

			-- 设置边框
			UIUtil.SetIsVisible(pNode.Img, IsTitle)

			for i = 1, #self.ExecuteNodes do
				if self.ExecuteNodes[i].pNode == nil then
					self.ExecuteNodes[i].pNode = pNode.Panel
					self.ExecuteNodes[i].isImage = false
					self.ExecuteNodes[i].isLast = isLast
					self.ExecCount = self.ExecCount + self.Height * Data.Space
					break
				end
			end
		end
	else
		pNode = self:GetEmptyImageNode()
		if pNode then
			SetPosIntY(pNode, self.Height + OUTDISP_OFFSET - ofs )
			pNode:SetBrushFromTexture(Data.Icon, true)
			UIUtil.SetIsVisible(pNode, true)

			for i = 1, #self.ExecuteNodes do
				if self.ExecuteNodes[i].pNode == nil then
					self.ExecuteNodes[i].pNode = pNode
					self.ExecuteNodes[i].isImage = true
					self.ExecuteNodes[i].isLast = isLast
					self.ExecCount = self.ExecCount + self.Height * Data.Space
					break
				end
			end
		end
	end

	self.CreditIndex = self.CreditIndex + 1
end

-- function StaffRollMainPanelView:GetEmptySecNode()
-- 	for i = 1, #self.TextSecList do
-- 		if self.UseSection[i] == false then
-- 			self.UseSection[i] = true
-- 			UIUtil.SetIsVisible(self.TextSecList[i], true)
-- 			return self.TextSecList[i]
-- 		end
-- 	end
-- 	return nil
-- end

-- function StaffRollMainPanelView:GetEmptyNameNode()
-- 	for i = 1, #self.TextNameList do
-- 		if self.UseName[i] == false then
-- 			self.UseName[i] = true
-- 			UIUtil.SetIsVisible(self.TextNameList[i], true)
-- 			return self.TextNameList[i]
-- 		end
-- 	end
-- 	return nil
-- end

-- function StaffRollMainPanelView:GetEmptyPartNode()
-- 	for i = 1, #self.TextPartList do
-- 		if self.UsePart[i] == false then
-- 			self.UsePart[i] = true
-- 			UIUtil.SetIsVisible(self.TextPartList[i], true)
-- 			return self.TextPartList[i]
-- 		end
-- 	end
-- 	return nil
-- end

function StaffRollMainPanelView:GetEmptyStaffNode()
	for i = 1, #self.StaffUIList do
		if self.UseStaff[i] == false then
			self.UseStaff[i] = true
			UIUtil.SetIsVisible(self.StaffUIList[i].Panel, true)
			return self.StaffUIList[i]
		end
	end
	return nil
end

function StaffRollMainPanelView:GetEmptyImageNode()
	for i = 1, #self.IconList do
		if self.UseIcon[i] == false then
			self.UseIcon[i] = true
			UIUtil.SetIsVisible(self.IconList[i], true)
			return self.IconList[i]
		end
	end
	return nil
end

function StaffRollMainPanelView:ReleaseNode(pNode)
	-- for i = 1, #self.TextSecList do
	-- 	if self.TextSecList[i] == pNode then
	-- 		self.UseSection[i] = false
	-- 		UIUtil.SetIsVisible(self.TextSecList[i], false)
	-- 		return
	-- 	end
	-- end

	-- for i = 1, #self.TextPartList do
	-- 	if self.TextPartList[i] == pNode then
	-- 		self.UsePart[i] = false
	-- 		UIUtil.SetIsVisible(self.TextPartList[i], false)
	-- 		return
	-- 	end
	-- end

	-- for i = 1, #self.TextNameList do
	-- 	if self.TextNameList[i] == pNode then
	-- 		self.UseName[i] = false
	-- 		UIUtil.SetIsVisible(self.TextNameList[i], false)
	-- 		return
	-- 	end
	-- end

	for i = 1, #self.StaffUIList do
		if self.StaffUIList[i].Panel == pNode then
			self.UseStaff[i] = false
			UIUtil.SetIsVisible(self.StaffUIList[i].Panel, false)
			return
		end
	end

	for i = 1, #self.IconList do
		if self.IconList[i] == pNode then
			self.UseIcon[i] = false
			UIUtil.SetIsVisible(self.IconList[i], false)
			return
		end
	end
end

function StaffRollMainPanelView:OnShowStaffList(StaffTable, ScrollTime)
	self.StaffTable = StaffTable
	self.ScrollTime = ScrollTime
end

function StaffRollMainPanelView:SwithBackImage()
	if self.CurrentImage ~= self.ImgBG01 then
		self.CurrentImage = self.ImgBG01
		self.CurrentSlot = self.ScaleBox_0
	else
		self.CurrentImage = self.ImgBG02
		self.CurrentSlot = self.ScaleBox_1
	end
end

-- 逻辑的初始化,在开始播放的时候再处理
function StaffRollMainPanelView:OnBeginPlay()
	-- image info
	self.CurrentImage = self.ImgBG01
	self.ShowImage = nil
	self.ShowInfo = nil
	self.HideImage = nil
	self.HideInfo = nil
	self.CurrentSlot = self.ScaleBox_0
	self.ImageSlot = nil

	-- staff info
	self.Height = 0
	self.SecCount = 0
	self.ExecCount = 0
	self.ScrollTime = 0
	self.CreditIndex = 1
	self.DeltaTimeRest = 0

	self.StaffTable = {}
	self.ExecuteNodes = {}
	-- self.UseSection = {}
	-- self.UsePart = {}
	-- self.UseName = {}
	self.UseStaff = {}
	self.UseIcon = {}

	-- local TextSecCnt = #self.TextSecList
	-- for i = 1, TextSecCnt do
	-- 	self.UseSection[i] = false
	-- end

	-- local TextPartCnt = #self.TextPartList
	-- for i = 1, TextPartCnt do
	-- 	self.UsePart[i] = false
	-- end

	-- local TextNameCnt = #self.TextNameList
	-- for i = 1, TextNameCnt do
	-- 	self.UseName[i] = false
	-- end

	local StaffUICnt = #self.StaffUIList
	for i = 1, StaffUICnt do
		self.UseStaff[i] = false
	end

	local IconCnt = #self.IconList
	for i = 1, IconCnt do
		self.UseIcon[i] = false
	end

	-- local ExecuteCnt = TextSecCnt + TextPartCnt + TextNameCnt + IconCnt
	local ExecuteCnt = StaffUICnt + IconCnt
	for i = 1, ExecuteCnt do
		self.ExecuteNodes[i] = {pNode = nil, isImage = false, isLast = false}
	end

	local ScreenSize = UIUtil.GetScreenSize()
	self.Height = ScreenSize.Y

	-- timer
	self.PlayerTime = 0.0
	if self.Timer ~= nil then
		self:UnRegisterTimer(self.Tick)
		self.Timer = nil
	end
	self.Timer = self:RegisterTimer(self.Tick, 0, 0.03, 0)
	self.bIsPlaying = true
end

function StaffRollMainPanelView:OnEndPlay()
	-- image info
	self.CurrentImage = nil
	self.ShowImage = nil
	self.ShowInfo = nil
	self.HideImage = nil
	self.HideInfo = nil
	self.CurrentSlot = nil
	self.ImageSlot = nil

	-- staff info
	self.Height = 0
	self.SecCount = 0
	self.ExecCount = 0
	self.CreditIndex = 0
	self.DeltaTimeRest = 0

	self.StaffTable = {}
	self.ExecuteNodes = {}
	-- self.UseSection = {}
	-- self.UsePart = {}
	-- self.UseName = {}
	self.UseStaff = {}
	self.UseIcon = {}

	if self.Timer ~= nil then
		self:UnRegisterTimer(self.Tick)
		self.Timer = nil
	end
	self.bIsPlaying = false
end

function StaffRollMainPanelView:OnDestroy()

end

-- UI的初始化,在UI创建出来的时候就处理
function StaffRollMainPanelView:OnShow()
	for i=1, #self.IconList do
		UIUtil.SetIsVisible(self.IconList[i], false, false)
	end
	
	-- for i=1, #self.TextSecList do
	-- 	UIUtil.SetIsVisible(self.TextSecList[i], false, false)
	-- end

	-- for i=1, #self.TextPartList do
	-- 	UIUtil.SetIsVisible(self.TextPartList[i], false, false)
	-- end

	-- for i=1, #self.TextNameList do
	-- 	UIUtil.SetIsVisible(self.TextNameList[i], false, false)
	-- end

	for i=1, #self.StaffUIList do
		UIUtil.SetIsVisible(self.StaffUIList[i].Panel, false, false)
	end

	UIUtil.SetIsVisible(self.ImgBG01, false)
	UIUtil.SetIsVisible(self.ImgBG02, false)
end

function StaffRollMainPanelView:OnHide()

end

function StaffRollMainPanelView:OnRegisterUIEvent()

end

function StaffRollMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.StaffRollBeginPlay, self.OnBeginPlay)
	self:RegisterGameEvent(_G.EventID.StaffRollEndPlay, self.OnEndPlay)

	self:RegisterGameEvent(_G.EventID.StaffRollBackImageShow, self.OnShowBackImage)
	self:RegisterGameEvent(_G.EventID.StaffRollBackImageHide, self.OnHideBackImage)
	self:RegisterGameEvent(_G.EventID.StaffRollShowStaffList, self.OnShowStaffList)

	self:RegisterGameEvent(_G.EventID.AppEnterBackground, self.OnGameEventAppEnterBackground)
    self:RegisterGameEvent(_G.EventID.AppEnterForeground, self.OnGameEventAppEnterForeground)
end

function StaffRollMainPanelView:OnRegisterBinder()
	local Binders = {
		{ "bStaffRollVisible", UIBinderSetIsVisible.New(self, self.MainPanel, false, true) },
	}

	self:RegisterBinders(SequencePlayerVM, Binders)
end

-- 切后台之后Sequence会被停住，如果字幕还在tick的话就会导致字幕提前走完
function StaffRollMainPanelView:OnGameEventAppEnterBackground()
	self.bIsPlaying = false
end

function StaffRollMainPanelView:OnGameEventAppEnterForeground()
	self.bIsPlaying = true
	-- 这里需要刷新一下Timer, 如果TimerMgr的Tick也被停掉了可能重新Tick的DeltaTime太大
	self.PlayerTime = 0
end

return StaffRollMainPanelView