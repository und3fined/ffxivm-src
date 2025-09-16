local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

--VM
local AdventureDetailVM = require("Game/Adventure/AdventureDetailVM")

--binder
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

local ProfModelCfg = require("TableCfg/ProfModelCfg")

local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")
local QuestHelper = require("Game/Quest/QuestHelper")
local QUEST_STATUS =  ProtoCS.CS_QUEST_STATUS

---@class AdventureJobPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AdventureJob1 AdventureJobTagItemView
---@field AdventureJob2 AdventureJobTagItemView
---@field BtnGo AdventureJobBtnItemView
---@field BtnTryRole AdventureJobBtnItemView
---@field FHorizontalBox_0 UFHorizontalBox
---@field FHorizontalBtn UFHorizontalBox
---@field IconArrow1 UFImage
---@field IconJob1 UFImage
---@field IconJob2 UFImage
---@field ImgLogo UFImage
---@field ImgPeople UFImage
---@field PanelArrow UFCanvasPanel
---@field PanelBook UFCanvasPanel
---@field PanelInfo_1 UFCanvasPanel
---@field SizeBox1 USizeBox
---@field SizeBox2 USizeBox
---@field TextInfo AdventureJobTextPanelView
---@field TextRoleName UFTextBlock
---@field TextTips UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AdventureJobPanelView = LuaClass(UIView, true)

function AdventureJobPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AdventureJob1 = nil
	--self.AdventureJob2 = nil
	--self.BtnGo = nil
	--self.BtnTryRole = nil
	--self.FHorizontalBox_0 = nil
	--self.FHorizontalBtn = nil
	--self.IconArrow1 = nil
	--self.IconJob1 = nil
	--self.IconJob2 = nil
	--self.ImgLogo = nil
	--self.ImgPeople = nil
	--self.PanelArrow = nil
	--self.PanelBook = nil
	--self.PanelInfo_1 = nil
	--self.SizeBox1 = nil
	--self.SizeBox2 = nil
	--self.TextInfo = nil
	--self.TextRoleName = nil
	--self.TextTips = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AdventureJobPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AdventureJob1)
	self:AddSubView(self.AdventureJob2)
	self:AddSubView(self.BtnGo)
	self:AddSubView(self.BtnTryRole)
	self:AddSubView(self.TextInfo)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AdventureJobPanelView:OnInit()
	self.ViewModel = AdventureDetailVM.New()
end

function AdventureJobPanelView:OnShow()
	if not self.Params then return end
	self:OnSelectJobChange(self.Params.Prof or 0)
	UIUtil.SetIsVisible(self.BtnTryRole, self.Params.NeedRenderActor and true or false)
	self.BtnTryRole.TextOngoing:SetText(LSTR(520061))
	self.BtnGo.TextOngoing:SetText(LSTR(520062))
	self.AdapterProfTableView = UIAdapterTableView.CreateAdapter(self, self.TextInfo.TableViewLine, self.OnProfTableViewSelectChange, false)
	local EmptyTable = {}
	for i = 1, 15 do
		table.insert(EmptyTable, {})
	end
	self.AdapterProfTableView:UpdateAll(EmptyTable)
	UIUtil.ImageSetBrushFromAssetPath(self.BtnGo.ImgIcon, "Texture2D'/Game/UI/Texture/Adventure/UI_Adventure_JoB_Img_Go.UI_Adventure_JoB_Img_Go'")
end

--选中职业改变
function AdventureJobPanelView:OnSelectJobChange(Prof)
	self.TextInfo.RichText:ScrollToStart()
	self.ViewModel:OnSelectJobChange(Prof)
	self:PlayAnimation(self.AnimSelectChange)
end

function AdventureJobPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGo.BtnJob, self.OnClickOpenMap)
	UIUtil.AddOnClickedEvent(self, self.BtnTryRole.BtnJob, self.OnClickOpenSkillPanel)
end

--前往转职
function AdventureJobPanelView:OnClickOpenMap()
	local MajorUtil = require("Utils/MajorUtil")
	local RoleVM = MajorUtil.GetMajorRoleVM()
	local ProfList = RoleVM.ProfSimpleDataList
	local MaxLevel = 1
	for _, v in pairs(ProfList) do
		if v.Level > MaxLevel then
			MaxLevel = v.Level
		end
	end
	local StartQuestCfg = _G.AdventureCareerMgr:GetCurProfChangeProfData(self.ViewModel.Prof)
	if not StartQuestCfg or not next(StartQuestCfg) then return end
	--判断任务是否能够接取
	local QuestState = _G.QuestMgr:GetQuestStatus(StartQuestCfg.StartQuestID)
	if not QuestHelper.CheckCanActivate(StartQuestCfg.StartQuestID) and QuestState == ProtoCS.CS_QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED then
		if self.ViewModel.Specialization then
			if self.ViewModel.Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT then
				MsgTipsUtil.ShowTips(LSTR(1050227))
			else
				MsgTipsUtil.ShowTips(LSTR(1050228))
			end
		end
		return
	end

	local tLevel = StartQuestCfg.Level
	--战斗职业判断等级
	if self.ViewModel.Specialization and
	self.ViewModel.Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT then
		if MaxLevel < tLevel then
			MsgTipsUtil.ShowErrorTips(string.format(LSTR(520044), tLevel))
			return
		end
	end

	if QuestState == ProtoCS.CS_QUEST_STATUS.CS_QUEST_STATUS_IN_PROGRESS or 
	 QuestState == ProtoCS.CS_QUEST_STATUS.CS_QUEST_STATUS_CAN_SUBMIT or 
	 QuestState == ProtoCS.CS_QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
		_G.UIViewMgr:ShowView(_G.UIViewID.QuestLogMainPanel)
		return
	end
	
	_G.WorldMapMgr:ShowWorldMapQuest(StartQuestCfg.AcceptMapID, StartQuestCfg.AcceptUIMapID, StartQuestCfg.StartQuestID)

	if self.MapAnimationTimer and self.MapAnimationTimer ~= 0 then
		self:UnRegisterTimer(self.MapAnimationTimer)
	end
	local WorldMapPanel = _G.UIViewMgr:FindView(_G.UIViewID.WorldMapPanel)
	local MarkerView = WorldMapPanel.MapContent:GetMapMarkerByID(StartQuestCfg.StartQuestID)
	self.MapAnimationTimer = self:RegisterTimer(function()
		if MarkerView then
            MarkerView:playAnimation(MarkerView.AnimNew)
        end
	end, 0, 2.97, 3)
end


function AdventureJobPanelView:OnClickOpenSkillPanel()
	local Params = {IndependentView = true}
	_G.EquipmentMgr:SetPreviewProfID(true, self.ViewModel.Prof)
	_G.UIViewMgr:ShowView(_G.UIViewID.SkillMainPanel, Params)
end


function AdventureJobPanelView:OnRegisterBinder()
	local Binders = {
		{"JobName", UIBinderSetText.New(self, self.TextRoleName)},
		{"DetailText", UIBinderSetText.New(self, self.TextInfo.RichText)},
		{"PreviewText", UIBinderSetText.New(self, self.TextTips)},
		{"AdventureJobText1", UIBinderSetText.New(self, self.AdventureJob1.TextOngoing)},
		{"AdventureJobText2", UIBinderSetText.New(self, self.AdventureJob2.TextOngoing)},
		{"ButtonText",UIBinderSetText.New(self, self.BtnTryRole.TextContent)},


		{"LogoPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgLogo)},
		{"RoleImagePath", UIBinderSetBrushFromAssetPath.New(self, self.ImgPeople)},
		{"NowJobIcon", UIBinderSetBrushFromAssetPath.New(self, self.IconJob1)},
		{"NextJobIcon", UIBinderSetBrushFromAssetPath.New(self, self.IconJob2)},
		{"AdventureJobBg1", UIBinderSetBrushFromAssetPath.New(self, self.AdventureJob1.ImgBG)},
		{"AdventureJobBg2", UIBinderSetBrushFromAssetPath.New(self, self.AdventureJob2.ImgBG)},

		{"bIsShowNowJobIcon", UIBinderSetIsVisible.New(self, self.SizeBox1)},
		{"bIsShowNextJobIcon", UIBinderSetIsVisible.New(self, self.SizeBox2)},
		{"bIsArrowShow", UIBinderSetIsVisible.New(self, self.PanelArrow)},
		{"bIsPreviewTextShow", UIBinderSetIsVisible.New(self, self.TextPreview2)},
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

return AdventureJobPanelView