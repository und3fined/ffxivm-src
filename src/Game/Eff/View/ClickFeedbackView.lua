---
--- Author: xingcaicao
--- DateTime: 2022-11-21 18:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local KIL = _G.UE.UKismetInputLibrary

---@class ClickFeedbackView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AniNode UFCanvasPanel
---@field BlockInput UButton
---@field BtnScreenshot UButton
---@field TxtRecord UTextBlock
---@field TxtRecordID UTextBlock
---@field AnimClick UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ClickFeedbackView = LuaClass(UIView, true)

function ClickFeedbackView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AniNode = nil
	--self.BlockInput = nil
	--self.BtnScreenshot = nil
	--self.TxtRecord = nil
	--self.TxtRecordID = nil
	--self.AnimClick = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ClickFeedbackView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ClickFeedbackView:OnInit()
end

function ClickFeedbackView:OnDestroy()
end

function ClickFeedbackView:OnShow()
	UIUtil.SetIsVisible(self.AniNode, false)
	UIUtil.SetIsVisible(self.TxtRecord,false)
	UIUtil.SetIsVisible(self.TxtRecordID,false)
	UIUtil.SetIsVisible(self.BtnScreenshot,false,false)
	UIUtil.SetIsVisible(self.BlockInput,false,false)
end

function ClickFeedbackView:OnHide()
end

function ClickFeedbackView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnScreenshot, self.OnScreenshot)
end

function ClickFeedbackView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
	self:RegisterGameEvent(_G.EventID.BlockAllInput, self.OnBlockAllInput)
	self:RegisterGameEvent(EventID.Update_Recording, self.UpdateRecording)
	self:RegisterGameEvent(EventID.Show_RecordID, self.ShowRecordID)
end

function ClickFeedbackView:OnRegisterBinder()
end

function ClickFeedbackView:OnPreprocessedMouseButtonDown(MouseEvent)
	if not UIUtil.IsVisible(self.AniNode) then
		UIUtil.SetIsVisible(self.AniNode, true)
	end

	local MousePosition = KIL.PointerEvent_GetScreenSpacePosition(MouseEvent)
	local SelfGeometry = _G.UE.UWidgetLayoutLibrary.GetViewportWidgetGeometry(self)
	local CurPos = _G.UE.USlateBlueprintLibrary.AbsoluteToLocal(SelfGeometry, MousePosition)
	UIUtil.CanvasSlotSetPosition(self.AniNode, CurPos)

	self:PlayAnimation(self.AnimClick)

	-- if _G.LevelRecordMgr ~= nil and _G.LevelRecordMgr.bIsInReplaying then
	-- 	_G.UIViewMgr:HideAllUIOverLayer()
	-- 	if  _G.StoryMgr:SequenceIsPlaying() then
	-- 		_G.StoryMgr:StopSequence()
	-- 	end
    -- end
end

function ClickFeedbackView:OnBlockAllInput(bIsBlock)
	-- UIUtil.SetIsVisible(self.BlockInput, bIsBlock,bIsBlock)
end

-- 临时功能，标记正在录像中
function ClickFeedbackView:UpdateRecording(Param)
    if _G.LevelRecordMgr == nil then
        UIUtil.SetIsVisible(self.TxtRecord,false)
		UIUtil.SetIsVisible(self.BtnScreenshot, false, false)
		return
    end
    local ReplayStatu = UE4.ULevelRecordMgr:Get():GetReplayStatu()
    UIUtil.SetIsVisible(self.TxtRecord, ReplayStatu ~= _G.LevelRecordMgr.EReplayStatus.None)
    local str = "";
    if ReplayStatu == _G.LevelRecordMgr.EReplayStatus.InRecord then
        str = "录像中...";
    end
    if ReplayStatu == _G.LevelRecordMgr.EReplayStatus.InRecordPlay then
        str = "回放中...";
    end
    self.TxtRecord:SetText(str)
	local bShow = ReplayStatu == _G.LevelRecordMgr.EReplayStatus.InRecord or ReplayStatu == _G.LevelRecordMgr.EReplayStatus.InRecordPlay
	bShow = bShow and UE4.UIRecordMgr:Get().OpenUIRecord
	UIUtil.SetIsVisible(self.BtnScreenshot, bShow, bShow)
end

function ClickFeedbackView:ShowRecordID(Param)
	if _G.LevelRecordMgr ~= nil then
		UIUtil.SetIsVisible(self.TxtRecordID,not UIUtil.IsVisible(self.TxtRecordID))
		self.TxtRecordID:SetText("录像ID:".._G.LevelRecordMgr.CurrentRecordID)
	end
end

function ClickFeedbackView:OnScreenshot()
	UE4.UIRecordMgr:Get():Screenshot("TestScreenshot/"..CommonUtil.GetCurrentCultureName().."/ShotPic",true,true)
	_G.MsgTipsUtil.ShowTips("截图成功!")
end

return ClickFeedbackView