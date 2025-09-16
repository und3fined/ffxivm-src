---
--- Author: richyczhou
--- DateTime: 2025-03-12 23:07
--- Description:
---

local UIView = require("UI/UIView")
local LoginMgr = require("Game/Login/LoginMgr")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local FLOG_INFO = _G.FLOG_INFO
local LSTR = _G.LSTR

---@class SettingsDeregisterAccountSmallWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn CommBtnLView
---@field Comm2FrameS_UIBP Comm2FrameSView
---@field RichText URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SettingsDeregisterAccountSmallWinView = LuaClass(UIView, true)

function SettingsDeregisterAccountSmallWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.Comm2FrameS_UIBP = nil
	--self.RichText = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SettingsDeregisterAccountSmallWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Btn)
	self:AddSubView(self.Comm2FrameS_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SettingsDeregisterAccountSmallWinView:OnInit()

end

function SettingsDeregisterAccountSmallWinView:OnDestroy()

end

function SettingsDeregisterAccountSmallWinView:OnShow()
	FLOG_INFO("[SettingsDeregisterAccountSmallWinView:OnShow]")
	--470133 账号注销
	self.Comm2FrameS_UIBP:SetTitleText(LSTR(470133))
	--470151 账号注销需要您退出或删除所有角色的社交关系，请等待检查中
	self.RichText:SetText(LSTR(470151))
	--470158 取消注销
	self.Btn.TextContent:SetText(LSTR(470158))
	self.Btn:SetIsNormal(true)
end

function SettingsDeregisterAccountSmallWinView:OnHide()
	FLOG_INFO("[SettingsDeregisterAccountSmallWinView:OnHide]")

end

function SettingsDeregisterAccountSmallWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickCancelBtn)
end

function SettingsDeregisterAccountSmallWinView:OnRegisterGameEvent()

end

function SettingsDeregisterAccountSmallWinView:OnRegisterBinder()

end

function SettingsDeregisterAccountSmallWinView:OnClickCancelBtn()
	FLOG_INFO("[SettingsDeregisterAccountSmallWinView:OnClickCancelBtn]")
	LoginMgr.bCancelAccountCancellation = true
	self:Hide()
end

return SettingsDeregisterAccountSmallWinView