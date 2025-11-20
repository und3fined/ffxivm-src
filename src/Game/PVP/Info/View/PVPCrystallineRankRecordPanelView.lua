---
--- Author: Administrator
--- DateTime: 2025-07-03 10:26
--- Description:
---

local ProtoRes = require("Protocol/ProtoRes")
local UIView = require("UI/UIView")
local UIViewID = require("Define/UIViewID")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

local SeriesMalmstoneSeasonCfg = require("TableCfg/SeriesMalmstoneSeasonCfg")

local PVPInfoVM = require ("Game/PVP/Info/VM/PVPInfoVM")
local PVPCrystallineRankRecordItemVM = require ("Game/PVP/Info/VM/PVPCrystallineRankRecordItemVM")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local PVPInfoMgr = _G.PVPInfoMgr
local UVersionMgr = _G.UE.UVersionMgr

---@class PVPCrystallineRankRecordPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewRecord UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPCrystallineRankRecordPanelView = LuaClass(UIView, true)

function PVPCrystallineRankRecordPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewRecord = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPCrystallineRankRecordPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPCrystallineRankRecordPanelView:OnInit()
	self.RecordList = UIAdapterTableView.CreateAdapter(self, self.TableViewRecord)
	self.RecordList:SetOnClickedCallback(self.OnClickRecord)
	self.InfoBinders = {
		{ "CrystallineRankRecordData", UIBinderValueChangedCallback.New(self, nil, self.OnCrystallineRankRecordDataChanged) },
	}
end

function PVPCrystallineRankRecordPanelView:OnDestroy()

end

function PVPCrystallineRankRecordPanelView:OnShow()

end

function PVPCrystallineRankRecordPanelView:OnHide()

end

function PVPCrystallineRankRecordPanelView:OnRegisterUIEvent()

end

function PVPCrystallineRankRecordPanelView:OnRegisterGameEvent()

end

function PVPCrystallineRankRecordPanelView:OnRegisterBinder()
	if PVPInfoVM then
		self:RegisterBinders(PVPInfoVM, self.InfoBinders)
	end
end

function PVPCrystallineRankRecordPanelView:OnClickRecord(Index, ItemData, ItemView)
	local SeasonID = ItemData and ItemData.SeasonID
	if SeasonID then
		local Record = PVPInfoMgr:GetCrystallineRankRecordData(SeasonID)
		if Record then
			local RankType = PVPInfoMgr:GetCrystallineRankType(Record.RankID)
			if RankType and RankType ~= ProtoRes.Game.pvp_rank_type.RT_None then
				PVPInfoMgr:OpenCrystallinePathPanel(SeasonID, false, true)
			else
				MsgTipsUtil.ShowTipsByID(338046)	-- 青铜及以上才可查看赛季记录
			end
		end
	end
end

function PVPCrystallineRankRecordPanelView:OnCrystallineRankRecordDataChanged(NewValue, OldValue)
	if NewValue then
		local VMList = {}
		local Cfgs = SeriesMalmstoneSeasonCfg:FindAllCfg()
		for _, Cfg in pairs(Cfgs) do
			if Cfg.Season ~= 0 then
				local BeginVersion = Cfg.BeginVersion
				local EndVersion = Cfg.EndVersion

				if not string.isnilorempty(BeginVersion) and not string.isnilorempty(EndVersion) then
					if UVersionMgr.IsBelowOrEqualGameVersion(BeginVersion) and UVersionMgr.IsBelowOrEqualGameVersion(EndVersion) then
						local VM = PVPCrystallineRankRecordItemVM.New()
						VM:UpdateVM({ SeasonID = Cfg.SeasonID })
						table.insert(VMList, VM)
					end
				end
			end
		end
		self.RecordList:UpdateAll(VMList)
	end
end

return PVPCrystallineRankRecordPanelView