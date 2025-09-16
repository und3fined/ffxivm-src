---
--- Author: Administrator
--- DateTime: 2024-08-05 10:01
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local MajorUtil = require("Utils/MajorUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetFrameIcon = require("Binder/UIBinderSetFrameIcon")

local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
-- local UIBinderSetCommPlayerHeadIcon = require("Binder/UIBinderSetCommPlayerHeadIcon")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local HeadFrameCfg = require("TableCfg/HeadFrameCfg")

local PersonPortraitHeadDefine = require("Game/PersonPortraitHead/PersonPortraitHeadDefine")

local PersonPortraitHeadHelper = require("Game/PersonPortraitHead/PersonPortraitHeadHelper")
local TabMainKey = PersonPortraitHeadDefine.EditTabMainKey
local LOG = _G.FLOG_INFO
local PersonPortraitHeadVM
local PersonPortraitHeadMgr

---@class PersonInfoHeadWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDelete UFButton
---@field BtnUnlockFrame CommBtnMView
---@field BtnUse CommBtnMView
---@field BtnUse2 CommBtnMView
---@field Comm2FrameL_UIBP Comm2FrameLView
---@field FramePanel UFCanvasPanel
---@field HeadPanel UFCanvasPanel
---@field Menu CommMenuView
---@field PanelCustom UFCanvasPanel
---@field PanelDefault UFCanvasPanel
---@field PanelList UFCanvasPanel
---@field PanelPlayer UFCanvasPanel
---@field PanelPlayer2 UFCanvasPanel
---@field PersonInfoPlayer PersonInfoPlayerItemView
---@field PersonInfoPlayer2 PersonInfoPlayerItemView
---@field TableViewCustom UTableView
---@field TableViewDefault UTableView
---@field TableViewFrame UTableView
---@field TextCustom UFTextBlock
---@field TextDefault UFTextBlock
---@field TextNot UFTextBlock
---@field TextPlayer UFTextBlock
---@field TextPlayer2 UFTextBlock
---@field TextPlayer3 UFTextBlock
---@field TextRoad UFTextBlock
---@field TextTime UFTextBlock
---@field AnimChangeMenu UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoHeadWinView = LuaClass(UIView, true)

function PersonInfoHeadWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnDelete = nil
	--self.BtnUnlockFrame = nil
	--self.BtnUse = nil
	--self.BtnUse2 = nil
	--self.Comm2FrameL_UIBP = nil
	--self.FramePanel = nil
	--self.HeadPanel = nil
	--self.Menu = nil
	--self.PanelCustom = nil
	--self.PanelDefault = nil
	--self.PanelList = nil
	--self.PanelPlayer = nil
	--self.PanelPlayer2 = nil
	--self.PersonInfoPlayer = nil
	--self.PersonInfoPlayer2 = nil
	--self.TableViewCustom = nil
	--self.TableViewDefault = nil
	--self.TableViewFrame = nil
	--self.TextCustom = nil
	--self.TextDefault = nil
	--self.TextNot = nil
	--self.TextPlayer = nil
	--self.TextPlayer2 = nil
	--self.TextPlayer3 = nil
	--self.TextRoad = nil
	--self.TextTime = nil
	--self.AnimChangeMenu = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoHeadWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnUnlockFrame)
	self:AddSubView(self.BtnUse)
	self:AddSubView(self.BtnUse2)
	self:AddSubView(self.Comm2FrameL_UIBP)
	self:AddSubView(self.Menu)
	self:AddSubView(self.PersonInfoPlayer)
	self:AddSubView(self.PersonInfoPlayer2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoHeadWinView:OnInit()
	self.AdpTableHeadFixed = UIAdapterTableView.CreateAdapter(self, self.TableViewDefault, self.OnAdpSletHeadFixed)
	self.AdpTableHeadCust = UIAdapterTableView.CreateAdapter(self, self.TableViewCustom, self.OnAdpSletHeadCust)
	self.AdpTableFrame = UIAdapterTableView.CreateAdapter(self, self.TableViewFrame, self.OnAdpSletFrame)

	PersonPortraitHeadVM = _G.PersonPortraitHeadVM
	PersonPortraitHeadMgr = _G.PersonPortraitHeadMgr

	self.Binders = 
	{
		{ "FrameVMList", 			UIBinderUpdateBindableList.New(self, self.AdpTableFrame) },
		{ "HeadMainFixedVMList", 	UIBinderUpdateBindableList.New(self, self.AdpTableHeadFixed) },
		{ "HeadMainCustVMList", 	UIBinderUpdateBindableList.New(self, self.AdpTableHeadCust) },
		-----
		{ "IsShowHeadPanel", 	UIBinderSetIsVisible.New(self, self.HeadPanel) },
		{ "IsShowFramePanel", 	UIBinderSetIsVisible.New(self, self.FramePanel) },
		-----
		{ "CurHeadVM", 			UIBinderValueChangedCallback.New(self, nil, self.OnValChgCurHead) },
		{ "CurFrameVM", 		UIBinderValueChangedCallback.New(self, nil, self.OnValChgCurFrame) },
		-----
		{ "InUseFrameID", 		UIBinderValueChangedCallback.New(self, nil, self.OnValChgInUseFrameID) },
		{ "CurHeadInfo", 		UIBinderValueChangedCallback.New(self, nil, self.OnValChgHeadInfo) },
		-----
		{ "HasHistoryHeads", 	UIBinderSetIsVisible.New(self, self.BtnHistoryHead, nil, true) },

		{ "LastUseCustHead", 	UIBinderValueChangedCallback.New(self, nil, self.OnValChgLastUseCustHead) },
	}

	self.MajorVMBinders = 
	{
		{ "HeadInfo", 				UIBinderValueChangedCallback.New(self, nil, self.OnValChgRoleInfo) },
		{ "HeadFrameID", 			UIBinderSetFrameIcon.New(self, self.PersonInfoPlayer.ImgFrame) },
	}

	self:InitLSTR()
end

function PersonInfoHeadWinView:InitLSTR()
	self.Comm2FrameL_UIBP.FText_Title:SetText(LSTR(960032))
	self.TextDefault:SetText(LSTR(960036))
	self.TextCustom:SetText(LSTR(960037))
	self.TextNot:SetText(LSTR(960047))
	self.BtnUnlockFrame:SetText(LSTR(960048))
end

function PersonInfoHeadWinView:OnDestroy()

end

function PersonInfoHeadWinView:OnShow()
	self.Menu:UpdateItems(PersonPortraitHeadVM:GetEditPanelTab(), false)
	self.Menu:SetSelectedKey(TabMainKey.Head, true)
	PersonPortraitHeadMgr:ReqGetFrame()
end

function PersonInfoHeadWinView:OnHide()
	self:EndTimerFrameCountDown()
end

function PersonInfoHeadWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnUse, self.OnBtnHeadSet)
	UIUtil.AddOnClickedEvent(self, self.BtnUnlockFrame, self.OnBtnUnlockFrame)
	UIUtil.AddOnClickedEvent(self, self.BtnUse2, self.OnBtnFrameSave)
	UIUtil.AddOnClickedEvent(self, self.BtnDelete, self.OnBtnDelete)
	UIUtil.AddOnClickedEvent(self, self.BtnHistoryHead, self.OnBtnHistoryHead)

	
	UIUtil.AddOnSelectionChangedEvent(self, self.Menu, 			self.OnSelectionChangedMenu)
end

function PersonInfoHeadWinView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.PersonHeadFrameListUpd, self.OnEvePersonHeadFrameListUpd)
end

function PersonInfoHeadWinView:OnRegisterBinder()
	self:RegisterBinders(PersonPortraitHeadVM, self.Binders)

	self.RoleVM = MajorUtil.GetMajorRoleVM()
	if self.RoleVM then
		self:RegisterBinders(self.RoleVM, self.MajorVMBinders)
	end
end

-------------------------------------------------------------------------------------------------------
---@region event handles

--- game event

function PersonInfoHeadWinView:OnEvePersonHeadFrameListUpd()
	local CurFrameVM = PersonPortraitHeadVM.CurFrameVM
	if CurFrameVM then
		self:OnValChgCurFrame(CurFrameVM)
	end
end

--- ui event

function PersonInfoHeadWinView:OnBtnUnlockFrame()
	local CurFrameVM = PersonPortraitHeadVM.CurFrameVM
	if CurFrameVM and CurFrameVM.PropID then
		_G.BagMgr:UseItem(CurFrameVM.PropID)
		_G.EventMgr:SendEvent(_G.EventID.PersonHeadFrameUnlock, CurFrameVM.FrameResID )
	end
end

function PersonInfoHeadWinView:OnBtnHeadSet()
	local CurHeadVM = PersonPortraitHeadVM.CurHeadVM
	local CurHeadInfo = PersonPortraitHeadMgr.CurHeadInfo or {}

	if not CurHeadVM then
		self:SeltCurHead()
		return
	end

	if CurHeadVM.HeadType == CurHeadInfo.HeadType and
		CurHeadVM.OptKey == CurHeadInfo.HeadIdx then
			MsgTipsUtil.ShowTips(LSTR(960019))
			return
	end

	PersonPortraitHeadMgr:ReqSetHead(CurHeadVM.OptKey, CurHeadVM.HeadType)
	MsgTipsUtil.ShowTips(LSTR(960004))
end

function PersonInfoHeadWinView:OnBtnDelete()
	local CurHeadVM = PersonPortraitHeadVM.CurHeadVM
	if CurHeadVM then
		PersonPortraitHeadMgr:TryDeleteCustHead(CurHeadVM.HeadCustID)
	end
end

function PersonInfoHeadWinView:OnBtnHistoryHead()
	_G.UIViewMgr:ShowView(_G.UIViewID.PersonInfoHeadHistoryPanel)
end

function PersonInfoHeadWinView:OnBtnFrameSave()
	local CurFrameID = PersonPortraitHeadMgr.CurFrameID or 1
	local SeltFrameID = (PersonPortraitHeadVM.CurFrameVM or {}).FrameResID 

	if SeltFrameID == CurFrameID then
		MsgTipsUtil.ShowTips(LSTR(960020))
	end

	PersonPortraitHeadMgr:ReqSetFrame(SeltFrameID)
end

function PersonInfoHeadWinView:OnAdpSletHeadFixed(_, ItemData)
	if nil == ItemData then
		return
	end

	LOG('[PersonHead][PersonInfoHeadWinView][OnAdpSletHeadFixed] Idx = ' .. tostring(ItemData.Idx))

	PersonPortraitHeadVM.CurHeadVM = ItemData
end

function PersonInfoHeadWinView:OnAdpSletHeadCust(_, ItemData)
	if nil == ItemData then
		return
	end

	if ItemData.IsEmpty then
		ItemData.IsSelt = false
		return
		--
	end

	LOG('[PersonHead][PersonInfoHeadWinView][OnAdpSletHeadCust] Idx = ' .. tostring(ItemData.Idx))

	PersonPortraitHeadVM.CurHeadVM = ItemData
end

function PersonInfoHeadWinView:OnAdpSletFrame(_, ItemData)
	if nil == ItemData then
		return
	end

	LOG('[PersonHead][PersonInfoHeadWinView][OnAdpSletFrame] Idx = ' .. tostring(ItemData.Idx))

	PersonPortraitHeadVM.CurFrameVM = ItemData
	self:UpdHeadUseBtnStat()
end

function PersonInfoHeadWinView:UpdFrameUseBtnStat()
	local CurVM = PersonPortraitHeadVM.CurFrameVM
	if CurVM then

		if CurVM.FrameResID == PersonPortraitHeadMgr.CurFrameID then
			self.BtnUse2:SetIsEnabled(false, true)
			self.BtnUse2:SetText(LSTR(960002))
			return
		end
	end

	self.BtnUse2:SetText(LSTR(960001))
	self.BtnUse2:SetIsEnabled(true, true)
end

function PersonInfoHeadWinView:OnSelectionChangedMenu(_, ItemData)
	-- PersonPortraitHeadMgr:ReqSetHeadGuideRedPoint()

	if nil == ItemData then
		return
	end

	PersonPortraitHeadVM:SetEditCurTab(ItemData:GetKey())

	if ItemData:GetKey() == PersonPortraitHeadDefine.EditTabMainKey.Head then
		self:SeltCurHead()
		self:EndTimerFrameCountDown()
	else
		self:SeltCurFrame()
	end

	self:PlayAnimation(self.AnimChangeMenu)
end

function PersonInfoHeadWinView:OnValChgHeadInfo(Val)
	self:UpdHeadUseBtnStat()
end

function PersonInfoHeadWinView:OnValChgInUseFrameID(Val)
	self:UpdFrameUseBtnStat()
end



function PersonInfoHeadWinView:OnValChgLastUseCustHead(Val)
	if not Val then
		return
	end

	self:SeltCurHead()
end

function PersonInfoHeadWinView:OnValChgCurFrame(Val)
	if not Val then
		return
	end

	UIUtil.ImageSetBrushFromAssetPath(self.PersonInfoPlayer2.ImgFrame, Val.FrameIcon)
	self.TextPlayer2:SetText(Val.FrameName)
	self.TextPlayer3:SetText(Val.FrameDesc)
	-- UIUtil.SetIsVisible(self.TextTime, false)
	-- UIUtil.SetIsVisible(self.TextRoad, false)

	
	UIUtil.SetIsVisible(self.TextNot, (not Val.IsUnlock) and (not Val.CanUnlock))
	UIUtil.SetIsVisible(self.BtnUse2, Val.IsUnlock, true)
	UIUtil.SetIsVisible(self.BtnUnlockFrame, Val.CanUnlock, true)

	self:UpdFrameUseBtnStat()
	self:UpdFrameLifeTimeAndAccess()
end

function PersonInfoHeadWinView:UpdFrameLifeTimeAndAccess()
	local CurVM = PersonPortraitHeadVM.CurFrameVM
	if not CurVM then
		return
	end

	local ResID = CurVM.FrameResID
    local Cfg = HeadFrameCfg:FindCfgByKey(ResID) or {}

	-- Cfg.LifeTimeDesc = "生命周期描述xx"

	if Cfg.LifeTimeDesc and not string.isnilorempty(Cfg.LifeTimeDesc) then
		self.TextTime:SetText(Cfg.LifeTimeDesc)
	else
		local LifeTime = tonumber(Cfg.Timelimit) or 0
		if LifeTime == 0 then
			self.TextTime:SetText(LSTR(960045))
		else
			self:StartTimerFrameCountDown()
		end
	end

	self.TextRoad:SetText(Cfg.Access or '')
end

function PersonInfoHeadWinView:StartTimerFrameCountDown()
	self:EndTimerFrameCountDown()
	self.TimerFrameCountDownID = self:RegisterTimer(self.OnTimerFrameCountDown, 0, 1, 0)
end

function PersonInfoHeadWinView:EndTimerFrameCountDown()
	if self.TimerFrameCountDownID then
		self:UnRegisterTimer(self.TimerFrameCountDownID)
		self.TimerFrameCountDownID = nil
	end
end

function PersonInfoHeadWinView:OnTimerFrameCountDown()
	local CurVM = PersonPortraitHeadVM.CurFrameVM
	if not CurVM then
		self:EndTimerFrameCountDown()
		return 
	end

	local ResID = CurVM.FrameResID
	local Text = PersonPortraitHeadMgr:GetFrameRemainTime(ResID)
	self.TextTime:SetText(Text)
end

function PersonInfoHeadWinView:OnValChgCurHead(Val)
	if not Val then
		self:SeltCurHead()
		return
	end

	if Val.HeadType == PersonPortraitHeadDefine.HeadType.Default then
		self.AdpTableHeadCust:CancelSelected()
        UIUtil.ImageSetMaterialTextureFromAssetPathSync(self.PersonInfoPlayer.ImgPlayer, Val.HeadIcon, 'Texture')
		UIUtil.SetIsVisible(self.BtnDelete, false)
		self.TextPlayer:SetText(Val.HeadName)
	elseif Val.HeadType == PersonPortraitHeadDefine.HeadType.Custom then
		self.AdpTableHeadFixed:CancelSelected()
		UIUtil.SetIsVisible(self.BtnDelete, true, true)
		PersonPortraitHeadHelper.SetHeadByUrl(self.PersonInfoPlayer.ImgPlayer, Val.HeadIconUrl, "PersonInfoHeadWinView:OnValChgCurHead")
		self.TextPlayer:SetText(LSTR(960044) .. tostring(Val.Idx))
	end

	self:UpdHeadUseBtnStat()
end


function PersonInfoHeadWinView:UpdHeadUseBtnStat()
	local CurVM = PersonPortraitHeadVM.CurHeadVM
	if CurVM then

		if CurVM.IsInUse then
			self.BtnUse:SetIsEnabled(false, true)
			self.BtnUse:SetText(LSTR(960002))
			return
		end
	end

	self.BtnUse:SetText(LSTR(960001))
	self.BtnUse:SetIsEnabled(true, true)
end

function PersonInfoHeadWinView:OnValChgRoleInfo(Val)
	PersonPortraitHeadHelper.SetMajorHead(self.PersonInfoPlayer2.ImgPlayer)
end

-- function PersonInfoHeadWinView:OnValChgCurHead(Val)
-- 	print('PersonInfoHeadWinView:OnValChgCurHead')
-- 	PersonPortraitHeadHelper.SetHeadByRoleVM(self.PersonInfoPlayer.ImgPlayer, _G.PersonInfoVM.RoleVM)
-- end

-------------------------------------------------------------------------------------------------------
---@region logic

function PersonInfoHeadWinView:SeltCurHead()
	local CurType
	local CurIdx
	if PersonPortraitHeadVM.LastUseCustHead then
		CurType = PersonPortraitHeadDefine.HeadType.Custom
		CurIdx = #PersonPortraitHeadMgr.HeadCustList
		PersonPortraitHeadVM.LastUseCustHead = nil

		if CurType == PersonPortraitHeadDefine.HeadType.Default then
			self.AdpTableHeadFixed:SetSelectedIndex(CurIdx)
		elseif CurType == PersonPortraitHeadDefine.HeadType.Custom then
			-- local List = PersonPortraitHeadMgr.HeadCustList
			-- local Idx = 1
			-- for _, Item in pairs(List or {}) do
			-- 	if Item.HeadID == CurIdx then
			-- 		Idx = Item.HeadIdx
			-- 		break
			-- 	end
			-- end
			self.AdpTableHeadCust:SetSelectedIndex(CurIdx)
		end
	else
		local HeadInfo = PersonPortraitHeadMgr.CurHeadInfo
		CurType = HeadInfo.HeadType or PersonPortraitHeadDefine.HeadType.Default
		CurIdx = HeadInfo.HeadIdx or 1

		if CurType == PersonPortraitHeadDefine.HeadType.Default then
			self.AdpTableHeadFixed:SetSelectedIndex(CurIdx)
		elseif CurType == PersonPortraitHeadDefine.HeadType.Custom then
			local List = PersonPortraitHeadMgr.HeadCustList
			local Idx = 1
			for _, Item in pairs(List or {}) do
				if Item.HeadID == CurIdx then
					Idx = Item.HeadIdx
					break
				end
			end
			self.AdpTableHeadCust:SetSelectedIndex(Idx)
		end
	end
end

function PersonInfoHeadWinView:SeltCurFrame()
	self.AdpTableFrame:CancelSelected()
	local FrameList = PersonPortraitHeadVM.HeadMainCustVMList:GetItems()
	local CurFrameID = PersonPortraitHeadMgr.CurFrameID or 1

	local TargetIdx

	for Idx, Item in pairs(FrameList or {}) do
		if Item.FrameResID == CurFrameID then
			TargetIdx = Idx
		end
	end

	self.AdpTableFrame:SetSelectedIndex(TargetIdx or 1)
end

return PersonInfoHeadWinView