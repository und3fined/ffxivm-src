---
--- Author: Administrator
--- DateTime: 2024-06-04 21:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderCommBtnUpdateImage = require("Binder/UIBinderCommBtnUpdateImage")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local AdventureRecommendTaskMgr = require("Game/Adventure/AdventureRecommendTaskMgr")
local MapUtil = require("Game/Map/MapUtil")
local AdventureDefine = require("Game/Adventure/AdventureDefine")
local ProtoCS = require("Protocol/ProtoCS")
local DataReportUtil = require("Utils/DataReportUtil")
local QuestMgr = require("Game/Quest/QuestMgr")
local QuestHelper = require("Game/Quest/QuestHelper")
local QUEST_STATUS =  ProtoCS.CS_QUEST_STATUS

---@class AdventureRecommendTaskNewItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AdventureJobState AdventureJobStateItemView
---@field BtnGo CommBtnSView
---@field ImgTask UFImage
---@field ImgTaskIcon UFImage
---@field PanelOngoing UFCanvasPanel
---@field PanelTop UFCanvasPanel
---@field RedDot2 CommonRedDot2View
---@field TableViewReward UTableView
---@field TextOngoing UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AdventureRecommendTaskNewItemView = LuaClass(UIView, true)

function AdventureRecommendTaskNewItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AdventureJobState = nil
	--self.BtnGo = nil
	--self.ImgTask = nil
	--self.ImgTaskIcon = nil
	--self.PanelOngoing = nil
	--self.PanelTop = nil
	--self.RedDot2 = nil
	--self.TableViewReward = nil
	--self.TextOngoing = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AdventureRecommendTaskNewItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AdventureJobState)
	self:AddSubView(self.BtnGo)
	self:AddSubView(self.RedDot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AdventureRecommendTaskNewItemView:OnInit()
	self.TableViewRewardAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewReward)

	self.Binders = {
		{"TextTitle", UIBinderSetText.New(self, self.TextTitle)},
		{"TextDescribe", UIBinderSetText.New(self, self.AdventureJobState.TextOngoing)},
		-- {"TextBtnGo", UIBinderSetText.New(self, self.BtnGo.TextContent)},
		{"ImgTaskIcon",UIBinderSetImageBrush.New(self, self.ImgTaskIcon)},
		{"ImgTask",UIBinderSetImageBrush.New(self, self.ImgTask)},
		{"IsNew", UIBinderSetIsVisible.New(self, self.RedDot2)},
		{"GoBtnStyle", UIBinderCommBtnUpdateImage.New(self, self.BtnGo)},
		{"StartVisible", UIBinderSetIsVisible.New(self, self.BtnGo)},
		{"Top", UIBinderSetIsVisible.New(self, self.PanelTop)},
		-- {"StartVisible", UIBinderSetIsVisible.New(self, self.PanelOngoing, true)},
		{"GoText", UIBinderSetText.New(self, self.BtnGo)},
		{"PanelOngoingVisible", UIBinderSetIsVisible.New(self, self.PanelOngoing)},
		{"RewardList", UIBinderUpdateBindableList.New(self, self.TableViewRewardAdapter)},
		{"ChapterID" , UIBinderValueChangedCallback.New(self, nil, self.OnChapterIDChanged)},
		{"UnlockIconPath", UIBinderSetImageBrush.New(self, self.AdventureJobState.IconRecommendTask)}
	}


end

function AdventureRecommendTaskNewItemView:OnDestroy()
end

function AdventureRecommendTaskNewItemView:OnShow()
	self.AdventureJobState:SetRecommendTagShow()
	local ViewModel = self.Params.Data

	if nil == ViewModel then
		return
	end

	self.ViewModel = ViewModel

	self:RegisterBinders(ViewModel, self.Binders)

	if ViewModel.ChapterID ~=  nil then
		local Type = AdventureRecommendTaskMgr:GetRecommendTaskType(ViewModel.ChapterID)
		local RedDotName = AdventureRecommendTaskMgr:GetRedDotName(Type, ViewModel.ChapterID)
		if RedDotName ~= nil then
			self.RedDot2:SetRedDotNameByString(RedDotName)
		end
	end

	-- self.BtnGo:SetText(_G.LSTR(860012)) -- 前往
	-- self.TextOngoing:SetText(_G.LSTR(860013)) -- 进行中
	self:PlayAnimLoop()
end

function AdventureRecommendTaskNewItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGo, self.OnClickedGoHandle)
end

function AdventureRecommendTaskNewItemView:OnRegisterGameEvent()
end

function AdventureRecommendTaskNewItemView:OnRegisterBinder()
	local ViewModel = self.Params.Data

	if nil == ViewModel then
		return
	end

	self.ViewModel = ViewModel

	self:RegisterBinders(ViewModel, self.Binders)

	if ViewModel.ChapterID ~=  nil then
		local Type = _G.AdventureRecommendTaskMgr:GetRecommendTaskType(ViewModel.ChapterID)
		local RedDotName = _G.AdventureRecommendTaskMgr:GetRedDotName(Type, ViewModel.ChapterID)
		if RedDotName ~= nil then
			self.RedDot2:SetRedDotNameByString(RedDotName)
		end
	end

end

function AdventureRecommendTaskNewItemView:OnChapterIDChanged(NewValue)
	if NewValue ~=  nil then
		local Type = _G.AdventureRecommendTaskMgr:GetRecommendTaskType(NewValue)
		local RedDotName = _G.AdventureRecommendTaskMgr:GetRedDotName(Type, NewValue)
		if RedDotName ~= nil then
			self.RedDot2:SetRedDotNameByString(RedDotName)
		end
	end
end

function AdventureRecommendTaskNewItemView:OnClickedGoHandle()
	-- if self.ViewModel and self.ViewModel.OnClickGoHandle then
	-- 	self.ViewModel:OnClickGoHandle(self.ViewModel.ID, self.ViewModel)
	-- end

	local ID = self.ViewModel.ID
	local ViewModel = self.ViewModel

	local ChapterID = ID
    local ChapterCfg = QuestHelper.GetChapterCfgItem(ID)
	if ChapterCfg == nil or ChapterCfg.StartQuest == nil then
		return
	end
    local StartQuestCfg = QuestHelper.GetQuestCfgItem(ChapterCfg.StartQuest)
	if  StartQuestCfg == nil or StartQuestCfg.id == nil  then
		return
	end
    local Status = QuestMgr:GetQuestStatus(StartQuestCfg.id)
    local MapDefine = require("Game/Map/MapDefine")

    if Status == QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED then
        local Params = {}
        Params.MapID  = StartQuestCfg.AcceptMapID or 0
        ViewModel:SetItemNewState(false)
        local Type = AdventureRecommendTaskMgr:GetRecommendTaskType(ChapterID)
        AdventureRecommendTaskMgr:DelRedDot(Type, ChapterID)

        _G.WorldMapMgr:ShowWorldMapQuest(StartQuestCfg.AcceptMapID, nil, StartQuestCfg.id, MapDefine.MapOpenSource.RecommendTask)

        DataReportUtil.ReportRecommendTaskData("ReTasksInfo", tostring(AdventureDefine.ReportAdventureRecommendTaskType.GoToBtn), ChapterID)
    else

		local QuestMainVM = require("Game/Quest/VM/QuestMainVM")
		local AllVMs = QuestMainVM.QuestLogVM:GetAllChapterVMs()
		local TargetQuestID = StartQuestCfg.id or 0
		for i = 1, AllVMs:Length() do
			local VM = AllVMs:Get(i)
			if VM.ChapterID == ID then
				local MapID = VM.TargetMapID
				TargetQuestID = VM.QuestID
				if (MapID == nil) or (MapID == 0) then return end
				local UIMapID = MapUtil.GetUIMapID(MapID)
				_G.WorldMapMgr:ShowWorldMapQuest(MapID, UIMapID, TargetQuestID)
				DataReportUtil.ReportRecommendTaskData("ReTasksInfo", tostring(AdventureDefine.ReportAdventureRecommendTaskType.GoToBtn), ChapterID)
				break
			end
		end
    end
end



return AdventureRecommendTaskNewItemView