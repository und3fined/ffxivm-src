---
--- Author: jamiyang
--- DateTime: 2023-10-08 15:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LoginAvatarMgr = nil

--@Binder
--local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

--@ViewModel
local LoginCreateAvatarVM = require("Game/LoginCreate/LoginCreateAvatarVM")

---@class LoginCreateAppearancePageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRandom UFButton
---@field LoginCreatePreviewPage LoginCreatePreviewPageView
---@field PanelRandom UFCanvasPanel
---@field TableViewLooks UTableView
---@field TextRabdom UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateAppearancePageView = LuaClass(UIView, true)

function LoginCreateAppearancePageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRandom = nil
	--self.LoginCreatePreviewPage = nil
	--self.PanelRandom = nil
	--self.TableViewLooks = nil
	--self.TextRabdom = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateAppearancePageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.LoginCreatePreviewPage)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateAppearancePageView:OnInit()
	LoginAvatarMgr = _G.LoginAvatarMgr
	self.ViewModel = LoginCreateAvatarVM
	self.RoleTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewLooks, self.OnRoleTableSelectChange, true, false)
	self.TextRabdom:SetText(_G.LSTR(980098)) --"随机生成"
end

function LoginCreateAppearancePageView:OnDestroy()

end

function LoginCreateAppearancePageView:OnShow()
	_G.LoginUIMgr:ResetHairBtnState() -- 束发状态
	self.ViewModel:InitViewData()
	self.RoleTableView:SetSelectedIndex(self.ViewModel.RoleTableIndex)
	if self.ViewModel.bCreateNew then
		self.RoleTableView:ScrollToIndex(self.ViewModel.RoleTableIndex)
	end
	-- 相机镜头变化
    LoginAvatarMgr:SetCameraFocus(0, true, true)
	-- 隐藏预览界面的部分UI
	UIUtil.SetIsVisible(self.LoginCreatePreviewPage.LoginRoleBackPage, false)
	--UIUtil.SetIsVisible(self.LoginCreatePreviewPage.TextContent, true)
	self.LoginCreatePreviewPage:HideTextContent()

end

function LoginCreateAppearancePageView:OnHide()
	-- 恢复相机机位
	--_G.LoginAvatarMgr:SetCameraFocus(0, true, false)
end

function LoginCreateAppearancePageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRandom, self.OnClickBtnRandom)

end

function LoginCreateAppearancePageView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.LoginCreatFaceServerReset, self.OnLoginCreatFaceServerReset)

end

function LoginCreateAppearancePageView:OnRegisterBinder()
	local Binders = {
		{ "ListRoleTableVM", UIBinderUpdateBindableList.New(self, self.RoleTableView) }, -- 预设列表
	}

	self:RegisterBinders(self.ViewModel, Binders)

end

function LoginCreateAppearancePageView:OnRoleTableSelectChange(Index, ItemData, ItemView)
	self.ViewModel:UpdateRoleTableSelected(Index)
	_G.ObjectMgr:CollectGarbage(false)
end

function LoginCreateAppearancePageView:OnClickBtnRandom()
	local function NewComformCallback()
		LoginAvatarMgr:SetRandomAvatar()
		LoginAvatarMgr:RefreshPlayerAvatarFace()
		self.ViewModel:SetPlayerCreate(true)
		self.ViewModel:AddRoleList()
		self.RoleTableView:SetSelectedIndex(self.ViewModel.RoleTableIndex)
		self.RoleTableView:ScrollToIndex(self.ViewModel.RoleTableIndex)
	end
	local Content = _G.LSTR(980101)
	_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, _G.LSTR(980022), Content, NewComformCallback, nil, _G.LSTR(980007), _G.LSTR(980035), nil)
	--self.RoleTableView:CancelSelected()
	_G.ObjectMgr:CollectGarbage(false)
end

function LoginCreateAppearancePageView:OnLoginCreatFaceServerReset(bTribeGender)
	self:OnShow()
end

return LoginCreateAppearancePageView