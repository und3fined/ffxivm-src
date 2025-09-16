---
--- Author: anypkvcai
--- DateTime: 2021-07-16 19:12
--- Description: 从LuaObject派生的、全局只有一个实例的ViewModel需要配置 其他多个实例的ViewModel通过New来创建
---

--life有："Game" "Account" "Role"	"Level"

-- priority有:   ！！！！！ 注意： lua模块的优先级最好大于1600 ！！！！
-- SuperPrioritizedFirst = 1000,
-- SuperPrioritized = 1200,
-- Prioritized = 1500,
-- Normal = 2000,
-- Late = 2500,
-- SuperLate = 3000,
-- Last = 5000,

---@class UIViewModelConfig
local UIViewModelConfig = {
	{ Name = "U2pmVM", 				Life = "Game", Priority = 2000, 		Path = "U2pm/U2pm/U2pmVM" },
	{ Name = "SampleVM", 				Life = "Game", Priority = 2000, 		Path = "Game/Sample/SampleVM" },
	{ Name = "LoginRoleMainPanelVM", 	Life = "Game", Priority = 2000, 		Path = "Game/LoginRole/LoginRoleMainPanelVM" },
	{ Name = "LoginRoleRaceGenderVM", 	Life = "Game", Priority = 2000, 		Path = "Game/LoginRole/LoginRoleRaceGenderVM" },
	{ Name = "LoginRoleTribePageVM", 	Life = "Game", Priority = 2000, 		Path = "Game/LoginRole/LoginRoleTribePageVM" },
	{ Name = "LoginCreateAvatarVM", 	Life = "Game", Priority = 2000, 		Path = "Game/LoginCreate/LoginCreateAvatarVM" },
	{ Name = "LoginCreateCustomizeVM", 	Life = "Game", Priority = 2000, 		Path = "Game/LoginCreate/LoginCreateCustomizeVM" },
	{ Name = "LoginCreateSaveVM", 	    Life = "Game", Priority = 2000, 		Path = "Game/LoginCreate/LoginCreateSaveVM" },
	{ Name = "LoginRoleBirthdayVM", 	Life = "Game", Priority = 2000, 		Path = "Game/LoginRole/LoginRoleBirthdayVM" },
	{ Name = "LoginRoleGodVM", 			Life = "Game", Priority = 2000, 		Path = "Game/LoginRole/LoginRoleGodVM" },
	{ Name = "LoginRoleProfVM", 		Life = "Game", Priority = 2000, 		Path = "Game/LoginRole/LoginRoleProfVM" },
	{ Name = "LoginRoleSetNameVM", 		Life = "Game", Priority = 2000, 		Path = "Game/LoginRole/LoginRoleSetNameVM" },
	{ Name = "LoginRoleShowPageVM", 	Life = "Game", Priority = 2000, 		Path = "Game/LoginRole/LoginRoleShowPageVM" },
	{ Name = "LoginVM", 				Life = "Game", Priority = 2000, 		Path = "Game/Login/LoginVM" },
	{ Name = "LoginNewVM", 				Life = "Game", Priority = 2000, 		Path = "Game/LoginNew/VM/LoginNewVM" },
	{ Name = "LoadingVM", 				Life = "Game", Priority = 2000, 		Path = "Game/Loading/LoadingVM" },
	{ Name = "ShareVM", 				Life = "Game", Priority = 2000, 		Path = "Game/Share/VM/ShareVM" },
	
	{ Name = "DanmakuVM",        		Life = "Role", Priority = 2000,         Path = "Game/Danmaku/DanmakuVM" },
	{ Name = "MainPanelVM", 			Life = "Role", Priority = 2000, 		Path = "Game/Main/MainPanelVM" },
	{ Name = "TeamVM", 					Life = "Role", Priority = 2000, 		Path = "Game/Team/VM/TeamVM" },
	{ Name = "PVPTeamVM", 				Life = "Role", Priority = 2000, 		Path = "Game/PVP/Team/PVPTeamVM" },
	{ Name = "EquipmentCurrencyVM",		Life = "Role", Priority = 2000, 		Path = "Game/Equipment/VM/EquipmentCurrencyVM"},
	{ Name = "TeamInviteVM", 			Life = "Role", Priority = 2000, 		Path = "Game/Team/VM/TeamInviteVM" },
	{ Name = "TeamRecruitVM", 			Life = "Role", Priority = 2000, 		Path = "Game/TeamRecruit/VM/TeamRecruitVM" },
	{ Name = "TeamRollItemVM", 			Life = "Role", Priority = 2000, 		Path = "Game/Team/VM/TeamRollItemVM" },
	--{ Name = "BackpackMainVM", 			Life = "Role", Priority = 2000, 		Path = "Game/Backpack/BackpackMainVM"},
	--{ Name = "BagVM", 					Life = "Role", Priority = 2000, 		Path = "Game/Bag/BagVM"},
	{ Name = "BagMainVM", 				Life = "Role", Priority = 2000, 		Path = "Game/NewBag/VM/BagMainVM"},
	{ Name = "DepotRenameWinVM", 		Life = "Role", Priority = 2000, 		Path = "Game/NewBag/VM/DepotRenameWinVM"},
	{ Name = "BagExpandWinVM", 		    Life = "Role", Priority = 2000, 		Path = "Game/NewBag/VM/BagExpandWinVM"},
	{ Name = "DepotExpandWinVM", 		Life = "Role", Priority = 2000, 		Path = "Game/NewBag/VM/DepotExpandWinVM"},
	{ Name = "BagMedicineSetWinVM", 	Life = "Role", Priority = 2000, 		Path = "Game/NewBag/VM/BagMedicineSetWinVM"},
	{ Name = "NewBagHintWinVM", 		Life = "Role", Priority = 2000, 		Path = "Game/NewBag/VM/NewBagHintWinVM"},
	{ Name = "NewBagDowngradetWinVM", 	Life = "Role", Priority = 2000, 	Path = "Game/NewBag/VM/NewBagDowngradetWinVM"},
	{ Name = "NewBagRecycleWinVM", 		Life = "Role", Priority = 2000, 		Path = "Game/NewBag/VM/NewBagRecycleWinVM"},
	{ Name = "NewBagSelectQuantityVM", 	Life = "Role", Priority = 2000, 		Path = "Game/NewBag/VM/NewBagSelectQuantityVM"},
	{ Name = "ItemTipsFrameVM",         Life = "Role", Priority = 2000,         Path = "Game/ItemTips/VM/ItemTipsFrameVM"},
	{ Name = "GMVM", 					Life = "Role", Priority = 2000, 		Path = "Game/GM/GMVM"},
	--{ Name = "BagDrugsSetPanelVM", 		Life = "Role", Priority = 2000, 		Path = "Game/Bag/BagDrugsSetPanelVM"},
	{ Name = "SkillDrugVM", 			Life = "Role", Priority = 2000, 		Path = "Game/MainSkillBtn/SkillDrugVM"},
	{ Name = "DepotVM", 				Life = "Role", Priority = 2000, 		Path = "Game/Depot/DepotVM"},
	{ Name = "QuestMainVM", 			Life = "Role", Priority = 2000, 		Path = "Game/Quest/VM/QuestMainVM"},
	{ Name = "ChatVM", 					Life = "Role", Priority = 2000, 		Path = "Game/Chat/ChatVM"},
	{ Name = "MapVM", 					Life = "Role", Priority = 2000, 		Path = "Game/Map/VM/MapVM"},
	{ Name = "WorldMapVM", 				Life = "Role", Priority = 2000, 		Path = "Game/Map/VM/WorldMapVM"},
	{ Name = "ModuleMapContentVM", 		Life = "Role", Priority = 2000, 		Path = "Game/Map/VM/ModuleMapContentVM"},
	{ Name = "FishVM", 					Life = "Role", Priority = 2000, 		Path = "Game/Fish/FishVM"},
	{ Name = "InteractiveMainPanelVM", 	Life = "Role", Priority = 2000, 		Path = "Game/Interactive/MainPanel/InteractiveMainPanelVM"},
	{ Name = "SelectMonsterMainPanelVM",Life = "Role", Priority = 2000, 		Path = "Game/Interactive/SelectMonster/SelectMonsterMainPanelVM"},
	{ Name = "EmoActPanelVM",			Life = "Role", Priority = 2000, 		Path = "Game/EmoAct/EmoActPanelVM"},
	{ Name = "EquipmentVM",				Life = "Role", Priority = 2000, 		Path = "Game/Equipment/VM/EquipmentVM"},
	{ Name = "SequencePlayerVM",		Life = "Role", Priority = 2000, 		Path = "Game/Story/SequencePlayerVM"},
	{ Name = "NpcDialogPlayVM",			Life = "Role", Priority = 2000, 		Path = "Game/Story/NpcDialogPlayVM"},
	{ Name = "NpcDialogHistoryVM",		Life = "Role", Priority = 2000, 		Path = "Game/Interactive/View/New/NpcDialogueHistoryVM"},
	{ Name = "MajorBuffVM",				Life = "Role", Priority = 2000, 		Path = "Game/Buff/VM/MajorBuffVM"},
	{ Name = "MainTargetBuffsVM",		Life = "Role", Priority = 2000, 		Path = "Game/Buff/VM/MainTargetBuffsVM"},
	{ Name = "FriendVM",                Life = "Role", Priority = 2000,         Path = "Game/Social/Friend/FriendVM"},
	{ Name = "LinkShellVM",             Life = "Role", Priority = 2000,         Path = "Game/Social/LinkShell/LinkShellVM"},
	{ Name = "MiniCactpotMainVM", 		Life = "Role", Priority = 2000, 		Path = "Game/MiniCactpot/MiniCactpotMainVM"},
	{ Name = "PWorldEntVM", 			Life = "Role", Priority = 2000, 		Path = "Game/PWorld/Entrance/PWorldEntVM"},
	{ Name = "PWorldMatchVM", 		    Life = "Role", Priority = 2000, 		Path = "Game/PWorld/Match/PWorldMatchVM"},
	{ Name = "PWorldEntDetailVM", 		Life = "Role", Priority = 2000, 		Path = "Game/PWorld/Entrance/PWorldEntDetailVM"},
	{ Name = "PWorldQuestVM", 		    Life = "Role", Priority = 2000, 		Path = "Game/PWorld/Quest/PWorldQuestVM"},
	{ Name = "PWorldTeamVM", 		    Life = "Role", Priority = 2000, 		Path = "Game/PWorld/Team/PWorldTeamVM"},
	{ Name = "PWorldVoteVM", 		    Life = "Role", Priority = 2000, 		Path = "Game/PWorld/Vote/PWorldVoteVM"},
	{ Name = "PWorldEntourageTeamVM",   Life = "Role", Priority = 2000, 		Path = "Game/PWorld/Team/PWorldEntourageTeamVM"},
	{ Name = "PWorldEntourageVM", 		Life = "Role", Priority = 2000, 		Path = "Game/PWorld/Entrance/Entourage/PWorldEntourageVM"},
	{ Name = "WeatherVM", 		    	Life = "Role", Priority = 2000, 		Path = "Game/Weather/WeatherVM"},

	-- 生产职业 制作相关
	{ Name = "AlchemistMainVM", 		Life = "Role", Priority = 2000, 		Path = "Game/Crafter/Alchemist/AlchemistMainVM"},
	{ Name = "CrafterSidebarPanelVM", 	Life = "Role", Priority = 2000, 		Path = "Game/Crafter/CrafterSidebarPanelVM"},
	--
	{ Name = "ShopVM",                  Life = "Role", Priority = 2000,         Path = "Game/Shop/ShopVM"},
	{ Name = "MountVM",				    Life = "Role", Priority = 2000, 		Path = "Game/Mount/VM/MountVM"},
	{ Name = "MountCustomMadeVM",		Life = "Role", Priority = 2000, 		Path = "Game/Mount/VM/MountCustomMadeVM"},
	{ Name = "FashionDecoVM",			Life = "Role", Priority = 2000, 		Path = "Game/FashionDeco/VM/FashionDecoVM"},
	{ Name = "FateVM",                  Life = "Role", Priority = 2000,         Path = "Game/Fate/VM/FateVM"},
	{ Name = "FateArchiveMainVM",       Life = "Role", Priority = 2000,         Path = "Game/FateArchive/VM/FateArchiveMainVM"},
	{ Name = "FateEventStatisticsVM",   Life = "Role", Priority = 2000,         Path = "Game/FateArchive/VM/FateEventStatisticsVM"},
	{ Name = "LegendaryWeaponMainPanelVM",     Life = "Role", Priority = 2000,         Path = "Game/LegendaryWeapon/VM/LegendaryWeaponMainPanelVM"},
	{ Name = "SettingsVM",              Life = "Role", Priority = 2000,         Path = "Game/Settings/VM/SettingsVM"},
	{ Name = "SettingsVoiceResVM", Life = "Role", Priority = 2000,        		Path = "Game/Settings/VM/SettingsVoiceResVM"},
	{ Name = "BoardVM",				    Life = "Role", Priority = 2000, 		Path = "Game/MessageBoard/VM/BoardVM"},
	{ Name = "RechargingBgModelVM",              Life = "Role", Priority = 2000,         Path = "Game/Recharging/VM/RechargingBgModelVM"},
	{ Name = "RechargingMainVM",              Life = "Role", Priority = 2000,         Path = "Game/Recharging/VM/RechargingMainVM"},
	{ Name = "RechargingGiftVM",              Life = "Role", Priority = 2000,         Path = "Game/Recharging/VM/RechargingGiftVM"},
	{ Name = "RechargingRewardVM",              Life = "Role", Priority = 2000,         Path = "Game/Recharging/VM/RechargingRewardVM"},
	{ Name = "RechargingHelpVM",              Life = "Role", Priority = 2000,         Path = "Game/Recharging/VM/RechargingHelpVM"},
	{ Name = "OnlineStatusSettingsVM",  Life = "Role", Priority = 2000,         Path = "Game/OnlineStatus/SettingsVM/OnlineStatusSettingsVM"},
	{ Name = "ProfessionToggleJobVM",              Life = "Role", Priority = 2000,         Path = "Game/Profession/VM/ProfessionToggleJobVM"},
	{ Name = "PersonInfoSetTipsVM", 			Life = "Role", Priority = 2000,         Path = "Game/PersonInfo/VM/PersonInfoSetTipsVM"},
	{ Name = "PersonInfoVM", 			Life = "Role", Priority = 2000,         Path = "Game/PersonInfo/VM/PersonInfoVM"},
	{ Name = "PersonPortraitVM", 		Life = "Role", Priority = 2000,         Path = "Game/PersonPortrait/VM/PersonPortraitVM"},
	{ Name = "PersonPortraitHeadVM", 		Life = "Role", Priority = 2000,         Path = "Game/PersonPortraitHead/VM/PersonPortraitHeadVM"},
	{ Name = "MarketMainVM",              	Life = "Role", Priority = 2000,         		Path = "Game/Market/VM/MarketMainVM"},
	{ Name = "MarketOnSaleWinVM",              	Life = "Role", Priority = 2000,         		Path = "Game/Market/VM/MarketOnSaleWinVM"},
	{ Name = "MarketExchangeWinVM",              	Life = "Role", Priority = 2000,         		Path = "Game/Market/VM/MarketExchangeWinVM"},
	{ Name = "MarketRemoveWinVM",              	Life = "Role", Priority = 2000,         		Path = "Game/Market/VM/MarketRemoveWinVM"},
	{ Name = "MarketBuyWinVM",              	Life = "Role", Priority = 2000,         		Path = "Game/Market/VM/MarketBuyWinVM"},
	{ Name = "MarketRecordWinVM",              	Life = "Role", Priority = 2000,         		Path = "Game/Market/VM/MarketRecordWinVM"},
	{ Name = "SidebarVM", 				Life = "Role", Priority = 2000,         Path = "Game/Sidebar/VM/SidebarVM"},
	{ Name = "CommScreenerVM",              	Life = "Role", Priority = 2000,         		Path = "Game/Common/Screener/CommScreenerVM"},
	{ Name = "GatheringJobPanelVM",     Life = "Role", Priority = 2000,         Path = "Game/GatheringJob/GatheringJobPanelVM"},
	{ Name = "GatheringJobSkillPanelVM",     Life = "Role", Priority = 2000,         Path = "Game/GatheringJob/GatheringJobSkillPanelVM"},
	{ Name = "GateMainVM",     			Life = "Role", Priority = 2000,         Path = "Game/Gate/View/VM/GateMainVM"},
	{ Name = "EquipmentMainVM",     			Life = "Role", Priority = 2000,         Path = "Game/Equipment/VM/EquipmentMainVM"},
	{ Name = "BuddyMainVM",              	Life = "Role", Priority = 2000,         		Path = "Game/Buddy/VM/BuddyMainVM"},
	{ Name = "BuddySurfaceVM",              	Life = "Role", Priority = 2000,         		Path = "Game/Buddy/VM/BuddySurfaceVM"},
	{ Name = "BuddySurfaceStainVM",              	Life = "Role", Priority = 2000,         		Path = "Game/Buddy/VM/BuddySurfaceStainVM"},
	{ Name = "BuddyUseAccelerateWinVM",              	Life = "Role", Priority = 2000,         		Path = "Game/Buddy/VM/BuddyUseAccelerateWinVM"},
	{ Name = "JumboCactpotExchangeItemVM",          Life = "Role", Priority = 2000,         Path = "Game/JumboCactpot/JumboCactpotExchangeItemVM"},
	{ Name = "MentorMainPanelVM",                   Life = "Role", Priority = 2000,         Path = "Game/Mentor/MentorMainPanelVM"},
	{ Name = "TutorialGuidePanelVM",				Life = "Role", Priority = 2000,         Path = "Game/Tutorial/VM/TutorialGuidePanelVM"},
	{ Name = "TeamDistributeItemVM",				Life = "Role", Priority = 2000,         Path = "Game/Team/VM/TeamDistributeItemVM"},
	{ Name = "ChatNoviceExamPageVM",				Life = "Role", Priority = 2000,         Path = "Game/Chat/VM/ChatNoviceExamPageVM"},
	{ Name = "MailMainVM",							Life = "Role", Priority = 2000,         Path = "Game/Mail/View/MailMainVM"},
	{ Name = "TitleMainPanelVM",					Life = "Role", Priority = 2000,         Path = "Game/Title/View/TitleMainPanelVM"},
	{ Name = "StoreMainVM",							Life = "Role", Priority = 2000,         Path = "Game/Store/VM/StoreMainVM"},
	{ Name = "StoreGiftMailVM",						Life = "Role", Priority = 2000,         Path = "Game/Store/VM/StoreGiftMailVM"},
	{ Name = "StoreBuyWinVM",						Life = "Role", Priority = 2000,         Path = "Game/Store/VM/StoreBuyWinVM"},

	{ Name = "AchievementMainPanelVM",				Life = "Role", Priority = 2000,         Path = "Game/Achievement/VM/AchievementMainPanelVM"},

	{ Name = "WardrobeMainPanelVM",					Life = "Role", Priority = 2000,         Path = "Game/Wardrobe/VM/WardrobeMainPanelVM"},
	{ Name = "WardrobeUnlockPanelVM",				Life = "Role", Priority = 2000,         Path = "Game/Wardrobe/VM/WardrobeUnlockPanelVM"},


	{ Name = "ActivityVM",                Life = "Role", Priority = 2000,         Path = "Game/Activity/ActivityVM"},
	{ Name = "OpsActivityMainVM",              	Life = "Role", Priority = 2000,         		Path = "Game/Ops/VM/OpsActivityMainVM"},
	{ Name = "OpsActivityTreasureChestPanelVM",              	Life = "Role", Priority = 2000,         		Path = "Game/Ops/VM/OpsActivityTreasureChestPanelVM"},

	{ Name = "GatheringLogVM",              Life = "Role", Priority = 2000,         Path = "Game/GatheringLog/GatheringLogVM"},
	{ Name = "JumboCactpotVM",              Life = "Role", Priority = 2000,         Path = "Game/JumboCactpot/JumboCactpotVM"}, 
	{ Name = "WorldExploraVM",              Life = "Role", Priority = 2000,         Path = "Game/WorldExplora/WorldExploraVM"},
	{ Name = "AetheryteticketVM",              Life = "Role", Priority = 2000,         Path = "Game/Aetheryteticket/AetheryteticketVM"},
	{ Name = "CollectablesVM",                  Life = "Role", Priority = 2000,         Path = "Game/Collectables/CollectablesVM"},
	{ Name = "GoldSauserVM",                  Life = "Role", Priority = 2000,         Path = "Game/Gate/GoldSauserVM"},


	-- 部队系统
	{ Name = "ArmyMainVM",                  Life = "Role", Priority = 2000,         Path = "Game/Army/VM/ArmyMainVM"},
	{ Name = "ArmyRenameWinVM", 		Life = "Role", Priority = 2000, 		Path = "Game/Army/VM/ArmyRenameWinVM"},
	{ Name = "ArmyExpandWinVM", 		    Life = "Role", Priority = 2000, 		Path = "Game/Army/VM/ArmyExpandWinVM"},
	--region 金碟主界面
	{ Name = "GoldSauserMainPanelMainVM",                   Life = "Role", Priority = 2000,         Path = "Game/GoldSauserMainPanel/VM/GoldSauserMainPanelMainVM"},
	--endregion 金碟主界面
	-- 新人攻略主界面
	{ Name = "OpsNewbieStrategyPanelVM",                  Life = "Role", Priority = 2000,         Path = "Game/Ops/VM/OpsNewbieStrategy/OpsNewbieStrategyPanelVM"},

	-- 风脉泉系统
	{ Name = "AetherCurrentsVM",   Life = "Role", Priority = 2000,    Path = "Game/AetherCurrent/AetherCurrentsVM"},
	-- 金碟小游戏
	{ Name = "MiniGameVM",   Life = "Role", Priority = 2000,    Path = "Game/GoldSaucerMiniGame/MiniGameVM"},

	-- 幻卡图鉴
	{ Name = "MagicCardCollectionVM",   Life = "Role", Priority = 2000,    Path = "Game/MagicCardCollection/VM/MagicCardCollectionVM"},
	-- 钓鱼笔记
	{ Name = "FishGuideVM",             Life = "Role", Priority = 2000,         Path = "Game/FishNotes/FishGuideVM"},
	{ Name = "FishIngholeVM",           Life = "Role", Priority = 2000,         Path = "Game/FishNotes/FishIngholeVM"},
	{ Name = "FishNotesClockSetWindVM", Life = "Role", Priority = 2000,         Path = "Game/FishNotes/FishNotesClockSetWindVM"},

	-- 幻卡大赛
	{ Name = "MagicCardTourneyVM", Life = "Role", Priority = 2000,         Path = "Game/MagicCardTourney/VM/MagicCardTourneyVM"},
	--神秘商人
	{ Name = "MysterMerchantVM", Life = "Role", Priority = 2000,         Path = "Game/MysterMerchant/VM/MysterMerchantVM"},

	-- 制作笔记
	{ Name = "CraftingLogVM",  			Life = "Role", Priority = 2000,         Path = "Game/CraftingLog/CraftingLogVM"},
	{ Name = "CraftingLogSetCraftTimesWinVM",  			Life = "Role", Priority = 2000,         Path = "Game/CraftingLog/CraftingLogSetCraftTimesWinVM"},
	{ Name = "CraftingLogSimpleCraftWinVM",  			Life = "Role", Priority = 2000,         Path = "Game/CraftingLog/CraftingLogSimpleCraftWinVM"},
	{ Name = "CraftingLogShopWinVM",  			Life = "Role", Priority = 2000,         Path = "Game/CraftingLog/CraftingLogShopWinVM"},

	--region 陆行鸟
	{ Name = "ChocoboRaceMainVM",                   Life = "Role", Priority = 2000,         Path = "Game/Chocobo/Race/VM/ChocoboRaceMainVM"},
	{ Name = "ChocoboMainVM",                  		Life = "Role", Priority = 2000,         Path = "Game/Chocobo/Life/VM/ChocoboMainVM"},
	{ Name = "ChocoboCodexArmorPanelVM",            Life = "Role", Priority = 2000,         Path = "Game/Chocobo/Codex/VM/ChocoboCodexArmorPanelVM"},
	{ Name = "ChocoboBorrowPanelVM",            Life = "Role", Priority = 2000,         Path = "Game/Chocobo/Mating/VM/ChocoboBorrowPanelVM"},
	--endregion 陆行鸟

	--region 寻宝
	{ Name = "TreasureHuntMainVM",             Life = "Role", Priority = 2000,         Path = "Game/TreasureHunt/VM/TreasureHuntMainVM"},
	{ Name = "TreasureHuntSkillPanelVM",       Life = "Role", Priority = 2000,         Path = "Game/TreasureHunt/VM/TreasureHuntSkillPanelVM"},
	{ Name = "TreasureHuntHouseWinVM",         Life = "Role", Priority = 2000,         Path = "Game/TreasureHunt/VM/TreasureHuntHouseWinVM"},
	--endregion 寻宝

	-- 宠物
	{ Name = "CompanionVM",			Life = "Role", Priority = 2000, 		Path = "Game/Companion/VM/CompanionVM"},
	-- 预警
	{ Name = "PWorldStagePanelVM",	Life = "Role", Priority = 2000, 		Path = "Game/PWorld/Warning/PWorldStagePanelVM"},

	-- 演奏
	{ Name = "MusicPerformanceVM",			Life = "Level", Priority = 2000, 		Path = "Game/MusicPerformance/MusicPerformanceVM"},
	--endregion GroupB

	--region 时尚品鉴
	{ Name = "FashionEvaluationsVM",             Life = "Role", Priority = 2000,         Path = "Game/FashionEvaluation/VM/FashionEvaluationVM"},
	--endregion 时尚品鉴s

	--region 光之启程
	{ Name = "DepartOfLightVM",             Life = "Role", Priority = 2000,         Path = "Game/Departure/VM/DepartOfLightVM"},
	--endregion 光之启程

	-- 足迹系统
	{ Name = "FootPrintVM",   Life = "Role", Priority = 2000,    Path = "Game/FootPrint/FootPrintVM"},

	-- 探索笔记
	{ Name = "DiscoverNoteVM",   Life = "Role", Priority = 2000,    Path = "Game/SightSeeingLog/DiscoverNoteVM"},
	-- 拍照
	{ Name = "PhotoVM",				Life = "Role", 	Priority = 2000, 	Path = "Game/Photo/PhotoVM"},
	{ Name = "PhotoCamVM",			Life = "Role", 	Priority = 2000, 	Path = "Game/Photo/VM/PhotoCamVM"},
	{ Name = "PhotoFilterVM",		Life = "Role", 	Priority = 2000, 	Path = "Game/Photo/VM/PhotoFilterVM"},
	{ Name = "PhotoDarkEdgeVM",		Life = "Role", 	Priority = 2000, 	Path = "Game/Photo/VM/PhotoDarkEdgeVM"},
	{ Name = "PhotoRoleStatVM",		Life = "Role", 	Priority = 2000, 	Path = "Game/Photo/VM/PhotoRoleStatVM"},
	{ Name = "PhotoRoleSettingVM",	Life = "Role", 	Priority = 2000, 	Path = "Game/Photo/VM/PhotoRoleSettingVM"},
	{ Name = "PhotoSceneVM",		Life = "Role", 	Priority = 2000, 	Path = "Game/Photo/VM/PhotoSceneVM"},
	{ Name = "PhotoTemplateVM",		Life = "Role", 	Priority = 2000, 	Path = "Game/Photo/VM/PhotoTemplateVM"},
	{ Name = "PhotoActionVM",		Life = "Role", 	Priority = 2000, 	Path = "Game/Photo/VM/PhotoActionVM"},
	{ Name = "PhotoEmojiVM",		Life = "Role", 	Priority = 2000, 	Path = "Game/Photo/VM/PhotoEmojiVM"},

	-- 目标标记
	{ Name = "SignsMainVM",			Life = "Role", 	Priority = 2000, 	Path = "Game/Signs/VM/SignsMainVM"},
	-- 场景标记
	{ Name = "SceneMarkersMainVM",	Life = "Role", 	Priority = 2000, 	Path = "Game/Signs/VM/SceneMarkersMainVM"},
	-- 副本教学
	{ Name = "TeachingVM", 			Life = "Role", 	Priority = 2000, 	Path = "Game/Pworld/Teaching/TeachingVM"},
	{ Name = "TeachingContentVM", 	Life = "Role", 	Priority = 2000, 	Path = "Game/Pworld/Teaching/TeachingContentVM"},

	-- 便捷使用
	{ Name = "SidePopUpMainBagVM",   Life = "Role", Priority = 2000,    Path = "Game/SidePopUp/VM/SidePopUpMainBagVM"},

	-- 任务提示
	{ Name = "InfoQuestTipsVM",   	Life = "Role", Priority = 2000,    	Path = "Game/InfoTips/Quest/InfoQuestTipsVM"},

	-- 战斗开始倒计时
	{ Name = "TeamBeginCDTipsVM",	Life = "Role", 	Priority = 2000, 	Path = "Game/InfoTips/TeamBeginCDTipsVM"},
	-- 拼装剪影
	{ Name = "PuzzleBurritosVM",              Life = "Role", Priority = 2000,         Path = "Game/NewBieGame/Puzzle/PuzzleBurritos/PuzzleBurritosVM"},

	-- 专属道具任务
	{ Name = "ExclusiveBattleQuestVM",              Life = "Role", Priority = 2000,         Path = "Game/ExclusiveBattleQuest/VM/ExclusiveBattleQuestVM"},

	-- 对战资料
	{ Name = "PVPInfoVM",              Life = "Role", Priority = 2000,         Path = "Game/PVP/VM/PVPInfoVM"},

    -- PVP水晶冲突
	{ Name = "PVPColosseumHeaderVM",   Life = "Role", Priority = 2000,         Path = "Game/PVP/Colosseum/VM/PVPColosseumHeaderVM"},
	{ Name = "PVPColosseumBattleLogVM",   Life = "Role", Priority = 2000,         Path = "Game/PVP/Colosseum/VM/PVPColosseumBattleLogVM"},
	{ Name = "PVPColosseumRecordVM",   Life = "Role", Priority = 2000,         Path = "Game/PVP/Record/VM/PVPColosseumRecordVM"},

	-- 自选宝箱
	{ Name = "TreasureChestVM",     Life = "Role", Priority = 2000,         Path = "Game/TreasureChest/VM/TreasureChestVM"},

	---面对面交易
	{ Name = "MeetTradeVM",     Life = "Role", Priority = 2000,         Path = "Game/MeetTrade/VM/MeetTradeVM"},
	{ Name = "MeetTradeBagMainVM",     Life = "Role", Priority = 2000,         Path = "Game/MeetTrade/VM/MeetTradeBagMainVM"},

	-- 主界面右上角功能区
	{ Name = "MainFunctionPanelVM",    Life = "Role", Priority = 2000,         Path = "Game/Main/FunctionPanel/MainFunctionPanelVM"},
	-- 主界面仇恨列表
	{ Name = "MainEnmityPanelVM",    Life = "Role", Priority = 2000,         Path = "Game/Main/EnmityPanel/MainEnmityPanelVM"},

	-- 决斗
	{ Name = "PVPDuelVM",              Life = "Role", Priority = 2000,         Path = "Game/PVP/Duel/VM/PVPDuelVM"},
	-- 升级途径
	{ Name = "PromoteLevelUpVM",       Life = "Role", Priority = 2000,         Path = "Game/PromoteLevelUp/PromoteLevelUpVM"},
	-- 技能Tips
	{ Name = "CommSkillTipsVM",        Life = "Role", Priority = 2000,         Path = "Game/Common/Tips/VM/CommSkillTipsVM" },
	-- 预览
	{ Name = "PreviewRoleAppearanceVM",	Life = "Role", Priority = 2000,         Path = "Game/Preview/VM/PreviewRoleAppearanceVM"},

	{ Name = "MainControlPanelVM",        Life = "Role", Priority = 2000,         Path = "Game/Main/VM/MainControlPanelVM" },

	{ Name = "BattlePassMainVM",        Life = "Role", Priority = 2000,         Path = "Game/BattlePass/VM/BattlePassMainVM" },
}

return UIViewModelConfig