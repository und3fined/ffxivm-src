---
--- Author: Administrator
--- DateTime: 2025-07-22 12:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MagicCardDefine = require("Game/MagicCard/MagicCardLocalDef")
local MagicCardMgr = require("Game/MagicCard/MagicCardMgr")
local MagicCardVMUtils = require("Game/MagicCard/MagicCardVMUtils")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local UKismetInputLibrary = UE.UKismetInputLibrary

---@class CardGameNewBiePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field GuideSelect TutorialGestureSelectItemView
---@field GuideSelect_1 TutorialGestureSelectItemView
---@field GuideSelect_2 TutorialGestureSelectItemView
---@field GuideSelect_3 TutorialGestureSelectItemView
---@field GuideSelect_4 TutorialGestureSelectItemView
---@field GuideSelect_5 TutorialGestureSelectItemView
---@field ImgMaskFocus UFImage
---@field PanelGuide01 UFCanvasPanel
---@field PanelGuide02 UFCanvasPanel
---@field PanelGuide03 UFCanvasPanel
---@field PanelGuide04 UFCanvasPanel
---@field PanelGuide05 UFCanvasPanel
---@field PanelGuide06 UFCanvasPanel
---@field SkillGenAttackTips TutorialGestureTips2ItemView
---@field SkillGenAttackTips_1 TutorialGestureTips2ItemView
---@field SkillGenAttackTips_2 TutorialGestureTips2ItemView
---@field SkillGenAttackTips_3 TutorialGestureTips2ItemView
---@field SkillGenAttackTips_4 TutorialGestureTips2ItemView
---@field SkillGenAttackTips_5 TutorialGestureTips2ItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardGameNewBiePanelView = LuaClass(UIView, true)

function CardGameNewBiePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.GuideSelect = nil
	--self.GuideSelect_1 = nil
	--self.GuideSelect_2 = nil
	--self.GuideSelect_3 = nil
	--self.GuideSelect_4 = nil
	--self.GuideSelect_5 = nil
	--self.ImgMaskFocus = nil
	--self.PanelGuide01 = nil
	--self.PanelGuide02 = nil
	--self.PanelGuide03 = nil
	--self.PanelGuide04 = nil
	--self.PanelGuide05 = nil
	--self.PanelGuide06 = nil
	--self.SkillGenAttackTips = nil
	--self.SkillGenAttackTips_1 = nil
	--self.SkillGenAttackTips_2 = nil
	--self.SkillGenAttackTips_3 = nil
	--self.SkillGenAttackTips_4 = nil
	--self.SkillGenAttackTips_5 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardGameNewBiePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.GuideSelect)
	self:AddSubView(self.GuideSelect_1)
	self:AddSubView(self.GuideSelect_2)
	self:AddSubView(self.GuideSelect_3)
	self:AddSubView(self.GuideSelect_4)
	self:AddSubView(self.GuideSelect_5)
	self:AddSubView(self.SkillGenAttackTips)
	self:AddSubView(self.SkillGenAttackTips_1)
	self:AddSubView(self.SkillGenAttackTips_2)
	self:AddSubView(self.SkillGenAttackTips_3)
	self:AddSubView(self.SkillGenAttackTips_4)
	self:AddSubView(self.SkillGenAttackTips_5)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardGameNewBiePanelView:OnInit()
	self.TutorialWidgetList = {
		-- 准备按钮
		[MagicCardDefine.TutorialID_Ready] = {Panel = self.PanelGuide05, SelectBtn = self.GuideSelect_4, 
			TipsBP = self.SkillGenAttackTips_4, Dir = TutorialDefine.TutorialArrowDir.Top, Type = TutorialDefine.TutorialType.Tips},
		-- 卡牌介绍
		[MagicCardDefine.TutorialID_CardInstruction] = {Panel = self.PanelGuide03, SelectBtn = self.GuideSelect_2, 
			TipsBP = self.SkillGenAttackTips_2, Dir = TutorialDefine.TutorialArrowDir.Bottom, Type = TutorialDefine.TutorialType.Tips}, 
		-- 不翻牌规则
		[MagicCardDefine.TutorialID_NPCPutCard] = {Panel = self.PanelGuide01, SelectBtn = self.GuideSelect, 
			TipsBP = self.SkillGenAttackTips, Dir = TutorialDefine.TutorialArrowDir.Bottom, Type = TutorialDefine.TutorialType.Tips},
		-- 玩家出牌指引
		[MagicCardDefine.TutorialID_PlayerTurn] = {Panel = self.PanelGuide02, SelectBtn = self.GuideSelect_1, 
			TipsBP = self.SkillGenAttackTips_1, Dir = TutorialDefine.TutorialArrowDir.Left, Type = TutorialDefine.TutorialType.Tips}, 
		-- [MagicCardDefine.TutorialID_PlayerPutCard] = {Panel = self.PanelGuide01, SelectBtn = self.GuideSelect, 
		-- TipsBP = self.SkillGenAttackTips, Dir = TutorialDefine.TutorialArrowDir.Bottom, Type = TutorialDefine.TutorialType.Tips}, -- 玩家翻牌
		-- [MagicCardDefine.TutorialID_NPCPutCardSecond] = {Panel = self.PanelGuide06, SelectBtn = self.GuideSelect_5, 
		-- TipsBP = self.SkillGenAttackTips_5, Dir = TutorialDefine.TutorialArrowDir.Bottom, Type = TutorialDefine.TutorialType.Tips}, -- 不翻牌规则
		-- 比分
		[MagicCardDefine.TutorialID_Result] = {Panel = self.PanelGuide04, SelectBtn = self.GuideSelect_3, 
			TipsBP = self.SkillGenAttackTips_3, Dir = TutorialDefine.TutorialArrowDir.Left, Type = TutorialDefine.TutorialType.Tips}, 
	}

	UIUtil.SetIsVisible(self.PanelGuide06, false) --  无用
	for _, WidgetInfo in pairs(self.TutorialWidgetList) do
		UIUtil.SetIsVisible(WidgetInfo.Panel, false)
	end
end

function CardGameNewBiePanelView:OnDestroy()
	
end

function CardGameNewBiePanelView:OnShow()
	self:SetContentText()
end

-- 设置引导框提示文本
function CardGameNewBiePanelView:SetContentText()
	for TutorialID, WidgetInfo in pairs(self.TutorialWidgetList) do
		WidgetInfo.TipsBP:NearBy(WidgetInfo.Dir, {Type = WidgetInfo.Type})
		WidgetInfo.TipsBP:SetText(MagicCardDefine.TutorialWidgetRef[TutorialID].Tips)
	end
end

function CardGameNewBiePanelView:OnHide()

end

function CardGameNewBiePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnCommonAreaClicked)
	for TutorialID, WidgetInfo in pairs(self.TutorialWidgetList) do
		if TutorialID == MagicCardDefine.TutorialID_PlayerTurn then
			WidgetInfo.SelectBtn:SetFunc(true)
		else
			WidgetInfo.SelectBtn:SetFunc(false)
			UIUtil.AddOnClickedEvent(self, WidgetInfo.SelectBtn.Btn, self.OnSelectBtnClicked, TutorialID)
		end
	end
end

function CardGameNewBiePanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PlayMagicCardTutorial, self.OnPlayMagicCardTutorial)
end

function CardGameNewBiePanelView:OnRegisterBinder()

end

-- 显示指定引导框
function CardGameNewBiePanelView:OnPlayMagicCardTutorial(TutorialID)
	if TutorialID == self.TutorialID then
		return
	end
	
	-- 显示
	local TutorialWidget = self.TutorialWidgetList[TutorialID]
	if TutorialWidget then
		UIUtil.SetIsVisible(TutorialWidget.Panel, true)
		if TutorialID == MagicCardDefine.TutorialID_PlayerTurn then
			self:SetMaterialParameter()
		end
	end

	-- 自动出牌时隐藏出牌指引
	if TutorialID == MagicCardDefine.TutorialID_PlayerPutCard then
		self:HideTutorialView(MagicCardDefine.TutorialID_PlayerTurn)
	end
	
	-- 开启公共区域点击(出牌指引除外)
	if TutorialID == MagicCardDefine.TutorialID_PlayerTurn then
		self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
	end
	UIUtil.SetIsVisible(self.Btn, true, true)
	self.TutorialID = TutorialID
end

-- 引导框被点击
function CardGameNewBiePanelView:OnSelectBtnClicked(TutorialID)
	self:HideTutorialView(TutorialID)
	MagicCardMgr:OnTutorialSelectBtnClicked(TutorialID, nil, true)
end

-- 引导框外被点击
function CardGameNewBiePanelView:OnCommonAreaClicked()
	local Widget = MagicCardVMUtils:GetTutorialWidget(self.TutorialID)
	if Widget == nil then
		self:HideTutorialView(self.TutorialID) -- 不需要点击按钮，所以可以通过点击空白区域关闭指引
	end
	MagicCardMgr:OnTutorialSelectBtnClicked(self.TutorialID, nil, false)
end

function CardGameNewBiePanelView:HideTutorialView(TutorialID)
	if TutorialID == MagicCardDefine.TutorialID_PlayerTurn then
		self:UnRegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
	end

	local TutorialWidget = self.TutorialWidgetList[TutorialID]
	if TutorialWidget then
		UIUtil.SetIsVisible(TutorialWidget.Panel, false)
		UIUtil.SetIsVisible(self.Btn, false)
	end
end

-- 出牌指引(特殊，需拖拽)
function CardGameNewBiePanelView:OnPreprocessedMouseButtonDown(MouseEvent)
	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	local TutorialID = MagicCardDefine.TutorialID_PlayerTurn
	local TutorialWidget = self.TutorialWidgetList[self.TutorialID]
	if TutorialWidget and UIUtil.IsUnderLocation(TutorialWidget.SelectBtn, MousePosition) then
		MagicCardMgr:OnTutorialSelectBtnClicked(TutorialID, MouseEvent, true)
		self:HideTutorialView(TutorialID)
	end
end

-- 出牌指引框透明材质参数动态设置
function CardGameNewBiePanelView:SetMaterialParameter()
	local ViewPortSize = UIUtil.GetViewportSize()
	local ActualSize = ViewPortSize / UIUtil.GetViewportScale()
	-- 动态设置Focus图片尺寸
	UIUtil.CanvasSlotSetSize(self.ImgMaskFocus, ActualSize)
	UIUtil.ImageSetMaterialScalarParameterValue(self.ImgMaskFocus, "ImageWidth", ActualSize.X)
	UIUtil.ImageSetMaterialScalarParameterValue(self.ImgMaskFocus, "ImageHeight", ActualSize.Y)
	-- 动态设置Focus图片材质的透明框位置
	local HandCardPos, BoardCardPos = self:GetHandAndBoardCardPos()
	UIUtil.ImageSetMaterialScalarParameterValue(self.ImgMaskFocus, "Focus1_X", BoardCardPos.X) -- 棋盘
	UIUtil.ImageSetMaterialScalarParameterValue(self.ImgMaskFocus, "Focus1_Y", BoardCardPos.Y)

	UIUtil.ImageSetMaterialScalarParameterValue(self.ImgMaskFocus, "Focus2_X", HandCardPos.X) -- 手牌
	UIUtil.ImageSetMaterialScalarParameterValue(self.ImgMaskFocus, "Focus2_Y", HandCardPos.Y)
end

-- 获取出牌指引中，手牌和对比牌的窗口位置
function CardGameNewBiePanelView:GetHandAndBoardCardPos()
	local PixelPos = nil
	local HandCardPos =  _G.UE.FVector2D(0, 0)
	local BoardCardPos =  _G.UE.FVector2D(0, 0)
	local HandCardItemView = MagicCardVMUtils:GetTutorialWidget(MagicCardDefine.TutorialID_PlayerTurn)
	if HandCardItemView then
		local HandCardLocalPos = UIUtil.CanvasSlotGetPosition(HandCardItemView)
		HandCardPos, PixelPos =  UIUtil.LocalToViewport(HandCardItemView, HandCardLocalPos)
		local CardSize = UIUtil.CanvasSlotGetSize(HandCardItemView)
		HandCardPos.X = HandCardPos.X - CardSize.X/3  -- 剩余两张手牌时，当前要打的牌位置估摸左移1/3
		HandCardPos.Y = HandCardPos.Y + CardSize.Y/15  -- 呼吸动效导致超出，所以下移点
	end

	if self.ParentView and self.ParentView.CardItemsOnBoard then
		local BoardCardItemView = self.ParentView.CardItemsOnBoard[6]
		if BoardCardItemView then
			local BoardCardLocalPos = UIUtil.CanvasSlotGetPosition(BoardCardItemView)
			BoardCardPos, PixelPos =  UIUtil.LocalToViewport(BoardCardItemView, BoardCardLocalPos)
			local CardSize = UIUtil.CanvasSlotGetSize(BoardCardItemView)
			BoardCardPos.Y = BoardCardPos.Y + CardSize.Y/10  -- 下移点
		end
	end


	return HandCardPos, BoardCardPos
end

return CardGameNewBiePanelView