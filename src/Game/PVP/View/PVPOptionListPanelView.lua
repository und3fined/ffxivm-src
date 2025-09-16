---
--- Author: Administrator
--- DateTime: 2024-11-18 15:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PVPOptionItemVM = require ("Game/PVP/VM/PVPOptionItemVM")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

---@class PVPOptionListPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field TableViewList UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPOptionListPanelView = LuaClass(UIView, true)

function PVPOptionListPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.TableViewList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPOptionListPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPOptionListPanelView:OnInit()
	self.OptionList = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
end

function PVPOptionListPanelView:OnDestroy()

end

function PVPOptionListPanelView:OnShow()
	local Params = self.Params
	if Params == nil then return end

	local Title, OptionList = Params.Title, Params.OptionList
	if Title == nil or OptionList == nil then return end

	self.BG:SetTitleText(Title)

	local VMList = {}
	for _, Option in pairs(OptionList) do
		local VM = PVPOptionItemVM.New()
		VM:UpdateVM(Option)
		table.insert(VMList, VM)
	end
	self.OptionList:UpdateAll(VMList)
end

function PVPOptionListPanelView:OnHide()

end

function PVPOptionListPanelView:OnRegisterUIEvent()

end

function PVPOptionListPanelView:OnRegisterGameEvent()

end

function PVPOptionListPanelView:OnRegisterBinder()

end

return PVPOptionListPanelView