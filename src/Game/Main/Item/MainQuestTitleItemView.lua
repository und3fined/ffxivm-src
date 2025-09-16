---
--- Author: lydianwang
--- DateTime: 2023-02-20 15:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UE = _G.UE
local DefaultScale = UE.FVector2D(1, 1)

---@class MainQuestTitleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconTask UFImage
---@field MI_DX_Common_Pathfind_1 UFImage
---@field MI_DX_Common_Pathfind_2 UFImage
---@field PanelPathfind UFCanvasPanel
---@field RichTextTitle URichTextBox
---@field AnimNewMission UWidgetAnimation
---@field AnimPathfindOver UWidgetAnimation
---@field AnimPathfindStart UWidgetAnimation
---@field AnimTitleSelect UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainQuestTitleItemView = LuaClass(UIView, true)

function MainQuestTitleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconTask = nil
	--self.MI_DX_Common_Pathfind_1 = nil
	--self.MI_DX_Common_Pathfind_2 = nil
	--self.PanelPathfind = nil
	--self.RichTextTitle = nil
	--self.AnimNewMission = nil
	--self.AnimPathfindOver = nil
	--self.AnimPathfindStart = nil
	--self.AnimTitleSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainQuestTitleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainQuestTitleItemView:OnInit()

end

function MainQuestTitleItemView:OnDestroy()

end

function MainQuestTitleItemView:OnShow()
	self.IconTask:SetRenderScale(DefaultScale)
	self.RichTextTitle:SetRenderOpacity(1)
end

function MainQuestTitleItemView:OnHide()

end

function MainQuestTitleItemView:OnActive()
	self.IconTask:SetRenderScale(DefaultScale)
	self.RichTextTitle:SetRenderOpacity(1)
end

function MainQuestTitleItemView:OnRegisterUIEvent()

end

function MainQuestTitleItemView:OnRegisterGameEvent()

end

function MainQuestTitleItemView:OnRegisterBinder()

end

---@param IconPath string
---@param Title string
function MainQuestTitleItemView:SetContent(IconPath, Title)
	UIUtil.ImageSetBrushFromAssetPath(self.IconTask, IconPath)
	self.RichTextTitle:SetText(Title or "")
end

---@param bPlay boolean
function MainQuestTitleItemView:PlayAnimNew(bPlay)
	if bPlay ~= false then
		self:PlayAnimation(self.AnimNewMission)
	end
end

---@param bPlay boolean
function MainQuestTitleItemView:PlayAnimTrack(bPlay)
	if bPlay ~= false then
		self:PlayAnimation(self.AnimNewMission)
	end

	-- 呼吸框动效
	--if self.AnimBreath and self.AnimBreathHidden then
	--	self:PlayAnimation((bPlay ~= false) and self.AnimBreath or self.AnimBreathHidden)
	--end
end

function MainQuestTitleItemView:SwitchAutoFindStatus(IsOn)
	if IsOn then
		self:StopAnimation(self.AnimPathfindOver)
        self:PlayAnimation(self.AnimPathfindStart)
		UIUtil.SetIsVisible(self.PanelPathfind, true)
		UIUtil.SetIsVisible(self.MI_DX_Common_Pathfind_2, true)
		self.IsPlayingFindPathAnim = true
	else
		if self.IsPlayingFindPathAnim then
			self:StopAnimation(self.AnimPathfindStart)
			self:PlayAnimation(self.AnimPathfindOver)
			self.IsPlayingFindPathAnim = false
		end
	end
end


return MainQuestTitleItemView