---
--- Author: Administrator
--- DateTime: 2024-09-26 19:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local PersonPortraitHeadVM
local PersonPortraitHeadMgr

---@class PersonInfoHistoryHeadWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field TableViewDefault1 UTableView
---@field TableViewDefault2 UTableView
---@field TextPlayer UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoHistoryHeadWinView = LuaClass(UIView, true)

function PersonInfoHistoryHeadWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm2FrameM_UIBP = nil
	--self.TableViewDefault1 = nil
	--self.TableViewDefault2 = nil
	--self.TextPlayer = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoHistoryHeadWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoHistoryHeadWinView:OnInit()
	self.AdpTableHeadCust1 = UIAdapterTableView.CreateAdapter(self, self.TableViewDefault1)
	self.AdpTableHeadCust2 = UIAdapterTableView.CreateAdapter(self, self.TableViewDefault2)

	PersonPortraitHeadVM = _G.PersonPortraitHeadVM
	PersonPortraitHeadMgr = _G.PersonPortraitHeadMgr

	self.Binders = 
	{
		{ "IsShow8HistoryHead", 	UIBinderSetIsVisible.New(self, self.TableViewDefault1, true) },
		{ "IsShow8HistoryHead", 	UIBinderSetIsVisible.New(self, self.TableViewDefault2) },

		{ "HeadHistoryHeadVMList", 	UIBinderUpdateBindableList.New(self, self.AdpTableHeadCust1) },
		{ "HeadHistoryHeadVMList", 	UIBinderUpdateBindableList.New(self, self.AdpTableHeadCust2) },
	}

	self.Comm2FrameM_UIBP.FText_Title:SetText(LSTR(960042))
	self.TextPlayer:SetText(LSTR(960043))
end

function PersonInfoHistoryHeadWinView:OnDestroy()

end

function PersonInfoHistoryHeadWinView:OnShow()

end

function PersonInfoHistoryHeadWinView:OnHide()

end

function PersonInfoHistoryHeadWinView:OnRegisterUIEvent()

end

function PersonInfoHistoryHeadWinView:OnRegisterGameEvent()

end

function PersonInfoHistoryHeadWinView:OnRegisterBinder()
	self:RegisterBinders(PersonPortraitHeadVM, self.Binders)
end

return PersonInfoHistoryHeadWinView