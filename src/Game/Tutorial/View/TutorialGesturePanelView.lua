---
--- Author: Administrator
--- DateTime: 2023-05-19 10:38
--- Description:
---

local UIView = require("UI/UIView")
local TutorialBaseView = require("Game/Tutorial/View/TutorialBaseView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TutorialCfg = require("TableCfg/TutorialCfg")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local TutorialUtil = require("Game/Tutorial/TutorialUtil")
local KIL = _G.UE.UKismetInputLibrary
local EventID
local EventMgr

---@class TutorialGesturePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field PanelGesture01 UFCanvasPanel
---@field PanelGesture02 UFCanvasPanel
---@field PanelGesture03 UFCanvasPanel
---@field PanelGesture04 UFCanvasPanel
---@field PanelTips TutorialGestureTips1ItemView
---@field AnimMove UWidgetAnimation
---@field AnimMoveStop UWidgetAnimation
---@field AnimScale UWidgetAnimation
---@field AnimScaleStop UWidgetAnimation
---@field AnimSlide UWidgetAnimation
---@field AnimSlideStop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TutorialGesturePanelView = LuaClass(TutorialBaseView, true)

function TutorialGesturePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.PanelGesture01 = nil
	--self.PanelGesture02 = nil
	--self.PanelGesture03 = nil
	--self.PanelGesture04 = nil
	--self.PanelTips = nil
	--self.AnimMove = nil
	--self.AnimMoveStop = nil
	--self.AnimScale = nil
	--self.AnimScaleStop = nil
	--self.AnimSlide = nil
	--self.AnimSlideStop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.EndFuncName = ""
end

function TutorialGesturePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PanelTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TutorialGesturePanelView:OnInit()
	EventID = _G.EventID
	EventMgr = _G.EventMgr

end

function TutorialGesturePanelView:OnDestroy()
end

function TutorialGesturePanelView:OnShow()
	
	if not self.Params then
		return 
	end

	self:SetTutorialParams()

	UIUtil.SetIsVisible(self.Btn, false, false)

	self.TutorialID = self.Params.TutorialID
	local TutorialID = self.TutorialID

	local EndAnim = TutorialCfg:GetTutorialEndAnim(TutorialID)
	local LoopAnim = TutorialCfg:GetTutorialAnim(TutorialID)
	local Content = TutorialCfg:GetTutorialContent(TutorialID)
	local Time = TutorialCfg:GetTutorialTime(TutorialID)

	local GuideWidgetPath = TutorialCfg:GetTutorialGuideWidgetPath(TutorialID)
	local GuideWidget = TutorialUtil:GetTutorialWidget(GuideWidgetPath)
	
	if LoopAnim then
		self.AnimIn = self[tostring(LoopAnim)]
	end

	if EndAnim then
		self.AnimOut = self[tostring(EndAnim)]
	end
	
	self.PanelTips:SetText(Content)
	self.PanelTips:PlayAnimIn()
	self.PanelTips:StartCountDown(Time)

	if self.AnimIn then
		UIUtil.SetIsVisible(self.PanelGesture01, self.PanelGesture01:GetName() == GuideWidget)
		UIUtil.SetIsVisible(self.PanelGesture02, self.PanelGesture02:GetName() == GuideWidget)
		UIUtil.SetIsVisible(self.PanelGesture03, self.PanelGesture02:GetName() == GuideWidget)
		UIUtil.SetIsVisible(self.PanelGesture04, self.PanelGesture04:GetName() == GuideWidget)
	end

	UIUtil.SetIsVisible(self.PanelTips, Content ~= "" and Content)
end

function TutorialGesturePanelView:OnRegisterUIEvent()
	--- 临时方案
	-- UIUtil.AddOnClickedEvent(self,self.Btn,self.EndFuncCallback)
end

function TutorialGesturePanelView:EndFuncCallback()
	local EndFuncName = TutorialCfg:GetTutorialEndFuncName(self.TutorialID)

	local Params = {}
	Params.FuncName = EndFuncName
	Params.TutorialID = self.TutorialID
	_G.EventMgr:SendEvent(_G.EventID.TutorialEnd, Params)
	
end

function TutorialGesturePanelView:OnRegisterGameEvent()
	--self:RegisterGameEvent(EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
end

function TutorialGesturePanelView:OnRegisterBinder()
end

-- function TutorialGesturePanelView:OnPreprocessedMouseButtonDown(MouseEvent)
-- 	local CurSoftID = self.TutorialID
--     if CurSoftID == nil or (CurSoftID ~= TutorialDefine.TutorialSpecialID.Move and CurSoftID ~= TutorialDefine.TutorialSpecialID.Zoom and CurSoftID ~= TutorialDefine.TutorialSpecialID.Rotation) then
--         return
--     end

--     local MousePosition = KIL.PointerEvent_GetScreenSpacePosition(MouseEvent)
-- 	local SelfGeometry = _G.UE.UWidgetLayoutLibrary.GetViewportWidgetGeometry(self)
-- 	local CurPos = _G.UE.USlateBlueprintLibrary.AbsoluteToLocal(SelfGeometry, MousePosition)
--     local ScreenSize = UIUtil.GetViewportSize()
-- 	local DPIScale = _G.UE.UWidgetLayoutLibrary.GetViewportScale(self)
--     local CurPosVP = CurPos.X * DPIScale

--     local Params = {}
--     Params.FuncName = TutorialCfg:GetTutorialEndFuncName(CurSoftID)
--     Params.TutorialID = CurSoftID

--     if CurSoftID == TutorialDefine.TutorialSpecialID.Move then
--         if CurPosVP > 0 and CurPosVP < ScreenSize.X / 2  then
--             EventMgr:SendEvent(EventID.TutorialEnd, Params)
--         end
--     else
-- 		-- if CurPosVP > ScreenSize.X / 2 then
--         EventMgr:SendEvent(EventID.TutorialEnd, Params)
-- 		-- end
--     end
-- end

return TutorialGesturePanelView