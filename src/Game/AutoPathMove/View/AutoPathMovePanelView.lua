---
--- Author: zerodeng
--- DateTime: 2024-07-01 14:13
--- Description:自动寻路提示，以及中断寻路提示
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local AutoMoveTargetType = require("Define/AutoMoveTargetType")

---@class AutoPathMovePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btnrestore UFButton
---@field ImgMovingIcon UFImage
---@field ImgProbar URadialImage
---@field PanelContinue UFCanvasPanel
---@field PanelMoving UFCanvasPanel
---@field TextContinue UFTextBlock
---@field TextMoving UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AutoPathMovePanelView = LuaClass(UIView, true)

function AutoPathMovePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btnrestore = nil
	--self.ImgMovingIcon = nil
	--self.ImgProbar = nil
	--self.PanelContinue = nil
	--self.PanelMoving = nil
	--self.TextContinue = nil
	--self.TextMoving = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AutoPathMovePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AutoPathMovePanelView:OnInit()
	local PreContent = _G.LSTR(1590002)
	self.SysbolList = {
		PreContent..".",
		PreContent.."..",
		PreContent.."..."
	}
	self.SysbolNum = #self.SysbolList
	self.TimeIndex = 0

	self.TextContinue:SetText(_G.LSTR(1590001))
end

function AutoPathMovePanelView:OnDestroy()

end

function AutoPathMovePanelView:OnShow()
	if (self.Params ~= nil and self.Params.IsAutoPathMove ~= nil
		and self.Params.IsAutoPathMove) then
		UIUtil.SetIsVisible(self.PanelContinue, false)
		UIUtil.SetIsVisible(self.PanelMoving, true)

		--目标类型		
		if (self.Params.TargetType == AutoMoveTargetType.Task) then			
			UIUtil.ImageSetBrushFromAssetPath(self.ImgMovingIcon, "PaperSprite'/Game/UI/Atlas/AutoPathMove/Frames/UI_AutoPathMove_Icon_Track02_png.UI_AutoPathMove_Icon_Track02_png'")
		else
			UIUtil.ImageSetBrushFromAssetPath(self.ImgMovingIcon, "PaperSprite'/Game/UI/Atlas/AutoPathMove/Frames/UI_AutoPathMove_Icon_Track01_png.UI_AutoPathMove_Icon_Track01_png'")
		end

		self:RegisterTimer(self.OnTimer, 0, 1, 0)
	elseif (self.Params ~= nil and self.Params.ResumeMove ~= nil) then		
		UIUtil.SetIsVisible(self.PanelContinue, true)
		UIUtil.SetIsVisible(self.PanelMoving, false)

		self.ShowTime = self.Params.ShowTime * 1000
		self.StartTime = _G.TimeUtil.GetLocalTimeMS()
		self:RegisterTimer(self.OnPercentSetTimer, 0, 0.01, 0)
	end
end

function AutoPathMovePanelView:OnHide()
	self:UnRegisterAllTimer()
end

function AutoPathMovePanelView:OnRegisterUIEvent()	
	UIUtil.AddOnClickedEvent(self,  self.Btnrestore, self.OnBtnResume)	
end

function AutoPathMovePanelView:OnRegisterGameEvent()
	--self:RegisterGameEvent(EventID.StartAutoPathMove, self.OnStartAutoPathMove)
	self:RegisterGameEvent(EventID.StopAutoPathMove, self.OnStopAutoPathMove)
end

function AutoPathMovePanelView:OnRegisterBinder()

end

function AutoPathMovePanelView:OnBtnResume()
	self:Hide()

	--重新发起寻路
	_G.AutoPathMoveMgr:ResumeAutoPathMove()
end

function AutoPathMovePanelView:OnTimer()
	self.TimeIndex = self.TimeIndex + 1
	local Index = math.fmod(self.TimeIndex, self.SysbolNum) + 1
	self.TextMoving:SetText(self.SysbolList[Index])
	_G.EventMgr:SendEvent(EventID.MapAutoPathProgressUpdate)
end

function AutoPathMovePanelView:OnPercentSetTimer()
	local DiffTime = _G.TimeUtil.GetLocalTimeMS() - self.StartTime
	local Precent = 1 - DiffTime / self.ShowTime
		
	self.ImgProbar:SetPercent(math.clamp(Precent, 0, 1))

	if (Precent <= 0) then
		self:Hide()
	end
end

--自动寻路结束
function AutoPathMovePanelView:OnStopAutoPathMove()
	self:Hide()
end

return AutoPathMovePanelView