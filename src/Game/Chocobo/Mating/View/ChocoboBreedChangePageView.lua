---
--- Author: Administrator
--- DateTime: 2024-01-02 14:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

---@class ChocoboBreedChangePageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRandom UFButton
---@field BtnSelect CommBtnMView
---@field CommSidebarFrameS_UIBP CommSidebarFrameSView
---@field DropDownSort CommDropDownListView
---@field TableViewChocobo UTableView
---@field AnimRefresh UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboBreedChangePageView = LuaClass(UIView, true)

function ChocoboBreedChangePageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRandom = nil
	--self.BtnSelect = nil
	--self.CommSidebarFrameS_UIBP = nil
	--self.DropDownSort = nil
	--self.TableViewChocobo = nil
	--self.AnimRefresh = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboBreedChangePageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnSelect)
	self:AddSubView(self.CommSidebarFrameS_UIBP)
	self:AddSubView(self.DropDownSort)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboBreedChangePageView:OnInit()

end

function ChocoboBreedChangePageView:OnDestroy()

end

function ChocoboBreedChangePageView:OnShow()
	-- LSTR string: 更  换
	self.BtnSelect:SetText(_G.LSTR(420003))
end

function ChocoboBreedChangePageView:OnHide()

end

function ChocoboBreedChangePageView:OnRegisterUIEvent()

end

function ChocoboBreedChangePageView:OnRegisterGameEvent()

end

function ChocoboBreedChangePageView:OnRegisterBinder()

end

function ChocoboBreedChangePageView:PlayAnimRefresh()
	self:PlayAnimation(self.AnimRefresh)
end

return ChocoboBreedChangePageView