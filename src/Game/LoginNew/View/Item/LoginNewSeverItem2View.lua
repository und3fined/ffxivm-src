---
--- Author: richyczhou
--- DateTime: 2024-06-25 09:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

---@class LoginNewSeverItem2View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field LoginNewSever LoginNewSeverItemView
---@field TextState UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewSeverItem2View = LuaClass(UIView, true)

function LoginNewSeverItem2View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.LoginNewSever = nil
	--self.TextState = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewSeverItem2View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.LoginNewSever)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewSeverItem2View:OnInit()

end

function LoginNewSeverItem2View:OnDestroy()

end

function LoginNewSeverItem2View:OnShow()
	local Params = self.Params
	if nil == Params then return end

	---@type ServerStateItemVM
	local ServerStateItemVM = Params.Data
	if nil == ServerStateItemVM then return end

	-- self.TextState:SetText(ServerStateItemVM.Name)
	-- self.LoginNewSever:SetStateIcon(ServerStateItemVM.Icon)
	self:SetSeverContent(ServerStateItemVM.Name, ServerStateItemVM.Icon)
end

function LoginNewSeverItem2View:SetSeverContent(StateName, Icon)
	self.TextState:SetText(StateName)
	self.LoginNewSever:SetStateIcon(Icon)
end

function LoginNewSeverItem2View:OnHide()

end

function LoginNewSeverItem2View:OnRegisterUIEvent()

end

function LoginNewSeverItem2View:OnRegisterGameEvent()

end

function LoginNewSeverItem2View:OnRegisterBinder()

end

--function LoginNewSeverItem2View:OnSelectChanged(IsSelected)
--	local Params = self.Params
--	if nil == Params then return end
--
--	---@type ServerStateItemVM
--	local ViewModel = Params.Data
--	if nil == ViewModel then return end
--
--	_G.FLOG_INFO("LoginNewSeverItem2View Name:%s", ViewModel.Name)
--end

return LoginNewSeverItem2View