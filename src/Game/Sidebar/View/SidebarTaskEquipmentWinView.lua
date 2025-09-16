---
--- Author: sammrli
--- DateTime: 2024-06-06 15:54
--- Description:一键穿戴侧边栏
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local SidebarTaskEquipmentWinVM = require ("Game/Sidebar/VM/SidebarTaskEquipmentWinVM")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

local SidepopupCfg = require("TableCfg/SidepopupCfg")

local ProtoRes = require("Protocol/ProtoRes")

local LSTR = _G.LSTR
local TIME_TO_CLOSE = 10 --默认10秒关闭

---@class SidebarTaskEquipmentWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose UFButton
---@field ImgBg UFImage
---@field ProBarCD UProgressBar
---@field SidePopUpBtn SidePopUpBtnItemView
---@field TableViewMemberProf UTableView
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimProBar UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SidebarTaskEquipmentWinView = LuaClass(UIView, true)

function SidebarTaskEquipmentWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.ImgBg = nil
	--self.ProBarCD = nil
	--self.SidePopUpBtn = nil
	--self.TableViewMemberProf = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimProBar = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SidebarTaskEquipmentWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SidePopUpBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SidebarTaskEquipmentWinView:OnInit()
	self.SidebarTaskEquipmentWinVM = SidebarTaskEquipmentWinVM.New()
	self.AdapterTableViewMemberProf = UIAdapterTableView.CreateAdapter(self, self.TableViewMemberProf)
end

function SidebarTaskEquipmentWinView:OnDestroy()

end

function SidebarTaskEquipmentWinView:OnShow()
	local Params = self.Params
	self.IsClickedWear = false
	if Params and Params.MissItemList then
		self.SidebarTaskEquipmentWinVM:UpdateView(Params.MissItemList)
	end

	self.ShowTime = TIME_TO_CLOSE
	local SidepopupCfgItem = SidepopupCfg:FindCfgByKey(ProtoRes.side_popup_type.SIDE_POPUP_CLICK_WEAR)
	if SidepopupCfgItem and SidepopupCfgItem.ShowTime then
		if SidepopupCfgItem.ShowTime > 0 then
			self.ShowTime = SidepopupCfgItem.ShowTime
		end
	end

	UIUtil.SetIsVisible(self.SidePopUpBtn.ImgAsh, false)

	self:PlayAnimation(self.AnimProBar, 0, 1, 0, 1 / self.ShowTime)
	self:RegisterTimer(self.OnTimeEnd, self.ShowTime)
end

function SidebarTaskEquipmentWinView:OnHide()

end

function SidebarTaskEquipmentWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.SidePopUpBtn.Btn, self.OnClickPopUpBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnClose, self.OnClickCloseBtn)

	local function OnOnSlotItemClick(EquipmentSlotItemVM)
		if EquipmentSlotItemVM then
			ItemTipsUtil.ShowTipsByGID(EquipmentSlotItemVM.GID, self.ImgBg)
		end
	end
	self.SidebarTaskEquipmentWinVM:RegisterSlotItemClick(OnOnSlotItemClick)
end

function SidebarTaskEquipmentWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.SidePopUpTaskEquipmentUpdate, self.OnGameEventUpdateView)
end

function SidebarTaskEquipmentWinView:OnRegisterBinder()
	local Binders = {
		{ "TextTitle", UIBinderSetText.New(self, self.TextTitle) },
		{ "TextBtn", UIBinderSetText.New(self, self.SidePopUpBtn.TextContent) },
		{ "EquipmentList", UIBinderUpdateBindableList.New(self, self.AdapterTableViewMemberProf) }
	}
	self:RegisterBinders(self.SidebarTaskEquipmentWinVM, Binders)
end

function SidebarTaskEquipmentWinView:OnClickPopUpBtn()
	if MajorUtil.IsMajorDead() then
		MsgTipsUtil.ShowTips( LSTR(596201)) --596201("当前状态无法穿戴")
        return
    end
	if not self.IsClickedWear then
		self.IsClickedWear = true
		self.SidebarTaskEquipmentWinVM:OneKeyWear()
		_G.SidePopUpMgr:RemoveSidePopUp(UIViewID.SidebarTaskEquipmentWin)
	end
end

function SidebarTaskEquipmentWinView:OnClickCloseBtn()
	_G.SidePopUpMgr:RemoveSidePopUp(UIViewID.SidebarTaskEquipmentWin)
end

function SidebarTaskEquipmentWinView:OnTimeEnd()
	_G.SidePopUpMgr:RemoveSidePopUp(UIViewID.SidebarTaskEquipmentWin)
end

function SidebarTaskEquipmentWinView:OnGameEventUpdateView()
	self:UnRegisterAllTimer()
	self:PlayAnimation(self.AnimProBar, 0, 1, 0, 1 / self.ShowTime)
	self:RegisterTimer(self.OnTimeEnd, self.ShowTime)

	local Params = self.Params
	if Params and Params.MissItemList then
		self.SidebarTaskEquipmentWinVM:UpdateView(Params.MissItemList)
	end
end

return SidebarTaskEquipmentWinView