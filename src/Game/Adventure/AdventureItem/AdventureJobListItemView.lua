--- Author: Administrator
--- DateTime: 2024-07-23 14:31
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetRenderOpacity = require("Binder/UIBinderSetRenderOpacity")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local AdventureCareerMgr = require("Game/Adventure/AdventureCareerMgr")
local QuestMgr = require("Game/Quest/QuestMgr")
local ProtoCS = require("Protocol/ProtoCS")
local QUEST_STATUS =  ProtoCS.CS_QUEST_STATUS
local MapUtil = require("Game/Map/MapUtil")
local MajorUtil = require("Utils/MajorUtil")
---@class AdventureJobListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AdventureJobState AdventureJobStateItemView
---@field BtnGo CommBtnSView
---@field ImgTask UFImage
---@field ImgTaskIcon UFImage
---@field PanelListItem UFCanvasPanel
---@field PanelSelect UFCanvasPanel
---@field RedDot2 CommonRedDot2View
---@field TableViewReward UTableView
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AdventureJobListItemView = LuaClass(UIView, true)

function AdventureJobListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AdventureJobState = nil
	--self.BtnGo = nil
	--self.ImgTask = nil
	--self.ImgTaskIcon = nil
	--self.PanelListItem = nil
	--self.PanelSelect = nil
	--self.RedDot2 = nil
	--self.TableViewReward = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AdventureJobListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AdventureJobState)
	self:AddSubView(self.BtnGo)
	--self:AddSubView(self.RedDot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AdventureJobListItemView:OnInit()
	self.TableViewRewardAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewReward)

	self.Binders = {
		{"TextTitle", UIBinderSetText.New(self, self.TextTitle)},
		{"TextBtnGo", UIBinderSetText.New(self, self.BtnGo.TextContent)},
		{"BtnGoVisible", UIBinderSetIsVisible.New(self, self.BtnGo)},	
		{"ImgTaskIcon",UIBinderSetImageBrush.New(self, self.ImgTaskIcon)},
		{"ImgTask",UIBinderSetImageBrush.New(self, self.ImgTask)},
		{"IsNew", UIBinderSetIsVisible.New(self, self.RedDot2)},		
		{"RewardList", UIBinderUpdateBindableList.New(self, self.TableViewRewardAdapter)},
		{"TextTypeTag", UIBinderSetText.New(self, self.AdventureJobState.TextOngoing)},
		{"TextTypeTagVisible", UIBinderSetIsVisible.New(self, self.AdventureJobState.PanelOngoing)},	
		{"TextOngoing", UIBinderSetText.New(self, self.TextOngoing)},
		{"PanelSelectVisible", UIBinderSetIsVisible.New(self, self.PanelSelect)},
		{"JobStateIcon", UIBinderSetImageBrush.New(self, self.AdventureJobState.IconJob) },
		{"JobStateIconVisible", UIBinderSetIsVisible.New(self, self.AdventureJobState.IconJob)},
		{"JobStateColor", UIBinderSetColorAndOpacityHex.New(self, self.AdventureJobState.TextOngoing)},
		{"EffVisible", UIBinderSetIsVisible.New(self, self.EFF)},	
	}
end


function AdventureJobListItemView:OnShow()
	self.AdventureJobState:SetProfTagShow()
	local ViewModel = self.Params.Data
	if nil == ViewModel then return end

	self.RedDot2.TextNewYellow1:SetText(LSTR(520030))
	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
	self:RefreshBtnStatus()
end

function AdventureJobListItemView:RefreshBtnStatus()
	local VM = self.ViewModel
	local Status = VM.Status
	if Status == QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED  then
		if VM.Activate then
			self.BtnGo:SetIsNormalState(true)
			self.BtnGo:SetText(LSTR(520010))
		else
			self.BtnGo:SetIsDisabledState(true, false)
			self.BtnGo:SetText(LSTR(520035))
		end
	else
		if Status == QUEST_STATUS.CS_QUEST_STATUS_CAN_SUBMIT or Status == QUEST_STATUS.CS_QUEST_STATUS_IN_PROGRESS then
			self.BtnGo:SetText(LSTR(520052))
			self.BtnGo:SetIsRecommendState(true)
		elseif Status == QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
			self.BtnGo:SetIsDoneState(true, LSTR(520019))
		else
			FLOG_INFO("AdventureJobListItemView:RefreshBtnStatus Error ID: %s", VM.ChapterID)
		end
	end
end

function AdventureJobListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGo, self.OnClickedGoHandle)
	--UIUtil.AddOnClickedEvent(self, self.BtnUnLock, self.OnClickedUnlockHandle)
end

function AdventureJobListItemView:OnRegisterBinder()
	local ViewModel = self.Params.Data

	if nil == ViewModel then
		return
	end

	self.ViewModel = ViewModel

	self:RegisterBinders(ViewModel, self.Binders)
end

function AdventureJobListItemView:OnClickedGoHandle()
	local ViewModel = self.ViewModel
	if not ViewModel then return end

	AdventureCareerMgr:JumpChapterOnMap(ViewModel.ChapterID)
end

-- function AdventureJobListItemView:OnClickedUnlockHandle()
-- 	local ViewModel = self.ViewModel
-- 	if not ViewModel then return end

-- 	local ID = ViewModel.ChapterID
-- 	 local ChapterCfg = AdventureCareerMgr:GetChapterCfgData(ID)
--     local StartQuestCfg = AdventureCareerMgr:GetQuestCfgData(ChapterCfg.StartQuest)
--     local TaskID = StartQuestCfg.id
--     local Status = QuestMgr:GetQuestStatus(TaskID)
--     if Status == QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED  then
--         local PreQuestNotFinished = (StartQuestCfg.OneofPreTask == 1) -- “任一前置”勾选项
--         local PrevQuestsIDs = StartQuestCfg.PreTaskID
--         if type(PrevQuestsIDs) == "table" and next(PrevQuestsIDs) ~= nil then
--             for _, PreQuestID in ipairs(PrevQuestsIDs) do
--                 if PreQuestNotFinished == (QuestMgr.EndQuestToChapterIDMap[PreQuestID] ~= nil) then
--                     PreQuestNotFinished = not PreQuestNotFinished
--                     break
--                 end
--             end
--         else
--             PreQuestNotFinished = false
--         end

--         if PreQuestNotFinished then
--             _G.MsgTipsUtil.ShowTips(LSTR(520034))
--             return
--         end

--         local RoleSimple = MajorUtil.GetMajorRoleSimple()
--         local bLowLevel = RoleSimple.Level < (ChapterCfg.MinLevel or 1)
--         if bLowLevel then
--             _G.MsgTipsUtil.ShowTips(LSTR(520046))
--         end
--     end
-- end

return AdventureJobListItemView