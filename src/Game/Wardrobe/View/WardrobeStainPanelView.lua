---
--- Author: Administrator
--- DateTime: 2024-02-21 14:18
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MajorUtil = require("Utils/MajorUtil")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")
local CommonUtil = require("Utils/CommonUtil")
local SystemEntranceMgr = require("Game/Common/Tips/SystemEntranceMgr")
local WardrobeMgr =  require("Game/Wardrobe/WardrobeMgr")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetBrushTintColorHex = require("Binder/UIBinderSetBrushTintColorHex")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local WardrobeStainPanelVM = require("Game/Wardrobe/VM/WardrobeStainPanelVM")
local WardrobeMainPanelVM = require("Game/Wardrobe/VM/WardrobeMainPanelVM")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local CameraFocusCfgMap = require("Game/Wardrobe/WardrobeCameraFocusCfgMap")
local EquipmentVM = require("Game/Equipment/VM/EquipmentVM")
local USaveMgr = _G.UE.USaveMgr
local SaveKey = require("Define/SaveKey")

local EquipmentCfg = require("TableCfg/EquipmentCfg")
local DyeColorCfg = require("TableCfg/DyeColorCfg")
local ClosetCfg = require("TableCfg/ClosetCfg")
local BagMgr = require("Game/Bag/BagMgr")
local WardrobeDefine = require("Game/Wardrobe/WardrobeDefine")
local EventID = _G.EventID
local EquipmentPartList = ProtoCommon.equip_part

---@class WardrobeStainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field BtnCamera UToggleButton
---@field BtnControls UFButton
---@field BtnGo UToggleButton
---@field BtnHand UToggleButton
---@field BtnHat UToggleButton
---@field BtnHatStyle UToggleButton
---@field BtnOnetouch UFButton
---@field BtnPose UToggleButton
---@field BtnUnlock CommBtnLView
---@field CommBtnM1 CommBtnMView
---@field CommBtnM2 CommBtnMView
---@field CommonBkg CommonBkg01View
---@field CommonTitle CommonTitleView
---@field Consume1 WardrobeConsumeItemView
---@field Consume2 WardrobeConsumeItemView
---@field FHorizontalRegion UFHorizontalBox
---@field HorizontalConsume UFHorizontalBox
---@field ImgDisable3 UFImage
---@field ImgMask UFImage
---@field PanelBg UFCanvasPanel
---@field PanelBtn2 UFCanvasPanel
---@field PanelColor UFCanvasPanel
---@field PanelList UFCanvasPanel
---@field PanelName UFCanvasPanel
---@field PanelTab UFCanvasPanel
---@field PanelTab2 UFCanvasPanel
---@field PanelTitle UFCanvasPanel
---@field PanelUnlock UFCanvasPanel
---@field StainTag WardrobeStainTagItemView
---@field StainTagNew WardrobeStainStyleItem2View
---@field TableViewBall UTableView
---@field TableViewBox UTableView
---@field TableViewList UTableView
---@field TableViewPosition UTableView
---@field TableViewStyle UTableView
---@field TextConsume UFTextBlock
---@field TextLack UFTextBlock
---@field TextName UFTextBlock
---@field TextRegion UFTextBlock
---@field TextSubtitle URichTextBox
---@field TextTitle UFTextBlock
---@field TextUnlock UFTextBlock
---@field WardrobeOperateItem WardrobeOperateItemView
---@field AnimIn UWidgetAnimation
---@field Tab1 UWidgetAnimation
---@field Tab2 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeStainPanelView = LuaClass(UIView, true)

function WardrobeStainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.BtnCamera = nil
	--self.BtnControls = nil
	--self.BtnGo = nil
	--self.BtnHand = nil
	--self.BtnHat = nil
	--self.BtnHatStyle = nil
	--self.BtnOnetouch = nil
	--self.BtnPose = nil
	--self.BtnUnlock = nil
	--self.CommBtnM1 = nil
	--self.CommBtnM2 = nil
	--self.CommonBkg = nil
	--self.CommonTitle = nil
	--self.Consume1 = nil
	--self.Consume2 = nil
	--self.FHorizontalRegion = nil
	--self.HorizontalConsume = nil
	--self.ImgDisable3 = nil
	--self.ImgMask = nil
	--self.PanelBg = nil
	--self.PanelBtn2 = nil
	--self.PanelColor = nil
	--self.PanelList = nil
	--self.PanelName = nil
	--self.PanelTab = nil
	--self.PanelTab2 = nil
	--self.PanelTitle = nil
	--self.PanelUnlock = nil
	--self.StainTag = nil
	--self.StainTagNew = nil
	--self.TableViewBall = nil
	--self.TableViewBox = nil
	--self.TableViewList = nil
	--self.TableViewPosition = nil
	--self.TableViewStyle = nil
	--self.TextConsume = nil
	--self.TextLack = nil
	--self.TextName = nil
	--self.TextRegion = nil
	--self.TextSubtitle = nil
	--self.TextTitle = nil
	--self.TextUnlock = nil
	--self.WardrobeOperateItem = nil
	--self.AnimIn = nil
	--self.Tab1 = nil
	--self.Tab2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeStainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.BtnUnlock)
	self:AddSubView(self.CommBtnM1)
	self:AddSubView(self.CommBtnM2)
	self:AddSubView(self.CommonBkg)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.Consume1)
	self:AddSubView(self.Consume2)
	self:AddSubView(self.StainTag)
	self:AddSubView(self.StainTagNew)
	self:AddSubView(self.WardrobeOperateItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeStainPanelView:OnInit()
	self.VM = WardrobeStainPanelVM.New()
	self.MainVM = WardrobeMainPanelVM
	-- 装备菜单列表
	self.AppearanceTabListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewPosition, self.OnAppearanceTabListChanged, true)
	-- 颜色菜单列表
	self.ColorTabListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewBall, self.OnColorTabListChanged, true)
	-- 颜色
	self.ColorListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewBox, self.OnColorListChanged, true)
	-- 染色区域
	self.ColorAreaListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnColorAreaListChanged, true)
	-- 常用颜色
	self.ColorOftenListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewStyle, self.OnColorOftenListChanged, true)

	self.MultiBinders = {
		{
			ViewModel = self.VM,
			Binders = {
				{ "AppearanceTabList",  UIBinderUpdateBindableList.New(self, self.AppearanceTabListAdapter)},
				{ "ColorTabList",  UIBinderUpdateBindableList.New(self, self.ColorTabListAdapter)},
				{ "ColorList",  UIBinderUpdateBindableList.New(self, self.ColorListAdapter)},
				{ "ColorAreaList",  UIBinderUpdateBindableList.New(self, self.ColorAreaListAdapter)},
				{ "ColorOftenList",  UIBinderUpdateBindableList.New(self, self.ColorOftenListAdapter)},
				{ "SubTitleName", UIBinderSetText.New(self, self.CommonTitle.TextSubtitle)},
				{ "SectionName", UIBinderSetText.New(self, self.TextRegion)},
				{ "ReNameBtnVisible", UIBinderSetIsVisible.New(self, self.BtnControls, false, true)},
				{ "AppearanceName", UIBinderSetText.New(self, self.TextName)},
				{ "CurColorName", UIBinderSetText.New(self, self.TextUnlock)},
				{ "CurColor", UIBinderSetBrushTintColorHex.New(self, self.StainTagNew.ImgStainColor)},
				{ "CurColorIsMetal", UIBinderSetIsVisible.New(self, self.StainTagNew.ImgMetal)},
				{ "CurColorVisible", UIBinderSetIsVisible.New(self, self.StainTagNew.ImgStainColor)},
				{ "CurColorVisible", UIBinderSetIsVisible.New(self, self.StainTagNew.ImgBg, true)},
				{ "BtnUnlockTxt", UIBinderSetText.New(self, self.BtnUnlock.TextContent)},
				{ "PanelUnlockVisible", UIBinderSetIsVisible.New(self, self.PanelUnlock)},
				{ "ActiveColor", UIBinderSetIsVisible.New(self, self.BtnUnlock, false, true)},
				{ "ActiveColor", UIBinderSetIsVisible.New(self, self.PanelBtn2, true, true)},
				{ "ItemLackVisible", UIBinderSetIsVisible.New(self, self.TextLack)},
				{ "AppearanceTabVisible", UIBinderSetIsVisible.New(self, self.PanelTab)},
				{ "HorizontalConsumeVisible", UIBinderSetIsVisible.New(self, self.HorizontalConsume)},
				{ "Consume1Visible", UIBinderSetIsVisible.New(self, self.Consume1)},
				{ "Consume2Visible", UIBinderSetIsVisible.New(self, self.Consume2)},
				{ "StainTitle", UIBinderSetText.New(self, self.CommonTitle.TextTitleName)},
				{ "ColorListSelectedIndex", UIBinderSetSelectedIndex.New(self, self.ColorListAdapter)},
				{ "MoreOftenVisible", UIBinderSetIsVisible.New(self, self.BtnGo, false, true)},
				{ "MoreOftenCheck", UIBinderSetIsChecked.New(self, self.BtnGo)},
				{ "BtnBlockVisible", UIBinderSetIsVisible.New(self, self.WardrobeOperateItem.BtnBlock, false, true)},
				{ "BtnBlockChecked", UIBinderSetIsChecked.New(self, self.WardrobeOperateItem.BtnBlock)},
			}
		},
		{
			ViewModel = self.MainVM,
			Binders = {
				{ "BtnHandChecked", UIBinderSetIsChecked.New(self, self.WardrobeOperateItem.BtnHand)},
				{ "BtnHatChecked", UIBinderSetIsChecked.New(self, self.WardrobeOperateItem.BtnHat)},
				{ "BtnHatStyleChecked", UIBinderSetIsChecked.New(self, self.WardrobeOperateItem.BtnHatStyle)},
				{ "BtnPoseChecked", UIBinderSetIsChecked.New(self, self.WardrobeOperateItem.BtnPose)},
			}
		}
	}

	self.CameraFocusCfgMap = CameraFocusCfgMap.New()
	self.LastAppID = 0
	self.CurColorID = -1	
	self.ColorTypeID = 0
	self.CurStainAreaID = -1
	self.CurAppearanceID = 0
	self.OftenSelectColor = nil
	self.OftenListOpen = false
	self.StainType = WardrobeDefine.Normal
	self.Common_Render2D_UIBP = nil
	self.ShowModelType = nil
	self.SuperView = nil
	self.IsTransition = true
	self.IsInsertUsedStain = false
end

function WardrobeStainPanelView:OnDestroy()
end

function WardrobeStainPanelView:OnShow()
	self:InitText()
	UIUtil.SetIsVisible(self.CommonBkg, false)
	UIUtil.SetIsVisible(self.PanelTitle, false)
	UIUtil.SetIsVisible(self.StainTag, false)
	UIUtil.SetIsVisible(self.FHorizontalRegion, true)
	UIUtil.SetIsVisible(self.StainTagNew, true)
	

	self.Common_Render2D_UIBP = self.Params.SuperView.Common_Render2D_UIBP
	self.SuperView = self.Params.SuperView
	self.CameraFocusCfgMap:SetAssetUserData(self.Common_Render2D_UIBP:GetEquipmentConfigAssetUserData())
	self.BtnBack:AddBackClick(self, function ()
		if self.VM:IsPreviewEmpty(self.CurAppearanceID) or self.StainType == WardrobeDefine.StainType.TryStain then
			self:ExitStainPanel()
			return
		else
			local Time =  WardrobeMgr:GetStainNoShowTipsTime()
			if Time == 0 or not _G.TimeUtil.GetIsCurDailyCycleTime(Time) then
				self:ShowExitStainPanelTips()
				return
			end
			self:ExitStainPanel()
		end
	end)
	self.StainType = self.Params.StainType
	self.IsTransition = true
	local IsTryStain = self.StainType == WardrobeDefine.StainType.TryStain 
	UIUtil.SetIsVisible(self.BtnOnetouch, not IsTryStain , not IsTryStain)

	-- 初始化染色的外观
	self:InitViewModelSuit()
	self.VM:InitAppearanceTabList(self.Params.AppearanceList)
	self.VM:UpdateTitle(self.StainType)
	self.VM:InitColorTabList()

	self.VM.MoreOftenCheck = self.OftenListOpen
	self.BtnGo:SetChecked(false, false)

	if self.StainType == WardrobeDefine.StainType.Normal then
		self:PlayAnimation(self.Tab1)
		self.VM.AppearanceTabVisible = true
		local TempIDList = {}				
		for _, AppID in ipairs(self.Params.AppearanceList) do		
			local DyeEnable = WardrobeMgr:GetDyeEnable(AppID)	
			if DyeEnable then	
				table.insert(TempIDList, AppID)
			end	
		end		

		if #TempIDList > 0 then
			WardrobeMgr:SendClosetActiveColor(TempIDList)
		end

		--- 从哪个部位进来的 就从哪个部位染色
		local SelectIndex = 1
		if self.Params.AppearanceID then
			for i = 1, self.AppearanceTabListAdapter:GetNum() do
				local ItemVM = self.AppearanceTabListAdapter:GetItemDataByIndex(i)
				if ItemVM ~= nil then
					if self.Params.AppearanceID == ItemVM.ID then
						SelectIndex = i
						break
					end
				end
			end
		end

		-- 更新染色模型
		self:UpdateModelEquipment()
		self.AppearanceTabListAdapter:CancelSelected()
		self.AppearanceTabListAdapter:SetSelectedIndex(SelectIndex)
	else
		self:PlayAnimation(self.Tab2)
		self.VM.AppearanceTabVisible = false
		self.CurAppearanceID = self.Params.AppearanceList[1]
		self.AppearanceTabListAdapter:CancelSelected()
		WardrobeMgr:SendClosetActiveColor({self.CurAppearanceID})
		self.AppearanceTabListAdapter:SetSelectedIndex(1)
	end

	self.VM.BtnBlockVisible = true
	self.WardrobeOperateItem.BtnBlock:SetChecked(self.VM.BtnBlockChecked, true)
	self:InitBtnHatStyleState()
	WardrobeMgr:SendClosetUsedStainQuery()
end

function WardrobeStainPanelView:OnHide()
	self.CurColorID = -1	
	self.ColorTypeID = 0
	self.CurAppearanceID = 0
	self.LastColorIndex = nil
	self.LastAppID = nil
	self.StainType = WardrobeDefine.Normal
	self.VM:ClearStainSuit()
	self.VM:ClearPreStainSuit()
end

function WardrobeStainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.WardrobeOperateItem.BtnHand, self.OnClickedBtnHand)
	UIUtil.AddOnStateChangedEvent(self, self.WardrobeOperateItem.BtnHat, self.OnClickedBtnHat)
	UIUtil.AddOnStateChangedEvent(self, self.WardrobeOperateItem.BtnHatStyle, self.OnClickedBtnHatStyle)
	UIUtil.AddOnStateChangedEvent(self, self.WardrobeOperateItem.BtnPose, self.OnClickedBtnPose)
	UIUtil.AddOnStateChangedEvent(self, self.WardrobeOperateItem.BtnCamera, self.OnClickedBtnCamera)
	UIUtil.AddOnStateChangedEvent(self, self.WardrobeOperateItem.BtnBlock, self.OnClickedBtnBlock)
	UIUtil.AddOnClickedEvent(self, self.BtnUnlock, self.OnClickedBtnUnlock)
	UIUtil.AddOnClickedEvent(self, self.BtnGo, self.OnClickedBtnGO)
	UIUtil.AddOnClickedEvent(self, self.CommBtnM1, self.OnClickedActive)  -- 激活染色
	UIUtil.AddOnClickedEvent(self, self.CommBtnM2, self.OnClickedActiveAndStain) -- 激活并染色
	UIUtil.AddOnClickedEvent(self, self.BtnControls, self.OnClickedRegionDyeName) -- 区域染色改名
	UIUtil.AddOnClickedEvent(self, self.BtnOnetouch, self.OnClickedBtnPreviewColor) --预览色弹窗
end

function WardrobeStainPanelView:OnRegisterGameEvent()
	--激活染色
	self:RegisterGameEvent(EventID.WardrobeActiveStain, self.OnWardrobeActiveStain)
	--染色监听
	self:RegisterGameEvent(EventID.WardrobeDyeUpdate, self.OnWardrobeDyeUpdate)
	--区域染色监听
	self:RegisterGameEvent(EventID.WardrobeRegionDyeUpdate, self.OnWardrobeRegionDyeUpdate)
	-- 染色信息查询
	self:RegisterGameEvent(EventID.WardrobeActiveColorUpdate, self.OnActiveColorUpdate)
	-- 通用染色刷新
	self:RegisterGameEvent(EventID.WardrobeUsedStainUpdate, self.OnWardrobeUsedStainUpdate)
	-- 染色区域改名
	self:RegisterGameEvent(EventID.WardrobeRegionDyeNameUpdate, self.OnWardrobeRegionDyeNameUpdate)
	-- 背包更新
	self:RegisterGameEvent(EventID.BagUpdate, self.OnUpdateBag)
	-- 模型组件组装通知
	self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
end

function WardrobeStainPanelView:OnRegisterBinder()
	self:RegisterMultiBinders(self.MultiBinders)
	self.Consume1:SetParams({ Data = self.VM.ConsumeVM1})
	self.Consume2:SetParams({ Data = self.VM.ConsumeVM2})
end

-- 初始化文本
function WardrobeStainPanelView:InitText()
	self.TextLack:SetText(_G.LSTR(1080076))
	self.TextConsume:SetText(_G.LSTR(1080059))

	self.CommBtnM1:SetText(_G.LSTR(1080107)) --解锁
	self.CommBtnM2:SetText(_G.LSTR(1080140)) --解锁并染色
end

-- 初始化染色的外观
function  WardrobeStainPanelView:InitViewModelSuit()
	local Suit = WardrobeMgr:GetCurAppearanceList()
	for _, appID in ipairs(self.Params.AppearanceList) do
		local PartID = WardrobeUtil.GetPartByAppearanceID(appID)
		if Suit[PartID] == nil then
			local RegionDye = WardrobeMgr:GetUnlockedAppearanceRegionDyes(appID)
			local Color = WardrobeMgr:GetDyeColor(appID)
			local TempStainAera =  WardrobeUtil.GetRegionDye(appID, RegionDye)
			self.VM:SetStainSuit(PartID, appID, Color, TempStainAera)
			self.VM:SetPreStainSuit(PartID, appID, Color, TempStainAera)
		else
			local value = Suit[PartID]
			if value and value.Avatar and value.Avatar == appID then
				local TempStainAera = WardrobeUtil.GetRegionDye(appID, value.RegionDye)
				self.VM:SetStainSuit(PartID, appID, value.Color, TempStainAera)
				self.VM:SetPreStainSuit(PartID, appID, value.Color, TempStainAera)
			else
				local RegionDye = WardrobeMgr:GetUnlockedAppearanceRegionDyes(appID)
				local Color = WardrobeMgr:GetDyeColor(appID)
				local TempStainAera = WardrobeUtil.GetRegionDye(appID, RegionDye)
				self.VM:SetStainSuit(PartID, appID, Color, TempStainAera)
				self.VM:SetPreStainSuit(PartID, appID, Color, TempStainAera)
			end
		end
	end
end

-- 初始化头部装饰开关状态
function WardrobeStainPanelView:InitBtnHatStyleState()
	local HasGimmick = self:CheckHeadHasGimmick()
	if HasGimmick then
		self.MainVM.BtnHatStyleDisabled = false
		self.WardrobeOperateItem.BtnHatStyle:SetCheckedState(self.MainVM.BtnHatStyleChecked and _G.UE.EToggleButtonState.Checked  or _G.UE.EToggleButtonState.Unchecked, false)
	else
	    self.MainVM.BtnHatStyleDisabled = true
		self.WardrobeOperateItem.BtnHatStyle:SetCheckedState(_G.UE.EToggleButtonState.Locked, false)
	end
end

function WardrobeStainPanelView:OnUpdateBag()
	self:UpdateBtnUnlockState(self.CurAppearanceID, self.CurColorID, self.CurStainAreaID)
	self:UpdateConsumeItem(self.CurAppearanceID, self.CurColorID)
end

-- 跟主界面不一样 因为可能预览了一些装备
function WardrobeStainPanelView:CheckHeadHasGimmick()
	local AppearanceList = self.Params.AppearanceList
	-- 先查询自身装备有没头部 有热
	for _,  appID in ipairs(AppearanceList) do
		local EquipID = WardrobeUtil.GetEquipIDByAppearanceID(appID)	
		local EquipCfg = EquipmentCfg:FindCfgByKey(EquipID)
		if EquipCfg ~= nil then
			if EquipCfg.Part == EquipmentPartList.EQUIP_PART_HEAD then
				return _G.EquipmentMgr:IsEquipHasGimmick(EquipID)
			end
		end
	end

	return WardrobeMgr:CheckHeadHasGimmick()
end

-- 激活染色查询
function WardrobeStainPanelView:OnActiveColorUpdate()
	self.VM:UpdateColorListUnlockState(self.StainType, self.CurAppearanceID)
	self.VM:UpdateBtnUnlockState(self.StainType, self.CurAppearanceID, self.CurColorID)
	self:UpdateConsumeItem(self.CurAppearanceID, self.CurColorID)
	self:UpdateBtnUnlockState(self.CurAppearanceID, self.CurColorID)
	self.VM:UpdateCurAppearanceSeationName(self.StainType, self.CurAppearanceID, self.CurStainAreaID)
end

-- 更新激活
function WardrobeStainPanelView:OnWardrobeActiveStain(Params)
	--更新
	local ColorList = Params.ColorIDList or {}
	local ColorID = Params.ColorID
	local AppID = Params.ID
	if AppID == self.CurAppearanceID then
		if table.is_nil_empty(ColorList) then
			self.VM:UpdateBtnUnlockState(self.StainType, self.CurAppearanceID, ColorID)
			self.VM:UpdateColorListUnlockState(self.StainType, self.CurAppearanceID)
			self:UpdateBtnUnlockState(self.CurAppearanceID, ColorID)
			self:UpdateConsumeItem(self.CurAppearanceID, ColorID)
		else
			for _, colorID in ipairs(ColorList) do
				self.VM:UpdateColorListUnlockState(self.StainType, self.CurAppearanceID)
				if colorID == self.CurColorID then
					self.VM:UpdateBtnUnlockState(self.StainType, self.CurAppearanceID, colorID)
					self:UpdateBtnUnlockState(self.CurAppearanceID, colorID)
					self:UpdateConsumeItem(self.CurAppearanceID, colorID)
				end
			end
		end
	end
end

-- 监听染色
function WardrobeStainPanelView:OnWardrobeDyeUpdate(Params)
	local AppID = Params.ID
	local ColorID = Params.ColorID -- 染色值
	local RegionDyes = Params.RegionDyes or {}

	-- Todo 如果是区域染色的外观 更改数据
	local CurPartID = WardrobeUtil.GetPartByAppearanceID(AppID)
	self.VM:SetStainSuit(CurPartID, AppID, ColorID, RegionDyes)

	if ColorID == 0 then
		local TempRegionDye = {}
		local PreStainView = self.VM:GetPreStainSuitByAppID(AppID)
		for index, v in ipairs(PreStainView.RegionDye or {}) do
			table.insert(TempRegionDye, {ID = index, ColorID = ColorID})
		end
		self.VM:SetPreStainSuit(CurPartID, AppID, ColorID, TempRegionDye)
	end
	
	--左边装备
	self.VM:UpdateAppearanceTabList()
	--更新颜色标志
	self.VM:UpdateColorListUnlockState(self.StainType, self.CurAppearanceID)
	--更新解锁按钮装备
	self.VM:UpdateBtnUnlockState(self.StainType, self.CurAppearanceID, ColorID or self.CurColorID)

	self:UpdateBtnUnlockState(self.CurAppearanceID, ColorID or self.CurColorID)
	--更新模型颜色
	self:UpdateModelColor(self.CurAppearanceID, ColorID or self.CurColorID)
	--更新染色区域
	self.VM:UpdateColorAeraList(self.CurAppearanceID, -1)

	--取消染色 
	if ColorID == 0 then
		self:SetColorListSelectdIndex(self.CurAppearanceID, -1, 0)
	end
end

-- 监听区域染色染色
function WardrobeStainPanelView:OnWardrobeRegionDyeUpdate(Params)
	local RegionDyes = Params.RegionDyes or  {}
	local ColorID = Params.ColorID
	local AppID = Params.ID

	-- 更新界面染色数据
	local CurPartID = WardrobeUtil.GetPartByAppearanceID(AppID)
	self.VM:SetStainSuit(CurPartID, AppID, Params.ColorID, Params.RegionDyes)

	--左边装备
	self.VM:UpdateAppearanceTabList()
	--更新颜色标志
	self.VM:UpdateColorListUnlockState(self.StainType, self.CurAppearanceID, self.CurStainAreaID)
	--更新解锁按钮装备
	self.VM:UpdateBtnUnlockState(self.StainType, self.CurAppearanceID, self.CurColorID, self.CurStainAreaID)

	self:UpdateBtnUnlockState(self.CurAppearanceID, self.CurColorID, self.CurStainAreaID)

	-- 更新左边颜色(Todo 每个都需要修改了)
	for _, v in ipairs(RegionDyes) do
		self.VM:UpdateColorAeraList(self.CurAppearanceID, v.ID)
	end

	--更新模型颜色(Todo 每个都需要修改了)
	for _, v in ipairs(RegionDyes) do
		-- if v.ID == self.CurStainAreaID then
			self:StainPartForSection(self.CurAppearanceID, self.CurPartID, {{ID = v.ID, ColorID = v.ColorID}})
		-- end
	end

	--取消染色 --如果是当前的颜色
	for _, v in ipairs(RegionDyes) do
		if v.ID == self.CurStainAreaID then
			if v.ColorID == 0 then
				self:SetColorListSelectdIndex(self.CurAppearanceID, self.CurStainAreaID, 0)
				break
			end
		end
	end
end

-- 刷新染色界面
function WardrobeStainPanelView:OnWardrobeUsedStainUpdate()
	self.VM:InitColorOftenList(WardrobeMgr:GetUsedStainList())
end

-- 染色区域改名监听
function WardrobeStainPanelView:OnWardrobeRegionDyeNameUpdate(Params)
	if Params == nil or Params.ID == nil or Params.Name == nil then
		return
	end
	
	local ID = Params.ID
	local Name = Params.Name

	for i = 1, self.ColorAreaListAdapter:GetNum() do
		local ItemData = self.ColorAreaListAdapter:GetItemDataByIndex(i)
		if ItemData and ItemData.ID and ItemData.ID == ID then
			ItemData:UpdateName(Name)
			break
		end
	end

	self.VM:UpdateCurAppearanceSeationName(self.StainType, self.CurAppearanceID, ID)
end

-- 刷新染色按钮状态（推荐，设置态）
function WardrobeStainPanelView:UpdateBtnUnlockState(AppearanceID, ColorID, SectionID)
	if self.StainType == WardrobeDefine.StainType.TryStain then
		self.VM.PanelUnlockVisible = false
		self.VM.ItemLackVisible = false
		self.VM.HorizontalConsumeVisible = false
		return
	end

	if self.StainType == WardrobeDefine.StainType.OnlyLook then
		self.VM.PanelUnlockVisible = true
	end

	if self.StainType == WardrobeDefine.StainType.Normal and ColorID ~= -1  then
		self.VM.PanelUnlockVisible = true
	end

	local IsActive = WardrobeMgr:IsActiveColor(AppearanceID, ColorID)
	local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(AppearanceID)
	local IsCurrentDye = WardrobeMgr:GetIsClothing(AppearanceID) and WardrobeMgr:GetCurAppearanceDyeColor(AppearanceID, SectionID) == ColorID or WardrobeMgr:GetDyeColor(AppearanceID, SectionID) == ColorID
	
	self.VM.ActiveColor = IsActive

	if ColorID == 0 then
		local IsDisable = false
		self.VM.ItemLackVisible = false
		self.VM.HorizontalConsumeVisible = false
		if SectionID == -1 then
			if not IsAppRegionDye then
				IsDisable = IsCurrentDye
			else
				IsDisable = WardrobeMgr:IsSameColorRegionDye(AppearanceID, ColorID)
			end
		else
			IsDisable = IsCurrentDye
		end
	
		-- 统一设置按钮状态
		if IsDisable then
			self.BtnUnlock:SetIsDisabledState(true, true)
		else
			self.BtnUnlock:SetIsRecommendState(true)
		end
		return
	end

	local ColorCfg = DyeColorCfg:FindCfgByKey(ColorID)

	local IsLacked = false
	if ColorCfg ~= nil then
		for _, v in ipairs(ColorCfg.StainAgentRes) do
			local DyeItemID = v.ID
			local DyeItemNum = v.Num
			if v.ID ~= 0 then
				if _G.BagMgr:GetItemNum(DyeItemID) < DyeItemNum then
					IsLacked = true
					break
				end
			end
		end
	end

	if IsActive then
		if IsCurrentDye then
			self.BtnUnlock:SetIsNormalState(true)
		else
			self.BtnUnlock:SetIsRecommendState(true)
		end
	end

	if IsLacked then
		self.CommBtnM1:SetIsRecommendState(true)
	else
		self.CommBtnM1:SetIsNormalState(true)
	end
end

-- 左侧外观Tab选中
function WardrobeStainPanelView:OnAppearanceTabListChanged(Index, ItemData, ItemView)
	self.CurAppearanceID = ItemData.ID
	self.VM:UpdateSubTitle(self.CurAppearanceID)
	self.VM:UpdateCurAppearanceInfo(self.CurAppearanceID, self.CurStainAreaID)
	self.CurPartID = self.VM:GetPart(self.CurAppearanceID)

	-- 设置镜头全身就是全身，当前部位就是当前部位
	if self.MainVM ~= nil and self.MainVM.BtnCameraChecked ~= nil then
		local EquipmentCfgs = EquipmentCfg:FindAllCfgByAppearanceID(ItemData.ID)
		if not table.is_nil_empty(EquipmentCfgs) then
			local Item = EquipmentCfgs[1]
			if self.MainVM.BtnCameraChecked then
				self:ShowModelFocusPart(Item.Part)
			else
				self:SetModelSpringArmToDefault(false)
			end
		end
	end


	self:UpdateModelEquipment()

	if self.VM.BtnBlockChecked then
		for _ , part in pairs(WardrobeDefine.EquipmentTab) do
			local IsHoldWeapon = (part == EquipmentPartList.EQUIP_PART_SLAVE_HAND or part == EquipmentPartList.EQUIP_PART_MASTER_HAND) and self.MainVM ~= nil and self.MainVM.BtnPoseChecked
			if not IsHoldWeapon then
				if self.CurPartID ~= part then
					self.Common_Render2D_UIBP:PreViewEquipment(nil, part, 0)
				end
			end
		end
	end

	-- 更新当前染色ID
	if self.LastAppID ~= self.CurAppearanceID then
		self.VM:InitColorAeraList(self.CurAppearanceID)
	end
	self.LastAppID = self.CurAppearanceID
	self.ColorAreaListAdapter:SetSelectedIndex(1)
	
end

-- 颜色菜单列表选中
function WardrobeStainPanelView:OnColorTabListChanged(Index, ItemData, ItemView)
	local ColorTypeID = ItemData.ID
	self.ColorTypeID = ColorTypeID
	self.LastColorIndex = nil
	local CurStainAreaID =  self.CurStainAreaID 
	local AppID = self.CurAppearanceID
	self.VM:UpdateColorList(self.StainType, ColorTypeID, AppID, CurStainAreaID)

	local CurColor = 0

	local StainViewSuit = self.VM:GetPreStainSuitByAppID(AppID)
	local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(AppID)

	if self.CurStainAreaID == -1 then
		CurColor = IsAppRegionDye and WardrobeUtil.GetUnifyRegionDyeColor(AppID, StainViewSuit.RegionDye) or StainViewSuit.Color
	else
		CurColor = StainViewSuit.RegionDye[CurStainAreaID] ~= nil and StainViewSuit.RegionDye[CurStainAreaID].ColorID or 0
	end

	self.VM:UpdateCurAppearanceSeationName(self.StainType, AppID, CurStainAreaID)

	if self.OftenSelectColor ~= nil then
		CurColor = self.OftenSelectColor
		self.OftenSelectColor = nil
	end

	self:SetColorListSelectdIndex(AppID, CurStainAreaID, CurColor) 
end

-- 设置同颜色列表选中
function WardrobeStainPanelView:SetColorListSelectdIndex(AppID, CurStainAreaID, CurColor)
	local SelectIndex = 0
	for i = 1, self.ColorListAdapter:GetNum() do
		local TempAppearanceItem = self.ColorListAdapter:GetItemDataByIndex(i)
		if TempAppearanceItem and TempAppearanceItem.ID == CurColor then
			SelectIndex = i
			break
		end
	end
	
	if SelectIndex ~= 0 then
		if CurStainAreaID == -1  then
			if CurColor ~= 0 then
				if WardrobeMgr:IsSameColorRegionDye(AppID, CurColor) then
					self.VM.ColorListSelectedIndex = 0
					self.VM.ColorListSelectedIndex = SelectIndex
					self.ColorListAdapter:SetSelectedIndex(SelectIndex)
					return
				end
			end
		else
			self.VM.ColorListSelectedIndex = 0
			self.VM.ColorListSelectedIndex = SelectIndex
			self.ColorListAdapter:SetSelectedIndex(SelectIndex)
			return
		end
	end

	self.VM.ColorListSelectedIndex = 0
	self.ColorListAdapter:CancelSelected()
	self.VM:UpdateCurColorInfo(CurColor ~= nil and CurColor or nil)
	self.VM.PanelUnlockVisible = false
	self.VM.ItemLackVisible = false
	self.VM.HorizontalConsumeVisible = false
end

-- 同色系颜色列表选中
function WardrobeStainPanelView:OnColorListChanged(Index, ItemData, ItemView)
	local ColorID = ItemData.ID

	if ColorID == -1 or ColorID == nil then
		if self.LastColorIndex ~= nil then
			self.ColorListAdapter:SetSelectedIndex(self.LastColorIndex)
		end
		return
	end

	self.CurColorID = ColorID
	self.LastColorIndex = Index

	self.VM:UpdateCurColorInfo(ColorID)
	
	if ColorID == -1 or ColorID == nil then
		self.VM.PanelUnlockVisible = false
		self.VM.ItemLackVisible = false
		self.VM.HorizontalConsumeVisible = false
	end

	if self.CurAppearanceID == 0 then
		return
	end

	-- 更新预览模型的颜色
	local AppID = self.CurAppearanceID
	local ResID =  WardrobeMgr:IsRandomAppID(AppID) and WardrobeMgr:GetEquipIDByRandomApp(AppID) or WardrobeUtil.GetEquipIDByAppearanceID(AppID)
	local Cfg = EquipmentCfg:FindCfgByKey(ResID)

	local StainViewSuitList = self.VM:GetStainSuit()
	local StainViewSuit = StainViewSuitList[Cfg.Part]

	local PreStainView = self.VM:GetPreStainSuitByAppID(AppID)
	local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(AppID)
	local TempStainAera = {}

	if self.CurStainAreaID == -1 then
		self.Common_Render2D_UIBP:PreViewEquipment(ResID, Cfg.Part, IsAppRegionDye and 0 or ColorID)
		local CCfg = ClosetCfg:FindCfgByKey(AppID)
		if CCfg ~= nil and CCfg.StainAera ~= nil then
			for index, v in ipairs(CCfg.StainAera) do
				if v.Ban ~= 1 and v.List ~= "" then
					table.insert(TempStainAera, {ID = index, ColorID = ColorID})
				end
			end
			self:StainPartForSection(AppID, Cfg.Part, TempStainAera)
		end
	else
		local CCfg = ClosetCfg:FindCfgByKey(AppID)
		if CCfg ~= nil and CCfg.StainAera ~= nil then
			for index, v in ipairs(CCfg.StainAera) do
				if v.Ban ~= 1 and v.List ~= ""  then
					local ColorID = 0 
					if StainViewSuit.RegionDye ~= nil and StainViewSuit.RegionDye[index] ~= nil and StainViewSuit.RegionDye[index].ColorID ~= nil then
						ColorID = StainViewSuit.RegionDye[index].ColorID
					end
					table.insert(TempStainAera, {ID = index, ColorID = ColorID})
				end
			end
		end
		self:StainPartForSection(AppID, Cfg.Part, {{ID = self.CurStainAreaID, ColorID = ColorID}})
	end

	local TempRegionDye = {}
	if self.CurStainAreaID == -1 then
		for index, v in ipairs(PreStainView.RegionDye or {}) do
			table.insert(TempRegionDye, {ID = index, ColorID = ColorID})
		end
		self.VM:SetPreStainSuit(Cfg.Part, AppID, ColorID, TempRegionDye)
	else
		for index, v in ipairs(PreStainView.RegionDye or {}) do
			table.insert(TempRegionDye, {ID = index, ColorID = index ~= self.CurStainAreaID and v.ColorID or ColorID})
		end
		self.VM:SetPreStainSuit(Cfg.Part, AppID, ColorID, TempRegionDye)
	end

	if self.IsInsertUsedStain then
		if self.CurColorID > 0 then
			WardrobeMgr:PushUsedStainList(self.CurColorID)
			WardrobeMgr:SengClosetUsedStainSave(self.CurAppearanceID, {self.CurColorID})
		end
	end

	self.LastCurStainAreaID = nil
	self.VM:UpdateColorAeraList(AppID, self.CurStainAreaID)
	self.VM:UpdateBtnUnlockState(self.StainType, self.CurAppearanceID, ColorID, self.CurStainAreaID)
	self:UpdateBtnUnlockState(self.CurAppearanceID, ColorID, self.CurStainAreaID)
	self:UpdateConsumeItem(self.CurAppearanceID, ColorID)
end

-- 区域染色列表选中
function WardrobeStainPanelView:OnColorAreaListChanged(Index, ItemData, ItemView)
	if self.LastCurStainAreaID == nil or self.LastCurStainAreaID ~= ItemData.ID then
		if ItemView ~= nil then
			ItemView:PlaySelectedAnim()
		end
		self.LastCurStainAreaID = ItemData.ID
	end

	self.CurStainAreaID = ItemData.ID
	if self.CurStainAreaID ~= -1 then
		local bShow = true
		self:RegisterTimer(function ()
			local SectionList = WardrobeUtil.ParseSectionIDList(self.CurAppearanceID,  ItemData.ID)
			local Part = WardrobeUtil.GetPartByAppearanceID(self.CurAppearanceID)
			for index, sectionID in ipairs(SectionList) do
				if sectionID ~= 0 then
					self.Common_Render2D_UIBP:ShowAvatarPart(WardrobeDefine.StainPartType[Part], bShow and tonumber(sectionID) or -1, index)
				end
			end
			bShow = not bShow
		end, 0, 0.5, 2)
	end

	local CurColor = 0
	local AppID = self.CurAppearanceID
	local StainViewSuit = self.VM:GetPreStainSuitByAppID(AppID) -- 实际染色的数据
	local RegionDye = StainViewSuit.RegionDye or {}
	if self.CurStainAreaID == -1 then
		local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(self.CurAppearanceID)
		CurColor = IsAppRegionDye and WardrobeUtil.GetUnifyRegionDyeColor(AppID, RegionDye) or StainViewSuit.Color
	else
		CurColor = RegionDye[self.CurStainAreaID] and RegionDye[self.CurStainAreaID].ColorID or 0
	end

	self.IsInsertUsedStain = false
	if CurColor == 0 then
		self.ColorTabListAdapter:CancelSelected()
		self.ColorTabListAdapter:SetSelectedIndex(1)
	else
		local ColorCfg = DyeColorCfg:FindCfgByKey(CurColor)
		if ColorCfg ~= nil then
			self.ColorTabListAdapter:CancelSelected()
			local Index = WardrobeUtil.ColorTypeConvertIndex(ColorCfg.Type)
			self.ColorTabListAdapter:SetSelectedIndex(Index)
		end
	end

	self.IsInsertUsedStain = true
end

-- 常用染色列表选中
function WardrobeStainPanelView:OnColorOftenListChanged(Index, ItemData, ItemView)
	--Todo 选中常用染色，根据当前的区域
	local ColorID = ItemData.ID
	self.OftenSelectColor = ColorID

	if ColorID == 0 then
		self.ColorTabListAdapter:CancelSelected()
		self.ColorTabListAdapter:SetSelectedIndex(1)
	else
		local ColorCfg = DyeColorCfg:FindCfgByKey(ColorID)
		self.ColorTabListAdapter:CancelSelected()
		self.ColorTabListAdapter:SetSelectedIndex(WardrobeUtil.ColorTypeConvertIndex(ColorCfg.Type))
	end
end

-- 更新染色模型
function WardrobeStainPanelView:UpdateModelColor(AppID, ColorID, RegionDyes)
	if AppID == nil then
		return
	end
	-- 判断跟mgr里的数据是否对的上
	local ResID = WardrobeMgr:IsRandomAppID(AppID) and WardrobeMgr:GetEquipIDByRandomApp(AppID) or WardrobeUtil.GetEquipIDByAppearanceID(AppID)
	local PartID = WardrobeUtil.GetPartByAppearanceID(AppID)
	local Cfg = EquipmentCfg:FindCfgByKey(ResID)
	if Cfg == nil then
		return
	end
	-- 预览颜色
	local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(AppID)

	if table.is_nil_empty(RegionDyes) then
		local RegionDye = WardrobeMgr:GetUnlockedAppearanceRegionDyes(AppID)
		RegionDyes = WardrobeUtil.GetRegionDye(AppID, RegionDye)
	end

	if self.CurStainAreaID == -1 then
		self.Common_Render2D_UIBP:PreViewEquipment(ResID, Cfg.Part, IsAppRegionDye and 0 or ColorID)
		self:StainPartForSection(AppID, PartID, RegionDyes)
	else
		self:StainPartForSection(AppID, PartID, RegionDyes)
	end
	if self.StainType == WardrobeDefine.StainType.Normal then
		WardrobeMgr:SetViewSuit(Cfg.Part, AppID, ColorID, RegionDyes)
	end
end

-- 更新染色消耗
function WardrobeStainPanelView:UpdateConsumeItem(ID, ColorID)
	local ColorCfg = DyeColorCfg:FindCfgByKey(ColorID)
	if ColorCfg == nil then
		return
	end

	if self.StainType == WardrobeDefine.StainType.TryStain then
		return
	end

	local IsActive = WardrobeMgr:IsActiveColor(ID, ColorID)
	self.VM.Consume1Visible = false
	self.VM.Consume2Visible = false
	self.VM.HorizontalConsumeVisible = not IsActive

	-- 更新道具
	local Items = {self.VM.ConsumeVM1, self.VM.ConsumeVM2}
	if not IsActive then
		for index, v in ipairs(ColorCfg.StainAgentRes) do
			if v.ID ~= 0 and Items[index] ~= nil then
				local ItemLacked = BagMgr:GetItemNum(v.ID) < v.Num
				local ColorNum = RichTextUtil.GetText(string.format("%d", BagMgr:GetItemNum(v.ID)), ItemLacked and WardrobeDefine.TxtColor.WarningColor or "#D5D5D5FF")
				local Item = ItemUtil.CreateItem(v.ID, 0)
				Items[index].BagSlotVM:UpdateVM(Item, {IsShowNum = false, IsShowLeftCornerFlag = false, PanelBagVisible = true})
				Items[index].Num = string.format("%s/%d", ColorNum, v.Num)
				Items[index].ItemNum = v.Num
			end

			if index == 1 then
				self.VM.Consume1Visible = v.ID ~= 0
			elseif index == 2 then
				self.VM.Consume2Visible = v.ID ~= 0
			end
		end
	end
end

function WardrobeStainPanelView:OnClickedBtnHand(ToggleButton, State)
	local bChanged = self.SuperView.OnClickedBtnHand(self.SuperView, ToggleButton, State)
	if not bChanged then
		self.WardrobeOperateItem.BtnHand:SetChecked(self.MainVM.BtnHandChecked, false)
	end
end

function WardrobeStainPanelView:OnClickedBtnHat(ToggleButton, State)
	local bChanged = self.SuperView.OnClickedBtnHat(self.SuperView, ToggleButton, State)
	if not bChanged then
		self.WardrobeOperateItem.BtnHat:SetChecked(self.MainVM.BtnHatChecked, false)
	end
end

function WardrobeStainPanelView:OnClickedBtnHatStyle(ToggleButton, State)
	local bChanged = self.SuperView.OnClickedBtnHatStyle(self.SuperView, ToggleButton, State)
	if not bChanged then
		if not self.MainVM.BtnHatStyleVisible then
			self.WardrobeOperateItem.BtnHatStyle:SetCheckedState(_G.UE.EToggleButtonState.Locked, false)
		else
			self.WardrobeOperateItem.BtnHatStyle:SetChecked(self.MainVM.BtnHatStyleChecked, false)
		end
	end
end

function WardrobeStainPanelView:OnClickedBtnPose(ToggleButton, State)
	local bChanged = self.SuperView.OnClickedBtnPose(self.SuperView, ToggleButton, State)
	if not bChanged then
		self.WardrobeOperateItem.BtnPose:SetChecked(self.MainVM.BtnPoseChecked, false)
	end

	if bChanged then
		-- 需要更新一下pose武器装备
		if self.MainVM.BtnPoseChecked then
			if self.Common_Render2D_UIBP ~= nil then
				local ViewSuit = WardrobeMgr:GetViewSuit()
				local HasEquipWeaponViewSuit = false
				for key, v in pairs(ViewSuit) do
					if key == EquipmentPartList.EQUIP_PART_MASTER_HAND or key == EquipmentPartList.EQUIP_PART_SLAVE_HAND then
						HasEquipWeaponViewSuit = true
						local EquipID = WardrobeUtil.GetEquipIDByAppearanceID(v.Avatar)
						local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(v.Avatar)
						self.Common_Render2D_UIBP:PreViewEquipment(EquipID, key, IsAppRegionDye and 0 or v.Color)
						-- Todo 区域染色逻辑
						self:StainPartForSection(v.Avatar, tonumber(key), v.RegionDye)
					end
				end
	
				if not HasEquipWeaponViewSuit then
					local EquipList = EquipmentVM.ItemList
					for _, part in pairs(WardrobeDefine.EquipmentTab) do
						if EquipmentPartList.EQUIP_PART_MASTER_HAND == part or EquipmentPartList.EQUIP_PART_SLAVE_HAND == part then
							-- 判断当前装备
							local CurrentAppID = WardrobeMgr:GetEquipPartAppearanceID(part)
							if CurrentAppID ~= 0 then
								local EquipID = WardrobeUtil.GetEquipIDByAppearanceID(CurrentAppID)
								local ColorID = WardrobeMgr:GetCurAppearanceDyeColor(CurrentAppID)
								local RegionDye = WardrobeMgr:GetCurAppearanceRegionDyes(CurrentAppID)
								local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(CurrentAppID)
								self.Common_Render2D_UIBP:PreViewEquipment(EquipID, part, IsAppRegionDye and 0 or ColorID)
								--Todo 区域染色逻辑
								self:StainPartForSection(CurrentAppID, tonumber(part), RegionDye)
							else
								local TempEquip = EquipList[part]
								if TempEquip ~= nil then
									local EquipID = TempEquip.ResID
									self.Common_Render2D_UIBP:PreViewEquipment(EquipID, part, 0)
								else
									self.Common_Render2D_UIBP:PreViewEquipment(nil, part, 0)
								end
							end
						end
					end
				end
			end
		end
	end
end

function WardrobeStainPanelView:OnClickedBtnCamera(ToggleButton, State)
	local IsShow = State == _G.UE.EToggleButtonState.Checked
	self.MainVM.BtnCameraChecked = IsShow
	if IsShow then
		_G.FLOG_INFO(string.format("WardrobeStainPanelView 切换镜头到 %s", ProtoEnumAlias.GetAlias(ProtoCommon.equip_part, self.CurPartID)))
		self:ShowModelFocusPart(self.CurPartID)
	else
		_G.FLOG_INFO(string.format("WardrobeStainPanelView 切换全身镜头"))
		self:ShowAllModel(true)
	end
end

-- 显示全身/显示单个装备
function WardrobeStainPanelView:OnClickedBtnBlock(ToggleButton, State)
	local IsShow = State == _G.UE.EToggleButtonState.Checked
	self.VM.BtnBlockChecked = IsShow
	
	local CurAppID = self.CurAppearanceID
	local PartID = WardrobeUtil.GetPartByAppearanceID(CurAppID)

	-- 清空所有部位
	if self.VM.BtnBlockChecked then
		for _ , part in pairs(WardrobeDefine.EquipmentTab) do
			local IsHoldWeapon = (part == EquipmentPartList.EQUIP_PART_SLAVE_HAND or part == EquipmentPartList.EQUIP_PART_MASTER_HAND) and self.MainVM.BtnPoseChecked
			if not IsHoldWeapon then
				if self.CurPartID ~= part then
					self.Common_Render2D_UIBP:PreViewEquipment(nil, part, 0)
				end
			end
		end
	else
		self:UpdateModelEquipment()
	end
end

-- 点击打开常用染色
function WardrobeStainPanelView:OnClickedBtnGO()
	self.VM:UpdateColorOfenList(not self.OftenListOpen)
	self.VM.ShowOftenAll = not self.VM.ShowOftenAll
	self.OftenListOpen = not self.OftenListOpen
	self.VM.MoreOftenCheck = self.OftenListOpen
end

-- 点击激活颜色
function WardrobeStainPanelView:OnClickedActive()
	if not CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_CLOSET_DYE, true) then
		return
	end

	if self.CurColorID == 0 or self.CurAppearanceID == 0  then
		return
	end

	local Color = self.CurColorID 
	local AppID = self.CurAppearanceID

	local IsActive = WardrobeMgr:IsActiveColor(AppID, Color)

	if IsActive then
		return
	end

	if self:IsEnoughStainItem(Color) then
		WardrobeMgr:SendClosetActiveReq(AppID, Color)
		return
	end

	-- 染色试剂不足
	self:ShowNotEoughtStainWin(Color)
end

-- 染剂是否充足
function WardrobeStainPanelView:IsEnoughStainItem(ColorID)
	local IsEnough = false

	local ColorCfg = DyeColorCfg:FindCfgByKey(ColorID)
	if ColorCfg ~= nil then
		for _, v in ipairs(ColorCfg.StainAgentRes) do
			if v.ID ~= 0 then
				IsEnough = BagMgr:GetItemNum(v.ID) >= v.Num
				if not IsEnough then
					return IsEnough
				end
			end
		end
	end

	return IsEnough
end

-- 展示染色不足弹窗
function WardrobeStainPanelView:ShowNotEoughtStainWin(ColorID)
	local ColorCfg = DyeColorCfg:FindCfgByKey(ColorID)
	if ColorCfg ~= nil then
		for _, v in ipairs(ColorCfg.StainAgentRes) do
			if v.ID ~= 0 then
				if BagMgr:GetItemNum(v.ID) < v.Num then
					local function GoShopping()
						local Cfg = ItemUtil.GetItemGetWayList(v.ID)
						if table.length(Cfg) > 0 then
							local TransferData = {}
							TransferData.NeedBuyNum =  v.Num - _G.BagMgr:GetItemNum(v.ID)
							TransferData.FunValue = 0
							SystemEntranceMgr:ShowStoreEntrance(v.ID, TransferData)
						end
					end
			
					local QuantityText = string.format(_G.LSTR("%s/%d"), RichTextUtil.GetText(_G.BagMgr:GetItemNum(v.ID), "dc5868"), v.Num)
					local CostText = string.format(_G.LSTR(1080101), RichTextUtil.GetText(ItemUtil.GetItemName(v.ID), "d1ba8e"))
					local Params = {ItemResID = v.ID, TextQuantity = QuantityText}
							_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, _G.LSTR(620039), CostText, GoShopping, nil, _G.LSTR(620011), _G.LSTR(620029), Params)
					return
				end
			end
		end
	end
end

-- 点击染色区域改名
function WardrobeStainPanelView:OnClickedRegionDyeName()
	if not CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_CLOSET_DYE, true) then
		return
	end
	
	if self.CurAppearanceID == 0 then
		return
	end

	local AppID = self.CurAppearanceID
	local CurStainAreaID = self.CurStainAreaID
    local Params = {
        Title = _G.LSTR(1080141),  --区域染色备注
        Desc = _G.LSTR(1080142), --区域名称
		HintText = _G.LSTR(1080143), --输入区域名称
        MaxTextLength = 14,
		EmptyInputEnable = true,
        SureCallback = function(Text)
			if Text ~= "" then
				_G.JudgeSearchMgr:QueryTextIsLegal(Text, function( IsLegal )
					if not IsLegal then
						MsgTipsUtil.ShowTips(_G.LSTR(10057)) 
						return
					end
					local Region = {}
					Region.ID = CurStainAreaID
					Region.Color = 0
					Region.Name = Text
					WardrobeMgr:SendRegionDyeRenameRep(Region, AppID)
				end)
			end
        end
    }

    _G.UIViewMgr:ShowView(_G.UIViewID.CommonPopupInput, Params)
end

-- 点击解锁并染色
function  WardrobeStainPanelView:OnClickedActiveAndStain()
	if not CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_CLOSET_DYE, true) then
		return
	end
	
	if self.CurColorID == 0 or self.CurAppearanceID == 0 then
		return
	end

	local Color = self.CurColorID 
	local AppID = self.CurAppearanceID
	local CurStainAreaID = self.CurStainAreaID

	local IsActive = WardrobeMgr:IsActiveColor(AppID, Color)

	if IsActive then
		return
	end

	if self:IsEnoughStainItem(Color) then
		local IsAllDye = CurStainAreaID == -1
		local RegionDye = {ID  = CurStainAreaID == -1 and 1 or CurStainAreaID, ColorID = Color, Name = "" }
		WardrobeMgr:SendClosetActiveAndStainReq(AppID, RegionDye, IsAllDye)
		return
	end

	self:ShowNotEoughtStainWin(Color)
end

-- 点击染色
function WardrobeStainPanelView:OnClickedBtnUnlock()
	if not CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_CLOSET_DYE, true) then
		return
	end
	
	if self.CurAppearanceID == 0 then
		return
	end

	local Color = self.CurColorID 
	local AppID = self.CurAppearanceID
	local CurStainAreaID = self.CurStainAreaID

	-- 如果是当前的染色 
	local CurColorID = WardrobeMgr:GetIsClothing(AppID) and WardrobeMgr:GetCurAppearanceDyeColor(AppID, CurStainAreaID) or WardrobeMgr:GetDyeColor(AppID, CurStainAreaID)
	local IsActive = WardrobeMgr:IsActiveColor(AppID, Color)

	-- 取消染色
	if CurColorID == Color then
		if self.CurStainAreaID == -1 then
			if WardrobeMgr:IsSameColorRegionDye(AppID, 0) then
				MsgTipsUtil.ShowTips(_G.LSTR(1080144))
				return
			end
		else
			if CurColorID == 0 then
				MsgTipsUtil.ShowTips(_G.LSTR(1080144))
				return
			end	
		end
		if self.CurStainAreaID == -1 then
			WardrobeMgr:SendClosetDyeRecoveryReq(AppID)
		else
			WardrobeMgr:SendClosetRegionDyeReq(AppID, CurStainAreaID, 0)
		end
		return
	end

	-- 染色
	if IsActive then
		if CurStainAreaID == -1 then
			WardrobeMgr:SendClosetDyeReq(AppID, Color)
		else
			WardrobeMgr:SendClosetRegionDyeReq(AppID, CurStainAreaID, Color)
		end
	end
end

-- 点击预览弹窗
function  WardrobeStainPanelView:OnClickedBtnPreviewColor()
	local CurAppID = self.CurAppearanceID
	local Params = {
		AppID =  CurAppID,
		StainColorList = self.VM:GetStainSuitByAppID(CurAppID),
		PreviewColorList = self.VM:GetPreStainSuitByAppID(CurAppID)
	}
	_G.UIViewMgr:ShowView(_G.UIViewID.WardrobePreviewColorWin, Params)
end

-- 更新当前外观
function WardrobeStainPanelView:UpdateModelEquipment()
	local ItemList = {}
	local EquipList = EquipmentVM.ItemList

	local CurViewSuit = self.VM:GetStainSuit()
	for index, partID in pairs(WardrobeDefine.EquipmentTab) do
		if CurViewSuit[partID] ~= nil and CurViewSuit[partID].Avatar ~= 0 then
			local Equip = CurViewSuit[partID]
			local AppID = CurViewSuit[partID].Avatar
			local EquipID = WardrobeMgr:IsRandomAppID(AppID) and WardrobeMgr:GetEquipIDByRandomApp(AppID) or WardrobeUtil.GetEquipIDByAppearanceID(AppID)
			table.insert(ItemList, {AppID = AppID,  EquipID = EquipID, PartID = partID, ColorID = Equip.Color, RegionDyes = Equip.RegionDye})
		else
			local HasEquip = false
			for part, value in pairs(EquipList) do
				if partID == part then
					HasEquip = true
					local TempEquip = value
					local EquipID = TempEquip.ResID
					local CurrentAppID = WardrobeMgr:GetEquipPartAppearanceID(part)
					local ColorID = 0
					local RegionDyes = {}
					if CurrentAppID ~= 0 then
						EquipID = WardrobeUtil.GetEquipIDByAppearanceID(CurrentAppID)
						ColorID = WardrobeMgr:GetCurAppearanceDyeColor(CurrentAppID)
						RegionDyes = WardrobeMgr:GetCurAppearanceRegionDyes(CurrentAppID)
					end
					table.insert(ItemList, {AppID = CurrentAppID, EquipID = EquipID, PartID = partID, ColorID = ColorID, RegionDyes =  RegionDyes})
				end
			end

			if not HasEquip then
				table.insert(ItemList, {AppID = 0 , EquipID = nil, PartID = partID, ColorID = 0, RegionDyes = {}})
			end
		end
	end

	-- 如果有预览效果
	self:RenderPreviewEquipmentList(ItemList)
end

-- 模型穿上装备
function WardrobeStainPanelView:RenderPreviewEquipmentList(Items)
	for i = 1, #Items do
		if Items[i] ~= nil and Items[i] ~= 0 then
			local Color = Items[i].ColorID or 0
			local PartID = Items[i].PartID
			local EquipID = Items[i].EquipID
			local RegionDyes = Items[i].RegionDyes or {}
			local AppID =  Items[i].AppID
			local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(AppID)
			if PartID == EquipmentPartList.EQUIP_PART_HEAD then
				if self.MainVM ~= nil and self.MainVM.BtnHatChecked ~= nil then
					if self.MainVM.BtnHatChecked then
						self.Common_Render2D_UIBP:PreViewEquipment(EquipID, PartID, IsAppRegionDye and 0 or Color)
						self:StainPartForSection(AppID, PartID, RegionDyes)
					else
						self.Common_Render2D_UIBP:PreViewEquipment(nil, PartID, 0)
					end				
				end
			elseif PartID == EquipmentPartList.EQUIP_PART_SLAVE_HAND or PartID == EquipmentPartList.EQUIP_PART_MASTER_HAND then
				if self.MainVM ~= nil and self.MainVM.BtnHandChecked ~= nil then
					if self.MainVM.BtnHandChecked or self.MainVM.BtnPoseChecked then
						self.Common_Render2D_UIBP:PreViewEquipment(EquipID, PartID, IsAppRegionDye and 0 or Color)
						self:StainPartForSection(AppID, PartID, RegionDyes)
					else
						self.Common_Render2D_UIBP:PreViewEquipment(nil, PartID, 0)
					end
				end
			else
				self.Common_Render2D_UIBP:PreViewEquipment(EquipID, PartID, IsAppRegionDye and 0 or Color)
				self:StainPartForSection(AppID, PartID, RegionDyes)
			end
		end
	end
end

-- 展示全模型
function WardrobeStainPanelView:ShowAllModel(bBackAll)
	self:SetModelSpringArmToDefault(true)
	self.MainVM.BtnCameraChecked = false
end

-- 展示对应部位镜头
function WardrobeStainPanelView:ShowModelFocusPart(Part)
	if type(Part) ~= 'number' then
		return
	end

	if self.IsTransition  then
		self.IsTransition = false
		return
	end

	local AttachType = MajorUtil.GetMajorAvatarComponent():GetAttachTypeIgnoreChangeRole()
	if Part == EquipmentPartList.EQUIP_PART_MASTER_HAND or Part == EquipmentPartList.EQUIP_PART_SLAVE_HAND then
		Part = 0
	end

	local CameraFocusCfg = self.CameraFocusCfgMap:GetCfgByRaceAndProf(AttachType, MajorUtil.GetMajorProfID(), Part)
	if CameraFocusCfg == nil then return end
	-- _G.FLOG_INFO(string.format("WardrobeStainPanelView:ShowModelFocusPart Fov %s ", tostring(CameraFocusCfg.FOV)))
	self.Common_Render2D_UIBP:SetCameraLockedFOV(CameraFocusCfg.FOV)
	self.Common_Render2D_UIBP:SetSpringArmCenterOffsetY(-50 + WardrobeDefine.StainPanelOffsetY, CameraFocusCfg.Distance)
	local DPIScale = _G.UE.UWidgetLayoutLibrary.GetViewportScale(self)
	local ViewportSize = UIUtil.GetViewportSize() / DPIScale
	local UIX = ViewportSize.X / 2 + (CameraFocusCfg.UIX + WardrobeDefine.StainPanelOffsetY)
	local UIY = ViewportSize.Y / 2 + CameraFocusCfg.UIY
	self.Common_Render2D_UIBP:SetCameraFocusScreenLocation(UIX * DPIScale, UIY * DPIScale, CameraFocusCfg.SocketName,
	CameraFocusCfg.Distance)
	
	-- 角色模型
	self.Common_Render2D_UIBP:SetModelRotation(0, CameraFocusCfg.Yaw , 0, true)

	-- 输入限制
	self.Common_Render2D_UIBP:EnableZoom(false)
	self.Common_Render2D_UIBP:EnablePitch(false)
	self.Common_Render2D_UIBP:EnableRotator(false)
	self.Common_Render2D_UIBP:SetCameraFocusEndCallback(function() self.Common_Render2D_UIBP:EnableRotator(true) end)
	
	self.ShowModelType = WardrobeDefine.ShowModelType.Part
end

-- 设置镜头位置
function WardrobeStainPanelView:SetModelSpringArmToDefault(bInterp)
	-- 设置一下相机参数
	if self.ShowModelType == WardrobeDefine.ShowModelType.All then
		return
	end
	if self.IsTransition then
		self.IsTransition  = false
		return
	end

	local DefaultSpringArmLength = nil
	if CommonUtil.IsObjectValid(self.Common_Render2D_UIBP) then
		if nil ~= self.Common_Render2D_UIBP.CamControlParams and self.Common_Render2D_UIBP.CamControlParams.DefaultViewDistance ~= nil then
			DefaultSpringArmLength = self.Common_Render2D_UIBP.CamControlParams.DefaultViewDistance
		end
	end
	
	self.Common_Render2D_UIBP:SetSpringArmCenterOffsetY(-50 + WardrobeDefine.StainPanelOffsetY, DefaultSpringArmLength)
	self.Common_Render2D_UIBP:EnableRotator(true)
	self.Common_Render2D_UIBP:SetCameraFocusScreenLocation(nil, nil, nil, nil)
	self.Common_Render2D_UIBP:SetModelRotation(0, 0 , 0, true)
	self.Common_Render2D_UIBP:ResetViewDistance(bInterp)
	self.Common_Render2D_UIBP:SetPostProcessVignetteIntensity(self.VignetteIntensityDefaultValue)
	self.Common_Render2D_UIBP:EnableZoom(true)
	
	local AttachType = MajorUtil.GetMajorAvatarComponent():GetAttachTypeIgnoreChangeRole()
	local CameraParams = self.CameraFocusCfgMap:GetCfgByRaceAndProf(AttachType, MajorUtil.GetMajorProfID() , 0)

	if CameraParams ~= nil then
		self.Common_Render2D_UIBP:ResetViewDistance(bInterp)
	end

	self.ShowModelType = WardrobeDefine.ShowModelType.All
end

-- 模型组装完成回调
function WardrobeStainPanelView:OnAssembleAllEnd(Params)
	if (self.Common_Render2D_UIBP == nil) then return end
	local ChildActor = self.Common_Render2D_UIBP:GetCharacter()
	if (ChildActor == nil) then return end
	local EntityID = Params.ULongParam1
	local ObjType = Params.IntParam1
	local AttrComp = ChildActor:GetAttributeComponent()
	if not (EntityID == AttrComp.EntityID and ObjType == AttrComp.ObjType) then
		return
	end
end

-- 区域染色接口
function WardrobeStainPanelView:StainPartForSection(AppID, PartID, RegionDyes)
	if AppID == nil then
		return
	end

	for _, v in ipairs(RegionDyes or {}) do
		local SectionList = WardrobeUtil.ParseSectionIDList(AppID, v.ID)
		for _, sectionID in ipairs(SectionList) do
			self.Common_Render2D_UIBP:StainPartForSection(WardrobeDefine.StainPartType[PartID], sectionID, v.ColorID)
		end
	end	
end

function WardrobeStainPanelView:SaveNoShowTipsTime(Params)
	if Params ~= nil and Params.IsNeverAgain ~= nil then
		if Params.IsNeverAgain then
			local ServerTime = _G.TimeUtil.GetServerLogicTime()
			WardrobeMgr:SetStainNoShowTipsTime(ServerTime)
			USaveMgr.SetInt(SaveKey.StainTipsNoShowTime, ServerTime, true)
		else
			WardrobeMgr:SetStainNoShowTipsTime(0)
			USaveMgr.SetInt(SaveKey.StainTipsNoShowTime, 0, true)
		end
	end
end

function WardrobeStainPanelView:ExitStainPanel()
	self.VM.BtnBlockChecked = true
	self.VM.BtnBlockVisible = false
	self.SuperView.ShowMainPanel(self.SuperView, false, self.CurPartID)
	self:Hide()
end

function WardrobeStainPanelView:ShowExitStainPanelTips()
	local function GoPreviewColorWinView()
		self:OnClickedBtnPreviewColor()
	end

	local function ExitStainPanelView(View, Params)
		self:SaveNoShowTipsTime(Params)
		self:ExitStainPanel()
	end

	local Params = {NeverMindText = _G.LSTR(1080145), bUseNever = true} --今日不再提示
	--退出确认, 
	--当前外观仍有未确认的染色, 是否确认要退出染色?
	--查看染色
	--退 出
	_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, _G.LSTR(1080146), _G.LSTR(1080147), ExitStainPanelView, GoPreviewColorWinView, _G.LSTR(1080148), _G.LSTR(1080149), Params)
end

return WardrobeStainPanelView