---
--- Author: Administrator
--- DateTime: 2025-07-15 20:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local Margin = 182

---@class StarLightRhythmGameHudPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FCanvasPanel_51 UFCanvasPanel
---@field RhythmGameBtnItem RhythmGameBtnItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StarLightRhythmGameHudPanelView = LuaClass(UIView, true)

function StarLightRhythmGameHudPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FCanvasPanel_51 = nil
	--self.RhythmGameBtnItem = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StarLightRhythmGameHudPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RhythmGameBtnItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StarLightRhythmGameHudPanelView:OnInit()

end

function StarLightRhythmGameHudPanelView:OnDestroy()

end

function StarLightRhythmGameHudPanelView:OnShow()

end

function StarLightRhythmGameHudPanelView:OnHide()

end

function StarLightRhythmGameHudPanelView:OnRegisterUIEvent()

end

function StarLightRhythmGameHudPanelView:OnRegisterGameEvent()

end

function StarLightRhythmGameHudPanelView:OnRegisterBinder()

end

function StarLightRhythmGameHudPanelView:UpdateNote(NoteData)
	local FCanvasSize = UIUtil.GetWidgetSize(self.FCanvasPanel_51)
	local AspectRatio = FCanvasSize.X / FCanvasSize.Y
	local DesignAspect = 16 / 9
	local ValidWidth, ValidHeight
	if AspectRatio > DesignAspect then
		ValidHeight = FCanvasSize.Y - 2 * Margin
		ValidWidth = ValidHeight * DesignAspect
	else
		ValidWidth = FCanvasSize.X - 2 * Margin
		ValidHeight = ValidWidth / DesignAspect
	end
	
	local X = ValidWidth * (NoteData.X - 0.5)
	local Y = ValidHeight * (NoteData.Y - 0.5)

	local Anchor = _G.UE.FAnchors()
	Anchor.Minimum = _G.UE.FVector2D(0.5, 0.5)
	Anchor.Maximum = _G.UE.FVector2D(0.5, 0.5)
	UIUtil.CanvasSlotSetAnchors(self.RhythmGameBtnItem, Anchor)
	UIUtil.CanvasSlotSetAlignment(self.RhythmGameBtnItem, _G.UE.FVector2D(0.5, 0.5))
	UIUtil.CanvasSlotSetPosition(self.RhythmGameBtnItem, _G.UE.FVector2D(X, Y))
	self.RhythmGameBtnItem:UpdateNote(NoteData)
end

function StarLightRhythmGameHudPanelView:ShowJudgement(Judgement)
	if Judgement == _G.RhythmGameMgr.Judgement.PERFECT then return self.RhythmGameBtnItem:PlayPerfect() end
	if Judgement == _G.RhythmGameMgr.Judgement.GREAT then return self.RhythmGameBtnItem:PlayGreat() end
	if Judgement == _G.RhythmGameMgr.Judgement.GOOD then return self.RhythmGameBtnItem:PlayGood() end
	if Judgement == _G.RhythmGameMgr.Judgement.MISS then return self.RhythmGameBtnItem:PlayMiss() end
end

function StarLightRhythmGameHudPanelView:PauseGame()
	self.RhythmGameBtnItem:PauseGame()
end

function StarLightRhythmGameHudPanelView:ResumeGame()
	self.RhythmGameBtnItem:ResumeGame()
end

return StarLightRhythmGameHudPanelView