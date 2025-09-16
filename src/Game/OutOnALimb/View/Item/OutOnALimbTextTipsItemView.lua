---
--- Author: alexchen
--- DateTime: 2023-11-09 16:44
--- Description:孤树无援砍树结果tips
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local MiniGameProgressType = GoldSaucerMiniGameDefine.MiniGameProgressType

local FLOG_ERROR = _G.FLOG_ERROR
local LSTR = _G.LSTR

---@class OutOnALimbTextTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BluePanel UFCanvasPanel
---@field GreenPanel UFCanvasPanel
---@field ImgLineBlue UFImage
---@field ImgLineGreen UFImage
---@field ImgLineRed UFImage
---@field ImgLineYellow UFImage
---@field RedPanel UFCanvasPanel
---@field TextTipsBlue UFTextBlock
---@field TextTipsGreen UFTextBlock
---@field TextTipsRed UFTextBlock
---@field TextTipsYellow UFTextBlock
---@field TextTitleBlue UFTextBlock
---@field TextTitleGreen UFTextBlock
---@field TextTitleRed UFTextBlock
---@field TextTitleYellow UFTextBlock
---@field YellowPanel UFCanvasPanel
---@field AnimInBlue UWidgetAnimation
---@field AnimInGreen UWidgetAnimation
---@field AnimInRed UWidgetAnimation
---@field AnimInYellow UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OutOnALimbTextTipsItemView = LuaClass(UIView, true)

function OutOnALimbTextTipsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BluePanel = nil
	--self.GreenPanel = nil
	--self.ImgLineBlue = nil
	--self.ImgLineGreen = nil
	--self.ImgLineRed = nil
	--self.ImgLineYellow = nil
	--self.RedPanel = nil
	--self.TextTipsBlue = nil
	--self.TextTipsGreen = nil
	--self.TextTipsRed = nil
	--self.TextTipsYellow = nil
	--self.TextTitleBlue = nil
	--self.TextTitleGreen = nil
	--self.TextTitleRed = nil
	--self.TextTitleYellow = nil
	--self.YellowPanel = nil
	--self.AnimInBlue = nil
	--self.AnimInGreen = nil
	--self.AnimInRed = nil
	--self.AnimInYellow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OutOnALimbTextTipsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OutOnALimbTextTipsItemView:InitConstStringInfo()
	self.TextTitleYellow:SetText(LSTR(370002))
	self.TextTipsYellow:SetText(LSTR(370003))
	self.TextTitleRed:SetText(LSTR(370008))
	self.TextTipsRed:SetText(LSTR(370009))
	self.TextTitleBlue:SetText(LSTR(370006))
	self.TextTipsBlue:SetText(LSTR(370007))
	self.TextTitleGreen:SetText(LSTR(370004))
	self.TextTipsGreen:SetText(LSTR(370005))
end

function OutOnALimbTextTipsItemView:OnInit()
	self.CallBack = nil
	self:InitConstStringInfo()
end

function OutOnALimbTextTipsItemView:OnDestroy()

end

function OutOnALimbTextTipsItemView:OnShow()
	
end

function OutOnALimbTextTipsItemView:OnHide()

end

function OutOnALimbTextTipsItemView:OnRegisterUIEvent()

end

function OutOnALimbTextTipsItemView:OnRegisterGameEvent()

end

function OutOnALimbTextTipsItemView:OnRegisterBinder()

end

function OutOnALimbTextTipsItemView:UpdateMainPanelData(ViewModel, CallBack)
	self.CallBack = CallBack
	if ViewModel == nil then
		return
	end

	UIUtil.SetIsVisible(self.BluePanel, false)
	UIUtil.SetIsVisible(self.YellowPanel, false)
	UIUtil.SetIsVisible(self.RedPanel, false)
	UIUtil.SetIsVisible(self.GreenPanel, false)

	local MiniGameInst = ViewModel.MiniGame
	if MiniGameInst == nil then
		return
	end

	local LatestProgressLv = MiniGameInst:GetLatestProgressLv()
    if LatestProgressLv ~= nil then
        if LatestProgressLv == MiniGameProgressType.Perfect then
			UIUtil.SetIsVisible(self.YellowPanel, true)
			self:PlayAnimation(self.AnimInYellow)
        elseif LatestProgressLv == MiniGameProgressType.Nice then
			UIUtil.SetIsVisible(self.GreenPanel, true)
			self:PlayAnimation(self.AnimInGreen)
        elseif LatestProgressLv == MiniGameProgressType.Good then
			UIUtil.SetIsVisible(self.BluePanel, true)
			self:PlayAnimation(self.AnimInBlue)
        elseif LatestProgressLv == MiniGameProgressType.Bad then
			UIUtil.SetIsVisible(self.RedPanel, true)
			self:PlayAnimation(self.AnimInRed)
        else
            FLOG_ERROR("OutOnALimbView:OnMiniGameProgressChanged do not have the MiniGameProgressType")
        end
    end
end

--- 动画结束统一回调
function OutOnALimbTextTipsItemView:OnAnimationFinished(Animation)
	local AnimEndCall = self.CallBack
	if Animation and AnimEndCall then
		AnimEndCall()
	end
end

return OutOnALimbTextTipsItemView