---
--- Author: chriswang
--- DateTime: 2024-09-24 14:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local SettingsUtils = require("Game/Settings/SettingsUtils")
local SettingsDefine = require("Game/Settings/SettingsDefine")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local SaveKey = require("Define/SaveKey")
local LSTR = _G.LSTR
local ItemDisplayStyle = SettingsDefine.ItemDisplayStyle

---@class SettingsItemDropDownListView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field DropDownList SettingDropDownListNewView
---@field DropDownList22 CommDropDownListView
---@field PanelDropDownList UFCanvasPanel
---@field TextItemContent UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SettingsItemDropDownListView = LuaClass(UIView, true)

function SettingsItemDropDownListView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.DropDownList = nil
	--self.DropDownList22 = nil
	--self.PanelDropDownList = nil
	--self.TextItemContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SettingsItemDropDownListView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.DropDownList)
	-- self:AddSubView(self.DropDownList22)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SettingsItemDropDownListView:OnInit()

end

function SettingsItemDropDownListView:OnDestroy()

end

function SettingsItemDropDownListView:OnShow()
	if nil == self.Params or nil == self.Params.Data then
		return
	end

	self.ItemVM = self.Params.Data

	local GetListDataFuncStr = self.ItemVM.SettingCfg.NoTranslateStr
	if not string.isnilorempty(GetListDataFuncStr) then
		local function PreClickDropDownFunc()
			local ListData = {}
			local SettingCfg = self.ItemVM.SettingCfg
		
			local ListStr = SettingsUtils.CallFunc(SettingCfg.NoTranslateStr, true, SettingCfg)
			for _, v in pairs(ListStr or {}) do
				table.insert(ListData, { Name = v })
			end
			
			local CurIndex = SettingsUtils.GetValue(self.ItemVM.GetValueFunc, self.ItemVM.SettingCfg)
			if nil == CurIndex or CurIndex <= 0 then
				CurIndex = 1
			else
				if SettingCfg.Num then
					local NumCnt = #SettingCfg.Num
					if NumCnt > 0 then
						for index = 1, NumCnt do
							if SettingCfg.Num[index] == CurIndex then
								CurIndex = index
								break
							end
						end
					end
				end
			end
			
			self.DropDownList:UpdateItems(ListData, CurIndex, self.DropDownList.IsSelectedFunc)
		end

		self.DropDownList:SetPreClickDropDownFunc(PreClickDropDownFunc)
	end

	self:SetDropDownList()
	-- local SettingCfg = self.ItemVM.SettingCfg
	-- if string.find(SettingCfg.SaveKey, "QualityLevel") then
	-- 	self:SetDropDownList()
	-- else
	-- 	self:SetDropDownList()
	-- end
end

function SettingsItemDropDownListView:OnHide()

end

function SettingsItemDropDownListView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownList, self.OnSelectionChangedDropDownList)
end

function SettingsItemDropDownListView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OnePictureFeatureChg, self.OnOnePictureFeatureChg)
	self:RegisterGameEvent(_G.EventID.QualityLevelChg, self.OnQualityLevelChg)
	self:RegisterGameEvent(_G.EventID.BgVoiceCloseCancel, self.OnBgVoiceCloseCancel)

end

function SettingsItemDropDownListView:OnRegisterBinder()

end

--2-7,11-12那些特性有修改的话，就变成自定义的了
--0表示 根据设备性能调整画质 （性能模式的）
function SettingsItemDropDownListView:OnOnePictureFeatureChg(Params)
	local SettingCfg = self.ItemVM.SettingCfg
	if not Params then
		return
	end

	--只有打开性能模式，但又取消的时候，才会触发这个事件，才需要切回到关闭
	if Params == 0 then
		if string.find(SettingCfg.SaveKey, "PerformanceMode") then
			self.DropDownList:SetSelectedIndex(1, nil , true)
		end
		
		return
	end

	if string.find(SettingCfg.SaveKey, "QualityLevel") then
		FLOG_INFO("Setting OnePictureFeatureChg %d", Params)
		--画质等级改成自定义
		local ListData = self:GetQualityLevelListData(true)
		self.DropDownList:UpdateItems(ListData, SettingsMgr.CustomQualityIndex, self.DropDownList.IsSelectedFunc)
		-- self.DropDownList:SetSelectedIndex(SettingsMgr.CustomQualityIndex, nil , true)
		
        _G.UE.USaveMgr.SetInt(SaveKey.QualityLevel, SettingsMgr.CustomQualityIndex, false)
	end
end

--画质等级切换，QualityLevel:0-4
function SettingsItemDropDownListView:OnQualityLevelChg(QualityLevel, Index)
	local SettingCfg = self.ItemVM.SettingCfg
	local ID = SettingCfg.ID
	FLOG_INFO("##Setting OnQualityLevelChg Level:%d, ID:%d", QualityLevel, ID)
	local TabPicture = SettingsUtils.GetSettingTabs("SettingsTabPicture")
	if TabPicture then
		if TabPicture.ScalabilityFeatureSettings[ID] then
			local Idx = 1
			if string.find(SettingCfg.SaveKey, "ScaleFactor") then
				local Value = _G.SettingsMgr.ScreenPercentList[QualityLevel + 1]
				Idx = SettingsUtils.GetDropDownListIndex(Value, SettingCfg)
			else
				Idx = SettingsUtils.GetDropDownListIndex(QualityLevel, SettingCfg)
			end
			
			FLOG_INFO("##Setting OnQualityLevelChg ScalabilityFeatureSettings ID:%d Idx:%d", ID, Idx)
			self.DropDownList:SetSelectedIndex(Idx, nil , true)
		end
		
		if TabPicture.PictureFeatureSettings[ID] then
			local Idx = 1
			if string.find(SettingCfg.SaveKey, "MaxFPS") then	--切画质，帧率都回到30	--目前不会有
				Idx = 2
			else
				Idx = SettingsUtils.GetDropDownListIndex(QualityLevel, SettingCfg)
			end
			FLOG_INFO("##Setting OnQualityLevelChg PictureFeatureSettings ID:%d Idx:%d", ID, Idx)
			self.DropDownList:SetSelectedIndex(Idx, nil , true)
		end
	end
	
	if string.find(SettingCfg.SaveKey, "QualityLevel") then
		FLOG_INFO("Setting OnePictureFeatureChg QualityLevel:%d, Index:%d", QualityLevel, Index)
		--画质等级改成自定义
		local ListData = self:GetQualityLevelListData(false)
		self.DropDownList:UpdateItems(ListData, Index, self.DropDownList.IsSelectedFunc)
		-- self.DropDownList:SetSelectedIndex(Index, nil , true)
	end
end

function SettingsItemDropDownListView:GetQualityLevelListData(bCustomLevel)
	local ListData = {} 
	if not self.ItemVM.Value then
		return ListData
	end

	local Cnt = #self.ItemVM.Value
	if not bCustomLevel then
		local QualityLevel = _G.UE.USaveMgr.GetInt(SaveKey.QualityLevel, _G.SettingsMgr.DefauleValueNotSave, false)
		if bCustomLevel == false or bCustomLevel == nil and QualityLevel ~= SettingsMgr.CustomQualityIndex then
			Cnt = Cnt - 1	--少最后的自定义
		end
	end

	for index = 1, Cnt do
		table.insert(ListData, { Name = self.ItemVM.Value[index] })
	end

	local DefaultLevel = _G.UE.USettingUtil.GetDefaultQualityLevel()
	if DefaultLevel < 0 then
		FLOG_ERROR("这个设备没有默认等级的配置")
		DefaultLevel = 0
	end

	--模拟器新增一档画质
	if SettingsMgr.IsWithEmulatorMode then
		table.insert(ListData, 6, { Name = LSTR(110029) })
	end

	local DefaultIndex = DefaultLevel + 1
	if DefaultIndex <= #ListData then
		ListData[DefaultIndex].Name = 
			string.format("%s%s", ListData[DefaultIndex].Name, LSTR(110039))
	end

	return ListData
end

function SettingsItemDropDownListView:GetMaxFpsListData()
	local ListData = {} 
	if not self.ItemVM.Value then
		return ListData
	end
	
	local UseCnt = 2
	local Platform = _G.UE.UGameplayStatics.GetPlatformName()
	local DefaultLevel = _G.UE.USettingUtil.GetDefaultQualityLevel()	-- -1:没配置 0-4
	if Platform == "IOS" then
		if DefaultLevel >= 2 then
			UseCnt = 4
		end
	else
		if _G.UE.UPlatformUtil.IsWithEditor() then
			UseCnt = 4
		else
			local IsWithEmulatorMode = _G.SettingsMgr.IsWithEmulatorMode
			if IsWithEmulatorMode then
				UseCnt = 4
			else
				if DefaultLevel >= 2 then
					UseCnt = 4
				else
					UseCnt = 2
				end
			end
		end
	end

	local Cnt = #self.ItemVM.Value
	FLOG_INFO("setting GetMaxFpsListData Device:%s DefaultQualityLevel:%d UseCnt:%d, Cnt:%d"
		, Platform, DefaultLevel, UseCnt, Cnt)
	if UseCnt > Cnt then
		UseCnt = Cnt
	end

	for index = 1, UseCnt do
		table.insert(ListData, { Name = self.ItemVM.Value[index] })
	end

	return ListData
end

-- function SettingsItemDropDownListView:PreClickDropDownFunc()
-- end

---下拉列表
function SettingsItemDropDownListView:SetDropDownList()
	-- 设置描述
	self.TextItemContent:SetText(self.ItemVM.Desc or "")

	local ListData = {}
	local SettingCfg = self.ItemVM.SettingCfg

	if not SettingCfg then
		return 
	end

	local bQualityLevel = false
	if string.find(SettingCfg.SaveKey, "QualityLevel") then
		bQualityLevel = true

		local QualityLevel = _G.UE.USaveMgr.GetInt(SaveKey.QualityLevel, _G.SettingsMgr.DefauleValueNotSave, false)
		if QualityLevel == _G.SettingsMgr.CustomQualityIndex then
			ListData = self:GetQualityLevelListData(true)
		else
			ListData = self:GetQualityLevelListData(false)
		end
	elseif string.find(SettingCfg.SaveKey, "MaxFPS") then
		ListData = self:GetMaxFpsListData()
	elseif not string.isnilorempty(SettingCfg.NoTranslateStr) then
		local ListStr = SettingsUtils.CallFunc(SettingCfg.NoTranslateStr, false, SettingCfg)
		for _, v in pairs(ListStr or {}) do
			table.insert(ListData, { Name = v })
		end
	else
		for _, v in pairs(self.ItemVM.Value or {}) do
			table.insert(ListData, { Name = v })
		end
	end

	local CurIndex = SettingsUtils.GetValue(self.ItemVM.GetValueFunc, self.ItemVM.SettingCfg)
	-- FLOG_INFO("SetDropDownList CurIndex:%s SaveKey:%s", tostring(CurIndex), SettingCfg.SaveKey)
	if nil == CurIndex or CurIndex <= 0 then
		CurIndex = 1
	else
		if SettingCfg.Num then
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
					if bQualityLevel then
						if CurIndex < 0 then
							CurIndex = 5
						end
					else
						for index = 1, NumCnt do
							if SettingCfg.Num[index] == CurIndex then
								CurIndex = index
								break
							end
						end

						if string.find(SettingCfg.SaveKey, "MaxFPS") then	--帧率特殊，ios下可能是25，如果是25，则是显示中
							if CurIndex == 25 then
								CurIndex = 2
							end
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
	local bConfigHotMsgBox = self.ItemVM.SettingCfg.IsConfigHotMsgBox == 1
	if bShowTips or bCanSwitch or bConfigHotMsgBox then
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
				if bConfigHotMsgBox then
					local DefaultValue = _G.SettingsMgr:GetDefaultValue(self.ItemVM.SettingCfg)
					if Index > DefaultValue then
						MsgBoxUtil.ShowMsgBoxTwoOp(
							self,
							LSTR(110025),
							LSTR(110049),
							DoSelectFunc,
							nil, LSTR(110021), LSTR(110032))
					else
						DoSelectFunc()
					end
				else
					DoSelectFunc()
				end
			end

			return false
		end)
	end
end

function SettingsItemDropDownListView:OnSelectionChangedDropDownList( Index, ItemData, ItemView, IsByClick)
	if IsByClick then
		SettingsUtils.SetValue(self.ItemVM.SetValueFunc, self.ItemVM.SettingCfg, Index, true, false, true)
	end
end

function SettingsItemDropDownListView:OnBgVoiceCloseCancel( Index )
	local ListData = {}
	if not self.ItemVM.Value then
		return
	end

	for _, v in pairs(self.ItemVM.Value or {}) do
		table.insert(ListData, { Name = v })
	end

	self.DropDownList:UpdateItems(ListData, Index)
end

return SettingsItemDropDownListView