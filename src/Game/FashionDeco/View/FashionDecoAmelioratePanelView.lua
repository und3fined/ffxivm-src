---
--- Author: rock
--- DateTime: 2025-09-02 16:26
--- Description: 配饰改良主界面（目前仅支持翅膀）
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local FashionDecoAmelioratePanelVM = require("Game/FashionDeco/VM/FashionDecoAmelioratePanelVM")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local HelpInfoUtil = require("Utils/HelpInfoUtil")
local UIViewID = require("Define/UIViewID")
local FashionDecorateCfg = require("TableCfg/FashionDecorateCfg")
local FashionDecoAmeliorateCfg = require("TableCfg/FashionDecoAmeliorateCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local CameraControlDefine = require("Game/Common/Render2D/CameraControlDefine")
local EquipmentCameraControlDataLoader = require("Game/Equipment/EquipmentCameraControlDataLoader")
local CameraFocusCfgMap = require("Game/Equipment/VM/CameraFocusCfgMap")
local MajorUtil = require("Utils/MajorUtil")
local SystemLightCfg = require("TableCfg/SystemLightCfg")
local CameraUtil = require("Game/Common/Camera/CameraUtil")
local ModelDefine = require("Game/Model/Define/ModelDefine")
local FashionDecoDefine = require("Game/FashionDeco/VM/FashionDecoDefine")
local ActorUtil = require("Utils/ActorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local EventID = require("Define/EventID")
local CommonUtil = require("Utils/CommonUtil")
local ProfIdleCfg = require("TableCfg/CharasysProfIdleCfg")
local ProfUtil = require("Game/Profession/ProfUtil")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local CommStatAnimCfg = require("TableCfg/CommStatAnimCfg")
local AnimationUtil = require("Utils/AnimationUtil")
local ObjectGCType = require("Define/ObjectGCType")
local ProtoRes = require("Protocol/ProtoRes")
local SideBarDefine = require("Game/Common/Frame/Define/CommonSelectSideBarDefine")
local CommSideBarUtil = require("Utils/CommSideBarUtil")
local TipsUtil = require("Utils/TipsUtil")
local ItemGetaccesstypeCfg = require("TableCfg/ItemGetaccesstypeCfg")
local ItemUtil = require("Utils/ItemUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")


local BackGroundActorPath = "Class'/Game/UI/Render2D/Equipment/BP_FashionDecoAmeliorateBackground.BP_FashionDecoAmeliorateBackground_C'"
local EquipmentMgr = _G.EquipmentMgr
local ItemMainType = ProtoCommon.ItemMainType
local EquipmentType = ProtoRes.EquipmentType
local SystemLightID = 32
local ActorFadeInTime = 0.7

-- 待机动作类型
local IdlePoseType =
{
	Default = 1, -- 默认姿势
	Show = 2, -- 展示用姿势
	Combat = 3, -- 战斗姿势
}

local AssembleAllEndCallbackType =
{
	View = 1, -- 相机相关
	StagePose = 2, -- 亮相动作
	IdlePose = 3, -- 待机动作
}

---@class FashionDecoAmelioratePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field BtnGo UFButton
---@field BtnHand UToggleButton
---@field BtnHat UToggleButton
---@field BtnPose UToggleButton
---@field BtnShowTips UFButton
---@field BtnSwitch UFButton
---@field CommBtn CommBtnLView
---@field CommonTitle CommonTitleView
---@field Common_Render2D_UIBP CommonRender2DView
---@field CostItemImage UFImage
---@field FHorizontalBox_43 UFHorizontalBox
---@field PanelCommBtn UFCanvasPanel
---@field PanelRoleBtn UFVerticalBox
---@field RichTextCost URichTextBox
---@field TableViewDeco UTableView
---@field TableViewSkill UTableView
---@field TableViewTab UTableView
---@field TextCost UFTextBlock
---@field TextDecoName UFTextBlock
---@field TextGo UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimTableViewTabSelectionChanged UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionDecoAmelioratePanelView = LuaClass(UIView, true)

function FashionDecoAmelioratePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.BtnGo = nil
	--self.BtnHand = nil
	--self.BtnHat = nil
	--self.BtnPose = nil
	--self.BtnShowTips = nil
	--self.BtnSwitch = nil
	--self.CommBtn = nil
	--self.CommonTitle = nil
	--self.Common_Render2D_UIBP = nil
	--self.CostItemImage = nil
	--self.FHorizontalBox_43 = nil
	--self.PanelCommBtn = nil
	--self.PanelRoleBtn = nil
	--self.RichTextCost = nil
	--self.TableViewDeco = nil
	--self.TableViewSkill = nil
	--self.TableViewTab = nil
	--self.TextCost = nil
	--self.TextDecoName = nil
	--self.TextGo = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimTableViewTabSelectionChanged = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionDecoAmelioratePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.CommBtn)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.Common_Render2D_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionDecoAmelioratePanelView:OnInit()
	self.CameraFocusCfgMap = CameraFocusCfgMap.New()
	self.AssembleAllEndCallbacks = {} -- 模型加载完后的回调
	self.IdlePoseNum = 0

	self.ViewModel = FashionDecoAmelioratePanelVM.New()
	--左边系列的列表
	self.AdapterTableSeries = UIAdapterTableView.CreateAdapter(self, self.TableViewTab, self.OnSelectChangedSeriesItem,true)
	--右边本系列中所有改良的列表
	self.AdapterTableViewAmeliorate = UIAdapterTableView.CreateAdapter(self, self.TableViewDeco, self.OnSelectChangedAmeliorateItem,true)
	--技能列表
	self.ActionTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewSkill, self.OnSelectChangedActionItem,true)
end

function FashionDecoAmelioratePanelView:InitStaticText()
	self.CommonTitle.CommInforBtn:SetHelpInfoID(11233)
	self.CommonTitle:SetTextTitleName(LSTR(1030032))
	self.TextCost:SetText(_G.LSTR(1030033))
	self.TextGo:SetText(_G.LSTR(1030034))
end

function FashionDecoAmelioratePanelView:OnDestroy()

end

function FashionDecoAmelioratePanelView:OnShow()
	self.IsFirstShowView = true

	self:InitStaticText()

	--根据是否有在【时尚配饰】界面选中的翅膀，若没有为nil是默认选中第1系列的第1个
	local SelectWingId = nil
	if self.Params and self.Params.SelectWingId then
		SelectWingId = self.Params.SelectWingId
	end
	self.ViewModel:InitDefualtData(SelectWingId)
	self:UpdateButtonState()

	--天气
	_G.LightMgr:EnableUIWeather(32)

	--禁止移动控制(虚拟摇杆)
	CommonUtil.DisableShowJoyStick(true)
	CommonUtil.HideJoyStick()

	--隐藏HUD
	_G.HUDMgr:SetIsDrawHUD(false)

	--不需要通用的背景场景actor, 配饰改良单独创建一个
	self.Common_Render2D_UIBP.bCreateNewBackground = false
    local function CallBack()
        local UClass = _G.ObjectMgr:GetClass(BackGroundActorPath)
        if not UClass then
            return
        end
		local Location = _G.UE.FVector(0, 0, 100000)
		self.Common_Render2D_UIBP.BackgroundActor = CommonUtil.SpawnActor(UClass, Location)
    end
    _G.ObjectMgr:LoadClassAsync(BackGroundActorPath, CallBack, ObjectGCType.LRU)

	--假阴影
	self.Common_Render2D_UIBP.bCreateShandowActor = true
	self.Common_Render2D_UIBP:SetShadowActorType(ActorUtil.ShadowType.Role)
	self.Common_Render2D_UIBP:SetShadowActorPos(_G.UE.FVector(0, 0, 100000.0))

	-- 加载相机参数
	local AvatarComp = MajorUtil.GetMajorAvatarComponent()
	if nil ~= AvatarComp then
		self.ViewModel.AttachType = AvatarComp:GetAttachTypeIgnoreChangeRole()
	end
	self.Common_Render2D_UIBP.bAutoInitSpringArm = false
	local CameraParams = EquipmentCameraControlDataLoader:GetCameraControlParams(self.ViewModel.AttachType, CameraControlDefine.FocusType.WholeBody)
	self.Common_Render2D_UIBP:SetCameraControlParams(CameraParams)

	--显示角色模型
	self:ShowPlayerActor()
end

--执行面板关闭
function FashionDecoAmelioratePanelView:ExecuteOnHide()
	self.Common_Render2D_UIBP.bCreateNewBackground = true --仅仅是让CommonRender2DView:DestroyBackground()能正常销毁
	self:Hide()
end

function FashionDecoAmelioratePanelView:OnHide()
	self.CameraFocusCfgMap:SetAssetUserData(nil)
	self.ViewModel:ClearData()

	self.Common_Render2D_UIBP:SwitchOtherLights(true)
	_G.LightMgr:DisableUIWeather()
	_G.HUDMgr:SetIsDrawHUD(true)

	--解除移动控制(虚拟摇杆)
	CommonUtil.DisableShowJoyStick(false)
	CommonUtil.ShowJoyStick()

	self.HoldLoopAnimProf = nil
	self.IdlePoseNum = 0
end

function FashionDecoAmelioratePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBack.Button, self.OnBackClick)
	UIUtil.AddOnClickedEvent(self, self.CommBtn.Button, self.OnCommBtnClick)
	UIUtil.AddOnClickedEvent(self, self.BtnGo, self.OnBtnGoClick)
	UIUtil.AddOnClickedEvent(self, self.BtnShowTips, self.OnCostItemClick)

	UIUtil.AddOnStateChangedEvent(self, self.BtnHand, self.OnChangedBtnHand)
	UIUtil.AddOnStateChangedEvent(self, self.BtnPose, self.OnChangedBtnPose)
	UIUtil.AddOnStateChangedEvent(self, self.BtnHat, self.OnChangedToggleBtnHat)
	UIUtil.AddOnClickedEvent(self, self.BtnSwitch, self.OnClickBtnSwitchPosture)
end

function FashionDecoAmelioratePanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
	self:RegisterGameEvent(EventID.DecorateImproveSuccess, self.OnDecorateImproveSuccess)
end

function FashionDecoAmelioratePanelView:OnRegisterBinder()
	local Binders = {
		{ "SeriesBindableList", UIBinderUpdateBindableList.New(self, self.AdapterTableSeries) },
		{ "AmeliorateWingBindableList", UIBinderUpdateBindableList.New(self, self.AdapterTableViewAmeliorate) },
		{ "ListActionItemListVM", UIBinderUpdateBindableList.New(self, self.ActionTableView) },--当前选中类型的所有技能Item自己的主面板VM

		{ "SeriesName", UIBinderSetText.New(self, self.TextDecoName) },

		{ "bIsShowWeapon", 			UIBinderSetIsChecked.New(self, self.BtnHand) },
		{ "bIsHoldWeapon", 				UIBinderSetIsChecked.New(self, self.BtnPose) },
		{ "bIsShowHat", 				UIBinderSetIsChecked.New(self, self.BtnHat) },
		-- { "bIsShowHatOrgan", 			UIBinderSetIsChecked.New(self, self.BtnOrgan) },

		{ "bIsShowHat",                 UIBinderValueChangedCallback.New(self, nil, self.OnIsShowHatChanged) },
		{ "bIsShowHatOrgan",            UIBinderValueChangedCallback.New(self, nil, self.OnIsShowHatOrganChanged) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function FashionDecoAmelioratePanelView:ShowPlayerActor()
	local CallBack = function(bSucc)
        if (bSucc) then
			self.VignetteIntensityDefaultValue = self.Common_Render2D_UIBP:GetPostProcessVignetteIntensity()
			self.Common_Render2D_UIBP:SwitchOtherLights(false)
            self.Common_Render2D_UIBP:ChangeUIState(false)
            self.Common_Render2D_UIBP:SetShowHead(self.ViewModel.bIsShowHead)
            self.Common_Render2D_UIBP:SetUICharacterByEntityID(MajorUtil.GetMajorEntityID())
			self.CameraFocusCfgMap:SetAssetUserData(self.Common_Render2D_UIBP:GetEquipmentConfigAssetUserData())
			self.Common_Render2D_UIBP:DisableEnvironmentLights()
			self.Common_Render2D_UIBP:SwitchCharacterIK(false)
        end
    end
	local ReCreateCallBack = function()
        self.CameraFocusCfgMap:SetAssetUserData(self.Common_Render2D_UIBP:GetEquipmentConfigAssetUserData())
    end
	
	--默认灯光预设
	local LightPath = "LightPreset'/Game/UI/Render2D/LightPresets/Login/TODUI_Equipment/Equipment_c0101.Equipment_c0101'" --保证有灯光
	local AttributeComp = ActorUtil.GetActorAttributeComponent(MajorUtil.GetMajorEntityID())
	if nil ~= AttributeComp then
		local RaceLightPreset = self:GetLightPresetPath(AttributeComp.RaceID, SystemLightID)
		if RaceLightPreset ~= "" then
			LightPath = RaceLightPreset
		end
	end

	--根据种族取对应的RenderActor
	local RenderActorPathForRace = string.format(ModelDefine.StagePath.Universe, self.ViewModel.AttachType, self.ViewModel.AttachType)
    self.Common_Render2D_UIBP:CreateRenderActor(RenderActorPathForRace, EquipmentMgr:GetEquipmentCharacterClass(), 
	LightPath, false, CallBack, ReCreateCallBack, nil, {bSyncLoad = true})
end

function FashionDecoAmelioratePanelView:GetLightPresetPath(Race, SystemLightID)
	if nil == Race then
		return ""
	end
	local SystemLightCfgData = SystemLightCfg:FindCfgByKey(SystemLightID)
    if nil == SystemLightCfgData then
		return ""
	end

	local PathList = SystemLightCfgData.LightPresetPaths
	if nil == PathList or nil == next(PathList) then
		return ""
	end

	local PathIndex = 1
	if Race == ProtoCommon.race_type.RACE_TYPE_Roegadyn then
		PathIndex = 2
	elseif Race == ProtoCommon.race_type.RACE_TYPE_Lalafell then
		PathIndex = 3
	end

	return PathList[PathIndex]
end

function FashionDecoAmelioratePanelView:OnBackClick()
	self:ExecuteOnHide()
end

function FashionDecoAmelioratePanelView:OnBtnHelpClicked()
	HelpInfoUtil.ShowHelpInfoByID(11233)
end

function FashionDecoAmelioratePanelView:OnCommBtnClick()
	if self.ViewModel.SelectAmeliorateWingData.IsEquip then
		--已穿戴，返回到时尚配饰界面
		self:ExecuteOnHide()
		_G.EventMgr:SendEvent(_G.EventID.FashionDecorateWingSelectChange, { SelectAmeliorateWingId = self.ViewModel.SelectAmeliorateWingId })
		-- CommSideBarUtil.ShowEasyToUseSideBarByType(SideBarDefine.EasyToUseTabType.FashionDeco, {bOpen = true})
	elseif self.ViewModel.SelectAmeliorateWingData.IsUnlock then
		--未穿戴和已改良，返回到时尚配饰界面
		self:ExecuteOnHide()
		_G.EventMgr:SendEvent(_G.EventID.FashionDecorateWingSelectChange, { SelectAmeliorateWingId = self.ViewModel.SelectAmeliorateWingId })
	elseif self.ViewModel.SelectAmeliorateWingData.IsOwnedFirst and not self.ViewModel.SelectAmeliorateWingData.IsOwnedLast then
		--拥有第一个母体，但不拥有上一级
		local TempFashionDecorateCfg = FashionDecorateCfg:FindCfgByKey(self.ViewModel.SelectAmeliorateWingData.UpgradeLastId) --时尚配饰表
		if TempFashionDecorateCfg then
			_G.MsgTipsUtil.ShowTips(string.format(_G.LSTR(1030022), TempFashionDecorateCfg.Name)) --请先获得<span color="#ffbf35ff">%s</>
		end
	elseif self.ViewModel.SelectAmeliorateWingData.IsOwnedFirst and self.ViewModel.SelectAmeliorateWingData.IsOwnedLast and not self.ViewModel.SelectAmeliorateWingData.IsBagEnoughCost then
		--拥有第一个母体,也拥有上一级，但是当前材料不够
		local Cfg = FashionDecoAmeliorateCfg:FindCfgByKey(self.ViewModel.SelectAmeliorateWingId)
		if Cfg then
			local ItemCfg = ItemCfg:FindCfgByKey(Cfg.CostID)
			if ItemCfg then
				_G.MsgTipsUtil.ShowTips(string.format(_G.LSTR(1030023), ItemCfg.ItemName)) --"%s不足，无法改良"
			end
		end
	else
		local AmeliorateWingData = self.ViewModel:GetAmeliorateWingData(self.ViewModel.SelectAmeliorateWingId)
		local LastUpgradeWingId = self.ViewModel.SelectAmeliorateWingId
		if AmeliorateWingData then
			LastUpgradeWingId = AmeliorateWingData.UpgradeLastId
		end

		local Params = {
			SelectWingId = self.ViewModel.SelectAmeliorateWingId,
			LastUpgradeWingId = LastUpgradeWingId
		}
		_G.UIViewMgr:ShowView(UIViewID.FashionDecoAmeliorateWinPanel, Params)
	end
end

--获取途径
function FashionDecoAmelioratePanelView:OnBtnGoClick()
	local AmeliorateCfg = FashionDecoAmeliorateCfg:FindCfgByKey(self.ViewModel.SelectAmeliorateWingId)
	if AmeliorateCfg == nil then
		return
	end
	local GetWayList = _G.StringTools.StringSplit(AmeliorateCfg.GetWayListId, ",")
	--写死获取途径
	-- local AccessList = {144, 145, 268}
	local MajorLevel = MajorUtil.GetMajorLevel()
	local UnLockIndex = 1
	local CommGetWayItems = {}
	for _, value in ipairs(GetWayList) do
		local Cfg = ItemGetaccesstypeCfg:FindCfgByKey(value)
		if Cfg ~= nil then
			local ViewParams = {ID = Cfg.ID, FunDesc = Cfg.FunDesc, ItemID = 0, MajorLevel = MajorLevel, 
			FunIcon = Cfg.FunIcon, ItemAccessFunType = Cfg.FunType, UnLockLevel = Cfg.UnLockLevel, 
			IsRedirect = Cfg.IsRedirect, FunValue = Cfg.FunValue, RepeatJumpTipsID = Cfg.RepeatJumpTipsID, UnLockTipsID = Cfg.UnLockTipsID}
			if (ViewParams.UnLockLevel == nil or ViewParams.MajorLevel == nil or ViewParams.UnLockLevel <= ViewParams.MajorLevel) 
			and ItemUtil.QueryIsUnLock(ViewParams.ItemAccessFunType, ViewParams.FunValue, ViewParams.ItemID) then --等级限制
				ViewParams.IsUnLock = true
			else
				ViewParams.IsUnLock = false
			end
			if ViewParams.IsUnLock and Cfg.SpoilerCondition and Cfg.SpoilerCondition ~= 0 then
				ViewParams.CanRevealPlot = ItemUtil.QueryIsCanRevealPlot(ViewParams.ItemAccessFunType, Cfg.SpoilerCondition)
				ViewParams.SpoilerTipsDesc = Cfg.SpoilerTipsDesc
			else
				ViewParams.CanRevealPlot = true
			end
			if ViewParams.IsUnLock then
				table.insert(CommGetWayItems, UnLockIndex, ViewParams)
				UnLockIndex = UnLockIndex + 1
			else
				table.insert(CommGetWayItems,ViewParams)
			end
		end
	end

	local Params = {}
	Params.Data = CommGetWayItems
	local BtnSize = UIUtil.CanvasSlotGetSize(self.BtnGo)
	local View = TipsUtil.ShowGetWayTips(self.ViewModel, nil, self.BtnGo, UE.FVector2D(BtnSize.X, -15), UE.FVector2D(1, 1), false)
	View:UpdateView(Params.Data)
end

--点击系列的列表
function FashionDecoAmelioratePanelView:OnSelectChangedSeriesItem(InIndex, ItemData, ItemView)
	self.ViewModel:ChangeSeriesListSelect(InIndex)

	local DefualtSelectWingId = self.ViewModel:GetDefualtSelectWingIdBySeries(ItemData.SeriesType)
	self.ViewModel:UpdateSelectedSeries(ItemData.SeriesType, DefualtSelectWingId)

	self:UpdateButtonState()

	--模型上显示翅膀
	self:OnShowModelWing()
end

--点击要升级改良的翅膀列表
function FashionDecoAmelioratePanelView:OnSelectChangedAmeliorateItem(InIndex, ItemData, ItemView)
	self.ViewModel:ChangeAmeliorateWingListSelect(InIndex, true)
	self.ViewModel:UpdateSelectAmeliorateWingData(ItemData.Id)

	self:UpdateButtonState()

	--模型上显示翅膀
	self:OnShowModelWing()
end

--模型上显示翅膀
function FashionDecoAmelioratePanelView:OnShowModelWing()
	self.Common_Render2D_UIBP:SetOrnamentCompData(FashionDecoDefine.FashionDecoType.Wing, self.ViewModel.SelectAmeliorateWingId)
end

--配饰改良成功后，刷新改良的翅膀列表
function FashionDecoAmelioratePanelView:OnDecorateImproveSuccess(Params)
	self.ViewModel:UpdateSelectedSeries(self.ViewModel.SelectSeriesType, self.ViewModel.SelectAmeliorateWingId)
	self:UpdateButtonState()

	if Params and Params.FashionDecorateId then
		--执行点击选中的翅膀操作，作为保存此翅膀的new类型红点的触发时机
		self.ViewModel:OnSaveSelectAneliorateItemRedDot(Params.FashionDecorateId)
	end
	self.ViewModel:UpdateSeriesListData()
end

function FashionDecoAmelioratePanelView:UpdateButtonState()
	if not self.ViewModel.SelectAmeliorateWingData.IsOwnedFirst then
		UIUtil.SetIsVisible(self.PanelCommBtn, false)
		UIUtil.SetIsVisible(self.BtnGo, true)
	else
		UIUtil.SetIsVisible(self.PanelCommBtn, true)
		UIUtil.SetIsVisible(self.BtnGo, false)

		if self.ViewModel.SelectAmeliorateWingData.IsEquip then
			self.CommBtn:SetBtnName(_G.LSTR(1030026))
			self.CommBtn:SetIsEnabled(true, true)
		else
			if self.ViewModel.SelectAmeliorateWingData.IsUnlock then
				UIUtil.SetIsVisible(self.FHorizontalBox_43, false)
				self.CommBtn:SetBtnName(_G.LSTR(1030027))
				self.CommBtn:SetIsEnabled(true, true)
			else
				--改良
				UIUtil.SetIsVisible(self.FHorizontalBox_43, true)
				self.CommBtn:SetBtnName(_G.LSTR(1030025))

				local Cfg = FashionDecoAmeliorateCfg:FindCfgByKey(self.ViewModel.SelectAmeliorateWingId)
				if Cfg then
					--材料数量
					local BagItemNum = _G.BagMgr:GetItemNum(Cfg.CostID)
					-- BagItemNum = math.clamp(BagItemNum, 0, Cfg.CostNum) --不用限制
					if BagItemNum < Cfg.CostNum then
						self.RichTextCost:SetText(string.format("<span color=\"#dc5868FF\">%s</>/%s", BagItemNum, Cfg.CostNum))	
					else
						self.RichTextCost:SetText(string.format("%s/%s", BagItemNum, Cfg.CostNum))	
					end

					--材料图标
					local CostItemCfg = ItemCfg:FindCfgByKey(Cfg.CostID)
					if nil ~= CostItemCfg then
						UIUtil.ImageSetBrushFromAssetPath(self.CostItemImage, ItemCfg.GetIconPath(CostItemCfg.IconID))
					end

					--材料是否足够、是否拥有上一级
					if BagItemNum < Cfg.CostNum or not self.ViewModel.SelectAmeliorateWingData.IsOwnedLast then
						self.CommBtn:SetIsEnabled(false, true)
					else
						self.CommBtn:SetIsEnabled(true, true)
					end
				end
			end
		end
	end
end

--点击技能按钮
function FashionDecoAmelioratePanelView:OnSelectChangedActionItem(InIndex, ItemData, ItemView)
	self.ViewModel:ClickCurrentAction(ItemData)
	ItemView:PlayAnimation(ItemView.AnimClick)
end

--材料物品的tips
function FashionDecoAmelioratePanelView:OnCostItemClick()
	local Cfg = FashionDecoAmeliorateCfg:FindCfgByKey(self.ViewModel.SelectAmeliorateWingId)
	if Cfg then
		ItemTipsUtil.ShowTipsByResID(Cfg.CostID, self.BtnShowTips)
	end
end

function FashionDecoAmelioratePanelView:OnAssembleAllEnd(Params)
	local ChildActor = self.Common_Render2D_UIBP:GetCharacter()
	if (ChildActor == nil) then return end

	local EntityID = Params.ULongParam1
	local ObjType = Params.IntParam1
	local AttrComp = ChildActor:GetAttributeComponent()
	if EntityID == AttrComp.EntityID and ObjType == AttrComp.ObjType then
		if self.IsFirstShowView then
			local UIComplexCharacter = self.Common_Render2D_UIBP.UIComplexCharacter
			if UIComplexCharacter then
				UIComplexCharacter:GetAvatarComponent():SetForcedLODForAll(1)
				UIComplexCharacter:StartFadeIn(ActorFadeInTime, true)
			end

			self.Common_Render2D_UIBP:UpdateFocusLocation()
			self:SetModelSpringArmToDefault(true)
			self.bReadyToInitCamera = false

			-- 设置不同职业待机动作
			local ProfIdleCfgData = ProfIdleCfg:FindCfgByKey(AttrComp.ProfID)
			if self.EquipDetailPageShow then
				self.Common_Render2D_UIBP:SetCombatRestEnabled(UIComplexCharacter, ProfIdleCfgData and ProfIdleCfgData.Action > 0)
			else
				self.Common_Render2D_UIBP:SetCombatRestEnabled(UIComplexCharacter, false)
			end

			--武器显隐
			self:UpdateWeaponHideState()

			--模型上显示翅膀
			self:OnShowModelWing()

			self.IsFirstShowView = false
		end
		self.Common_Render2D_UIBP:UpdateAllLights()
		
		--防止模型加载完动作不正常情况
		if not table.is_nil_empty(self.AssembleAllEndCallbacks) then
			for _, Callback in pairs(self.AssembleAllEndCallbacks) do
				Callback()
			end
			self.AssembleAllEndCallbacks = {}
		end
	end
end

function FashionDecoAmelioratePanelView:SetModelSpringArmToDefault(bInterp)
	-- self.Common_Render2D_UIBP.bAutoInitSpringArm = true
	local DefaultSpringArmLength = nil
	if nil ~= self.Common_Render2D_UIBP.CamControlParams then
		DefaultSpringArmLength = self.Common_Render2D_UIBP.CamControlParams.DefaultViewDistance
	end
	self.Common_Render2D_UIBP:SetSpringArmCenterOffsetY(-5, DefaultSpringArmLength)
	self.Common_Render2D_UIBP:EnableRotator(true)
	self.Common_Render2D_UIBP:SetCameraFocusScreenLocation(nil, nil, nil, nil)
    
	self.Common_Render2D_UIBP:SetModelRotation(0, 0 , 0, true)

	self.Common_Render2D_UIBP:ResetViewDistance(bInterp)
	self.Common_Render2D_UIBP:SetPostProcessVignetteIntensity(self.VignetteIntensityDefaultValue)
	self:PoseStyleSwitch(0)
end

function FashionDecoAmelioratePanelView:PoseStyleSwitch(ButtonState, Inpart)
	self.ViewModel.bIsHoldWeapon = ButtonState == _G.UE.EToggleButtonState.Checked

	local ProfClass = ProfUtil.GetProfClass(self.ViewModel.ProfID)
	if self.Common_Render2D_UIBP and self.Common_Render2D_UIBP.UIComplexCharacter then
		if ProfClass == ProtoCommon.class_type.CLASS_TYPE_CARPENTER then
			--能工巧匠，有些区别
			self.Common_Render2D_UIBP:HoldOnWeapon(false)
			local Comp = self.Common_Render2D_UIBP.UIComplexCharacter:GetAnimationComponent()
			if self.ViewModel.bIsHoldWeapon then
				self.HoldLoopAnimProf = self:PlayEnterAnimByProf(Comp, Inpart)
			else
				if self.HoldLoopAnimProf and CommonUtil.IsObjectValid(self.HoldLoopAnimProf) then
					self.HoldLoopAnimProf = nil
					self:PlayExitAnimByProf(self.ViewModel.ProfID, Comp, Inpart)
				end
			end
		else
			if self.HoldLoopAnimProf and CommonUtil.IsObjectValid(self.HoldLoopAnimProf)then
				local Comp = self.Common_Render2D_UIBP.UIComplexCharacter:GetAnimationComponent()
				if Comp then
					Comp:StopMontage(self.HoldLoopAnimProf)
					self.HoldLoopAnimProf = nil
				end
			end
			self.Common_Render2D_UIBP:HoldOnWeapon(self.ViewModel.bIsHoldWeapon)
		end
	end
	self:UpdateWeaponHideState()
end

function FashionDecoAmelioratePanelView:PlayEnterAnimByProf(Comp, Inpart)
	local Section = ""
	local RecipeAnimDataTable = CommStatAnimCfg:FindAllCfg("ProfID = "..tostring(self.ViewModel.ProfID))
	if RecipeAnimDataTable == nil then
		_G.FLOG_ERROR("[EquipmentNewMainView]PoseStyleSwitch Cant Find Anim, Prof =" .. self.ViewModel.ProfID)
		return
	end
	local RecipeAnimData = RecipeAnimDataTable[1]
	if Inpart then
		if Inpart == ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND then
			RecipeAnimData = RecipeAnimDataTable[1]
		elseif Inpart == ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND then
			RecipeAnimData = RecipeAnimDataTable[2]
		end
	end
	local EnterAnimStr = AnimationUtil.ConvertToTruePath(RecipeAnimData and RecipeAnimData.EnterAnim or "")
	local EnterAnim = _G.ObjectMgr:LoadObjectSync(EnterAnimStr, ObjectGCType.LRU)
	local LoopAnimStr = AnimationUtil.ConvertToTruePath(RecipeAnimData and RecipeAnimData.LoopAnim or "")
	local LoopAnim = _G.ObjectMgr:LoadObjectSync(LoopAnimStr, ObjectGCType.LRU)
	if not EnterAnim or not LoopAnim then
		FLOG_ERROR("[EquipmentNewMainView] Can not Find Anim[%s] or Anim[%s]", EnterAnimStr, LoopAnimStr)
		return 
	end
	local DynamicMontage = AnimationUtil.CreateLoopDynamicMontage(EnterAnim, LoopAnim, "WholeBody")
	return AnimationUtil.PlayMontage(Comp, DynamicMontage, "WholeBody", nil, nil, Section)
end

-- 手上武器，套件默认隐藏，散件默认显示(拔刀状态时，武器强制显示)
function FashionDecoAmelioratePanelView:OnChangedBtnHand(ToggleGroup, ToggleButton, BtnState)
	self.ViewModel.bIsShowWeapon = ToggleButton == _G.UE.EToggleButtonState.Checked 
	self.Common_Render2D_UIBP:HideWeapon(not self.ViewModel.bIsShowWeapon)
	self:UpdateWeaponHideState()
end

--- 武器拔出/收起状态，套件默认收起，散件默认拔出(拔刀状态时，武器强制显示)
function FashionDecoAmelioratePanelView:OnChangedBtnPose(ToggleGroup, ToggleButton, BtnState)
	self.ViewModel.bIsHoldWeapon = ToggleButton == _G.UE.EToggleButtonState.Checked
	self.Common_Render2D_UIBP:HoldOnWeapon(self.ViewModel.bIsHoldWeapon)
	self:UpdateWeaponHideState()
end

--- 头部装备显隐，默认显示
function FashionDecoAmelioratePanelView:OnChangedToggleBtnHat(ToggleGroup, ToggleButton, BtnState)
	self.ViewModel.bIsShowHat = ToggleButton == _G.UE.EToggleButtonState.Checked
end

function FashionDecoAmelioratePanelView:OnIsShowHatChanged(bIsShowHat)
	self.Common_Render2D_UIBP:HideHead(not bIsShowHat)
	if bIsShowHat then
		self.Common_Render2D_UIBP:SwitchHelmet(self.ViewModel.bIsShowHatOrgan)
	end
end

--- 头部装备机关，默认关
function FashionDecoAmelioratePanelView:OnChangedToggleBtnOrgan(ToggleGroup, ToggleButton, BtnState)
	if not self.ViewModel.bEnableHatOrganBtn then
		_G.MsgTipsUtil.ShowTips(_G.LSTR(1050226))
		return
	end
	self.ViewModel.bIsShowHatOrgan = ToggleButton == _G.UE.EToggleButtonState.Checked
end

function FashionDecoAmelioratePanelView:OnIsShowHatOrganChanged(bIsShowHatOrgan)
	self.Common_Render2D_UIBP:SwitchHelmet(bIsShowHatOrgan)
end

-- 头部装备机关的按钮状态
function FashionDecoAmelioratePanelView:UpdateNeedShowHatOrgan()
	if not self.ViewModel.bEnableHatOrganBtn then
		self.BtnOrgan:SetCheckedState(_G.UE.EToggleButtonState.Locked,false)
	end
end

--- 切换情感动作
function FashionDecoAmelioratePanelView:OnClickBtnSwitchPosture()
	if not self.ViewModel.bIsHoldWeapon then
		self:SwitchIdlePose(IdlePoseType.Show)
	else
		self:SwitchIdlePose(IdlePoseType.Combat)
	end
end

function FashionDecoAmelioratePanelView:UpdateWeaponHideState()
	local bHideMasterHand = self:IsHideMasterHand()
	local bHideSlaveHand = self:IsHideSlaveHand()
	self.Common_Render2D_UIBP:HideMasterHand(bHideMasterHand)
	self.Common_Render2D_UIBP:HideSlaveHand(bHideSlaveHand)
end

-- 判断是否隐藏主手武器，拔刀必定显示武器
-- 生产职业预览副手，隐藏主手
function FashionDecoAmelioratePanelView:IsHideMasterHand()
	local bIsHideWeapon = not (self.ViewModel.bIsShowWeapon or self.ViewModel.bIsHoldWeapon)
	local bIsProductProf = RoleInitCfg:FindProfSpecialization(MajorUtil.GetMajorProfID()) == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION
	local bIsPreviewSlaveHand = self.SelectSlotPart == ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND
	return bIsHideWeapon or (bIsProductProf and bIsPreviewSlaveHand)
end

-- 判断是否隐藏副手武器，拔刀必定显示武器
-- 生产职业非预览副手状态隐藏副手
function FashionDecoAmelioratePanelView:IsHideSlaveHand()
	local bIsHideWeapon = not (self.ViewModel.bIsShowWeapon or self.ViewModel.bIsHoldWeapon)
	local bIsProductProf = RoleInitCfg:FindProfSpecialization(MajorUtil.GetMajorProfID()) == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION
	local bIsPreviewSlaveHand = self.SelectSlotPart == ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND
	return bIsHideWeapon or (bIsProductProf and not bIsPreviewSlaveHand)
end

-- 切换待机动作
function FashionDecoAmelioratePanelView:SwitchIdlePose(PoseType)
	PoseType = PoseType or 1
	local Render2DCharcter = self.Common_Render2D_UIBP:GetCharacter()
	local FailCallback = function()
		self:AddAssembleAllEndCallback(AssembleAllEndCallbackType.IdlePose, 
		function()
			self:SwitchIdlePose(PoseType) 
		end)
	end
	if nil == Render2DCharcter then
		FailCallback()
		return
	end
	local AnimComp = Render2DCharcter:GetAnimationComponent()
	if nil == AnimComp then
		return
	end
	local AnimInst = AnimComp:GetPlayerAnimInstance()
	if nil == AnimInst then
		FailCallback()
		return
	end
	local PlayerAnimParam = AnimInst:GetPlayerAnimParam()
	self.IdlePoseNum = PoseType == IdlePoseType.Default and 0 or (self.IdlePoseNum + 1) % 6
	if PoseType ~= IdlePoseType.Combat then
		AnimComp.IsInEmote = false
		PlayerAnimParam.bIgnoreRestTime = true
		PlayerAnimParam.bCanRest = true
		PlayerAnimParam.NormalIdleType = self.IdlePoseNum
		AnimInst:UpdatePlayerAnimParam(PlayerAnimParam)
	else
		PlayerAnimParam.bIgnoreRestTime = false
		PlayerAnimParam.IdleToRestTime = 0.02
		AnimInst:UpdatePlayerAnimParam(PlayerAnimParam)
		AnimComp.IsInEmote = not AnimComp.IsInEmote
	end
end

function FashionDecoAmelioratePanelView:AddAssembleAllEndCallback(CallbackType, Callback)
	if nil == CallbackType or nil == Callback then
		return
	end
	self.AssembleAllEndCallbacks[CallbackType] = Callback
end

return FashionDecoAmelioratePanelView