---
--- Author: anypkvcai
--- DateTime: 2023-04-03 15:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")
local EventID = require("Define/EventID")
local FLinearColor = _G.UE.FLinearColor
---@class CommHorTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnItem UFButton
---@field IconLock UFImage
---@field ImgBtnNormal UFImage
---@field ImgBtnSelect UFImage
---@field ImgIconNormal UFImage
---@field ImgIconSelect UFImage
---@field PanelNormal UFCanvasPanel
---@field PanelSelect UFCanvasPanel
---@field PanelTab UFCanvasPanel
---@field RedDot CommonRedDotView
---@field RedDot2 CommonRedDot2View
---@field SizeBox USizeBox
---@field TextTabName UFTextBlock
---@field AnimCheck UWidgetAnimation
---@field AnimUncheck UWidgetAnimation
---@field ParamColorNormal SlateColor
---@field ParamColorSelect SlateColor
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommHorTabItemView = LuaClass(UIView, true)

function CommHorTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnItem = nil
	--self.IconLock = nil
	--self.ImgBtnNormal = nil
	--self.ImgBtnSelect = nil
	--self.ImgIconNormal = nil
	--self.ImgIconSelect = nil
	--self.PanelNormal = nil
	--self.PanelSelect = nil
	--self.PanelTab = nil
	--self.RedDot = nil
	--self.RedDot2 = nil
	--self.SizeBox = nil
	--self.TextTabName = nil
	--self.AnimCheck = nil
	--self.AnimUncheck = nil
	--self.ParamColorNormal = nil
	--self.ParamColorSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommHorTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	self:AddSubView(self.RedDot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommHorTabItemView:OnInit()
	self.IsUnLock = false
	UIUtil.SetIsVisible(self.PanelNormal, true)
	UIUtil.SetIsVisible(self.PanelSelect, false)
end

function CommHorTabItemView:OnDestroy()

end

function CommHorTabItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil ~= Adapter then
		self:InitTab(Adapter.Params)
	end

	self:UpdateItem(Params.Data)
end

function CommHorTabItemView:OnHide()

end

function CommHorTabItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnItem, self.OnClickBtnItem)
end

function CommHorTabItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.UpdateTabRedDot, self.UpdateRedDot)
end

function CommHorTabItemView:OnRegisterBinder()

end

function CommHorTabItemView:OnClickBtnItem()
	local Params = self.Params
	if nil == Params then
		return
	end 

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end

	local ViewModel = self.Params.Data
	local View = Adapter.View
	if nil ~= View then
		if not self.IsUnLock then
			_G.ModuleOpenMgr:ModuleState(ViewModel.ModuleID)
			return
		end
		View:SetSelectedIndex(Params.Index)
	end
	self:UpdateItem(ViewModel)
end

function CommHorTabItemView:InitTab(Params)
	if nil == Params then
		return
	end

	UIUtil.SetIsVisible(self.ImgIconNormal, Params.ShowIcon)
	UIUtil.SetIsVisible(self.ImgIconSelect, Params.ShowIcon)
	UIUtil.SetIsVisible(self.TextTabName, Params.ShowText)
	
end

function CommHorTabItemView:OnSelectChanged(IsSelected)
	if not self.IsUnLock then
		return
	end

	UIUtil.SetIsVisible(self.PanelNormal, not IsSelected)
	UIUtil.SetIsVisible(self.PanelSelect, IsSelected)

	local Color = IsSelected and self.ColorSelect or self.ColorNormal
	local LinearColor = FLinearColor.FromHex(Color)
	self.TextTabName:SetColorAndOpacity(LinearColor)

	self:StopAllAnimations()

	if IsSelected then
		self:PlayAnimation(self.AnimCheck)
	else
		self:PlayAnimation(self.AnimUncheck)
	end
	self.IsSelected = IsSelected
end

function CommHorTabItemView:UpdateItem(Data)
	if nil == Data then
		return
	end

	local ModuleID 
	if Data.ModuleID == 0 then
		ModuleID = nil
	else
		ModuleID = Data.ModuleID
	end
	self.IsUnLock = _G.ModuleOpenMgr:CheckOpenState(ModuleID)

	if not self.IsUnLock then
		if Data.Name ~= nil then
			UIUtil.SetIsVisible(self.IconLock, false)
			UIUtil.SetIsVisible(self.SizeBox, true)
		else
			UIUtil.SetIsVisible(self.IconLock, true)
			UIUtil.SetIsVisible(self.SizeBox, false)
		end
	end

	self.TextTabName:SetText(Data.Name)

	local IconPathNormal = Data.IconPathNormal
	if nil ~= IconPathNormal then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgIconNormal, IconPathNormal)
	end

	local IconPathSelect = Data.IconPathSelect
	if nil ~= IconPathSelect then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgIconSelect, IconPathSelect)
	end

	local IconNormal = Data.IconNormal
	if nil ~= IconNormal then
		self.ImgIconNormal:SetBrush(IconNormal)
	end

	local IconSelect = Data.IconSelect
	if nil ~= IconSelect then
		self.ImgIconSelect:SetBrush(IconSelect)
	end

	local ImageNormal = Data.ImageNormal
	if nil ~= ImageNormal then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgBtnNormal, ImageNormal)
	end

	local ImageSelect = Data.ImageSelect
	if nil ~= ImageSelect then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgBtnSelect, ImageSelect)
	end

	local ColorNormal = Data.ColorNormal
	if nil ~= ColorNormal then
		self.ColorNormal = ColorNormal
	end

	local ColorSelect = Data.ColorSelect
	if nil ~= ColorSelect then
		self.ColorSelect = ColorSelect
	end

	local Color = self.IsSelected and self.ColorSelect or self.ColorNormal
	local LinearColor = FLinearColor.FromHex(Color)
	self.TextTabName:SetColorAndOpacity(LinearColor)

	---红点更新
	if Data.RedDotType ~= nil then
		self:UpdateRedDot(Data)
	end
end

function CommHorTabItemView:UpdateRedDot(Data)
	if Data == nil then
		Data = self.Params.Data
	end
	local RedDotName = nil
	local IsStrongReminder = false
	if Data.RedDotType == ProtoCS.NoteType.NOTE_TYPE_PRODUCTION then
		RedDotName = _G.CraftingLogMgr:GetRedDotName(nil, Data.Index)
		IsStrongReminder = _G.CraftingLogMgr:GetRedDotIsStrongReminder(RedDotName)
	elseif Data.RedDotType == ProtoCS.NoteType.NOTE_TYPE_COLLECTION then
		RedDotName = _G.GatheringLogMgr:GetRedDotName(nil, Data.Index)
		IsStrongReminder = _G.GatheringLogMgr:GetRedDotIsStrongReminder(RedDotName)
	else
		RedDotName = Data.RedDotName
		IsStrongReminder = Data.IsStrongReminder
	end
	
	self.RedDot:SetRedDotNameByString("")
	self.RedDot2:SetRedDotNameByString("")
	if RedDotName then
		if IsStrongReminder then --如果是强提醒
			self.RedDot:SetRedDotNameByString(RedDotName)
		else
			self.RedDot2:SetRedDotNameByString(RedDotName)
		end	
	end
end


return CommHorTabItemView