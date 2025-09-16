---
--- Author: richyczhou
--- DateTime: 2025-03-12 23:07
--- Description:
---

local AccountRoleItemVM = require("Game/Settings/VM/AccountRoleItemVM")
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local LoginMgr = require("Game/Login/LoginMgr")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBindableList = require("UI/UIBindableList")

local FLOG_INFO = _G.FLOG_INFO

---@class SettingsDeregisterAccountBigWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm2FrameL_UIBP Comm2FrameLView
---@field RichTextHint URichTextBox
---@field TableViewList UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SettingsDeregisterAccountBigWinView = LuaClass(UIView, true)

function SettingsDeregisterAccountBigWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm2FrameL_UIBP = nil
	--self.RichTextHint = nil
	--self.TableViewList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SettingsDeregisterAccountBigWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameL_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SettingsDeregisterAccountBigWinView:OnInit()
	FLOG_INFO("[SettingsDeregisterAccountBigWinView:OnInit]")
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList)

	--self.Binders = {
	--	{ "CheckList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
	--}

	self.AccountCheckList = UIBindableList.New(AccountRoleItemVM)
end

function SettingsDeregisterAccountBigWinView:OnDestroy()

end

function SettingsDeregisterAccountBigWinView:OnShow()
	FLOG_INFO("[SettingsDeregisterAccountBigWinView:OnShow]")
	--470133 账号注销
	self.Comm2FrameL_UIBP:SetTitleText(LSTR(470133))
	--470152 账号注销需要您退出或删除所有角色的社交关系，检测到您以下角色尚未满足条件，请处理后重试：
	self.RichTextHint:SetText(LSTR(470152))

	local AllAccountInfos = LoginMgr.AllAccountInfos
	--self.TableViewAdapter:UpdateAll(AllAccountInfos)
	self.AccountCheckList:UpdateByValues(AllAccountInfos)
	self.TableViewAdapter:UpdateAll(self.AccountCheckList)
end

function SettingsDeregisterAccountBigWinView:OnHide()

end

function SettingsDeregisterAccountBigWinView:OnRegisterUIEvent()

end

function SettingsDeregisterAccountBigWinView:OnRegisterGameEvent()

end

function SettingsDeregisterAccountBigWinView:OnRegisterBinder()

end

return SettingsDeregisterAccountBigWinView