---
--- Author: Administrator
--- DateTime: 2024-10-31 18:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

---@class PersonlnfoFormerNameTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewName UTableView
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonlnfoFormerNameTipsView = LuaClass(UIView, true)

function PersonlnfoFormerNameTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewName = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonlnfoFormerNameTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonlnfoFormerNameTipsView:OnInit()
	self.TabsViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewName)
end

function PersonlnfoFormerNameTipsView:OnDestroy()

end

function PersonlnfoFormerNameTipsView:OnShow()
	local Params = self.Params
	if Params.InTargetWidget then
		local TipsUtil = require("Utils/TipsUtil")
		TipsUtil.AdjustTipsPosition(self.FormerNameSizeBox, Params.InTargetWidget, nil, Params.Alignment)
	end

	self.TextFormerName:SetText(_G.LSTR(620106))
	-- local Data = {
	-- 	[1] = "Test1",
	-- 	[2] = "Test2",
	-- 	[3] = "Test3",
	-- 	[4] = "Test5",
	-- 	[5] = "Test4",
	-- 	[6] = "Test7",
	-- 	[7] = "Test0",
	-- 	[8] = "Test01"
	-- }

	local HistoryNameData = Params.NameData or {}
	self.TabsViewAdapter:UpdateAll(HistoryNameData)
end

function PersonlnfoFormerNameTipsView:OnClickBg()
	self:Hide()
end

function PersonlnfoFormerNameTipsView:OnHide()

end

function PersonlnfoFormerNameTipsView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BgBtn, self.OnClickBg)
end

function PersonlnfoFormerNameTipsView:OnRegisterGameEvent()

end

function PersonlnfoFormerNameTipsView:OnRegisterBinder()

end

return PersonlnfoFormerNameTipsView