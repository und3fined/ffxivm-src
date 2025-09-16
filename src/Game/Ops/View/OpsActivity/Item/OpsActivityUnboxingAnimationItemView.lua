---
--- Author: yutingzhan
--- DateTime: 2024-11-14 16:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")

---@class OpsActivityUnboxingAnimationItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnJumpOver UFButton
---@field PanelJumpOver UFCanvasPanel
---@field TextJumpOver UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsActivityUnboxingAnimationItemView = LuaClass(UIView, true)

function OpsActivityUnboxingAnimationItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnJumpOver = nil
	--self.PanelJumpOver = nil
	--self.TextJumpOver = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsActivityUnboxingAnimationItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsActivityUnboxingAnimationItemView:OnInit()
	self.TextJumpOver:SetText(_G.LSTR(100025))
end

function OpsActivityUnboxingAnimationItemView:OnDestroy()

end

function OpsActivityUnboxingAnimationItemView:OnShow()
	if self.Params == nil then
		return
	end
end

function OpsActivityUnboxingAnimationItemView:OnHide()

end

function OpsActivityUnboxingAnimationItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.BtnJumpOver, self.OnBtnJumpOverClick)
end

function OpsActivityUnboxingAnimationItemView:OnRegisterGameEvent()

end

function OpsActivityUnboxingAnimationItemView:OnRegisterBinder()

end

function OpsActivityUnboxingAnimationItemView:OnBtnJumpOverClick()
	self:Hide()
	UIViewMgr:ShowView(UIViewID.CommonRewardPanel, self.Params)
end

return OpsActivityUnboxingAnimationItemView