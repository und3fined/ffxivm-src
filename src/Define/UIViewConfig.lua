---
--- Author: anypkvcai
--- Date: 2020-08-05 15:52:16
--- Description:

-- 设计增加了半屏界面，沟通后大概新增加了几个规则：
-- 1. 半屏界面一般同时只存在一个, 增加了bUnique配置项
-- 2. 有的界面需要动态调整层级
-- 3. 半屏界面导致不一定后显示的界面先关闭, 层级之间的一些互斥规则有就问题了, 大概规则还是和之前保持一致, 按顺序简单处理互斥规则
-- 对于一些特殊情况设计那边也没确定的规则, 尽量不要配置一些特殊的规则, 例如:
-- A隐藏B B隐藏C C隐藏A 循环隐藏
-- B和C同时显示 B隐藏A 但C显示A

--- 配置参数说明:
--- BPName: Content/UI/BP这层开始
--- ShowType: 参考 UIShowType
--- Layer: 参考 UILayer
--- GCType: 参考 ObjectGCType
--- ListToSetVisible: 配置ViewID列表，打开View时，在列表中的View，不会因为层级互斥等原因被隐藏
--- ListToSetInvisible: 配置ViewID列表，打开View时，隐藏列表中的View，只是设置不可见，并不会从ViewMgr队列里删除
---@deprecated ListToHide: 建议用ListToHideOnShow， 配置ViewID列表，打开View时，隐藏列表中的View，调用ViewMgr:HideView()，会从ViewMgr队列里删除
----ListToHideOnShow: 配置ViewID列表，打开View时，隐藏列表中的View，调用ViewMgr:HideView()，会从ViewMgr队列里删除
----ListToHideOnHide: 配置ViewID列表，关闭View时，隐藏列表中的View，调用ViewMgr:HideView()，会从ViewMgr队列里删除
--- DontHideWhenLoadMap: 为true时切图时不关闭UIView，默认关闭
--- bInputModeUIOnly: 为true时不能旋转镜头不能选中玩家，默认为false
--- bCantControlCamera:为true时不能旋转镜头，默认为false
--- @deprecated IsSyncLoad: 为true时同步加载 默认同步步加载（废弃）
--- bAsyncLoad: 为true时异步加载 默认同步加载
--- bForceGC: 为true时关闭界面会强制GC 一般用于显示模型等内存占用比较大的界面
--- bUnique: 只会存在一个 一般是半屏界面 打开一个半屏界面后就隐藏另一个半屏界面
--- bEnableUpdateView: 界面已经显示 再次调用ShowView时 是否调用UpdateView接口
--- bEnableChangeLayer: 界面已经显示 再次调用ShowView时 是否改变层级显示到最顶层

local UIShowType = require("UI/UIShowType")
local UILayer = require("UI/UILayer")
local ObjectGCType = require("Define/ObjectGCType")
local UIViewID = require("Define/UIViewID")

---@class UIViewConfig @使用默认值的不用配置
local UIViewConfig = {
	[UIViewID.RootView] = {
		BPName = "Root/RootView",
		GCType = ObjectGCType.Hold,
	},

	[UIViewID.ClickFeedbackView] = {
		BPName = "Eff/ClickFeedback_UIBP",
		GCType = ObjectGCType.Hold,
	},

	[UIViewID.WaterMark] = {
		BPName = "Eff/WaterMark_UIBP",
		GCType = ObjectGCType.Hold,
	},

	[UIViewID.NetworkReconnectTips] = {
		BPName = "Network/ReconnectTips_UIBP",
		ShowType = UIShowType.Normal,
		GCType = ObjectGCType.Hold,
		Layer = UILayer.Network,
		bInputModeUIOnly = true,
		DontHideWhenLoadMap = true,
	},
	[UIViewID.NetworkReconnectMsgBox] = {
		BPName = "Network/ReconnectMsgBox_UIBP",
		ShowType = UIShowType.HideOthers,
		GCType = ObjectGCType.Hold,
		Layer = UILayer.Network,
		bInputModeUIOnly = true,
		DontHideWhenLoadMap = true,
	},
	[UIViewID.NetworkWaiting] = {
		BPName = "Network/NetworkWaiting_UIBP",
		ShowType = UIShowType.Normal,
		GCType = ObjectGCType.Hold,
		Layer = UILayer.Network,
		bInputModeUIOnly = true,
		DontHideWhenLoadMap = true,
	},

	[UIViewID.HUDView] = {
		BPName = "Root/HUD_UIBP",
		GCType = ObjectGCType.Hold,
	},

	[UIViewID.SampleMain] = {
		BPName = "Sample/SampleMainPanel_UIBP",
		GCType = ObjectGCType.LRU,
	},

	--[UIViewID.LoginMain] = {
	--	BPName = "Login/LoginMainPanelNew_UIBP",
	--	ShowType = UIShowType.Normal,
	--	Layer = UILayer.Normal,
	--	GCType = ObjectGCType.LRU,
	--	bInputModeUIOnly = true,
	--	bForceGC = true,
	--},

	--[UIViewID.TxUserProtocol] = {
	--	BPName = "LoginNew/Win/LoginNewUserAgreementWin_UIBP",
	--	ShowType = UIShowType.Normal,
	--	Layer = UILayer.Normal,
	--	GCType = ObjectGCType.LRU,
	--	bInputModeUIOnly = true,
	--},

	[UIViewID.RequirePermission] = {
		BPName = "LoginNew/Win/LoginNewPermissionsWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.LoginSplash] = {
		BPName = "LoginNew/LoginSplash_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.LoginMainNew] = {
		BPName = "LoginNew/LoginNewMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.LoginMainOversea] = {
		BPName = "LoginNew/LoginNewMainForeignServicePanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.LoginMoreWin] = {
		BPName = "LoginNew/Win/LoginNewMoreWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.LoginEmailMain] = {
		BPName = "LoginNew/Win/LoginNewCodeWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.LoginPreDownload] = {
		BPName = "LoginNew/Win/LoginNewPreDownloadWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.UserAgreementUpdate] = {
		BPName = "LoginNew/Win/LoginNewUpdateWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.LoginLanguageWin] = {
		BPName = "LoginNew/Win/LoginNewLanguageWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.LoginAgreementsWin] = {
		BPName = "LoginNew/Win/LoginNewAgreementWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.LoginCG] = {
		BPName = "LoginNew/LoginNewCGPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.LoginNotice] = {
		BPName = "LoginNew/Win/LoginNewNoticeWin_WBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	--[UIViewID.LoginLicensePrivacy] = {
	--	BPName = "Login/LoginLicensePrivacyWin_UIBP",
	--	ShowType = UIShowType.Normal,
	--	Layer = UILayer.Normal,
	--	GCType = ObjectGCType.LRU,
	--	bInputModeUIOnly = true,
	--},

	[UIViewID.LoginAgeAppropriate] = {
		--BPName = "Login/LoginAgeAppropriateWin_UIBP",
		BPName = "LoginNew/Win/LoginNewAgeTipsWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	--[UIViewID.LoginServerListItem] = {
	--	BPName = "Login/LoginServerListItem_UIBP",
	--	ShowType = UIShowType.Normal,
	--	Layer = UILayer.Normal,
	--	GCType = ObjectGCType.LRU,
	--},

	[UIViewID.LoginServerList] = {
		BPName = "LoginNew/LoginNewSeverPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.LoginQueueWin] = {
		BPName = "LoginNew/Win/LoginNewTipsWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.AccountCancellationWait] = {
		BPName = "Settings/SettingsDeregisterAccountSmallWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.AccountCancellationList] = {
		BPName = "Settings/SettingsDeregisterAccountBigWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.IntegrationView] = {
		BPName = "LoginNew/LoginNewAssemblePanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	--局内通用登录场景的ui
	[UIViewID.CommonLoginMapMainPanel] = {
		BPName = "Common/LoginMap/CommonLoginMapMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	-------- 新版登录 begin
	[UIViewID.LoginCreateRaceGender] = {
		-- BPName = "LoginRole/LoginRoleRaceGenderPage_UIBP",
		BPName = "LoginCreate/LoginCreateRaceGenderPage_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.BelowNormal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.LoginRoleRender2D] = {
		BPName = "LoginRole/LoginRoleRender2D_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.BelowNormal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	-- [UIViewID.HairCutRoleRender2D] = {
	-- 	BPName = "LoginCreate/HairCutRoleRender2D_UIBP",
	-- 	ShowType = UIShowType.Normal,
	-- 	Layer = UILayer.Normal,
	-- 	GCType = ObjectGCType.LRU,
	-- 	bInputModeUIOnly = true,
	-- },

	[UIViewID.LoginFixPage] = {
		-- BPName = "LoginRole/LoginRoleFixPage_UIBP",
		BPName = "LoginCreate/LoginCreateFixPage_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.LoginCreateTribe] = {
		BPName = "LoginCreate/LoginCreateTribePage_UIBP",
		-- BPName = "LoginRole/LoginRoleTribePage_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.BelowNormal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.LoginProgressWin] = {
		BPName = "LoginCreate/LoginCreateProgressWin_UIBP",
		-- BPName = "LoginRole/LoginRoleProgressWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.LoginRoleBirthday] = {
		BPName = "LoginCreate/LoginCreateBirthdayPage_UIBP",
		-- BPName = "LoginRole/LoginRoleBirthdayPage_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.BelowNormal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.LoginRoleGod] = {
		BPName = "LoginCreate/LoginCretaeGodPage_UIBP",
		-- BPName = "LoginRole/LoginRoleGodPage_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.BelowNormal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.LoginRoleProf] = {
		BPName = "LoginCreate/LoginCreateRolePage_UIBP",
		-- BPName = "LoginRole/LoginRoleRolePage_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.BelowNormal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.LoginDemoSkill] = {
		-- BPName = "LoginRole/LoginRoleDemoSkill_UIBP",
		BPName = "LoginCreate/LoginCreateDemoSkill_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.BelowNormal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},

	[UIViewID.LoginRoleName] = {
		-- BPName = "LoginRole/LoginRoleNameWin_UIBP",
		BPName = "LoginCreate/LoginCreateNamePanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.BelowNormal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.LoginCreateMakeName] = {
		BPName = "LoginCreate/LoginCreateMakeNamePanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Exclusive,
		ListToSetVisible = {UIViewID.ErrorTips, UIViewID.ActiveSystemErrorTips},
		GCType = ObjectGCType.LRU,
	},

	-- [UIViewID.GMLoginCreateMakeName] = {
	-- 	BPName = "LoginCreate/LoginCreateMakeNamePanel_UIBP",
	-- 	ShowType = UIShowType.Normal,
	-- 	Layer = UILayer.BelowNormal,
	-- 	GCType = ObjectGCType.LRU,
	-- },

	[UIViewID.LoginRoleShowPage] = {
		-- BPName = "LoginRole/LoginRoleShowPage_UIBP",
		BPName = "LoginCreate/LoginCreatePreviewPage_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.LoginSelectRoleNew] = {
		BPName = "LoginCreate/LoginCreateMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

    [UIViewID.LoginCreateAppearance] = {
		BPName = "LoginCreate/LoginCreateAppearancePage_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.BelowNormal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.LoginCreateAppearanceCustomize] = {
		BPName = "LoginCreate/LoginCreateAppearanceCustomizePage_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.BelowNormal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.LoginCreateSaveWin] = {
		BPName = "LoginCreate/LoginCreateSaveWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.NcutLoginLogoPage] = {
		BPName = "LoginNew/Ncut_LoginLogoPage_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Loading,
		GCType = ObjectGCType.NoCache,
		bInputModeUIOnly = true,
	},

	[UIViewID.FantasiaFinishWin] = {
		BPName = "LoginCreate/LoginFantasiaFinishWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	-------- 新版登录 end

	[UIViewID.LoadingDefault] = {
		BPName = "Loading/LoadingDefaultPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Loading,
		GCType = ObjectGCType.LRU,
		DontHideWhenLoadMap = true,
		bInputModeUIOnly = true,
		ListToHideOnShow = {UIViewID.NetworkReconnectMsgBox},
	},

	[UIViewID.LoadingMainCity] = {
		BPName = "Loading/LoadingMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Loading,
		GCType = ObjectGCType.LRU,
		DontHideWhenLoadMap = true,
		bInputModeUIOnly = true,
		ListToHideOnShow = {UIViewID.NetworkReconnectMsgBox},
	},

	[UIViewID.LoadingOther] = {
		BPName = "Loading/LoadingBannerPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Loading,
		GCType = ObjectGCType.LRU,
		DontHideWhenLoadMap = true,
		bInputModeUIOnly = true,
		ListToHideOnShow = {UIViewID.PVPInfoPanel, UIViewID.PVPSeriesMalmstonePanel, UIViewID.PVPOptionListPanel, UIViewID.PVPHonorPanel, UIViewID.NetworkReconnectMsgBox},
	},

	[UIViewID.BagPanel] = {
		BPName = "Bag/BagPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.MainPanel] = {
		BPName = "Main/MainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.Hold,
		--DontHideWhenLoadMap = true,
		DontHideWhenRevive = true,
	},

	[UIViewID.Main2ndPanel] = {
		BPName = "Main2nd/Main2ndPanelNew_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.Hold,
		bInputModeUIOnly = false,
		bUnique = true,
		ListToSetVisible = { UIViewID.MainPanel},
	},

	[UIViewID.Main2ndHelpInfoTips] = {
		BPName = "Main2nd/Main2ndHelpInfoTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.MainSkillStorage] = {
		BPName = "MainSkillBtn/SkillEnergyStorage_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.Hold,
	},

	[UIViewID.SkillCancelJoyStick] = {
		BPName = "MainSkillBtn/SkillCancelJoyStick_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.Hold,
	},

	[UIViewID.GMPanel] = {
		BPName = "GM/GMPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.Map,
		DontHideWhenRevive = true,
	},

	[UIViewID.GMMain] = {
		BPName = "GM/GMMainHud_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.Map,
	},

	[UIViewID.GMFloat] = {
		BPName = "GM/GMFloat_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.Map,
	},
	[UIViewID.GMMonsterAIInfo] = {
		BPName = "GM/GMMonsterAIInfo_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.Map,
	},

	[UIViewID.GMTargetInfo] = {
		BPName = "GM/GMTargetInfo_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.Map,
	},

	[UIViewID.GMVfxInfo] = {
		BPName = "GM/GMVfxInfo_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.Map,
		bEnableUpdateView = true,
	},

	[UIViewID.DragHud] = {
		BPName = "DragUI/DragHud__UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.Map,
	},

	[UIViewID.GMMainMinimizationHud] = {
		BPName = "GM/GMMainMinimizationHud_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.Map,
		bInputModeUIOnly = false,
	},

	[UIViewID.ItemButton] = {
		BPName = "GM/Item/GMItemButton_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.HomePageItem] = {
		BPName = "GM/GMHomePageItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.GMButton] = {
		BPName = "GM/GMButton_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.GMSlider] = {
		BPName = "GM/GMSlider_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.GMFilterItem] = {
		BPName = "GM/GMFilterItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.GMSwitch] = {
		BPName = "GM/GMSwitch_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.FOVView] = {
		BPName = "GM/FOV_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.SimplePerf] = {
		BPName = "Performance/SimplePerf_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveHigh,
		GCType = ObjectGCType.Hold,
	},

	[UIViewID.PWorldMainlinePanel] = {
		BPName = "PWorld/PWorldMainlinePanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		ListToHideOnShow = { UIViewID.ProfessionToggleJobTab },
	},

	[UIViewID.PWorldMainPanel] = {
		BPName = "PWorld/PWorldMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.PWorldSettingDetailPanel] = {
		BPName = "PWorld/PWorldSettingInforWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.PWorldEntrancePanel] = {
		BPName = "PWorld/PWorldEntrancePanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.PWorldEntranceSelectPanel] = {
		BPName = "PWorld/PWorldSelectSetPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.PWorldCardsMatchPanel] = {
		BPName = "PWorld/PWorldCardsMatchPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.PWorldDirectorListPannel] = {
		BPName = "PWorld/PWorldMentorConditionWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.GetLevelRecordListPanel] = {
		BPName = "Test/LevelRecord/GetLevelRecordListPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.RecordPlayControlPanel] = {
		BPName = "Test/LevelRecord/RecordPlayControlPanel_UIBP",
		GCType = ObjectGCType.Hold,
		DontHideWhenLoadMap = true,
	},


	[UIViewID.PWorldTaskSetUpListItem] = {
		BPName = "Pworld/Item/PWorldTaskSetUpListItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.PWorldEntouragePanel] = {
		BPName = "Entourage/EntourageMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.PWorldTeachingPanel] = {
		BPName = "PWorld/Teaching/PWorldTeachingPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.PWorldTeachingContentPanel] = {
		BPName = "PWorld/Teaching/Item/PWorldTeachingContentItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveLow,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.PWorldSkillGuidancePanel] = {
		BPName = "MainSkillBtn/SkillGuidanceItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.CommTextTipsBigStrongItem] = {
		BPName = "Common/Text/Tips/CommTextTipsBigStrongItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.PWorldQuestMenu] = {
		BPName = "PWorld/PWorldQuestMenuWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		ListToHideOnShow = {UIViewID.TeamRollPanel},
	},

	[UIViewID.SidebarGiveUpTaskWin] = {
		BPName = "SideBar/SidebarGiveUpTaskWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Highest,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.PWorldVoteExpelResult] = {
		BPName = "PWorld/PWorldVoteExpelResultWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Highest,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.PWorldVoteBest] = {
		BPName = "PWorld/PWorldVoteBestWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.PWorldAddMember] = {
		BPName = "PWorld/PWorldAddMemberWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.PWorldMatchDetail] = {
		BPName = "PWorld/PWorldMatchDetailWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		ListToHideOnShow = {UIViewID.ProfessionToggleJobTab},
	},

	[UIViewID.PWorldStageInfoPanel] = {
		BPName = "PWorld/Stage/PWorldStageInfoPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.PWorldConfirm] = {
		BPName = "PWorld/PWorldTeamConfirmPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.BelowHigh,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		ListToHideOnShow = {UIViewID.PWorldMatchDetail, UIViewID.PVPInfoPanel, UIViewID.PVPSeriesMalmstonePanel, UIViewID.PVPOptionListPanel, UIViewID.PVPHonorPanel},
	},

	[UIViewID.EntourageConfirm] = {
		BPName = "Entourage/EntourageConfirmPanel_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.PWorldWarning] = {
		BPName = "PWorld/Warning/WarningBossCDPanel_UIBP",
		ShowType = UIShowType.AboveHigh,
		Layer = UILayer.AboveLow,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.PWorldAreaImageTest] = {
		BPName = "PWorld/PWorldAreaImageTest_UIBP",
		ShowType = UIShowType.AboveHigh,
		Layer = UILayer.AboveLow,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.InfoAreaTipsInCutScene] = {
		BPName = "InfoTips/Text/InfoAreaTips_UIBP", --共用InfoAreaTips_UIBP，但是显示规则不同
		ShowType = UIShowType.Normal,
		Layer = UILayer.Exclusive,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.PWorldBranchPanel] = {
		BPName = "PWorld/Branch/PWorldBranchPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.PWorldBranchWin] = {
		BPName = "PWorld/Branch/PWorldBranchWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.MessageBox] = {
		BPName = "PWorld/MessageBox_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.BelowHigh,
		GCType = ObjectGCType.LRU,
		bCantControlCamera = true,
		bInputModeUIOnly = true,
	},

	[UIViewID.CommonTips] = {
		BPName = "InfoTips/CommonTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Highest,
		GCType = ObjectGCType.Hold,
		DontHideWhenLoadMap = true,
	},

	[UIViewID.ErrorTips] = {
		BPName = "InfoTips/ErrorTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Highest,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.ActiveTips] = {
		BPName = "InfoTips/ActiveTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Highest,
		GCType = ObjectGCType.LRU,
		bAsyncLoad = true,
	},

	[UIViewID.FateTips] = {
		BPName = "InfoTips/FateTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.InfoFateTips] = {
		BPName = "InfoTips/Quest/InfoFateTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.InfoCountdownTipsView] = {
		BPName = "InfoTips/Text/InfoCountdownTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.InfoCountdownTipsForPVPView] = {
		BPName = "InfoTips/Text/InfoCountdownTipsForPVP_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.CommonRunningTips] = {
		BPName = "InfoTips/CommonRunningTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveLow,
		GCType = ObjectGCType.LRU,
		DontHideWhenLoadMap = true,
	},

	[UIViewID.InfoJobNulockTipsView] = {
		BPName = "InfoTips/Job/InfoJobNulockTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Highest,
		GCType = ObjectGCType.LRU,
		ListToHideOnShow = {UIViewID.GMMain},
	},

	[UIViewID.InfoDoubtNulockTips] = {
		BPName = "InfoTips/Job/InfoDoubtNulockTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Exclusive,
		GCType = ObjectGCType.LRU,
		ListToHideOnShow = {UIViewID.GMMain},
	},

	[UIViewID.GatherSkillTip] = {
		BPName = "GatheringJob/GatheringJobSkillTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.GatherChainTips] = {
		BPName = "InfoTips/GatherChainTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	--新版采集面板
	[UIViewID.GatheringJobPanel] = {
		-- BPName = "GatheringJob/GatheringJobPanel_UIBP",
		BPName = "GatheringJob/NewGatheringJobPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.BelowNormal,
		GCType = ObjectGCType.LRU,
		ListToSetVisible = { UIViewID.MainPanel},
	},

	[UIViewID.GatherDrugSkillPanel] = {
		BPName = "GatheringJob/GatherDrugSkillPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveLow,
		GCType = ObjectGCType.LRU,
	},

	--新版采集收藏品面板
	[UIViewID.GatheringJobSkillPanel] = {
		BPName = "GatheringJob/GatheringJobSkillPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.AreaTips] = {
		BPName = "InfoTips/AreaTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.InfoAreaTips] = {
		BPName = "InfoTips/Text/InfoAreaTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.BottomTips] = {
		BPName = "InfoTips/BottomTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.LevelUpTips] = {
		BPName = "InfoTips/Job/InfoJobLevelTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.MissionTips] = {
		BPName = "InfoTips/MissionTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.InfoMissionTips] = {
		BPName = "InfoTips/Text/InfoMissionTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
		bEnableUpdateView = true,
    },

	[UIViewID.QuestInfoTips] = {
		BPName = "InfoTips/Quest/InfoQuestTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.NPCTalkCommon] = {
		BPName = "InfoTips/NPCTalkCommon_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Story,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.NPCTalkTips] = {
		BPName = "InfoTips/NPCTalkTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.NewNPCTalkTips] = {
		BPName = "InfoTips/InfoCountDownNewTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
		bEnableUpdateView = true,
	},

	[UIViewID.InfoTextTips] = {
		BPName = "InfoTips/Text/InfoTextTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
		bEnableUpdateView = true,
	},

	[UIViewID.ActiveSystemErrorTips] = {
		BPName = "InfoTips/ActiveSysteamErrorTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Highest,
		GCType = ObjectGCType.Hold,
		DontHideWhenLoadMap = true,
	},

	[UIViewID.InfoDoubtLevelTips] = {
		BPName = "InfoTips/Job/InfoDoubtLevelTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Exclusive,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.ItemTips] = {
		BPName = "ItemTips/ItemTipsFrameNew_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
	},

	[UIViewID.CurrencyTips] = {
		BPName = "ItemTips/CurrencyTipsFrame_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.ItemTipsStatus] = {
		BPName = "ItemTips/ItemTipsStatusFrame_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.CommGetWayItem] = {
		BPName = "Common/Tips/CommGetWayItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.EquipTips] = {
		BPName = "Equipment/EquipmentDetail_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.DropTips] = {
		BPName = "CommMsg/Msg_DropTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.CommonDropTips] = {
		BPName = "Common/Tips/CommDropTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.TeamApply] = {
		BPName = "Team/Team_ApplyListPanel_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.TeamConfirm] = {
		BPName = "Team/Team_DisbandConfirmTips_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.TeamMenu] = {
		BPName = "Main/Item/MainTeamMenuTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.Hold,
	},

	[UIViewID.TeamInvite] = {
		BPName = "Team/TeamInvitePanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		ListToHideOnShow = {UIViewID.TeamSignsMainPanel, UIViewID.SceneMarkersMainPanel, UIViewID.TeamRollPanel, UIViewID.EmotionMainPanel, UIViewID.ChatMainPanel, UIViewID.BuddyMainPanel, UIViewID.Main2ndPanel},
	},

	[UIViewID.TeamMainPanel] = {
		BPName = "Team/TeamMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		ListToHideOnShow = {UIViewID.TeamSignsMainPanel, UIViewID.SceneMarkersMainPanel, UIViewID.TeamRollPanel, UIViewID.EmotionMainPanel, UIViewID.ChatMainPanel, UIViewID.BuddyMainPanel, UIViewID.Main2ndPanel},
	},

	[UIViewID.TeamCheckPlayerDetail] = {
		BPName = "Team/TeamCheckPlayerDetail_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.TeamAttriAddInfor] = {
		BPName = "Team/TeamAttriAddInfor_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.TeamRecruitEdit] = {
		BPName = "TeamRecruit/TeamRecruitEdit_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		ListToHideOnShow = { UIViewID.ChatMainPanel, }
	},

	[UIViewID.TeamRecruitCode] = {
		BPName = "TeamRecruit/TeamRecruitCode_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.TeamRecruitContentSelect] = {
		BPName = "TeamRecruit/TeamRecruitContentSelect_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.TeamRecruitQuickInput] = {
		BPName = "TeamRecruit/TeamRecruitQuickInput_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.TeamRecruitEditFunc] = {
		BPName = "TeamRecruit/TeamRecruitEditFunc_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.TeamRecruitDetail] = {
		BPName = "TeamRecruit/TeamRecruitDetail_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		ListToHideOnShow = {UIViewID.TeamInvite}
	},

	[UIViewID.TeamRecruitFilter] = {
		BPName = "TeamRecruit/TeamRecruitObjectFiltering",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.TeamRollPanel] = {
		BPName = "Team/TeamRollPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveLow,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = false,
		DontHideWhenLoadMap = true,
		ListToHideOnShow = {UIViewID.TeamSignsMainPanel, UIViewID.SceneMarkersMainPanel, UIViewID.TeamRollValuablesTips}
	},

	[UIViewID.TeamDistributeItem] = {
		BPName = "Team/Item/TeamDistributeItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.TeamRollTreasureBox] = {
		BPName = "Team/TeamRollTreasureBox_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveLow,
		GCType = ObjectGCType.LRU,
		DontHideWhenRevive = true,
	},

	[UIViewID.TeamBeginsCDWin] = {
		BPName = "Team/TeamBeginsCDWin_UIBP",
		ShowType = UIShowType.Tips,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.TeamBeginsCDTips] = {
		BPName = "InfoTips/TeamBeginsCDTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.TeamSignsMainPanel] = {
		BPName = "Signs/SignsMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveLow,
		GCType = ObjectGCType.LRU,
		ListToHideOnShow = {
			UIViewID.ChatMainPanel,
			UIViewID.SceneMarkersMainPanel,
			UIViewID.TeamRollPanel,
			UIViewID.EmotionMainPanel,
			UIViewID.BuddyMainPanel,
			UIViewID.Main2ndPanel,
		},
	},
	[UIViewID.SceneMarkersMainPanel] = {
		BPName = "Signs/SceneMarkersMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveLow,
		GCType = ObjectGCType.LRU,
		ListToHideOnShow = {UIViewID.TeamSignsMainPanel, UIViewID.TeamRollPanel, UIViewID.EmotionMainPanel, UIViewID.TeamRollPanel, UIViewID.ChatMainPanel, UIViewID.BuddyMainPanel, UIViewID.Main2ndPanel},
	},
	[UIViewID.MainTeamChatTip] = {
		BPName = "Main/MainTeamChatTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.TeamRollValuablesTips] = {
		BPName = "Team/TeamRollValuablesTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.BelowNormal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.QTEMain] = {
		BPName = "QTE/QTE_MainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	-- [UIViewID.PWorldMoviePlayer] = {
	-- 	BPName = "PWorld/PWorldMapMoviePanel_UIBP",
	-- 	ShowType = UIShowType.Normal,
	-- 	Layer = UILayer.Exclusive,
	-- 	GCType = ObjectGCType.LRU,
	-- },

	[UIViewID.BeReviveView] = {
		BPName = "PWorld/Death/ReviveTipsBox_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.High,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		DontHideWhenRevive = true,
	},

	[UIViewID.ReviveFloatButton] = {
		BPName = "PWorld/Death/ReviveFloatButton_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveLow,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.BeDeathView] = {
		BPName = "PWorld/Death/DeathTipsBox_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.High,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.DeathFloatButton] = {
		BPName = "PWorld/Death/DeathFloatButton_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveLow,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.CommonMaskPanel] = {
		BPName = "Common/CommonMaskPanel",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Highest,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.CommPlayerHeadSlotItem] = {
		BPName = "Common/Slot/Comm_Player_HeadSlot_Item_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.COmmPlayerProfSlotItem] = {
		BPName = "Common/Slot/Comm_Player_ProfSlot_Item_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.MainUIMoveMask] = {
		BPName = "Main/Item/MainUIMoveMask_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.Hold,
	},

	--[UIViewID.InputPanel] = {
	--	BPName = "Input/InputPanel",
	--	ShowType = UIShowType.Normal,
	--	Layer = UILayer.Input,
	--	GCType = ObjectGCType.LRU,
	--},


	[UIViewID.SpeechBubble] = {
		BPName = "NPC/SpeechBubble_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.SpeechBubblePanel] = {
		BPName = "NPC/SpeechBubblePanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Lowest, -- 气泡防止挡住主界面小地图
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.NpcTalkBubbleItem] = {
		BPName = "NPCTalk/NPCTalk_Bubble_Item_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.InteractiveMainPanel] = {
		BPName = "Interactive/InteractiveMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.Map,
		bAsyncLoad = true
	},

	[UIViewID.FunctionCommonItem] = {
		BPName = "Interactive/FunctionCommonItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.DialogCommonItem] = {
		BPName = "Interactive/New/BubbleBoxCommonItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.FunctionGatherItem] = {
		BPName = "Interactive/FunctionGatherItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.NpcTalkDialoguePanel] = {
		BPName = "NPCTalk/NPCTalk_Dialogue_Panel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.EntranceCommonItem] = {
		BPName = "Interactive/EntranceCommonItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.NpcTalkMainPanel] = {
		BPName = "NPCTalk/NPCTalk_Main_Panel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.NpcTalkTaskTips] = {
		BPName = "NPCTalk/NPCTalk_TaskTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.NpcTalkTopInfoItem] = {
		BPName = "NPCTalk/NPCTalk_TopInfo_Item_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.TATestPanel] = {
		BPName = "Test/TATest_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.FieldTestPanel] = {
		BPName = "Test/FieldTest/FieldTestPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.Map,
		DontHideWhenLoadMap = true,
	},

	[UIViewID.MultiLanguageTestPanel] = {
		BPName = "Test/MultiLanguage/MultiLanguageTestPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.Map,
		DontHideWhenLoadMap = true,
	},

	[UIViewID.FieldTestMinimizationView] = {
		BPName = "Test/FieldTest/TestMinimization_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.Map,
		DontHideWhenLoadMap = true,
	},

	[UIViewID.NarrativeTestPanel] = {
		BPName = "Test/NarrativeTest/NarrativeTestPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.Map,
		DontHideWhenLoadMap = true,
	},

	[UIViewID.MagicCardRulePanelView] = {
		BPName = "Cards/CardChallengeRuleWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal, -- 在打开的需要NORMAL层级，否则在幻卡对局中，查看规则会发生层级问题
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.MagicCardEnterConfirmPanel] = {
		BPName = "Cards/CardsReadinessPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},

	[UIViewID.MagicCardMainPanel] = {
		BPName = "Cards/CardsMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
		bAsyncLoad = true,
	},

	[UIViewID.MagicCardGameFinishPanel] = {
		BPName = "Cards/CardsGameResultPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.MagicCardFirstSeenCardView] = {
		BPName = "Cards/CardRewardWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.MagicCardItemView] = {
		BPName = "MagicCard/MagicCardCardItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.Hold,
	},

	[UIViewID.MagicCardEditGroupView] = {
		BPName = "MagicCard/MagicCardCardEdit_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.MagicCardShowGetWayView] = {
		BPName = "Cards/Item/CardsShowGetWay_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.Hold,
	},

	[UIViewID.MagicCardPrepareMainPanel] = {
		BPName = "Cards/CardsPrepareMainNewPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},

	[UIViewID.MagicCardEditPanel] = {
		BPName = "Cards/CardsEditDecksPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.MagicCardBigCardItem] = {
		BPName = "Cards/Item/CardsBigCardItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.Hold,
	},

	[UIViewID.MagicCardCommMsgBoxView] = {
		BPName = "MagicCard/MagicCardCommMsgBox_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.MagicCardSaveReminderView] = {
		BPName = "MagicCard/MagicCardSaveReminder_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.MagicCardGameRuleView] = {
		BPName = "MagicCard/MagicCardGameRules_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.MagicCardEditGroupNameView] = {
		BPName = "MagicCard/MagicCardEditGroupName_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.MagicCardTourneySignUpView] = {
		BPName = "Cards/CardsTourneyApplicationNewWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.MagicCardCollectionMainPanel] = {
		BPName = "MagicCardCollection/MagicCardMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
	},

	[UIViewID.MagicCardTourneyEffectSelectView] = {
		BPName = "Cards/CardsTourneyStageBuffWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
	},

	[UIViewID.MagicCardTourneyDetailPanel] = {
		BPName = "Cards/CardsTourneyInfoNewWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.MagicCardRewardView] = {
		BPName = "Cards/CardsTourneyFinalSettlementWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.MagicCardStageSettlmentView] = {
		BPName = "Cards/CardsTourneyStageSettlementWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.MagicCardTourneyTipView] = {
		BPName = "Cards/CardsTourneyMissionTipsNew_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.MagicCardTourneyStageTipView] = {
		BPName = "Cards/CardsTourneyTipsNew_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.MagicCardTourneyMatchConfirmView] = {
		BPName = "Cards/CardsTourneyMatching_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.MagicCardTourneyStageDetailView] = {
		BPName = "Cards/CardsTourneyInfoTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.MagicCardTourneyRankView] = {
		BPName = "Cards/CardsTourneyRankNewWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.CollectionAwardPanel] = {
		BPName = "Guide/Item/GuideAwardWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
	},

	[UIViewID.MysterShopMainPanelView] = {
		BPName = "MysterMerchant/MysterMechantMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.MysterMerchantSettlementView] = {
		BPName = "MysterMerchant/Item/MysterMerchantSettlementWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.MysterMerchantBuyPropsWinView] = {
		BPName = "MysterMerchant/Item/MysterMerchantBuyPropsWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.BagMain] = {
		BPName = "NewBag/NewBagMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.BagDrugsSetPanel] = {
		BPName = "NewBag/NewBagMedicineSetWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},

	[UIViewID.BagItemTips] = {
		BPName = "NewBag/BagItemTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.BagDepotRename] = {
		BPName = "NewBag/NewBagRenameWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.BagDepotTransfer] = {
		BPName = "NewBag/NewBagSelectQuantityWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.BagExpandWin] = {
		BPName = "NewBag/NewBagExpandWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.BagItemActionTips] = {
		BPName = "NewBag/NewBagHintWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.BagItemToNQTips] = {
		BPName = "NewBag/NewBagDowngradetWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.BagItemListActionTips] = {
		BPName = "NewBag/NewBagRecycleWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.DepotExpandWin] = {
		BPName = "NewBag/NewBagExpandSetWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.BackpackMain] = {
		BPName = "Backpack/Backpack_MainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.BackpackWareRename] = {
		BPName = "Backpack/Backpack_StoreRename_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.BackpackItemTips] = {
		BPName = "Backpack/BackpackItemTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.QuestLogMainPanel] = {
		BPName = "Quest/NewQuestLog/NewQuestLogMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
		ListToHideOnShow = {UIViewID.TeamSignsMainPanel, UIViewID.SceneMarkersMainPanel, UIViewID.EmotionMainPanel, UIViewID.TeamRollPanel, UIViewID.ChatMainPanel, UIViewID.BuddyMainPanel, UIViewID.Main2ndPanel},
	},

	[UIViewID.QuestAcceptTips] = {
		BPName = "Quest/QuestAccept/QuestAcceptTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.QuestPropPanel] = {
		BPName = "Quest/QuestProp/QuestPropPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveLow,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.NewQuestPropPanel] = {
		BPName = "Quest/NewQuestLog/NewQuestPropPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.CfgMainPanel] = {
		BPName = "SystemConfig/Cfg_MainPanel_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.Hold,
	},

	[UIViewID.StoryTips] = {
		BPName = "InfoTips/ActiveSysteamErrorTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Highest,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.DialogueMainPanel] = {
		BPName = "Story/DialogueMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Exclusive,
		GCType = ObjectGCType.Hold,
		ListToSetVisible = {UIViewID.InfoJobNulockTipsView, UIViewID.CGMovieMainPanel, UIViewID.FashionEvaluationProgressPanel, UIViewID.StoryTips, UIViewID.CommonMsgBox, UIViewID.PowerSavingMode, UIViewID.PVPColosseumIntroduction},
		bInputModeUIOnly = true,
		bIgnoreInReconnect = true,
	},

	[UIViewID.NpcDialogueMainPanel] = {
		BPName = "Story/NpcDialogueMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.Hold,
		bInputModeUIOnly = true,
		ListToSetInvisible = {UIViewID.MainPanel},
		ListToSetVisible = {UIViewID.PWorldMainlinePanel, UIViewID.InteractiveMainPanel, UIViewID.TutorialGestureMainPanel,
		UIViewID.QuestPropPanel, UIViewID.CommEasytoUseView, UIViewID.NewQuestPropPanel, UIViewID.NarrativeTestPanel, UIViewID.ItemTips,
		UIViewID.CommonFadePanel},
		ListToHideOnShow = {UIViewID.CraftingLog, UIViewID.GatheringLogMainPanelView, UIViewID.FishInghole, UIViewID.ProfessionToggleJobTab},
	},

	[UIViewID.DialogHistoryLow] = {
		BPName = "Interactive/New/NPCPlotReviewItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Exclusive,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true
	},

	[UIViewID.StaffRollMainPanel] = {
		BPName = "Story/StaffRollMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Exclusive,
		GCType = ObjectGCType.LRU,
		bIgnoreInReconnect = true,
	},
	[UIViewID.CGMovieMainPanel] = {
		BPName = "Story/CGMovieMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.BelowNormal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bIgnoreInReconnect = true,
	},
	[UIViewID.Story3DEffectPanel] = {
		BPName = "Story/Story3DEffectUI/Story3DEffect_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Exclusive,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.CommonFadePanel] = {
		BPName = "Common/CommonFade_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Highest,
		GCType = ObjectGCType.LRU,
		ListToSetVisible = { UIViewID.InfoAreaTipsInCutScene, UIViewID.SidebarLeft},
		DontHideWhenRevive = true,
		DontHideWhenLoadMap = true,
		bEnableUpdateView = true,
		bInputModeUIOnly = true,
	},

	[UIViewID.ChatMainPanel] = {
		BPName = "Chat/ChatMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.Hold,
		---策划需要空白区域响应摇杆
		--bInputModeUIOnly = true,
		bUnique = true,
		bEnableUpdateView = true,
		bEnableChangeLayer = true,
		bForceGC = true,
		ListToSetVisible = { UIViewID.MainPanel},
		ListToHideOnShow = { UIViewID.ChatNewbieMemberPanel, UIViewID.EmotionMainPanel, UIViewID.BuddyMainPanel, UIViewID.TeamSignsMainPanel, UIViewID.SceneMarkersMainPanel, UIViewID.TeamRollPanel, UIViewID.TeamInvite},
		--ListToSetInvisible = { UIViewID.MagicCardMainPanel } --如果启用了 UIShowType.HideOthers，但是有希望不隐藏的，加这个List
	},

	[UIViewID.ChatSettingPanel] = {
		BPName = "Chat/ChatSettingPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},

	[UIViewID.ChatHyperlinkPanel] = {
		BPName = "Chat/ChatHyperlinkPanel_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	[UIViewID.ChatNewbieMemberPanel] = {
		BPName = "Chat/ChatNewbieMemberPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
		ListToSetVisible = { UIViewID.MainPanel},
	},

	[UIViewID.FishMainPanel] = {
		BPName = "Fish/New/FishMainPanelNew_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.FishReleaseTipsPanel] = {
		BPName = "Fish/New/FishTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.FishBiteBagPanel] = {
		BPName = "Fish/New/Item/FishNewWinItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.FishRarefiedTipsPanel] = {
		BPName = "Fish/New/FishTipsWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.SingBar] = {
		BPName = "Interactive/SingBar_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
	},

	[UIViewID.SingBarQuestUseItem] = {
		BPName = "Interactive/NPCUsedItemSingBar_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
	},

	[UIViewID.SingBarAttuning] = {
		BPName = "Interactive/AttuningSingBar_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		ListToSetVisible = { UIViewID.AutoPathMoveTips },
		ListToSetInvisible = {
			UIViewID.Main2ndPanel,
			UIViewID.EmotionMainPanel,
			UIViewID.TeamInvite,
			UIViewID.FishInghole,
			UIViewID.GatherDrugSkillPanel,
			UIViewID.GatheringLogMainPanelView,
			UIViewID.GateMainCountDownPanel
		},
		ListToHideOnShow = {			
			UIViewID.BagMain,
			UIViewID.WorldMapPanel,
			UIViewID.WorldExploraMainPanel,
			UIViewID.WorldExploraWin,
		}
	},


	[UIViewID.EquipmentMainPanel] = {
		BPName = "Equipment/EquipmentNewMain_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},

	[UIViewID.SkillMainPanel] = {
		BPName = "Skill/SkillMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},

	[UIViewID.CurrencySummary] = {
		BPName = "Equipment/EquipmentCurrencyPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.CurrencyConvertWin] = {
		BPName = "Equipment/CurrencyConvertWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.CameraModify] = {
		BPName = "Equipment/CameraModify_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.EquipmentStrongest] = {
		BPName = "Equipment/EquipmentStrongestSuitTips_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.EquipmentSuitRepair] = {
		BPName = "Equipment/EquipmentRepairWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.EquipmentRepair] = {
		BPName = "Equipment/EquipmentRepair_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	---情感动作主界面（已废弃）
	[UIViewID.EmotionMainPanel] = {
		BPName = "EmoAct/EmoActMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bUnique = true,
		bForceGC = true,
		ListToSetVisible = {
			UIViewID.MainPanel,
			UIViewID.EmotionUsingTips,
			UIViewID.SingBar,
			UIViewID.SingBarAttuning,
		 },
		ListToHideOnShow = {
			UIViewID.ChatMainPanel,
			UIViewID.SceneMarkersMainPanel,
			UIViewID.TeamSignsMainPanel,
			UIViewID.TeamRollPanel,
			UIViewID.TeamInvite
		},
	},

	---情感动作提示
	[UIViewID.EmotionUsingTips] = {
		BPName = "EmoAct/EmoActUsingTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.LRU,
		ListToSetVisible = { UIViewID.CommEasytoUseView},
	},

	---情感动作规则说明
	[UIViewID.EmoActRulesWin] = {
		BPName = "EmoAct/EmoActRulesWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		ListToSetVisible = { UIViewID.EmotionMainPanel},
	},

	[UIViewID.MonsterSkillTest] = {
		BPName = "Test/MonsterSkillTest/MonsterTestPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.LRU,
	},

	--收藏品
	[UIViewID.CollectionPanel] = {
		BPName = "Gather/CollectionMain_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.LRU,
	},

	-- 社交
	[UIViewID.SocialMainPanel] = {
		BPName = "Social/SocialMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		ListToHideOnHide = { UIViewID.CommHelpInfoTipsView }
	},

	--搜索确定按钮
	[UIViewID.CommInputCommitButton] = {
		BPName = "Common/InputBox/CommInputCommitButton_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Highest,
		GCType = ObjectGCType.LRU,
	},

	--好友
	[UIViewID.FriendGroupManageWin] = {
		BPName = "Social/Friend/FriendGroupManageWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.FriendScreenerWin] = {
		BPName = "Social/Friend/FriendScreenerWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	--通讯贝
	[UIViewID.LinkShellCreateWin] = {
		BPName = "Social/LinkShell/LinkShellCreateWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.LinkShellJoinWin] = {
		BPName = "LinkShell/LinkShellJoinWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU
	},
	[UIViewID.LinkShellActivityWin] = {
		BPName = "LinkShell/LinkShellActivityWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU
	},
	[UIViewID.LinkShellRecruitSetWin] = {
		BPName = "LinkShell/LinkShellRecruitSetWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU
	},
	[UIViewID.LinkShellInviteWin] = {
		BPName = "Social/LinkShell/LinkShellInviteWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.LinkShellNewsWin] = {
		BPName = "Social/LinkShell/LinkShellNewsWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.LinkShellManageWin] = {
		BPName = "Social/LinkShell/LinkShellManageWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.LinkShellScreenerWin] = {
		BPName = "Social/LinkShell/LinkShellScreenerWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	--魔晶石
	[UIViewID.MagicsparInlay] = {
		BPName = "Magicspar/MagicsparInlay_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.MagicsparInlayTips] = {
		BPName = "Magicspar/MagicsparRemoveTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.High,
		GCType = ObjectGCType.LRU,
	},

	-- 新的魔晶石界面
	[UIViewID.MagicsparInlayMainPanel] = {
		BPName = "Magicspar/MagicsparInlayMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	[UIViewID.MagicsparSucceedTips] = {
		BPName ="Magicspar/MagicsparSucceedTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.MagicsparSwitchPanel] = {
		BPName = "Magicspar/MagicsparSwitchPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},


	[UIViewID.PWorldExitTaskWin] = {
		BPName = "PWorld/PWorldExitTaskWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.High,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		DontHideWhenRevive = true,
	},

	[UIViewID.CommonMsgBox] = {
		BPName = "Common/Tips/CommMsgBoxNew_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.High,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		DontHideWhenRevive = true,
		DontHideWhenLoadMap = true,
	},

	[UIViewID.CommonMsgBoxMustClick] = {
		BPName = "Common/Tips/CommMsgBoxMustClick_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.High,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		DontHideWhenRevive = true,
		DontHideWhenLoadMap = true,
	},

	[UIViewID.CommonCostBox] = {
		BPName = "Common/Tips/CommCostBox_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.High,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.CommonLongMsgBox] = {
		BPName = "Common/Tips/CommLongMsgBox_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.High,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		DontHideWhenLoadMap = true,
	},

	[UIViewID.CommonPopupInput] = {
		BPName = "Common/Tips/CommPopupInputBox_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.CommonPopupMultiLineInput] = {
		BPName = "Common/Tips/CommPopupMultiLineInputBox_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU
	},

	[UIViewID.CommDropDownListNew] = {
		BPName = "Common/DropDownList/CommDropDownListNew_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	--交互：按键选怪
	[UIViewID.SelectMonsterMainPanel] = {
		BPName = "Interactive/SelectMonsterMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.Hold,
	},

	--天气预报主界面
	[UIViewID.WeatherForecastMainPanel] = {
		BPName = "Weather/WeatherMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.High,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},

	--天气预报界面Tips
	[UIViewID.WeatherForecastTips] = {
		BPName = "Weather/Item/WeatherDetailsItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.High,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	--微彩 二次确认框
	[UIViewID.MiniCactpotJoinMsgBox] = {
		BPName = "MiniCactpot/MiniCactpotJoinTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.High,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	--微彩 主界面
	[UIViewID.MiniCactpotMainFrame] = {
		BPName = "MiniCactpot/MiniCactpotMain_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	--微彩 奖励界面
	[UIViewID.MiniCactpotRewardTip] = {
		BPName = "MiniCactpot/MiniCactpotRewardTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.High,
		GCType = ObjectGCType.LRU,
	},

	----------------- 生产职业相关 begin
	--通用
	[UIViewID.CrafterMainPanel] = {
		BPName = "Crafter/CrafterMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		ListToSetVisible = {
			UIViewID.CrafterAlchemistMainPanel,
			UIViewID.CrafterCarpenterMainPanel,
			UIViewID.CrafterBlacksmithMainPanel,
			UIViewID.CrafterGoldsmithMainPanel,
			UIViewID.CrafterArmorerMainPanel,
			UIViewID.CrafterCulinarianMainPanel,
			UIViewID.CrafterWeaverMainPanel,
			UIViewID.CrafterLeatherworkerMainPanel,
		},
		--ListToSetInvisible = {UIViewID.BagMain, UIViewID.MarketMainPanel, UIViewID.ShopMainPanelView,UIViewID.ShopBuyPropsWinView,UIViewID.CompanySealMainPanelView, UIViewID.CollectablesMainPanelView},
	},


	[UIViewID.CrafterStateTips] = {
		BPName = "Crafter/CrafterStateTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.CrafterSkillTips] = {
		BPName = "Crafter/CrafterSkillTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.CrafterDetailsPanel] = {
		BPName = "Crafter/Item/CrafterHowtoplayWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	--炼金
	[UIViewID.CrafterAlchemistMainPanel] = {
		BPName = "Crafter/Alchemist/CrafterAlchemistMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		-- bInputModeUIOnly = true,
	},

	[UIViewID.CrafterBottleItem] = {
		BPName = "Crafter/Alchemist/CrafterAlchemistBottleItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	--炼金老的临时的界面
	-- [UIViewID.AlchemistMainPanel] = {
	-- 	BPName = "Crafter/Alchemist/AlchemistMain_UIBP",
	-- 	ShowType = UIShowType.Normal,
	-- 	Layer = UILayer.Normal,
	-- 	GCType = ObjectGCType.LRU,
	-- },

	-- 刻木匠主界面
	[UIViewID.CrafterCarpenterMainPanel] = {
		BPName = "Crafter/Carpenter/CrafterCarpenterMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	-- 锻铁匠主界面
	[UIViewID.CrafterBlacksmithMainPanel] = {
		BPName = "Crafter/Blacksmith/CrafterBlacksmithMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	-- 雕金匠主界面
	[UIViewID.CrafterGoldsmithMainPanel] = {
		BPName = "Crafter/Goldsmith/CrafterGoldsmithMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	-- 铸甲匠主界面
	[UIViewID.CrafterArmorerMainPanel] = {
		BPName = "Crafter/Armorer/CrafterArmorerMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	-- 烹调师主界面
	[UIViewID.CrafterCulinarianMainPanel] = {
		BPName = "Crafter/Culinarian/CrafterCulinarianMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	-- 裁衣匠主界面
	[UIViewID.CrafterWeaverMainPanel] = {
		BPName = "Crafter/Weaver/CrafterWeaverMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	-- 裁衣匠拖拽界面
	[UIViewID.CrafterWeaverNeedleItem] = {
		BPName = "Crafter/Weaver/CrafterWeaverNeedleItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	-- 制革匠主界面
	[UIViewID.CrafterLeatherworkerMainPanel] = {
		BPName = "Crafter/Leatherworker/CrafterLeatherworkerMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	----------------- 生产职业相关 end

	--------------------交易所相关 begin
	[UIViewID.MarketMainPanel] = {
		BPName = "Market/MarketMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.MarketOnSaleWin] = {
		BPName = "Market/MarketOnSaleWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.MarketOnSaleRuleWin] = {
		BPName = "Market/MarketOnSaleRuleWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.MarketExchangeWin] = {
		BPName = "Market/MarketExchangeWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.MarketRemoveWin] = {
		BPName = "Market/MarketRemoveWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.MarketSaleSuccessWin] = {
		BPName = "Market/MarketSaleSuccessWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.MarketIncreaseWin] = {
		BPName = "Market/MarketIncreaseWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.MarketBuyWin] = {
		BPName = "Market/MarketBuyWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.MarketRecordWin] = {
		BPName = "Market/MarketRecordWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	--------------------交易所相关 end
	--筛选界面
	[UIViewID.ScreenerWin] = {
		BPName = "Common/Screener/CommScreener_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	--------------------------活动
	[UIViewID.OpsActivityMainPanel] = {
		BPName = "Ops/OpsActivity/OpsActivityMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
		bInputModeUIOnly = true,
	},

	[UIViewID.OpsSeasonActivityPanel] = {
		BPName = "Ops/OpsActivity/OpsAcitivitySeasonPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.OpsActivityTreasureChestBuyItemWinView] = {
		BPName = "Ops/OpsActivity/Item/OpsActivityTreasureChestBuyItemWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.OpsActivityPrizePoolWinView] = {
		BPName = "Ops/OpsActivity/Item/OpsActivityPrizePoolWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
    [UIViewID.OpsActivityUnboxingAnimationItemView] = {
		BPName = "Ops/OpsActivity/Item/OpsActivityUnboxingAnimationItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.CommonVideoPlayerView] = {
		BPName = "Common/CommonVideoPlayer_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.OpsDesertFinePanelPlanWin] = {
		BPName = "Ops/OpsActivity/Item/OpsDesertFinePanelPlanWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.OpsDesertFineRebateTaskWin] = {
		BPName = "Ops/OpsActivity/Item/OpsDesertFineRebateTaskWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.OpsDesertFineShareCodeWin] = {
		BPName = "Ops/OpsActivity/Item/OpsDesertFineShareCouponCodeWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.OpsActivityExchangeListWin] = {
		BPName = "Ops/OpsShopping/OpsShoppingExchangeWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.OpsHalloweenPromPanel] = {
		BPName = "Ops/OpsHalloween/OpsHalloweenPromPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.OpsHalloweenMancrPanel] = {
		BPName = "Ops/OpsHalloween/OpsHalloweenMancrPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.OpsHalloweenGamePanel] = {
		BPName = "Ops/OpsHalloween/OpsHalloweenGamePanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.OpsHalloweenGameWin] = {
		BPName = "Ops/OpsHalloween/OpsHalloweenGameWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.OpsVersionNoticeContentPanelView] = {
		BPName = "Ops/OpsVersionNotice/OpsVersionNoticeContentPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.OpsSeasonAnimView] = {
		BPName = "Main/MainOpsAnim_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	-- 地图
	[UIViewID.MiddleMapPanel] = {
		BPName = "Map/MiddleMapPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.WorldMapPanel] = {
		BPName = "Map/WorldMapMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
		ListToHideOnShow = {UIViewID.EmotionMainPanel},
	},

	[UIViewID.WorldMapSettingPanel] = {
		BPName = "Map/WorldMapSettingPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.WorldMapPlaceMarkerPanel] = {
		BPName = "Map/WorldMapPlaceMarkerPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.WorldMapTransferPanel] = {
		BPName = "Map/WorldMapTransferPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.WorldMapSetMarkPanel] = {
		BPName = "Map/WorldMapSetMarkPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.WorldMapSendMarkWin] = {
		BPName = "Map/WorldMapSendMarkPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.WorldMapMarkerTipsList] = {
		BPName = "Map/WorldMapMarkerTipsList_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.WorldMapMarkerTipsTransfer] = {
		BPName = "Map/WorldMapMarkerTipsTransfer_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.WorldMapMarkerTipsFollow] = {
		BPName = "Map/WorldMapMarkerTipsFollow_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.WorldMapMarkerTipsTarget] = {
		BPName = "Map/WorldMapMarkerTipsTarget_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.WorldMapMarkerTipsChocoboTransport] = {
		BPName = "Map/WorldMapMarkerTipsChocoboTransport_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.TreasureOperatePanel] = {
		BPName = "Treasure/OpenTreasurePanel_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.WorldMapMarkerFateStageInfoPanel] = {
		BPName = "Map/WorldMapMarkerFateStageInfo_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.WorldMapMarkerPlayStyleStageInfo] = {
		BPName = "Map/WorldMapMarkerPlayStyleStageInfo_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.PlayStyleMapWin] = {
		BPName = "PlayStyle/Map/PlayStyleMapWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	-- PVP --
	[UIViewID.PVPColosseumMain] = {
		BPName = "PVP/Colosseum/PVPColosseumMain_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.LRU,
		DontHideWhenRevive = true,
	},

	[UIViewID.PVPColosseumIntroduction] = {
		BPName = "PVP/Colosseum/PVPColosseumIntroduction_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.NoCache,
	},

	[UIViewID.PVPColosseumRecord] = {
		BPName = "PVP/Record/PVPColosseumRecord_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.NoCache,
		bInputModeUIOnly = true,
	},

	[UIViewID.InfoPVPReviveTimeTips] = {
		BPName = "InfoTips/PVPReviveTimeTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Highest,
		GCType = ObjectGCType.NoCache,
		bUnique = true,
	}, -- PVP复活
	-- PVP --

	--冒险系统
	[UIViewID.AdventruePanel] = {
		BPName = "Adventure/AdventureMainPanelNew_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},

	[UIViewID.AdventureCompletionPanel] = {
		BPName = "Adventure/AdventureCompletionWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.AdventrueDetailPanel] = {
		BPName = "Adventure/AdventureJobDetailsPage_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	--公共获得奖励界面
	[UIViewID.CommonRewardPanel] = {
		BPName = "Common/Reward/CommRewardPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	--坐骑系统
	[UIViewID.MountPanel] = {
		BPName = "Mount/MountMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		ListToSetVisible = {UIViewID.SingBarAttuning},
	},
	--坐骑系统
	[UIViewID.MountArchivePanel] = {
		BPName = "Mount/MountArchiveNewPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},

	[UIViewID.MountSpeedPanel] = {
		BPName = "Mount/MountSpeed/MountSpeedMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},

	[UIViewID.MountSpeedWinPanel] = {
		BPName = "Mount/MountSpeed/MountSpeedWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.NoCache,
	},

	[UIViewID.MountCustomMadePanel] = {
		BPName = "Mount/MountCustomMadePanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},

	--时尚配饰
	[UIViewID.OrnamentPanel] = {
		BPName = "FashionDeco/FashionDecoSideFrameWin_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		ListToSetVisible = {UIViewID.SingBarAttuning},
	},
	--传奇武器
	[UIViewID.LegendaryWeaponPanel] = {
		BPName = "LegendaryWeapon/LegendaryWeaponMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	[UIViewID.LegendaryWeaponSystemPopUp] = {
		BPName = "LegendaryWeapon/LegendaryWeaponSystemPopUp_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.LegendaryWeaponCraftPopUp] = {
		BPName = "LegendaryWeapon/LegendaryWeaponCraftPopUp_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.LegendaryWeaponDeBugUI] = {
		BPName = "LegendaryWeapon/LegendaryWeaponDeBugUI_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	--通用留言板
	[UIViewID.MessageBoardPanel] = {
		BPName = "MessageBoard/MessageBoardMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.MessageBoardPublishWin] = {
		BPName = "MessageBoard/MessageBoardPublishWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.High,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	--Fate结算界面
	[UIViewID.FateFinishPanel] = {
		BPName = "Fate/FateFinishNewPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	-- Fate开服活动，企鹅BOSS结算界面
	[UIViewID.FateCelebrateFinishPanel] = {
		BPName = "Common/Reward/CommFateRewardPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	--Fate开服活动结算界面
	[UIViewID.FateActivityResultPanel] = {
		BPName = "Ops/OpsCeremony/OpsCeremonyFateWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	--Fate图鉴主界面
	[UIViewID.FateArchiveMainPanel] = {
		BPName = "FateArchive/FateArchiveMergerPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
		bInputModeUIOnly = true,
	},

	--Fate图鉴，统计界面
	[UIViewID.FateEventStatisticsPanel] = {
		BPName = "FateArchive/FateEventStatisticsNewPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
		ListToSetVisible ={
			UIViewID.FateArchiveMainPanel
		},
		bInputModeUIOnly = true,
	},

	--Fate图鉴，地图进度奖励界面
	[UIViewID.FateArchiveRewardWin] = {
		BPName = "FateArchive/FateArchiveRewardWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	--Fate事件统计详情界面
	[UIViewID.FateEventStatsDetialPanel] = {
		BPName = "FateArchive/FateArchiveInfoNewWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	--Fate物品提交界面
	[UIViewID.FateItemSubmitPanel] = {
		BPName = "Fate/FateItemSubmitPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveLow,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	--Fate活动用的专用情感头顶图标
	[UIViewID.FateEmoTipsPanelView] = {
		BPName = "Fate/FateEmoTips/FateEmoTipsPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Lowest, -- 气泡防止挡住主界面小地图
		GCType = ObjectGCType.LRU,
	},

	-- SDK Test
	[UIViewID.SDKMainPanel] = {
		BPName = "SDK/SDKMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	-- 设置
	[UIViewID.Settings] = {
		BPName = "Settings/SettingsMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.SettingsColor] = {
		BPName = "Settings/SettingsColorWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.SettingsVoiceResPanel] = {
		BPName = "Settings/SettingsVoiceResourcesWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.SettingsPkgDownLoadPanel] = {
		BPName = "Settings/SettingsDownloadWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},
	
	[UIViewID.SettingDropDownListNew] = {
		BPName = "Settings/Item/SettingDropDownList_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.SettingsFPSMode] = {
		BPName = "Settings/SettingsFPSSettingWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},
	
	--省电模式
	[UIViewID.PowerSavingMode] = {
		BPName = "Settings/SettingsPowerSavingMode_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Highest,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	
	-- 充值
	[UIViewID.RechargingBgModelPanel] = {
		BPName = "Recharging/RechargingBgModelPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
	},

	[UIViewID.RechargingMainPanel] = {
		BPName = "Recharging/RechargingMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bEnableUpdateView = true,
		bForceGC = true,
	},

	[UIViewID.RechargingGiftPanel] = {
		BPName = "Recharging/RechargingGiftPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
	},

	[UIViewID.RechargingRewardWin] = {
		BPName = "Recharging/RechargingRewardWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.RechargingServiceWin] = {
		BPName = "Recharging/RechargingServiceWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.RechargingHelpWin] = {
		BPName = "Recharging/RechargingHelpWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.RechargingVoucherWin] = {
		BPName = "Recharging/RechargingVoucherWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.OnlineStatusSettingsPanel] = {
		BPName = "OnlineStatus/OnlineStatusWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.OnlineStatusSettingsTips] = {
		BPName = "OnlineStatus/OnlineStatusInfoTips_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	--个人信息
	[UIViewID.PersonInfoMainPanel] = {
		BPName = "PersonInfoNew/PersonInfoMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},

	[UIViewID.PersonInfoSimplePanel] = {
		BPName = "PersonInfoNew/PersonInfoSimplePanel_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.PersonInfoHeadPanel] = {
		BPName = "PersonInfoNew/PersonInfoHeadEditPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},

	[UIViewID.PersonHeadMainPanel] = {
		BPName = "PersonInfoNew/PersonInfoHeadWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},

	[UIViewID.PersonInfoHeadHistoryPanel] = {
		BPName = "PersonInfoNew/PersonInfoHistoryHeadWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},

	[UIViewID.PersonInfoSetTipsPanel] = {
		BPName = "PersonInfoNew/PersonlnfoSetTips_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},

	[UIViewID.PersonInfoPerferredProfPanel] = {
		BPName = "PersonInfoNew/PersonInfoPerferredProfWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.PersonInfoGameStylePanel] = {
		BPName = "PersonInfo/PersonInfoGameStylePanel_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.PersonInfoHoursPanel] = {
		BPName = "PersonInfo/PersonInfoHoursPanel_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.PersonInfoSignPanel] = {
		BPName = "PersonInfo/PersonInfoSignPanel_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.PersonInfoArmyPanel] = {
		BPName = "PersonInfo/PersonInfoArmyPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.PersonPortraitMainPanel] = {
		BPName = "PersonPortrait/PersonPortraitMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	[UIViewID.PersonPortraitSaveSetWin] = {
		BPName = "PersonPortrait/PersonPortraitSaveSetWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
	},

	[UIViewID.ReportPlayerPanel] = {
		BPName = "Report/ReportPlayerWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.ReportPanel] = {
		BPName = "Report/ReportWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.ReportTips] = {
		BPName = "Report/CommReportTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
	},

	[UIViewID.ProfessionToggleJobTab] = {
		BPName = "Profession/ProfessionToggleJobTab_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
		bUnique = true,
		ListToHideOnShow = {UIViewID.TeamSignsMainPanel, UIViewID.SceneMarkersMainPanel, UIViewID.TeamRollPanel, UIViewID.EmotionMainPanel, UIViewID.BuddyMainPanel},
	},

	--侧边栏
	[UIViewID.SidebarMain] = {
		BPName = "Sidebar/SidebarMainWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveHigh,
		GCType = ObjectGCType.LRU,
		DontHideWhenRevive = true,
	},

	--侧边栏左侧
	[UIViewID.SidebarLeft] = {
		BPName = "Sidebar/SidebarLeftWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.BelowHigh, -- 为了应对sequence下也弹出显示的需求做的
		GCType = ObjectGCType.LRU,
		DontHideWhenLoadMap = true
	},

	[UIViewID.SidebarCommon] = {
		BPName = "Sidebar/SidebarCommonWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveHigh,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.SidebarTeamInvite] = {
		BPName = "Sidebar/SidebarTeamInviteWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.SidebarFishClock] = {
		BPName = "Sidebar/SidebarFishWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.SidebarPrivateChat] = {
		BPName = "Sidebar/SidebarPrivateChatWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveHigh,
		GCType = ObjectGCType.LRU,
		ListToHideOnShow = {UIViewID.SidebarMain},
	},

	[UIViewID.SidePopUpEasyUse] = {
		BPName = "SidePopUp/SidePopUpMainBagWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Highest,
		GCType = ObjectGCType.LRU,
	},



	[UIViewID.CameraSettingsPanel] = {
		BPName = "CameraSettings/CameraSettingsPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.GMCharacterInfo] = {
		BPName = "GM/CharacterInfo/GMCharacterInfo_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.NPCDialogGMPanel] = {
		BPName = "NPC/NPCDialogGMPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	--仙人仙彩
	[UIViewID.JumboCactpotMainPanel] = {
		BPName = "JumboCactpot/JumboCactpotMain_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.JumboCactpotExchangePanel] = {
		BPName = "JumboCactpot/JumboCactpotExchange_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.JumboCactpotBuyerPanel] = {
		BPName = "JumboCactpot/JumboCactpotBuyers_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.JumboCactpotRecordPanel] = {
		BPName = "JumboCactpot/JumboCactpotRecord_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.JumboCactpotNewMainPanel] = {
		BPName = "JumboCactpot/JumboCactpotNewMain_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.JumboCactpotAddChance] = {
		BPName = "JumboCactpot/JumboCactpotAddChance_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.JumboCactpotBuyTipsWin] = {
		BPName = "JumboCactpot/JumboCactpotBuyTipsWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.JumboCactpotBuyWin] = {
		BPName = "JumboCactpot/JumboCactpotBuyWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.JumboCactpotPlate] = {
		BPName = "JumboCactpot/JumboCactpotPlate_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.JumboCactpotGetRewardWin] = {
		BPName = "JumboCactpot/JumboCactpotGetRewardWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.JumboCactpotRewardResume] = {
		BPName = "JumboCactpot/JumboCactpotRewardResume_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.JumboCactpotHistorylottery] = {
		BPName = "JumboCactpot/JumboCactpotHistorylottery_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.JumboCactpotFirstPrize] = {
		BPName = "JumboCactpot/JumboCactpotFirstPrizePanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.JumboCactpotRewardBonusNew] = {
		BPName = "JumboCactpot/JumboCactpotRewardBonusNew_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.JumboCactpotRewardShowWin] = {
		BPName = "JumboCactpot/JumboCactpotRewardShowWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.JumboCactpotGetRewardNewWin] = {
		BPName = "JumboCactpot/JumboCactpotGetRewardNewWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	-- 世界探索
	[UIViewID.WorldExploraMainPanel] = {
		BPName = "WorldExplora/WorldExploraMain_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.WorldExploraWin] = {
		BPName = "WorldExplora/WorldExploraWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	--金碟通用界面
	[UIViewID.GoldSauserOpportunityPanel] = {
		BPName = "Gate/GateOpportunityPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		ListToSetInvisible = {
			UIViewID.NewNPCTalkTips,
			UIViewID.InfoAreaTips,
			UIViewID.SidebarMain
		},
		bInputModeUIOnly = true,
	},
	[UIViewID.GoldSauserMainPanel] = {
		BPName = "Gate/GateMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.Map,
		ListToSetInvisible = { UIViewID.SidebarMain },
	},
	[UIViewID.GoldSauserResultPanel] = {
		BPName = "Gate/GateResultPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.Map,
		bInputModeUIOnly = true,
	},
	[UIViewID.GoldSauserGetRewardWin] = {
		BPName = "Gate/GateRewardWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.Map,
	},
	[UIViewID.GateMainCountDownPanel] = {
		BPName = "Gate/GateMainCountDownPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveLow,
		GCType = ObjectGCType.LRU,
		DontHideWhenRevive = true,
	},

	[UIViewID.PlayStyleCommWin] = {
		BPName = "PlayStyle/PlayStyleCommWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
		bInputModeUIOnly = true,
	},
	[UIViewID.PlayStyleLoadingPanel] = {
		BPName = "PlayStyle/PlayStyleLoadingPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Loading,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.PlayStyleCountDownTips] = {
		BPName = "PlayStyle/Tips/PlayStyleCountDownTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Loading,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.PlayStyleCommRewardWin] = {
		BPName = "PlayStyle/PlayStyleCommRewardWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.PlayStyleSystemTips] = {
		BPName = "PlayStyle/Tips/PlayStyleSystemTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Loading,
		GCType = ObjectGCType.LRU,
	},
	-- 金碟主界面

	[UIViewID.GoldSauserEntranceMainPanel] = {
		BPName = "GoldSauserMainPanel/GoldSauserMainPanelMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	[UIViewID.GoldSauserMainPanelDataWinItem] = {
		BPName = "GoldSauserMainPanel/Item/GoldSauserMainPanelDataWinItem_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.GoldSauserMainPanelTyphonGameItem] = {
		BPName = "GoldSauserMainPanel/Item/GoldSauserMainPanelTyphonGameItem_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.GoldSauserMainPanelExchangeWin] = {
		BPName = "GoldSauserMainPanel/Item/GoldSauserMainPanelExchangeWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.GoldSauserMainPanelBodyguardGameItem] = {
		BPName = "GoldSauserMainPanel/Item/GoldSauserMainPanelBodyguardGameItem_UIBP1",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.GoldSauserInfoCountDownTip] = {
		BPName = "InfoTips/InfoCountDownTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.GoldSaucerMainPanelChallengeNotesWin] = {
		BPName = "GoldSauserMainPanel/Item/GoldSaucerMainPanelChallengeNotesWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},

	[UIViewID.GoldSaucerMainPanelUsingTeleportWin] = {
		BPName = "GoldSauserMainPanel/Item/GoldSaucerMainPanelUsingTeleportWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.GateLeapOfFaithTopInfo] = {
		BPName = "Gate/GateLeapOfFaithTopInfo_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveLow,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.GateLeapOfFaithResultPanel] = {
		BPName = "Gate/GateLeapOfFaithResultPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		ListToHideOnShow = {
			UIViewID.AdventruePanel
		}
	},
	[UIViewID.GoldSauserMainPanelAwardWin] = {
		BPName = "GoldSauserMainPanel/GoldSauserMainPanelAwardWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	-- 金蝶END

	[UIViewID.SystemUnlockSkillPanel] = {
		BPName = "InfoTips/SystemUnlock/SystemUnlockSkillPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.InfoTipsSystemUnlockTips] = {
		BPName = "InfoTips/SystemUnlock/InfoTipsSystemUnlockTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		ListToSetInvisible = {UIViewID.TutorialGuideShowPanel, UIViewID.TutorialEntrancePanel},
	},
	[UIViewID.InfoContentUnlockTips] = {
		BPName = "InfoTips/ContentUnlock/InfoContentUnlockTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	--指导者系统
	[UIViewID.MentorAuthenticationPanel] = {
		BPName = "Mentor/MentorAuthenticationPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		ListToSetVisible = { UIViewID.SpeechBubble,  UIViewID.SpeechBubblePanel },
		bInputModeUIOnly = true,
		--bUnique = true,
	},
	[UIViewID.MentorUpdateNoticePanel] = {
		BPName = "Mentor/MentorUpdateNoticePanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.MentorMainPanel] = {
		BPName = "Mentor/MentorMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		ListToSetVisible = { UIViewID.SpeechBubble,  UIViewID.SpeechBubblePanel  },
		bInputModeUIOnly = true,
		--bUnique = true,
	},
	--- 新手引导
	[UIViewID.TutorialGestureMainPanel] = {
		BPName = "Tutorial/TutorialGestureMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true
	},
	[UIViewID.TutorialGestureBG] = {
		BPName = "Tutorial/TutorialGestureBG_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.TutorialGesturePanel] = {
		BPName = "Tutorial/TutorialGesturePanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.TutorialGuideShowPanel] = {
		BPName = "Tutorial/TutorialGuideShowPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		ListToSetInvisible = {UIViewID.MainPanel},
	},
	[UIViewID.TutorialGuidePanel] = {
		BPName = "Tutorial/TutorialGuidePanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.TutorialGestureMapItem] = {
		BPName = "Tutorial/TutorialGestureMapItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.TutorialGestureFriendItem] = {
		BPName = "Tutorial/TutorialGestureFriendItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.TutorialGestureSecondaryItem] = {
		BPName = "Tutorial/TutorialGestureSecondaryItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.TutorialGestureSelectItem] = {
		BPName = "Tutorial/TutorialGestureSelectItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.TutorialGestureTips1Item] = {
		BPName = "Tutorial/TutorialGestureTips1Item_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.TutorialGestureTips2Item] = {
		BPName = "Tutorial/TutorialGestureTips2Item_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.TutorialEntrancePanel] = {
		BPName = "Tutorial/TutorialEntrancePanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	--推荐任务
	[UIViewID.AdventureRecommendTaskTips] = {
		BPName = "Adventure/AdventureRecommendTaskTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	--GM信息面板
	[UIViewID.GMWeatherInfoPanel] = {
		BPName = "GM/GMWeatherInfo_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	--帮助说明界面
	[UIViewID.HelpInfoLargeWinView] = {
		BPName = "Common/Tips/CommHelpInfoWinL_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.HelpInfoMidWinView] = {
		BPName = "Common/Tips/CommHelpInfoWinM_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	[UIViewID.HelpInfoMenuWinView] = {
		BPName = "Common/Tips/CommHelpInfoWinLMenu_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
    [UIViewID.PWorldInfoWinPopUp] = {
		BPName = "PWorld/PWorldExplainWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	-- [UIViewID.CommInforBtn] = {
	-- 	BPName = "Common/Btn/CommInforBtn_UIBP",
	-- 	ShowType = UIShowType.Normal,
	-- 	Layer = UILayer.Tips,
	-- 	GCType = ObjectGCType.LRU,
	-- },

	-- 浮层提示Tips
	[UIViewID.CommHelpInfoTipsView] = {
		BPName = "Common/Tips/CommHelpInfoTips1_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
	},
	[UIViewID.CommHelpInfoSimpleTipsView] = {
		BPName = "Common/Tips/CommHelpInfoTips4_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.CommHelpInfoTitleTipsView] = {
		BPName = "Common/Tips/CommHelpInfoTips2_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.CommHelpInfoJumpTipsView] = {
		BPName = "Common/Tips/CommHelpInfoTips3_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.CommStorageTipsView] = {
		BPName = "Common/Tips/CommStorageTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.CommGetWayTipsView] = {
		BPName = "Common/Tips/CommGetWayTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.CommJumpWayTitleTipsView] = {
		BPName = "Common/Tips/CommJumpWayTitleTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.CommJumpWayTipsView] = {
		BPName = "Common/Tips/CommJumpWayTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.CommJumpWayIconTipsView] = {
		BPName = "Common/Tips/CommJumpWayIconTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.CommSkillTipsView] = {
		BPName = "Common/Tips/CommSkillTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
		bAsyncLoad = true,
	},
	-- 福利-月卡
	[UIViewID.MonthCardMainPanel] = {
		BPName = "MonthCard/MonthCardNewMain_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
	},

	-- 福利-测试首充
	[UIViewID.FirstRechargingMainPanel] = {
		BPName = "Ops/OpsActivity/OpsActivityFirstChargePanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
	},

	-- 战令
	[UIViewID.BattlePassMainView] = {
		BPName = "BattlePass/BattlePassMain_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
	},
	[UIViewID.BattlePassBuyLevelWin] = {
		BPName = "BattlePass/BattlePassBuyLevelNewWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
	},
	[UIViewID.BattlePassAdvanceView] = {
		BPName = "BattlePass/BattlePassAdvancePanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.BattlePassRewardPanel] = {
		BPName = "BattlePass/BattlePassRewardWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.WorldMapTaskListPanel] = {
		BPName = "NewMap/NewMapTaskListPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.NewMapTaskDetailPanel] = {
		BPName = "NewMap/NewMapTaskDetailPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bEnableUpdateView = true,
	},
	[UIViewID.NewMapTaskTrackingTips] = {
		BPName = "NewMap/Item/NewMapTaskTrackingTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.WorldMapMarkerFocusItem] = {
		BPName = "Map/Item/WorldMapMarkerFocusItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	--新人频道相关界面
	[UIViewID.ChatInvitationWinPanel] = {
		BPName = "Chat/ChatInvitationWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.ChatNoviceExamPagePanel] = {
		BPName = "Chat/ChatNoviceExamPage_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
	},
	[UIViewID.ChatRemoveNewbieChannelWin] = {
		BPName = "Chat/ChatRemoveNewbieChannelWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
	},

	--邮件Mail
	[UIViewID.MailMainView] = {
		BPName = "Mail/MailMain_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},

	-- -- 商城2.0
	-- [UIViewID.StoreMainPanel] = {
	-- 	BPName = "Store/StoreMainPanel_UIBP",
	-- 	ShowType = UIShowType.Normal,
	-- 	Layer = UILayer.Normal,
	-- 	GCType = ObjectGCType.LRU,
	-- 	bInputModeUIOnly = true,
	-- 	bForceGC = true,
	-- },
	-- [UIViewID.StorePropsPage] = {
	-- 	BPName = "Store/StorePropsPage_UIBP",
	-- 	ShowType = UIShowType.Normal,
	-- 	Layer = UILayer.Normal,
	-- 	GCType = ObjectGCType.LRU,
	-- },
	-- [UIViewID.StoreGoodsExpandPage] = {
	-- 	BPName = "Store/StoreGoodsExpandPage_UIBP",
	-- 	ShowType = UIShowType.Normal,
	-- 	Layer = UILayer.Normal,
	-- 	GCType = ObjectGCType.LRU,
	-- },
	[UIViewID.StoreBuyGoodsWin] = {
		BPName = "Store/StoreBuyGoodsWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.StoreBuyPropsWin] = {
		BPName = "Store/StoreBuyPropsWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	-- [UIViewID.StoreNotMatchTips] = {
	-- 	BPName = "Store/StoreNotMatchTips_UIBP",
	-- 	ShowType = UIShowType.Normal,
	-- 	Layer = UILayer.Tips,
	-- 	GCType = ObjectGCType.LRU,
	-- },
	-- 商城3.0
	[UIViewID.StoreNewMainPanel] = {
		BPName = "StoreNew/StoreMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
		-- 幻想药完成编辑界面会跳转到商城，需要隐藏，否则模型展示界面会看到幻想药的UI
		ListToSetInvisible = {UIViewID.LoginRoleName},
	},
	[UIViewID.StoreNewCouponsWin] = {
		BPName = "StoreNew/StoreCouponsWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.StoreNewCommodityExpandPanel] = {
		BPName = "StoreNew/StoreCommodityExpandPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.StoreNewBuyWinPanel] = {
		BPName = "StoreNew/StoreBuyWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.StoreNewBlindBoxDescription] = {
		BPName = "StoreNew/StoreBlindBoxDescription_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	--称号
	[UIViewID.TitleMainPanelView] = {
		BPName = "Title/TitleMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bEnableUpdateView = true,
		bEnableChangeLayer = true,
	},

	--理符任务
	[UIViewID.LeveQuestMainPanel] = {
		BPName = "LeveQuest/LeveQuestMainPanel_UIBP",
        ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
	},

	--理符交纳设置界面
	[UIViewID.LeveQuestPaySettingPanel] = {
		BPName = "LeveQuest/Item/LeveQuestPaySettingsWin_UIBP",
        ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	--成就
	[UIViewID.AchievementMainPanel] = {
		BPName = "Achievement/AchievementMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
		bInputModeUIOnly = true,
	},
	[UIViewID.AchievementDetailWin] = {
		BPName = "Achievement/AchievementDetailWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bEnableUpdateView = true,
		bEnableChangeLayer = true,
	},

	--衣橱
	[UIViewID.WardrobeMainPanel] = {
		BPName = "Wardrobe/WardrobeMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
		bInputModeUIOnly = true,
	},

	[UIViewID.WardrobeAppearancePanel] = {
		BPName = "Wardrobe/WardrobeAppearancePanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.WardrobePresetsPanel] = {
		BPName = "Wardrobe/WardrobePresetsPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.WardrobeUnlockPanel] = {
		BPName = "Wardrobe/WardrobeUnlockPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.WardrobeStainPanel] = {
		BPName = "Wardrobe/WardrobeStainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.WardrobeTips] = {
		BPName = "Wardrobe/Item/WardrobeTipsItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.WardrobeTipsWin] = {
		BPName = "Wardrobe/WardrobeTipsWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.WardrobeProfAppListWin] = {
		BPName = "Wardrobe/Item/WardrobeTipsItem2_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.WardrobeSuitPanel] = {
		BPName = "Wardrobe/WardrobeSuitPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		ListToHideOnShow = {UIViewID.MarketMainPanel}
	},


	-- 赠礼
	[UIViewID.StoreGiftChooseFriendWin] = {
		BPName = "Store/StoreGiftChooseFriendWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.StoreGiftMailWin] = {
		BPName = "Store/StoreGiftMailWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},

	--乐谱播放器
	[UIViewID.MusicPlayerMainPanelView] = {
		BPName = "MusicPlayer/MusicPlayerMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	--乐谱图鉴
	[UIViewID.MusicAtlasMainView] = {
		BPName = "MusicAtlas/MusicAtlasMain_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
		ListToSetInvisible = {UIViewID.GuideMainPanelView},
	},

	--乐谱回想
	[UIViewID.MusicAtlasRevertPanelView] = {
		BPName = "MusicAtlas/MusicAtlasRevertPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
		bUnique = true,
		ListToSetVisible = {UIViewID.MainPanel},
		ListToSetInvisible = {UIViewID.MusicAtlasMainView, UIViewID.GuideMainPanelView},
		ListToHideOnShow = {
			UIViewID.SceneMarkersMainPanel,
			UIViewID.TeamSignsMainPanel,
			UIViewID.TeamRollPanel,
		},
	},

	--商店
	[UIViewID.ShopMainPanelView] = {
		BPName = "Shop/ShopMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bEnableUpdateView = true,
		bForceGC = true,
	},

	[UIViewID.GuideMainPanelView] = {
		BPName = "Guide/GuideMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.ShopSearchPageView] = {
		BPName = "Shop/ShopSearchPage_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		ListToHideOnShow = { UIViewID.ShopSearchResultPanelView },
		ListToSetInvisible = { UIViewID.ShopMainPanelView }
	},

	[UIViewID.ShopSearchResultPanelView] = {
		BPName = "Shop/ShopSearchResultPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		ListToHideOnShow = { UIViewID.ShopSearchPageView }
	},

	[UIViewID.ShopExchangeWinView] = {
		BPName = "Shop/ShopExchangeWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.ShopCurrencyTipsView] = {
		BPName = "Shop/ShopCurrencyTips_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.ShopInletPanelNewView] = {
		BPName = "Shop/ShopInletPanelNew_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.ShopInletPanelView] = {
		BPName = "Shop/ShopInletPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.ShopMainPanelNewView] = {
		BPName = "Shop/ShopMainPanelNew_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
		bEnableChangeLayer = true,
		--bEnableUpdateView = true,
	},

	[UIViewID.ShopBuyPropsWinNewView] = {
		BPName = "Shop/ShopBuyPropsWinNew_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.ShopBuyPropsWinView] = {
		BPName = "Shop/ShopBuyPropsWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		--bEnableChangeLayer = true,
	},

	--活动系统
	[UIViewID.ActivityPanel] = {
		BPName = "Activity/ActivityMain_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.ShopExchangeWinNew] = {
		BPName = "Shop/ShopExchangeWinNew_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	--采集笔记
	[UIViewID.GatheringLogMainPanelView] = {
		BPName = "GatheringLog/GatheringLogMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
		ListToSetInvisible = {UIViewID.GatheringJobPanel},
	},
	[UIViewID.GatheringLogSearchPageView] = {
		BPName = "GatheringLog/GatheringLogSearchPage_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.GatheringLogSetAlarmClockWinView] = {
		BPName = "GatheringLog/GatheringLogSetAlarmClockWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.SearchResultPanelView] = {
		BPName = "GatheringLog/GatheringLogSearchResultPage_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	--收藏品
	[UIViewID.CollectablesMainPanelView] = {
		BPName = "Collectables/CollectablesMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.CollectablesTransactionTipsView] = {
		BPName = "Collectables/CollectablesTransactionTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
	},


	-- 钓鱼笔记, 鱼类图鉴
	[UIViewID.FishGuide] = {
		BPName = "FishNotesNew/FishGuidePanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
	},

	-- 钓鱼笔记, 钓场信息
	[UIViewID.FishInghole] = {
		BPName = "FishNotesNew/FishIngholePanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU
	},
	[UIViewID.FishNotesOtherBait] = {
		BPName = "FishNotesNew/FishIngholeBaitWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU
	},
	[UIViewID.FishNoteClockSetWinView] = {
		BPName = "FishNotes/FishIngholeClockSetWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU
	},
	[UIViewID.FishIngHoleTips] = {
		BPName = "FishNotesNew/FishIngholeTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU
	},
	[UIViewID.FishIngholeInfoWin] = {
		BPName = "FishNotesNew/FishIngholeInfoWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU
	},

	--region 部队系统
	[UIViewID.ArmyPanel] = {
        BPName = "Army/ArmyMainPanel_UIBP",
        ShowType = UIShowType.HideOthers,
        Layer = UILayer.Normal,
        GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
    },
    -- 部队队徽编辑
    [UIViewID.ArmyEmblemEditPanel] = {
        BPName = "Army/ArmySelectBadgeWin_UIBP",
        ShowType = UIShowType.Popup,
        Layer = UILayer.Normal,
        GCType = ObjectGCType.LRU
    },
    [UIViewID.ArmyRuleWinPage] = {
        BPName = "Army/ArmyRuleWin_UIBP",
        ShowType = UIShowType.Popup,
        Layer = UILayer.Normal,
        GCType = ObjectGCType.LRU
    },
    [UIViewID.ArmyEditNoticPanel] = {
        BPName = "Army/ArmyInfoNoticeWin_UIBP",
        ShowType = UIShowType.Popup,
        Layer = UILayer.Normal,
        GCType = ObjectGCType.LRU
    },
    [UIViewID.ArmyEditInfoPanel] = {
        BPName = "Army/ArmyInfoEditorWin_UIBP",
        ShowType = UIShowType.Popup,
        Layer = UILayer.Normal,
        GCType = ObjectGCType.LRU
    },
    [UIViewID.ArmyEditRecruitPanel] = {
        BPName = "Army/ArmyInfoRecruitWin_UIBP",
        ShowType = UIShowType.Popup,
        Layer = UILayer.Normal,
        GCType = ObjectGCType.LRU
    },
    [UIViewID.ArmyInfoTrendsPanel] = {
        BPName = "Army/ArmyInfoTrendsWin_UIBP",
        ShowType = UIShowType.Popup,
        Layer = UILayer.Normal,
        GCType = ObjectGCType.LRU
    },
    [UIViewID.ArmyApplyJoinPanel] = {
        BPName = "Army/ArmyJoinWin_UIBP",
        ShowType = UIShowType.Popup,
        Layer = UILayer.AboveNormal,
        GCType = ObjectGCType.LRU
    },
    [UIViewID.ArmyMemClassSettingPanel] = {
        BPName = "Army/ArmyMemberClassSettingWin_UIBP",
        ShowType = UIShowType.Popup,
        Layer = UILayer.Normal,
        GCType = ObjectGCType.LRU
    },
    [UIViewID.ArmyMemberCategoryChangePanel] = {
        BPName = "Army/ArmyRankListWin_UIBP",
        ShowType = UIShowType.Normal,
        Layer = UILayer.Normal,
        GCType = ObjectGCType.LRU
    },
    [UIViewID.ArmyEditCategoryIconPanel] = {
        BPName = "Army/ArmyRankIconWin_UIBP",
        ShowType = UIShowType.Normal,
        Layer = UILayer.Normal,
        GCType = ObjectGCType.LRU
    },
    [UIViewID.ArmyEditClassNamePanel] = {
        BPName = "Army/ArmyRankNameWin_UIBP",
        ShowType = UIShowType.Popup,
        Layer = UILayer.Normal,
        GCType = ObjectGCType.LRU
    },
	[UIViewID.ArmyDepotPanel] = {
        BPName = "Army/ArmyDepotPanel_UIBP",
        ShowType = UIShowType.Normal,
        Layer = UILayer.Normal,
        GCType = ObjectGCType.LRU
    },
	[UIViewID.ArmyItemTips] = {
        BPName = "Army/ArmyItemTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
    },
	[UIViewID.ArmyDepotRename] = {
		BPName = "Army/ArmyRenameWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.ArmyExpandWin] = {
		BPName = "Army/ArmyExpandWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.ArmyCategoryEditPanel] = {
		BPName = "Army/ArmyMemberClassEditPowerPage_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.ArmySEPanel] = {
		BPName = "Army/ArmySpecialEffectsPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.ArmySEBuyWin] = {
		BPName = "Army/ArmyBuySpecialEffectsWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.ArmyDepotMoneyWin] = {
		BPName = "Army/ArmyStorageTakeoutSpeciesWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.ArmyJoinInfoViewWin] = {
		BPName = "Army/ArmyJoinInfoViewWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
		bEnableUpdateView = true,
	},
	[UIViewID.ArmyEditInformationWin] = {
		BPName = "Army/ArmyEditArmyInformationWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.ArmyInviteWin] = {
		BPName = "Army/ArmyInvitePanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bUnique = true,
	},
	[UIViewID.ArmySelectQuantityWin] = {
		BPName = "Army/ArmySelectQuantityWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bUnique = true,
	},
    --endregion 部队系统
	--region 新人攻略
	[UIViewID.OpsNewbieStrategyLightofEtherWinView] = {
		BPName = "Ops/OpsNewbieStrategy/OpsNewbieStrategyLightofEtherWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.OpsNewBieStrategyCommListWinView] = {
		BPName = "Ops/OpsNewbieStrategy/OpsNewBieStrategyCommListWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.OpsNewbieStrategyBraveryAwardWinView] = {
		BPName = "Ops/OpsNewbieStrategy/OpsNewBieStrategyRewardforCourageWin_UIBP",
        ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.OpsNewbieStrategyHintWinView] = {
		BPName = "Ops/OpsNewbieStrategy/OpsNewbieStrategyHintWin_UIBP",
        ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
    --endregion 新人攻略
	--region CraftingLog
	[UIViewID.CraftingLog] = {
		BPName = "CraftingLog/CraftingLogMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
        bInputModeUIOnly = true
	},
	[UIViewID.CraftingLogSearchPageView] = {
		BPName = "CraftingLog/CraftingLogSearchPage_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.CraftingLogListItemView] = {
		BPName = "CraftingLog/CraftingLogListItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.CraftingLogSetCraftTimesWinView] = {
		BPName = "CraftingLog/CraftingLogSetCraftTimesWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.CraftingLogSimpleWorkPanel] = {
		BPName = "CraftingLog/CraftingLogSimpleWorkPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		ListToHideOnShow = { UIViewID.CraftingLog },
	},
	[UIViewID.CraftingLogShopWin] = {
		BPName = "CraftingLog/CraftingLogShopWin_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true
	},

	--endregion

	--region 风脉泉主界面
	[UIViewID.AetherCurrentMainPanelView] = {
		BPName = "AetherCurrent/AetherCurrentMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	[UIViewID.AetherCurrentTipsPanelView] = {
		BPName = "InfoTips/Text/InfoAetherCurrentTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.AetherCurrentTips02PanelView] = {
		BPName = "AetherCurrent/AetherCurrentTips02Panel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.AetherCurrentMapPanelView] = {
		BPName = "AetherCurrent/AetherCurrentMapPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		ListToSetVisible = {
			UIViewID.FateArchiveMainPanel
		}
	},
	--endregion

	--region 孤树无援主界面
	[UIViewID.OutOnALimbMainPanel] = {
		BPName = "OutOnALimb/OutOnALimbMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		--bAsyncLoad = true,
		bForceGC = true,
	},
	-- 小游戏入口确认
	[UIViewID.OutOnALimbOkWin] = {
		BPName = "OutOnALimb/OutOnALimbOkWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	-- 小游戏再次挑战确认
	[UIViewID.OutOnALimbDoubleWin] = {
		BPName = "OutOnALimb/NewOutOnALimbDoubleWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
	},
	-- 孤树无援结算界面
	[UIViewID.OutOnALimbSettlementPanel] = {
		BPName = "OutOnALimb/OutOnALimbSettlementPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		--ListToHideOnShow = {UIViewID.OutOnALimbMainPanel, UIViewID.OutOnALimbDoubleWin},
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	-- 矿脉探索主界面
	[UIViewID.TheFinerMinerMainPanel] = {
		BPName = "TheFinerMiner/TheFinerMinerMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		--bAsyncLoad = true,
		bForceGC = true,
	},
	-- 矿脉探索结算界面
	[UIViewID.TheFinerMinerSettlementPanel] = {
		BPName = "TheFinerMiner/TheFinerMinerSettlementPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		--ListToHideOnShow = {UIViewID.TheFinerMinerMainPanel, UIViewID.OutOnALimbDoubleWin},
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	-- 莫古抓球机主界面
	[UIViewID.MooglePawMainPanel] = {
		BPName = "GoldSaucerGame/MooglePaw/GoldSaucer_MooglePawMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		--bAsyncLoad = true,
		bForceGC = true,
	},
	-- 莫古抓球机游戏界面
	[UIViewID.MooglePawGamePanel] = {
		BPName = "GoldSaucerGame/MooglePaw/GoldSaucer_MooglePawGamePanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	-- 莫古抓球机结果界面
	[UIViewID.MooglePawResultPanel] = {
		BPName = "GoldSaucerGame/MooglePaw/GoldSaucer_MooglePawResultPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	-- 莫古抓球机入口确认
	[UIViewID.MooglePawOkWin] = {
		BPName = "GoldSaucerGame/MooglePaw/Item/GoldSaucer_MooglePawSmallWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	-- 莫古抓球机再次挑战确认
	[UIViewID.MooglePawDoubleWin] = {
		BPName = "GoldSaucerGame/MooglePaw/Item/GoldSaucer_MooglePawMediumWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	-- 重击吉尔伽什美主界面
	[UIViewID.GoldSaucerCuffMainPanel] = {
		BPName = "GoldSaucerGame/Cuff/GoldSaucer_CuffMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		--bAsyncLoad = true,
		bForceGC = true,
	},
	[UIViewID.GoldSaucerCuffBlowTips] = {
		BPName = "GoldSaucerGame/Cuff/Item/GoldSaucer_CuffBlowTipsItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.GoldSaucerCuffShootingTips] = {
		BPName = "GoldSaucerGame/Cuff/GoldSaucer_CuffShootingTipsItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	-- 怪物投篮
	[UIViewID.GoldSaucerMonsterTossMainPanel] = {
		BPName = "GoldSaucerGame/MonsterToss/GoldSaucer_MonsterTossMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		--bAsyncLoad = true,
	},
	-- 强袭水晶塔主界面
	[UIViewID.CrystalTowerStrikerMainPanel] = {
		BPName = "GoldSaucerGame/CrystalTowerStriker/GoldSaucer_CrystalTowerStrikerMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		--bAsyncLoad = true,
	},
	[UIViewID.GoldSaucerMonsterTossShootingTips] = {
		BPName = "GoldSaucerGame/MonsterToss/Item/GoldSaucer_MonsterTossShootingTipsItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	--endregion

	--region 演奏界面
	[UIViewID.MusicPerformanceMainPanelView] = {
		BPName = "Performance/PerformanceMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = false,
		bForceGC = true,
	},
	[UIViewID.MusicPerformanceSelectPanelView] = {
		BPName = "Performance/PerformanceSelectPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	[UIViewID.MusicPerformanceMetronomeSettingView] = {
		BPName = "Performance/PerformanceMetronomeSettingWin_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	[UIViewID.MusicPerformanceEnsembleMetronmeView] = {
		BPName = "Performance/PerformanceMetronomeEnsembleWin_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.MusicPerformanceEnsembleConfirmView] = {
		BPName = "Performance/PerformanceEnsembleWin_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.MusicPerformanceSettingView] = {
		BPName = "Performance/PerformanceSettingNewWin_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	[UIViewID.MusicPerformanceProtocolView] = {
		BPName = "Performance/PerformanceProtocolWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.MusicPefromanceSongPanelView] = {
		BPName = "Performance/PerformanceSongNewPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	[UIViewID.MusicPefromanceSongDetailPanelView] = {
		BPName = "Performance/PerformanceSongDetailPage_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.PerformanceAssistantPanelView] = {
		BPName = "Performance/PerformanceAssistantNewPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.NoCache,
		bInputModeUIOnly = true,
	},
	[UIViewID.PerformanceAssistantItemView] = {
		BPName = "Performance/Item/PerformanceAssistNewItem_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.PerformanceAssistantPauseWinView] = {
		BPName = "Performance/PerformancePauseWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	--endregion

	--region 预览系统界面
	[UIViewID.PreviewMountView] = {
		BPName = "Preview/PreviewMount_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	[UIViewID.PreviewCompanionView] = {
		BPName = "Preview/PreviewCompanion_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	[UIViewID.PreviewRoleAppearanceView] = {
		BPName = "Preview/PreviewRoleAppearance_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	--endregion

	--region 陆行鸟
	[UIViewID.ChocoboRaceMainView] = {
		BPName = "Chocobo/Race/ChocoboRaceMain_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.ChocoboRaceCountDownView] = {
		BPName = "Chocobo/Race/ChocoboRaceCountDown_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.ChocoboRaceResultPanelView] = {
		BPName = "Chocobo/Race/ChocoboRaceResultPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.ChocoboWordsPanelView] = {
		BPName = "Chocobo/Race/ChocoboWordsPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Exclusive,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.ChocoboRaceNpcChallengeView] = {
		BPName = "Chocobo/Race/ChocoboRaceNpcChallenge_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.ChocoboMainPanelView] = {
		BPName = "Chocobo/Life/ChocoboMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
		ListToSetInvisible = {UIViewID.InteractiveMainPanel},
	},
	[UIViewID.ChocoboGenealogyPanelView] = {
		BPName = "Chocobo/Life/ChocoboGenealogyPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.BelowNormal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	[UIViewID.ChocoboRelationPageView] = {
		BPName = "Chocobo/Life/ChocoboRelationPage_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.ChocoboExchangeRacerPageView] = {
		BPName = "Chocobo/Life/ChocoboExchangeRacerPage_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.ChocoboScreenerView] = {
		BPName = "Chocobo/Life/ChocoboScreener_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.ChocoboInfoPanelView] = {
		BPName = "Chocobo/Life/ChocoboInfoPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	[UIViewID.ChocoboOverviewPanelView] = {
		BPName = "Chocobo/Life/ChocoboOverviewPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	[UIViewID.ChocoboSkillPanelView] = {
		BPName = "Chocobo/Life/ChocoboSkillPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.BelowNormal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	[UIViewID.ChocoboSkillSideWinView] = {
		BPName = "Chocobo/Life/ChocoboSkillSideWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.ChocoboTitleWinView] = {
		BPName = "Chocobo/Life/ChocoboTitleWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.ChocoboSkillDetailTips] = {
		BPName = "Chocobo/Life/ChocoboSkillDetailTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.Hold,
	},
	[UIViewID.ChocoboLevelUpTipsView] = {
		BPName = "Chocobo/Life/ChocoboLevelUpTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.Hold,
		DontHideWhenLoadMap = true,
	},
	[UIViewID.ChocoboCodexArmorPanelView] = {
		BPName = "Chocobo/Codex/ChocoboCodexArmorPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	[UIViewID.ChocoboCodexArmorRewardWinView] = {
		BPName = "Chocobo/Codex/ChocoboCodexArmorRewardWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.ChocoboBorrowPanelView] = {
		BPName = "Chocobo/Mating/ChocoboBorrowPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	[UIViewID.ChocoboBreedPanelView] = {
		BPName = "Chocobo/Mating/ChocoboBreedPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	[UIViewID.ChocoboTransferWinView] = {
		BPName = "Chocobo/Mating/ChocoboTransferWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.ChocoboNewBornPanelView] = {
		BPName = "Chocobo/Mating/ChocoboNewBornPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Exclusive,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.ChocoboNameWinView] = {
		BPName = "Chocobo/Mating/ChocoboNameWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.ChocoboSelectSexView] = {
		BPName = "Chocobo/Life/ChocoboSelectSex_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.ChocoboModelGMPanelView] = {
		BPName = "Chocobo/Life/ChocoboModelGMPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.ChocoboRaceGMTargetInfoView] = {
		BPName = "Chocobo/Race/ChocoboRaceGMTargetInfo_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},
	--endregion

	--region 宠物
	[UIViewID.CompanionListPanel] = {
		BPName = "Companion/CompanionListPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	-- 宠物图鉴
	[UIViewID.CompanionArchivePanel] = {
		BPName = "Companion/CompanionArchivePanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},
	--endregion 宠物

	--region 拍照
	--拍照主界面
	[UIViewID.PhotoMain] = {
		BPName = "Photo/PhotoMain_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		-- bInputModeUIOnly = true,
		bForceGC = true,
		ListToHideOnShow = {
			UIViewID.SceneMarkersMainPanel,
			UIViewID.TeamSignsMainPanel,
			UIViewID.TeamRollPanel,
			UIViewID.Main2ndPanel,
		},
	},

	[UIViewID.PhotoTemplatePanel] = {
		BPName = "Photo/PhotoAddTemplatePanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		-- bInputModeUIOnly = true,
	},

	[UIViewID.PhotoActionPanel] = {
		BPName = "Photo/PhotoActionPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		-- bInputModeUIOnly = true,
	},

	[UIViewID.PhotoEmojiPaenl] = {
		BPName = "Photo/PhotoEmojiPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		-- bInputModeUIOnly = true,
	},

	[UIViewID.PhotoFilterPanel] = {
		BPName = "Photo/PhotoFilterPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		-- bInputModeUIOnly = true,
	},

	[UIViewID.PhotoRolePanel] = {
		BPName = "Photo/PhotoRolePanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		-- bInputModeUIOnly = true,
	},

	[UIViewID.PhotoSetupPanel] = {
		BPName = "Photo/PhotoSetUpPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		-- bInputModeUIOnly = true,
	},

	[UIViewID.PhotoEffectPanel] = {
		BPName = "Photo/PhotoSpecialEffectsPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		-- bInputModeUIOnly = true,
	},

	[UIViewID.PhotoStatePanel] = {
		BPName = "Photo/PhotoStatePanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		-- bInputModeUIOnly = true,
	},

	[UIViewID.PhotoWeatherPanel] = {
		BPName = "Photo/PhotoTimeWeatherPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		-- bInputModeUIOnly = true,
	},

	[UIViewID.PhotoAddTemplate] = {
		BPName = "Photo/PhotoAddTemplateWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
		-- bInputModeUIOnly = true,
	},
	--endregion 拍照

	--region 搭档主界面
	[UIViewID.BuddyMainPanel] = {
		BPName = "Buddy/BuddyMainPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		bForceGC = true,
		GCType = ObjectGCType.LRU,
		bUnique = true,
		ListToSetVisible = {
			UIViewID.MainPanel,
			UIViewID.EmotionUsingTips,
			UIViewID.SingBar,
			UIViewID.SingBarAttuning,
		 },
		ListToHideOnShow = {
			UIViewID.ChatMainPanel,
			UIViewID.SceneMarkersMainPanel,
			UIViewID.TeamSignsMainPanel,
			UIViewID.TeamRollPanel,
			UIViewID.TeamInvite
		},
	},

	[UIViewID.BuddySurfacePanel] = {
		BPName = "Buddy/BuddySurfaceArmorPanel_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
		bInputModeUIOnly = true,
		ListToHideOnShow = { UIViewID.BuddyMainPanel},
	},

	[UIViewID.BuddySurfaceStainWin] = {
		BPName = "Buddy/BuddySurfaceStainWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.BuddySkillDetailTips] = {
		BPName = "Buddy/BuddySkillDetailTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.BuddyUseAccelerateWin] = {
		BPName = "Buddy/BuddyUseAccelerateWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	--endregion

	-- region 寻宝
	[UIViewID.TreasureHuntMainPanel] = {
		BPName = "TreasureHunt/TreasureHuntMain_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
		bEnableUpdateView = true,
	},

	[UIViewID.TreasureHuntSkillPanel] = {
		BPName = "TreasureHunt/TreasureHuntSkillPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveLow,
		DontHideWhenLoadMap = true,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.TreasureHuntBtnItem] = {
		BPName = "TreasureHunt/Item/TreasureHuntBtnItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveLow,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.TreasureHuntFinishPanel] = {
		BPName = "TreasureHunt/TreasureHuntTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.TreasureHuntTransferPanel] = {
		BPName = "TreasureHunt/Item/TreasureHuntTransferWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.TreasureHuntHouseWinPanel] = {
		BPName = "TreasureHunt/TreasureHuntHouseWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.FashionEvaluationLoadingPanel] = {
		BPName = "FashionEvaluation/FashionEvaluationOpeningPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},

	[UIViewID.FashionEvaluationMainPanel] = {
		BPName = "FashionEvaluation/FashionEvaluationMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},

	[UIViewID.FashionEvaluationFittingPanel] = {
		BPName = "FashionEvaluation/FashionEvaluationFittingRoomPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.FashionEvaluationHistoryPanel] = {
		BPName = "FashionEvaluation/FashionEvaluationChallengeRecordPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.FashionEvaluationTrackerPanel] = {
		BPName = "FashionEvaluation/Item/FashionEvaluationFittingRoomWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.FashionEvaluationNPCPanel] = {
		BPName = "FashionEvaluation/FashionEvaluationExpertRatingPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.FashionEvaluationProgressPanel] = {
		BPName = "FashionEvaluation/FashionEvaluationScoringProcessInPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.FashionEvaluationSettlementPanel] = {
		BPName = "FashionEvaluation/FashionEvaluationSettlementPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.FashionEvaluationCelebrationEffectPanel] = {
		BPName = "FashionEvaluation/FashionEvaluationCelebrationMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	--endregion

	--region --光之启程
	[UIViewID.DepartOfLightMainPanel] = {
		BPName = "Departure/DepartureMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveLow,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.DepartOfLightActivityDetailView] = {
		BPName = "Departure/DepartureBannerWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveLow,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.DepartOfLightRecyclePanel] = {
		BPName = "Departure/DepartureWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveLow,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	--endregion

	-- region 理发屋
	[UIViewID.HaircutMainPanel] = {
		BPName = "Haircut/HaircutMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
	},

	[UIViewID.HaircutPreviewPanel] = {
		BPName = "Haircut/HaircutPreviewPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.HaircutWin] = {
		BPName = "Haircut/Item/HaircutWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	--endregion

	[UIViewID.TravelLogPanel] = {
		BPName = "TravelLog/TravelLogMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},

	[UIViewID.ChocoboTransportPanel] = {
		BPName = "Chocobo/Transport/ChocoboTransportMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		ListToSetInvisible = {UIViewID.SidebarMain},
	},

	-- region 探索笔记
	[UIViewID.SightSeeingLogMainView] = {
		BPName = "SightSeeingLog/SightSeeingLogMain_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},

	[UIViewID.SightSeeingLogFinishPopupView] = {
		BPName = "SightSeeingLog/SightSeeingLogFinishPopup_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.SightSeeingLogActChooseView] = {
		BPName = "SightSeeingLog/SightSeeingLogActChoosePanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	-- endRegion 探索笔记

	-- region 足迹系统
	[UIViewID.FootPrintMainPanelView] = {
		BPName = "FootPrint/FootPrintMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		--bForceGC = true,
		--ListToSetVisible = { UIViewID.FootPrintDataPanelView },
		--bAsyncLoad = true,
	},

	[UIViewID.FootPrintDataPanelView] = {
		BPName = "FootPrint/FootPrintDataPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		--bForceGC = true,
		--ListToSetVisible = { UIViewID.FootPrintMainPanelView },
		--bAsyncLoad = true,
	},
	-- endRegion 足迹系统

	[UIViewID.ChocoboTransportTip] = {
		BPName = "Chocobo/Transport/ChocoboTransportTipPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.ChocoboTransportSkill] = {
		BPName = "Chocobo/Transport/ChocoboTransportSkill_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.LRU,
		ListToSetInvisible = {UIViewID.InteractiveMainPanel},
	},

	[UIViewID.ChocoboTransportQuest] = {
		BPName = "Chocobo/Transport/ChocoboTransportQuest_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.LRU,
		ListToSetInvisible = {UIViewID.InteractiveMainPanel},
	},

	[UIViewID.ChocoboFeeDingMainPanelView] = {
		BPName = "NewBieGame/ChocoboFeeDing/ChocoboFeeDingMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.ShowModelPanel] = {
		BPName = "Model/ShowModelPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.SidebarTaskEquipmentWin] = {
		BPName = "Sidebar/SidebarTaskEquipmentWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Highest,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.CommMiniKeypadWin] = {
		BPName = "Common/EditQuantity/CommMiniKeypadWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.CompanySealMainPanelView] = {
		BPName = "CompanySeal/CompanySealMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.CompanySealInfoPanelView] = {
		BPName = "CompanySeal/CompanySealInfoPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.CompanySealPromotionWinView] = {
		BPName = "CompanySeal/Item/CompanySealPromotionWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.CompanySealTransferWinView] = {
		BPName = "CompanySeal/Item/CompanySealTransferWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.CompanySealUnsubmittableWinView] = {
		BPName = "CompanySeal/Item/CompanySealUnsubmittableWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.GrandCompanyTips] = {
		BPName = "CompanySeal/Item/CompanySealJoiningtheArmyItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	------自动寻路 begin----
	[UIViewID.AutoPathMoveTips] = {
		BPName = "AutoPathMove/AutoPathMovePanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Lowest,
		GCType = ObjectGCType.LRU,
		DontHideWhenLoadMap = true,
		bAsyncLoad = true,
	},

	------自动寻路 end----

    [UIViewID.PVPInfoPanel] = {
        BPName = "PVP/PVPInfoPanel_UIBP",
        ShowType = UIShowType.Normal,
        Layer = UILayer.Normal,
        GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
    },

	[UIViewID.PVPSeriesMalmstonePanel] = {
        BPName = "PVP/PVPSeriesMalmstonePanel_UIBP",
        ShowType = UIShowType.Normal,
        Layer = UILayer.Normal,
        GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
		ListToHideOnShow = { UIViewID.PVPInfoPanel },
    },

	[UIViewID.PVPOptionListPanel] = {
        BPName = "PVP/PVPOptionListPanel_UIBP",
        ShowType = UIShowType.Normal,
        Layer = UILayer.Normal,
        GCType = ObjectGCType.LRU,
    },

	[UIViewID.PVPHonorPanel] = {
        BPName = "PVP/PVPHonorPanel_UIBP",
        ShowType = UIShowType.Normal,
        Layer = UILayer.Normal,
        GCType = ObjectGCType.LRU,
    },

	[UIViewID.PVPDuelPanel] = {
        BPName = "PVP/Duel/PVPDuelPanel_UIBP",
        ShowType = UIShowType.Normal,
        Layer = UILayer.Normal,
        GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
    },

	[UIViewID.TouringBandGuidePanelView] = {
		BPName = "TouringBand/TouringBandGuidePanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bForceGC = true,
	},

	[UIViewID.TouringBandFanWinView] = {
		BPName = "TouringBand/TouringBandFanWin_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.TouringBandSupportPanelView] = {
		BPName = "TouringBand/TouringBandSupportPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.TouringBandSupportWinView] = {
		BPName = "TouringBand/TouringBandSupportWin_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.SkillExclusiveProp] = {
		BPName = "MainSkillBtn/SkillExclusivePropBtnPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.NewMainSkill] = {
		BPName = "MainSkillBtn/NewMainSkill_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.UMGVideoPlayerView] = {
		BPName = "UMGVideoPlayer/UMGVideoPlayer_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Low,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.PandoraMainPanelView] = {
		BPName = "Pandora/PandoraMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.NoCache,
	},

	[UIViewID.PandoraActivityPanelView] = {
		BPName = "Pandora/PandoraActivityPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.NoCache,
	},

	------拼装剪影 begin----
	[UIViewID.PuzzleBurritosMainPanel] = {
		BPName = "NewBieGame/Puzzle/PuzzleBurritos/PuzzleBurritosMain_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.PuzzleBurritosMoveBreadView] = {
		BPName = "NewBieGame/Puzzle/PuzzleBurritos/Item/PuzzleBurritosMoveBreadItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.PuzzlePenguinJigsawMainView] = {
		BPName = "NewBieGame/Puzzle/PuzzlePenguinJigsaw/PuzzlePenguinJigsawMain_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.PuzzlePenguinJigsawMoveItemView] = {
		BPName = "NewBieGame/Puzzle/PuzzlePenguinJigsaw/PuzzlePenguinJigsawMoveItem_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	------拼装剪影 end----

	---- 传送网格使用券 -----
	[UIViewID.WorldMapUsePortal] = {
		BPName = "Map/WorldMapUsePortalPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	---- 传送网格使用券End -----

	[UIViewID.InfoMistTips] = {
		BPName = "InfoTips/Text/InfoMistTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.InfoCrystalTips] = {
		BPName = "InfoTips/Text/InfoCrystalTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.InfoPVPColosseumTips] = {
		BPName = "InfoTips/PVPColosseumTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.InfoPVPColosseumTeamTips] = {
		BPName = "InfoTips/PVPColosseumTeamTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.InfoPVPColosseumKillTips] = {
		BPName = "InfoTips/PVPColosseumKillTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Tips,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.HardLockEffect] = {
		BPName = "Eff/HardLockEffect_UIBP",
		GCType = ObjectGCType.Hold,
	},

	[UIViewID.UseRenameCard] = {
		BPName = "NewBag/NewBagChangeNameWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.PersonFormerName] = {
		BPName = "PersonInfoNew/Item/PersonlnfoFormerNameTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.EquipmentExchangeWinView] = {
		BPName = "Equipment/EquipmentExchangeWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.EquipmentSwitchWinView] = {
		BPName = "Equipment/EquipmentSwitchWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.EuipmentImproveWinView] = {
		BPName = "Equipment/EuipmentImproveWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.WeChatPrivilegePanel] = {
		BPName = "PersonInfoNew/PersonInfoprivilegeWin_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.OperationChannelPanel] = {
		BPName = "Main2nd/Main2ndMoreTips_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},

	[UIViewID.CDKeyExchangeView] = {
		BPName = "Settings/SettingsCDKWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.BagTreasureChestWin] = {
		BPName = "NewBag/BagTreasureChestWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.OpsActivityBuyWin] = {
		BPName = "Ops/OpsActivity/Item/OpsActivityBuyWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.OpsWhaleMonutRebatesWin] = {
		BPName = "Ops/OpsActivity/Item/OpsWhaleMonutRebatesWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.OpsSkateboardRebatesWin] = {
		BPName = "Ops/OpsSkateboard/OpsSkateboardRebatesWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.ShareMain] = {
		BPName = "Share/NewShareMainPanel_UIBP.NewShareMainPanel_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
		bForceGC = true,
	},

	[UIViewID.ShareExternalLink] = {
		BPName = "Share/ShareExternalLinkPanel_UIBP.ShareExternalLinkPanel_UIBP",
		ShowType = UIShowType.Popup,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.ShareActivity] = {
		BPName = "Share/ShareActivityPanel_UIBP.ShareActivityPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},

	[UIViewID.ShareReward] = {
		BPName = "Common/Slot/CommBackpack74Slot_UIBP.CommBackpack74Slot_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.MeetTradeMainView] = {
		BPName = "MeetTrade/MeetTradeMain_UIBP.MeetTradeMain_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.MeetTradeExchangeChoosePanel] = {
			BPName = "MeetTrade/MeetTradeExchangeChoosePanel_UIBP.MeetTradeExchangeChoosePanel_UIBP",
			ShowType = UIShowType.Normal,
			Layer = UILayer.AboveNormal,
			GCType = ObjectGCType.LRU,
	},
	[UIViewID.MeetTradeConfirmationView] = {
		BPName = "MeetTrade/MeetTradeConfirmationWin_UIBP.MeetTradeConfirmationWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.AboveNormal,
		GCType = ObjectGCType.LRU,
	},
	--零式排行榜
	[UIViewID.SavageRankMainView] = {
		BPName = "SavageRank/SavageRankMain_UIBP",
		ShowType = UIShowType.HideOthers,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.SavageRankTeamInfoWinView] = {
		BPName = "SavageRank/SavageRankTeamInfoWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.WorldVisitPanel] = {
		BPName = "WorldVisit/WorldVisitMain_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.WorldVisitWinPanel] = {
		BPName = "WorldVisit/WorldVisitWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.TeamTeleportWinPanel] = {
		BPName = "Team/TeamTeleportWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bInputModeUIOnly = true,
	},
	[UIViewID.PromoteLevelUpMainPanel] = {
		BPName = "PWorld/PWorldPromoteWin_UIBP.PWorldPromoteWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.CommEasytoUseView] = {
		BPName = "Common/Frame/CommEasytoUseSidebarPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
		bUnique = true,
		ListToSetVisible = {
			UIViewID.EmotionUsingTips,
			UIViewID.MainPanel,
			UIViewID.ChocoboTransportTip,
			UIViewID.FateEmoTipsPanelView,
			UIViewID.CommonRunningTips,
		},
		ListToHideOnShow = {
			UIViewID.SceneMarkersMainPanel,
			UIViewID.TeamSignsMainPanel,
			UIViewID.TeamRollPanel,
		},
	},
	--光之盛典开服活动
	[UIViewID.OpsCeremonyMainPanelView] = {
		BPName = "Ops/OpsCeremony/OpsCeremonyMainPanel_UIBP.OpsCeremonyMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.OpsCeremonyMysteriousVisitorPanelView] = {
		BPName = "Ops/OpsCeremony/OpsCeremonyMysteriousVisitorPanel_UIBP.OpsCeremonyMysteriousVisitorPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.OpsCermonyPenguinWarsPanelView] = {
		BPName = "Ops/OpsCeremony/OpsCermonyPenguinWarsPanel_UIBP.OpsCermonyPenguinWarsPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.OpsCeremonyCelebrationPanelView] = {
		BPName = "Ops/OpsCeremony/OpsCeremonyCelebrationPanel_UIBP.OpsCeremonyCelebrationPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.OpsCeremonyFateWinView] = {
		BPName = "Ops/OpsCeremony/OpsCeremonyCelebrationPanel_UIBP.OpsCeremonyCelebrationPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.UpgradeMainPanelView] = {
		BPName = "Upgrade/UpgradeMainPanel_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.HotUpdateTest] = {
		BPName = "HotUpdateTest/HotUpdateTest_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	--拉回流活动
	[UIViewID.OpsConcertRecallWinView] = {
		BPName = "Ops/OpsConcert/OpsConcertRecallWin_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
	[UIViewID.PermissionTips] = {
		BPName = "Permission/PermissionTips_UIBP",
		ShowType = UIShowType.Normal,
		Layer = UILayer.Normal,
		GCType = ObjectGCType.LRU,
	},
}

return UIViewConfig
