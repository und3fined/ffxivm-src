--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2024-05-09 15:59:47
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2024-05-09 16:20:20
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UE = _G.UE
local FVector2D = UE.FVector2D

local UnLimitedNum = 999 -- 无限滚动
local SlideTypeDefine = {
	PingPong = 0,
	AlwaysRun = 1,
	RigntToLeft = 2
}
---@class CommTextSlideView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FCanvasPanel UFCanvasPanel
---@field ScrollBox UScrollBox
---@field TextTitle URichTextBox
---@field CustomFont SlateFontInfo
---@field TextDes text
---@field CustomTextColor LinearColor
---@field MoveSpeed float
---@field IsTextAlwaysLeft bool
---@field SlideNum int
---@field IntervalTime float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommTextSlideView = LuaClass(UIView, true)

function CommTextSlideView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FCanvasPanel = nil
	--self.ScrollBox = nil
	--self.TextTitle = nil
	--self.CustomFont = nil
	--self.TextDes = nil
	--self.CustomTextColor = nil
	--self.MoveSpeed = nil
	--self.IsTextAlwaysLeft = nil
	--self.SlideNum = nil
	--self.IntervalTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.IsForArtPreview = false
	self.EndCallBack = nil
	self.Vector2D = FVector2D()
	self.OriginTextStr = nil
end

function CommTextSlideView:OnShow()
	self:ResetTextScrollSlide()
end

function CommTextSlideView:OnActive()
	self:ResetTextScrollSlide()
end

function CommTextSlideView:CheckIsNeedUpdate(Text)
	-- loiafeng: 走马灯（RigntToLeft类型）即使文本一样也要刷新一遍
	if self.SlideType == SlideTypeDefine.RigntToLeft then
		self.OriginTextStr = Text
		return true
	end

	local NeedUpdate = true
	if not self.OriginTextStr or self.OriginTextStr ~= Text then
		self.OriginTextStr = Text
	else
		NeedUpdate = false
	end

	return NeedUpdate
end

function CommTextSlideView:ShowSliderText(Text, EndCallBack)
	if not Text then return end

	self.EndCallBack = EndCallBack
	if self:CheckIsNeedUpdate(Text) then
		self:ResetTextScrollSlide(Text)
	end
end

function CommTextSlideView:ResetTextScrollSlide(Text)
	local TextStr = Text or self.OriginTextStr or ""
	self.TextTitle:SetText(TextStr)
	self:UnRegisterAllTimer()
	self.LenghSize = 0
	self.TextLengh = 0
	self.OriginTextLengh = 0
	self:ClearAutoSlideTimer()
	self.ScrollBox:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
	self.TextSizeBox:SetWidthOverride(self.DefaultSize)
	self:RegisterTimer(self.OnResetTextTimer, 0.1, 0.1, -1)
end

function CommTextSlideView:OnResetTextTimer()
	local Vector2D = self.Vector2D
	local TextDesiredSize = UIUtil.GetWidgetSize(self.TextTitle)
	if TextDesiredSize.X == 0 then return end
	self.TextLengh = TextDesiredSize.X	
	self.OriginTextLengh = TextDesiredSize.X
	
	self:UnRegisterAllTimer()
	local ScrollSize = UIUtil.GetWidgetSize(self.ScrollBox)
	self.LenghSize = self.TextLengh - ScrollSize.X
	if self.SlideType == SlideTypeDefine.RigntToLeft then
		Vector2D:Set(ScrollSize.X, 0)
		self.ScrollBox:SetRenderTranslation(Vector2D)
		self:RunTextByType()
	else
		Vector2D:Set(0, 0)
		if self.LenghSize > 0 and self.SlideNum > 0 then
			self.ScrollBox:SetRenderTranslation(Vector2D)
			self:RunTextByType()
		else
			if self.AutoRetract then
				self.ScrollBox:SetRenderTranslation(Vector2D)
				self.TextSizeBox:SetWidthOverride(self.TextLengh)
			else
				if self.IsTextAlwaysLeft then
					self.ScrollBox:SetRenderTranslation(Vector2D)
				else
					Vector2D:Set(-1 * self.LenghSize, 0)
					self.ScrollBox:SetRenderTranslation(Vector2D)
				end
			end
		end
	end
end

function CommTextSlideView:RunTextByType()
	local MoveLengh = 0
	local bMoveToLeft = true
	local MoveNum = 0
	local IntervalTime = self.IntervalTime
	local RecordTag = false
	local OriginText = self.OriginTextStr
	local HasIntervalTime = self.IntervalTime ~= 0
	local Vector2D = self.Vector2D
	if self.SlideType == SlideTypeDefine.PingPong then
		if self.IsTextAlwaysLeft then
			Vector2D:Set(0, 0)
			self.ScrollBox:SetRenderTranslation(Vector2D)
		else
			Vector2D:Set(-1 * self.LenghSize, 0)
			self.ScrollBox:SetRenderTranslation(Vector2D)
			bMoveToLeft = false
			MoveLengh = -1 * self.LenghSize
		end
	elseif self.SlideType == SlideTypeDefine.AlwaysRun then
		local SpaceStr = string.rep(" ", self.SpaceNum)
		local RunText = string.format("%s%s%s", OriginText, SpaceStr, OriginText)
		self.TextTitle:SetText(RunText)
	else 
		local ScrollSize = UIUtil.GetWidgetSize(self.ScrollBox)
		MoveLengh = ScrollSize.X
	end

	self.AutoSlideTimer = self:RegisterTimer(function() 
		if HasIntervalTime and MoveNum ~= 0 and MoveNum % 1 == 0 and not RecordTag then
			RecordTag = true
			self:RegisterTimer(function()
				IntervalTime = IntervalTime + self.IntervalTime
			end, self.IntervalTime, 0, 1)
		end

		if not HasIntervalTime or (HasIntervalTime and IntervalTime > MoveNum * self.IntervalTime) then
			if self.SlideType == SlideTypeDefine.PingPong then
				MoveNum, RecordTag, IntervalTime, MoveLengh, bMoveToLeft = self:OnRunPingPongType(MoveNum, RecordTag, IntervalTime, MoveLengh, bMoveToLeft)
			elseif self.SlideType == SlideTypeDefine.AlwaysRun then
				MoveNum, RecordTag, IntervalTime, MoveLengh = self:OnRunLoopType(MoveNum, RecordTag, IntervalTime, MoveLengh)
			else
				MoveNum, RecordTag, IntervalTime, MoveLengh = self:OnRunRightToLeftType(MoveNum, RecordTag, IntervalTime, MoveLengh)
			end

			Vector2D:Set(MoveLengh, 0)
			self.ScrollBox:SetRenderTranslation(Vector2D)
		end

		if self.SlideNum ~= UnLimitedNum and MoveNum == self.SlideNum then
			self:ClearAutoSlideTimer()
			self.TextTitle:SetText(OriginText)

			self.ScrollBox:SetVisibility(UE.ESlateVisibility.Visible)
			-- loiafeng: 有可能在回调函数中绑定新的回调，故不能在执行回调之后清空回调
			local Callback = self.EndCallBack
			self.EndCallBack = nil
			if Callback then
				Callback()
			end
		end
	end, 0, 0.01, -1)
end

function CommTextSlideView:OnRunPingPongType(MoveNum, RecordTag, IntervalTime, MoveLengh, bMoveToLeft)
	if bMoveToLeft then
		MoveLengh = MoveLengh - self.MoveSpeed
		if MoveLengh < -1 * self.LenghSize  then
			MoveLengh = -1 * self.LenghSize
			bMoveToLeft = false
			MoveNum = MoveNum + 0.5
			RecordTag = false
		end
	else
		MoveLengh = MoveLengh + self.MoveSpeed
		if MoveLengh > 0 then
			MoveLengh = 0
			bMoveToLeft = true
			MoveNum = MoveNum + 0.5
			RecordTag = false
		end
	end

	return MoveNum, RecordTag, IntervalTime, MoveLengh, bMoveToLeft
end

function CommTextSlideView:OnRunLoopType(MoveNum, RecordTag, IntervalTime, MoveLengh)
	if self.TextLengh == self.OriginTextLengh then
		local TextDesiredSize = UIUtil.GetWidgetSize(self.TextTitle)
		self.TextLengh = TextDesiredSize.X
	else
		local SpaceSizeLengh = self.TextLengh - self.OriginTextLengh * 2
		MoveLengh = MoveLengh - self.MoveSpeed
		if -1 * MoveLengh > self.OriginTextLengh  + SpaceSizeLengh then
			MoveNum = MoveNum + 1
			MoveLengh = 0
			RecordTag = false
		end
	end

	return MoveNum, RecordTag, IntervalTime, MoveLengh
end

function CommTextSlideView:OnRunRightToLeftType(MoveNum, RecordTag, IntervalTime, MoveLengh)
	MoveLengh = MoveLengh - self.MoveSpeed
	if -1 * MoveLengh >= self.TextLengh then
		local ScrollSize = UIUtil.GetWidgetSize(self.ScrollBox)
		MoveLengh = ScrollSize.X 
		MoveNum = MoveNum + 1
		RecordTag = false
	end

	return MoveNum, RecordTag, IntervalTime, MoveLengh
end

function CommTextSlideView:ClearAutoSlideTimer()
	if self.AutoSlideTimer then
		self:UnRegisterTimer(self.AutoSlideTimer)
		self.AutoSlideTimer = nil
	end
end

function CommTextSlideView:OnDestroy()
	self:UnRegisterAllTimer()
	self.EndCallBack = nil
	self.OriginTextStr = nil
end

return CommTextSlideView