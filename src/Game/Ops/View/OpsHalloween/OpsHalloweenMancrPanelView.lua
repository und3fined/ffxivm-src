---
--- Author: Administrator
--- DateTime: 2025-02-26 16:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local OpsHalloweenMancrPanelVM = require("Game/Ops/VM/OpsHalloween/OpsHalloweenMancrPanelVM")
local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")
local UIBinderUpdateCountDown = require("Binder/UIBinderUpdateCountDown")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local LocalizationUtil = require("Utils/LocalizationUtil")
local TimeUtil = require("Utils/TimeUtil")
local SaveKey = require("Define/SaveKey")
local ProtoRes = require ("Protocol/ProtoRes")
local SceneEnterCfg = require("TableCfg/SceneEnterCfg")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")
local OpsSeasonActivityDefine = require("Game/Ops/OpsSeasonActivityDefine")
local DataReportUtil = require("Utils/DataReportUtil")
local SCORE_TYPE = ProtoRes.SCORE_TYPE
local LSTR = _G.LSTR
local PumpkinCoin = 66500030
local OpsSeasonActivityMgr
---@class OpsHalloweenMancrPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackBtn CommBackBtnView
---@field BtnChallenge UFButton
---@field BtnGame UFButton
---@field BtnShop UFButton
---@field CommInforBtn_UIBP CommInforBtnView
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field Money CommMoneySlotView
---@field PanelMatch UFVerticalBox
---@field PanelTime UFHorizontalBox
---@field PanelTips UFCanvasPanel
---@field RedDot CommonRedDotView
---@field Tab1 OpsHalloweenMancrTabItemView
---@field Tab2 OpsHalloweenMancrTabItemView
---@field TableViewTask UTableView
---@field TextChallenge UFTextBlock
---@field TextClose UFTextBlock
---@field TextEstimatedTime UFTextBlock
---@field TextTime UFTextBlock
---@field TextTips UFTextBlock
---@field TextTitle UFTextBlock
---@field TextTitleGame UFTextBlock
---@field TextTitleShop UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimMatch UWidgetAnimation
---@field AnimMatchOff UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsHalloweenMancrPanelView = LuaClass(UIView, true)

function OpsHalloweenMancrPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackBtn = nil
	--self.BtnChallenge = nil
	--self.BtnGame = nil
	--self.BtnShop = nil
	--self.CommInforBtn_UIBP = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.Money = nil
	--self.PanelMatch = nil
	--self.PanelTime = nil
	--self.PanelTips = nil
	--self.RedDot = nil
	--self.Tab1 = nil
	--self.Tab2 = nil
	--self.TableViewTask = nil
	--self.TextChallenge = nil
	--self.TextClose = nil
	--self.TextEstimatedTime = nil
	--self.TextTime = nil
	--self.TextTips = nil
	--self.TextTitle = nil
	--self.TextTitleGame = nil
	--self.TextTitleShop = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimMatch = nil
	--self.AnimMatchOff = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsHalloweenMancrPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackBtn)
	self:AddSubView(self.CommInforBtn_UIBP)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	self:AddSubView(self.Money)
	self:AddSubView(self.RedDot)
	self:AddSubView(self.Tab1)
	self:AddSubView(self.Tab2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsHalloweenMancrPanelView:OnInit()
	OpsSeasonActivityMgr = _G.OpsSeasonActivityMgr
	self.ViewModel = OpsHalloweenMancrPanelVM.New()
	self.TableViewTaskAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTask)
	self.AdapterCountDownTime = UIAdapterCountDown.CreateAdapter(self, self.TextTime, "dd:hh", _G.LSTR(1560009), self.TimeOutCallback, self.TimeUpdateCallback)
	self.Binders = {
		{"ChallengeVisible", UIBinderSetIsVisible.New(self, self.TextChallenge)},
		{"MatchVisible", UIBinderSetIsVisible.New(self, self.PanelMatch)},
		{"EstimateWaitTimeDesc", UIBinderSetText.New(self, self.TextEstimatedTime)},
		{"CancelText", UIBinderSetText.New(self, self.TextClose)},
		
		{"ShowTimeText", UIBinderUpdateCountDown.New(self, self.AdapterCountDownTime, 1, true, false) },
		{"TipsVisible", UIBinderSetIsVisible.New(self, self.PanelTips)},
		{"TaskVMList", UIBinderUpdateBindableList.New(self, self.TableViewTaskAdapter)},
		{"TimeVisible", UIBinderSetIsVisible.New(self, self.PanelTime)},
		
    }

	self.CommInforBtn_UIBP:SetCheckClickedCallback(self, self.OnInforBtnClicked)
	
end

function OpsHalloweenMancrPanelView:OnDestroy()

end

function OpsHalloweenMancrPanelView:OnShow()
	self.Money:UpdateView(PumpkinCoin, false, nil, false)
	self.HauntedManorIndex = 1

	local MainActivity = OpsSeasonActivityMgr:GetSeasonActivity()
    if MainActivity == nil then
        return
    end

	local ChildrenActivitys = _G.OpsSeasonActivityMgr:GetChildrenActivityList(MainActivity.ActivityID)
	if ChildrenActivitys == nil or #ChildrenActivitys < 2 then
		return
	end

	self.ChildrenActivitys = ChildrenActivitys
	local Detail = _G.OpsActivityMgr.ActivityNodeMap[MainActivity.ActivityID] or {}
	local NodeList = Detail.NodeList or {}
	local Node, ActivityNode = OpsSeasonActivityMgr:NodeByNodeTitle(NodeList, LSTR(1560003))
	if Node and ActivityNode then
		self.HauntedManorNodeID = Node.Head.NodeID
        if ActivityNode.ParamNum >2 then
			self.HauntedManorIDs = {}
			table.insert(self.HauntedManorIDs, ActivityNode.Params[2])
			table.insert(self.HauntedManorIDs, ActivityNode.Params[3])
		end
    end 

	Node, ActivityNode = OpsSeasonActivityMgr:NodeByNodeTitle(NodeList, LSTR(1560002))
	if Node and ActivityNode then
        if ActivityNode then
			self.JumpType = ActivityNode.JumpType
			self.JumpParam = ActivityNode.JumpParam
        end
    end 
	
	self.Tab1:SetText(ChildrenActivitys[1].Title)
	self.Tab1:SetLock(false)
	self.Tab1:SetRedDotNameByString(OpsSeasonActivityMgr:GetRedDotName(tostring(MainActivity.ActivityID).."/"..tostring(self.HauntedManorNodeID).."/"..tostring(ChildrenActivitys[1].ActivityID)))

	self.RedDot:SetRedDotNameByString(OpsSeasonActivityMgr:GetRedDotName(tostring(MainActivity.ActivityID).."/"..tostring(self.HauntedManorNodeID).."/"..OpsSeasonActivityDefine.HalloweenMiniGame.."/"..tostring(ChildrenActivitys[1].ActivityID)))
	self.RedDot:SetStyle(RedDotDefine.RedDotStyle.SecondStyle)
	self:OnClickTab1()
	if #ChildrenActivitys > 1 then
		local ActivityTime = _G.OpsActivityMgr:GetActivityStartTime(ChildrenActivitys[2])
		self.ViewModel.ShowTimeText = ActivityTime
		self.Tab2:SetText(ChildrenActivitys[2].Title)
		self.Tab2:SetRedDotNameByString(OpsSeasonActivityMgr:GetRedDotName(tostring(MainActivity.ActivityID).."/"..tostring(self.HauntedManorNodeID).."/"..tostring(ChildrenActivitys[2].ActivityID)))
		if ActivityTime > TimeUtil.GetServerLogicTime() then
			self.ViewModel.TimeVisible = true
			self.HauntedManorIndex = 1
			self.Tab2:SetLock(true)
			self.TextTime:SetText(string.format(_G.LSTR(1560009), LocalizationUtil.GetCountdownTimeForLongTime(ActivityTime - TimeUtil.GetServerLogicTime() , "")))
		else
			self.ViewModel.TimeVisible = false
			self.Tab2:SetLock(false)
			self.HauntedManorIndex = 2
			self.RedDot:SetRedDotNameByString(OpsSeasonActivityMgr:GetRedDotName(tostring(MainActivity.ActivityID).."/"..tostring(self.HauntedManorNodeID).."/"..OpsSeasonActivityDefine.HalloweenMiniGame.."/"..tostring(ChildrenActivitys[2].ActivityID)))
		end
	end 

	local HalloweenMancrPrompt = _G.UE.USaveMgr.GetInt(SaveKey.HalloweenMancrPrompt, 0, true) or 0
	UIUtil.SetIsVisible(self.PanelTips, HalloweenMancrPrompt == 0)


	if self.HauntedManorIDs and #self.HauntedManorIDs > 1 then
		self.ViewModel:UpdateMatch(self.HauntedManorIDs[self.HauntedManorIndex])
	end
end

function OpsHalloweenMancrPanelView:TimeOutCallback()
	self.ViewModel.TimeVisible = false
	self.HauntedManorIndex = 2
	self.Tab2:SetLock(false)
end

function OpsHalloweenMancrPanelView:TimeUpdateCallback(LeftTime)
	return LocalizationUtil.GetCountdownTimeForLongTime(LeftTime, "")
end


function OpsHalloweenMancrPanelView:OnHide()

end

function OpsHalloweenMancrPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BackBtn.Button, self.OnClickBackBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnGame, self.OnClickGameBtn)
	UIUtil.AddOnClickedEvent(self, self.Tab1.ToggleBtnTab, self.OnClickTab1)
	UIUtil.AddOnClickedEvent(self, self.Tab2.ToggleBtnTab, self.OnClickTab2)

	UIUtil.AddOnClickedEvent(self, self.BtnShop, self.OnClickSeasonShopBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnChallenge, self.OnClickBtnChallengeBtn)
end

function OpsHalloweenMancrPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OpsActivityNodeGetReward, self.UpdateTaskInfo)

end

function OpsHalloweenMancrPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
	self.TextTitle:SetText(LSTR(1560003))
	self.TextTitleGame:SetText(LSTR(1560010))
	self.TextTitleShop:SetText(LSTR(1560002))
	self.TextTips:SetText(LSTR(1560011))
	self.TextChallenge:SetText(LSTR(1560012))
end

function OpsHalloweenMancrPanelView:OnClickBackBtn()
	self:Hide()
	if self.Params and self.Params.HideCallBack then
		self.Params.HideCallBack()
	end
end

function OpsHalloweenMancrPanelView:OnRegisterTimer()
    self:RegisterTimer(self.OnMatchTime, 0, 1, 0)
end

function OpsHalloweenMancrPanelView:UpdateTaskInfo()
	if self.ChildrenActivitys == nil then
		return
	end

	local ChildrenActivitys = self.ChildrenActivitys
	if #ChildrenActivitys < 2 then
		return
	end

	if self.CurIndex < 1 or self.CurIndex > #ChildrenActivitys then
		return
	end

	self.ViewModel:ShowTaskByActivityID(ChildrenActivitys[self.CurIndex])
end

function OpsHalloweenMancrPanelView:OnClickTab1()
	if self.ChildrenActivitys == nil then
		return
	end

	local ChildrenActivitys = self.ChildrenActivitys
	if #ChildrenActivitys < 2 then
		return
	end

	self.CurIndex = 1
	self.Tab1:SetChecked(true)
	self.Tab2:SetChecked(false)
	self.ViewModel:ShowTaskByActivityID(ChildrenActivitys[1])
	self.TableViewTaskAdapter:ScrollToTop()

end

function OpsHalloweenMancrPanelView:OnClickTab2()
	if self.ChildrenActivitys == nil then
		return
	end


	local ChildrenActivitys = self.ChildrenActivitys
	if #ChildrenActivitys < 2 then
		return
	end

	--[[if self.ViewModel.TimeVisible  == true then
		self.Tab2:SetChecked(false)
		return
	end]]--
	self.CurIndex = 2
	self.Tab1:SetChecked(false)
	self.Tab2:SetChecked(true)
	self.ViewModel:ShowTaskByActivityID(ChildrenActivitys[2])
	self.TableViewTaskAdapter:ScrollToTop()
end

function OpsHalloweenMancrPanelView:OnClickGameBtn()
	if self.ChildrenActivitys == nil then
		return
	end

	local ChildrenActivitys = self.ChildrenActivitys
	if #ChildrenActivitys < 2 then
		return
	end

	_G.UIViewMgr:ShowView(_G.UIViewID.OpsHalloweenGamePanel, {ChildrenActivitys = self.ChildrenActivitys})

	if self.ViewModel.TimeVisible  == true then
		_G.OpsSeasonActivityMgr:RecordRedDotClicked(ChildrenActivitys[1].ActivityID)
		DataReportUtil.ReportActivityFlowData("HauntedManor1ActionTypeClickFlow", self.HauntedManorNodeID, OpsSeasonActivityDefine.HauntedManor1ActionType.ClickedMiniGame)
	else
		_G.OpsSeasonActivityMgr:RecordRedDotClicked(ChildrenActivitys[1].ActivityID)
		_G.OpsSeasonActivityMgr:RecordRedDotClicked(ChildrenActivitys[2].ActivityID)
		DataReportUtil.ReportActivityFlowData("HauntedManor2ActionTypeClickFlow", self.HauntedManorNodeID, OpsSeasonActivityDefine.HauntedManor2ActionType.ClickedMiniGame)
	end
end

function OpsHalloweenMancrPanelView:UpdateMatch()
	if self.HauntedManorIDs and #self.HauntedManorIDs > 1 then
		self.ViewModel:UpdateMatch(self.HauntedManorIDs[self.HauntedManorIndex])
	end
end


function OpsHalloweenMancrPanelView:OnClickBtnChallengeBtn()
	_G.UE.USaveMgr.SetInt(SaveKey.HalloweenMancrPrompt, 1, true)
	UIUtil.SetIsVisible(self.PanelTips, false)

	if self.ViewModel.TimeVisible  == true then
		DataReportUtil.ReportActivityFlowData("HauntedManor1ActionTypeClickFlow", self.HauntedManorNodeID, OpsSeasonActivityDefine.HauntedManor1ActionType.ClickedChallenge)
	else
		DataReportUtil.ReportActivityFlowData("HauntedManor2ActionTypeClickFlow", self.HauntedManorNodeID, OpsSeasonActivityDefine.HauntedManor2ActionType.ClickedChallenge)
	end
	
	if self.HauntedManorIDs and #self.HauntedManorIDs > 1 then
		local Cfg = SceneEnterCfg:FindCfgByKey(self.HauntedManorIDs[self.HauntedManorIndex])
		if Cfg then
			if self.ViewModel.IsMatching == true then
				_G.PWorldMatchMgr:ReqCancelMatch(Cfg.TypeID, Cfg.ID)
				--self:PlayAnimation(self.AnimMatchOff)
			else
				_G.PWorldMatchMgr:ReqStartMatch(Cfg.TypeID, Cfg.ID)
				--self:PlayAnimation(self.AnimMatch)
			end
		end
	end
end

function OpsHalloweenMancrPanelView:OnMatchTime()
	if self.HauntedManorIDs and #self.HauntedManorIDs > 1 then
		self.ViewModel:UpdateMatch(self.HauntedManorIDs[self.HauntedManorIndex])

		if self.ViewModel.MatchChange == true then
			if self.ViewModel.MatchVisible == false then
				self:PlayAnimation(self.AnimMatchOff)
			elseif self.ViewModel.MatchVisible == true then
				self:PlayAnimation(self.AnimMatch)
			end
			self.ViewModel.MatchChange = false
		end
	end
end


function OpsHalloweenMancrPanelView:OnClickSeasonShopBtn()
	if self.JumpType == nil then
		return
	end
	_G.OpsActivityMgr:Jump(self.JumpType, self.JumpParam)
end

function OpsHalloweenMancrPanelView:OnInforBtnClicked()
	if self.ViewModel.TimeVisible  == true then
		DataReportUtil.ReportActivityFlowData("HauntedManor1ActionTypeClickFlow", self.HauntedManorNodeID, OpsSeasonActivityDefine.HauntedManor1ActionType.ClickedInfoBtn)
	else
		DataReportUtil.ReportActivityFlowData("HauntedManor2ActionTypeClickFlow", self.HauntedManorNodeID, OpsSeasonActivityDefine.HauntedManor2ActionType.ClickedInfoBtn)
	end
end


return OpsHalloweenMancrPanelView