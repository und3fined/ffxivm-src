---
--- Author: Administrator
--- DateTime: 2024-01-02 14:12
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

---@class ChocoboBorrowChangePageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRandom UFButton
---@field CommSidebarFrameS_UIBP CommSidebarFrameSView
---@field DropDownSort CommDropDownListView
---@field TableViewChocobo UTableView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimRefresh UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboBorrowChangePageView = LuaClass(UIView, true)

function ChocoboBorrowChangePageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRandom = nil
	--self.CommSidebarFrameS_UIBP = nil
	--self.DropDownSort = nil
	--self.TableViewChocobo = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimRefresh = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboBorrowChangePageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommSidebarFrameS_UIBP)
	self:AddSubView(self.DropDownSort)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboBorrowChangePageView:OnInit()

end

function ChocoboBorrowChangePageView:OnDestroy()

end

function ChocoboBorrowChangePageView:OnShow()
	self:InitConstInfo()
end

function ChocoboBorrowChangePageView:InitConstInfo()
	-- LSTR string: 租借陆行鸟
	self.CommSidebarFrameS_UIBP.CommonTitle:SetTextTitleName(_G.LSTR(420034))
end

function ChocoboBorrowChangePageView:OnHide()

end

function ChocoboBorrowChangePageView:OnRegisterUIEvent()
end

function ChocoboBorrowChangePageView:OnRegisterGameEvent()

end

function ChocoboBorrowChangePageView:OnRegisterBinder()

end

--function ChocoboBorrowChangePageView:PlayAnimIn()
--	self:PlayAnimation(self.AnimIn)
--end
--
--function ChocoboBorrowChangePageView:PlayAnimOut()
--	self:PlayAnimation(self.AnimOut)
--end

function ChocoboBorrowChangePageView:PlayAnimRefresh()
	self:PlayAnimation(self.AnimRefresh)
end

return ChocoboBorrowChangePageView