---
--- Author: Administrator
--- DateTime: 2025-03-19 14:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class PersonlnfoSetTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FormerNameSizeBox USizeBox
---@field PopUpBG CommonPopUpBGView
---@field TableViewName UTableView
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonlnfoSetTipsView = LuaClass(UIView, true)

function PersonlnfoSetTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FormerNameSizeBox = nil
	--self.PopUpBG = nil
	--self.TableViewName = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonlnfoSetTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	-- self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonlnfoSetTipsView:OnInit()
	self.AdpTableViewBtns = UIAdapterTableView.CreateAdapter(self, self.TableViewName, self.OnSeltChgEnt, true)
	
	self.Binders = {
		{ "BtnVMList", UIBinderUpdateBindableList.New(self, self.AdpTableViewBtns) },
	}
end

function PersonlnfoSetTipsView:OnDestroy()

end

function PersonlnfoSetTipsView:OnShow()
	
end

function PersonlnfoSetTipsView:OnHide()

end

function PersonlnfoSetTipsView:OnRegisterUIEvent()

end

function PersonlnfoSetTipsView:OnRegisterGameEvent()

end

function PersonlnfoSetTipsView:OnRegisterBinder()
	self:RegisterBinders(_G.PersonInfoSetTipsVM, self.Binders)
end

function PersonlnfoSetTipsView:UpdateView(DataTable)
	-- self:UnRegisterAllBinder()
	_G.PersonInfoSetTipsVM:UpdateVM(DataTable)
	-- self:RegisterBinders(_G.PersonInfoSetTipsVM, self.Binders)
end

function PersonlnfoSetTipsView:OnSeltChgEnt(Idx, ItemVM)
	if ItemVM.Callback then
		ItemVM.Callback()
	end

	-- self:Hide()
end

return PersonlnfoSetTipsView