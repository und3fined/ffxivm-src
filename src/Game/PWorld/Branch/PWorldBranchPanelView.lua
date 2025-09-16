---
--- Author: peterxie
--- DateTime: 2024-06-14 09:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

local PWorldMgr = _G.PWorldMgr


---@class PWorldBranchPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field ImgState UFImage
---@field InforBtn UFButton
---@field TableViewBranchList UTableView
---@field TextBranchName UFTextBlock
---@field TextCurrent UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldBranchPanelView = LuaClass(UIView, true)

function PWorldBranchPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.ImgState = nil
	--self.InforBtn = nil
	--self.TableViewBranchList = nil
	--self.TextBranchName = nil
	--self.TextCurrent = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldBranchPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldBranchPanelView:OnInit()
	self.AdapterBranchList = UIAdapterTableView.CreateAdapter(self, self.TableViewBranchList, self.OnBranchSelectChanged, true)
end

function PWorldBranchPanelView:OnDestroy()

end

function PWorldBranchPanelView:OnShow()
	self:InitText()

	PWorldMgr:SendLineQuery()

	self:RefreshData()
end

function PWorldBranchPanelView:InitText()
	local LSTR = _G.LSTR

	self.TextTitle:SetText(LSTR(800008)) -- 切换分线
	self.TextCurrent:SetText(LSTR(800009)) -- 当前
end

function PWorldBranchPanelView:OnHide()

end

function PWorldBranchPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.InforBtn, self.OnClickBtnInfor)
end

function PWorldBranchPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.LeaveInteractionRange, self.OnGameEventLeaveInteractionRange)
	self:RegisterGameEvent(_G.EventID.PWorldLineQueryResult, self.OnPWorldLineQueryResult)
end

function PWorldBranchPanelView:OnRegisterBinder()

end

function PWorldBranchPanelView:RefreshData()
	local CurrLineList = PWorldMgr:GetCurrPWorldLineList()
	local CurrLineID = PWorldMgr:GetCurrPWorldLineID()

	table.sort(CurrLineList, function(Left, Right)
		return Left.LineID < Right.LineID
	end)

	local CurrLine = nil -- 当前所在分线
	for _, Line in ipairs(CurrLineList) do
		if Line.LineID == CurrLineID then
			CurrLine = Line
		end
	end
	self.AdapterBranchList:UpdateAll(CurrLineList)

	if nil == CurrLine then
		return
	end

	local CurrMapTableCfg = PWorldMgr:GetCurrMapTableCfg()

	local BranchText = string.format("%s（%02d）", CurrMapTableCfg.DisplayName, CurrLine.LineID)
	self.TextBranchName:SetText(BranchText)

	local BranchStateIcon = PWorldMgr:GetPWorldLineStateIconPath(CurrLine.PlayerNum)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgState, BranchStateIcon)
end

function PWorldBranchPanelView:OnGameEventLeaveInteractionRange(Params)
	if Params.IntParam1 == _G.LuaEntranceType.CRYSTAL then
        self:Hide()
    end
end

function PWorldBranchPanelView:OnPWorldLineQueryResult(Params)
	self:RefreshData()
end

function PWorldBranchPanelView:OnBranchSelectChanged(Index, ItemData, ItemView)
	local Line = ItemData
	if nil == Line then
		return
	end

	if Line.LineID == PWorldMgr:GetCurrPWorldLineID() then
		_G.MsgTipsUtil.ShowTips(_G.LSTR(800001)) -- "您当前已在该分线"
		return
	end

	PWorldMgr:SendLineEnter(PWorldMgr:GetCurrPWorldResID(), Line.LineID, _G.InteractiveMgr.CurInteractEntityID)

	self:Hide()
end

function PWorldBranchPanelView:OnClickBtnInfor()
	_G.UIViewMgr:ShowView(_G.UIViewID.PWorldBranchWin)
end

return PWorldBranchPanelView