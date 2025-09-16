---
--- Author: bowxiong
--- DateTime: 2025-03-11 19:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GoldSaucerMiniGameMgr = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameMgr")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local LSTR = _G.LSTR
local AudioType = GoldSaucerMiniGameDefine.AudioType

---@class GoldSaucerMooglePawShootingTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgLine UFImage
---@field MI_DX_Common_GoldSaucer_1 UFImage
---@field MI_DX_Common_GoldSaucer_3 UFImage
---@field PanelTipsFail UFCanvasPanel
---@field PanelTipsSuccess UFCanvasPanel
---@field TextFail UFTextBlock
---@field TextSuccess UFTextBlock
---@field AnimTipsFail UWidgetAnimation
---@field AnimTipsSuccess UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerMooglePawShootingTipsItemView = LuaClass(UIView, true)

function GoldSaucerMooglePawShootingTipsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgLine = nil
	--self.MI_DX_Common_GoldSaucer_1 = nil
	--self.MI_DX_Common_GoldSaucer_3 = nil
	--self.PanelTipsFail = nil
	--self.PanelTipsSuccess = nil
	--self.TextFail = nil
	--self.TextSuccess = nil
	--self.AnimTipsFail = nil
	--self.AnimTipsSuccess = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerMooglePawShootingTipsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerMooglePawShootingTipsItemView:OnInit()

end

function GoldSaucerMooglePawShootingTipsItemView:OnDestroy()

end

function GoldSaucerMooglePawShootingTipsItemView:OnShow()
	-- 默认加载一次BP默认的多语言  
	self.TextSuccess:SetText(LSTR(270008)) -- 	成功
	self.TextFail:SetText(LSTR(270007)) -- 失败
end

function GoldSaucerMooglePawShootingTipsItemView:OnHide()

end

function GoldSaucerMooglePawShootingTipsItemView:OnRegisterUIEvent()

end

function GoldSaucerMooglePawShootingTipsItemView:OnRegisterGameEvent()

end

function GoldSaucerMooglePawShootingTipsItemView:OnRegisterBinder()

end

function GoldSaucerMooglePawShootingTipsItemView:OnAnimationFinished(_)
	if self.ParentView then
		self.ParentView:HideShootingTips()
	end
end

function GoldSaucerMooglePawShootingTipsItemView:ShowResult(bSuccess)
	if bSuccess then
		self:PlayAnimation(self.AnimTipsSuccess)
	else
		self:PlayAnimation(self.AnimTipsFail)
		GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.MoogleFailTips)
	end
end

function GoldSaucerMooglePawShootingTipsItemView:IsForceGC()
	return true
end

return GoldSaucerMooglePawShootingTipsItemView