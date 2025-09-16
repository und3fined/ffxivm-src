---
--- Author: enqingchen
--- DateTime: 2022-03-14 16:52
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EquipmentMgr = _G.EquipmentMgr
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local ProtoCommon = require("Protocol/ProtoCommon")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

--@ViewModel
local MagicsparInlayVM = require("Game/Magicspar/VM/MagicsparInlayVM")

local OvalOriginPos = {125, 210, 270, 330, 55}
local OvalParamA, OvalParamB = 400, 150
local OvalOffset = _G.UE.FVector2D(0, 50)
local FMath = _G.UE.UKismetMathLibrary
local OvalScaleCfg = 
{
	[1] = {Angle = 90, Scale = 0.5};
	[2] = {Angle = 270, Scale = 1.0};
}

local MsgBoxUtil = _G.MsgBoxUtil

---@class MagicsparInlayView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field Btn_Back CommonCloseBtnView
---@field Btn_BanInlay Comm1BtnLView
---@field Btn_Inlay Comm2BtnLView
---@field Btn_NormalInlay Comm1BtnLView
---@field Btn_Remove Comm2BtnLView
---@field FCanvasPanel_0 UFCanvasPanel
---@field FImg_IconEquip UFImage
---@field FImg_IconEquipMask UFImage
---@field InforCommItem EquipmentInforCommItemView
---@field InlayPanel UFCanvasPanel
---@field InlayPanel1 UFCanvasPanel
---@field RichText_Rate URichTextBox
---@field RichText_SuccessRate URichTextBox
---@field SlotItem01 MagicsparInlaySlotItemView
---@field SlotItem02 MagicsparInlaySlotItemView
---@field SlotItem03 MagicsparInlaySlotItemView
---@field SlotItem04 MagicsparInlaySlotItemView
---@field SlotItem05 MagicsparInlaySlotItemView
---@field SoltEmptyTips UFCanvasPanel
---@field TableView_Magicspar UTableView
---@field TableView_Slot UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MagicsparInlayView = LuaClass(UIView, true)

function MagicsparInlayView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.Btn_Back = nil
	--self.Btn_BanInlay = nil
	--self.Btn_Inlay = nil
	--self.Btn_NormalInlay = nil
	--self.Btn_Remove = nil
	--self.FCanvasPanel_0 = nil
	--self.FImg_IconEquip = nil
	--self.FImg_IconEquipMask = nil
	--self.InforCommItem = nil
	--self.InlayPanel = nil
	--self.InlayPanel1 = nil
	--self.RichText_Rate = nil
	--self.RichText_SuccessRate = nil
	--self.SlotItem01 = nil
	--self.SlotItem02 = nil
	--self.SlotItem03 = nil
	--self.SlotItem04 = nil
	--self.SlotItem05 = nil
	--self.SoltEmptyTips = nil
	--self.TableView_Magicspar = nil
	--self.TableView_Slot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MagicsparInlayView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.Btn_Back)
	self:AddSubView(self.Btn_BanInlay)
	self:AddSubView(self.Btn_Inlay)
	self:AddSubView(self.Btn_NormalInlay)
	self:AddSubView(self.Btn_Remove)
	self:AddSubView(self.InforCommItem)
	self:AddSubView(self.SlotItem01)
	self:AddSubView(self.SlotItem02)
	self:AddSubView(self.SlotItem03)
	self:AddSubView(self.SlotItem04)
	self:AddSubView(self.SlotItem05)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MagicsparInlayView:OnInit()
	self.ViewModel = MagicsparInlayVM.New()
	self.AdapterSlotTableView = UIAdapterTableView.CreateAdapter(self, self.TableView_Slot)
	self.AdapterItemTableView = UIAdapterTableView.CreateAdapter(self, self.TableView_Magicspar, self.OnMagicsparSelect, false)
	self.Btn_Back:SetCallback(self, self.OnSelectBackClick)
end

function MagicsparInlayView:OnDestroy()

end

function MagicsparInlayView:UpdateUI()
	self.Tag = self.Params.Tag
	self.Item = EquipmentMgr:GetItemByGID(self.Params.GID)
	self.ViewModel:InitMagicsparByGID(self.Params.GID, self.Item)
	self.InforCommItem:InitItem(self.Item.ResID, self.Params.GID)
	self.ViewModel.EquipmentIconPath = self.InforCommItem.EquipSlot.ViewModel.IconPath
	self:UpdateInlayAllSlot()
end

function MagicsparInlayView:OnShow()
	self:UpdateUI()
	self:RecoderMagicsparOriginPos()

	self.bAnimation = false
	self.IconEquipSize = UIUtil.CanvasSlotGetSize(self.FImg_IconEquip)
	self.OriginLocation = UIUtil.CanvasSlotGetPosition(self.FImg_IconEquip) + self.IconEquipSize/2 + OvalOffset
end

function MagicsparInlayView:RecoderMagicsparOriginPos()
	self.SlotViewOriginPos = {}
	for i = 1, 5 do
		local SlotView = self["SlotItem0"..i]
		local SlotViewSize = UIUtil.CanvasSlotGetSize(SlotView)
		local SlotPosition = UIUtil.CanvasSlotGetPosition(SlotView)
		self.SlotViewOriginPos[i] = {Pos = SlotPosition, Size = SlotViewSize}
	end
end

function MagicsparInlayView:SetMagicsparPosOrigin()
	self.bAnimation = false
	for key, value in pairs(self.SlotViewOriginPos) do
		local SlotView = self["SlotItem0"..key]
		UIUtil.CanvasSlotSetPosition(SlotView, value.Pos)
		UIUtil.CanvasSlotSetSize(SlotView, value.Size)
		SlotView:SetRenderScale(_G.UE.FVector2D(1, 1))
		SlotView:SetRenderOpacity(1)
	end
end

function MagicsparInlayView:SetMagicsparOvalPosOrigin(Index)
	self.CurOvalIndex = 3
	self.AnimToIndex = 3
	self.AnimTarAngle = {}
	for key, value in pairs(OvalOriginPos) do
		self.AnimTarAngle[key] = value
	end
	
	self:MoveMagicspar(Index)

	self.AnimCurAngle = {}
	for key, value in pairs(self.AnimTarAngle) do
		self.AnimCurAngle[key] = value
	end

	self:SetMagicsparOvalPosByList(self.AnimCurAngle)
	
	self.bAnimation = false
	self.CurOvalIndex = Index
end

function MagicsparInlayView:OnHide()

end

function MagicsparInlayView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn_NormalInlay.Button, self.OnNormalInlayClick)
	UIUtil.AddOnClickedEvent(self, self.Btn_BanInlay.Button, self.OnBanInlayClick)
	UIUtil.AddOnClickedEvent(self, self.Btn_Remove.Button, self.OnRemoveClick)
	UIUtil.AddOnClickedEvent(self, self.Btn_Inlay.Button, self.OnInlayClick)
end

function MagicsparInlayView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.MagicsparInlaySucc, self.OnInlaySucc)
	self:RegisterGameEvent(_G.EventID.MagicsparUnInlaySucc, self.OnUnInlaySucc)
end

function MagicsparInlayView:OnRegisterBinder()
	local Binders = {
		--{ "Title", UIBinderSetText.New(self, self.Text_MagicsparInlay) },
		{ "EquipmentIconPath", UIBinderSetBrushFromAssetPath.New(self, self.FImg_IconEquip) },
		{ "EquipmentIconPath", UIBinderSetBrushFromAssetPath.New(self, self.FImg_IconEquipMask) },
		{ "CurSelect", UIBinderValueChangedCallback.New(self, nil, self.OnSlotSelectChange) },
		{ "lstMagicsparInlayStatusItemVM", UIBinderUpdateBindableList.New(self, self.AdapterSlotTableView) },
		{ "bSelect", UIBinderSetIsVisible.New(self, self.FImg_IconEquipMask) },
		{ "bSelect", UIBinderSetIsVisible.New(self, self.TableView_Magicspar) },
		{ "bSelect", UIBinderSetIsVisible.New(self, self.InlayPanel) },
		{ "bSelect", UIBinderSetIsVisible.New(self, self.TableView_Slot, true, true) },
		{ "bSelect", UIBinderSetIsVisible.New(self, self.Btn_Back, false) },
		{ "bSelect", UIBinderSetIsVisible.New(self, self.Btn_Close, true, true) },
		{ "bSelect", UIBinderSetIsVisible.New(self, self.Btn_Inlay, true) },
		{ "bSelectNomal", UIBinderSetIsVisible.New(self, self.Btn_NormalInlay, false) },
		{ "bSelectNomal", UIBinderSetIsVisible.New(self, self.Btn_BanInlay, true) },
		{ "lstMagicsparInlayRecomItemVM", UIBinderUpdateBindableList.New(self, self.AdapterItemTableView) },
		{ "bMagicsparItemEmpty", UIBinderSetIsVisible.New(self, self.SoltEmptyTips) },
		{ "CurRatio", UIBinderSetTextFormat.New(self, self.RichText_Rate, "%d%%") },
		{ "EquipmentInUse", UIBinderSetIsVisible.New(self, self.Img_InUse) },
		{ "bListSelectUse", UIBinderSetIsVisible.New(self, self.Btn_Remove, false) },
		{ "bListSelectUse", UIBinderSetIsVisible.New(self, self.InlayPanel1, true) },
		{ "bSelect", UIBinderSetIsVisible.New(self, self.RichText_SuccessRate) },
		{ "bSelect", UIBinderSetIsVisible.New(self, self.RichText_Rate) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function MagicsparInlayView:OnMagicsparSelect(Index, ItemData, ItemView)
	local MagicsparInlayRecomItemVM = ItemData
	self.MagicsparItemSelectIndex = Index
	self.SelectGemResID = MagicsparInlayRecomItemVM.ResID
	self.ViewModel.bListSelectUse = MagicsparInlayRecomItemVM.bUse
end

function MagicsparInlayView:OnNormalInlayClick()
	if self.ViewModel.bMagicsparItemEmpty == true then
		MsgTipsUtil.ShowTips(LSTR("1060006"))
		return
	end
	EquipmentMgr:SendEquipInlay(self.SelectGemResID, self.Params.GID, self.ViewModel.EquipmentPart, self.ViewModel.CurSelect, self.ViewModel.EquipmentInUse)
end

function MagicsparInlayView:OnBanInlayClick()
	if self.ViewModel.bMagicsparItemEmpty == true then
		MsgTipsUtil.ShowTips(LSTR("1060006"))
		return
	end
	
    local GemInfo = self.Item.Attr.Equip.GemInfo.CarryList
	local ResID = GemInfo[self.ViewModel.CurSelect]
	if ResID ~= nil and ResID > 0 then
		self.ShowTipsTag = 1
		local Title = nil
		MsgBoxUtil.ShowMsgBoxTwoOp(self, Title, 
		string.format(_G.LSTR("1060009"), self.ViewModel.CurRatio), -- 镶嵌新的禁忌魔晶石会自动卸下已镶嵌的魔晶石，卸下重新镶嵌魔晶石成功率为<span color=\"#f80003ff\">%d%%</>，是否继续？
		self.OnTipsSure)
		--UIViewMgr:ShowView(UIViewID.MagicsparInlayTips, {self, self.OnTipsSure})
	else
		EquipmentMgr:SendEquipInlay(self.SelectGemResID, self.Params.GID, self.ViewModel.EquipmentPart, self.ViewModel.CurSelect, self.ViewModel.EquipmentInUse)
	end
end

function MagicsparInlayView:OnRemoveClick()
	if self.ViewModel.MagicsparInlayCfg.Hole[self.ViewModel.CurSelect].Type == ProtoCommon.hole_type.HOLE_TYPE_NORMAL then
		EquipmentMgr:SendEquipUnInlay(self.Params.GID, self.ViewModel.EquipmentPart, self.ViewModel.CurSelect, self.Tag)
	else
		self.ShowTipsTag = 2
		UIViewMgr:ShowView(UIViewID.MagicsparInlayTips, {self, self.OnTipsSure})
	end
end

function MagicsparInlayView:OnTipsSure()
	if (self.ShowTipsTag == 1) then
		EquipmentMgr:SendEquipInlay(self.SelectGemResID, self.Params.GID, self.ViewModel.EquipmentPart, self.ViewModel.CurSelect, self.ViewModel.EquipmentInUse)
	elseif (self.ShowTipsTag == 2) then
		EquipmentMgr:SendEquipUnInlay(self.Params.GID, self.ViewModel.EquipmentPart, self.ViewModel.CurSelect, self.Tag)
	end
end

function MagicsparInlayView:OnInlayClick()
	self:OnInlaySlotClick(1)
end

function MagicsparInlayView:OnSelectBackClick()
	--self:OnInlaySlotClick(3)
	self:SetMagicsparPosOrigin()
	self.ViewModel:UpSelectSlot()
end

function MagicsparInlayView:OnSlotSelectChange(NewValue, OldValue)
	--把魔晶石从NewValue逆时针转动到椭圆中心
	if NewValue ~= nil and NewValue ~= self.AnimToIndex then 
		self:MoveMagicspar(NewValue)
	end
	self:SetSlotSelect(NewValue, true)
	self:SetSlotSelect(OldValue, false)
end

function MagicsparInlayView:SetSlotSelect(Index, bSelect)
	if Index == nil then return end	
	local InlaySlotItem = self.InforCommItem["InlaySlotItem"..Index]
	InlaySlotItem.ViewModel.bSelect = bSelect
	local SlotView = self["SlotItem0"..Index]
	SlotView.ViewModel.bSelect = bSelect
end

function MagicsparInlayView:UpdateInlayAllSlot()
	local lst = self.InforCommItem.ViewModel.Item.Attr.Equip.GemInfo.CarryList
	local iNomalCount = self.InforCommItem.ViewModel.MagicsparInlayCfg.NomalCount
	local iBanCount = self.InforCommItem.ViewModel.MagicsparInlayCfg.BanCount
	for i = 1, iNomalCount do
		self:UpdateInlaySlot(i, lst[i], true)
	end
	for i = 1, iBanCount do
		self:UpdateInlaySlot(iNomalCount + i, lst[iNomalCount + i], false)
	end
end

function MagicsparInlayView:UpdateInlaySlot(Index, ResID, bNomal)
	local SlotView = self["SlotItem0"..Index]
	SlotView:InitSlot(ResID, Index, bNomal, function ()
		self:OnInlaySlotClick(Index)
	end)
end

function MagicsparInlayView:OnInlaySlotClick(Index, bKeep)
	if self.bAnimation == true and Index ~= self.ViewModel.CurSelect then
		return
	end

	if self.ViewModel.bSelect == false then
		--第一次选中
		self:SetMagicsparOvalPosOrigin(Index)
	end

	local CurIndex = self.MagicsparItemSelectIndex
	self.ViewModel:SelectSlot(Index)
	if self.ViewModel.bMagicsparItemEmpty == false then
		self.AdapterItemTableView:SetSelectedIndex(1)
	end
	if bKeep == true then
		if CurIndex <= #self.ViewModel.lstMagicsparInlayRecomItemVM then
			self.AdapterItemTableView:SetSelectedIndex(CurIndex)
		else
			self.AdapterItemTableView:SetSelectedIndex(#self.ViewModel.lstMagicsparInlayRecomItemVM)
		end
	else
		self.AdapterItemTableView:ScrollToTop()
	end
end

function MagicsparInlayView:OnInlaySucc(Params)
	if (Params.GID == self.Params.GID) then
		local bSucc = Params.ResID ~= nil and Params.ResID > 0
		if bSucc then
			self:OnSelectBackClick()
			MsgTipsUtil.ShowTips(LSTR("1060004"))
		else
			self:OnInlaySlotClick(self.ViewModel.CurSelect, true)
			MsgTipsUtil.ShowTips(LSTR("1060005"))
		end
		self:UpdateUI()
	end
end

function MagicsparInlayView:OnUnInlaySucc(Params)
	if (Params.GID == self.Params.GID) then
		MsgTipsUtil.ShowTips(LSTR("1060007"))
		self:UpdateUI()
		self:OnInlaySlotClick(self.ViewModel.CurSelect)
	end
end

local function NomalAngle(InAngle)
	if InAngle < 0 then
		return InAngle + 360
	end
	if InAngle >= 360 then
		return InAngle - 360
	end
	return InAngle
end

--会重写蓝图中的Tick函数
function MagicsparInlayView:Tick(_, InDeltaTime)
	if self.bAnimation == nil or self.bAnimation == false then
		return
	end

	local Count = #self.AnimCurAngle
	for i = 1, Count do
		local CurAngle, TarAngle = self.AnimCurAngle[i], self.AnimTarAngle[i]
		if self.bAnimLeft == true and CurAngle > TarAngle then
			CurAngle = CurAngle - 360
		end
		if self.bAnimLeft == false and CurAngle < TarAngle then
			CurAngle = CurAngle + 360
		end

		self.AnimCurAngle[i] = NomalAngle(FMath.FInterpTo(CurAngle, TarAngle, InDeltaTime, 3.0))
		self:SetMagicsparOvalPos(i, self.AnimCurAngle[i])
	end

	local bEnd = true
	if self.AnimToIndex ~= nil and self.AnimCurAngle[self.AnimToIndex] ~= nil and self.AnimTarAngle[self.AnimToIndex] ~= nil and 
		math.abs(self.AnimCurAngle[self.AnimToIndex] - self.AnimTarAngle[self.AnimToIndex]) > 0.1 then
		bEnd = false
	else
		for i = 1, Count do
			self.AnimCurAngle[i] = self.AnimTarAngle[i]
			self:SetMagicsparOvalPos(i, self.AnimCurAngle[i])
		end
	end

	if bEnd then
		--插值动画结束
		--print("插值动画结束")
		self.bAnimation = false
		self.CurOvalIndex = self.AnimToIndex
	end
end

function MagicsparInlayView:MoveMagicspar(ToIndex)
	--print("MoveMagicspar From "..tostring(self.CurOvalIndex).." To "..tostring(ToIndex))
	if ToIndex == self.CurOvalIndex or ToIndex == nil then
		return
	end

	self.bAnimation = true
	self.AnimToIndex = ToIndex

	local MoveIndex = ToIndex - self.CurOvalIndex
	local Count = #self.AnimTarAngle
	local AnimTarAngle = {}
	local LeftCount, RightCount = 0, 0
	for i = 1, Count do
		AnimTarAngle[i] = self.AnimTarAngle[(Count + i - 1 - MoveIndex)%Count + 1]
		local Detal = AnimTarAngle[i] - self.AnimTarAngle[i]
		if Detal > 0 then
			LeftCount = LeftCount + 1
		else
			RightCount = RightCount + 1
		end
	end
	self.bAnimLeft = LeftCount > RightCount
	self.AnimTarAngle = AnimTarAngle
	--print("self.AnimCurAngle = "..table_to_string(self.AnimCurAngle))
	--print("self.AnimTarAngle = "..table_to_string(self.AnimTarAngle))
end

function MagicsparInlayView:SetMagicsparOvalPosByList(ListAngle)
	for i = 1, #ListAngle do
		self:SetMagicsparOvalPos(i, ListAngle[i])
	end
end

function MagicsparInlayView:SetMagicsparOvalPos(Index, Angle)
	local SlotView = self["SlotItem0"..Index]
	local SlotViewSize = UIUtil.CanvasSlotGetSize(SlotView)
	local X, Y = self:CalculateOvalXY(Angle)
	local ScreenLocation = _G.UE.FVector2D(X, -Y) + self.OriginLocation - SlotViewSize / 2
	SlotView.Slot:SetPosition(ScreenLocation)

	--计算Scale
	local Scale = 1.0
	local NomalAngle = NomalAngle(Angle)
	if NomalAngle >= OvalScaleCfg[1].Angle and NomalAngle <= OvalScaleCfg[2].Angle then
		Scale = (NomalAngle - OvalScaleCfg[1].Angle)/(OvalScaleCfg[2].Angle - OvalScaleCfg[1].Angle)*(OvalScaleCfg[2].Scale -  OvalScaleCfg[1].Scale) + OvalScaleCfg[1].Scale
	elseif NomalAngle < OvalScaleCfg[1].Angle then
		Scale = (OvalScaleCfg[1].Angle - NomalAngle)/(OvalScaleCfg[2].Angle - OvalScaleCfg[1].Angle)*(OvalScaleCfg[2].Scale -  OvalScaleCfg[1].Scale) + OvalScaleCfg[1].Scale
	elseif NomalAngle > OvalScaleCfg[2].Angle then
		Scale = OvalScaleCfg[2].Scale - (NomalAngle - OvalScaleCfg[2].Angle)/(OvalScaleCfg[2].Angle - OvalScaleCfg[1].Angle)*(OvalScaleCfg[2].Scale -  OvalScaleCfg[1].Scale)
	end
	SlotView:SetRenderScale(_G.UE.FVector2D(Scale, Scale))
	local Alpha = (Scale - OvalScaleCfg[1].Scale)/(OvalScaleCfg[2].Scale - OvalScaleCfg[1].Scale)
	SlotView:SetRenderOpacity(Alpha)
end

--根据椭圆的参数方程计算XY坐标
--x=acosθ
--y=bsinθ
--θ = [0,360] 从X轴正向开始
function MagicsparInlayView:CalculateOvalXY(InAngle)
	local Value = _G.math.rad(InAngle)
	return OvalParamA*_G.math.cos(Value), OvalParamB*_G.math.sin(Value)
end

return MagicsparInlayView