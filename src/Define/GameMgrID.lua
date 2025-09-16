--
-- Author: anypkvcai
-- Date: 2020-08-05 16:24:39
-- Description:
-- 改成直接用全局表了 不用在通过MgrID来获取了

--[=[
---@class GameMgrID
local GameMgrID = {
	EventMgr = 1,
	TimerMgr = 2,
	GameNetworkMgr = 3,
	UIViewMgr = 4,
	ObjectMgr = 5,
	LoginMgr = 6,
	WorldMsgMgr = 7,
	PWorldMgr = 8,
	SelectTargetMgr = 9,
	HUDMgr = 10,
	MapAreaMgr = 11,
	TipsMgr = 12,
	TeamMgr = 13,
	ActorMgr = 14,
	TargetMgr = 15,
	SkillSeries = 16,
    SkillStorage = 17,
	GMMgr = 18,
	PWorldStageMgr = 19,
	Chat = 20,
	SwitchTarget = 21,
	SkillPreInput = 22,
	Combat = 23,
	SkillCDMgr = 24,
	MainProSkillMgr = 25,
	InputMgr = 26,
	BuglyMgr = 27,
	SkillBuffMgr = 28,
	SkillLogicMgr = 29,
	PWorldTriggerActionExecMgr = 30,
	UIMoveMgr = 31,
	ReviveMgr = 32,
	SkillSingEffectMgr = 33,
	NpcMgr = 34,
	UIViewModelMgr = 35,
	MagicCardMgr = 37,
    SpeechBubbleMgr = 38,
	ScoreMgr = 39,
	ProfMgr = 40,
	NpcDialogMgr = 41,
	BackpackMgr = 42,
	PWorldWarningMgr = 43,
	QuestMgr = 44,
	LootMgr = 45,
}

return GameMgrID
--]=]