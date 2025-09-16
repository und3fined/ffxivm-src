---
--- Author: zimuyi
--- DateTime: 2023-06-26 15:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EquipmentVM = require("Game/Equipment/VM/EquipmentVM")

---@class RoleProfPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PopUpBG CommonPopUpBGView
---@field ToggleJobPage ProfessionToggleJobPageView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local RoleProfPageView = LuaClass(UIView, true)

function RoleProfPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PopUpBG = nil
	--self.ToggleJobPage = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function RoleProfPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	self:AddSubView(self.ToggleJobPage)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function RoleProfPageView:OnInit()

end

function RoleProfPageView:OnDestroy()

end

function RoleProfPageView:OnShow()
	self.ToggleJobPage:SetParams({ bShowBtnFold = true })
	self.ToggleJobPage.Hide = self.HideSelf
	self.PopUpBG.Hide = self.HideSelf
	self.TextTitle:SetText(LSTR(1050174))
end

function RoleProfPageView:HideSelf()
	EquipmentVM.bShowProfDetail = false
end

function RoleProfPageView:OnHide()

end

function RoleProfPageView:OnRegisterUIEvent()

end

function RoleProfPageView:OnRegisterGameEvent()
end

function RoleProfPageView:OnRegisterBinder()

end

return RoleProfPageView