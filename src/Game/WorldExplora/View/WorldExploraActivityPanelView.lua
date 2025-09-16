---
--- Author: Administrator
--- DateTime: 2025-03-17 20:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

local ProtoRes = require("Protocol/ProtoRes")

--local WilderExploreMainCfg = require("TableCfg/WilderExploreMainCfg")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

local WorldExploraMgr = require("Game/WorldExplora/WorldExploraMgr")
local WorldExploraVM = require("Game/WorldExplora/WorldExploraVM")
local WorldExploraDefine = require("Game/WorldExplora/WorldExploraDefine")

local LSTR = _G.LSTR
local Wilder_Explore_GameType = ProtoRes.Wilder_Explore_GameType
local TabType = WorldExploraDefine.TabType
---@class WorldExploraActivityPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field BtnClick_1 UFButton
---@field BtnClick_2 UFButton
---@field ImgLock UFImage
---@field ImgLock_1 UFImage
---@field ImgLock_2 UFImage
---@field ImgRaceIcon UFImage
---@field PanelTips UFCanvasPanel
---@field PanelTips_1 UFCanvasPanel
---@field TextJoinTimes UFTextBlock
---@field TextJoinTimes_1 UFTextBlock
---@field TextJoinTimes_2 UFTextBlock
---@field TextLevel UFTextBlock
---@field TextName UFTextBlock
---@field TextName_1 UFTextBlock
---@field TextName_2 UFTextBlock
---@field TextNumber UFTextBlock
---@field TextOwn UFTextBlock
---@field TextRace UFTextBlock
---@field TextRecommend UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldExploraActivityPanelView = LuaClass(UIView, true)

function WorldExploraActivityPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClick = nil
	--self.BtnClick_1 = nil
	--self.BtnClick_2 = nil
	--self.ImgLock = nil
	--self.ImgLock_1 = nil
	--self.ImgLock_2 = nil
	--self.ImgRaceIcon = nil
	--self.PanelTips = nil
	--self.PanelTips_1 = nil
	--self.TextJoinTimes = nil
	--self.TextJoinTimes_1 = nil
	--self.TextJoinTimes_2 = nil
	--self.TextLevel = nil
	--self.TextName = nil
	--self.TextName_1 = nil
	--self.TextName_2 = nil
	--self.TextNumber = nil
	--self.TextOwn = nil
	--self.TextRace = nil
	--self.TextRecommend = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldExploraActivityPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldExploraActivityPanelView:OnInit()
	self.Cfgs = nil

	self.Binders = {
		{ "THRemainCount", UIBinderSetText.New(self, self.TextJoinTimes_1)}, -- TH = TreasureHunt 寻宝
		{ "bTHLockImgVisible", UIBinderSetIsVisible.New(self, self.ImgLock_1)},
		{ "TreasureNum", UIBinderSetText.New(self, self.TextNumber)},
		
		{ "FTRemainCount", UIBinderSetText.New(self, self.TextJoinTimes)}, -- FT = FriendlyTribe 友好部族
		{ "bFTLockImgVisible", UIBinderSetIsVisible.New(self, self.ImgLock)},
		{ "RecommRace", UIBinderSetText.New(self, self.TextRace)},
		{ "RaceLevel", UIBinderSetText.New(self, self.TextLevel)},
		{ "RaceIconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgRaceIcon)}, 

		{ "MonsterRemainCount", UIBinderSetText.New(self, self.TextJoinTimes_2)}, -- 怪物狩猎
		{ "bMonsterLockVisible", UIBinderSetIsVisible.New(self, self.ImgLock_2)}, -- 怪物狩猎

	}
end

function WorldExploraActivityPanelView:OnDestroy()

end

function WorldExploraActivityPanelView:OnShow()
	self:InitByCfg()
end

function WorldExploraActivityPanelView:OnHide()
	self.Cfgs = nil
end

function WorldExploraActivityPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClick_1, self.OnBtnTreasureHuntClick)
	UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnBtnFriendlyTribeClick)
	UIUtil.AddOnClickedEvent(self, self.BtnClick_2, self.OnBtnMonsterClick)

end

function WorldExploraActivityPanelView:OnRegisterGameEvent()

end

function WorldExploraActivityPanelView:OnRegisterBinder()
	self:RegisterBinders(WorldExploraVM, self.Binders)
end

-- 打开寻宝界面
function WorldExploraActivityPanelView:OnBtnTreasureHuntClick()
	local bLock = WorldExploraVM.bTHLockImgVisible
	if bLock then				
		WorldExploraMgr:ShowLockTips(Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_TREASUREHUNT,
		self.ImgLock_1, TabType.EActivity, _G.UE.FVector2D( 0, 1))
		return
	end	
	_G.TreasureHuntMgr:GetTreasureAllMapReq()
end

-- 打开友好部族界面 TODO
function WorldExploraActivityPanelView:OnBtnFriendlyTribeClick()
	--[[
	local bLock = WorldExploraVM.bFTLockImgVisible
	if bLock then
		MsgTipsUtil.ShowTips(LSTR(1610019)) -- 暂未开启, 敬请期待
		return
	end
	]]
end

-- 打开怪物狩猎界面 TODO
function WorldExploraActivityPanelView:OnBtnMonsterClick()
	local bLock = WorldExploraVM.bMonsterLockVisible
	if bLock then
		MsgTipsUtil.ShowTips(LSTR(1610019)) -- 暂未开启, 敬请期待
		return
	end
end


function WorldExploraActivityPanelView:InitByCfg()
	self:InitTreasureHuntPanel()
	self:InitFriendlyTribePanel()
	self:InitMonsterPanel()
end

-- 初始化寻宝相关
function WorldExploraActivityPanelView:InitTreasureHuntPanel()
	local Cfg = self:FindCfgByGameType(Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_TREASUREHUNT)
	if Cfg == nil then
		FLOG_ERROR("TreasureHunt Cfg is nil")
		return
	end
	self.TextName_1:SetText(Cfg.FuncName)
	self.TextOwn:SetText(LSTR(1610003)) -- 拥有宝图

	local bLock = WorldExploraVM.bTHLockImgVisible
	UIUtil.SetIsVisible(self.TextJoinTimes_1, not bLock)
	UIUtil.SetIsVisible(self.PanelTips_1, not bLock)
end

-- 初始化友好部族相关
function WorldExploraActivityPanelView:InitFriendlyTribePanel()
	local Cfg = self:FindCfgByGameType(Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_FRIENDLYTRIBE)
	if Cfg == nil then
		FLOG_ERROR("FriendlyTribe Cfg is nil")
		return
	end
	self.TextName:SetText(Cfg.FuncName)
	--self.TextRecommend:SetText(LSTR(1610005)) -- 推荐部族

	--local bLock = WorldExploraVM.bFTLockImgVisible
	UIUtil.SetIsVisible(self.TextJoinTimes, false)
	--UIUtil.SetIsVisible(self.PanelTips, not bLock)
end

-- 初始化怪物狩猎相关
function WorldExploraActivityPanelView:InitMonsterPanel()
	local Cfg = self:FindCfgByGameType(Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_MONSTERHUNT)
	if Cfg == nil then
		FLOG_ERROR("FriendlyTribe Cfg is nil")
		return
	end
	self.TextName_2:SetText(Cfg.FuncName)

	local bLock = WorldExploraVM.bMonsterLockVisible
	UIUtil.SetIsVisible(self.TextJoinTimes_2, not bLock)
end


function WorldExploraActivityPanelView:FindCfgByGameType(GameType)
	return WorldExploraMgr:FindCfgByGameType(GameType, TabType.EActivity)
end

return WorldExploraActivityPanelView