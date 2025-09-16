---
--- Author: Administrator
--- DateTime: 2024-01-23 16:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")

---@class CommDropDownListItemNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnItem UFButton
---@field IconAttire UFImage
---@field IconPanel UFCanvasPanel
---@field ImgIcon UFImage
---@field ImgLine UFImage
---@field ImgSelect UFImage
---@field LinePanel UFCanvasPanel
---@field RedDot CommonRedDotView
---@field SelectPanel UFCanvasPanel
---@field SizeBox USizeBox
---@field TextContent URichTextBox
---@field TextNew UFTextBlock
---@field TextQuantity UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommDropDownListItemNewView = LuaClass(UIView, true)

function CommDropDownListItemNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnItem = nil
	--self.IconAttire = nil
	--self.IconPanel = nil
	--self.ImgIcon = nil
	--self.ImgLine = nil
	--self.ImgSelect = nil
	--self.LinePanel = nil
	--self.RedDot = nil
	--self.SelectPanel = nil
	--self.SizeBox = nil
	--self.TextContent = nil
	--self.TextNew = nil
	--self.TextQuantity = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommDropDownListItemNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommDropDownListItemNewView:OnInit()
	self.Binders = {
		{"Name", UIBinderSetText.New(self, self.TextContent)},
		{"TextNewStr", UIBinderSetText.New(self, self.TextNew)},
		{"TextQuantityStr", UIBinderSetText.New(self, self.TextQuantity)},
		{"IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon)},
		{"RightIconPath", UIBinderSetBrushFromAssetPath.New(self, self.IconAttire)},
		{"IsNew", UIBinderSetIsVisible.New(self, self.TextNew)},
		{"bTextQuantityShow", UIBinderSetIsVisible.New(self, self.TextQuantity)},
		{"IsShowIcon", UIBinderSetIsVisible.New(self, self.SizeBox)},
		{"IsShowRightIcon", UIBinderSetIsVisible.New(self, self.IconAttire)},
		{"IsShowRightPanel", UIBinderSetIsVisible.New(self, self.IconPanel)},
		{"IconPath", UIBinderValueChangedCallback.New(self, nil, self.OnIconUpdata)},
		{"RightIconPath", UIBinderValueChangedCallback.New(self, nil, self.OnRightIconUpdata)},
		{"IsNew", UIBinderValueChangedCallback.New(self, nil, self.OnIsNewUpdata)},
		{"RedDotID", UIBinderValueChangedCallback.New(self, nil, self.OnSetRedDotID)},
		{"IsShowPlayingIcon", UIBinderSetIsVisible.New(self, self.IconPlaingPanel)},
	}
end

function CommDropDownListItemNewView:OnDestroy()

end

function CommDropDownListItemNewView:OnShow()
	self:UpdateItem(self.Params)
	self:SetStyle()
end

function CommDropDownListItemNewView:OnHide()

end

function CommDropDownListItemNewView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnItem, self.OnBtnClick)
end

function CommDropDownListItemNewView:OnBtnClick()
	local IsSelect = true
	local Index
	local Adapter
	local VM
	if self.Params then
		Adapter = self.Params.Adapter
		Index = self.Params.Index
		VM = self.Params.Data
	end
	if VM then
		if VM.ClickFunc then
			IsSelect = VM.ClickFunc(VM)
		elseif VM.IsSelectedFunc then
			IsSelect = VM.IsSelectedFunc(VM, Index)
		end
	end
	if Adapter and IsSelect then
		Adapter:OnItemClicked(self, Index)
	end
end

function CommDropDownListItemNewView:OnRegisterGameEvent()

end

function CommDropDownListItemNewView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	if not self.ViewModel.IsItemVM then
		return
	end
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function CommDropDownListItemNewView:OnIconUpdata(IconPath)
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	if nil == IconPath then
		VM.IsShowIcon = false
	end
end

function CommDropDownListItemNewView:OnSetRedDotID(ID)
	if nil ~= ID and self.RedDot then
		UIUtil.SetIsVisible( self.RedDot, true )
		self.RedDot:SetRedDotIDByID(ID)
	end
end

function CommDropDownListItemNewView:OnRightIconUpdata(RightIconPath)
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	if nil == RightIconPath then
		VM.IsShowRightIcon = false
		if not VM.IsNew then
			VM.IsShowRightPanel = false
		end
	end
end

function CommDropDownListItemNewView:OnIsNewUpdata(IsNew)
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	if nil == IsNew then
		if not VM.RightIconPath then
			VM.IsShowRightPanel = false
		end
	end
end

function CommDropDownListItemNewView:OnSelectChanged(IsSelected)
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	UIUtil.SetIsVisible(self.SelectPanel, IsSelected)

	if IsSelected then
		--UIUtil.TextBlockSetColorAndOpacityHex(self.TextContent, COLOR_SELECTED)
		--UIUtil.TextBlockSetColorAndOpacity(self.TextContent, VM.ItemTextContenSelectedColor.R, VM.ItemTextContenSelectedColor.G, VM.ItemTextContenSelectedColor.B, VM.ItemTextContenSelectedColor.A)
		if VM.ItemTextContenSelectedColor then
			self.TextContent:SetColorAndOpacity(VM.ItemTextContenSelectedColor)
			self.TextQuantity:SetColorAndOpacity(VM.ItemTextContenSelectedColor)
			if VM.ImgIconColorbSameasText then
				self.ImgIcon:SetColorAndOpacity(VM.ItemTextContenSelectedColor)
			end
		end
	else
		--UIUtil.TextBlockSetColorAndOpacityHex(self.TextContent, COLOR_NORMAL)
		if VM.ItemTextContentColor then
			self.TextContent:SetColorAndOpacity(VM.ItemTextContentColor)
			self.TextQuantity:SetColorAndOpacity(VM.ItemTextContentColor)
			if VM.ImgIconColorbSameasText then
				self.ImgIcon:SetColorAndOpacity(VM.ItemTextContentColor)
			end
		end
	end
end

function CommDropDownListItemNewView:UpdateItem(Params)
	if nil == Params then
		return
	end

	local Index = Params.Index
	local Adapter = Params.Adapter
	local Data = Params.Data

	---红点更新
	if Data.RedDotType ~= nil or Data.RedDotData ~= nil then
		self:UpdateRedDot(Data)
	end

	--- 发现有其他蓝图引用下拉列表Item，保持适配原有逻辑
	if Data and Data.IsItemVM then
		UIUtil.SetIsVisible(self.LinePanel, Index < Adapter:GetNum())
		return
	end

	self.TextContent:SetText(Data.Name)
	local IconPath = Data.IconPath
	if nil ~= IconPath then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, IconPath)
	end

	local RightIconPath = Data.RightIconPath
	if nil ~= RightIconPath then
		UIUtil.ImageSetBrushFromAssetPath(self.IconAttire, IconPath)
	end

	local IsNew = Data.IsNew

	local TextNewStr = Data.TextNewStr
	if nil ~= TextNewStr then
		self.TextNew:SetText(Data.TextNewStr)
	end

	UIUtil.SetIsVisible(self.ImgIcon, nil ~= IconPath)
	UIUtil.SetIsVisible(self.IconAttire, nil ~= RightIconPath)
	UIUtil.SetIsVisible(self.IconPanel, nil ~= RightIconPath or nil ~= IsNew )
	UIUtil.SetIsVisible(self.TextNew, IsNew)

	UIUtil.SetIsVisible(self.LinePanel, Index < Adapter:GetNum())
end

function CommDropDownListItemNewView:UpdateRedDot(Data)	
	local RedDotName = nil
	local IsStrongReminder = false
	if Data.RedDotType == ProtoCS.NoteType.NOTE_TYPE_PRODUCTION then
		RedDotName = _G.CraftingLogMgr:GetRedDotName(Data.Prof,Data.HorIndex, Data.DropdownIndex or 0)
		IsStrongReminder = _G.CraftingLogMgr:GetRedDotIsStrongReminder(RedDotName)
	elseif Data.RedDotType == ProtoCS.NoteType.NOTE_TYPE_COLLECTION then
		RedDotName = _G.GatheringLogMgr:GetRedDotName(Data.Prof,Data.HorIndex, Data.DropdownIndex or 0)
		IsStrongReminder = _G.GatheringLogMgr:GetRedDotIsStrongReminder(RedDotName)
	end
	
	local RedDotData = Data.RedDotData
	if RedDotData ~= nil then
		RedDotName = RedDotData.RedDotName
		IsStrongReminder = RedDotData.IsStrongReminder
	end

	self.RedDot:SetRedDotNameByString("")
	--self.RedDot2:SetRedDotNameByString("")
	if RedDotName then
		self.RedDot:SetRedDotNameByString(RedDotName)
		if IsStrongReminder then --如果是强提醒
			self.RedDot:SetStyle(RedDotDefine.RedDotStyle.NormalStyle)
		else
			self.RedDot:SetStyle(RedDotDefine.RedDotStyle.SecondStyle)
		end	
	end
end

function CommDropDownListItemNewView:SetStyle()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end

	---先用SpecifiedColor判断是否是SlateColor,不是的话，不设置，防止崩溃
	-- if VM.ImgLineColor and VM.ImgLineColor.SpecifiedColor  then
	-- 	self.ImgLine:SetBrushTintColor(VM.ImgLineColor)
	-- end
	-- if VM.ImgSelectColor and VM.ImgSelectColor.SpecifiedColor then
	-- 	self.ImgSelect:SetBrushTintColor(VM.ImgSelectColor)
	-- end
	if VM.ImgLineColor then
		self.ImgLine:SetColorAndOpacity(VM.ImgLineColor)
	end
	if VM.ImgSelectColor then
		self.ImgSelect:SetColorAndOpacity(VM.ImgSelectColor)
	end
end

return CommDropDownListItemNewView