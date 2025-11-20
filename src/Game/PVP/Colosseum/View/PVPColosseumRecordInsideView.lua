---
--- Author: Administrator
--- DateTime: 2025-08-07 15:35
--- Description:
---

local PVPColosseumMgr = require("Game/PVP/Colosseum/PVPColosseumMgr")
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TipsUtil = require("Utils/TipsUtil")
local PVPColosseumRecordInsideVM = require("Game/PVP/Colosseum/VM/PVPColosseumRecordInsideVM")
local PVPColosseumDefine = require("Game/PVP/Colosseum/PVPColosseumDefine")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateCountDown = require("Binder/UIBinderUpdateCountDown")
local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
---@class PVPColosseumRecordInsideView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field CommonPopUpBG CommonPopUpBGView
---@field IconA1 UFImage
---@field IconA2 UFImage
---@field IconD1 UFImage
---@field IconD2 UFImage
---@field IconK1 UFImage
---@field IconK2 UFImage
---@field IconTeamA1 UFImage
---@field IconTeamA1Btn UFButton
---@field IconTeamA2 UFImage
---@field IconTeamA2Btn UFButton
---@field IconTeamD1 UFImage
---@field IconTeamD1Btn UFButton
---@field IconTeamD2 UFImage
---@field IconTeamD2Btn UFButton
---@field IconTeamK1 UFImage
---@field IconTeamK1Btn UFButton
---@field IconTeamK2 UFImage
---@field IconTeamK2Btn UFButton
---@field IconTeamTime1 UFImage
---@field IconTeamTime1Btn UFButton
---@field IconTeamTime2 UFImage
---@field IconTeamTime2Btn UFButton
---@field ImgS UFImage
---@field ImgV UFImage
---@field PanelMidKDA UFCanvasPanel
---@field PanelMidRecord UFCanvasPanel
---@field PanelVS UFCanvasPanel
---@field TableViewKDARecord1 UTableView
---@field TableViewKDARecord2 UTableView
---@field TextA1 UFTextBlock
---@field TextA2 UFTextBlock
---@field TextD1 UFTextBlock
---@field TextD2 UFTextBlock
---@field TextHurt1 UFTextBlock
---@field TextHurt2 UFTextBlock
---@field TextInTreatment1 UFTextBlock
---@field TextInTreatment2 UFTextBlock
---@field TextInjured1 UFTextBlock
---@field TextInjured2 UFTextBlock
---@field TextK1 UFTextBlock
---@field TextK2 UFTextBlock
---@field TextName1 UFTextBlock
---@field TextName2 UFTextBlock
---@field TextProgress1 UFTextBlock
---@field TextProgress2 UFTextBlock
---@field TextSwitch UFTextBlock
---@field ToggleBtnSwitch UToggleButton
---@field VS UFCanvasPanel
---@field AnimFail UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimVictory UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPColosseumRecordInsideView = LuaClass(UIView, true)

function PVPColosseumRecordInsideView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.CommonPopUpBG = nil
	--self.IconA1 = nil
	--self.IconA2 = nil
	--self.IconD1 = nil
	--self.IconD2 = nil
	--self.IconK1 = nil
	--self.IconK2 = nil
	--self.IconTeamA1 = nil
	--self.IconTeamA1Btn = nil
	--self.IconTeamA2 = nil
	--self.IconTeamA2Btn = nil
	--self.IconTeamD1 = nil
	--self.IconTeamD1Btn = nil
	--self.IconTeamD2 = nil
	--self.IconTeamD2Btn = nil
	--self.IconTeamK1 = nil
	--self.IconTeamK1Btn = nil
	--self.IconTeamK2 = nil
	--self.IconTeamK2Btn = nil
	--self.IconTeamTime1 = nil
	--self.IconTeamTime1Btn = nil
	--self.IconTeamTime2 = nil
	--self.IconTeamTime2Btn = nil
	--self.ImgS = nil
	--self.ImgV = nil
	--self.PanelMidKDA = nil
	--self.PanelMidRecord = nil
	--self.PanelVS = nil
	--self.TableViewKDARecord1 = nil
	--self.TableViewKDARecord2 = nil
	--self.TextA1 = nil
	--self.TextA2 = nil
	--self.TextD1 = nil
	--self.TextD2 = nil
	--self.TextHurt1 = nil
	--self.TextHurt2 = nil
	--self.TextInTreatment1 = nil
	--self.TextInTreatment2 = nil
	--self.TextInjured1 = nil
	--self.TextInjured2 = nil
	--self.TextK1 = nil
	--self.TextK2 = nil
	--self.TextName1 = nil
	--self.TextName2 = nil
	--self.TextProgress1 = nil
	--self.TextProgress2 = nil
	--self.TextSwitch = nil
	--self.ToggleBtnSwitch = nil
	--self.VS = nil
	--self.AnimFail = nil
	--self.AnimOut = nil
	--self.AnimVictory = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPColosseumRecordInsideView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommonPopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPColosseumRecordInsideView:OnInit()
	self.AdapterTableViewRecord1 = UIAdapterTableView.CreateAdapter(self, self.TableViewKDARecord1)
	self.AdapterTableViewRecord2 = UIAdapterTableView.CreateAdapter(self, self.TableViewKDARecord2)

	self.Binders =
	{
        { "Goal_Team1", UIBinderSetText.New(self, self.TextProgress1) },
		{ "Goal_Team2", UIBinderSetText.New(self, self.TextProgress2) },
		{ "TotalKillCount_Team1", UIBinderSetText.New(self, self.TextK1) },
		{ "TotalDeadCount_Team1", UIBinderSetText.New(self, self.TextD1) },
		{ "TotalAssistCount_Team1", UIBinderSetText.New(self, self.TextA1) },
		{ "TotalKillCount_Team2", UIBinderSetText.New(self, self.TextK2) },
		{ "TotalDeadCount_Team2", UIBinderSetText.New(self, self.TextD2) },
		{ "TotalAssistCount_Team2", UIBinderSetText.New(self, self.TextA2) },

		{ "ShowData", UIBinderSetIsVisible.New(self, self.PanelMidRecord) },
		{ "ShowData", UIBinderSetIsVisible.New(self, self.PanelMidKDA, true) },
		{ "ShowData", UIBinderSetIsChecked.New(self, self.ToggleBtnSwitch)},
		{ "ShowData", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedShowData) },

		{ "LeftTeamRecordInsideList", UIBinderUpdateBindableList.New(self, self.AdapterTableViewRecord1) },
		{ "RightTeamRecordInsideList", UIBinderUpdateBindableList.New(self, self.AdapterTableViewRecord2) },
	}
end

function PVPColosseumRecordInsideView:OnDestroy()

end

function PVPColosseumRecordInsideView:OnShow()
	self:InitText()
	self:SetupTeam()
	self:OnTimerReqRecordData()
end

function PVPColosseumRecordInsideView:OnHide()

end

function PVPColosseumRecordInsideView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnSwitch, self.OnClickBtnSwitch)

	UIUtil.AddOnClickedEvent(self, self.IconTeamK1Btn, self.OnClickBtnK, self.IconTeamK1Btn)
	UIUtil.AddOnClickedEvent(self, self.IconTeamD1Btn, self.OnClickBtnD, self.IconTeamD1Btn)
	UIUtil.AddOnClickedEvent(self, self.IconTeamA1Btn, self.OnClickBtnA, self.IconTeamA1Btn)
	UIUtil.AddOnClickedEvent(self, self.IconTeamTime1Btn, self.OnClickBtnTime, self.IconTeamTime1Btn)
	UIUtil.AddOnClickedEvent(self, self.IconTeamK2Btn, self.OnClickBtnK, self.IconTeamK2Btn)
	UIUtil.AddOnClickedEvent(self, self.IconTeamD2Btn, self.OnClickBtnD, self.IconTeamD2Btn)
	UIUtil.AddOnClickedEvent(self, self.IconTeamA2Btn, self.OnClickBtnA, self.IconTeamA2Btn)
	UIUtil.AddOnClickedEvent(self, self.IconTeamTime2Btn, self.OnClickBtnTime, self.IconTeamTime2Btn)
end

function PVPColosseumRecordInsideView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.ShowUI, self.GameEventOnShowView)
end

function PVPColosseumRecordInsideView:OnRegisterBinder()
	self:RegisterBinders(PVPColosseumRecordInsideVM, self.Binders)
end

function PVPColosseumRecordInsideView:GameEventOnShowView(ViewID)
	if ViewID == nil then
        return
    end
	-- 结算时，关闭当前界面
	if ViewID == _G.UIViewID.PVPColosseumRecord then
		self:Hide()
	end
end

-- 点击图标提示
function PVPColosseumRecordInsideView:ShowBtnTips(Widget, Content)
	local WidgetSize = UIUtil.GetLocalSize(Widget)
	TipsUtil.ShowInfoTips(Content, Widget, _G.UE.FVector2D(-WidgetSize.X/2-10, 0), _G.UE.FVector2D(0.5, 1), false)
end

function PVPColosseumRecordInsideView:OnClickBtnK(Params)
	self:ShowBtnTips(Params, LSTR(810037))
end

function PVPColosseumRecordInsideView:OnClickBtnD(Params)
	self:ShowBtnTips(Params, LSTR(810038))
end

function PVPColosseumRecordInsideView:OnClickBtnA(Params)
	self:ShowBtnTips(Params, LSTR(810039))
end

function PVPColosseumRecordInsideView:OnClickBtnTime(Params)
	self:ShowBtnTips(Params, LSTR(810040))
end

-- 切换显示战绩还是数据
function PVPColosseumRecordInsideView:OnClickBtnSwitch()
	PVPColosseumRecordInsideVM:SwitchShowData()
end

function PVPColosseumRecordInsideView:OnValueChangedShowData(Value)
	if Value then
		self.TextSwitch:SetText(LSTR(810008)) -- "数据"
	else
		self.TextSwitch:SetText(LSTR(810007)) -- "战绩"
	end
end

function PVPColosseumRecordInsideView:InitText()
	self.TextHurt1:SetText(LSTR(810004)) -- "伤害量"
	self.TextInjured1:SetText(LSTR(810005)) -- "受伤量"
	self.TextInTreatment1:SetText(LSTR(810006)) -- "治疗量"
	self.TextHurt2:SetText(LSTR(810004))
	self.TextInjured2:SetText(LSTR(810005))
	self.TextInTreatment2:SetText(LSTR(810006))
end

-- 初始化队伍红蓝方显示，左边固定是蓝方，右边固定是红方，我方队伍为蓝方
function PVPColosseumRecordInsideView:SetupTeam()
	local TeamConfig =
	{
		-- 队伍名称
		StarName = LSTR(810001),
		SpiritName = LSTR(810002),

		-- 队伍标记
		BlueStarIcon = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPColosseum_Img_BlueStar.UI_PVPColosseum_Img_BlueStar'",
		BlueSpiritIcon = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPColosseum_Img_BlueSpirit.UI_PVPColosseum_Img_BlueSpirit'",
		RedStarIcon =  "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPColosseum_Img_RedStar.UI_PVPColosseum_Img_RedStar'",
		RedSpiritIcon = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPColosseum_Img_RedSpirit.UI_PVPColosseum_Img_RedSpirit'",
	}

    local MyTeamIndex = _G.PVPColosseumMgr:GetTeamIndex()
    if MyTeamIndex == PVPColosseumDefine.ColosseumTeam.COLOSSEUM_TEAM_1 then
		self.TextName1:SetText(TeamConfig.StarName)
		self.TextName2:SetText(TeamConfig.SpiritName)
		--UIUtil.ImageSetBrushFromAssetPath(self.ImgFlagA1, TeamConfig.BlueStarIcon)
		--UIUtil.ImageSetBrushFromAssetPath(self.ImgFlagA2, TeamConfig.RedSpiritIcon)
    else
		self.TextName1:SetText(TeamConfig.SpiritName)
		self.TextName2:SetText(TeamConfig.StarName)
		--UIUtil.ImageSetBrushFromAssetPath(self.ImgFlagA1, TeamConfig.BlueSpiritIcon)
		--UIUtil.ImageSetBrushFromAssetPath(self.ImgFlagA2, TeamConfig.RedStarIcon)
    end
end

---@type 每隔一段时间请求战绩数据
function PVPColosseumRecordInsideView:OnTimerReqRecordData()
	local function ReqRecordInside()
		PVPColosseumMgr:RequestRecordInside()
	end
	self:RegisterTimer(ReqRecordInside, 0, 1, 0)
end

return PVPColosseumRecordInsideView