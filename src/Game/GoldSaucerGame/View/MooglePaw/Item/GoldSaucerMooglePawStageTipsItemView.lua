---
--- Author: Administrator
--- DateTime: 2024-02-28 17:31
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GoldSaucerMiniGameMgr = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameMgr")
local LSTR = _G.LSTR

---@class GoldSaucerMooglePawStageTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelBallBlue UFCanvasPanel
---@field TextTips UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerMooglePawStageTipsItemView = LuaClass(UIView, true)

function GoldSaucerMooglePawStageTipsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelBallBlue = nil
	--self.TextTips = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerMooglePawStageTipsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerMooglePawStageTipsItemView:InitConstStringInfo()
	self.TextTips:SetText(LSTR(360032))
end

function GoldSaucerMooglePawStageTipsItemView:OnInit()
	self:InitConstStringInfo()
end

function GoldSaucerMooglePawStageTipsItemView:OnDestroy()

end

function GoldSaucerMooglePawStageTipsItemView:OnShow()
	local MiniGameInst = GoldSaucerMiniGameMgr.CurMiniGameInst
	if MiniGameInst == nil then
		return
	end
	local DefineCfg = MiniGameInst.DefineCfg
	if not DefineCfg.bNeedStageTipsAutoHide then -- 在配置里些是否需要自动隐藏
		return
	end
	self:RegisterTimer(function()
		UIUtil.SetIsVisible(self, false)
	end, DefineCfg.HideTipTime, 0, 1)
end

function GoldSaucerMooglePawStageTipsItemView:OnHide()
	
end

function GoldSaucerMooglePawStageTipsItemView:OnRegisterUIEvent()

end

function GoldSaucerMooglePawStageTipsItemView:OnRegisterGameEvent()

end

function GoldSaucerMooglePawStageTipsItemView:OnRegisterBinder()

end

return GoldSaucerMooglePawStageTipsItemView