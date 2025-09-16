---
--- Author: xingcaicao
--- DateTime: 2023-03-20 21:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local SettingsUtils = require("Game/Settings/SettingsUtils")
local SettingsDefine = require("Game/Settings/SettingsDefine")
local MsgBoxUtil = require("Utils/MsgBoxUtil")

local LSTR = _G.LSTR
local ItemDisplayStyle = SettingsDefine.ItemDisplayStyle

---@class SettingsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field DropDownList CommDropDownListView
---@field HyperlinkBar CommHyperlinkBarView
---@field PanelDropDownList UFCanvasPanel
---@field PanelHyperlink UFCanvasPanel
---@field PanelSettingsColor UFCanvasPanel
---@field PanelSlider UFCanvasPanel
---@field SettingsColorSettingsItem SettingsColorSettingsItemView
---@field SliderBar CommSliderHorizontalView
---@field TextItemContent UFTextBlock
---@field TextSliderValue UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SettingsItemView = LuaClass(UIView, true)

function SettingsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.DropDownList = nil
	--self.HyperlinkBar = nil
	--self.PanelDropDownList = nil
	--self.PanelHyperlink = nil
	--self.PanelSettingsColor = nil
	--self.PanelSlider = nil
	--self.SettingsColorSettingsItem = nil
	--self.SliderBar = nil
	--self.TextItemContent = nil
	--self.TextSliderValue = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SettingsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.DropDownList)
	self:AddSubView(self.HyperlinkBar)
	self:AddSubView(self.SettingsColorSettingsItem)
	self:AddSubView(self.SliderBar)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SettingsItemView:OnInit()

end

function SettingsItemView:OnDestroy()

end

function SettingsItemView:OnShow()
	if nil == self.Params or nil == self.Params.Data then
		return
	end

	self.ItemVM = self.Params.Data

	UIUtil.SetIsVisible(self.PanelSlider, false)
	UIUtil.SetIsVisible(self.PanelHyperlink, false)
	UIUtil.SetIsVisible(self.PanelDropDownList, false)
	UIUtil.SetIsVisible(self.PanelSettingsColor, false)

	local Style = self.ItemVM.DisplayStyle
	if Style == ItemDisplayStyle.Slider then
		self:SetSlider()

	elseif Style == ItemDisplayStyle.Hyperlink then
		self:SetHyperlink()

	elseif Style == ItemDisplayStyle.DropDownList then
		self:SetDropDownList()

	elseif Style == ItemDisplayStyle.Button then
		self:SetClieckCallback()

	elseif Style == ItemDisplayStyle.ColorPalette then
		self:SetColorPaletteItem()
	elseif Style == ItemDisplayStyle.TextByCustomUI then
		self:SetCustomUIItem()
	end
end

function SettingsItemView:OnHide()

end

function SettingsItemView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownList, self.OnSelectionChangedDropDownList)
end

function SettingsItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OnePictureFeatureChg, self.OnOnePictureFeatureChg)
	self:RegisterGameEvent(_G.EventID.QualityLevelChg, self.OnQualityLevelChg)


end

function SettingsItemView:OnRegisterBinder()

end

--2-7,11-12那些特性有修改的话，就变成自定义的了
function SettingsItemView:OnOnePictureFeatureChg(Params)
	local SettingCfg = self.ItemVM.SettingCfg
	if Params and string.find(SettingCfg.SaveKey, "QualityLevel") then
		FLOG_INFO("Setting OnePictureFeatureChg %d", Params)
		--画质等级改成自定义
		self.DropDownList:SetSelectedIndex(6, nil , true)
	end
end

--画质等级切换，QualityLevel:0-4
function SettingsItemView:OnQualityLevelChg(QualityLevel)
	local SettingCfg = self.ItemVM.SettingCfg
	local ID = SettingCfg.ID
	FLOG_INFO("##Setting OnQualityLevelChg Level:%d, ID:%d", QualityLevel, ID)
	local TabPicture = SettingsUtils.GetSettingTabs("SettingsTabPicture")
	if TabPicture then
		if TabPicture.ScalabilityFeatureSettings[ID] then
			local Idx = SettingsUtils.GetDropDownListIndex(QualityLevel, SettingCfg)
			FLOG_INFO("##Setting OnQualityLevelChg ScalabilityFeatureSettings ID:%d Idx:%d", ID, Idx)
			self.DropDownList:SetSelectedIndex(Idx, nil , true)
		end
		
		if TabPicture.PictureFeatureSettings[ID] then
			local Idx = SettingsUtils.GetDropDownListIndex(QualityLevel, SettingCfg)
			FLOG_INFO("##Setting OnQualityLevelChg PictureFeatureSettings ID:%d Idx:%d", ID, Idx)
			self.DropDownList:SetSelectedIndex(Idx, nil , true)
		end
	end
	
	if string.find(SettingCfg.SaveKey, "QualityLevel") then
		FLOG_INFO("Setting OnePictureFeatureChg QualityLevel:%d", QualityLevel)
		--画质等级改成自定义
		self.DropDownList:SetSelectedIndex(QualityLevel + 1, nil , true)
	end
end
----------------------------------------------------------------------------------------------
---进度条。Value[最大值、默认值]
function SettingsItemView:SetSlider()
	-- 设置描述
	self.TextItemContent:SetText(self.ItemVM.Desc or "")

	UIUtil.SetIsVisible(self.PanelSlider, true)
	
	self.SliderMinValue = tonumber(self.ItemVM.Value[3]) or 0
	if self.SliderMinValue <= 0 then
		self.SliderMinValue = 0
	end

	self.SliderMaxValue = tonumber(self.ItemVM.Value[1]) or 1
	if self.SliderMaxValue <= 0 then
		self.SliderMaxValue = 1
	end

	-- 设置值
	local CurValue = SettingsUtils.GetValue(self.ItemVM.GetValueFunc, self.ItemVM.SettingCfg)
	if nil == CurValue or CurValue < self.SliderMinValue then
		CurValue = tonumber(self.ItemVM.Value[2]) or self.SliderMinValue
	end

	self:SetSliderValue(CurValue)
	self.TextSliderValue:SetText(CurValue)

	self.SliderBar:SetValueChangedCallback(function (v)
		self:OnValueChangedSlider(v)
	end)
end

function SettingsItemView:SetSliderValue( WholeNumber )
	local Percent = (WholeNumber - self.SliderMinValue) / (self.SliderMaxValue - self.SliderMinValue) 
	if Percent < 0 then
		Percent = 0
	end

	self.SliderBar:SetValue(Percent)
end

function SettingsItemView:OnValueChangedSlider( Value )
	local WholeNumber = self.SliderMinValue + math.ceil(Value * (self.SliderMaxValue - self.SliderMinValue))
	self.TextSliderValue:SetText(WholeNumber)

	SettingsUtils.SetValue(self.ItemVM.SetValueFunc, self.ItemVM.SettingCfg, WholeNumber, true)
end

----------------------------------------------------------------------------------------------
---超链接（唤起网页）
function SettingsItemView:SetHyperlink()
	UIUtil.SetIsVisible(self.PanelHyperlink, true)

	-- CommHyperlinkBarView文本
	self.HyperlinkBar:SetContentText(self.ItemVM.Value[1])

	-- 设置url
	self.HyperlinkBar:SetUrl(self.ItemVM.Value[2])

	-- 设置点击回调
	local ClickCallback = self.ItemVM.SetValueFunc
	if not string.isnilorempty(ClickCallback) then
		self.HyperlinkBar:SetClickCallback(function()
			SettingsUtils.SetValue(ClickCallback, self.ItemVM.SettingCfg)
		end)
	end

	-- 设置描述
	local Desc = self.ItemVM.Desc
	if string.isnilorempty(Desc) then
		Desc = SettingsUtils.GetValue(self.ItemVM.GetValueFunc, self.ItemVM.SettingCfg)
	end

	self.TextItemContent:SetText(Desc or "")
end

----------------------------------------------------------------------------------------------
---下拉列表
function SettingsItemView:SetDropDownList()
	-- 设置描述
	self.TextItemContent:SetText(self.ItemVM.Desc or "")

	UIUtil.SetIsVisible(self.PanelDropDownList, true)

	local ListData = {} 
	local SettingCfg = self.ItemVM.SettingCfg

	if string.find(SettingCfg.SaveKey, "QualityLevel") then
		for _, v in pairs(self.ItemVM.Value or {}) do
			table.insert(ListData, { Name = v })
		end

		local DefaultLevel = _G.UE.USettingUtil.GetDefaultQualityLevel()
		if DefaultLevel < 0 then
			FLOG_ERROR("这个设备没有默认等级的配置")
			DefaultLevel = 0
		end

		local DefaultIndex = DefaultLevel + 1
		if DefaultIndex < #ListData then
			ListData[DefaultIndex].Name = 
				string.format("%s%s", ListData[DefaultIndex].Name, LSTR(110039))
		end
	else
		for _, v in pairs(self.ItemVM.Value or {}) do
			table.insert(ListData, { Name = v })
		end
	end

	local CurIndex = SettingsUtils.GetValue(self.ItemVM.GetValueFunc, self.ItemVM.SettingCfg)
	if nil == CurIndex or CurIndex <= 0 then
		CurIndex = 1
	else
		if SettingCfg and SettingCfg.Num then
			local NumCnt = #SettingCfg.Num
			if SettingCfg.IsScalabilityFeature == 1 then		--CurIndex是0-4	画质等级的； 如果是0的话，其实是走上面的if，一样的
				if NumCnt > 0 then
					for index = NumCnt, 1, -1 do
						if SettingCfg.Num[index] <= CurIndex then
							CurIndex = index
							break
						end
					end
				end
			else
				if NumCnt > 0 then
					for index = 1, NumCnt do
						if SettingCfg.Num[index] == CurIndex then
							CurIndex = index
							break
						end
					end
				-- else
				-- 	CurIndex = SettingCfg.DefaultIndex
				end
			end
		-- else
		-- 	CurIndex = SettingCfg.DefaultIndex
		end
	end

	self.DropDownList:UpdateItems(ListData, CurIndex)

	local SwitchTips = self.ItemVM.SwitchTips
	local SwitchCheckFunc = self.ItemVM.SettingCfg.SwitchCheckFunc	--没配置的话，默认是可以切换的
	local bCanSwitch = not string.isnilorempty(SwitchCheckFunc)
	local bShowTips = not string.isnilorempty(SwitchTips)
	if bShowTips or bCanSwitch then
		self.DropDownList:SetIsSelectFunc(function(ItemVM)
			local Index = self.DropDownList:GetIndexByItemData(ItemVM)
			bCanSwitch = not string.isnilorempty(SwitchCheckFunc)

			if bCanSwitch then
				bCanSwitch, bShowTips = SettingsUtils.SwitchCheckFunc(SwitchCheckFunc, self.ItemVM.SettingCfg, Index)
			else
				--没配置SwitchCheckFunc，但是配置了SwitchTips，允许切换并且弹tips
				bCanSwitch = true
			end

			local function DoSelectFunc()
				self.DropDownList:SetSelectedIndexByItemVM(ItemVM)

				-- local Index = self.DropDownList:GetIndexByItemData(ItemVM)
				SettingsUtils.SetValue(self.ItemVM.SetValueFunc, self.ItemVM.SettingCfg, Index, true, false , true)
			end

			if bShowTips then
				if bCanSwitch then
					MsgBoxUtil.ShowMsgBoxTwoOp(
						self, 
						LSTR(110025),
						SwitchTips,
						DoSelectFunc,
						nil, LSTR(110021), LSTR(110032))
				else
					_G.MsgBoxUtil.ShowMsgBoxOneOpRight(nil, LSTR(110026), SwitchTips)
				end
			elseif bCanSwitch then
				DoSelectFunc()
			end

			return false
		end)
	end
end

function SettingsItemView:OnSelectionChangedDropDownList( Index, ItemData, ItemView, IsByClick)
	if IsByClick then
		SettingsUtils.SetValue(self.ItemVM.SetValueFunc, self.ItemVM.SettingCfg, Index, true, false, true)
	end
end

----------------------------------------------------------------------------------------------
---点击回调(按钮)
function SettingsItemView:SetClieckCallback()
	UIUtil.SetIsVisible(self.PanelHyperlink, true)

	self.TextItemContent:SetText(self.ItemVM.Desc or "")
	self.HyperlinkBar:SetContentText(self.ItemVM.Value[1])
	self.HyperlinkBar:SetUrl(nil)

	-- 设置点击回调
	local ClickCallback = self.ItemVM.SetValueFunc
	if not string.isnilorempty(ClickCallback) then
		self.HyperlinkBar:SetClickCallback(function()
			SettingsUtils.SetValue(ClickCallback, self.ItemVM.SettingCfg)
		end)
	end
end

----------------------------------------------------------------------------------------------
---调色板。
function SettingsItemView:SetColorPaletteItem()
	-- 设置描述
	self.TextItemContent:SetText(self.ItemVM.Desc or "")

	UIUtil.SetIsVisible(self.PanelSettingsColor, true)
	
	-- 更新本条目显示的颜色
	local CurColorID = self:GetCurrentColorID()
	self.SettingsColorSettingsItem:SetColor(CurColorID)

	-- 设置点击回调
	UIUtil.AddOnClickedEvent(self, self.SettingsColorSettingsItem:GetButton(), self.OnColorPaletteItemClick)
end

function SettingsItemView:GetCurrentColorID()
	return SettingsUtils.GetValue(self.ItemVM.GetValueFunc, self.ItemVM.SettingCfg) or 0
end

function SettingsItemView:OnColorPaletteItemClick()
	-- 打开调色盘界面
	local CurColorID = self:GetCurrentColorID()
	local MainPanel = (self.ParentView or {}).ParentView
	if MainPanel then
		MainPanel:ShowColorPalette(CurColorID, self, self.OnColorPaletteClose)
	end
end

function SettingsItemView:OnColorPaletteClose(ColorID)
	-- 更新本条目显示的颜色
	self.SettingsColorSettingsItem:SetColor(ColorID)

	-- 设置值
	SettingsUtils.SetValue(self.ItemVM.SetValueFunc, self.ItemVM.SettingCfg, ColorID, true)
end

----------------------------------------------------------------------------------------------
--- 自定义UI ，相当于按钮
function SettingsItemView:SetCustomUIItem()
	UIUtil.SetIsVisible(self.PanelHyperlink, true)

	self.TextItemContent:SetText(self.ItemVM.Desc or "")
	
	self.HyperlinkBar:SetUrl(nil)

	local Value = SettingsUtils.GetValue(self.ItemVM.GetValueFunc, self.ItemVM.SettingCfg) or 1
	local RightBtnContent, UIViewID = _G.SettingsMgr:GetContentBySaveKey(self.ItemVM.SettingCfg.SaveKey, Value)
	if RightBtnContent == nil then
		RightBtnContent, UIViewID = _G.SettingsMgr:GetContentByClientSetupKey(self.ItemVM.SettingCfg.ClientSetupKey, Value)
	end

	self.HyperlinkBar:SetContentText(RightBtnContent or "")

	-- UIUtil.AddOnClickedEvent(self, self.HyperlinkBar.BtnHyperlink
	-- 	, self.OnCustomUIClose)

	self.HyperlinkBar:SetClickCallback(function()
		_G.UIViewMgr:ShowView(UIViewID, {ViewObj = self, CallBack = self.OnCustomUIClose, Value = Value})
	end)
end

function SettingsItemView:OnCustomUIClose(SelectValue)
	FLOG_INFO("setting OnCustomUIClose SelectValue: %d", SelectValue)
	local Value = SelectValue
	local RightBtnContent = _G.SettingsMgr:GetContentBySaveKey(self.ItemVM.SettingCfg.SaveKey, Value)
	if RightBtnContent == nil then
		RightBtnContent = _G.SettingsMgr:GetContentByClientSetupKey(self.ItemVM.SettingCfg.ClientSetupKey, Value)
	end

	self.HyperlinkBar:SetContentText(RightBtnContent or "")

	-- 设置值
	SettingsUtils.SetValue(self.ItemVM.SetValueFunc, self.ItemVM.SettingCfg, SelectValue, true)
end

return SettingsItemView