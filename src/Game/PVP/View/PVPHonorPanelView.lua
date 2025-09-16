---
--- Author: Administrator
--- DateTime: 2024-11-18 11:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local PVPHonorCfg = require("TableCfg/PVPHonorCfg")
local PVPHonorItemVM = require ("Game/PVP/VM/PVPHonorItemVM")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

---@class PVPHonorPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field PanelMultiLevel UFCanvasPanel
---@field SingleLevelHonorItem PVPHonorItemView
---@field TableViewHonor UTableView
---@field TextHonorDesc UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPHonorPanelView = LuaClass(UIView, true)

function PVPHonorPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.PanelMultiLevel = nil
	--self.SingleLevelHonorItem = nil
	--self.TableViewHonor = nil
	--self.TextHonorDesc = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPHonorPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.SingleLevelHonorItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPHonorPanelView:OnInit()
	self.HonorList = UIAdapterTableView.CreateAdapter(self, self.TableViewHonor)
end

function PVPHonorPanelView:OnDestroy()

end

function PVPHonorPanelView:OnShow()
	local ID = self.Params and self.Params.HonorID
	if ID == nil then return end

    local Cfg = PVPHonorCfg:FindCfgByKey(ID)
	if Cfg == nil then return end

 	local Cfgs = PVPHonorCfg:FindCfgsByType(Cfg.Type)
	if Cfgs == nil then return end

	table.sort(Cfgs, function(Cfg1, Cfg2)
		if Cfg1 and Cfg2 then
			if Cfg1.Level ~= Cfg2.Level then
				return Cfg1.Level < Cfg2.Level
			end

			if Cfg1.ID ~= Cfg2.ID then
				return Cfg1.ID < Cfg2.ID
			end
		end
		return false
	end)

	local DataList = {}
	for _, Cfg in pairs(Cfgs) do
		local VM = PVPHonorItemVM.New()
		VM:UpdateVM(Cfg)
		table.insert(DataList, VM)
	end
	local IsMultiLevel = #DataList > 1

	if IsMultiLevel then
		self.HonorList:UpdateAll(DataList)
	else
		self.SingleLevelHonorItem:SetParams({ Data = DataList[1] })
	end

	local TypeText = ProtoEnumAlias.GetAlias(ProtoRes.Game.pvp_badgetype, Cfg.Type)
	self.BG:SetTitleText(TypeText)
	self.TextHonorDesc:SetText(Cfg.Description)
	UIUtil.SetIsVisible(self.PanelMultiLevel, IsMultiLevel)
	UIUtil.SetIsVisible(self.SingleLevelHonorItem, not IsMultiLevel)
end

function PVPHonorPanelView:OnHide()

end

function PVPHonorPanelView:OnRegisterUIEvent()

end

function PVPHonorPanelView:OnRegisterGameEvent()

end

function PVPHonorPanelView:OnRegisterBinder()

end

return PVPHonorPanelView