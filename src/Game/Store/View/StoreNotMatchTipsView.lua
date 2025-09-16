
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local StoreMainVM = require("Game/Store/VM/StoreMainVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local TipsUtil = require("Utils/TipsUtil")

---@class StoreNotMatchTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelTips UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field TableViewList UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreNotMatchTipsView = LuaClass(UIView, true)

function StoreNotMatchTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelTips = nil
	--self.PopUpBG = nil
	--self.TableViewList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreNotMatchTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreNotMatchTipsView:OnInit()
	local CallBack = function()
		_G.EventMgr:SendEvent(_G.EventID.StoreHideNotMatchTips)
	end
	self.PopUpBG:SetCallback(self, CallBack)
	self.PopUpBG:SetHideOnClick(false)
	self.AdapterItemList = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
	self.Binders = {
		{"SpecailTipsList", UIBinderUpdateBindableList.New(self, self.AdapterItemList)}
	}
	self.ItemView = nil

end

function StoreNotMatchTipsView:OnDestroy()

end

function StoreNotMatchTipsView:OnShow()
	-- local SpecailTips = StoreMainVM.SpecailTips
	-- self.AdapterItemList:UpdateAll(SpecailTips)
	UIUtil.AdjustTipsPosition(self.PanelTips, self.ItemView, {X = 0, Y = 0})
end

function StoreNotMatchTipsView:OnHide()

end

function StoreNotMatchTipsView:OnRegisterUIEvent()

end

function StoreNotMatchTipsView:OnRegisterGameEvent()

end

function StoreNotMatchTipsView:OnRegisterBinder()
	self:RegisterBinders(StoreMainVM, self.Binders)
end

return StoreNotMatchTipsView