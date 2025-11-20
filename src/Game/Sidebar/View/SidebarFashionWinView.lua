---
--- Author: Administrator
--- DateTime: 2025-07-04 14:12
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local SidepopupCfg = require("TableCfg/SidepopupCfg")
local TimeUtil = require("Utils/TimeUtil")
local SidePopUpFashionVM = require("Game/SidePopUp/VM/SidePopUpFashionVM")
local EventID = require("Define/EventID")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIViewID = require("Define/UIViewID")
local ProtoCS = require("Protocol/ProtoCS")
local ItemCfg = require("TableCfg/ItemCfg")
local EquipmentCfg = require("TableCfg/EquipmentCfg")

local SidePopUpMgr = _G.SidePopUpMgr
---@class SidebarFashionWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose UFButton
---@field ImgBg UFImage
---@field ProBarCD UProgressBar
---@field SidePopUpBtn SidePopUpBtnItemView
---@field SkillHandleCloseBtn SkillHandleCloseBtnView
---@field TableViewMemberProf UTableView
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimProBar UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SidebarFashionWinView = LuaClass(UIView, true)

function SidebarFashionWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.ImgBg = nil
	--self.ProBarCD = nil
	--self.SidePopUpBtn = nil
	--self.SkillHandleCloseBtn = nil
	--self.TableViewMemberProf = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimProBar = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SidebarFashionWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SidePopUpBtn)
	self:AddSubView(self.SkillHandleCloseBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SidebarFashionWinView:OnInit()
	self.ItemTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewMemberProf)
	self.ItemTableViewAdapter:SetOnClickedCallback(self.OnItemSelectChanged)

	self.Binders = {
		{ "CDProgressPercent", UIBinderSetPercent.New(self, self.ProBarCD) },
		{ "CurrentItemVMList", UIBinderUpdateBindableList.New(self, self.ItemTableViewAdapter) },
	}
end

function SidebarFashionWinView:OnDestroy()

end

function SidebarFashionWinView:OnShow()
	local Params = self.Params
	if Params == nil then
		return
	end
	SidePopUpFashionVM:UpdateVM(Params.ItemList)
	self:PlayAnimationTimeRange(self.AnimProBar, 0 , 0.1, 1, nil, 0.1, false)
end

function SidebarFashionWinView:OnHide()

end

function SidebarFashionWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClose, self.OnClickButtonClose)
	UIUtil.AddOnClickedEvent(self, self.SidePopUpBtn.Btn, self.OnClickedAction)
end

function SidebarFashionWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.SidePopUpUpdateTime, self.OnEventSidePopUpUpdateTime)
end

function SidebarFashionWinView:OnRegisterBinder()
	self:RegisterBinders(SidePopUpFashionVM, self.Binders)
	self.TextTitle:SetText(_G.LSTR(1020077))
	self.SidePopUpBtn.TextContent:SetText(_G.LSTR(1020078))
end

function SidebarFashionWinView:OnEventSidePopUpUpdateTime()
	local EndTime = SidePopUpMgr:GetDisplayedEndTime(ProtoRes.side_popup_type.SIDE_POPUP_UNLOCK_FASHION)
    local CDTime = SidepopupCfg:FindCfgByKey(ProtoRes.side_popup_type.SIDE_POPUP_UNLOCK_FASHION).ShowTime

    if CDTime == 0 or EndTime == 0 then
        return
    end

	local Percent = (EndTime - TimeUtil.GetServerTime())/CDTime
	if Percent == SidePopUpFashionVM.CDProgressPercent then
		return
	end
	self:PlayAnimationTimeRange(self.AnimProBar, 1 - Percent, 1 - Percent + 0.1, 1, nil, 0.1, false)
	SidePopUpFashionVM.CDProgressPercent = Percent
	
end

function SidebarFashionWinView:OnClickButtonClose()
	SidePopUpMgr:RemoveSidePopUp(UIViewID.SidebarFashionWin)
end

function SidebarFashionWinView:OnClickedAction()
	local Params = self.Params
	if Params == nil then
		return
	end
	local BatchItem = {}
	--[[
	for _, Value in ipairs(Params.ItemList) do
		table.insert(BatchItem, {GID = Value.GID, Num = 1, UseType = 0, ParamTarget = nil, ParamPos = nil, UseFrom = ProtoCS.ITEM_USE_FROM.ITEM_USE_FROM_BAG })
	end

	_G.BagMgr:SendMsgBatchUseItemReq(BatchItem)
	]]--

	
	for _, Value in ipairs(Params.ItemList) do
		local Cfg = ItemCfg:FindCfgByKey(Value.ResID)
		if Cfg and Cfg.EquipmentID > 0 then
			local TempEquipmentCfg = EquipmentCfg:FindCfgByEquipID(Cfg.EquipmentID)
			if TempEquipmentCfg and TempEquipmentCfg.AppearanceID > 0 then
				local GIDs = {}
				table.insert(GIDs, Value.GID)
				table.insert(BatchItem, {ID = TempEquipmentCfg.AppearanceID, GIDs = GIDs})
			end
		end
	end

	_G.WardrobeMgr:SendClosetUnLockReq(BatchItem)
	
	SidePopUpMgr:RemoveSidePopUp(UIViewID.SidebarFashionWin)
end

function SidebarFashionWinView:OnItemSelectChanged(Index, ItemData, ItemView)
	ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView)
end

return SidebarFashionWinView