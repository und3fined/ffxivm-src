---
--- Author: kofhuang
--- DateTime: 2025-03-22 16:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBindableList = require("UI/UIBindableList")
local FieldTestTabItemVM = require("Game/Test/FieldTest/ViewModel/FieldTestTabItemVM")
local MultiLanguageTestLogVM = require("Game/Test/MultiLanguage/MultiLanguageTestLogVM")
local ProtoRes = require("Protocol/ProtoRes")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local AchievementCfgTable = require("TableCfg/AchievementCfg")
local SingstateCfgTable = require("TableCfg/SingstateCfg")
local YellCfgTable = require("TableCfg/YellCfg")
local BalloonCfgTable = require("TableCfg/BalloonCfg")
local SysnoticeCfgTable = require("TableCfg/SysnoticeCfg")
local MonsterCfgTable = require("TableCfg/MonsterCfg")
local NpcCfgTable = require("TableCfg/NpcCfg")
local EObjCfgTable = require("TableCfg/EobjCfg")
local BuffCfgTable = require("TableCfg/BuffCfg")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCS = require("Protocol/ProtoCS")
local ItemCfgTable = require("TableCfg/ItemCfg")
local ItemUtil = require("Utils/ItemUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBindableBuffList = require("Game/Buff/VM/UIBindableBuffList")
local BuffDefine = require("Game/Buff/BuffDefine")
local EventID = require("Define/EventID")
local BuffUIUtil = require("Game/Buff/BuffUIUtil")

local ItemTypeDetail = ProtoCommon.ITEM_TYPE_DETAIL
local UIViewID = _G.UIViewID
local UIViewMgr = _G.UIViewMgr
local GMMgr = _G.GMMgr
local TimerMgr = _G.TimerMgr
local UE = _G.UE

local GMType = {
	Information = 1,
	Entity = 2,
	BluePrint = 3,
}

---@class MultiLanguageTestPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BImg UImage
---@field Bg_7 UFImage
---@field Bg_8 UFImage
---@field Bg_9 UFImage
---@field BtnDrag UFButton
---@field BtnMini UFButton
---@field BtnReturn UFButton
---@field BtnStart UFButton
---@field CommSearchBar_UIBP CommSearchBarView
---@field CommonCloseBtn CommonCloseBtnView
---@field CurGM UFTextBlock
---@field FHorizontalBox UFHorizontalBox
---@field FSearchBar UFHorizontalBox
---@field ItemList UFTreeView
---@field ItemView UBorder
---@field LeftPanel UFCanvasPanel
---@field MajorBuffInfoTips MainBuffInfoTipsNewView
---@field Maximum UEditableText
---@field Minimum UEditableText
---@field MovePanel UFCanvasPanel
---@field NewBagItemTips NewBagItemTipsView
---@field RightPanel UFCanvasPanel
---@field Runnum UFTextBlock
---@field TabList UTableView
---@field TextDrag UFTextBlock
---@field TextMinimize UFTextBlock
---@field TextReturn UFTextBlock
---@field TextStart UFTextBlock
---@field Timeinterval UEditableText
---@field TitleText_4 UFTextBlock
---@field TitleText_5 UFTextBlock
---@field IsDrag bool
---@field MovePanelSlot CanvasPanelSlot
---@field Offset Vector2D
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MultiLanguageTestPanelView = LuaClass(UIView, true)

function MultiLanguageTestPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BImg = nil
	--self.Bg_7 = nil
	--self.Bg_8 = nil
	--self.Bg_9 = nil
	--self.BtnDrag = nil
	--self.BtnMini = nil
	--self.BtnReturn = nil
	--self.BtnStart = nil
	--self.CommSearchBar_UIBP = nil
	--self.CommonCloseBtn = nil
	--self.CurGM = nil
	--self.FHorizontalBox = nil
	--self.FSearchBar = nil
	--self.ItemList = nil
	--self.ItemView = nil
	--self.LeftPanel = nil
	--self.MajorBuffInfoTips = nil
	--self.Maximum = nil
	--self.Minimum = nil
	--self.MovePanel = nil
	--self.NewBagItemTips = nil
	--self.RightPanel = nil
	--self.Runnum = nil
	--self.TabList = nil
	--self.TextDrag = nil
	--self.TextMinimize = nil
	--self.TextReturn = nil
	--self.TextStart = nil
	--self.Timeinterval = nil
	--self.TitleText_4 = nil
	--self.TitleText_5 = nil
	--self.IsDrag = nil
	--self.MovePanelSlot = nil
	--self.Offset = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.SubPanelViews = {}
	self.SubPanelID = 0
	self.GMStartIndex = 0
	self.GMEndIndex = 0
	self.GMTimer = nil
	self.GMCounts = 0
	self.SearchText = ""
	self.SearchTextLength = 0
	self.GMType = GMType.Information
	self.BuffList = UIBindableBuffList.New()
end

function MultiLanguageTestPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommSearchBar_UIBP)
	self:AddSubView(self.CommonCloseBtn)
	self:AddSubView(self.MajorBuffInfoTips)
	self:AddSubView(self.NewBagItemTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MultiLanguageTestPanelView:OnInit()
	self.AdapterTabList = UIAdapterTableView.CreateAdapter(self, self.TabList)
	self.TabVMList = UIBindableList.New(FieldTestTabItemVM)

	self.GMDataList = UIBindableList.New(MultiLanguageTestLogVM)
	self.RecordList = UIBindableList.New(MultiLanguageTestLogVM)
	self.AdapterCategoryTable = UIAdapterTableView.CreateAdapter(self, self.ItemList, nil)

	self.CommSearchBar_UIBP:SetCallback(self, self.OnSearchTextChange, nil, self.OnClickCancelSearchBar)

	self.DPIScale = UE.UWidgetLayoutLibrary.GetViewportScale(self)
end

function MultiLanguageTestPanelView:OnDestroy()
	self.AdapterTabList:OnDestroy()
	self.AdapterTabList = nil
	self.TabVMList = nil
	if self.UpdateTimerID then
		TimerMgr:CancelTimer(self.UpdateTimerID)
		self.UpdateTimerID = nil
	end
	if self.GMTimer ~= nil then
		TimerMgr:CancelTimer(self.GMTimer)
		self.GMTimer = nil
	end
end

function MultiLanguageTestPanelView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewType = Params.ViewType
	self.TabVMList:Clear()

	if ViewType == LSTR("信息自动化") then
		self.TabVMList:AddByValue({Key = 1, Name = "系统通知", PanelView = self, CallBack = self.OnSelectedTabIndex})
		self.TabVMList:AddByValue({Key = 2, Name = "balloon", PanelView = self, CallBack = self.OnSelectedTabIndex})
		self.TabVMList:AddByValue({Key = 3, Name = "气泡表", PanelView = self, CallBack = self.OnSelectedTabIndex})
		self.TabVMList:AddByValue({Key = 4, Name = "成就表", PanelView = self, CallBack = self.OnSelectedTabIndex})
		self.TabVMList:AddByValue({Key = 5, Name = "交互表", PanelView = self, CallBack = self.OnSelectedTabIndex})
		self.GMType = GMType.Information
	elseif ViewType == LSTR("实体创建") then
		self.TabVMList:AddByValue({Key = 1, Name = "怪物", PanelView = self, CallBack = self.OnSelectedTabIndex})
		self.TabVMList:AddByValue({Key = 2, Name = "NPC", PanelView = self, CallBack = self.OnSelectedTabIndex})
		self.TabVMList:AddByValue({Key = 3, Name = "EOBJ", PanelView = self, CallBack = self.OnSelectedTabIndex})
		self.TabVMList:AddByValue({Key = 4, Name = "buff表", PanelView = self, CallBack = self.OnSelectedTabIndex})
		self.GMType = GMType.Entity
	elseif ViewType == LSTR("蓝图检查") then
		self.TabVMList:AddByValue({Key = 1, Name = "物品弹窗", PanelView = self, CallBack = self.OnSelectedTabIndex})
		self.TabVMList:AddByValue({Key = 2, Name = "物品快捷", PanelView = self, CallBack = self.OnSelectedTabIndex})
		self.TabVMList:AddByValue({Key = 3, Name = "物品详细", PanelView = self, CallBack = self.OnSelectedTabIndex})
		self.TabVMList:AddByValue({Key = 4, Name = "buff表", PanelView = self, CallBack = self.OnSelectedTabIndex})
		self.GMType = GMType.BluePrint
	end


	self.TextDrag:SetText(_G.LSTR(1440003)) --拖拽
	UIUtil.SetIsVisible(self.CommSearchBar_UIBP.FImageSearchDark, false)
	UIUtil.SetIsVisible(self.CommSearchBar_UIBP.FImageSearchLight, false)
	UIUtil.SetIsVisible(self.FSearchBar, true)
	UIUtil.SetIsVisible(self.BtnReturn, false)
	UIUtil.SetIsVisible(self.NewBagItemTips, false)
	UIUtil.SetIsVisible(self.MajorBuffInfoTips, false)

	self.AdapterTabList:UpdateAll(self.TabVMList)
	self.AdapterTabList:SetSelectedIndex(1)
	self.CurGM:SetText("")
	self.Runnum:SetText("")
	self.SubPanelID = 1

	self.LastMapResID = _G.PWorldMgr:GetCurrMapResID()
	self.GMDataList:FreeAllItems()
	self.RecordList:FreeAllItems()

	UIUtil.SetIsVisible(self.LeftPanel, true)
	UIUtil.SetIsVisible(self.FSearchBar, true)
	local Position = _G.UE.FVector2D(0, 0)
	UIUtil.CanvasSlotSetPosition(self.MovePanel, Position)
end

function MultiLanguageTestPanelView:OnHide()
	if self.GMTimer ~= nil then
		TimerMgr:CancelTimer(self.GMTimer)
		self.GMTimer = nil
	end
end

function MultiLanguageTestPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnMini, self.OnMinimizeClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnStart, self.OnBtnStartClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnReturn, self.OnClickReturn)
end

function MultiLanguageTestPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.UpdateBuff, self.OnGameEventUpdateBuff)
end

function MultiLanguageTestPanelView:OnRegisterBinder()

end

function MultiLanguageTestPanelView:OnSelectedTabIndex(Index)
	--FLOG_INFO(string.format("MultiLanguageTestPanelView:OnSelectedTabIndex:%s", Index))
	UIUtil.SetIsVisible(self.NewBagItemTips, false)
	UIUtil.SetIsVisible(self.MajorBuffInfoTips, false)
	self.AdapterTabList:SetSelectedIndex(Index)
	self.SubPanelID = Index
	if self.GMTimer ~= nil then
		TimerMgr:CancelTimer(self.GMTimer)
		self.GMTimer = nil
	end
	self.CurGM:SetText("")
end

function MultiLanguageTestPanelView:OnMapEnter(Params)
	if Params and Params.CurrMapResID ~= self.LastMapResID then
		self:Hide()
	end
end

function MultiLanguageTestPanelView:OnMinimizeClicked()
	UIUtil.SetIsVisible(self.LeftPanel, false)
	UIUtil.SetIsVisible(self.FSearchBar, false)

	local Position = _G.UE.FVector2D(-1250, 0)
	UIUtil.CanvasSlotSetPosition(self.MovePanel, Position)
	-- local BuffInfoPosition = _G.UE.FVector2D(1237, -212)
	-- UIUtil.CanvasSlotSetPosition(self.MajorBuffInfoTips, BuffInfoPosition)


	self.BtnReturn:SetVisibility(_G.UE.ESlateVisibility.Visible)

	if self.GMTimer == nil then
		self:StartGMCommand()
	end
end

function MultiLanguageTestPanelView:OnBtnStartClicked()
	if self.GMTimer == nil then
		self:StartGMCommand()
	end
end

function MultiLanguageTestPanelView:StartGMCommand()
	FLOG_INFO(string.format("koff MultiLanguageTestPanelView:StartGMCommand,self.SubPanelID:%s,self.GMType:%s",self.SubPanelID,self.GMType))
	local CfgTable = SysnoticeCfgTable:FindAllCfg() or {}
	local GMCur = "当前GM命令:"
	if self.GMTimer ~= nil then
		TimerMgr:CancelTimer(self.GMTimer)
		self.GMTimer = nil
	end
	self.CurGM:SetText("")
	self.Runnum:SetText("")
	self.GMCounts = 0

	self.GMDataList:FreeAllItems()
	self.RecordList:FreeAllItems()
	self.AdapterCategoryTable:UpdateAll(self.RecordList)

	self.GMStartIndex = tonumber(self.Minimum:GetText())
	self.GMStartIndex = math.max(1,self.GMStartIndex)
	self.GMEndIndex = tonumber(self.Maximum:GetText())
	local Timeinterval = tonumber(self.Timeinterval:GetText())

	local GMStr = ""
	local LastTableID = 0
	if self.SubPanelID == 1 then
		if self.GMType == GMType.Information then
			CfgTable = SysnoticeCfgTable:FindAllCfg() or {}
			GMStr = "client sysnotice %d"
		elseif self.GMType == GMType.Entity then
			CfgTable = MonsterCfgTable:FindAllCfg() or {}
			GMStr = "scene monster create %d"
		elseif self.GMType == GMType.BluePrint then
			CfgTable = ItemCfgTable:FindAllCfg() or {}
			GMStr = "role bag add %d 1"
		end
	elseif self.SubPanelID == 2 then
		if self.GMType == GMType.Information then
			CfgTable = BalloonCfgTable:FindAllCfg() or {}
			GMStr = "client PlayBalloon %d"
		elseif self.GMType == GMType.Entity then
			CfgTable = NpcCfgTable:FindAllCfg() or {}
			GMStr = "scene npc create %d"
		elseif self.GMType == GMType.BluePrint then
			CfgTable = ItemCfgTable:FindAllCfg() or {}
			GMStr = "role bag add %d 1"
		end
	elseif self.SubPanelID == 3 then
		if self.GMType == GMType.Information then
			CfgTable = YellCfgTable:FindAllCfg() or {}
			GMStr = "client PlayYell %d"
		elseif self.GMType == GMType.Entity then
			CfgTable = EObjCfgTable:FindAllCfg() or {}
			GMStr = "scene eobj create %d"
		elseif self.GMType == GMType.BluePrint then
			CfgTable = ItemCfgTable:FindAllCfg() or {}
			GMStr = "role bag add %d 1"
		end
	elseif self.SubPanelID == 4 then
		if self.GMType == GMType.Information then
			GMMgr:ReqGM("role achieve clear")
			CfgTable = AchievementCfgTable:FindAllCfg() or {}
			GMStr = "role achieve setcomp %d"
		elseif self.GMType == GMType.Entity then
			CfgTable = BuffCfgTable:FindAllCfg() or {}
			GMStr = "cell buff add %d"
		elseif self.GMType == GMType.BluePrint then
			CfgTable = BuffCfgTable:FindAllCfg() or {}
			GMStr = "cell buff add %d"
		end
	elseif self.SubPanelID == 5 then
		CfgTable = SingstateCfgTable:FindAllCfg() or {}
		GMStr = "client sing %d"

		FLOG_INFO(string.format("SingstateCfgTable Nums:%s", #CfgTable))
		if self.GMType ~= GMType.Information then
			local log = string.format("这里不该被点到!!!，self.GMType：%s",self.GMType)
			MsgTipsUtil.ShowErrorTips(_G.LSTR(log))
			return
		end
	end	

	self.GMEndIndex = math.min(#CfgTable,self.GMEndIndex)

	local MajorID = MajorUtil.GetMajorEntityID()
	_G.SwitchTarget:SwitchToTarget(MajorID, true)

	-- local FinshCallback
	local FinshCallback = function ()
		if self.GMStartIndex > self.GMEndIndex then
			if self.GMTimer ~= nil then
				TimerMgr:CancelTimer(self.GMTimer)
				self.GMTimer = nil
			end
		else
			local CfgTableID
			if self.GMType == GMType.BluePrint and self.SubPanelID ~= 4 then
				CfgTableID = CfgTable[self.GMStartIndex].ItemID
			else
				CfgTableID = CfgTable[self.GMStartIndex].ID
			end

			if CfgTableID ~= nil then
				local GMText = string.format(GMStr, CfgTableID)
				local Data = {}

				if self.SubPanelID == 1 then
					UIViewMgr:HideView(UIViewID.MessageBox,true)

					if self.GMType == GMType.Information then
						_G.MsgTipsUtil.ShowTipsByID(CfgTableID)
					elseif self.GMType == GMType.Entity then
						local DestoryText = string.format("scene monster destroy %d", LastTableID)
						GMMgr:ReqGM(DestoryText)

						GMMgr:ReqGM(GMText)
					elseif self.GMType == GMType.BluePrint then
						GMMgr:ReqGM(GMText)
					end

				elseif self.SubPanelID == 2 then
					if self.GMType == GMType.Information then
						_G.SpeechBubbleMgr:ShowBalloonTest(CfgTableID)
					elseif self.GMType == GMType.Entity then
						local DestoryText = string.format("scene npc destroy %d", LastTableID)
						GMMgr:ReqGM(DestoryText)
						--FLOG_INFO(string.format("Destory:%s", DestoryText))
						GMMgr:ReqGM(GMText)
					elseif self.GMType == GMType.BluePrint then
						for i = self.GMStartIndex, #CfgTable do
							if i > self.GMEndIndex then
								if self.GMTimer ~= nil then
									TimerMgr:CancelTimer(self.GMTimer)
									self.GMTimer = nil
									return
								end
							else
								local EasyUse = CfgTable[i].EasyUse
								if EasyUse ~= 1 then
									self.GMStartIndex = self.GMStartIndex + 1
									goto continue
								else
									break
								end
							end
							::continue::
						end

						CfgTableID = CfgTable[self.GMStartIndex].ItemID
						GMText = string.format(GMStr, CfgTableID)
						local Item = ItemUtil.CreateItem(CfgTableID)
						self:PopUpEasyUse(Item)
						-- GMMgr:ReqGM(GMText)
					end

				elseif self.SubPanelID == 3 then
					if self.GMType == GMType.Information then
						_G.SpeechBubbleMgr:ShowBubbleTest(CfgTableID)
					elseif self.GMType == GMType.Entity then
						local DestoryText = string.format("scene eobj destroy %d", LastTableID)
						GMMgr:ReqGM(DestoryText)
						FLOG_INFO(string.format("Destory:%s", DestoryText))
						GMMgr:ReqGM(GMText)
					elseif self.GMType == GMType.BluePrint then
						local Item = ItemUtil.CreateItem(CfgTableID)
						Item.Attr = {
							Equip = {
								IsInScheme = false,
								GemInfo = {
									CarryList = {}
								}
							}
						}

						UIUtil.SetIsVisible(self.NewBagItemTips, true)
						self.NewBagItemTips:UpdateItem(Item)
					end

				elseif self.SubPanelID == 4 then
					if self.GMType == GMType.Information then
						local AchievementMgr = _G.AchievementMgr
						for i = self.GMStartIndex, #CfgTable do
							if i > self.GMEndIndex then
								if self.GMTimer ~= nil then
									TimerMgr:CancelTimer(self.GMTimer)
									self.GMTimer = nil
									return
								end
							else
								CfgTableID = CfgTable[i].ID
								local Info = AchievementMgr:GetAchievementInfo(CfgTableID)
								if Info == nil then
									FLOG_INFO(string.format("无效的成就ID:%d", CfgTableID))
									self.GMStartIndex = self.GMStartIndex + 1
									goto continue
								else
									break
								end
							end
							::continue::
						end
						GMText = string.format(GMStr, CfgTableID)
						_G.LeftSidebarMgr:ResetDefaultStayTimeForTest(0.5)
					elseif self.GMType == GMType.Entity then
						local DestoryText = string.format("cell buff del %d", LastTableID)
						GMMgr:ReqGM(DestoryText)
						FLOG_INFO(string.format("Destory:%s", DestoryText))
					elseif self.GMType == GMType.BluePrint then
						local DestoryText = string.format("cell buff del %d", LastTableID)
						GMMgr:ReqGM(DestoryText)
					end

					GMMgr:ReqGM(GMText)
				elseif self.SubPanelID == 5 then
					_G.SingBarMgr:MajorSingBySingStateIDWithoutInteractiveID(CfgTableID, nil)
				end

				Data.Text = GMText
				self.RecordList:AddByValue(Data)

				GMText = GMCur..GMText
				self.CurGM:SetText(GMText)
				self.GMCounts = self.GMCounts + 1
				UIViewMgr:HideView(UIViewID.GMMain)

				LastTableID = CfgTableID
				self:SetDataList(self.RecordList)
			end
		end
		self.GMStartIndex = self.GMStartIndex + 1
	end

	self.GMTimer = TimerMgr:AddTimer(self, FinshCallback, 0, Timeinterval, 0, nil)
end

function MultiLanguageTestPanelView:SetDataList(DataList)
	if self.SearchTextLength > 0  then
		local OldList = self.RecordList:GetItems()

		self.GMDataList:FreeAllItems()

		for i = 1, #OldList do
			local NameStr = OldList[i].Text
			if string.find(NameStr, self.SearchText) then
				local Data = OldList[i]
				self.GMDataList:AddByValue(Data)
			end
		end
	
		self.AdapterCategoryTable:UpdateAll(self.GMDataList)
		self.AdapterCategoryTable:ScrollToBottom()
	else
		self.AdapterCategoryTable:UpdateAll(self.RecordList)
		self.AdapterCategoryTable:ScrollToBottom()
	end

	self.Runnum:SetText(self.GMStartIndex)
end

function MultiLanguageTestPanelView:OnSearchTextChange(SearchText, Length)
	self.SearchTextLength = Length
	if Length <= 0 then
        if self.RecordList ~= nil then
			self:SetDataList(self.RecordList)
		end
        return
    end

	self.SearchText = SearchText
	self:SetDataList(self.RecordList)
end

function MultiLanguageTestPanelView:OnClickCancelSearchBar()
	if self.RecordList ~= nil then
		self:SetDataList(self.RecordList)
	end
end

function MultiLanguageTestPanelView:OnClickReturn()
	UIUtil.SetIsVisible(self.LeftPanel, true)
	UIUtil.SetIsVisible(self.FSearchBar, true)
	UIUtil.SetIsVisible(self.BtnReturn, false)
	local Position = _G.UE.FVector2D(0, 0)
	UIUtil.CanvasSlotSetPosition(self.MovePanel, Position)
	-- local BuffInfoPosition = _G.UE.FVector2D(-13, -212)
	-- UIUtil.CanvasSlotSetPosition(self.MajorBuffInfoTips, BuffInfoPosition)
end

function MultiLanguageTestPanelView:PopUpEasyUse(Item)
    if UIViewMgr:IsViewVisible(UIViewID.SidePopUpEasyUse) then
		_G.SidePopUpMgr:RemoveSidePopUp(UIViewID.SidePopUpEasyUse)
    end

	_G.SidePopUpMgr:AddSidePopUp(ProtoRes.side_popup_type.SIDE_POPUP_EASY_USE, UIViewID.SidePopUpEasyUse, Item, function(Item)
		local ItemResID = Item.ResID
		local CurItemCfg = ItemCfgTable:FindCfgByKey(ItemResID)
		if CurItemCfg == nil then
			return false
		end

		if CurItemCfg.EasyUse == 1 then
			if CurItemCfg.ItemMainType == ProtoCommon.ItemMainType.ItemCollage then
				if CurItemCfg.ItemType == ItemTypeDetail.COLLAGE_COIFFURE then
					_G.HaircutMgr:SendMsgHairQuery()
				end
			end

			return true
		end

		return false
	end)
end

function  MultiLanguageTestPanelView:OnGameEventUpdateBuff(Params)
	-- FLOG_INFO(string.format("koff MultiLanguageTestPanelView:OnGameEventUpdateBuff"))
	if self.GMType ~= GMType.BluePrint then
		return
	end


    local Values = BuffUIUtil.GetEntityBuffVMParamsList(MajorUtil.GetMajorEntityID(), true)
    self.BuffList:UpdateByValues(Values, BuffUIUtil.SortBuffDisplay)

	local BufferID = Params.IntParam1
	local EntityID = Params.ULongParam1
	local Giver = Params.ULongParam2

	-- FLOG_INFO(string.format("koff MultiLanguageTestPanelView:OnGameEventUpdateBuff BufferID:%s,EntityID:%s,Giver:%s",BufferID,EntityID,Giver))

	local VM = self.BuffList:FindBuffVM(BufferID, Giver, BuffDefine.BuffSkillType.Combat)
	if nil == VM then
		UIUtil.SetIsVisible(self.MajorBuffInfoTips, false)
		FLOG_INFO(string.format("koff nil == VM!!!!!!"))
		return
	end

	UIUtil.SetIsVisible(self.MajorBuffInfoTips, true)
	self.MajorBuffInfoTips:ChangeVMAndUpdate(VM)
end

return MultiLanguageTestPanelView