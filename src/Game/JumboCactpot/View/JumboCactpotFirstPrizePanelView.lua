---
--- Author: Administrator
--- DateTime: 2023-09-18 09:28
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local LocalizationUtil = require("Utils/LocalizationUtil")
local JumboCactpotDefine = require("Game/JumboCactpot/JumboCactpotDefine")
local AudioUtil = require("Utils/AudioUtil")
local UIUtil = require("Utils/UIUtil")
---@class JumboCactpotFirstPrizePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FCanvasPanel_73 UFCanvasPanel
---@field ImgText UFImage
---@field PopUpBG CommonPopUpBGView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotFirstPrizePanelView = LuaClass(UIView, true)

function JumboCactpotFirstPrizePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FCanvasPanel_73 = nil
	--self.ImgText = nil
	--self.PopUpBG = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotFirstPrizePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotFirstPrizePanelView:OnInit()

end

function JumboCactpotFirstPrizePanelView:OnDestroy()

end

function JumboCactpotFirstPrizePanelView:OnShow()
	local DefaultPath = "Texture2D'/Game/UI/Texture/Localized/chs/UI_JumboCactpot_Img_Win.UI_JumboCactpot_Img_Win'"
	local LocalIconPath = LocalizationUtil.GetLocalizedAssetPath(DefaultPath)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgText, LocalIconPath)
	local JumboUIAudioPath = JumboCactpotDefine.JumboUIAudioPath
	AudioUtil.LoadAndPlayUISound(JumboUIAudioPath.GetFirstPrize)
	AudioUtil.LoadAndPlayUISound(JumboUIAudioPath.GetFirstPrizeCheer)
	self:RegisterTimer(self.UpdateCountDown, 3, nil, 1, nil)
end

function JumboCactpotFirstPrizePanelView:OnHide()

end

function JumboCactpotFirstPrizePanelView:OnRegisterUIEvent()

end

function JumboCactpotFirstPrizePanelView:OnRegisterGameEvent()

end

function JumboCactpotFirstPrizePanelView:OnRegisterBinder()

end

function JumboCactpotFirstPrizePanelView:UpdateCountDown()
	self:Hide()
end

return JumboCactpotFirstPrizePanelView