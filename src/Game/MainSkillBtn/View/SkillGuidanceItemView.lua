---
--- Author: ashyuan
--- DateTime: 2024-05-28 11:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local MainPanelVM = require("Game/Main/MainPanelVM")
local TeachingDefine = require("Game/Pworld/Teaching/TeachingDefine")
local ProtoRes = require("Protocol/ProtoRes")

local UI_DIR_TYPE = ProtoRes.ui_dir_type

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
---@field PanelTips10 UFCanvasPanel
---@field PanelTips11 UFCanvasPanel
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
---@field SkillGuidanceTips10 PWorldTeachingSkillGuidanceItemView
---@field SkillGuidanceTips11 PWorldTeachingSkillGuidanceItemView
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
---@field Tips10 USizeBox
---@field Tips11 USizeBox
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
	--self.PanelTips10 = nil
	--self.PanelTips11 = nil
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
	--self.SkillGuidanceTips10 = nil
	--self.SkillGuidanceTips11 = nil
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
	--self.Tips10 = nil
	--self.Tips11 = nil
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
	self:AddSubView(self.SkillGuidanceTips10)
	self:AddSubView(self.SkillGuidanceTips11)
	self:AddSubView(self.SkillGuidanceTipsSlide)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillGuidanceItemView:OnInit()
	--技能引导控件列表
	self.GuideList = {
		[1] = {Panel = self.PanelTips01, Tips = self.Tips01, Guidance = self.SkillGuidanceTips01, Dir = UI_DIR_TYPE.UI_DIR_LEFT},
		[2] = {Panel = self.PanelTips02, Tips = self.Tips02, Guidance = self.SkillGuidanceTips02, Dir = UI_DIR_TYPE.UI_DIR_LEFT},
		[3] = {Panel = self.PanelTips03, Tips = self.Tips03, Guidance = self.SkillGuidanceTips03, Dir = UI_DIR_TYPE.UI_DIR_LEFT},
		[4] = {Panel = self.PanelTips04, Tips = self.Tips04, Guidance = self.SkillGuidanceTips04, Dir = UI_DIR_TYPE.UI_DIR_UP},
		[5] = {Panel = self.PanelTips05, Tips = self.Tips05, Guidance = self.SkillGuidanceTips05, Dir = UI_DIR_TYPE.UI_DIR_UP},
		[11] = {Panel = self.PanelTips06, Tips = self.Tips06, Guidance = self.SkillGuidanceTips06, Dir = UI_DIR_TYPE.UI_DIR_LEFT},
		[8] = {Panel = self.PanelTips07, Tips = self.Tips07, Guidance = self.SkillGuidanceTips07, Dir = UI_DIR_TYPE.UI_DIR_LEFT},
		[9] = {Panel = self.PanelTips08, Tips = self.Tips08, Guidance = self.SkillGuidanceTips08, Dir = UI_DIR_TYPE.UI_DIR_LEFT},
		[6] = {Panel = self.PanelTips09, Tips = self.Tips09, Guidance = self.SkillGuidanceTips09, Dir = UI_DIR_TYPE.UI_DIR_UP},
		[7] = {Panel = self.PanelTips10, Tips = self.Tips10, Guidance = self.SkillGuidanceTips10, Dir = UI_DIR_TYPE.UI_DIR_UP},
		[14] = {Panel = self.PanelTips11, Tips = self.Tips11, Guidance = self.SkillGuidanceTips11, Dir = UI_DIR_TYPE.UI_DIR_LEFT},
	}
	--技能引导控件（拖拽技能）
	self.SlideGuide = {Panel = self.PanelTipsSlide, Tips = self.TipsSlide, Guidance = self.SkillGuidanceTipsSlide}
	self.MiddleList = {
		{Panel = self.Mid01, Guidance = self.SkillGuidanceMid01, Dir = UI_DIR_TYPE.UI_DIR_UP},
		{Panel = self.Mid02, Guidance = self.SkillGuidanceMid02, Dir = UI_DIR_TYPE.UI_DIR_RIGHT},
		{Panel = self.Mid03, Guidance = self.SkillGuidanceMid03, Dir = UI_DIR_TYPE.UI_DIR_DOWN},
		{Panel = self.Mid04, Guidance = self.SkillGuidanceMid04, Dir = UI_DIR_TYPE.UI_DIR_LEFT},
	}
end

function SkillGuidanceItemView:OnDestroy()

end

function SkillGuidanceItemView:OnShow()
	self:InitAllMask()

	local Params = self.Params
	if not Params or not Params.SkillID then
		self:Hide()
		return
	end

	-- 前置处理, 需要判断一下技能界面是否显示
	if not self:PreprocessSkillGuide() then
		self:Hide()
		return
	end

    local SkillID = Params.SkillID
	-- 配置错误, 直接关闭界面
	if not self:UpdateSkillInfo(SkillID) then
		_G.FLOG_ERROR("[SkillGuidanceItemView]Invalid SkillID:%d", SkillID)
		self:Hide()
		return
	end

	-- 引导界面显示
	self:ShowCommonSkillGuide()
end

function SkillGuidanceItemView:InitAllMask()
	UIUtil.SetIsVisible(self.PanelSkillGuidance, true)

	for _, PanelInfo in pairs(self.GuideList) do
		UIUtil.SetIsVisible(PanelInfo.Panel, false)
	end

	UIUtil.SetIsVisible(self.SlideGuide.Panel, false)

	UIUtil.SetIsVisible(self.ImgMaskMid, true)
	UIUtil.SetIsVisible(self.PanelMaskMidHollow, false)

	for i = 1, #self.MiddleList do
		UIUtil.SetIsVisible(self.MiddleList[i].Panel, false)
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
	if self.GuideSkillInfo == nil or self.GuideSkillInfo.SubSkillIndex == nil then
		return
	end
    if nil ~= Params and Params.IsDisplayed == true then
        self:ShowMultiChoiceSkillGuide(true)
    else
        self:ShowMultiChoiceSkillGuide(false)
    end
	-- TODO, 选择药品的时候会导致界面被盖住, 这种情况下没法继续进行教学, 先强制关闭教学界面避免卡流程
	if Params and not Params.IsDisplayed and Params.SelectIndex == 4 then
		self:Hide()
	end
end

--- 监听主角使用技能的情况
function SkillGuidanceItemView:OnMajorUseSkill(Params)
	if self.GuideSkillInfo == nil then
		self:Hide()
		return
	end
	local SkillIndex = Params.ULongParam1
	local SkillID = Params.IntParam1
	-- 判断是否使用的目标技能, 判断索引的时候使用技能索引, 按键的索引可能是修改过的
	if self.GuideSkillInfo.SkillID == SkillID and self.GuideSkillInfo.SkillIndex == SkillIndex then
		self:Hide()
		return
	end
	-- 子技能只判断技能ID是否一致
	if self.GuideSkillInfo.SubSkillID == SkillID then
		self:Hide()
		return
	end
end

--- 前置处理, 判断一下技能界面有没有正常显示
function SkillGuidanceItemView:PreprocessSkillGuide()
	self.SkillMainPanel = nil
	local MainPanelView = _G.UIViewMgr:FindVisibleView(UIViewID.MainPanel)
	-- 主界面关闭的情况下, 不显示教学
	if MainPanelView == nil then
		return false
	end
	-- 技能界面不可见的情况下不显示教学(后续可以考虑主动将技能面板打开)
	if not MainPanelVM.ControlPanelVisible or not MainPanelVM.IsFightState then
		return false
	end
	local ControlPanel = MainPanelView.ControlPanel
	self.SkillMainPanel = ControlPanel and ControlPanel.NewMainSkill_UIBP
	return self.SkillMainPanel ~= nil
end

--- 刷新技能相关数据
---@param SkillID number @技能ID
function SkillGuidanceItemView:UpdateSkillInfo(SkillID)
	-- 清空数据
	self.GuideSkillInfo = {}
	if self.SkillMainPanel == nil then
		return false
	end
	_G.FLOG_INFO("[SkillGuidanceItemView]Update SkillID:%d", SkillID)
	for _, View in pairs(self.SkillMainPanel.AbleSkillMap) do
		if View.BtnSkillID == SkillID then
			self.GuideSkillInfo.SkillID = SkillID
			self.GuideSkillInfo.SkillIndex = View.ButtonIndex
			self.GuideSkillInfo.SkillButtonIndex = View.OriginalButtonIndex
			return true
		end
		-- 如果有多选技能, 判断一下多选技能ID
		if View.SelectIdList then
			for SubIndex, Value in ipairs(View.SelectIdList) do
				if Value.ID == SkillID then
					self.GuideSkillInfo.SkillID = View.BtnSkillID
					self.GuideSkillInfo.SkillIndex = View.ButtonIndex
					self.GuideSkillInfo.SkillButtonIndex = View.OriginalButtonIndex
					self.GuideSkillInfo.SubSkillID = Value.ID
					self.GuideSkillInfo.SubSkillIndex = SubIndex
					return true
				end
			end
		end
	end
	return false
end

--- 技能教学界面显示
function SkillGuidanceItemView:ShowCommonSkillGuide()
	-- 显示教学界面的时候用按键索引
	local SkillButtonIndex = self.GuideSkillInfo.SkillButtonIndex
	if not self.GuideList[SkillButtonIndex] then
		return
	end
	local GuideInfo = self.GuideList[SkillButtonIndex]
	UIUtil.SetIsVisible(GuideInfo.Panel, true)
	UIUtil.SetIsVisible(GuideInfo.Tips, true)
	GuideInfo.Guidance:SetSkillInfo(self.GuideSkillInfo.SkillID, GuideInfo.Dir)
	self:ShowSkillGuideMask(GuideInfo.Panel)
end

--- 选择技能教学界面显示
---@param bShow boolean @是否显示
function SkillGuidanceItemView:ShowMultiChoiceSkillGuide(bShow)
	UIUtil.SetIsVisible(self.ImgMaskMid, not bShow)
	UIUtil.SetIsVisible(self.PanelMaskMidHollow, bShow)
	local Index = self.GuideSkillInfo.SubSkillIndex
	if not self.MiddleList[Index] then
		return
	end
	local MiddleInfo = self.MiddleList[Index]
	UIUtil.SetIsVisible(MiddleInfo.Panel, bShow)
	MiddleInfo.Guidance:SetSkillInfo(self.GuideSkillInfo.SubSkillID, MiddleInfo.Dir)
end

--- 显示技能教学Mask
---@param GuideWidget UUserWidget @SkillID对应技能面板上的按键控件
function SkillGuidanceItemView:ShowSkillGuideMask(GuideWidget)
	-- 获取按键的大小和位置信息
	local WidgetPos = UIUtil.CanvasSlotGetPosition(GuideWidget)
	local WidgetSize = UIUtil.CanvasSlotGetSize(GuideWidget)
	-- 重新计算右侧Mask区域的宽高
	local ScreenSize = UIUtil.GetScreenSize()
	local MaskLeftPos = UIUtil.CanvasSlotGetPosition(self.ImgMaskLeft)
	local MaskWidth = ScreenSize.X / 2 - MaskLeftPos.X
	local MaskHeight = ScreenSize.Y

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

function SkillGuidanceItemView:OnRegisterBinder()

end

return SkillGuidanceItemView