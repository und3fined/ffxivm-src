---
--- Author: Administrator
--- DateTime: 2024-08-26 19:37
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local SceneEnterTypeCfg = require("TableCfg/SceneEnterTypeCfg")
local UIBindableList = require("UI/UIBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgTipsID = require("Define/MsgTipsID")
local TeamDefine = require("Game/Team/TeamDefine")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
local MagicCardTourneyVMUtils = require("Game/MagicCardTourney/MagicCardTourneyVMUtils")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local TourneyVM = require("Game/MagicCardTourney/VM/MagicCardTourneyVM")
local MagicCardTourneyMgr = require("Game/MagicCardTourney/MagicCardTourneyMgr")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
local PWorldQuestDefine = require("Game/PWorld/Quest/PWorldQuestDefine")
local PWorldEntDetailVM = _G.PWorldEntDetailVM

---@class PWorldCardsMatchPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field BtnDown UFButton
---@field BtnExplan UFButton
---@field BtnJoin CommBtnLView
---@field BtnUp UFButton
---@field ImgWarning UFImage
---@field PanelLong UFCanvasPanel
---@field PanelShort UFCanvasPanel
---@field RichTextDate URichTextBox
---@field TableViewRewards UTableView
---@field TextAsk UFTextBlock
---@field TextAskContent UFTextBlock
---@field TextCardsBattle UFTextBlock
---@field TextCardsMatch UFTextBlock
---@field TextLimitTime UFTextBlock
---@field TextLong UFTextBlock
---@field TextMatchName UFTextBlock
---@field TextReward UFTextBlock
---@field TextShort UFTextBlock
---@field TextTime UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldCardsMatchPanelView = LuaClass(UIView, true)

function PWorldCardsMatchPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.BtnDown = nil
	--self.BtnExplan = nil
	--self.BtnJoin = nil
	--self.BtnUp = nil
	--self.ImgWarning = nil
	--self.PanelLong = nil
	--self.PanelShort = nil
	--self.RichTextDate = nil
	--self.TableViewRewards = nil
	--self.TextAsk = nil
	--self.TextAskContent = nil
	--self.TextCardsBattle = nil
	--self.TextCardsMatch = nil
	--self.TextLimitTime = nil
	--self.TextLong = nil
	--self.TextMatchName = nil
	--self.TextReward = nil
	--self.TextShort = nil
	--self.TextTime = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldCardsMatchPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.BtnJoin)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldCardsMatchPanelView:OnInit()
	self.AdpTbRewards = UIAdapterTableView.CreateAdapter(self, self.TableViewRewards, self.ShowRewardsDetail, true, false)
	self.MultiBinders = {
		{
			ViewModel = TourneyVM,
			Binders = {
				{ "PWorldTourneyInfoText",     UIBinderSetText.New(self, self.RichTextDate)},
				{ "PWorldTourneyCupName",      UIBinderSetText.New(self, self.TextMatchName)},
				{ "TourneyRewardVMs",    		UIBinderUpdateBindableList.New(self, self.AdpTbRewards)},
				{ "IsJoinBtnEnable",           	UIBinderSetIsEnabled.New(self, self.BtnJoin, false, true) },
				{ "JoinBtnText",        		UIBinderSetText.New(self, self.BtnJoin) },
			}
		},
		-- {
		-- 	ViewModel = PWorldEntDetailVM,
		-- 	Binders = {
		-- 		{ "IsJoinBtnEnable",           	UIBinderSetIsEnabled.New(self, self.BtnJoin, false, true) },
		-- 		{ "JoinBtnText",        		UIBinderSetText.New(self, self.BtnJoin) },
		-- 	}
		-- },
	}
	
end

function PWorldCardsMatchPanelView:OnDestroy()

end

function PWorldCardsMatchPanelView:SetLSTR()
    self.TextTitle:SetText(_G.LSTR(1150026))--("幻卡对局室")
	self.TextCardsBattle:SetText(_G.LSTR(1150026))--("幻卡对局室")
	self.TextCardsMatch:SetText(_G.LSTR(1150025))--("幻卡大赛")
	self.TextLimitTime:SetText(_G.LSTR(1150071))--("限制时间")
	self.TextAsk:SetText(_G.LSTR(1150072))--("要求")
    self.TextReward:SetText(_G.LSTR(1150065)) --("奖励")
	self.TextAskContent:SetText(_G.LSTR(1150073)) --("不可与其他任务同时参加")
end

function PWorldCardsMatchPanelView:OnShow()
	-- local EntSet = SceneEnterTypeCfg:GetPWorldEntIDs(self.TypeID) or {}
	-- if EntSet then
	-- 	local CardsEnt = EntSet[1]
	-- 	if CardsEnt then
	-- 		local Desc = CardsEnt.
	-- 	end
	-- end
	--PWorldEntDetailVM:SeletectPWorldByIndex(24)
	self:SetLSTR()
	local MatchRoomInfo = MagicCardTourneyVMUtils.GetMatchRoomInfo()
	if MatchRoomInfo == nil then
		return
	end
	local Duration = MatchRoomInfo.ExistTimeText --分钟
	local Summary = MatchRoomInfo.Summary or ""
	self.TextTime:SetText(Duration)
	self.TextLong:SetText(Summary)
	self.TextShort:SetText(Summary)
	UIUtil.SetIsVisible(self.BtnUp, false)
	UIUtil.SetIsVisible(self.TextShort, true)
	UIUtil.SetIsVisible(self.TextLong, false)
	local TextLines = self:GetTextLine(self.TextLong, Summary)
	if TextLines > 4 then
		UIUtil.SetIsVisible(self.BtnDown, true, true)
	else
		UIUtil.SetIsVisible(self.BtnDown, false)
	end
end

---@type 获取文本行数
function PWorldCardsMatchPanelView:GetTextLine(TextWidget, Text)
	if TextWidget == nil then
		return 0
	end
	local FontSize = TextWidget.Font.Size * 1.3
	local WidgetSize = UIUtil.GetWidgetSize(TextWidget)
	local PerLineCount = WidgetSize.X / FontSize
	local TextLength = self:GetStringWordNum(Text)
	if TextLength and TextLength > 0 then
		return math.ceil(TextLength / PerLineCount)
	end
	return 0
end

function PWorldCardsMatchPanelView:GetStringWordNum(str)
    local fontSize = 20
    local lenInByte = #str
    local count = 0
    local i = 1
    while true do
        local curByte = string.byte(str, i)
        if i > lenInByte then
            break
        end
        local byteCount = 1
        if curByte > 0 and curByte < 128 then
            byteCount = 1
        elseif curByte>=128 and curByte<224 then
            byteCount = 2
        elseif curByte>=224 and curByte<240 then
            byteCount = 3
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        else
            break
        end
        -- local char = string.sub(str, i, i+byteCount-1)
        i = i + byteCount
        count = count + 1
    end
    return count
end

function PWorldCardsMatchPanelView:OnHide()

end

function PWorldCardsMatchPanelView:OnRegisterUIEvent()
	--UIUtil.AddOnClickedEvent(self, self.BtnSelect, self.OnClickButtonItem)
	UIUtil.AddOnClickedEvent(self, self.BtnJoin, self.OnClickBtnJoin)
	UIUtil.AddOnClickedEvent(self, self.BtnDown, self.OnClickBtnDown)
	UIUtil.AddOnClickedEvent(self, self.BtnUp, self.OnClickBtnUp)
	self.BtnBack:AddBackClick(self, self.Hide)
end

function PWorldCardsMatchPanelView:OnRegisterGameEvent()

end

function PWorldCardsMatchPanelView:OnRegisterBinder()
	self:RegisterMultiBinders(self.MultiBinders)
end

local function GetMatchReqParams()
	local EntType = ProtoCommon.ScenePoolType.ScenePoolFantasyCard
	local EntID = PWorldEntUtil.GetMagicCardTourneyPWorldID() --PWorldEntDetailVM.CurEntID
	local Mode = PWorldQuestDefine.ClientSceneMode.SceneModeChocoboRoom --  PWorldEntDetailVM.TaskType
	local SubType = 0 --PWorldEntDetailVM.SubType
	return EntType, EntID, Mode, SubType
end

function PWorldCardsMatchPanelView:OnClickBtnJoin()
	if PWorldEntDetailVM.IsMatching then
		_G.MsgTipsUtil.ShowTipsByID(MsgTipsID.MatchRoomRefuseEnter, nil)
		return
	end
	
	if _G.TeamMgr:IsInTeam() and not _G.TeamMgr:IsCaptain() and not PWorldEntDetailVM.bMuren then
		_G.MsgTipsUtil.ShowTipsByID(MsgTipsID.PWorldMatchJoinOrCancelNoCaptain, nil)
		return
	end

	-- 如果在副本内，则无法进入对局室
	local IsInDungeon = _G.PWorldMgr:CurrIsInDungeon()
	if IsInDungeon then
		_G.MsgTipsUtil.ShowTipsByID(MsgTipsID.MatchRoomRefuseEnterInPworld, nil)
		return
	end

	-- 跳跳乐比较特殊，需要单独做个判断
	if (_G.GoldSauserLeapOfFaithMgr:IsCurMapLeapOfFaith()) then
		_G.MsgTipsUtil.ShowTipsByID(109014)
		return
	end

	self:JoinInner()
end

function PWorldCardsMatchPanelView:JoinInner()
	-- if not PWorldEntDetailVM.IsPreCheckPass then
	-- 	_G.FLOG_ERROR("PWorldCardsMatchPanelView:JoinInner IsPreCheckPass failed!")
	-- 	return
	-- end

	if _G.SidebarMgr:GetSidebarItemVM(SidebarDefine.SidebarType.PWorldEnterConfirm) or _G.UIViewMgr:FindVisibleView(_G.UIViewID.PWorldConfirm) ~= nil then
		_G.MsgTipsUtil.ShowTips(LSTR("进本准备中，无法进行匹配"))
		return
	end

	-- local IsJoinOK, Reasons = PWorldEntUtil.JoinCheck()

	-- if not IsJoinOK then
	-- 	PWorldEntUtil.ShowJoinFailedTips(Reasons)
	-- 	return
	-- end

	local IsEnter = PWorldEntUtil.EnterTest()
	local PWorldID = PWorldEntUtil.GetMagicCardTourneyPWorldID() --PWorldEntDetailVM.CurEntID
	local SMode = ProtoCommon.SceneMode.SceneModeNormal
	local EntTy = ProtoCommon.ScenePoolType.ScenePoolFantasyCard

	if _G.TeamMgr:IsInTeam() and _G.TeamMgr:IsCaptain() then
		_G.PWorldVoteMgr:ReqStartVoteEnterMagicCardTourneyRoom(PWorldID, EntTy, SMode)
	else
		if MagicCardTourneyMgr:GetIsInTourneyRomm() then
			return
		end

		-- 单人本进入
		local Cfg = require("TableCfg/SceneEnterCfg"):FindCfgByKey(PWorldID)
		_G.PWorldMgr:EnterSinglePWorld(Cfg and Cfg.SPID)
	end
end

function PWorldCardsMatchPanelView:OnClickBtnDown()
	UIUtil.SetIsVisible(self.BtnDown, false)
	UIUtil.SetIsVisible(self.BtnUp, true, true)
	UIUtil.SetIsVisible(self.TextShort, false)
	UIUtil.SetIsVisible(self.TextLong, true)
end

function PWorldCardsMatchPanelView:OnClickBtnUp()
	UIUtil.SetIsVisible(self.BtnDown, true, true)
	UIUtil.SetIsVisible(self.BtnUp, false)
	UIUtil.SetIsVisible(self.TextShort, true)
	UIUtil.SetIsVisible(self.TextLong, false)
end

function PWorldCardsMatchPanelView:ShowRewardsDetail(ItemIndex, ItemVM)
	if ItemIndex then
		local ItemView = self.AdpTbRewards:GetChildWidget(ItemIndex)
		ItemTipsUtil.ShowTipsByResID(ItemVM.ID, ItemView)
	end
end

return PWorldCardsMatchPanelView