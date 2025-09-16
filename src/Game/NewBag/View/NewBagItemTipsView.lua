---
--- Author: Administrator
--- DateTime: 2024-06-12 14:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local NewBagItemTipsVM = require("Game/NewBag/VM/NewBagItemTipsVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local TipsUtil = require("Utils/TipsUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local ItemUtil = require("Utils/ItemUtil")
local EquipImproveCfg = require("TableCfg/EquipImproveCfg")
local LSTR = _G.LSTR
local UIDefine = require("Define/UIDefine")
local CommBtnColorType = UIDefine.CommBtnColorType
local EmotionMgr = require("Game/Emotion/EmotionMgr")
local EmotionDefines = require("Game/Emotion/Common/EmotionDefines")
local MajorUtil = require("Utils/MajorUtil")
local AnimationUtil = require("Utils/AnimationUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ItemCfg = require("TableCfg/ItemCfg")

---@class NewBagItemTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BagFrameInterface ItemTipsFrameInterfaceView
---@field BtnGo CommBtnLView
---@field BtnMore UFButton
---@field BtnRead CommBtnLView
---@field BtnThrowAway CommBtnLView
---@field BtnUse CommBtnLView
---@field PanelBtn UFCanvasPanel
---@field PanelDetail UFCanvasPanel
---@field PanelMore UFCanvasPanel
---@field RedDot CommonRedDotView
---@field TableViewMore UTableView
---@field AnimMoreIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewBagItemTipsView = LuaClass(UIView, true)

function NewBagItemTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BagFrameInterface = nil
	--self.BtnGo = nil
	--self.BtnMore = nil
	--self.BtnRead = nil
	--self.BtnThrowAway = nil
	--self.BtnUse = nil
	--self.PanelBtn = nil
	--self.PanelDetail = nil
	--self.PanelMore = nil
	--self.RedDot = nil
	--self.TableViewMore = nil
	--self.AnimMoreIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewBagItemTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BagFrameInterface)
	self:AddSubView(self.BtnGo)
	self:AddSubView(self.BtnRead)
	self:AddSubView(self.BtnThrowAway)
	self:AddSubView(self.BtnUse)
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewBagItemTipsView:OnInit()
	self.ViewModel = NewBagItemTipsVM.New()
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewMore)
	self.TableViewAdapter:SetOnClickedCallback(self.OnMenuClicked)
	self.BtnUseValue = 1

	self.Binders = {
		{"MoreBtnVisible", UIBinderSetIsVisible.New(self, self.BtnMore, false, true) },
		{"MorePanelVisible", UIBinderSetIsVisible.New(self, self.PanelMore) },
		{"MenuBindableListItem", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
		{"GoBtnVisible", UIBinderSetIsVisible.New(self, self.BtnGo) },
		{"UseBtnVisible", UIBinderSetIsVisible.New(self, self.BtnUse, false, true) },
		{"BtnReadVisible", UIBinderSetIsVisible.New(self, self.BtnRead, false, true) },
		{"BtnDropVisible", UIBinderSetIsVisible.New(self, self.BtnThrowAway,false,true) },

		{ "EquipmentBtnEnabled", UIBinderSetIsEnabled.New(self, self.BtnGo) },
		{ "UseBtnEnabled", UIBinderSetIsEnabled.New(self, self.BtnUse,false,true) },
		{ "BtnReadEnabled", UIBinderSetIsEnabled.New(self, self.BtnRead,false,true) },
        { "BtnDropEnabled", UIBinderSetIsEnabled.New(self, self.BtnThrowAway,false,true) },

	}
end

function NewBagItemTipsView:OnDestroy()

end

function NewBagItemTipsView:OnShow()
	self.RedDot:SetIsCustomizeRedDot(true)
end

function NewBagItemTipsView:OnHide()

end

function NewBagItemTipsView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnMore, self.OnClickedMoreBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnGo.Button, self.OnClickedGoBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnUse.Button, self.OnClickedUseBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnRead.Button,self.OnClickedReadMap)
	UIUtil.AddOnClickedEvent(self, self.BtnThrowAway.Button,self.OnClickedDropBtn)
end

function NewBagItemTipsView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.LootItemUpdateRes, self.OnLootItemUpdateRes)
end

function NewBagItemTipsView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)

	self.BtnGo:SetButtonText(LSTR(990079))
	self.BtnUse:SetButtonText(LSTR(990080))
	self.BtnRead:SetButtonText(LSTR(990078))
	self.BtnThrowAway:SetButtonText(LSTR(990081))
end

function NewBagItemTipsView:ChangUseBtnDisableImg(NewValue)
	local NeedColor
	if NewValue == CommBtnColorType.Disable then
		self.BtnUse:SetIsDisabledState(true, true)
		NeedColor = "#999999"
	elseif NewValue == CommBtnColorType.Recommend then
		self.BtnUse:SetIsRecommendState(true)
		NeedColor = "FFFCF1FF"
	end
	self.BtnUse:SetTextColorAndOpacityHex(NeedColor)
end


function NewBagItemTipsView:UpdateItem(Value)
	--装备改良红点，暂时放这
	local bShow = _G.EquipmentMgr:GetImproveMaterialEnough(Value.ResID)
	self.RedDot:SetRedDotUIIsShow(bShow)
	self.BagFrameInterface:UpdateUI(Value)
	self.ViewModel:UpdateVM(Value)
end

function NewBagItemTipsView:OnMenuClicked(Index, ItemData, ItemView)
	if nil == ItemData then
		return
	end

	local MenuConfig = ItemData.Value
	if nil == MenuConfig then
		return
	end
	MenuConfig:OnClicked(self.ViewModel.Value)
	self.ViewModel.MorePanelVisible = false
end

function NewBagItemTipsView:OnClickedMoreBtn()
	-- self.ViewModel.MorePanelVisible = not self.ViewModel.MorePanelVisible
	if UIViewMgr:IsViewVisible(UIViewID.CommStorageTipsView) then
		UIViewMgr:HideView(UIViewID.CommStorageTipsView)
	else
		local BtnList = {}
		for k , v in ipairs(self.ViewModel.MenuBindableListItem.Items) do
			table.insert(BtnList, {Content = v.Name, ClickItemCallback = self.OnClickedBtn, View = self, Value = v.Value})
		end
		local BtnSize = UIUtil.CanvasSlotGetSize(self.BtnMore)
		TipsUtil.ShowStorageBtnsTips(BtnList, self.BtnMore, _G.UE.FVector2D(-BtnSize.X /2, 0), _G.UE.FVector2D(0.5, 1), false)
	end
end

function NewBagItemTipsView:OnClickedBtn(ItemData)

	local MenuConfig = ItemData.Value
	if nil == MenuConfig then
		return
	end
	MenuConfig:OnClicked(self.ViewModel.Value)
	UIViewMgr:HideView(UIViewID.CommStorageTipsView) 

	--self.ViewModel.MorePanelVisible = not self.ViewModel.MorePanelVisible
	--self:PlayAnimation(self.AnimMoreIn)

end

function NewBagItemTipsView:OnClickedGoBtn()
	local Cfg = EquipmentCfg:FindCfgByEquipID(self.ViewModel.Value.ResID)
	local Params = {}
	Params.Part = Cfg.Part
	Params.GID = self.ViewModel.Value.GID
	_G.EquipmentMgr:ShowEquipDetail(Params)
end

function NewBagItemTipsView:OnClickedUseBtn()
	local Item =  _G.BagMgr:FindItem(self.ViewModel.Value.GID)
	if Item == nil then return end

	local Cfg = ItemCfg:FindCfgByKey(Item.ResID)
	if self.ViewModel.UseBtnEnabled == false  and Cfg and Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY then
		_G.MsgTipsUtil.ShowTips(LSTR(990128)) 
		return
	end

	if ItemUtil.CheckIsTreasureMapByResID(Item.ResID) then
		if _G.TreasureHuntMgr:IsInDungeon() then return end
		self:Hide()
		_G.TreasureHuntMgr:InterpretMapReq(Item.ResID)
	elseif ItemUtil.CheckIsMateriaByResID(Item.ResID) then
		if _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDGemInfo) then
			for i = 1, ProtoCommon.equip_part.EQUIP_PART_EAR do
				local Equip = _G.EquipmentMgr:GetEquipedItemByPart(i)
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
		if EmotionMgr.MajorCanUseType == EmotionDefines.CanUseTypes.SIT_GROUND or 
			EmotionMgr.MajorCanUseType == EmotionDefines.CanUseTypes.SIT_CHAIR then
			_G.MsgTipsUtil.ShowTips(LSTR(990102)) -- 坐下状态无法使用道具
		elseif EmotionMgr.MajorCanUseType == EmotionDefines.CanUseTypes.RIDE then
			_G.MsgTipsUtil.ShowTips(LSTR(990103)) -- 乘骑状态无法使用道具
		elseif PlayerAnimInst and PlayerAnimInst.bUseBed then
			_G.MsgTipsUtil.ShowTips(LSTR(990104)) -- 躺下状态无法使用道具
		elseif _G.SingBarMgr:GetMajorIsSinging() then
			_G.MsgTipsUtil.ShowTips(LSTR(990105)) -- 读条状态无法使用道具
		else
			if Item.ResID == 66700089 then
				local Major = MajorUtil.GetMajor()
				if  Major and Major:IsSwimming() then
					_G.MsgTipsUtil.ShowTips(LSTR(990106)) -- 游泳时无法使用该道具
				else
                    _G.BagMgr:UseItem(self.ViewModel.Value.GID, nil)
                end
			else
				_G.BagMgr:UseItem(self.ViewModel.Value.GID, nil)
			end
		end
	else
		_G.BagMgr:UseItem(self.ViewModel.Value.GID, nil)
	end
end

function NewBagItemTipsView:OnClickedDropBtn()
	local Item =  _G.BagMgr:FindItem(self.ViewModel.Value.GID)
	if Item == nil then return end

	_G.BagMgr:DropItem(Item)
end

function NewBagItemTipsView:OnClickedReadMap()
	local Item = _G.BagMgr:FindItem(self.ViewModel.Value.GID)
	if Item == nil then return end

	if self.ViewModel.BtnReadEnabled then 
		_G.TreasureHuntMgr:DecodeTreasureMap(Item.ResID)
	else	
		local DecodeResID = _G.TreasureHuntMainVM:GetDecodeMapID(Item.ResID)
		if DecodeResID ~= nil then 
		    local DecodeItemName = ItemUtil.GetItemName(DecodeResID)  
			_G.MsgTipsUtil.ShowTips(string.format(_G.LSTR(990039),DecodeItemName))
		end
	end
end

function NewBagItemTipsView:OnLootItemUpdateRes(InLootList, InReason)
	if not InLootList or not next(InLootList) then
        return
    end
	local Cfg = EquipImproveCfg:FindCfgByKey(self.ViewModel.Value.ResID)
	local MaterialID = Cfg and Cfg.MaterialID or 0
	for key, value in pairs(InLootList) do
		-- body
		if value.Item and value.Item.ResID == MaterialID then
			local bShow = _G.EquipmentMgr:GetImproveMaterialEnough(self.ViewModel.Value.ResID)
			self.RedDot:SetRedDotUIIsShow(bShow)
		end
	end
end
return NewBagItemTipsView