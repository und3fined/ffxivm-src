---
--- Author: Administrator
--- DateTime: 2025-02-24 20:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local BagPropsSideFrameVM = require("Game/NewBag/VM/BagPropsSideFrameVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ItemUtil = require("Utils/ItemUtil")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local EmotionMgr = require("Game/Emotion/EmotionMgr")
local EmotionDefines = require("Game/Emotion/Common/EmotionDefines")
local MajorUtil = require("Utils/MajorUtil")
local AnimationUtil = require("Utils/AnimationUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local ITEM_TYPE_DETAIL = ProtoCommon.ITEM_TYPE_DETAIL
local BagMgr = _G.BagMgr
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local EventID = _G.EventID
---@class BagPropsSideFrameView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn CommBtnMView
---@field CommEmpty CommBackpackEmptyView
---@field TableViewSlot UTableView
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BagPropsSideFrameView = LuaClass(UIView, true)

function BagPropsSideFrameView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.CommEmpty = nil
	--self.TableViewSlot = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BagPropsSideFrameView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Btn)
	self:AddSubView(self.CommEmpty)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BagPropsSideFrameView:OnInit()
	self.Btn:SetButtonText(LSTR(990080))
	UIUtil.SetIsVisible(self.CommEmpty, false)
	self.ViewModel = BagPropsSideFrameVM.New()
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot)
	self.TableViewAdapter:SetOnClickedCallback(self.OnItemClicked)
	self.Binders = {
		{"CurrentItemVMList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
		{"PropName", UIBinderSetText.New(self, self.TextName) },
		{"PropNameVisiable", UIBinderSetIsVisible.New(self, self.TextName) },
		{"UseBtnEnabled", UIBinderSetIsEnabled.New(self, self.Btn,false,true) },
		{"UseBtnVisible", UIBinderSetIsVisible.New(self, self.Btn,false,true) },
	}
end

function BagPropsSideFrameView:OnDestroy()

end

function BagPropsSideFrameView:OnShow()
	BagMgr:SendMsgBagInfoReq()
	BagMgr:SendMsgBagItemCDInfo(0) --同步物品Cd
end

function BagPropsSideFrameView:OnHide()

end

function BagPropsSideFrameView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn.Button, self.OnClickedUseBtn)
end

function BagPropsSideFrameView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.BagInit, self.OnUpdateEasyUseProp)
	self:RegisterGameEvent(EventID.BagUpdate, self.OnUpdateEasyUseProp)
	self:RegisterGameEvent(EventID.BagFreezeCD, self.OnFreezeCD)
end

function BagPropsSideFrameView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function BagPropsSideFrameView:OnItemClicked(Index, ItemData, ItemView)
	if ItemData == nil then
		return
	end 

	if UIViewMgr:IsViewVisible(UIViewID.BagItemTips) then
		UIViewMgr:HideView(UIViewID.BagItemTips)
	end

	self.ViewModel:SetCurItem(Index)
	local CurItem = self.ViewModel:GetCurItem()
	self:SetCurItemInfo(CurItem)
	local ItemWidgetPosition = UIUtil.GetWidgetPosition(ItemView)
	local TableWidgetPosition = UIUtil.GetWidgetPosition(self.TableViewSlot)
	if CurItem then
		ItemTipsUtil.ShowTipsByResID(CurItem.ResID, ItemView, {X = 10 + (ItemWidgetPosition.X - TableWidgetPosition.X)}, nil, 30)
	end
end

function BagPropsSideFrameView:SetCurItemInfo(CurItem)
	if CurItem then
		local ItemResID = CurItem.ResID
		self.ViewModel.PropName = ItemCfg:GetItemName(ItemResID)
		local Cfg = ItemCfg:FindCfgByKey(ItemResID)
		if Cfg == nil then
			return
		end

		if _G.BagMgr:TimeLimitItemExpired(CurItem) then
			self.ViewModel.UseBtnVisible = false
		elseif ItemUtil.CheckIsEquipment(Cfg.Classify) then
			self.ViewModel.UseBtnVisible = false
		elseif ItemUtil.CheckIsTreasureMap(Cfg.ItemType) then --宝图
			if Cfg.UseFunc > 0 then  --未解读的宝图
				self.ViewModel.UseBtnVisible = false
			else
				self.ViewModel.UseBtnVisible = true
				self.ViewModel.UseBtnEnabled = true
			end
		elseif ItemUtil.CheckIsAetherCurrentMachine(ItemResID) then
			self.ViewModel.UseBtnVisible = true
			self.ViewModel.UseBtnEnabled = true
		elseif ItemUtil.CheckIsMateria(Cfg.ItemType) then
			self.ViewModel.UseBtnVisible = true
			self.ViewModel.UseBtnEnabled = true
		elseif CurItem.FreezeGroup == 6 then
			self.ViewModel.PropNameVisiable = true
			if  _G.BagMgr.FreezeCDTable[Cfg.FreezeGroup] ~= nil or
				EmotionMgr.MajorCanUseType == EmotionDefines.CanUseTypes.SIT_GROUND or
				EmotionMgr.MajorCanUseType == EmotionDefines.CanUseTypes.RIDE or
				EmotionMgr.MajorCanUseType == EmotionDefines.CanUseTypes.SIT_CHAIR then
				self.ViewModel.UseBtnVisible = true
				self.ViewModel.UseBtnEnabled = false
			else
				self.ViewModel.UseBtnVisible = true
				self.ViewModel.UseBtnEnabled = Cfg.ItemType ~= ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY and Cfg.UseFunc > 0
			end
		else
			self.ViewModel.UseBtnVisible = true
			self.ViewModel.UseBtnEnabled = Cfg.ItemType ~= ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY and Cfg.UseFunc > 0
		end

		if ItemUtil.CheckIsAetheryteticket(Cfg.ItemType) then
			if not _G.BagMgr:ItemUseCondition({ResID = ItemResID}, nil, nil, true) then
				self.ViewModel.UseBtnEnabled = false
			end
		end
	end
end

function BagPropsSideFrameView:OnUpdateEasyUseProp()
	self.ViewModel:UpdateTabInfo()

	local LastItemIndex = self.ViewModel.ItemIndex or 0
	local CurItem = self.ViewModel:GetCurItem()

	if CurItem == nil then
		if LastItemIndex > 1 then
			self.ViewModel:SetCurItem(LastItemIndex - 1)
			self:SetCurItemInfo(self.ViewModel:GetCurItem())
			self.ViewModel.PropNameVisiable = true
			self.TableViewAdapter:ScrollIndexIntoView(LastItemIndex - 1)
		else
			self.ViewModel.UseBtnVisible = false
			self.ViewModel.PropNameVisiable = false
		end
	else
		self.ViewModel:SetCurItem(self.ViewModel.ItemIndex)
		self:SetCurItemInfo(CurItem)
		self.ViewModel.PropNameVisiable = true
		self.TableViewAdapter:ScrollIndexIntoView(self.ViewModel.ItemIndex)
	end
end

function BagPropsSideFrameView:OnClickedUseBtn()
	local Item = self.ViewModel:GetCurItem()
	if Item == nil then return end

	if ItemUtil.CheckIsTreasureMapByResID(Item.ResID) then
		if _G.TreasureHuntMgr:IsInDungeon() then return end
		self:Hide()
		_G.TreasureHuntMgr:InterpretMapReq(Item.ResID)
	elseif ItemUtil.CheckIsMateriaByResID(Item.ResID) then
		if _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDGemInfo) then
			for _,Part in pairs(ProtoCommon.equip_part) do
				local Equip = _G.EquipmentMgr:GetEquipedItemByPart(Part)
				if Equip then
					local EquipCfg = EquipmentCfg:FindCfgByEquipID(Equip.ResID)
					if EquipCfg and EquipCfg.MateID > 0 then
						local Param = {GID = Equip.GID, ResID = Equip.ResID, Tag = "Bag"}
						_G.EquipmentMgr:TryInlayMagicspar(Param)
						return
					end
				end
			end
			_G.MsgTipsUtil.ShowTipsByID(100051)
		else
			_G.MsgTipsUtil.ShowTipsByID(100050)
		end
	elseif Item.FreezeGroup == 6 then
		local MajorEntityID = MajorUtil.GetMajorEntityID()
		local PlayerAnimInst = AnimationUtil.GetPlayerAnimInst(MajorEntityID)
		local MoveComp = MajorUtil.GetMajor():GetMovementComponent()
		if EmotionMgr.MajorCanUseType == EmotionDefines.CanUseTypes.SIT_GROUND or 
			EmotionMgr.MajorCanUseType == EmotionDefines.CanUseTypes.SIT_CHAIR then
			_G.MsgTipsUtil.ShowTips(LSTR(990102)) -- 坐下状态无法使用道具
		elseif EmotionMgr.MajorCanUseType == EmotionDefines.CanUseTypes.RIDE then
			_G.MsgTipsUtil.ShowTips(LSTR(990103)) -- 乘骑状态无法使用道具
		elseif PlayerAnimInst and PlayerAnimInst.bUseBed then
			_G.MsgTipsUtil.ShowTips(LSTR(990104)) -- 躺下状态无法使用道具
		elseif _G.SingBarMgr:GetMajorIsSinging() then
			_G.MsgTipsUtil.ShowTips(LSTR(990105)) -- 读条状态无法使用道具
		elseif MoveComp and MoveComp.Velocity:Size2D() > 0 then
			_G.MsgTipsUtil.ShowTips(LSTR(990129)) -- 移动状态无法使用道具
		else
			if Item.ResID == 66700089 then
				local Major = MajorUtil.GetMajor()
				if  Major and Major:IsSwimming() then
					_G.MsgTipsUtil.ShowTips(LSTR(990106)) -- 游泳时无法使用该道具
				else
                    _G.BagMgr:UseItem(self.ViewModel.CurGID, nil)
					DataReportUtil.ReportEasyUseFlowData(3, Item.ResID, 2)
                end
			else
				_G.BagMgr:UseItem(self.ViewModel.CurGID, nil)
				DataReportUtil.ReportEasyUseFlowData(3, Item.ResID, 2)
			end
		end
	else
		_G.BagMgr:UseItem(self.ViewModel.CurGID, nil)
		DataReportUtil.ReportEasyUseFlowData(3, Item.ResID, 2)
	end
end

function BagPropsSideFrameView:OnFreezeCD(GroupID, EndFreezeTime, FreezeCD)
	local Item = self.ViewModel:GetCurItem()
	if Item ~= nil then
		local Cfg = ItemCfg:FindCfgByKey(Item.ResID)
		if Cfg and _G.BagMgr.FreezeCDTable[Cfg.FreezeGroup] ~= nil then
			self.Btn:SetIsDisabledState(true, true)
		else
			self.Btn:SetIsEnabled(true, true)
		end
	end
end

return BagPropsSideFrameView