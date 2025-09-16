---
--- Author: ashyuan
--- DateTime: 2024-05-28 11:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local TeachingDefine = require("Game/Pworld/Teaching/TeachingDefine")

local TeachingMgr = _G.TeachingMgr

---@class SkillGuidanceItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgDown UFImage
---@field ImgMaskLeft UFImage
---@field ImgMaskMid UFImage
---@field ImgMaskRight UFImage
---@field ImgTop UFImage
---@field Mid01 USizeBox
---@field Mid02 USizeBox
---@field Mid03 USizeBox
---@field Mid04 USizeBox
---@field PanelMask UFCanvasPanel
---@field PanelMaskMidHollow UFCanvasPanel
---@field PanelSkillGuidance UFCanvasPanel
---@field PanelTips01 UFCanvasPanel
---@field PanelTips02 UFCanvasPanel
---@field PanelTips03 UFCanvasPanel
---@field PanelTips04 UFCanvasPanel
---@field PanelTips05 UFCanvasPanel
---@field PanelTips06 UFCanvasPanel
---@field PanelTips07 UFCanvasPanel
---@field PanelTips08 UFCanvasPanel
---@field PanelTips09 UFCanvasPanel
---@field PanelTipsSlide UFCanvasPanel
---@field SkillGuidanceMid01 PWorldTeachingSkillGuidanceItemView
---@field SkillGuidanceMid02 PWorldTeachingSkillGuidanceItemView
---@field SkillGuidanceMid03 PWorldTeachingSkillGuidanceItemView
---@field SkillGuidanceMid04 PWorldTeachingSkillGuidanceItemView
---@field SkillGuidanceTips01 PWorldTeachingSkillGuidanceItemView
---@field SkillGuidanceTips02 PWorldTeachingSkillGuidanceItemView
---@field SkillGuidanceTips03 PWorldTeachingSkillGuidanceItemView
---@field SkillGuidanceTips04 PWorldTeachingSkillGuidanceItemView
---@field SkillGuidanceTips05 PWorldTeachingSkillGuidanceItemView
---@field SkillGuidanceTips06 PWorldTeachingSkillGuidanceItemView
---@field SkillGuidanceTips07 PWorldTeachingSkillGuidanceItemView
---@field SkillGuidanceTips08 PWorldTeachingSkillGuidanceItemView
---@field SkillGuidanceTips09 PWorldTeachingSkillGuidanceItemView
---@field SkillGuidanceTipsSlide PWorldTeachingSkillGuidanceItemView
---@field Tips01 USizeBox
---@field Tips02 USizeBox
---@field Tips03 USizeBox
---@field Tips04 USizeBox
---@field Tips05 USizeBox
---@field Tips06 USizeBox
---@field Tips07 USizeBox
---@field Tips08 USizeBox
---@field Tips09 USizeBox
---@field TipsSlide USizeBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillGuidanceItemView = LuaClass(UIView, true)

function SkillGuidanceItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgDown = nil
	--self.ImgMaskLeft = nil
	--self.ImgMaskMid = nil
	--self.ImgMaskRight = nil
	--self.ImgTop = nil
	--self.Mid01 = nil
	--self.Mid02 = nil
	--self.Mid03 = nil
	--self.Mid04 = nil
	--self.PanelMask = nil
	--self.PanelMaskMidHollow = nil
	--self.PanelSkillGuidance = nil
	--self.PanelTips01 = nil
	--self.PanelTips02 = nil
	--self.PanelTips03 = nil
	--self.PanelTips04 = nil
	--self.PanelTips05 = nil
	--self.PanelTips06 = nil
	--self.PanelTips07 = nil
	--self.PanelTips08 = nil
	--self.PanelTips09 = nil
	--self.PanelTipsSlide = nil
	--self.SkillGuidanceMid01 = nil
	--self.SkillGuidanceMid02 = nil
	--self.SkillGuidanceMid03 = nil
	--self.SkillGuidanceMid04 = nil
	--self.SkillGuidanceTips01 = nil
	--self.SkillGuidanceTips02 = nil
	--self.SkillGuidanceTips03 = nil
	--self.SkillGuidanceTips04 = nil
	--self.SkillGuidanceTips05 = nil
	--self.SkillGuidanceTips06 = nil
	--self.SkillGuidanceTips07 = nil
	--self.SkillGuidanceTips08 = nil
	--self.SkillGuidanceTips09 = nil
	--self.SkillGuidanceTipsSlide = nil
	--self.Tips01 = nil
	--self.Tips02 = nil
	--self.Tips03 = nil
	--self.Tips04 = nil
	--self.Tips05 = nil
	--self.Tips06 = nil
	--self.Tips07 = nil
	--self.Tips08 = nil
	--self.Tips09 = nil
	--self.TipsSlide = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillGuidanceItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SkillGuidanceMid01)
	self:AddSubView(self.SkillGuidanceMid02)
	self:AddSubView(self.SkillGuidanceMid03)
	self:AddSubView(self.SkillGuidanceMid04)
	self:AddSubView(self.SkillGuidanceTips01)
	self:AddSubView(self.SkillGuidanceTips02)
	self:AddSubView(self.SkillGuidanceTips03)
	self:AddSubView(self.SkillGuidanceTips04)
	self:AddSubView(self.SkillGuidanceTips05)
	self:AddSubView(self.SkillGuidanceTips06)
	self:AddSubView(self.SkillGuidanceTips07)
	self:AddSubView(self.SkillGuidanceTips08)
	self:AddSubView(self.SkillGuidanceTips09)
	self:AddSubView(self.SkillGuidanceTipsSlide)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillGuidanceItemView:OnInit()
	--技能引导控件列表
	self.GuideList = {
		{Panel = self.PanelTips01, Tips = self.Tips01, Guidance = self.SkillGuidanceTips01},
		{Panel = self.PanelTips02, Tips = self.Tips02, Guidance = self.SkillGuidanceTips02},
		{Panel = self.PanelTips03, Tips = self.Tips03, Guidance = self.SkillGuidanceTips03},
		{Panel = self.PanelTips04, Tips = self.Tips04, Guidance = self.SkillGuidanceTips04},
		{Panel = self.PanelTips05, Tips = self.Tips05, Guidance = self.SkillGuidanceTips05},
		{Panel = self.PanelTips06, Tips = self.Tips06, Guidance = self.SkillGuidanceTips06},
		{Panel = self.PanelTips07, Tips = self.Tips07, Guidance = self.SkillGuidanceTips07},
		{Panel = self.PanelTips08, Tips = self.Tips08, Guidance = self.SkillGuidanceTips08},
		{Panel = self.PanelTips09, Tips = self.Tips09, Guidance = self.SkillGuidanceTips09},
	}
	--技能引导控件（拖拽技能）
	self.SlideGuide = {Panel = self.PanelTipsSlide, Tips = self.TipsSlide, Guidance = self.SkillGuidanceTipsSlide}
	self.MiddleList = {
		{Panel = self.Mid01, Guidance = self.SkillGuidanceMid01},
		{Panel = self.Mid02, Guidance = self.SkillGuidanceMid02},
		{Panel = self.Mid03, Guidance = self.SkillGuidanceMid03},
		{Panel = self.Mid04, Guidance = self.SkillGuidanceMid04},
	}
end

function SkillGuidanceItemView:OnDestroy()

end

function SkillGuidanceItemView:OnShow()

	self:InitAllMask()

	local Params = self.Params
	if not Params or not Params.Index then
		return
	end

	self.GuideSkillID = 0
	self.GuideSkillIndex = 0
	self.MiddleSkillIndex = 0

    local Index = Params.Index

	if Index > TeachingDefine.GuideSkillExBaseID then
		-- 拖拽技能处理
		if self.SlideGuide then
			UIUtil.SetIsVisible(self.SlideGuide.Panel, true)
			UIUtil.SetIsVisible(self.SlideGuide.Tips, true)
			self.SlideGuide.Guidance:SetSkillInfo(0)
			self:OnCalculateMask(self.SlideGuide.Panel)
		end
		self.GuideSkillID = TeachingMgr:GetGuideSkillID(Index)
		self.MiddleSkillIndex = Index - TeachingDefine.GuideSkillExBaseID
	else
		-- 普通技能处理
		if self.GuideList[Index] then
			UIUtil.SetIsVisible(self.GuideList[Index].Panel, true)
			UIUtil.SetIsVisible(self.GuideList[Index].Tips, true)
			self.GuideList[Index].Guidance:SetSkillInfo(Index)
			self:OnCalculateMask(self.GuideList[Index].Panel)
		end
		self.GuideSkillIndex = Index
	end
end

function SkillGuidanceItemView:InitAllMask()
	UIUtil.SetIsVisible(self.PanelSkillGuidance, true)

	for i = 1, #self.GuideList do
		UIUtil.SetIsVisible(self.GuideList[i].Panel, false)
	end

	UIUtil.SetIsVisible(self.SlideGuide.Panel, false)
	
	UIUtil.SetIsVisible(self.ImgMaskMid, true)
	UIUtil.SetIsVisible(self.PanelMaskMidHollow, false)

	for i = 1, #self.MiddleList do
		UIUtil.SetIsVisible(self.MiddleList[i].Panel, false)
	end
end

function SkillGuidanceItemView:OnCalculateMask(GuideWidget)
	-- 重新计算右侧Mask区域的宽高
	local ScreenSize = UIUtil.GetScreenSize()
	local MaskLeftPos = UIUtil.CanvasSlotGetPosition(self.ImgMaskLeft)
	local MaskWidth = ScreenSize.X / 2 - MaskLeftPos.X
	local MaskHeight = ScreenSize.Y

	-- 计算Widget的位置和大小
	local WidgetPos = UIUtil.CanvasSlotGetPosition(GuideWidget)
	local WidgetSize = UIUtil.CanvasSlotGetSize(GuideWidget)

	-- 计算上下左右的大小
	local Left = MaskWidth + WidgetPos.X - WidgetSize.X
	local Right = -WidgetPos.X
	local Top = MaskHeight + WidgetPos.Y - WidgetSize.Y
	local Down = -WidgetPos.Y

	if Left < 0 then
		Left = 0
	end

	-- Left和Right的位置固定，只需要设置Size
	UIUtil.CanvasSlotSetSize(self.ImgMaskLeft, _G.UE.FVector2D(Left, 0))
	UIUtil.CanvasSlotSetSize(self.ImgMaskRight, _G.UE.FVector2D(Right, 0))

	-- Top和Down需要调整整个Offset
	local TopOffset = UIUtil.CanvasSlotGetOffsets(self.ImgTop)
	TopOffset.Left = MaskLeftPos.X + Left
	TopOffset.Right = Right
	TopOffset.Bottom = Top
	UIUtil.CanvasSlotSetOffsets(self.ImgTop, TopOffset)

	local DownOffset = UIUtil.CanvasSlotGetOffsets(self.ImgDown)
	DownOffset.Left = MaskLeftPos.X + Left
	DownOffset.Right = Right
	DownOffset.Bottom = Down
	UIUtil.CanvasSlotSetOffsets(self.ImgDown, DownOffset)
end

function SkillGuidanceItemView:OnShowMiddleHollowMask(bShow)
	if bShow then
		UIUtil.SetIsVisible(self.ImgMaskMid, false)
		UIUtil.SetIsVisible(self.PanelMaskMidHollow, true)

		local Index = self.MiddleSkillIndex
		if Index and self.MiddleList[Index] then
			UIUtil.SetIsVisible(self.MiddleList[Index].Panel, true)
			self.MiddleList[Index].Guidance:SetSkillInfo(Index + TeachingDefine.GuideSkillExBaseID)
		end
	else
		UIUtil.SetIsVisible(self.ImgMaskMid, true)
		UIUtil.SetIsVisible(self.PanelMaskMidHollow, false)

		local Index = self.MiddleSkillIndex
		if Index and self.MiddleList[Index] then
			UIUtil.SetIsVisible(self.MiddleList[Index].Panel, false)
		end
	end
end

function SkillGuidanceItemView:OnHide()

end

function SkillGuidanceItemView:OnRegisterUIEvent()

end

function SkillGuidanceItemView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.MajorUseSkill, self.OnMajorUseSkill)
	self:RegisterGameEvent(EventID.SkillMultiChoicePanelShowed, self.OnSkillMultiChoicePanelShowed)
end

function SkillGuidanceItemView:OnSkillMultiChoicePanelShowed(Params)
    if nil ~= Params and Params.IsDisplayed == true then
        self:OnShowMiddleHollowMask(true)
		if self.SlideGuide then
			self.SlideGuide.Guidance:SetSelecetScale(1.2)
		end
    else
        self:OnShowMiddleHollowMask(false)
		if self.SlideGuide then
			self.SlideGuide.Guidance:SetSelecetScale(1.0)
		end
    end
end

function SkillGuidanceItemView:OnMajorUseSkill(Params)
	-- 判断SkillIndex

	local SkillIndex = Params.ULongParam1
	local SkillID = Params.IntParam1
	if self.GuideSkillIndex and self.GuideSkillIndex > 0 then
		if SkillIndex and SkillIndex == self.GuideSkillIndex then
			_G.UIViewMgr:HideView(UIViewID.PWorldSkillGuidancePanel)
		end
		return
	end
	-- 判断SkillID
	if self.GuideSkillID and self.GuideSkillID > 0 then
		if SkillID and SkillID == self.GuideSkillID then
			_G.UIViewMgr:HideView(UIViewID.PWorldSkillGuidancePanel)
		end
		return
	end
end

function SkillGuidanceItemView:OnRegisterBinder()

end

return SkillGuidanceItemView