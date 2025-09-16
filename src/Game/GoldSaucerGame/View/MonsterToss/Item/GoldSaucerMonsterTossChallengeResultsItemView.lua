---
--- Author: Administrator
--- DateTime: 2024-03-01 10:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class GoldSaucerMonsterTossChallengeResultsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgMonsterFail UFImage
---@field ImgMonsterNormal UFImage
---@field PanelFail UFCanvasPanel
---@field PanelMianResult UFCanvasPanel
---@field PanelSuccess UFCanvasPanel
---@field PanelTimesup UFCanvasPanel
---@field TextFail UFTextBlock
---@field TextSuccess UFTextBlock
---@field TextTimesup UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerMonsterTossChallengeResultsItemView = LuaClass(UIView, true)

function GoldSaucerMonsterTossChallengeResultsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgMonsterFail = nil
	--self.ImgMonsterNormal = nil
	--self.PanelFail = nil
	--self.PanelMianResult = nil
	--self.PanelSuccess = nil
	--self.PanelTimesup = nil
	--self.TextFail = nil
	--self.TextSuccess = nil
	--self.TextTimesup = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerMonsterTossChallengeResultsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerMonsterTossChallengeResultsItemView:OnInit()

end

function GoldSaucerMonsterTossChallengeResultsItemView:OnDestroy()

end

function GoldSaucerMonsterTossChallengeResultsItemView:OnShow()
	local LSTR = _G.LSTR
	self.TextTimesup:SetText(LSTR(250023)) -- 时间结束
	self.TextSuccess:SetText(LSTR(250024)) -- 挑战成功
	self.TextFail:SetText(LSTR(250025)) -- 挑战失败

end

function GoldSaucerMonsterTossChallengeResultsItemView:OnHide()

end

function GoldSaucerMonsterTossChallengeResultsItemView:OnRegisterUIEvent()

end

function GoldSaucerMonsterTossChallengeResultsItemView:OnRegisterGameEvent()

end

function GoldSaucerMonsterTossChallengeResultsItemView:OnRegisterBinder()

end

return GoldSaucerMonsterTossChallengeResultsItemView