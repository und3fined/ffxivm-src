---
--- Author: Administrator
--- DateTime: 2025-03-17 20:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local ProtoRes = require("Protocol/ProtoRes")

local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local JumpUtil = require("Utils/JumpUtil")

local WorldExploraMgr = require("Game/WorldExplora/WorldExploraMgr")
local WorldExploraVM = require("Game/WorldExplora/WorldExploraVM")
local WorldExploraDefine = require("Game/WorldExplora/WorldExploraDefine")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local ItemCfg = require("TableCfg/ItemCfg")
local ScoreCfg = require("TableCfg/ScoreCfg")
local AchievementTextCfg = require("TableCfg/AchievementTextCfg")

local Wilder_Explore_GameType = ProtoRes.Wilder_Explore_GameType
local Wilder_Explore_WERewardItemType = ProtoRes.Wilder_Explore_WERewardItemType
local LSTR = _G.LSTR
---@class WorldExploraWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGo UFButton
---@field BtnTitleTips UFButton
---@field CloseBtn CommonCloseBtnView
---@field CommBtnL_UIBP CommBtnLView
---@field CommInforBtn_UIBP CommInforBtnView
---@field CommonBkg CommonBkg02View
---@field CommonBkgMask CommonBkgMaskView
---@field Desc URichTextBox
---@field FCanvasPanel_837 UFCanvasPanel
---@field FGoPanel UFCanvasPanel
---@field FHorizontalBox_93 UFHorizontalBox
---@field FinishText UFTextBlock
---@field FuncIcon UFImage
---@field FuncName UFTextBlock
---@field GoReasonText UFTextBlock
---@field ImgBanner UFImage
---@field Num UFTextBlock
---@field NumText UFTextBlock
---@field Panel01 UFCanvasPanel
---@field Panel02 UFCanvasPanel
---@field Panel03 UFCanvasPanel
---@field PanelBtn UFCanvasPanel
---@field PanelFunction UFCanvasPanel
---@field PanelReward UFHorizontalBox
---@field PanelView UFCanvasPanel
---@field Progress UProgressBar
---@field RichTextBox URichTextBox
---@field RichTextBox_385 URichTextBox
---@field RichTextDescribe URichTextBox
---@field SlotItem01 WorldExploraSlotItemView
---@field SlotItem02 WorldExploraSlotItemView
---@field SlotItem03 WorldExploraSlotItemView
---@field SlotItem04 WorldExploraSlotItemView
---@field SlotItem05 WorldExploraSlotItemView
---@field SlotItem06 WorldExploraSlotItemView
---@field TableViewPlace UTableView
---@field TableViewTab UTableView
---@field TextFunction UFTextBlock
---@field TextGo UFTextBlock
---@field TextTitle UFTextBlock
---@field TextView UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimSwitch UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldExploraWinView = LuaClass(UIView, true)

function WorldExploraWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGo = nil
	--self.BtnTitleTips = nil
	--self.CloseBtn = nil
	--self.CommBtnL_UIBP = nil
	--self.CommInforBtn_UIBP = nil
	--self.CommonBkg = nil
	--self.CommonBkgMask = nil
	--self.Desc = nil
	--self.FCanvasPanel_837 = nil
	--self.FGoPanel = nil
	--self.FHorizontalBox_93 = nil
	--self.FinishText = nil
	--self.FuncIcon = nil
	--self.FuncName = nil
	--self.GoReasonText = nil
	--self.ImgBanner = nil
	--self.Num = nil
	--self.NumText = nil
	--self.Panel01 = nil
	--self.Panel02 = nil
	--self.Panel03 = nil
	--self.PanelBtn = nil
	--self.PanelFunction = nil
	--self.PanelReward = nil
	--self.PanelView = nil
	--self.Progress = nil
	--self.RichTextBox = nil
	--self.RichTextBox_385 = nil
	--self.RichTextDescribe = nil
	--self.SlotItem01 = nil
	--self.SlotItem02 = nil
	--self.SlotItem03 = nil
	--self.SlotItem04 = nil
	--self.SlotItem05 = nil
	--self.SlotItem06 = nil
	--self.TableViewPlace = nil
	--self.TableViewTab = nil
	--self.TextFunction = nil
	--self.TextGo = nil
	--self.TextTitle = nil
	--self.TextView = nil
	--self.AnimIn = nil
	--self.AnimSwitch = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldExploraWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommBtnL_UIBP)
	self:AddSubView(self.CommInforBtn_UIBP)
	self:AddSubView(self.CommonBkg)
	self:AddSubView(self.CommonBkgMask)
	self:AddSubView(self.SlotItem01)
	self:AddSubView(self.SlotItem02)
	self:AddSubView(self.SlotItem03)
	self:AddSubView(self.SlotItem04)
	self:AddSubView(self.SlotItem05)
	self:AddSubView(self.SlotItem06)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldExploraWinView:OnInit()
	self.TableAdapterTab = UIAdapterTableView.CreateAdapter(self, self.TableViewTab, self.OnSelectChangedTab, true)
	self.PlaceAdapterTab = UIAdapterTableView.CreateAdapter(self, self.TableViewPlace, self.OnPlaceChangedTab, true) 
	self.GameType = nil
	self.LastGameType = nil		
	self.TableIndex = 0
	self.Binders = {
		
		{ "BGImgPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgBanner)}, 

		{ "bPanelBtnVisible", UIBinderSetIsVisible.New(self, self.PanelBtn)},   -- PanelBtn
		{ "BookName", UIBinderSetText.New(self, self.TextGo)},

		{ "GameName", UIBinderSetText.New(self, self.TextTitle)},
		{ "Describe", UIBinderSetText.New(self, self.RichTextDescribe)},

		{ "bPanelRewardVisible", UIBinderSetIsVisible.New(self, self.PanelReward)}, 

		{ "bPanelFunctionVisible", UIBinderSetIsVisible.New(self, self.PanelFunction)}, 
		{ "FuncIconPath", UIBinderSetBrushFromAssetPath.New(self, self.FuncIcon)}, 
		{ "FuncName", UIBinderSetText.New(self, self.FuncName)}, 

		{ "bProgressVisible", UIBinderSetIsVisible.New(self, self.Panel02)},
		{ "NumText", UIBinderSetText.New(self, self.NumText)},
		{ "CurNum", UIBinderSetText.New(self, self.Num)},
		{ "TipDesc", UIBinderSetText.New(self, self.Desc)},
		{ "TipDesc", UIBinderSetText.New(self, self.RichTextBox)},

		{ "CurProgress", UIBinderSetPercent.New(self, self.Progress)},

		{ "bRecomMapVisible", UIBinderSetIsVisible.New(self, self.Panel03)},
		{ "RecommMapText", UIBinderSetText.New(self, self.RichTextBox_385)},
		{ "bDownTextVisible", UIBinderSetIsVisible.New(self, self.RichTextBox_385, true)},

		{ "HasFinishTipText", UIBinderSetText.New(self, self.FinishText)},
		{ "bFinishTipVisible", UIBinderSetIsVisible.New(self, self.FCanvasPanel_837)},
		{ "RecommPlaceList", UIBinderUpdateBindableList.New(self, self.PlaceAdapterTab)},
		{ "bPlaceListVisible", UIBinderSetIsVisible.New(self, self.TableViewPlace)},
		{ "bDownTextVisible", UIBinderSetIsVisible.New(self, self.RichTextBox)}, 
		{ "bTipDescVisible", UIBinderSetIsVisible.New(self, self.Desc)}, 

		{ "bGoPanelVisible", UIBinderSetIsVisible.New(self, self.FGoPanel)}, 
		{ "GoReasonText", UIBinderSetText.New(self, self.GoReasonText)},

		{ "RewardChangeCallBackNum", UIBinderValueChangedCallback.New(self, nil, self.OnRewardChange) },
	}
end

function WorldExploraWinView:OnDestroy()

end

function WorldExploraWinView:OnShow()
	self:InitLocalText()
	local Params = self.Params
	if Params == nil then
		return
	end
	
	self.TableAdapterTab:UpdateAll(Params.ItemData)
	self.TableAdapterTab:SetSelectedIndex(Params.SelectIndex)
	self.TableAdapterTab:ScrollToIndex(Params.SelectIndex)
end

function WorldExploraWinView:OnHide()
	self.GameType = Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_INVALID
	self.TableIndex = 0
end

function WorldExploraWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnTitleTips, self.OnBtnTitleTipsClick)
	UIUtil.AddOnClickedEvent(self, self.CommBtnL_UIBP.Button, self.OnGoClick)
	UIUtil.AddOnClickedEvent(self, self.BtnGo, self.OnJumpClick)
end

function WorldExploraWinView:OnRegisterGameEvent()

end

function WorldExploraWinView:InitLocalText()
	self.TextView:SetText(LSTR(1610006)) -- 奖励预览
	self.TextFunction:SetText(LSTR(1610007))  -- 功能预览
	self.CommBtnL_UIBP.TextContent:SetText(LSTR(10019)) -- 前 往
end

function WorldExploraWinView:OnRegisterBinder()
	self:RegisterBinders(WorldExploraVM, self.Binders)
end

--- 点击打开新手指南
function WorldExploraWinView:OnBtnTitleTipsClick()
	local GameType = self.GameType
	if GameType == nil then
		return
	end
	local Cfg = WorldExploraMgr:FindCfgByGameType(GameType,  WorldExploraDefine.TabType.EExplora)
	if Cfg == nil then
		return
	end
	WorldExploraMgr:OnShowPWorldGuideTip(Cfg.GuideID)
end

--- 点击前往解锁职业按钮
function WorldExploraWinView:OnGoClick()
	local GameType = self.GameType
	if GameType == nil then
		return
	end
	local Cfg = WorldExploraMgr:FindCfgByGameType(GameType,  WorldExploraDefine.TabType.EExplora)
	if Cfg == nil then
		return
	end
	_G.EquipmentMgr:OpenEquipmentByPreviewProf(Cfg.ProfID)
end

--- @type 点击跳转
function WorldExploraWinView:OnJumpClick()
	local GameType = self.GameType
	if GameType == nil then
		return
	end
	local Cfg = WorldExploraMgr:FindCfgByGameType(GameType,  WorldExploraDefine.TabType.EExplora)
	if Cfg == nil or Cfg.JumpID == nil or Cfg.JumpID == 0 then
		return
	end
	JumpUtil.JumpTo(Cfg.JumpID)
end


-- 当选择下方的Tab
function WorldExploraWinView:OnSelectChangedTab(Index, ItemData, ItemView)
	local GameType = ItemData.GameType
	local bLock = false
	if GameType == Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_AETHER and not WorldExploraMgr:CheckAetherIsUnlock() then
		bLock = true 
	end

	if GameType == Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_SIGHTSEE and not WorldExploraMgr:CheckSightseeingLogIsUnlock() then
		bLock = true 
	end

	if bLock then
		MsgTipsUtil.ShowTips(LSTR(1610011)) --"功能暂未解锁"

		--失败，重新点回原来的
		if (self.TableIndex > 0) then
			self.TableAdapterTab:SetSelectedIndex(self.TableIndex)	
		end
		
		return
	end
	
	self.TableIndex = Index

	self.LastGameType = self.GameType
	self.GameType = ItemData.GameType
	
	if self.GameType ~= self.LastGameType then
		self:UpdateGuideTileBtnState()
		self:UpdatePreFuncHelpID()
		WorldExploraMgr:OnGameTypeSelectChanged(GameType)

		self:PlayAnimation(self.AnimSwitch)
	end
end

--更新新手指引按钮状态
function WorldExploraWinView:UpdateGuideTileBtnState()
	UIUtil.SetIsVisible(self.BtnTitleTips, false)

	local Cfg = WorldExploraMgr:FindCfgByGameType(self.GameType,  WorldExploraDefine.TabType.EExplora)
	if Cfg == nil then
		return
	end

	if (_G.TutorialGuideMgr:CheckGuide(Cfg.GuideID)) then
		UIUtil.SetIsVisible(self.BtnTitleTips, true, true)
	end
end

-- 更新预览功能帮助ID
function WorldExploraWinView:UpdatePreFuncHelpID()
	local GameType = self.GameType
	local Cfg = WorldExploraMgr:FindCfgByGameType(GameType,  WorldExploraDefine.TabType.EExplora)
	if Cfg == nil then
		return
	end
	self.CommInforBtn_UIBP:SetHelpInfoID(Cfg.AbilityTipID)
end

-- 当选择地图
function WorldExploraWinView:OnPlaceChangedTab(Index, ItemData, ItemView)
	if ItemData == nil then
		return
	end
	local MapID = ItemData.MapID
	WorldExploraMgr:GoMapClick(MapID)
end

-- 变更奖励
function WorldExploraWinView:OnRewardChange()
	local GameType = self.GameType
	local Cfg = WorldExploraMgr:FindCfgByGameType(GameType,  WorldExploraDefine.TabType.EExplora)
	if Cfg == nil then
		return
	end
	local NeedData = { --[[{ID =xxx ,Type = xxx, IconPath = XXX, Num = xxx, TipsID = XXX} ]]}

	local Reward = Cfg.Reward   -- 先取Reward数据
	for i = 1, #Reward do
		if Reward[i].ID ~= 0 then
			local TmpTable = {}
			TmpTable.Num = Reward[i].Num
			TmpTable.ID = Reward[i].ID
			TmpTable.Type = Reward[i].Type
			if Reward[i].Type == Wilder_Explore_WERewardItemType.WILDER_EXPLORE_REWARDITEMTYPE_ITEM then			-- 物品
				local Cfg = ItemCfg:FindCfgByKey(Reward[i].ID)
				if Cfg ~= nil then
					TmpTable.IconPath = ItemCfg.GetIconPath(Cfg.IconID)
				end
			elseif Reward[i].Type == Wilder_Explore_WERewardItemType.WILDER_EXPLORE_REWARDITEMTYPE_SCORE then		-- 积分
				local ScoreConfig = ScoreCfg:FindCfgByKey(Reward[i].ID)
				if ScoreConfig then
					TmpTable.IconPath = ScoreConfig.IconName
				end
			elseif Reward[i].Type == Wilder_Explore_WERewardItemType.WILDER_EXPLORE_REWARDITEMTYPE_HONOR then   		-- 成就
				TmpTable.IconPath = WorldExploraDefine.ArchievementPath
			end
			table.insert(NeedData, TmpTable)
		end
		
	end

	--钓鱼，伐木，采矿，乐团对应的OtherReward最后一个图标，使用PanelIcon图标
	local ShowPanelIcon = false
	if (self.GameType == Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_TOUR
		or self.GameType == Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_FISHING
		or self.GameType == Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_MIN
		or self.GameType == Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_GATHER) then
		ShowPanelIcon = true
	end

	local OtherReward = Cfg.OtherReward  -- 再取OtherReward数据
	for i = 1, #OtherReward do
		local Elem = OtherReward[i]
		if Elem.TipsID ~= 0 then
			local TmpTable = {}
			TmpTable.IconPath = Elem.IconPath
			TmpTable.TipsID = Elem.TipsID
			TmpTable.ShowPanelIcon = false
			TmpTable.ShowImgTypeIcon = false

			if (i == #OtherReward) then
				if (ShowPanelIcon) then
					TmpTable.ShowPanelIcon = true
				elseif (self.GameType == Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_MYSTERMECH) then
					--冒险商团，显示ImgTypeIcon
					TmpTable.ShowImgTypeIcon = true
				end
			end

			table.insert(NeedData, TmpTable)
		end	
	end

	for i = 1, 6 do							-- 统一处理
		local bNeedShow = false
		local Item = self["SlotItem0"..tostring(i)]
		local ItemSlot74 = self["SlotItem0"..tostring(i)].Slot74
		if i <= #NeedData then
			local Data = NeedData[i]
			bNeedShow = true
			if Data.ID and Data.Type and 
				(Data.Type == Wilder_Explore_WERewardItemType.WILDER_EXPLORE_REWARDITEMTYPE_SCORE or Data.Type == Wilder_Explore_WERewardItemType.WILDER_EXPLORE_REWARDITEMTYPE_ITEM) then
				ItemSlot74:SetNum(Data.Num)
				ItemSlot74:SetNumVisible((Data.Num ~= nil and Data.Num > 0))
				ItemSlot74:SetClickButtonCallback(ItemSlot74, function(TargetItemView)
					ItemTipsUtil.ShowTipsByResID(Data.ID, ItemSlot74)
				end)
			elseif Data.ID and Data.Type and Data.Type == Wilder_Explore_WERewardItemType.WILDER_EXPLORE_REWARDITEMTYPE_HONOR then
				local AchievementConfig = AchievementTextCfg:FindCfgByKey(Data.ID)
				if AchievementConfig ~= nil then
					ItemSlot74:SetNumVisible(false)
					ItemSlot74:SetClickButtonCallback(ItemSlot74, function(TargetItemView)
						WorldExploraMgr:ShowInfoTipByContent(TargetItemView, AchievementConfig.Name, AchievementConfig.Help)
					end)
				end
			elseif Data.TipsID and Data.TipsID ~= 0 then
				ItemSlot74:SetNumVisible(false)
				ItemSlot74:SetClickButtonCallback(ItemSlot74, function(TargetItemView)
					WorldExploraMgr:ShowInfoTips(TargetItemView, Data.TipsID)
				end)
			end
			ItemSlot74:SetIconImg(Data.IconPath)
			ItemSlot74:SetIconChooseVisible(false)
					
			if (Data.ShowPanelIcon ~= nil and Data.ShowPanelIcon) then
				--显示PanelIcon(钓鱼，伐木，采矿，乐团)
				UIUtil.SetIsVisible(ItemSlot74, false)
				UIUtil.SetIsVisible(Item.ImgTypeIcon, false)				
				UIUtil.SetIsVisible(Item.PanelIcon, true)
				UIUtil.SetIsVisible(Item.BtnTips, true, true)
				UIUtil.SetIsVisible(Item.ImgIcon, true)

				UIUtil.ImageSetBrushFromAssetPath(Item.ImgIcon, Data.IconPath)	
				
				Item:SetButtonTipsHelpID(Data.TipsID)
			elseif (Data.ShowImgTypeIcon ~= nil and Data.ShowImgTypeIcon) then
				--显示ImgTypeIcon(冒险团)
				UIUtil.SetIsVisible(ItemSlot74, false)
				UIUtil.SetIsVisible(Item.ImgTypeIcon, true)				
				UIUtil.SetIsVisible(Item.PanelIcon, false)
				UIUtil.SetIsVisible(Item.BtnTips, true, true)
				
				UIUtil.ImageSetBrushFromAssetPath(Item.ImgTypeIcon, Data.IconPath)				
				Item:SetButtonTipsHelpID(Data.TipsID)
			else
				UIUtil.SetIsVisible(ItemSlot74, true)
				UIUtil.SetIsVisible(Item.ImgTypeIcon, false)				
				UIUtil.SetIsVisible(Item.PanelIcon, false)
				UIUtil.SetIsVisible(Item.BtnTips, false)
			end
		end

		UIUtil.SetIsVisible(Item, bNeedShow)
		
	end
end


return WorldExploraWinView