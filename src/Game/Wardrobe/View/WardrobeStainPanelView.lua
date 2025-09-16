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
---@field BtnGo UFButton
---@field BtnHand UToggleButton
---@field BtnHat UToggleButton
---@field BtnHatStyle UToggleButton
---@field BtnPose UToggleButton
---@field BtnUnlock CommBtnLView
---@field CommonBkg CommonBkg01View
---@field CommonTitle CommonTitleView
---@field Consume1 WardrobeConsumeItemView
---@field Consume2 WardrobeConsumeItemView
---@field HorizontalConsume UFHorizontalBox
---@field ImgDisable3 UFImage
---@field ImgMask UFImage
---@field PanelBg UFCanvasPanel
---@field PanelColor UFCanvasPanel
---@field PanelList UFCanvasPanel
---@field PanelName UFCanvasPanel
---@field PanelTab UFCanvasPanel
---@field PanelTab2 UFCanvasPanel
---@field PanelTitle UFCanvasPanel
---@field StainTag WardrobeStainTagItemView
---@field TableViewBall UTableView
---@field TableViewBox UTableView
---@field TableViewList UTableView
---@field TableViewPosition UTableView
---@field TableViewStyle UTableView
---@field TextConsume UFTextBlock
---@field TextLack UFTextBlock
---@field TextName UFTextBlock
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
	--self.BtnGo = nil
	--self.BtnHand = nil
	--self.BtnHat = nil
	--self.BtnHatStyle = nil
	--self.BtnPose = nil
	--self.BtnUnlock = nil
	--self.CommonBkg = nil
	--self.CommonTitle = nil
	--self.Consume1 = nil
	--self.Consume2 = nil
	--self.HorizontalConsume = nil
	--self.ImgDisable3 = nil
	--self.ImgMask = nil
	--self.PanelBg = nil
	--self.PanelColor = nil
	--self.PanelList = nil
	--self.PanelName = nil
	--self.PanelTab = nil
	--self.PanelTab2 = nil
	--self.PanelTitle = nil
	--self.StainTag = nil
	--self.TableViewBall = nil
	--self.TableViewBox = nil
	--self.TableViewList = nil
	--self.TableViewPosition = nil
	--self.TableViewStyle = nil
	--self.TextConsume = nil
	--self.TextLack = nil
	--self.TextName = nil
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
	self:AddSubView(self.CommonBkg)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.Consume1)
	self:AddSubView(self.Consume2)
	self:AddSubView(self.StainTag)
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
				{ "AppearanceName", UIBinderSetText.New(self, self.TextName)},
				{ "CurColorName", UIBinderSetText.New(self, self.TextUnlock)},
				{ "CurColor", UIBinderSetBrushTintColorHex.New(self, self.StainTag.ImgStainColor)},
				{ "CurColorVisible", UIBinderSetIsVisible.New(self, self.StainTag.ImgStainColor)},
				{ "CurColorVisible", UIBinderSetIsVisible.New(self, self.StainTag.ImgBg, true)},
				{ "BtnUnlockTxt", UIBinderSetText.New(self, self.BtnUnlock.TextContent)},
				{ "BtnUnlockVisible", UIBinderSetIsVisible.New(self, self.BtnUnlock)},
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
				{ "BtnCameraChecked", UIBinderSetIsChecked.New(self, self.WardrobeOperateItem.BtnCamera)},
				{ "BtnHatStyleVisible", UIBinderSetIsVisible.New(self, self.WardrobeOperateItem.BtnHatStyle, false, true)},
			}
		}
	}

	self.CameraFocusCfgMap = CameraFocusCfgMap.New()

	self.CurColorID = 0	
	self.ColorTypeID = 0
	self.CurStainAreaID = -1
	self.CurAppearanceID = 0
	self.OftenSelectColor = nil
	self.OftenListOpen = false
	self.StainType = WardrobeDefine.Normal
	self.Common_Render2D_UIBP = nil
	self.ShowModelType = nil
	self.SuperView = nil
	self.StainPanelY = 25
	self.IsTransition = true
end

function WardrobeStainPanelView:OnDestroy()
end

function WardrobeStainPanelView:OnShow()
	self:InitText()
	UIUtil.SetIsVisible(self.CommonBkg, false)
	UIUtil.SetIsVisible(self.PanelTitle, false)
	self.Common_Render2D_UIBP = self.Params.SuperView.Common_Render2D_UIBP
	self.SuperView = self.Params.SuperView
	
	self.CameraFocusCfgMap:SetAssetUserData(self.Common_Render2D_UIBP:GetEquipmentConfigAssetUserData())

	self.BtnBack:AddBackClick(self, function () 
		self.VM.BtnBlockChecked = true
		self.VM.BtnBlockVisible = false
		self.SuperView.ShowMainPanel(self.SuperView, false) self:Hide() 
	end)
	self.StainType = self.Params.StainType
	self.IsTransition = true


	-- 初始化染色的装备
	local Suit = WardrobeMgr:GetCurAppearanceList()
	for _, appID in ipairs(self.Params.AppearanceList) do
		local PartID = WardrobeUtil.GetPartByAppearanceID(appID)
		if Suit[PartID] == nil then
			local RegionDye = WardrobeMgr:GetUnlockedAppearanceRegionDyes(appID)
			local Color = WardrobeMgr:GetDyeColor(appID)
			local TempStainAera =  WardrobeUtil.GetRegionDye(appID, RegionDye)
			WardrobeMgr:SetStainViewSuit(PartID, appID, Color, TempStainAera)
		else
			local value = Suit[PartID]
			if value and value.Avatar and value.Avatar == appID then
				local TempStainAera = WardrobeUtil.GetRegionDye(appID, value.RegionDye)
				WardrobeMgr:SetStainViewSuit(PartID, appID, value.Color, TempStainAera)
			else
				local RegionDye = WardrobeMgr:GetUnlockedAppearanceRegionDyes(appID)
				local Color = WardrobeMgr:GetDyeColor(appID)
				local TempStainAera = WardrobeUtil.GetRegionDye(appID, RegionDye)
				WardrobeMgr:SetStainViewSuit(PartID, appID, Color, TempStainAera)
			end
		end
	end
	
	self.VM:InitAppearanceTabList(self.Params.AppearanceList)
	self.VM:UpdateTitle(self.StainType)
	self.VM:InitColorTabList()

	self.VM.MoreOftenCheck = self.OftenListOpen
	self.BtnGo:SetChecked(false, false)

	if self.StainType == WardrobeDefine.StainType.Normal then
		self:PlayAnimation(self.Tab1)
		self.VM.AppearanceTabVisible = true
		local TempIDList = {}				
		for _, AppID in ipairs( self.Params.AppearanceList) do		
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

	self:InitBtnHatStyleState()
	self.VM.BtnBlockVisible = true
	self.WardrobeOperateItem.BtnBlock:SetChecked(self.VM.BtnBlockChecked, true)
	WardrobeMgr:SendClosetUsedStainQuery()
end

function WardrobeStainPanelView:InitText()
	self.TextLack:SetText(_G.LSTR(1080076))
	self.TextConsume:SetText(_G.LSTR(1080059))
end

function WardrobeStainPanelView:OnHide()
	self.CurColorID = 0	
	self.ColorTypeID = 0
	self.CurAppearanceID = 0
	self.LastColorIndex = nil
	self.StainType = WardrobeDefine.Normal
	WardrobeMgr:ClearStainViewSuit()
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

function WardrobeStainPanelView:InitBtnHatStyleState()
	local HasGimmick = self:CheckHeadHasGimmick()
	if HasGimmick then
		self.MainVM.BtnHatStyleDisabled = false
		self.WardrobeOperateItem.BtnHatStyle:SetCheckedState(self.MainVM.BtnHatStyleChecked and _G.UE.EToggleButtonState.Checked  or _G.UE.EToggleButtonState.Unchecked, false)
	else
	    self.MainVM.BtnHatStyleDisabled = true
		self.BtnHatStyle:SetCheckedState(_G.UE.EToggleButtonState.Locked, false)
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
end

-- 更新激活
function WardrobeStainPanelView:OnWardrobeActiveStain()
	--更新
	self.VM:UpdateBtnUnlockState(self.StainType, self.CurAppearanceID, self.CurColorID)
	self.VM:UpdateColorListUnlockState(self.StainType, self.CurAppearanceID)
	self:UpdateBtnUnlockState(self.CurAppearanceID, self.CurColorID)
	self:UpdateConsumeItem(self.CurAppearanceID, self.CurColorID)
	-- if self.CurStainAreaID == -1 then
	-- 	self:UpdateModelColor(self.CurAppearanceID, self.CurColorID)
	-- else
	-- 	self:StainPartForSection(self.CurAppearanceID, self.CurPartID, {{ID = self.CurStainAreaID, ColorID = self.CurColorID}})
	-- end
end

-- 监听染色
function WardrobeStainPanelView:OnWardrobeDyeUpdate(Params)
	local RecoveryColor = Params.ColorID
	--左边装备
	self.VM:UpdateAppearanceTabList()
	--更新颜色标志
	self.VM:UpdateColorListUnlockState(self.StainType, self.CurAppearanceID)
	--更新解锁按钮装备
	self.VM:UpdateBtnUnlockState(self.StainType, self.CurAppearanceID, RecoveryColor or self.CurColorID)

	self:UpdateBtnUnlockState(self.CurAppearanceID, RecoveryColor or self.CurColorID)
	--更新模型颜色
	self:UpdateModelColor(self.CurAppearanceID, RecoveryColor or self.CurColorID)
	--更新染色区域
	local RegionDyes = WardrobeMgr:GetUnlockedAppearanceRegionDyes(self.CurAppearanceID)
	-- local CurPartID
	-- for _, v in ipairs(RegionDyes) do
	-- 	self.VM:UpdateColorAeraList(self.CurAppearanceID, v.ID, -1)
	-- end
	self.VM:UpdateColorAeraList(self.CurAppearanceID, self.CurPartID, -1)


	--取消染色 
	if RecoveryColor and RecoveryColor == 0 then
		self.ColorListAdapter:CancelSelected()
		self.VM.BtnUnlockVisible = false
		self.VM:UpdateCurColorInfo(nil)
	end
end

-- 监听区域染色染色
function WardrobeStainPanelView:OnWardrobeRegionDyeUpdate(Params)
	local RecoveryColor = Params.ColorID
	local RegionDyes = Params.RegionDyes or  {}
	local RecoveryColor
	for _, v in ipairs(RegionDyes) do
		if v.ID == self.CurStainAreaID then
			RecoveryColor = v.ColorID == 0 and v.ColorID or nil
			break
		end
	end

	--左边装备
	self.VM:UpdateAppearanceTabList()
	--更新颜色标志
	self.VM:UpdateColorListUnlockState(self.StainType, self.CurAppearanceID, self.CurStainAreaID)
	--更新解锁按钮装备
	self.VM:UpdateBtnUnlockState(self.StainType, self.CurAppearanceID, RecoveryColor or self.CurColorID, self.CurStainAreaID)

	self:UpdateBtnUnlockState(self.CurAppearanceID, RecoveryColor or self.CurColorID, self.CurStainAreaID)

	-- 更新左边颜色
	for _, v in ipairs(RegionDyes) do
		self.VM:UpdateColorAeraList(self.CurAppearanceID, v.ID, self.CurStainAreaID)
	end
	--更新模型颜色
	for _, v in ipairs(RegionDyes) do
		if v.ID == self.CurStainAreaID then
			self:StainPartForSection(self.CurAppearanceID, self.CurPartID, {{ID = self.CurStainAreaID, ColorID = self.CurColorID}})
		end
	end

	-- for _, v in ipairs(RegionDyes) do
	-- 	self:UpdateModelColor(self.CurAppearanceID, RecoveryColor or self.CurColorID, RegionDyes)
	-- end

	--取消染色 --如果是当前的颜色
	for _, v in ipairs(RegionDyes) do
		if v.ID == self.CurStainAreaID then
			if v.ColorID == 0 then
				self.ColorListAdapter:CancelSelected()
				self:StainPartForSection(self.CurAppearanceID, self.CurPartID, {{ID = self.CurStainAreaID, ColorID = 0}})
				self.VM.BtnUnlockVisible = false
				self.VM:UpdateCurColorInfo(nil)
			end
			break
		end
	end
end

-- 刷新染色界面
function WardrobeStainPanelView:OnWardrobeUsedStainUpdate()
	self.VM:InitColorOftenList(WardrobeMgr:GetUsedStainList())
end

function WardrobeStainPanelView:UpdateBtnUnlockState(AppearanceID, ColorID, SectionID)
	if self.StainType == WardrobeDefine.StainType.TryStain then
		self.VM.BtnUnlockVisible = false
		self.VM.ItemLackVisible = false
		self.VM.HorizontalConsumeVisible = false
		return
	end

	if self.StainType == WardrobeDefine.StainType.OnlyLook then
		self.VM.BtnUnlockVisible = true
	end

	if self.StainType == WardrobeDefine.StainType.Normal and ColorID ~= 0 then
		self.VM.BtnUnlockVisible = true
	end

	local ColorCfg = DyeColorCfg:FindCfgByKey(ColorID)
	if ColorCfg == nil then
		self.BtnUnlock:SetIsNormalState(true)
		return
	end

	local IsLacked = false
	local DyeItemID = ColorCfg.StainAgentRes[1] and ColorCfg.StainAgentRes[1].ID or 0
	local DyeItemNum = ColorCfg.StainAgentRes[1] and ColorCfg.StainAgentRes[1].Num or 0
	if DyeItemID ~= 0 then
		IsLacked = _G.BagMgr:GetItemNum(DyeItemID) < DyeItemNum
	end

	local IsUnlock = WardrobeMgr:IsActiveColor(AppearanceID, ColorID)
	local IsCurrentDye = WardrobeMgr:GetIsClothing(AppearanceID) and WardrobeMgr:GetCurAppearanceDyeColor(AppearanceID, SectionID) == ColorID or WardrobeMgr:GetDyeColor(AppearanceID, SectionID) == ColorID

	if IsUnlock then
		if IsCurrentDye then
			self.BtnUnlock:SetIsNormalState(true)
		else
			self.BtnUnlock:SetIsRecommendState(true)
		end
	else
		if IsLacked then
			self.BtnUnlock:SetIsDisabledState(true, true)
		else
			self.BtnUnlock:SetIsRecommendState(true)
		end
	end
end

function WardrobeStainPanelView:OnAppearanceTabListChanged(Index, ItemData, ItemView)
	self.CurAppearanceID = ItemData.ID
	self.VM:UpdateSubTitle(self.CurAppearanceID)
	self.VM:UpdateCurAppearanceInfo(self.CurAppearanceID)
	self.CurPartID = self.VM:GetPart(self.CurAppearanceID)

	-- 设置镜头全身就是全身，当前部位就是当前部位
	if self.MainVM and self.MainVM.BtnCameraChecked ~= nil then
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
			if self.CurPartID ~= part then
				self.Common_Render2D_UIBP:PreViewEquipment(nil, part, 0)
			end
		end
	end

	-- 更新当前染色ID
	self.VM:InitColorAeraList(self.CurAppearanceID)
	self.ColorAreaListAdapter:SetSelectedIndex(1)
	
end

function WardrobeStainPanelView:OnColorTabListChanged(Index, ItemData, ItemView)
	local ColorTypeID = ItemData.ID
	self.ColorTypeID = ColorTypeID
	self.LastColorIndex = nil
	self.VM:UpdateColorList(self.StainType, ColorTypeID, self.CurAppearanceID, self.CurStainAreaID)

	local CurColor = 0

	local AppID = self.CurAppearanceID
	local StainViewSuit = WardrobeMgr:GetStainViewSuitByAppID(AppID)

	if self.CurStainAreaID == -1 then
		local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(self.CurAppearanceID)
		CurColor = IsAppRegionDye and  WardrobeUtil.GetUnifyRegionDyeColor(AppID, StainViewSuit.RegionDye) or StainViewSuit.Color
	else
		CurColor = StainViewSuit.RegionDye[self.CurStainAreaID] ~= nil and StainViewSuit.RegionDye[self.CurStainAreaID].ColorID or 0
	end

	if self.OftenSelectColor ~= nil then
		CurColor = self.OftenSelectColor
		self.OftenSelectColor = nil
	end

	local SelectIndex = 0
	if CurColor ~= 0 then
		for i = 1, self.ColorListAdapter:GetNum() do
			local TempAppearanceItem = self.ColorListAdapter:GetItemDataByIndex(i)
			if TempAppearanceItem and TempAppearanceItem.ID == CurColor then
				SelectIndex = i
				break
			end
		end

		if SelectIndex ~= 0 then
			self.VM.ColorListSelectedIndex = 0
			self.VM.ColorListSelectedIndex = SelectIndex
			self.ColorListAdapter:SetSelectedIndex(SelectIndex)
			return
		end
	end

	-- 如果没有选中，按钮跟消耗都不显示
	self.VM.ColorListSelectedIndex = 0
	self.ColorListAdapter:CancelSelected()
	self.VM:UpdateCurColorInfo(CurColor ~= nil and CurColor or nil)
	self.VM.BtnUnlockVisible = false
	self.VM.ItemLackVisible = false
	self.VM.HorizontalConsumeVisible = false

end

function WardrobeStainPanelView:OnColorListChanged(Index, ItemData, ItemView)
	local ColorID = ItemData.ID

	if ColorID == 0 or ColorID == nil then
		if self.LastColorIndex ~= nil then
			self.ColorListAdapter:SetSelectedIndex(self.LastColorIndex)
		end
		return
	end

	self.CurColorID = ColorID
	self.LastColorIndex = Index

	self.VM:UpdateCurColorInfo(ColorID)
	if ColorID == 0 or ColorID == nil then
		self.VM.BtnUnlockVisible = false
		self.VM.ItemLackVisible = false
		self.VM.HorizontalConsumeVisible = false
	end

	local ColorCfg = DyeColorCfg:FindCfgByKey(ColorID)
	if ColorCfg == nil then
		return
	end
	if self.CurAppearanceID == 0 then
		return
	end

	-- 更新预览模型的颜色
	local AppID = self.CurAppearanceID
	local ResID =  WardrobeMgr:IsRandomAppID(AppID) and WardrobeMgr:GetEquipIDByRandomApp(AppID) or WardrobeUtil.GetEquipIDByAppearanceID(AppID)
	local Cfg = EquipmentCfg:FindCfgByKey(ResID)
	local TempStainAera = {}
	local StainViewSuitList = WardrobeMgr:GetStainViewSuit()
	local StainViewSuit = StainViewSuitList[Cfg.Part]
	local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(AppID)

	if self.CurStainAreaID == -1 then
		self.Common_Render2D_UIBP:PreViewEquipment(ResID, Cfg.Part, IsAppRegionDye and 0 or ColorID)
		local CCfg = ClosetCfg:FindCfgByKey(AppID)
		if CCfg ~= nil and CCfg.StainAera ~= nil then
			for index, v in ipairs(CCfg.StainAera) do
				if v.Ban ~= 1 then
					table.insert(TempStainAera, {ID = index, ColorID = ColorID})
				end
			end
			self:StainPartForSection(AppID, Cfg.Part, TempStainAera)
		end
	else
		local CCfg = ClosetCfg:FindCfgByKey(AppID)
		if CCfg ~= nil and CCfg.StainAera ~= nil then
			for index, v in ipairs(CCfg.StainAera) do
				if v.Ban ~= 1 then
					local ColorID = 0 
					if StainViewSuit.RegionDye ~= nil and StainViewSuit.RegionDye[index] ~= nil and StainViewSuit.RegionDye[index].Color ~= nil then
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
		for _, v in ipairs(StainViewSuit.RegionDye or {}) do
			table.insert(TempRegionDye, {ID = v.ID, ColorID = ColorID})
		end
		WardrobeMgr:SetStainViewSuit(Cfg.Part, AppID, ColorID, TempRegionDye)
	else
		for index, v in ipairs(StainViewSuit.RegionDye or {}) do
			table.insert(TempRegionDye, {ID = v.ID, ColorID = index ~= self.CurStainAreaID and v.ColorID or ColorID})
		end
		WardrobeMgr:SetStainViewSuit(Cfg.Part, AppID, ColorID, TempRegionDye)
	end

	WardrobeMgr:PushUsedStainList(self.CurColorID)
	WardrobeMgr:SengClosetUsedStainSave(self.CurAppearanceID, {self.CurColorID})
	self.VM:UpdateColorAeraList(AppID, Cfg.Part, self.CurStainAreaID)
	self.VM:UpdateBtnUnlockState(self.StainType, self.CurAppearanceID, ColorID, self.CurStainAreaID)
	self:UpdateBtnUnlockState(self.CurAppearanceID, ColorID, self.CurStainAreaID)
	self:UpdateConsumeItem(self.CurAppearanceID, ColorID)

end

function WardrobeStainPanelView:OnColorAreaListChanged(Index, ItemData, ItemView)
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
	local StainViewSuit = WardrobeMgr:GetStainViewSuitByAppID(AppID)
	if self.CurStainAreaID == -1 then
		local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(self.CurAppearanceID)
		CurColor = IsAppRegionDye and WardrobeUtil.GetUnifyRegionDyeColor(AppID, StainViewSuit.RegionDye) or StainViewSuit.Color
	else
		CurColor = StainViewSuit.RegionDye[self.CurStainAreaID] and  StainViewSuit.RegionDye[self.CurStainAreaID].ColorID or 0
	end

	if CurColor == 0 then
		self.ColorTabListAdapter:CancelSelected()
		self.ColorTabListAdapter:SetSelectedIndex(1)
	else
		local ColorCfg = DyeColorCfg:FindCfgByKey(CurColor)
		self.ColorTabListAdapter:CancelSelected()
		self.ColorTabListAdapter:SetSelectedIndex(self:ConvertIndex(ColorCfg.Type))
	end

end

function WardrobeStainPanelView:ConvertIndex(Type)
	local TypeList = WardrobeDefine.ColorTypeList
	for _, v in ipairs(TypeList) do
		if v == Type then
			return _
		end
	end
	return   1
end

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
		self.ColorTabListAdapter:SetSelectedIndex(self:ConvertIndex(ColorCfg.Type))
	end
end

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
				Items[index].Num = string.format("%s/%d", ColorNum, v.Num)
				local IconID = ItemUtil.GetItemIcon(v.ID)
				if IconID ~= 0 then
					Items[index].BagSlotVM.ResID = v.ID
					Items[index].BagSlotVM.Icon = UIUtil.GetIconPath(IconID)
					Items[index].BagSlotVM.PanelBagVisible = true
					Items[index].ItemNum = v.Num
				end
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
		self.WardrobeOperateItem.BtnHatStyle:SetChecked(self.MainVM.BtnHatStyleChecked, false)
	end
end

function WardrobeStainPanelView:OnClickedBtnPose(ToggleButton, State)
	local bChanged = self.SuperView.OnClickedBtnPose(self.SuperView, ToggleButton, State)
	if not bChanged then
		self.WardrobeOperateItem.BtnPose:SetChecked(self.MainVM.BtnPoseChecked, false)
	end
end

function WardrobeStainPanelView:OnClickedBtnCamera(ToggleButton, State)
	local IsShow = State == _G.UE.EToggleButtonState.Checked
	self.MainVM.BtnCameraChecked = IsShow
	if IsShow then
		self:ShowModelFocusPart(self.CurPartID)
		_G.FLOG_INFO(string.format("WardrobeStainPanelView 切换镜头到 %s", ProtoEnumAlias.GetAlias(ProtoCommon.equip_part, self.CurPartID)))
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
			if PartID ~= part then
				self.Common_Render2D_UIBP:PreViewEquipment(nil, part, 0)
			end
		end
	else
		self:UpdateModelEquipment()
	end
end

function WardrobeStainPanelView:OnClickedBtnGO()
	self.VM:UpdateColorOfenList(not self.OftenListOpen)
	self.VM.ShowOftenAll = not self.VM.ShowOftenAll
	self.OftenListOpen = not self.OftenListOpen
	self.VM.MoreOftenCheck = self.OftenListOpen
end

-- 点击解锁
function WardrobeStainPanelView:OnClickedBtnUnlock()

	if not CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_CLOSET_DYE, true) then
		return
	end

	-- 如果是当前的染色 
	local CurColorID = WardrobeMgr:GetIsClothing(self.CurAppearanceID) and WardrobeMgr:GetCurAppearanceDyeColor(self.CurAppearanceID, self.CurStainAreaID)  or WardrobeMgr:GetDyeColor(self.CurAppearanceID, self.CurStainAreaID)
	local IsActive = WardrobeMgr:IsActiveColor(self.CurAppearanceID, self.CurColorID)

	if self.CurColorID == 0 then
		return
	end

	if CurColorID == self.CurColorID then
		if self.CurStainAreaID == -1 then
			WardrobeMgr:SendClosetDyeRecoveryReq(self.CurAppearanceID)
		else
			WardrobeMgr:SendClosetRegionDyeReq(self.CurAppearanceID, self.CurStainAreaID, 0)
		end
		return
	end

	if self.CurColorID ~= 0 then
		local ColorCfg = DyeColorCfg:FindCfgByKey(self.CurColorID)
		local IsEnough = false
	
		for index, v in ipairs(ColorCfg.StainAgentRes) do
			if v.ID ~= 0 then
				IsEnough = BagMgr:GetItemNum(v.ID) >= v.Num
				if not IsEnough then
					break
				end
			end
		end
		
		if IsActive then
			if self.CurStainAreaID == -1 then
				WardrobeMgr:SendClosetDyeReq(self.CurAppearanceID, self.CurColorID)
			else
				WardrobeMgr:SendClosetRegionDyeReq(self.CurAppearanceID, self.CurStainAreaID, self.CurColorID)
			end
		else
			if not IsEnough then
				for index, v in ipairs(ColorCfg.StainAgentRes) do
					if v.ID ~= 0 then
						if BagMgr:GetItemNum(v.ID) < v.Num then
						MsgTipsUtil.ShowErrorTips(string.format(_G.LSTR(1080048), ItemUtil.GetItemName(v.ID))) --"%s不足"
						return
						end
					end
				end
			end
			WardrobeMgr:SendClosetActiveStainReq(self.CurAppearanceID, self.CurColorID)
		end
	end
end

-- 更新当前外观
function WardrobeStainPanelView:UpdateModelEquipment()
	local ItemList = {}
	local EquipList = EquipmentVM.ItemList

	local CurViewSuit = WardrobeMgr:GetStainViewSuit()
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
					if self.MainVM.BtnHandChecked then
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

function WardrobeStainPanelView:ShowAllModel(bBackAll)
	self:SetModelSpringArmToDefault(false)
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
	local CameraFocusCfg = self.CameraFocusCfgMap:GetCfgByRaceAndProf(AttachType,  MajorUtil.GetMajorProfID(), Part)
	if CameraFocusCfg == nil then return end
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

function WardrobeStainPanelView:SetModelSpringArmToDefault(bInterp)
	-- 设置一下相机参数
	if self.ShowModelType == WardrobeDefine.ShowModelType.All then
		return
	end

	if self.IsTransition  then
		self.IsTransition  = false
		return
	end

	local DefaultSpringArmLength = nil
	if nil ~= self.Common_Render2D_UIBP.CamControlParams then
		DefaultSpringArmLength = self.Common_Render2D_UIBP.CamControlParams.DefaultViewDistance
	end
	self.Common_Render2D_UIBP:SetSpringArmCenterOffsetY(-50 + WardrobeDefine.StainPanelOffsetY, DefaultSpringArmLength)
	self.Common_Render2D_UIBP:EnableRotator(true)
	self.Common_Render2D_UIBP:SetCameraFocusScreenLocation(nil, nil, nil, nil)
	self.Common_Render2D_UIBP:SetModelRotation(0, 0 , 0, true)
	self.Common_Render2D_UIBP:ResetViewDistance(bInterp)
	self.Common_Render2D_UIBP:SetPostProcessVignetteIntensity(self.VignetteIntensityDefaultValue)
	self.Common_Render2D_UIBP:EnableZoom(true)

	local AttachType = MajorUtil.GetMajorAvatarComponent():GetAttachTypeIgnoreChangeRole()
	--local CameraParams = WardrobeMgr:GetCameraControlParams(AttachType, 1)
	local CameraParams = self.CameraFocusCfgMap:GetCfgByRaceAndProf(AttachType, MajorUtil.GetMajorProfID() , 0)

	if CameraParams ~= nil then
		-- _G.FLOG_INFO(string.format("WardrobeStainPanelView:SetModelSpringArmToDefault Fov %s ", tostring(CameraParams.FOV)))
		self.Common_Render2D_UIBP:ResetViewDistance(bInterp)
	end

	self.ShowModelType = WardrobeDefine.ShowModelType.All
end


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



return WardrobeStainPanelView