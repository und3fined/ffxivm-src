---
--- Author: daniel
--- DateTime: 2023-03-10 14:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ArmyDefine = require("Game/Army/ArmyDefine")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgBoxUtil = _G.MsgBoxUtil
local LSTR = _G.LSTR
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local ArmyBadgeType = ArmyDefine.ArmyBadgeType
local GroupEmblemTotemCfg = require("TableCfg/GroupEmblemTotemCfg")
local GroupEmblemBackgroundCfg = require("TableCfg/GroupEmblemBackgroundCfg")
local GroupEmblemIconCfg = require("TableCfg/GroupEmblemIconCfg")

---@class ArmySelectBadgeWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ArmyBadgeItem ArmyBadgeItemView
---@field BG Comm2FrameLView
---@field BtnRandom UFButton
---@field BtnReset UFButton
---@field BtnSave CommBtnLView
---@field ImgArmyBg UFImage
---@field TableViewSlot UTableView
---@field ToggleGroupTabs CommHorTabsView
---@field AnimUpdateSlot UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmySelectBadgeWinView = LuaClass(UIView, true)

function ArmySelectBadgeWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ArmyBadgeItem = nil
	--self.BG = nil
	--self.BtnRandom = nil
	--self.BtnReset = nil
	--self.BtnSave = nil
	--self.ImgArmyBg = nil
	--self.TableViewSlot = nil
	--self.ToggleGroupTabs = nil
	--self.AnimUpdateSlot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmySelectBadgeWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ArmyBadgeItem)
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnSave)
	self:AddSubView(self.ToggleGroupTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmySelectBadgeWinView:OnInit()
	self.CurArmyBadgeType = -1
	self.CurSelectedImpliedIndex = nil
	self.CurSelectedShieldIndex = nil
	self.CurSelectedBgIndex = nil
	self.OldSelectedImpliedID = nil
	self.OldSelectedShieldIndex = nil
	self.OldSelectedBgIndex = nil
	self.CommitedCallback = nil
	self.CurGrandCompanyType = nil
	-- LSTR string:撤销修改
	---self.BtnReset:SetText(LSTR(910145))
	self.TabsViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot)
	self.TabsViewAdapter:SetOnClickedCallback(self.OnClickedSelectItem)
	self.TabsViewAdapter:SetOnSelectChangedCallback(self.OnSelectChangedCallback)
end

--- 选中
---@param Index number @下标 从1开始
function ArmySelectBadgeWinView:OnClickedSelectItem(Index, ItemData, ItemView)
	if self.CurArmyBadgeType == ArmyBadgeType.Implied then
		self.CurSelectedImpliedIndex = Index
		--寓意物有筛选，不能直接用下标
		self.CurSelectedImpliedID = ItemData.ID
		self.ArmyBadgeItem:SetSymbol(self.CurSelectedImpliedID)
	elseif self.CurArmyBadgeType == ArmyBadgeType.Shield then
		self.CurSelectedShieldIndex = Index
		self.ArmyBadgeItem:SetShield(self.CurSelectedShieldIndex)
	elseif self.CurArmyBadgeType == ArmyBadgeType.ShieldBg then
		if self.CurSelectedShieldIndex > 0 then
			self.CurSelectedBgIndex = Index
			self.ArmyBadgeItem:SetBackground(self.CurSelectedBgIndex)
		else
			-- LSTR string:请先完成盾纹选择
			MsgTipsUtil.ShowTips(LSTR(910225))
			self.TabsViewAdapter:CancelSelected()
		end
	end
	self:CheckedEdit()
end

--- 选中变更事件，用于随机队徽时滑动处理
---@param Index number @下标 从1开始
function ArmySelectBadgeWinView:OnSelectChangedCallback(Index, ItemData, ItemView, IsByClick)
	if not IsByClick then
		self.TabsViewAdapter:ScrollIndexIntoView(Index)
	end
end

function ArmySelectBadgeWinView:OnDestroy()

end

function ArmySelectBadgeWinView:OnShow()
	local Tab = {
		-- LSTR string:寓意物
		{ Name = LSTR(910293) }, 
		-- LSTR string:盾纹
		{ Name = LSTR(910294) },
		-- LSTR string:背景
		{ Name = LSTR(910295) },
   }
   self.ToggleGroupTabs:UpdateItems(Tab)
   -- LSTR string:编辑队徽
   self.BG:SetTitleText(LSTR(910207))
	local Params = self.Params
	if nil == Params then
		return
	end
	self.CurGrandCompanyType = self.Params.GrandCompanyType
	self.CurSelectedImpliedIndex = ArmyDefine.Zero
	self.CurSelectedShieldIndex = ArmyDefine.Zero
	self.CurSelectedBgIndex = ArmyDefine.Zero
	self.CurSelectedImpliedID = ArmyDefine.Zero
	if Params.BadgeData then
		self.CurSelectedImpliedID = Params.BadgeData.TotemID
		self.CurSelectedShieldIndex = Params.BadgeData.IconID
		self.CurSelectedBgIndex = Params.BadgeData.BackgroundID
		self.OldSelectedImpliedID = Params.BadgeData.TotemID
		self.OldSelectedShieldIndex = Params.BadgeData.IconID
		self.OldSelectedBgIndex = Params.BadgeData.BackgroundID
	end
	self.ArmyBadgeItem:SetBadgeData(Params.BadgeData)
	self.CommitedCallback = Params.CommitedCallback
	self.BtnSave:SetIsEnabled(false)
	self.BtnReset:SetIsEnabled(false)
	self.ToggleGroupTabs:CancelSelected()
	self.CurArmyBadgeType = nil
	self.ToggleGroupTabs:SetSelectedIndex(1)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgArmyBg, Params.UnitedIcon)
	if self.CurSelectedImpliedID > 0 then
		self.CurSelectedImpliedIndex = self:GetTotemListIndexForTotemID(self.CurSelectedImpliedID)
		if self.CurSelectedImpliedIndex then
			self.TabsViewAdapter:SetSelectedIndex(self.CurSelectedImpliedIndex)
			self.TabsViewAdapter:ScrollIndexIntoView(self.CurSelectedImpliedIndex)
		else
			self.TabsViewAdapter:CancelSelected()
		end
	else
		self.TabsViewAdapter:CancelSelected()
	end

	-- LSTR string:保  存
	self.BtnSave:SetText(LSTR(910041))
end

function ArmySelectBadgeWinView:OnHide()
	self.CurArmyBadgeType = -1
end

function ArmySelectBadgeWinView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.ToggleGroupTabs, self.OnGroupTabsSelectionChanged)
	UIUtil.AddOnClickedEvent(self, self.BtnRandom, self.OnClickedRandomBadge)
	UIUtil.AddOnClickedEvent(self, self.BtnReset, self.OnClickedBadgeReset)
	UIUtil.AddOnClickedEvent(self, self.BtnSave, self.OnClickedSave)
end

function ArmySelectBadgeWinView:OnRegisterGameEvent()

end

function ArmySelectBadgeWinView:OnRegisterBinder()

end

--- Tab切换
---@param Index number @下标 从0开始
function ArmySelectBadgeWinView:OnGroupTabsSelectionChanged(Index, ItemData, ItemView)
	local CurIndex = Index - 1
	if CurIndex == ArmyDefine.One and self.CurSelectedImpliedID < ArmyDefine.One then
		-- LSTR string:请先完成寓意物选择
		MsgTipsUtil.ShowTips(LSTR(910224))
		self.ToggleGroupTabs:SetSelectedIndex(1)
		return
	elseif CurIndex == ArmyDefine.CEditIdx and self.CurSelectedShieldIndex < ArmyDefine.One then
		-- LSTR string:请先完成盾纹选择
		MsgTipsUtil.ShowTips(LSTR(910225))
		self.ToggleGroupTabs:SetSelectedIndex(2)
		return
	end
	self:PlayAnimation(self.AnimUpdateSlot)
	if CurIndex ~= self.CurArmyBadgeType then
		self.CurArmyBadgeType = CurIndex
		local SelectedIndex
		local Values
		if self.CurArmyBadgeType == ArmyBadgeType.Implied then
			local TotemCfg = GroupEmblemTotemCfg:GetAllEmblemTotemCfg()
			Values = {}
			for _, Totem in ipairs(TotemCfg) do
				if Totem.CompanyIDs then
					for _, CompanyID in ipairs(Totem.CompanyIDs) do
						if self.CurGrandCompanyType and CompanyID == self.CurGrandCompanyType then
							table.insert(Values, Totem)
							break
						end
					end
				end
			end
			SelectedIndex = self.CurSelectedImpliedIndex
		elseif self.CurArmyBadgeType == ArmyBadgeType.Shield then
			Values = GroupEmblemIconCfg:GetAllEmblemIconCfg()
			SelectedIndex = self.CurSelectedShieldIndex
		elseif self.CurArmyBadgeType == ArmyBadgeType.ShieldBg then
			Values = GroupEmblemBackgroundCfg:GetAllEmblemBgCfg()
			SelectedIndex = self.CurSelectedBgIndex
		end
		self.TabsViewAdapter:UpdateAll(Values)
		if SelectedIndex and SelectedIndex > ArmyDefine.Zero then
			self.TabsViewAdapter:SetSelectedIndex(SelectedIndex)
			self.TabsViewAdapter:ScrollToIndex(SelectedIndex)
		else
			self.TabsViewAdapter:ClearSelectedItem()
		end
	end
end

--- 随机徽章
function ArmySelectBadgeWinView:OnClickedRandomBadge()
	local TotemAllCfg = GroupEmblemTotemCfg:GetAllEmblemTotemCfg()
	local ShieldCfg = GroupEmblemIconCfg:GetAllEmblemIconCfg()
	local BgCfg = GroupEmblemBackgroundCfg:GetAllEmblemBgCfg()
	local ImpliedCount = #TotemAllCfg
	local ImpliedIndex = self.CurSelectedImpliedID
	while ImpliedIndex == self.CurSelectedImpliedID do
		ImpliedIndex = math.floor(math.random(1, ImpliedCount))
		local TotemCfg = GroupEmblemTotemCfg:FindCfgByKey(ImpliedIndex)
		if TotemCfg.CompanyIDs then
			local IsFind = table.find_by_predicate(TotemCfg.CompanyIDs,function(A)
				return A == self.CurGrandCompanyType
			end)
			if not IsFind then
				ImpliedIndex = self.CurSelectedImpliedID
			end
		else
			ImpliedIndex = self.CurSelectedImpliedID
		end
	end
	self.CurSelectedImpliedID = ImpliedIndex
	self.CurSelectedImpliedIndex = self:GetTotemListIndexForTotemID(self.CurSelectedImpliedID)
	local ShieldNum = #ShieldCfg
	local ShieldIndex = math.floor(math.random(1, ShieldNum))
	while ShieldIndex == self.CurSelectedShieldIndex do
		ShieldIndex = math.floor(math.random(1, ShieldNum))
	end
	self.CurSelectedShieldIndex = ShieldIndex
	local BgNum = #BgCfg
	local BgIndex = math.floor(math.random(1, BgNum))
	while BgIndex == self.CurSelectedShieldIndex do
		BgIndex = math.floor(math.random(1, BgNum))
	end
	self.CurSelectedBgIndex = BgIndex
	self.ArmyBadgeItem:SetBadgeData({
		TotemID = self.CurSelectedImpliedID,
		IconID = self.CurSelectedShieldIndex,
		BackgroundID = self.CurSelectedBgIndex,
	})
	if self.CurArmyBadgeType == ArmyBadgeType.Implied then
		self.CurSelectedImpliedIndex = self:GetTotemListIndexForTotemID(self.CurSelectedImpliedID)
		self.TabsViewAdapter:SetSelectedIndex(self.CurSelectedImpliedIndex)
	elseif self.CurArmyBadgeType == ArmyBadgeType.Shield then
		self.TabsViewAdapter:SetSelectedIndex(self.CurSelectedShieldIndex)
	elseif self.CurArmyBadgeType == ArmyBadgeType.ShieldBg then
		self.TabsViewAdapter:SetSelectedIndex(self.CurSelectedBgIndex)
	end
	self.BtnSave:SetIsEnabled(true)
	self.BtnReset:SetIsEnabled(true)
end

function ArmySelectBadgeWinView:CheckedEdit()
	local Params = self.Params
	if nil == Params then
		return
	end
    if Params.BadgeData.TotemID ~= self.CurSelectedImpliedID or
		Params.BadgeData.IconID ~= self.CurSelectedShieldIndex or
		Params.BadgeData.BackgroundID ~= self.CurSelectedBgIndex
	then
		if self.CurSelectedImpliedID > 0 and self.CurSelectedShieldIndex > 0 and self.CurSelectedBgIndex > 0 then
			self.BtnSave:SetIsEnabled(true)
		else
			self.BtnSave:SetIsEnabled(false)
		end
		self.BtnReset:SetIsEnabled(true)
	else
		self.BtnSave:SetIsEnabled(false)
		self.BtnReset:SetIsEnabled(false)
	end
end

function ArmySelectBadgeWinView:GetTotemListIndexForTotemID(ID)
	local TotemCfg = GroupEmblemTotemCfg:GetAllEmblemTotemCfg()
	local CurSelected = 0
	for _, Totem in ipairs(TotemCfg) do
		if Totem.CompanyIDs then
			for _, CompanyID in ipairs(Totem.CompanyIDs) do
				if self.CurGrandCompanyType and CompanyID == self.CurGrandCompanyType then
					CurSelected = CurSelected + 1
					if Totem.ID == ID then			
						return CurSelected
					end
				end
			end
		end
	end
end

--- 重置
function ArmySelectBadgeWinView:OnClickedBadgeReset()
	-- LSTR string:提示
	MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(910144), LSTR(910190), self.Reset, nil, LSTR(910083), LSTR(910182))
end

function ArmySelectBadgeWinView:Reset()
	self.CurSelectedImpliedID = self.OldSelectedImpliedID
	self.CurSelectedImpliedIndex = self:GetTotemListIndexForTotemID(self.CurSelectedImpliedID)
	self.CurSelectedShieldIndex = self.OldSelectedShieldIndex
	self.CurSelectedBgIndex = self.OldSelectedBgIndex
	self.ArmyBadgeItem:SetBadgeData({
		TotemID = self.CurSelectedImpliedID,
		IconID = self.CurSelectedShieldIndex,
		BackgroundID = self.CurSelectedBgIndex,
	})
	self.BtnSave:SetIsEnabled(false)
	self.BtnReset:SetIsEnabled(false)
	self.ToggleGroupTabs:SetSelectedIndex(1)
	if self.CurSelectedImpliedIndex > 0 then
		self.CurSelectedImpliedIndex = self:GetTotemListIndexForTotemID(self.CurSelectedImpliedID)
		self.TabsViewAdapter:SetSelectedIndex(self.CurSelectedImpliedIndex)
	else
		self.TabsViewAdapter:CancelSelected()
	end
end

function ArmySelectBadgeWinView:OnClickedSave()
	if self.CurSelectedImpliedIndex < ArmyDefine.One then
		-- LSTR string:请先完成寓意物选择
		MsgTipsUtil.ShowTips(LSTR(910224))
		return
	elseif self.CurSelectedShieldIndex < ArmyDefine.One then
		-- LSTR string:请先完成盾纹选择
		MsgTipsUtil.ShowTips(LSTR(910225))
		return
	elseif self.CurSelectedBgIndex < ArmyDefine.One then
		-- LSTR string:请先完成背景选择
		MsgTipsUtil.ShowTips(LSTR(910226))
		return
	end
	if self.CommitedCallback ~= nil then
		self.CommitedCallback({
			TotemID = self.CurSelectedImpliedID,
			IconID = self.CurSelectedShieldIndex,
			BackgroundID = self.CurSelectedBgIndex,
		})
	end
	self:Hide()
end

return ArmySelectBadgeWinView