---
--- Author: Administrator
--- DateTime: 2025-04-07 20:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UUIUtil = _G.UE.UUIUtil
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")

---@class CommonBorderRedDotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgArrowDown UFImage
---@field ImgArrowLeft UFImage
---@field ImgArrowRight UFImage
---@field ImgArrowUp UFImage
---@field PanelBorderRedDot UFCanvasPanel
---@field PanelContent UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommonBorderRedDotView = LuaClass(UIView, true)

function CommonBorderRedDotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgArrowDown = nil
	--self.ImgArrowLeft = nil
	--self.ImgArrowRight = nil
	--self.ImgArrowUp = nil
	--self.PanelBorderRedDot = nil
	--self.PanelContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommonBorderRedDotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommonBorderRedDotView:OnInit()

end

function CommonBorderRedDotView:OnDestroy()

end

function CommonBorderRedDotView:OnShow()
	if self.ListKey then
		_G.RedDotMgr:CollectBorderRedDotViewByShow(self)
		self:UpdataIsShowByListKey(self.ListKey)
	end
end

function CommonBorderRedDotView:OnHide()
	if self.ListKey then
		_G.RedDotMgr:RemoveBorderRedDotViewByHide(self.ListKey)
	end
end

function CommonBorderRedDotView:OnRegisterUIEvent()

end

function CommonBorderRedDotView:OnRegisterGameEvent()

end

function CommonBorderRedDotView:OnRegisterBinder()

end

function CommonBorderRedDotView:SetType(Type)
	self.Type = Type
end

function CommonBorderRedDotView:SetListKeyAndType(ListKey, Type)
	self:SetType(Type)
	self:SetStyle(self.Type)
	self:SetListKey(ListKey)
end

---刚刚创建的时候拿不到正确的屏幕坐标，位置计算位置有问题，先重构摆红点位置
-- function CommonBorderRedDotView:SetPos(TargetWidget, Offset, Type)
-- 	self.Type = Type or self.Type
-- 	--- 位置设置
-- 	local TargetWidgetSize
-- 	if TargetWidget then
-- 		TargetWidgetSize = UUIUtil.GetLocalSize(TargetWidget)
-- 	else
-- 		TargetWidgetSize = {X = 0, Y = 0}
-- 	end
-- 	local ViewTargetWidgetHeight = TargetWidgetSize.Y
-- 	local ViewTargetWidgetWidth = TargetWidgetSize.X
-- 	local PosOffset 
-- 	if Offset then
-- 		PosOffset = {X = Offset.X , Y = Offset.Y}
-- 	else
-- 		PosOffset = {X = 0, Y = 0}
-- 	end
-- 	self:SetStyle(self.Type)
-- 	if self.Type == RedDotDefine.ListRedDotPosType.Top then
-- 		PosOffset.X = PosOffset.X - ViewTargetWidgetWidth/2
-- 	elseif self.Type == RedDotDefine.ListRedDotPosType.Bottom then
-- 		PosOffset.X = PosOffset.X - ViewTargetWidgetWidth/2
-- 		PosOffset.Y = PosOffset.Y + ViewTargetWidgetHeight
-- 	elseif self.Type == RedDotDefine.ListRedDotPosType.Left then
-- 		PosOffset.Y = PosOffset.Y + ViewTargetWidgetHeight/2
-- 	elseif self.Type == RedDotDefine.ListRedDotPosType.Right then
-- 		PosOffset.X = PosOffset.X -  ViewTargetWidgetWidth
-- 		PosOffset.Y = PosOffset.Y + ViewTargetWidgetHeight/2
-- 	end

-- 	UIUtil.AdjustTipsPosition2(self.PanelBorderRedDot, TargetWidget, PosOffset)
-- end

function CommonBorderRedDotView:SetLocalPos(Offset)
	UIUtil.CanvasSlotSetPosition(self, _G.UE.FVector2D(Offset.X, Offset.Y))
end

function CommonBorderRedDotView:SetStyle(Type)
	--todo 后面改成旋转，减少图片控件，节省内存
	UIUtil.SetIsVisible(self.ImgArrowUp, Type == RedDotDefine.ListRedDotPosType.Top)
	UIUtil.SetIsVisible(self.ImgArrowDown, Type == RedDotDefine.ListRedDotPosType.Bottom)
	UIUtil.SetIsVisible(self.ImgArrowLeft, Type == RedDotDefine.ListRedDotPosType.Left)
	UIUtil.SetIsVisible(self.ImgArrowRight, Type == RedDotDefine.ListRedDotPosType.Right)
end

function CommonBorderRedDotView:SetListKey(ListKey)
	self.ListKey = ListKey
	self:UpdataIsShowByListKey(self.ListKey)
	---防止设置Listkey在onshow后面
	_G.RedDotMgr:CollectBorderRedDotViewByShow(self)
end

function CommonBorderRedDotView:SetIsShow(IsShow)
	UIUtil.SetIsVisible(self.PanelContent, IsShow)
end

function CommonBorderRedDotView:UpdataIsShowByListKey(ListKey)
	local BorderRedDotData = _G.RedDotMgr:GetListRedDotDataByListKey(ListKey)
	local ListRedDotType
	if BorderRedDotData then
		ListRedDotType =  BorderRedDotData.ListRedDotType
	end
	if self.Type and BorderRedDotData and ListRedDotType then
		if self.Type == ListRedDotType.Mini then
			self:SetIsShow(BorderRedDotData.MiniShow)
		elseif self.Type == ListRedDotType.Max then
			self:SetIsShow(BorderRedDotData.MaxShow)
		else
			_G.FLOG_WARNING(string.format("边界红点样式不对， ListKey样式为max %s Mini %s,当前样式为%s", tostring(ListRedDotType.Max), tostring(ListRedDotType.Mini), tostring(self.Type)))
		end
	end
end

return CommonBorderRedDotView