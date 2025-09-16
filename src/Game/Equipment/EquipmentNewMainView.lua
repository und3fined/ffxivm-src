local UIView = require("UI/UIView")
local UIViewMgr = require("UI/UIViewMgr")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local EquipmentMgr = _G.EquipmentMgr
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local UIAdapterToggleGroup = require("UI/Adapter/UIAdapterToggleGroup")
local CommonUtil = require("Utils/CommonUtil")
local USaveMgr = _G.UE.USaveMgr
local SaveKey = require("Define/SaveKey")
local EffectUtil = require("Utils/EffectUtil")
local TeamDefine = require("Game/Team/TeamDefine")
local ProfUtil = require("Game/Profession/ProfUtil")
local ProfMgr = require("Game/Profession/ProfMgr")
local PersonInfoMgr = require("Game/PersonInfo/PersonInfoMgr")
local ScoreMgr = require("Game/Score/ScoreMgr")
local TipsUtil = require("Utils/TipsUtil")
local ProfModelCfg = require("TableCfg/ProfModelCfg")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local ProfIdleCfg = require("TableCfg/CharasysProfIdleCfg")
local ClientSetupID = require("Game/ClientSetup/ClientSetupID")
local SettingsTabRole = require("Game/Settings/SettingsTabRole")
local CameraControlDefine = require("Game/Common/Render2D/CameraControlDefine")
local EquipmentCameraControlDataLoader = require("Game/Equipment/EquipmentCameraControlDataLoader")
local ModelDefine = require("Game/Model/Define/ModelDefine")
local LightDefine = require("Game/Light/LightDefine")
local SystemLightCfg = require("TableCfg/SystemLightCfg")

--@ViewModel
local EquipmentMainVM = require("Game/Equipment/VM/EquipmentMainVM")
local EquipmentJobBtnItemVM = require("Game/Equipment/VM/EquipmentJobBtnItemVM")
local EquipmentPageTabVM = require("Game/Equipment/VM/EquipmentPageTabVM")
local EquipmentVM = require("Game/Equipment/VM/EquipmentVM")
local CameraFocusCfgMap = require("Game/Equipment/VM/CameraFocusCfgMap")

--@Binder
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetProfName = require("Binder/UIBinderSetProfName")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisibleByBit = require("Binder/UIBinderSetIsVisibleByBit")
local UIViewID = require("Define/UIViewID")
local ObjectGCType = require("Define/ObjectGCType")

local LSTR = _G.LSTR

local EquipmentNewMainView = LuaClass(UIView, true)

local CommBtnColorType = {
	Normal = 0, -- 普通 灰色
	Recommend = 1, -- 推荐 绿色
	Disable = 2, -- 禁用状态
}

local PageType =
{
	None = 0,
	Attribute = 1,
	Equipment = 2,
	Skill = 3,
	AttributeDetail = 11, -- 二级页面，编号+10
	EquipmentDetail = 12,
	SimpleMain = 21,      --预览，编号+22
	SimpleSkill = 22,
}

local EquipmentLightConfig = {
	["e_c0101"] = 1,
	["e_c0901"] = 2,
	["e_c1101"] = 3,
	["a_c0101"] = 1,
	["a_c0901"] = 2,
	["a_c1101"] = 3
}
local ActorFadeInTime = 0.7

function EquipmentNewMainView:Ctor()
end

function EquipmentNewMainView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackBtn)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommonRedDot)
	self:AddSubView(self.CommonRedDotPersonInfo)
	self:AddSubView(self.Common_Render2D_UIBP)
	self:AddSubView(self.ProfTableViewNew)
	self:AddSubView(self.RoleProfPage)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentNewMainView:OnInit()

	self.PreViewMap = {}
    self.ViewModel = EquipmentMainVM--.New()
	self.CameraFocusCfgMap = CameraFocusCfgMap.New()

	self.AdapterTabTableView = UIAdapterTableView.CreateAdapter(self, self.TabList, self.OnTabTableViewSelectChange, false)
	self.AdapterTabTableView:SetScrollbarIsVisible(false)
	
	self.ChildTable = {}
	self.bVisible = true
	self.bReadyToInitCamera = false
	self.bFirstAvatarAssemble = false
	self.bActive = true

	self.ActivePage = PageType.None
	self.WidgetsInsidePage =
	{
		--属性界面
		[PageType.Attribute] = { {NotNeedAttach = false, AttachPanel = self.MainPanel,
		BpName = "Attribute/AttributeMainPage_UIBP.AttributeMainPage_UIBP", Name = "AttributeMainPage"}},
		--装备界面
		[PageType.Equipment] = { {NotNeedAttach = false, AttachPanel = self.MainPanel,
		BpName = "Equipment/CurrrentEquipPage_UIBP.CurrrentEquipPage_UIBP", Name ="CurrrentEquipList"}},
		--技能界面
		[PageType.Skill] = {{NotNeedAttach = false, AttachPanel = self.MainPanel,
		BpName = "Skill/SkillMainPanel_UIBP.SkillMainPanel_UIBP", Name ="SkillMainPanel"}},
		--属性详情
		[PageType.AttributeDetail] = {{NotNeedAttach = false, AttachPanel = self.MainPanel,
		BpName = "Attribute/AttributeDetailPanel_UIBP.AttributeDetailPanel_UIBP", Name ="AttributeDetail"},},
		--装备详情，这里没有需要展示或者挂载的界面了，保持统一的同时在隐藏显示的时候需要判空
		[PageType.EquipmentDetail] = {},

		[PageType.SimpleMain] = { {NotNeedAttach = false, AttachPanel = self.MainPanel,
		BpName = "Adventure/AdventureJobPanel_UIBP.AdventureJobPanel_UIBP", Name = "SimpleMain"}},

		[PageType.SimpleSkill] = {{NotNeedAttach = false, AttachPanel = self.TopPanel,
		BpName = "Skill/SkillMainPanel_UIBP.SkillMainPanel_UIBP", Name ="SkillMainPanel"}},
	}
	self.WidgetsOutsidePage =
	{
		--属性详情
		[PageType.AttributeDetail] = {{NotNeedAttach = false, AttachPanel = self.MainPanel,
		BpName = "Attribute/AttributeMainPage_UIBP.AttributeMainPage_UIBP", Name = "AttributeMainPage"},
		{NotNeedAttach = true, Widget = self.CloseBtn},
		{NotNeedAttach = true, Widget = self.EquipmentOtherPanel} },
		--装备详情
		[PageType.EquipmentDetail] = {{NotNeedAttach = true, Widget = self.EquipmentOtherPanel},
		{NotNeedAttach = true, Widget = self.CloseBtn}},
	}

	--每次挂上去的UI都在这
	self.ChildViewTable = {}

	self.Callbacks = {}
	self.CallbackID = 0
	self.CurProfID = 0
end

function EquipmentNewMainView:OnDestroy()
	
end

function EquipmentNewMainView:UpdateSlotByItem(Part, ResID, GID, bAddClick, bPlayAnim)
	if self.CurrrentEquipList then
		self.CurrrentEquipList:UpdateSlotByItem(Part, ResID, GID, bAddClick, bPlayAnim)
	end
end

function EquipmentNewMainView:GetSlotViewModel(Part)
	if self.CurrrentEquipList then
		return self.CurrrentEquipList:GetSlotViewModel(Part)
	end
end

function EquipmentNewMainView:UpdateEquipScore()
	self.ViewModel.EquipScore = EquipmentMgr:CalculateEquipScore()
end

function EquipmentNewMainView:UpdateStrongest()
	self.ViewModel.bStrongest = EquipmentMgr:IsStrongest()
end

---穿戴装备改变后需要更新的部分
function EquipmentNewMainView:UpdateWhenEquipedChange()
	self:UpdateEquipScore()
	self:UpdateStrongest()
end

function EquipmentNewMainView:UpdateProfList()
	if self.CurProfID == self.ViewModel.ProfID  then 
		return
	end

	---初始化左边职业列表
	local ProfList = {}
	if EquipmentVM.lstProfDetail ~= nil then
		local lstData = nil
	    local ProfSpecialization = RoleInitCfg:FindProfSpecialization(self.ViewModel.bUnlockProf and 
										_G.EquipmentMgr:GetPreviewProfID() or MajorUtil.GetMajorProfID())
		lstData = ProfMgr.GenProfLevelSortData(EquipmentVM.lstProfDetail, ProfSpecialization, false)
		for _, SectionData in ipairs(lstData) do
			if (#SectionData.lst > 0) then
				for Index = 1, #SectionData.lst do
					local ItemData = SectionData.lst[Index]
					local ProfVM = {}
					local ProfCfgData = RoleInitCfg:FindCfgByKey(ItemData.Prof)
					local ProfLevel = ProfCfgData.ProfLevel
					local ProfType = ProfCfgData.Specialization
					local ProfCfg = RoleInitCfg:FindProfForPAdvance(ItemData.Prof)

					local IsAdvancedProf = ProfUtil.IsAdvancedProf(ItemData.Prof)
					if ProfType == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION then
						if not IsAdvancedProf then
							ProfVM.RedDotData = {}
							ProfVM.RedDotType = "Equipment"
							ProfVM.RedDotData.RedDotName = _G.RedDotMgr:GetRedDotNameByID(tonumber("71"..string.format("%02d", ItemData.Prof)))
							ProfVM.RedDotData.IsStrongReminder = true
						end
						ProfVM.ProfID = ItemData.Prof
						ProfVM.Data = ItemData.Data
						ProfVM.IconPath = ProfUtil.GetProfIconBySelected(ItemData.Prof, false)
						ProfVM.SelectIcon = ProfUtil.GetProfIconBySelected(ItemData.Prof, true)
						ProfVM.ID = ItemData.Prof
						ProfVM.ConditionData = ItemData.Prof
						ProfVM.ConditionFunc = function(Data)
							if not _G.ProfMgr:CanChangeProf(Data, true, false)then
								if Data ~= MajorUtil.GetMajorProfID() then
									return true
								end
							end
							if self.IsInAnimation then
								return true
							end
						end
						ProfList[#ProfList + 1] = ProfVM
					else
						if ProfLevel > 0 and not ItemData.bActive and ProfCfg then
							--未解锁的有基职的特职不显示
						elseif ItemData.AdvancedProf ~= 0 and EquipmentVM.lstProfDetail[ItemData.AdvancedProf] ~= nil then
							--解锁特职的基职不显示
						else
							ProfVM.ProfID = ItemData.Prof
							ProfVM.Data = ItemData.Data
							ProfVM.IconPath = ProfUtil.GetProfIconBySelected(ItemData.Prof, false)
							ProfVM.SelectIcon = ProfUtil.GetProfIconBySelected(ItemData.Prof, true)
							ProfVM.ID = ItemData.Prof
							if not IsAdvancedProf then
								ProfVM.RedDotData = {}
								ProfVM.RedDotType = "Equipment"
								ProfVM.RedDotData.RedDotName = _G.RedDotMgr:GetRedDotNameByID(tonumber("71"..string.format("%02d", ItemData.Prof)))
								ProfVM.RedDotData.IsStrongReminder = true
							end
							ProfVM.ConditionData = ItemData.Prof
							ProfVM.ConditionFunc = function(Data)
								if not _G.ProfMgr:CanChangeProf(Data, true, false)then
									if Data ~= MajorUtil.GetMajorProfID() then
										return true
									end
								end
								if self.IsInAnimation then
									return true
								end
							end
							ProfList[#ProfList + 1] = ProfVM
						end
					end
				end
			end
		end
	end

	self.ViewModel.ProfList = ProfList;

	--select当前职业
	local MajorIndex = 0
	local ProfID = _G.EquipmentMgr:GetPreviewProfID()
	if not ProfID or ProfID == 0 then
		ProfID = MajorUtil.GetMajorProfID()
	end
	self.ViewModel:SetProf(ProfID)
	for i = 1, #ProfList do
		if ProfList[i].ProfID == self.ViewModel.ProfID then
			MajorIndex = i
			break
		end
	end

	self.CurProfID = self.ViewModel.ProfID

	self.ProfTableViewNew:UpdateItems(ProfList, MajorIndex > 0 and MajorIndex or 1)
end

function EquipmentNewMainView:InitText()

end

function EquipmentNewMainView:OnShow()		
	local bPlayAnimIn = true
	if nil ~= self.Params and nil ~= self.Params.bPlayAnimIn then
		bPlayAnimIn = self.Params.bPlayAnimIn
	end
	self.TextTitle:SetText(LSTR(1050155))
	if bPlayAnimIn then		
		self:PlayAnimation(self.AnimIn0)
		self.IsInAnimation = true
		local EndTime = self.AnimIn0:GetEndTime()
		self:RegisterTimer(function()
			self.IsInAnimation = false
			_G.EventMgr:SendEvent(_G.EventID.EquipmentAnimFinish)
		end, EndTime + 0.1, 0, 1)
	else
		_G.EventMgr:SendEvent(_G.EventID.EquipmentAnimFinish)
	end

	self:ExecuteAllCallbacks()
	self.Common_Render2D_UIBP.bCreateNewBackground = true
	self.Common_Render2D_UIBP.bCreateShandowActor = true
	self.BackBtn:AddBackClick(self, function()
		self:OnListPageBackClick()
	end)

	self.CloseBtn:SetCallback(self, function()
		-- if self.SimpleMain then
		-- 	self.SimpleMain:HideRenderView()
		-- end
		self:Hide()
	end)
	
	self.ViewModel:SetProf(MajorUtil.GetMajorProfID())
	self.ViewModel:SetProfSpecialization(RoleInitCfg:FindProfSpecialization(self.ViewModel.ProfID))
	self.ViewModel.Level = MajorUtil.GetMajorLevel()
	if not EquipmentMgr:GetCanSwitchHatVisble() then
		self.ViewModel.bIsShowHead = true
	else
		self.ViewModel.bIsShowHead = EquipmentMainVM:GetSettingsTabRole().ShowHeadIdx == 1 and true or false
	end
	local AvatarComp = MajorUtil.GetMajorAvatarComponent()
	if nil ~= AvatarComp then
		self.ViewModel.AttachType = AvatarComp:GetAttachTypeIgnoreChangeRole()
	end

	-- 加载相机参数
	local CameraParams = EquipmentCameraControlDataLoader:GetCameraControlParams(self.ViewModel.AttachType,
		CameraControlDefine.FocusType.WholeBody)
	self.Common_Render2D_UIBP:SetCameraControlParams(CameraParams)

	self:WeaponVisibleSwitch(self.ViewModel.bIsShowWeapon and 1 or 0)
	self:HatVisibleSwitch(self.ViewModel.bIsShowHead and 1 or 0)
	self:HatStyleSwitch(self.ViewModel.bIsHelmetGimmickOn and 1 or 0)

	self:PoseStyleSwitch(0)

	---初始化左边职业列表	
	local RoleDetail = _G.ActorMgr:GetMajorRoleDetail()
	if self.Params and not self.Params.bPreviewIn then
		_G.EquipmentMgr:SetPreviewProfID(false, MajorUtil.GetMajorProfID())
	end
	if RoleDetail and RoleDetail.Prof and RoleDetail.Prof.ProfList then
		EquipmentVM.lstProfDetail = RoleDetail.Prof.ProfList		
	end
	self:UpdateProfList(true)

	-- 初始化选中的页签
	self:InitTabList(false, 1)
	self.ActivePage = PageType.None

	-- 初始化页面
	self:SwitchPage(PageType.Attribute, true)

	--根据种族取对应的RenderActor
	local RenderActorPathForRace = string.format(ModelDefine.StagePath.Universe, self.ViewModel.AttachType, self.ViewModel.AttachType)

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
			self.bReadyToInitCamera = true
			self.bFirstAvatarAssemble = true
        end
    end
	local ReCreateCallBack = function()
        self.CameraFocusCfgMap:SetAssetUserData(self.Common_Render2D_UIBP:GetEquipmentConfigAssetUserData())
		if self.ActivePage == PageType.EquipmentDetail then
			self.Common_Render2D_UIBP.bAutoInitSpringArm = false
			self:ModelMoveToLeft()
		elseif self.ActivePage == PageType.AttributeDetail then
			self.Common_Render2D_UIBP.bAutoInitSpringArm = false
			self:ModelMoveToLeft(true, "Attr")
		end
    end
	local SystemLightCfgItem = SystemLightCfg:FindCfgByKey(3)
	local PathList
    if SystemLightCfgItem then
        PathList = SystemLightCfgItem.LightPresetPaths
    end
	--默认灯光预设
	local LightPath = "LightPreset'/Game/UI/Render2D/LightPresets/Login/TODUI_Equipment/Equipment_c0101.Equipment_c0101'"
	if PathList and next(PathList) then
		local LightType = self:GetLightConfigType(self.ViewModel.AttachType)
		LightPath = PathList[EquipmentLightConfig[LightType]]
	else
		_G.FLOG_INFO("EquipmentNewMainView LightPreset Init Faild")
	end
    self.Common_Render2D_UIBP:CreateRenderActor(RenderActorPathForRace,
	EquipmentMgr:GetEquipmentCharacterClass(), LightPath,
	false, CallBack, ReCreateCallBack)

	--UI天气
	self.Common_Render2D_UIBP.bIgnoreTodAffective = true

	-- local LightLevelID = LightDefine.LightLevelID.LIGHT_LEVEL_ID_EQUIP
	-- _G.LightMgr:LoadLightLevel(LightLevelID)

	_G.HUDMgr:SetIsDrawHUD(false)

	self.CommonRedDot:SetRedDotIDByID(8001)
	self:UpdateStrongest()
	--装备红点
	_G.EquipmentMgr:SetRedDot(7002, not self.ViewModel.bStrongest)
	--职业红点
	_G.EquipmentMgr:UpdateRoleRedDot()
	local RoleRedTable = _G.EquipmentMgr:GetRoleRedDotData()
	local HasRolePoint  = RoleRedTable[self.ViewModel.ProfID]
	_G.EquipmentMgr:SetRedDot(7010, HasRolePoint)
	--技能红点
	local SkillRedDotNum = _G.SkillSystemMgr:GetProfRedDotNum(self.ViewModel.ProfID)
	_G.EquipmentMgr:SetRedDot(7201, SkillRedDotNum > 0)

	self.EquipDetailPageShow = false
end

function EquipmentNewMainView:OnHide()
	self.CameraFocusCfgMap:SetAssetUserData(nil)
	self.bProfDetailListChange = nil
	self.ViewModel.bUnlockProf = false
	self.Common_Render2D_UIBP:SwitchOtherLights(true)
	for _, v in pairs(self.ChildTable) do
		local ViewID = _G.UIViewMgr:GetViewIDByName(v.BpName)
		if ViewID > 0 then
			_G.UIViewMgr:HideView(ViewID)
		end
		self[v.AttachName] = nil
	end
	EquipmentVM.bShowProfDetail = false
	_G.EquipmentMgr:RemoveUINPC()
	_G.HUDMgr:SetIsDrawHUD(true)
	_G.LightMgr:DisableUIWeather(true)
	-- local LightLevelID = LightDefine.LightLevelID.LIGHT_LEVEL_ID_EQUIP
	-- _G.LightMgr:UnLoadLightLevel(LightLevelID)
	_G.EquipmentMgr:SetPreviewProfID(false, nil)
	UIViewMgr:HideView(UIViewID.CommGetWayTipsView)
	self.EquipDetailPageShow = false
end

function EquipmentNewMainView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ProfTableViewNew.BtnSwitch, self.OnProfDetailClick)
	--
	UIUtil.AddOnClickedEvent(self, self.BtnPersonInfo, self.OnRoleInfoClick)
	UIUtil.AddOnClickedEvent(self, self.BtnCurrency, self.OnCurrencySummaryClick)
	UIUtil.AddOnSelectionChangedEvent(self, self.ProfTableViewNew, self.OnSelectionChangedTabs)
end

function EquipmentNewMainView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.MajorLevelUpdate, self.OnMajorLevelUpdate)
	self:RegisterGameEvent(_G.EventID.EquipRepairSucc, self.OnEquipRepairSucc)
	self:RegisterGameEvent(_G.EventID.MajorProfSwitch, self.OnMajorProfSwitch)
	self:RegisterGameEvent(_G.EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
	self:RegisterGameEvent(_G.EventID.RoleLoginRes, self.OnRoleLoginRes)
	self:RegisterGameEvent(_G.EventID.StrongestEquipUpdate, self.OnStrongestEquipUpdate)
	self:RegisterGameEvent(_G.EventID.SwitchLockProf, self.OnLockProfSelect)
    self:RegisterGameEvent(_G.EventID.SkillSystemProfRedDotChange, self.OnSkillSystemProfRedDotChange)
	self:RegisterGameEvent(_G.EventID.HideUI, self.OnViewHide)
	self:RegisterGameEvent(_G.EventID.StartDialog, self.Hide)
	self:RegisterGameEvent(_G.EventID.WorldPostLoad, self.Hide)
	--闪断重连不需要关闭界面，断线重连才需要
	-- self:RegisterGameEvent(_G.EventID.NetworkReconnected, self.OnRelayConnected)
	self:RegisterGameEvent(_G.EventID.SkillCustomEnter, self.OnSkillCustomEnter)
	self:RegisterGameEvent(_G.EventID.SkillCustomLeave, self.OnSkillCustomLeave)
	self:RegisterGameEvent(_G.EventID.ReSelectMajorProf, self.OnReSelectMajorProf)
	self:RegisterGameEvent(_G.EventID.EquipStrongestViewHide , self.OnStrongestViewHide)
end

function EquipmentNewMainView:OnRegisterBinder()
	local UIBinderSetIsVisibleByBitData = { MaxIndex = 0 }
    local Binders = {
		{ "ProfID", UIBinderSetProfName.New(self, self.Text_Prof, true)},
		{ "Level", UIBinderSetTextFormat.New(self, self.Text_RoleLevel, _G.LSTR(1050001)) },
		{ "Level", UIBinderValueChangedCallback.New(self, nil, self.OnRoleLevelChange) },
		{ "Subtitle", UIBinderValueChangedCallback.New(self, nil, self.OnTextSubtitleUpdate) },
		{ "ProfID", UIBinderValueChangedCallback.New(self, nil, self.OnTextSubtitleUpdate) },
		{ "TabList", UIBinderUpdateBindableList.New(self, self.AdapterTabTableView) },
		--暂时注了，没看见有地方用到
		--{ "EquipmentOtherPanel", UIBinderSetIsVisible.New(self, self.EquipmentOtherPanel) },
		{ "bHasSubtitle", UIBinderSetIsVisibleByBit.New(self, self.Text_RoleLevel, UIBinderSetIsVisibleByBitData, true) },
		{ "bUnlockProf",  UIBinderSetIsVisibleByBit.New(self, self.Text_RoleLevel, UIBinderSetIsVisibleByBitData, true) },
		{ "bHasSubtitle", UIBinderSetIsVisible.New(self, self.Text_Prof, true) },
		{ "bHasSubtitle", UIBinderSetIsVisible.New(self, self.TextSubtitle) },
		{ "Subtitle", UIBinderSetText.New(self, self.TextSubtitle) },
		{ "bUnlockProf", UIBinderSetIsVisible.New(self, self.BtnPersonInfo, true, true)},
		{ "bUnlockProf", UIBinderSetIsVisible.New(self, self.BtnCurrency, true, true)},
		{ "bUnlockProf", UIBinderSetIsVisible.New(self, self.SizeBoxJob) },
	}
	self:RegisterBinders(self.ViewModel, Binders)

	local Binders1 = {
		{ "lstProfDetail", UIBinderValueChangedCallback.New(self, nil, self.OnProfDetailListChange) },
		{ "bShowProfDetail", UIBinderValueChangedCallback.New(self, nil, self.OnShowProfDetailChange) },
	}

	self:RegisterBinders(EquipmentVM, Binders1)
end

function EquipmentNewMainView:OnProfDetailListChange()
	--职业详情查询结果返回
	if self.bProfDetailListChange == nil and EquipmentVM.lstProfDetail ~= nil then
		--只使用打开UI的那一次结果，保证后续不被影响
		self.bProfDetailListChange = true
		self:UpdateProfList()
	end
end

function EquipmentNewMainView:OnRoleLevelChange()
	self:PlayAnimation(self.AnimTextRoleLevelUpdate)
end

function EquipmentNewMainView:OnTextSubtitleUpdate()
	self:PlayAnimation(self.AnimTextSubtitleUpdate)
end

function EquipmentNewMainView:OnTextProfUpdate()
	self:PlayAnimation(self.AnimTextProfUpdate)
end
---------- UI事件 ----------
function EquipmentNewMainView:OnBtnHandClick(ToggleButton, ButtonState)
	local IsShow = self:WeaponVisibleSwitch(ButtonState)
	self:ShowWeaopenTips(IsShow)
end

function EquipmentNewMainView:WeaponVisibleSwitch(ButtonState)
	local bIsShowWeapon = ButtonState == _G.UE.EToggleButtonState.Checked
	self.ViewModel:SetIsShowWeapon(bIsShowWeapon, true)
	self:SendClientSetupPost(ClientSetupID.RoleWeaponVisible, self.ViewModel.bIsShowWeapon)
	self:UpdateWeaponHideState()
	return bIsShowWeapon
end

--- 发送给服务器保存下来
function EquipmentNewMainView:SendClientSetupPost(Key, State)
    local Params = {}
    Params.IntParam1 = Key
    Params.StringParam1 = tostring(State and 1 or 2)
    _G.ClientSetupMgr:OnGameEventSet(Params)
end

function EquipmentNewMainView:ShowWeaopenTips(bIsShowWeapon)
	local OpenContent = (LSTR(1050061))
	local CloseContnet = (LSTR(1050024))
	local Text = bIsShowWeapon and OpenContent or CloseContnet
	--_G.MsgTipsUtil.ShowTips(Text)
end

function EquipmentNewMainView:OnBtnHatClick(ToggleButton, ButtonState)
	local IsShow = self:HatVisibleSwitch(ButtonState)
	self:ShowHatTips(IsShow)
end

function EquipmentNewMainView:HatVisibleSwitch(ButtonState)
	local bHideHead = true
	if ButtonState == _G.UE.EToggleButtonState.Checked then
		bHideHead = false
	end
	self:SendClientSetupPost(ClientSetupID.RoleHatVisible, self.ViewModel.bHideHead)
	self.ViewModel:HideHead(bHideHead, true)
	self.Common_Render2D_UIBP:HideHead(bHideHead)
	return bHideHead
end

function EquipmentNewMainView:ShowHatTips(bHideHead)
	local OpenContent = (LSTR(1050060))
	local CloseContnet = (LSTR(1050023))
	local Text = bHideHead and CloseContnet or OpenContent
	--_G.MsgTipsUtil.ShowTips(Text)
end

function EquipmentNewMainView:OnBtnHatStyleClick(ToggleButton, ButtonState)
	local IsShow = self:HatStyleSwitch(ButtonState)
	self:ShowHatStyleTips(IsShow)
end

function EquipmentNewMainView:HatStyleSwitch(ButtonState)
	if not self.ViewModel.bEnableHelmetBtn then
		return
	end
	local bIsHelmetGimmickOn = ButtonState == _G.UE.EToggleButtonState.Checked
	self.Common_Render2D_UIBP:SwitchHelmet(bIsHelmetGimmickOn)
	self.ViewModel:SwitchHelmet(bIsHelmetGimmickOn, true)
end

function EquipmentNewMainView:ShowHatStyleTips()
	if not self.ViewModel.bEnableHelmetBtn then
		_G.MsgTipsUtil.ShowTips(_G.LSTR(1050226))
		return
	end
end

function EquipmentNewMainView:OnBtnPoseClick(ToggleButton, ButtonState)
	local IsShow = self:PoseStyleSwitch(ButtonState)
	self:ShowPoseStyleTips(IsShow)
end

function EquipmentNewMainView:PoseStyleSwitch(ButtonState)
	self.ViewModel.bIsHoldWeapon = ButtonState == _G.UE.EToggleButtonState.Checked
	self.Common_Render2D_UIBP:HoldOnWeapon(self.ViewModel.bIsHoldWeapon)
	self:UpdateWeaponHideState()
end

function EquipmentNewMainView:ShowPoseStyleTips()
	local Contnet = (LSTR(1050028))
	--_G.MsgTipsUtil.ShowTips(Contnet)
end

function EquipmentNewMainView:OnTabTableViewSelectChange(Index, ItemData, ItemView, bIsByClick)
	if self.IsInAnimation then
		return
	end
	if bIsByClick then
		-- 默认脚本触发的页签切换不切换页面，脚本切换页面需调用SwitchPage
		--判断是否是预览，预览Index + 2
		if self.ViewModel.bUnlockProf then
			Index = Index + 20
			--self.ActivePage = Index
		end
		self:SwitchPage(Index)
	end
end

---------- 游戏事件 ----------

function EquipmentNewMainView:OnMajorLevelUpdate(Params)
	self.ViewModel:UpdateLevelValue(Params)
end

function EquipmentNewMainView:OnEquipRepairSucc(Params)
	for _,GID in pairs(Params) do
		local Item, Part = EquipmentMgr:GetItemByGID(GID)
		self:UpdateSlotByItem(Part, Item.ResID, Item.GID, false)
	end
end

--如果当前是技能面板的页签，更新技能数据
function EquipmentNewMainView:OnMajorProfSwitch(Params)
	self.ViewModel:SetProf(Params.ProfID)
	if self.SkillMainPanel and UIUtil.IsVisible(self.SkillMainPanel) then
		self.Common_Render2D_UIBP:ReSetFovTarget()
		self.SkillMainPanel:OnSelectedProfChange(Params.ProfID)
	end

	self.ViewModel:SetProfSpecialization(RoleInitCfg:FindProfSpecialization(Params.ProfID))
	self.ViewModel.bUnlockProf = false
	local VfxParameter = _G.UE.FVfxParameter()
	local ChildActor = self.Common_Render2D_UIBP:GetCharacter()
	VfxParameter.VfxRequireData.VfxTransform = ChildActor:GetTransform()
    VfxParameter.VfxRequireData.EffectPath = TeamDefine.ProfChgEffect
    local AttachPointType_Body = _G.UE.EVFXAttachPointType.PlaySourceType_Equip
    VfxParameter:SetCaster(ChildActor, 0, AttachPointType_Body, 0)
    _G.ProfMgr.ProfChgEffectID = EffectUtil.PlayVfx(VfxParameter)
	EquipmentVM.bShowProfDetail = false
	--更新红点
	local RoleRedTable = _G.EquipmentMgr:GetRoleRedDotData()
	local HasRolePoint  = RoleRedTable[self.ViewModel.ProfID]
	_G.EquipmentMgr:SetRedDot(7010, HasRolePoint)
end

function EquipmentNewMainView:SetAssembleCallBack(Function)
	self.AssembleCallBack = Function
end

--装备界面角色拼装完成
function EquipmentNewMainView:OnAssembleAllEnd(Params)
	local ChildActor = self.Common_Render2D_UIBP:GetCharacter()
	if (ChildActor == nil) then return end
	local EntityID = Params.ULongParam1
	local ObjType = Params.IntParam1
	local AttrComp = ChildActor:GetAttributeComponent()
	if EntityID == AttrComp.EntityID and ObjType == AttrComp.ObjType then
		self.Common_Render2D_UIBP:UpdateAllLights()
		local UIComplexCharacter = self.Common_Render2D_UIBP.UIComplexCharacter
		if UIComplexCharacter then
			UIComplexCharacter:GetAvatarComponent():SetForcedLODForAll(1)

			--根据设置 显示
			self:CheckNeedShowSwitchHelmet()
			-- if self.ViewModel.bIsShowWeapon then	这条不用管，会刷新的
			-- UIComplexCharacter:HideHead(self.ViewModel.bIsShowHead, true) --提前做，否则死循环
			UIComplexCharacter:SwitchHelmet(self.ViewModel.bIsHelmetGimmickOn)
			if self.bFirstAvatarAssemble then
				UIComplexCharacter:StartFadeIn(ActorFadeInTime, true)
				self.bFirstAvatarAssemble = false
			end
		end
		if self.bReadyToInitCamera then
			self.Common_Render2D_UIBP:UpdateFocusLocation()
			self:SetModelSpringArmToDefault(true)
			self.bReadyToInitCamera = false
		end
		self:UpdateWeaponHideState()
		-- 设置不同职业待机动作
		local ProfIdleCfgData = ProfIdleCfg:FindCfgByKey(AttrComp.ProfID)
		if self.EquipDetailPageShow then
			self.Common_Render2D_UIBP:SetCombatRestEnabled(UIComplexCharacter, ProfIdleCfgData and ProfIdleCfgData.Action > 0)
		else
			self.Common_Render2D_UIBP:SetCombatRestEnabled(UIComplexCharacter, false)
		end

	end
	if self.AssembleCallBack ~= nil then
		self.AssembleCallBack()
		self.AssembleCallBack = nil
	end
end

function EquipmentNewMainView:CheckNeedShowSwitchHelmet()
	local ItemList = EquipmentVM.ItemList
	if ItemList and next(ItemList) and ItemList[ProtoCommon.equip_part.EQUIP_PART_HEAD] then
		local UIComplexCharacter = self.Common_Render2D_UIBP.UIComplexCharacter
		local HasGimick = UIComplexCharacter:GetAvatarComponent():GetHelmetHasGimmick()
		self.ViewModel.bEnableHelmetBtn = HasGimick
	else
		self.ViewModel.bEnableHelmetBtn = false
	end

	if self.CurrrentEquipList then
		if not self.ViewModel.bEnableHelmetBtn then
			self.CurrrentEquipList.Btn_HatStyle:SetCheckedState(_G.UE.EToggleButtonState.Locked,false)
		else
			self.CurrrentEquipList.Btn_HatStyle:SetCheckedState(self.ViewModel.bIsHelmetGimmickOn and 1 or 0,false)
		end
	end
end

function EquipmentNewMainView:OnRoleLoginRes(Params)
	if Params.bReconnect then
		self:Hide()
	end
end

function EquipmentNewMainView:OnRelayConnected(Params)
    if not Params.bRelay or not self.bActive then
        return
    end
	--闪断重连不需要关闭界面，断线重连才需要
	-- self:Hide()
end

function EquipmentNewMainView:OnStrongestEquipUpdate(_)
	self:UpdateStrongest()
end

function EquipmentNewMainView:OnSkillSystemProfRedDotChange(Param)
	local SkillRedDotNum = _G.SkillSystemMgr:GetProfRedDotNum(self.ViewModel.ProfID)
	_G.EquipmentMgr:SetRedDot(7201, Param.bRedDotVisible)
end

function EquipmentNewMainView:OnViewHide(ViewID)
	if ViewID == UIViewID.CurrencySummary or ViewID == UIViewID.PersonInfoMainPanel or ViewID == UIViewID.MagicsparInlayMainPanel then
		self.Common_Render2D_UIBP:OnActive()
	elseif ViewID == UIViewID.LegendaryWeaponPanel then
		local CameraMgr = _G.UE.UCameraMgr.Get()
		if CameraMgr ~= nil then
			CameraMgr:SwitchCamera(self.Common_Render2D_UIBP.RenderActor, 0)
		end
	end
end

function EquipmentNewMainView:OnLockProfSelect(Data)
	--记录一下是未解锁职业
	self.IsPreview = Data.IsUnlock
	self.Common_Render2D_UIBP:HidePlayer(Data.IsUnlock)
	_G.EquipmentMgr:SetPreviewProfID(self.IsPreview, Data.ProfID)
	self.ViewModel:SetProf(Data.ProfID)
	if self.SkillMainPanel and UIUtil.IsVisible(self.SkillMainPanel) then
		self.Common_Render2D_UIBP:ReSetFovTarget()
		self.SkillMainPanel:OnSelectedProfChange(Data.ProfID)
	end
	if self.ViewModel.bUnlockProf ~= Data.IsUnlock then
		--在属性，装备就切简介,在技能就不处理
		if self.ActivePage == PageType.Attribute or self.ActivePage == PageType.Equipment then
			self:SwitchPage(PageType.SimpleMain)
		elseif self.ActivePage == PageType.SimpleMain then
			self:SwitchPage(PageType.Attribute)
		end
		if Data.IsUnlock and self.ActivePage == PageType.Skill or self.ActivePage == PageType.SimpleSkill then
			self.ActivePage = self.ActivePage == PageType.Skill and PageType.SimpleSkill or PageType.Skill
		end
		self:InitTabList(Data.IsUnlock, Data.IsUnlock and self.ActivePage - 20 or self.ActivePage, true)
	else
		local PageIndex = self:GetTabByPageType(self.ActivePage)
		PageIndex = PageIndex > 10 and PageIndex - 10 or PageIndex
		if self.ActivePage == PageType.SimpleMain then
			self.SimpleMain:OnSelectJobChange(_G.EquipmentMgr:GetPreviewProfID())
		end
		self:InitTabList(Data.IsUnlock, PageIndex, true)
	end
	self.ViewModel.bUnlockProf = Data.IsUnlock
	if Data.IsUnlock then
		--改成图片等设计，模型暂时注释提前开发
	end
end


function EquipmentNewMainView:InitTabList(isUnlock, SelectIndex, ReCreate)
	local TabList= {}
	if not isUnlock then
		local TextList = {_G.LSTR(1050054), _G.LSTR(1050122), _G.LSTR(1050079)}
		for i = 1, 3 do
			local EquipmentPageTabVM = EquipmentPageTabVM.New()
			EquipmentPageTabVM.Text = TextList[i]
			TabList[i] = EquipmentPageTabVM
			if i == 2 then
				TabList[i].RedDotID = 7001
			elseif i == 3 then
				TabList[i].RedDotID = 7201
			else
				TabList[i].RedDotID = nil
			end
			TabList[i].bSelect = SelectIndex == i and true or false
			TabList[i].ReCreate = ReCreate
		end
	else
		local TextList = {_G.LSTR(1050108),  _G.LSTR(1050079)}
		for i = 1, 2 do
			local EquipmentPageTabVM = EquipmentPageTabVM.New()
			EquipmentPageTabVM.Text = TextList[i]
			TabList[i] = EquipmentPageTabVM
			TabList[i].bShowRedPoint = nil
			TabList[i].ReCreate = ReCreate
			TabList[i].bSelect = SelectIndex == i and true or false
		end
	end
	self.ViewModel.TabList = TabList
	self.AdapterTabTableView:ScrollToTop()
	self.AdapterTabTableView:SetSelectedIndex(SelectIndex or 1)
end
---------- 其他 ----------

function EquipmentNewMainView:SwitchBackground(bRender2DBackground)
	self.Common_Render2D_UIBP:ShowBackgroundActor(bRender2DBackground)
end

function EquipmentNewMainView:SwitchPage(NewPage, IgnoreAnim)
	--动画播放中不切换界面
	if self.IsInAnimation and not IgnoreAnim then
		return
	end

	if not self:CanSwitchPage(NewPage) then
		self.AdapterTabTableView:SetSelectedIndex(self:GetTabByPageType(self.ActivePage))
		return
	end

	-- 隐藏上一页面控件与场景（切换到二级页面不需要）
	if NewPage <= 10 or NewPage >= 20 then
		local HideFunctionMap =
		{
			[PageType.Attribute] = self.HideAttributePage,
			[PageType.Equipment] = self.HideEquipmentPage,
			[PageType.Skill] = self.HideSkillPage,
			[PageType.AttributeDetail] = self.HideAttrDetailPage,
			[PageType.EquipmentDetail] = self.HideEquipDetailPage,
			[PageType.SimpleMain] = self.HideSimpleMainUI,
			[PageType.SimpleSkill] = self.HideSkillPage,
		}
		if self.ActivePage ~= PageType.None then
			HideFunctionMap[self.ActivePage](self, false)
		else
			self:HideAllPages(NewPage)
		end
	end

	-- 显示选中页面控件与场景（只有一级页面切换到其他页面需要）
	if self.ActivePage <= 10  or self.ActivePage >= 20 then
		local ShowFunctionMap =
		{
			[PageType.Attribute] = self.ShowAttributePage,
			[PageType.Equipment] = self.ShowEquipmentPage,
			[PageType.Skill] = self.ShowSkillPage,
			[PageType.AttributeDetail] = self.ShowAttrDetailPage,
			[PageType.EquipmentDetail] = self.ShowEquipDetailPage,
			[PageType.SimpleMain] = self.ShowSimpleMainUI,
			[PageType.SimpleSkill] = self.ShowSkillPage,
		}
		
		ShowFunctionMap[NewPage](self, self.ActivePage == PageType.None) -- 首次显示使用AnimIn动画
	end

	self.ActivePage = NewPage
end

function EquipmentNewMainView:CanSwitchPage(NewPage)
	if math.abs(NewPage - self.ActivePage) > 15 or self.IsPreview then
		return true
	end
	local bIsCurrentTierOne = self.ActivePage < 10
	local bIsNewTierOne = NewPage < 10
	local bIsParentChild = math.abs(NewPage - self.ActivePage) == 10 
	local bCanSwitch = bIsParentChild
	if bIsCurrentTierOne then
		bCanSwitch = bCanSwitch or bIsNewTierOne
	end
	return bCanSwitch
end

function EquipmentNewMainView:GetTabByPageType(InPageType)
	InPageType = InPageType > 10 and InPageType - 10 or InPageType
	return InPageType
end

function EquipmentNewMainView:HideAllPages(Exception)
	local HideFunctionMap =
	{
		[PageType.Attribute] = self.HideAttributePage,
		[PageType.Equipment] = self.HideEquipmentPage,
		[PageType.Skill] = self.HideSkillPage,
	}
	for Key, Function in pairs(HideFunctionMap) do
		if Key ~= Exception then
			Function(self, true)
		end
	end
end

function EquipmentNewMainView:SetVisibilityOfPage(InPageType, bVisible, Anim, bInstantly)
	local WidgetsInsidePage = self.WidgetsInsidePage[InPageType]
	local WidgetsOutsidePage = self.WidgetsOutsidePage[InPageType]
	if nil == WidgetsInsidePage then
		WidgetsInsidePage = {}
	end
	if nil == WidgetsOutsidePage then
		WidgetsOutsidePage = {}
	end
	local WidgetsToShow = bVisible and WidgetsInsidePage or WidgetsOutsidePage
	local WidgetsToHide = bVisible and WidgetsOutsidePage or WidgetsInsidePage
    if nil ~= Anim then
    	self:PlayVisibilityAnim(Anim, WidgetsToHide, WidgetsToShow, bInstantly)
    else
		for _, Widget in pairs(WidgetsToHide) do
			if not Widget.NotNeedAttach and self[Widget.Name] then
				UIUtil.SetIsVisible(self[Widget.Name], false)
			elseif Widget.NotNeedAttach and Widget.Widget then
				UIUtil.SetIsVisible(Widget.Widget, false)
			end
		end
		for _, Widget in pairs(WidgetsToShow) do
			--没有挂载重新挂载
			if not Widget.NotNeedAttach then
				if not self[Widget.Name] then
					local CurrentID = _G.EquipmentMgr:GetPreviewProfID()
					local Data = {Prof = CurrentID}
					local PageView = _G.UIViewMgr:CreateViewByName(Widget.BpName, ObjectGCType.NoCache, self, true, true, Data)
					if not PageView then
						_G.FLOG_ERROR("EquipmentNewMainView:CreateViewByName failed, BPName=%s", Widget.BpName)
						return
					end
					PageView.SuperView = self
					Widget.AttachPanel:AddChildToCanvas(PageView)
					self[Widget.Name] = PageView
					local Anchor = _G.UE.FAnchors()
					Anchor.Minimum = _G.UE.FVector2D(0, 0)
					Anchor.Maximum = _G.UE.FVector2D(1, 1)
					UIUtil.CanvasSlotSetAnchors(PageView, Anchor)
					UIUtil.CanvasSlotSetPosition(PageView, _G.UE.FVector2D(0, 0))
					local Offset = UIUtil.CanvasSlotGetOffsets(Widget.AttachPanel)
					UIUtil.CanvasSlotSetOffsets(PageView, Offset)
					if InPageType == PageType.Attribute then
						PageView.OnAttrDetailInfo = self.OnAttrDetailInfo
					end
					if InPageType == PageType.Skill then
						self.SkillMainPanel.EquipmentMainVM = self.ViewModel
						self.SkillMainPanel.EquipmentMainView = self
					end
					if InPageType == PageType.AttributeDetail then
						self.AttributeDetail:ReScrollToTop()
					end
					local PageData = {BpName = Widget.BpName, AttachName = Widget.Name}
					table.insert(self.ChildTable, PageData)
					--有缓存，确保一下
					UIUtil.SetIsVisible(self[Widget.Name], true)
				else
					UIUtil.SetIsVisible(self[Widget.Name], true)
					if InPageType == PageType.SimpleMain then
						self.SimpleMain:OnSelectJobChange(_G.EquipmentMgr:GetPreviewProfID())
					end
				end
			else
				if not Widget.NotNeedAttach and self[Widget.Name] then
					UIUtil.SetIsVisible(self[Widget.Name], true)
				elseif Widget.NotNeedAttach and Widget.Widget then
					UIUtil.SetIsVisible(Widget.Widget, true)
				end
			end
		end
	end
	--兜底处理tablist
	self.AdapterTabTableView:ScrollToTop()
end

function EquipmentNewMainView:GetLightConfigType(Type)
	local str
	if Type == PageType.Attribute then
		str = "a_"
	else
		str = "e_"
	end
	if self.ViewModel.AttachType == "c0901" or self.ViewModel.AttachType == "c1101" then
		return str..self.ViewModel.AttachType
	else
		return str.."c0101"
	end
end

function EquipmentNewMainView:OnStrongestClick()
	if self.ViewModel.bPVE == false then
		MsgTipsUtil.ShowTips(LSTR(1050012))
	elseif self.ViewModel.bStrongest == true then
		MsgTipsUtil.ShowTips(LSTR(1050065))
	else
		self.Common_Render2D_UIBP:SetForceVisible(true)
		UIViewMgr:ShowView(UIViewID.EquipmentStrongest, {Render2DView = self.Common_Render2D_UIBP,
		FOV = self.CameraFocusCfgMap:GetOriginFOV(self.ViewModel.AttachType)})
	end
end

function EquipmentNewMainView:ShowAttributePage(bWithoutAnim)
	if self.Common_Render2D_UIBP:GetActiveFlag() == false then
		self.Common_Render2D_UIBP:SetActiveFlag(true)
		self.Common_Render2D_UIBP:ShowRenderActor(true)
	end
	self:SetModelSpringArmToDefault(false)
	self:SetVisibilityOfPage(PageType.Attribute, true, nil, false)
	_G.LightMgr:EnableUIWeather(3, false)
	local SystemLightCfgItem = SystemLightCfg:FindCfgByKey(3)
	local PathList
    if SystemLightCfgItem then
        PathList = SystemLightCfgItem.LightPresetPaths
    end
	--调整灯光预设
	if PathList and next(PathList) then
		local LightType = self:GetLightConfigType(self.ViewModel.AttachType)
		local LightPath = PathList[EquipmentLightConfig[LightType]]
		if LightPath then
			self.Common_Render2D_UIBP:ResetLightPreset(LightPath)
		end
	end
end

function EquipmentNewMainView:HideAttributePage(bInstantly)
	self:SetVisibilityOfPage(PageType.Attribute, false, nil, bInstantly)
end

function EquipmentNewMainView:ShowSimpleMainUI()
	self:SetVisibilityOfPage(PageType.SimpleMain, true)--, Anim)
end

function EquipmentNewMainView:HideSimpleMainUI()
	self:SetVisibilityOfPage(PageType.SimpleMain, false, nil)
end

function EquipmentNewMainView:ShowEquipmentPage()
	if self.Common_Render2D_UIBP:GetActiveFlag() == false then
		self.Common_Render2D_UIBP:SetActiveFlag(true)
		self.Common_Render2D_UIBP:ShowRenderActor(true)
	end
	-- _G.LightMgr:EnableUIWeather(19, false)
	-- 首测分支临时tod
	_G.LightMgr:EnableUIWeather(3, false)
	self:SetModelSpringArmToDefault(false)

	local SystemLightCfgItem = SystemLightCfg:FindCfgByKey(3)
	local PathList
    if SystemLightCfgItem then
        PathList = SystemLightCfgItem.LightPresetPaths
    end
	--调整灯光预设
	if PathList and next(PathList) then
		local LightType = self:GetLightConfigType(self.ViewModel.AttachType)
		local LightPath = PathList[EquipmentLightConfig[LightType]]
		if LightPath then
			self.Common_Render2D_UIBP:ResetLightPreset(LightPath)
		end
	end
	self:SetVisibilityOfPage(PageType.Equipment, true, self.AnimEquipListIn, false)
end

function EquipmentNewMainView:HideEquipmentPage(bInstantly)
	self:SetVisibilityOfPage(PageType.Equipment, false, self.AnimEquipListOut, bInstantly)
end

function EquipmentNewMainView:ShowSkillPage()
	self.Common_Render2D_UIBP:SetActiveFlag(false)
	self.Common_Render2D_UIBP:ShowRenderActor(false)
	self:SetVisibilityOfPage(PageType.Skill, true)
end

function EquipmentNewMainView:HideSkillPage()
	self:SetVisibilityOfPage(PageType.Skill, false)
	_G.HUDMgr:SetIsDrawHUD(false)
end

function EquipmentNewMainView:ShowEquipDetailPage()
	UIUtil.SetIsVisible(self.BackBtn, true, true)
	self.EquipDetailPageShow = true
	if self.ActivePage == PageType.Equipment then
		self.CurrrentEquipList:PlayAnimation(self.CurrrentEquipList.AnimListPanelIn)
		self.ActivePage = PageType.EquipmentDetail
	end

	self:SetVisibilityOfPage(PageType.EquipmentDetail, true)--, Anim)
	self.CurrrentEquipList:SetEquipmentDetailVsible(true)
	self.ViewModel.Subtitle = LSTR(1050124)
	self.ViewModel.bHasSubtitle = true
	EquipmentMgr:PreLoadMagicspar() -- 魔晶石预加载
	local ProfIdleCfgData = ProfIdleCfg:FindCfgByKey(self.ViewModel.ProfID)
	self.Common_Render2D_UIBP:SetCombatRestEnabled(self.Common_Render2D_UIBP.UIComplexCharacter, ProfIdleCfgData and ProfIdleCfgData.Action > 0)
end

function EquipmentNewMainView:HideEquipDetailPage()
	UIUtil.SetIsVisible(self.BackBtn, false, true)
	self.EquipDetailPageShow = false
	self.CurrrentEquipList:SetEquipmentDetailVsible(false)
	self:SetVisibilityOfPage(PageType.EquipmentDetail, false, self.AnimListPanelOut)

	self.ViewModel.bHasSubtitle = false

	---装备插槽选中
	self:SetSlotSelect(false, self.SelectSlotPart)
	self.CurrrentEquipList.Btn_ShowAllModel:SetChecked(false, false)

	--模型复位
	self:SetModelSpringArmToDefault(true)
	self:ClearPreView()
	self.Common_Render2D_UIBP:SetCombatRestEnabled(self.Common_Render2D_UIBP.UIComplexCharacter, false)
end

function EquipmentNewMainView:SetSlotSelect(bSelect, Part)
	if (Part == nil) then return end
	local EquipmentSlotItemVM = self:GetSlotViewModel(Part)
	if EquipmentSlotItemVM then
		EquipmentSlotItemVM.bSelect = bSelect
	end
	self.SelectSlotPart = bSelect and Part or nil
end

function EquipmentNewMainView:ClearPreView()
	if nil == next(self.PreViewMap) then
		return
	end
	self.PreViewMap = {}
	self.Common_Render2D_UIBP:ResumeAvatar()
end

function EquipmentNewMainView:ModelMoveToLeft(bShowAllModel, Tag)
	--模型左移
	
	if bShowAllModel == nil then bShowAllModel = false end
	self.Common_Render2D_UIBP:EnableZoom(false)
	self.Common_Render2D_UIBP:EnableRotator(false)
	self.Common_Render2D_UIBP:SetPostProcessVignetteIntensity(0)
	if bShowAllModel == true then
		self:PoseStyleSwitch(0)
		if Tag == "Attr" then
			-- 属性详情页面使用身体的机位配置
			local CameraFocusCfg = self.CameraFocusCfgMap:GetCfgByRaceAndProf(self.ViewModel.AttachType, MajorUtil.GetMajorProfID(), ProtoCommon.equip_part.EQUIP_PART_BODY)
			if CameraFocusCfg == nil then return end
			self:ModelMoveToLeftByCameraFocusCfg(CameraFocusCfg)
		else
			self:ShowAllModel()
			self.Common_Render2D_UIBP:SetCameraFOV(self.CameraFocusCfgMap:GetLeftDefaultFOV(self.ViewModel.AttachType))
		end
	else
		local CameraFocusCfg = self.CameraFocusCfgMap:GetCfgByRaceAndProf(self.ViewModel.AttachType, MajorUtil.GetMajorProfID(), self.SelectSlotPart)
		if CameraFocusCfg == nil then return end
		self:ModelMoveToLeftByCameraFocusCfg(CameraFocusCfg)
	end
end

function EquipmentNewMainView:ModelMoveToLeftByCameraFocusCfg(CameraFocusCfg)
	local SpringArmRotation = self.Common_Render2D_UIBP:GetSpringArmRotation()
	self.Common_Render2D_UIBP:SetSpringArmRotation(CameraFocusCfg.Pitch, SpringArmRotation.Yaw, SpringArmRotation.Roll, true)
	self.Common_Render2D_UIBP:SetCameraFOV(CameraFocusCfg.FOV)
	if CameraFocusCfg.BackAll then
		self:ShowAllModel(true)
		self.Common_Render2D_UIBP:SetModelRotation(0, CameraFocusCfg.Yaw , 0, true)
		self.Common_Render2D_UIBP:SetCameraFOV(self.CameraFocusCfgMap:GetLeftDefaultFOV(self.ViewModel.AttachType))
		self:PoseStyleSwitch(CameraFocusCfg.HoldWeapon and 1 or 0)
	else
		self:PoseStyleSwitch(CameraFocusCfg.HoldWeapon and 1 or 0)
		self.Common_Render2D_UIBP:SetModelRotation(0, CameraFocusCfg.Yaw , 0, true)
		local DPIScale = _G.UE.UWidgetLayoutLibrary.GetViewportScale(self)
		local ViewportSize = UIUtil.GetViewportSize()/DPIScale
		local UIX = ViewportSize.X/2 + CameraFocusCfg.UIX
		local UIY = ViewportSize.Y/2 + CameraFocusCfg.UIY
		self.Common_Render2D_UIBP:SetCameraFocusScreenLocation(UIX * DPIScale, UIY * DPIScale, CameraFocusCfg.SocketName, CameraFocusCfg.Distance)

		-- local ScreenLocation = _G.UE.FVector2D(CameraFocusCfg.UIX, CameraFocusCfg.UIY)
		-- self.FocusPoint.Slot:SetPosition(ScreenLocation)
	end
end

function EquipmentNewMainView:OnSlotClick(Part)
	if not self.CurrrentEquipList then return end
	if Part == self.SelectSlotPart then return end
	self:SwitchPage(PageType.EquipmentDetail)
	self.Common_Render2D_UIBP:SwitchActorAutoRotator(false)

	---装备插槽选中
	self:SetSlotSelect(false, self.SelectSlotPart)
	self:SetSlotSelect(true, Part)
	self.CurrrentEquipList.Btn_ShowAllModel:SetChecked(false, false)

	---显示可用装备列表
	local EquipmentListPageVM = self.CurrrentEquipList.EquipmentListPage.ViewModel
	local ProfID = self.ViewModel.ProfID
	EquipmentListPageVM:SetPart(Part, ProfID)
	self.CurrrentEquipList.EquipmentListPage:ToOriginState()

	--模型左移
	self:ModelMoveToLeft()
	self:ClearPreView()

	-- 武器显隐
	self:UpdateWeaponHideState()
end

function EquipmentNewMainView:OnListPageBackClick()
	self.Common_Render2D_UIBP:EnableZoom(true)
	if self.ActivePage == PageType.AttributeDetail then
		self:SwitchPage(PageType.Attribute)
	elseif self.ActivePage == PageType.EquipmentDetail then
		self.CurrrentEquipList:PlayAnimation(self.CurrrentEquipList.AnimListPanelOut)
		self:SwitchPage(PageType.Equipment)
	end
end

function EquipmentNewMainView:SetModelSpringArmToDefault(bInterp)
	self.Common_Render2D_UIBP.bAutoInitSpringArm = true
	local DefaultSpringArmLength = nil
	if nil ~= self.Common_Render2D_UIBP.CamControlParams then
		DefaultSpringArmLength = self.Common_Render2D_UIBP.CamControlParams.DefaultViewDistance
	end
	self.Common_Render2D_UIBP:SetSpringArmCenterOffsetY(-5, DefaultSpringArmLength)
	self.Common_Render2D_UIBP:EnableRotator(true)
	self.Common_Render2D_UIBP:SetCameraFocusScreenLocation(nil, nil, nil, nil)
    
	-- local SpringArmRotation = self.Common_Render2D_UIBP:GetSpringArmRotation()
	-- self.Common_Render2D_UIBP:SetSpringArmRotation(0, SpringArmRotation.Yaw, SpringArmRotation.Roll, true)
	self.Common_Render2D_UIBP:SetModelRotation(0, 0 , 0, true)

	-- local DefaultArmDistance = self.CameraFocusCfgMap:GetSpringArmDistance(self.ViewModel.AttachType)
    -- self.Common_Render2D_UIBP:SetSpringArmDistance(DefaultArmDistance, bInterp)
    -- self.Common_Render2D_UIBP:SetSpringArmDistance(self.Common_Render2D_UIBP.DefaultSpringArmLength, bInterp)
	self.Common_Render2D_UIBP:ResetViewDistance(bInterp)
	-- self.Common_Render2D_UIBP:SetSpringArmLocation(0.0, 0.0, self.Common_Render2D_UIBP.DefaultSpringArmLocationZ, bInterp)
	-- self.Common_Render2D_UIBP:SetCameraFOV(self.CameraFocusCfgMap:GetOriginFOV(self.ViewModel.AttachType))
	self.Common_Render2D_UIBP:SetPostProcessVignetteIntensity(self.VignetteIntensityDefaultValue)
	self:PoseStyleSwitch(0)
end

function EquipmentNewMainView:ShowAllModel(bBackAll)
	if bBackAll then
		self.Common_Render2D_UIBP:SetCameraFocusScreenLocation(nil, nil, nil, nil)
		self.Common_Render2D_UIBP:SetSpringArmLocation(100, -120, 106, true)
		self.Common_Render2D_UIBP:SetModelRotation(0, -45 , 0, true)
		local DefaultArmDistance = self.CameraFocusCfgMap:GetSpringArmDistance(self.ViewModel.AttachType)
		self.Common_Render2D_UIBP:SetSpringArmDistance(DefaultArmDistance - 50, true)
	else
		-- 使用部位0的配置
		local CameraFocusCfg = self.CameraFocusCfgMap:GetCfgByRaceAndProf(self.ViewModel.AttachType, MajorUtil.GetMajorProfID(), 0)
		if CameraFocusCfg == nil then return end
		self:ModelMoveToLeftByCameraFocusCfg(CameraFocusCfg)
	end
end

function EquipmentNewMainView:OnShowAllModelChange(ToggleButton, ButtonState)
	if ButtonState == _G.UE.EToggleButtonState.Checked then
		self:ShowAllModel()
	else
		self:ModelMoveToLeft()
	end
end

function EquipmentNewMainView:OnAttrDetailInfo()
	self:SwitchPage(PageType.AttributeDetail)
	if self.AttributeDetail then
		self.AttributeDetail:ReScrollToTop()
	end
end

function EquipmentNewMainView:ShowAttrDetailPage()
	UIUtil.SetIsVisible(self.BackBtn, true, true)
	self:SetVisibilityOfPage(PageType.AttributeDetail, true, self.AnimAttributeDetailIn)

	self.ViewModel.bHasSubtitle = true
	self.ViewModel.Subtitle = LSTR(1050055)

	--模型左移
	self:ModelMoveToLeft(true, "Attr")
end

function EquipmentNewMainView:HideAttrDetailPage()
	UIUtil.SetIsVisible(self.BackBtn, false, true)
	self:SetVisibilityOfPage(PageType.AttributeDetail, false, self.AnimAttributeDetailOut)

	self.ViewModel.bHasSubtitle = false

	--模型复位
	self:SetModelSpringArmToDefault(true)
end

function EquipmentNewMainView:OnSingleClick()
    self.Common_Render2D_UIBP:SwitchActorAutoRotator()
end

function EquipmentNewMainView:OnRoleInfoClick()
	_G.EventMgr:SendEvent(_G.EventID.PreShowPersonInfo)
	PersonInfoMgr:ShowPersonInfoView(MajorUtil.GetMajorRoleID())
end

function EquipmentNewMainView:OnCurrencySummaryClick()
	_G.UIViewMgr:ShowView(_G.UIViewID.CurrencySummary)
end

function EquipmentNewMainView:OnSelectionChangedTabs(Index, ItemData, ItemView, bClick)
	if bClick then
		local ProfData = self.ViewModel.ProfList[Index]
		_G.EquipmentMgr:SwitchProfByID(ProfData.ProfID)
	end
end

function EquipmentNewMainView:OnShowProfDetailChange(bShow)
	if bShow == true then
		self.IsProfRangeAsecSort = true
	else
		self.ViewModel:SetProfSpecialization(self.ViewModel.ProfSpecialization)
		--关闭职业预览详情
		if not (self.CurProfID == self.ViewModel.ProfID) then
			self:UpdateProfList()
		end
	end

	UIUtil.SetIsVisible(self.ProfPanel, bShow)
	UIUtil.SetIsVisible(self.RoleProfPage, bShow)
	UIUtil.SetIsVisible(self.RoleMainPanel, not bShow)
	UIUtil.SetIsVisible(self.HorizontalTitle, not bShow)
end

function EquipmentNewMainView:OnProfDetailClick()
	EquipmentVM.bShowProfDetail = not EquipmentVM.bShowProfDetail
end

function EquipmentNewMainView:OnEquipmentListSelect(Index, ItemData, ItemView)
	-- 切换预览装备
	local EquipmentDetailItemVM = ItemData
	if (EquipmentDetailItemVM) then
		---预览装备
		local EquipedItem = EquipmentMgr:GetEquipedItemByPart(EquipmentDetailItemVM.Part)
		local bSameAsEquipedItem = nil ~= EquipedItem and EquipmentDetailItemVM.ResID == EquipedItem.ResID
		if nil == self.PreViewMap[EquipmentDetailItemVM.Part] and bSameAsEquipedItem then
			-- 选中已穿戴装备，不切换预览
			return
		end
		if self.PreViewMap[EquipmentDetailItemVM.Part] ~= EquipmentDetailItemVM.ResID then
			if bSameAsEquipedItem then
				self.PreViewMap[EquipmentDetailItemVM.Part] = nil
			else
				self.PreViewMap[EquipmentDetailItemVM.Part] = EquipmentDetailItemVM.ResID
			end
			-- --[sammrli] 如果有投影,则显示投影的resid
			-- local GlamourID, ColorID = EquipmentMgr:GetGlamourByGID(EquipmentDetailItemVM.GID)
			-- local ResID = GlamourID > 0 and GlamourID or EquipmentDetailItemVM.ResID
			-- self.Common_Render2D_UIBP:PreViewEquipment(ResID, EquipmentDetailItemVM.Part, ColorID)

			-- 幻化
			local EquipID = EquipmentDetailItemVM.ResID
			local AppearanceID, ColorID, RandomID = WardrobeUtil.GetMajorAppearanceAndColorByPartID(EquipmentDetailItemVM.Part)
			EquipID = WardrobeUtil.GetEquipID(EquipID, AppearanceID, RandomID)
			self.Common_Render2D_UIBP:PreViewEquipment(EquipID, EquipmentDetailItemVM.Part, ColorID)
		end
	end

	-- 更新武器显隐状态
	self:UpdateWeaponHideState()
end

function EquipmentNewMainView:OnQualityClicked()
	UIUtil.SetIsVisible(self.BtnQualityBG, true, true)
	self:PlayAnimation(self.AnimPanelQIIn)
end

function EquipmentNewMainView:OnQualityBGClicked()
	UIUtil.SetIsVisible(self.BtnQualityBG, false)
end

-- 判断是否隐藏主手武器，拔刀必定显示武器
-- 生产职业预览副手，隐藏主手
function EquipmentNewMainView:IsHideMasterHand()
	local bIsHideWeapon = not (self.ViewModel.bIsShowWeapon or self.ViewModel.bIsHoldWeapon)
	local bIsProductProf = RoleInitCfg:FindProfSpecialization(MajorUtil.GetMajorProfID()) == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION
	local bIsPreviewSlaveHand = self.SelectSlotPart == ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND
	return bIsHideWeapon or (bIsProductProf and bIsPreviewSlaveHand)
end

-- 判断是否隐藏副手武器，拔刀必定显示武器
-- 生产职业非预览副手状态隐藏副手
function EquipmentNewMainView:IsHideSlaveHand()
	local bIsHideWeapon = not (self.ViewModel.bIsShowWeapon or self.ViewModel.bIsHoldWeapon)
	local bIsProductProf = RoleInitCfg:FindProfSpecialization(MajorUtil.GetMajorProfID()) == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION
	local bIsPreviewSlaveHand = self.SelectSlotPart == ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND
	return bIsHideWeapon or (bIsProductProf and not bIsPreviewSlaveHand)
end

-- 判断是否隐藏主手武器挂件，继承主手武器隐藏状态，但只有拔刀时才显示
function EquipmentNewMainView:IsHideAttachMasterHand()
	return self:IsHideMasterHand() or not self.ViewModel.bIsHoldWeapon
end

-- 判断是否隐藏副手武器挂件，继承副手武器隐藏状态，但只有拔刀时才显示
function EquipmentNewMainView:IsHideAttachSlaveHand()
	return self:IsHideSlaveHand() or not self.ViewModel.bIsHoldWeapon
end

function EquipmentNewMainView:UpdateWeaponHideState()
	local bHideMasterHand = self:IsHideMasterHand()
	local bHideSlaveHand = self:IsHideSlaveHand()
	self.Common_Render2D_UIBP:HideMasterHand(bHideMasterHand)
	self.Common_Render2D_UIBP:HideSlaveHand(bHideSlaveHand)

	self.Common_Render2D_UIBP:HideAttachMasterHand(self:IsHideAttachMasterHand())
	self.Common_Render2D_UIBP:HideAttachSlaveHand(self:IsHideAttachSlaveHand())
end

function EquipmentNewMainView:UpdateMajorWeaponHideState()
	local bHideMasterHand = self:IsHideMasterHand()
	local bHideSlaveHand = self:IsHideSlaveHand()

	local Major = MajorUtil.GetMajor()
	if Major then
		Major:HideMasterHand(bHideMasterHand)
		Major:HideSlaveHand(bHideSlaveHand)
	end
end

function EquipmentNewMainView:PlayAnimationOverride(Animation, bInstantly)
	local StartAtTime = bInstantly and Animation:GetEndTime() or 0
	self:PlayAnimation(Animation, StartAtTime, 1, nil, 1.0, false)
end

function EquipmentNewMainView:AddCallback(Callback)
	self.Callbacks[self.CallbackID] = Callback
	self.CallbackID = self.CallbackID + 1
end

function EquipmentNewMainView:RemoveCallback(CallbackID)
	self.Callbacks[CallbackID] = nil
end

function EquipmentNewMainView:ExecuteAllCallbacks()
	for _, Callback in pairs(self.Callbacks) do
		Callback()
	end
	self.Callbacks = {}
	self.CallbackID = 0
end

function EquipmentNewMainView:PlayVisibilityAnim(Anim, WidgetsToHide, WidgetsToShow, bInstantly)
	if nil == Anim then
		return
	end

	-- 先SetIsVisible以保证VM绑定正确执行
	for _, Widget in pairs(WidgetsToShow) do
		UIUtil.SetIsVisible(Widget, true)
	end

	self:PlayAnimationOverride(Anim, bInstantly)

	local function HideWidgets()
		for _, View in pairs(WidgetsToHide) do
			UIUtil.SetIsVisible(View, false)
		end
	end

	if bInstantly then
		-- 直接执行隐藏
		HideWidgets()
	else
		-- 计时器回调方式执行隐藏
		local CallbackID = self.CallbackID
		local function AnimCallback()
			self:PlayAnimationOverride(Anim, true)
			HideWidgets()
			self:RemoveCallback(CallbackID)
		end
		self:RegisterTimer(AnimCallback, Anim:GetEndTime() + 0.01)
		self:AddCallback(AnimCallback)
	end
end

function EquipmentNewMainView:OnSkillCustomStateChanged(bInState)
	local SkillMainPanel = self.SkillMainPanel
	if SkillMainPanel then
		UIUtil.CanvasSlotSetZOrder(SkillMainPanel, bInState and 2 or 0)
	end
	UIUtil.CanvasSlotSetZOrder(self.HorizontalTitle, bInState and 3 or 0)
	--[[
	UE的ZOrder排列只适用于同一Parent下的Widget, 不存在global的ZOrder
	如果要实现将EquipmentNewMain中其他控件置于SkillMainPanel中的遮罩之下, 关闭按钮置于其上,
	只能将关闭按钮暂时隐藏, 然后使用SkillMainPanel中的关闭按钮暂时替代
	这里设置半透是因为不和可见性的设置产生冲突
	]]
	self.CloseBtn:SetRenderOpacity(bInState and 0 or 1)
end

function EquipmentNewMainView:OnSkillCustomEnter()
	self:OnSkillCustomStateChanged(true)
end

function EquipmentNewMainView:OnSkillCustomLeave()
	self:OnSkillCustomStateChanged(false)
end

function EquipmentNewMainView:OnReSelectMajorProf()
	local Index = 1
	for key, value in pairs(self.ViewModel.ProfList) do
		if value and value.ProfID == MajorUtil.GetMajorProfID() then
			Index = key
		end
	end
	self.ProfTableViewNew:SetSelectedIndex(Index)
end

function EquipmentNewMainView:OnStrongestViewHide(bEnter)
	local TODMainActor = _G.UE.UEnvMgr:Get():GetTodSystem()
	if nil ~= TODMainActor and nil ~= TODMainActor.PostProcessCom then
		local Settings = TODMainActor.PostProcessCom.Settings
		Settings.bOverride_DepthOfFieldScale = bEnter
		Settings.DepthOfFieldScale = 1
		Settings.bOverride_DepthOfFieldFocalRegion = bEnter
		Settings.DepthOfFieldFocalRegion = 10
		Settings.bOverride_DepthOfFieldFocalDistance = bEnter
		Settings.DepthOfFieldFocalDistance = 50
		Settings.bOverride_MobileBokehDOFScale = bEnter
		Settings.MobileBokehDOFScale = 0.5
	end
	local ViewportSize = UIUtil.GetViewportSize()
	local UIX = ViewportSize.X * 0.5
	local UIY = ViewportSize.Y * 0.5
	if bEnter == true then
		self.Common_Render2D_UIBP:SaveCameraStatus()
		self.Common_Render2D_UIBP:SetCameraFocusScreenLocation(UIX, UIY, "spine3_M", 250)
		self.Common_Render2D_UIBP:SetCameraFOV(self.CameraFocusCfgMap:GetOriginFOV(self.ViewModel.AttachType), false)
		self.Common_Render2D_UIBP:DoCameraFocusScreenLocation(false)
		self.Common_Render2D_UIBP:ResetViewDistance(false)
		self.Common_Render2D_UIBP:SaveCharacterStatus()
		self.Common_Render2D_UIBP:SetModelRotation(0, 0, 0, false)
	else
		self.Common_Render2D_UIBP:RecoverCameraStatus(false)
		self.Common_Render2D_UIBP:RecoverCharacterStatus(false)
	end
end

return EquipmentNewMainView
