---
--- Author: ds_tianjiateng
--- DateTime: 2024-03-21 14:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local SceneMarkersMainVM = require("Game/Signs/VM/SceneMarkersMainVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local SignsMgr = require("Game/Signs/SignsMgr")
local PworldCfg = require("TableCfg/PworldCfg")
local ProtoRes = require("Protocol/ProtoRes")
local EventID = require("Define/EventID")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")

local TArray = UE.TArray
local AActor = UE.AActor
local UGameplayStatics = UE.UGameplayStatics
local AStaticMeshActor = UE.AStaticMeshActor
local ABlockingVolume = UE.ABlockingVolume
local ASgLayoutActorBase = UE.ASgLayoutActorBase
local PWorldMgr = _G.PWorldMgr

---@class SceneMarkersMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDelete UFButton
---@field CommSidebarFrameS_UIBP CommSidebarFrameSView
---@field IconMarkersFocus1 UFImage
---@field IconMarkersFocus2 UFImage
---@field IconMarkersFocus3 UFImage
---@field IconMarkersFocus4 UFImage
---@field IconMarkersFocus5 UFImage
---@field IconMarkersFocus6 UFImage
---@field IconMarkersFocus7 UFImage
---@field IconMarkersFocus8 UFImage
---@field IconMarkersNormal1 UFImage
---@field IconMarkersNormal2 UFImage
---@field IconMarkersNormal3 UFImage
---@field IconMarkersNormal4 UFImage
---@field IconMarkersNormal5 UFImage
---@field IconMarkersNormal6 UFImage
---@field IconMarkersNormal7 UFImage
---@field IconMarkersNormal8 UFImage
---@field PanelMain UFCanvasPanel
---@field TableViewList UTableView
---@field TableViewSceneMarkers UTableView
---@field TextMarkTips UFTextBlock
---@field TextMarkTips_1 UFTextBlock
---@field TextSaveTime UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SceneMarkersMainPanelView = LuaClass(UIView, true)

function SceneMarkersMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnDelete = nil
	--self.CommSidebarFrameS_UIBP = nil
	--self.IconMarkersFocus1 = nil
	--self.IconMarkersFocus2 = nil
	--self.IconMarkersFocus3 = nil
	--self.IconMarkersFocus4 = nil
	--self.IconMarkersFocus5 = nil
	--self.IconMarkersFocus6 = nil
	--self.IconMarkersFocus7 = nil
	--self.IconMarkersFocus8 = nil
	--self.IconMarkersNormal1 = nil
	--self.IconMarkersNormal2 = nil
	--self.IconMarkersNormal3 = nil
	--self.IconMarkersNormal4 = nil
	--self.IconMarkersNormal5 = nil
	--self.IconMarkersNormal6 = nil
	--self.IconMarkersNormal7 = nil
	--self.IconMarkersNormal8 = nil
	--self.PanelMain = nil
	--self.TableViewList = nil
	--self.TableViewSceneMarkers = nil
	--self.TextMarkTips = nil
	--self.TextMarkTips_1 = nil
	--self.TextSaveTime = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SceneMarkersMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommSidebarFrameS_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SceneMarkersMainPanelView:OnInit()
	self.TableAdapterSigns = UIAdapterTableView.CreateAdapter(self, self.TableViewSceneMarkers, self.OnSlotItemSelectedChanged, true)
	self.TableAdapterSaveList = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnSaveListItemSelectedChanged, true)

	self.Binders = {
		{"SignsSlots", 					UIBinderUpdateBindableList.New(self, self.TableAdapterSigns)},
		{"SaveList", 					UIBinderUpdateBindableList.New(self, self.TableAdapterSaveList)},
		{"SaveTimeText", 				UIBinderSetText.New(self, self.TextSaveTime)},
		{"IconMarkersFocus1Visible", 	UIBinderSetIsVisible.New(self, self.IconMarkersFocus1)},
		{"IconMarkersFocus2Visible", 	UIBinderSetIsVisible.New(self, self.IconMarkersFocus2)},
		{"IconMarkersFocus3Visible", 	UIBinderSetIsVisible.New(self, self.IconMarkersFocus3)},
		{"IconMarkersFocus4Visible", 	UIBinderSetIsVisible.New(self, self.IconMarkersFocus4)},
		{"IconMarkersFocus5Visible", 	UIBinderSetIsVisible.New(self, self.IconMarkersFocus5)},
		{"IconMarkersFocus6Visible", 	UIBinderSetIsVisible.New(self, self.IconMarkersFocus6)},
		{"IconMarkersFocus7Visible", 	UIBinderSetIsVisible.New(self, self.IconMarkersFocus7)},
		{"IconMarkersFocus8Visible", 	UIBinderSetIsVisible.New(self, self.IconMarkersFocus8)},
	}
	self.CommSidebarFrameS_UIBP.BtnClose:SetCallback(self, self.OnClickBtnClose)
	--- 读服务器数据，登陆事件后读拿不到，所以放到这里
	SignsMgr:OnGetServerSaveList()

	self.IsFileReading = false
	self.IsMarksChanged = false
	self.SlotClickTimerID = 0
	self.IsNeedCloseTips = false				--- 读档并变更后关闭提示保存
end

function SceneMarkersMainPanelView:OnDestroy()

end

function SceneMarkersMainPanelView:OnShow()
	self:GetIgnoreObjects()
	self.CommSidebarFrameS_UIBP.CommonTitle:SetTextTitleName(LSTR(1240001))		--- "场景标记"
	self.TextMarkTips:SetText(LSTR(1240002))	--- "双击或拖拽进行标记"
	self.TextMarkTips_1:SetText(LSTR(1240003))	--- "存档"
	self.TextSaveTime:SetText(LSTR(1240002))	--- "双击或拖拽进行标记"
	SceneMarkersMainVM:OnInitViewData()
	self.PanelMain:SetVisibility(_G.UE.ESlateVisibility.SelfHitTestInvisible)
	self.TableAdapterSaveList:CancelSelected()
	self:CheckItemUsedState()
end

function SceneMarkersMainPanelView:OnClickBtnClose()
	if self.IsFileReading and self.IsMarksChanged and self.IsNeedCloseTips then
		MsgBoxUtil.ShowMsgBoxTwoOp(
			self,
			LSTR(1240005),	--- "提示"
			LSTR(1240006),	--- "存档有改动，是否要保存？"
			function()
				local Index = SceneMarkersMainVM.SelectedIndex
				SignsMgr:OnSaveSceneMarkersListByIndex(Index)
				-- 刷新SaveListItem
				local SelectedItemData = SignsMgr.SceneMarkersSaveList[Index]
				if table.is_nil_empty(SelectedItemData) then
					--- 点全部删除按钮->关闭二次弹窗内选择保存会保存空表，视为删除当前保存Item
					SceneMarkersMainVM:OnResetSaveItemByIndex(Index)
				else
					SceneMarkersMainVM:OnUpdateSaveListByIndex(Index, SelectedItemData)
				end
				self.IsMarksChanged = false
				self:Hide()
			end,
			self.Hide,
			LSTR(1240008),		--- "不保存"
			LSTR(1240007)		--- "保存"
		)
		self.IsNeedCloseTips = false
	else
		self:Hide()
	end
end

function SceneMarkersMainPanelView:OnHide()
	-- self.IsFileReading = false
	_G.SignsMgr:ClearIgnoreActors()
	SceneMarkersMainVM:ClearAllItemUsed()
	SignsMgr.SceneMarkersMainPanelIsShowing = false
	_G.FLOG_INFO("SceneMarkersMainPanelView:OnHide, To InteractiveMgr, Show InteractiveMainPanel")
    _G.UIViewMgr:ShowView(_G.UIViewID.InteractiveMainPanel)
end

function SceneMarkersMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnDelete, self.OnClearAllMarking)
end

function SceneMarkersMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.TeamSceneMarkMoveEvent, self.OnReceiveTeamSceneMarkMoveEvent)
	self:RegisterGameEvent(EventID.TeamSceneMarkSeverNotifyEvent, self.OnTeamSceneMarkSeverNotify)
	self:RegisterGameEvent(EventID.PWorldExit, self.OnGameEventPworldExit)
    self:RegisterGameEvent(EventID.TeamSceneMarkConfirmEvent, self.OnGameEventTeamSceneMarkConfirm)
	self:RegisterGameEvent(EventID.NetStateUpdate,self.OnCombatStateUpdate)
end

function SceneMarkersMainPanelView:OnRegisterBinder()
	self:RegisterBinders(SceneMarkersMainVM, self.Binders)
end

function SceneMarkersMainPanelView:OnCombatStateUpdate(Params)
	if MajorUtil.IsMajor(Params.ULongParam1) and Params.IntParam1 == ProtoCommon.CommStatID.COMM_STAT_COMBAT then
		self:SetRenderOpacity(1.0)
	end
end

function SceneMarkersMainPanelView:OnUpdateUsedList()

end

function SceneMarkersMainPanelView:OnSlotItemSelectedChanged(Index, ItemData, ItemView)
	if self.SlotClickTimerID == 0 then
		self.SlotClickTimerID = self:RegisterTimer(function(_, params)
			local IsUsed = params.ItemData.IsUsed
			self.IsMarksChanged = true
			if IsUsed then
				UIUtil.SetIsVisible(self["IconMarkersFocus" .. params.Index], not IsUsed)
				SignsMgr:SendSceneMarkingClearReq(params.Index)
				self:UnRegisterTimer(self.SlotClickTimerID)
				self.SlotClickTimerID = 0
			end
		end, 0.3, 0, 1,{Index = Index, ItemData = ItemData })
	else
		self:UnRegisterTimer(self.SlotClickTimerID)
		self.SlotClickTimerID = 0
	end
end

--[[

	状态1:当前副本档
		1.当前场景内无标记，点击选中并读取该存档
		2.当前场景内有标记，点击弹出[ 读档二次确认弹窗 ]
	状态2: 其他副本档
		点击选中但无法读取该存档，弹出tips提示“当前区域无法使用指定的场景标记
	状态3:空档
		1.在当前副本场景中，
			1.若已标记   点击空白存档条即可存入当前副本的场景标记方案并选中
			2.若无标记   点击空白存档条弹出tips提示“无法保存，未设置场景标记”
		2.在副本外，点击空白存档条弹出tips提示“副本外无法保存场景标记
]]
--- 存档TableView选中回调
function SceneMarkersMainPanelView:OnSaveListItemSelectedChanged(Index, ItemData, ItemView)

	if ItemView.IsClickedBtnDelete == true then
		MsgBoxUtil.ShowMsgBoxTwoOp(
			self,
			LSTR(1240009),	--- "删除存档"
			LSTR(1240010),	--- "确认删除当前存档吗？"
			function()
				SignsMgr:OnClearSaveListItem(Index)
				self.TextSaveTime:SetText("")
			end,
			nil,
			LSTR(1240011),	--- "取  消"
			LSTR(1240012)	--- "确  认"
		)
		ItemView.IsClickedBtnDelete = false
		return
	end
	local SelectedSaveData = SignsMgr:OnGetSeverDataByIndex(Index)
	local CurrentUseSceneMarkers = SignsMgr:GetCurrentUseSceneMarkers()

	local PWorldResID = _G.PWorldMgr:GetCurrPWorldResID()
	local TempPworldCfg = PworldCfg:FindCfgByKey(PWorldResID)
	--- 副本内
	if TempPworldCfg.Type == ProtoRes.pworld_type.PWORLD_CATEGORY_DUNGEON then
		if table.is_nil_empty(SelectedSaveData) then
			if table.is_nil_empty(CurrentUseSceneMarkers) then
				-- TODO 3.1.2		“无法保存，未设置场景标记”   103051  已配置
				MsgTipsUtil.ShowTipsByID(103051)
			else
				-- TODO 3.1.1   
				SignsMgr:OnSaveSceneMarkersListByIndex(Index)
				-- 刷新SaveListItem
				SceneMarkersMainVM:OnUpdateSaveListByIndex(Index, SignsMgr.SceneMarkersSaveList[Index])
				SceneMarkersMainVM:OnSetSelectedIndex(Index)
				self.IsFileReading = true
				self.IsMarksChanged = false
				self.IsNeedCloseTips = true
			end
		else
			-- 覆盖
			if ItemView.IsClickedBtnCover then
				MsgBoxUtil.ShowMsgBoxTwoOp(
					self,
					LSTR(1240013),	--- "覆盖存档"
					LSTR(1240014),	--- "确认覆盖当前存档吗？"
					function()
						if table.is_nil_empty(CurrentUseSceneMarkers) then
							-- TODO 3.1.2		“无法保存，未设置场景标记”   103051  已配置
							MsgTipsUtil.ShowTipsByID(103051)
						else
							-- TODO 3.1.1   
							SignsMgr:OnSaveSceneMarkersListByIndex(Index)
							SceneMarkersMainVM:OnSetSelectedIndex(Index)
							-- 刷新SaveListItem
							SceneMarkersMainVM:OnUpdateSaveListByIndex(Index, SignsMgr.SceneMarkersSaveList[Index])
						end
					end,
					nil,
					LSTR(1240011),	--- "取  消"
					LSTR(1240012)	--- "确  认"
				)
			else
				if SelectedSaveData.PworldID == PWorldResID then
					if table.is_nil_empty(CurrentUseSceneMarkers) then
						-- TODO 1.1
						SceneMarkersMainVM:ClearAllItemUsed()
						SceneMarkersMainVM:OnSetSelectedIndex(Index)
						self:OnRepMarkings(SelectedSaveData)
						self.IsFileReading = true
						self.IsMarksChanged = false
						self.IsNeedCloseTips = true
					else
						-- TODO 1.2   读档二次确认弹窗
						MsgBoxUtil.ShowMsgBoxTwoOp(
							self,
							LSTR(1240015),	--- "读取存档"
							LSTR(1240016),	--- "确认读取存档标记吗？\n当前场景标记会被替换"
							function()
								SceneMarkersMainVM:OnSetSelectedIndex(Index)
								self:OnRepMarkings(SelectedSaveData)
								self.IsFileReading = true
								self.IsMarksChanged = false
								self.IsNeedCloseTips = true
							end,
							nil,
							LSTR(1240011),	--- "取  消"
							LSTR(1240012)	--- "确  认"
						)
					end
				else
					-- TODO  2   当前区域无法使用指定的场景标记  103050  已配置
					MsgTipsUtil.ShowTipsByID(103050)
				end
			end
		end
	else
		-- TODO  3.2   副本外无法保存场景标记   103052  已配置
		MsgTipsUtil.ShowTipsByID(103052)
	end

	ItemView.IsClickedBtnCover = false
end

function SceneMarkersMainPanelView:OnClearAllMarking()
	MsgBoxUtil.ShowMsgBoxTwoOp(
		self,
		LSTR(1240017),	--- "删除标记"
		LSTR(1240018),	--- "确认删除当前场景所有标记吗？"
		function()
			--- 清除下方已用标记
			SceneMarkersMainVM:ClearAllItemUsed()
			SignsMgr.CurrentUseSceneMarkers = {}
			SignsMgr:CheckSceneMarkingState()
			self.IsMarksChanged = true
			SignsMgr:SendSceneMarkingClearReq(0)
			-- SignsMgr:ClearCurrentSceneMarkerData()
		end,
		nil,
		LSTR(1240011),	--- "取  消"
		LSTR(1240012)	--- "确  认"
	)
end

--- 读档时，用读到的数据挨个上报，后台广播给其他队伍成员 显示标记
function SceneMarkersMainPanelView:OnRepMarkings(SelectedSaveData)
	if table.is_nil_empty(SelectedSaveData) or table.is_nil_empty(SelectedSaveData.Items) then
		return
	end
	SceneMarkersMainVM:ClearAllItemUsed()
	-- SignsMgr:SendSceneMarkingClearReq(0)
	-- for i = 1, 8 do
	-- 	SignsMgr:RemoveSceneMarkEffect(i)
	-- 	if not table.is_nil_empty(SignsMgr.CurrentUseSceneMarkers.Items) then
	-- 		SignsMgr.CurrentUseSceneMarkers.Items[i] = nil
	-- 	end
	-- 	_G.EventMgr:SendEvent(EventID.TeamSceneMarkRemoveEvent, i)
	-- end
	local CurrentUseSceneMarkers = SignsMgr:GetCurrentUseSceneMarkers()
	local ParamGroups = {}
	if table.is_nil_empty(CurrentUseSceneMarkers) or table.is_nil_empty(CurrentUseSceneMarkers.Items) then
		for key, value in pairs(SelectedSaveData.Items) do
			-- SignsMgr:SendSceneMarkingReq(key, value.Position)
			table.insert(ParamGroups, {Index = key, Pos = value.Position})
		end
	else
		for i = 1, 8 do
			if table.is_nil_empty(CurrentUseSceneMarkers.Items[tostring(i)]) then 
				if SelectedSaveData.Items[tostring(i)] ~= nil then
					-- SignsMgr:SendSceneMarkingReq(i, SelectedSaveData.Items[i].Position)
					table.insert(ParamGroups, {Index = i, Pos = SelectedSaveData.Items[tostring(i)].Position})
				end
			else
				if SelectedSaveData.Items[tostring(i)] ~= nil then
					-- SignsMgr:SendSceneMarkingReq(i, SelectedSaveData.Items[i].Position)
					table.insert(ParamGroups, {Index = i, Pos = SelectedSaveData.Items[tostring(i)].Position})
				else
					SignsMgr:SendSceneMarkingClearReq(i)
				end
			end
		end
	end
	SignsMgr:SendSceneMarkingBatchReq(ParamGroups)
end

function SceneMarkersMainPanelView:CheckItemUsedState()
	local CurrentUseSceneMarkers = SignsMgr:GetCurrentUseSceneMarkers()
	if CurrentUseSceneMarkers ~= nil and CurrentUseSceneMarkers.Items ~= nil then
		local Items = CurrentUseSceneMarkers.Items
		for index, _ in pairs(Items) do
			SceneMarkersMainVM:OnSetItemUsedState(index, true)
		end
	end
end

function SceneMarkersMainPanelView:OnReceiveTeamSceneMarkMoveEvent(Params)
	local Visibility
	if Params.BoolParam1 then
		self:SetRenderOpacity(0.0)
		Visibility = _G.UE.ESlateVisibility.HitTestInvisible
	else
		self:SetRenderOpacity(1.0)
		Visibility = _G.UE.ESlateVisibility.SelfHitTestInvisible
	end
	self.PanelMain:SetVisibility(Visibility)
end

function SceneMarkersMainPanelView:OnTeamSceneMarkSeverNotify()
	local CurrentUseSceneMarkers = SignsMgr:GetCurrentUseSceneMarkers()

	if CurrentUseSceneMarkers ~= nil and CurrentUseSceneMarkers.Items ~= nil then
		local Items = CurrentUseSceneMarkers.Items
		for index, _ in pairs(Items) do
			for i = 1, #SceneMarkersMainVM.SignsSlots do
				if SceneMarkersMainVM.SignsSlots[i]:GetID() == Items[index].Index then
					SceneMarkersMainVM.SignsSlots[i]:OnTeamSceneMarkAdd({Index = Items[index].Index,Pos = Items[index].Position})
				end
			end
		end
	end
end

function SceneMarkersMainPanelView:OnGameEventPworldExit()
	self.TableAdapterSaveList:CancelSelected()
	SceneMarkersMainVM.SaveTimeText = ""
end

function SceneMarkersMainPanelView:OnGameEventTeamSceneMarkConfirm()

	self.IsMarksChanged = true
end

function SceneMarkersMainPanelView:GetIgnoreObjects()
	local MapResID = PWorldMgr:GetCurrMapResID()
	_G.SignsMgr:ClearIgnoreActors()

	if MapResID == 2017 then
		local Actors = TArray(AActor)
		UGameplayStatics.GetAllActorsOfClass(_G.FWORLD(), AStaticMeshActor.StaticClass(), Actors)
		for Index = Actors:Length() ,1,-1 do
			local ActorName = Actors:Get(Index):GetName()
			if ActorName == "s5p1_terrain_r2_3" or ActorName == "s5p1_terrain_r1_5" then
				_G.SignsMgr:AddIgnoreActor(Actors:Get(Index))
			end

			if table.length(_G.SignsMgr:GetIgnoreActors()) == 2 then
				break
			end
		end
	elseif MapResID == 2022 then
		local Actors = TArray(AActor)
		UGameplayStatics.GetAllActorsOfClass(_G.FWORLD(), AStaticMeshActor.StaticClass(), Actors)
		for Index = Actors:Length() ,1,-1 do
			local ActorName = Actors:Get(Index):GetName()
			if ActorName == "s5p2_terrain_r2_5" or ActorName == "s5p2_terrain_r1_3" then
				_G.SignsMgr:AddIgnoreActor(Actors:Get(Index))
			end

			if table.length(_G.SignsMgr:GetIgnoreActors()) == 2 then
				break
			end
		end
	elseif MapResID == 2023 then
		local Actors = TArray(AActor)
		UGameplayStatics.GetAllActorsOfClass(_G.FWORLD(), AStaticMeshActor.StaticClass(), Actors)
		for Index = Actors:Length() ,1,-1 do
			local ActorName = Actors:Get(Index):GetName()

			if ActorName == "s5p3_terrain_a1_5" or ActorName == "s5p3_terrain_a2_7" or ActorName == "s5p3_terrain_r2_11" then
				_G.SignsMgr:AddIgnoreActor(Actors:Get(Index))
			end

			if table.length(_G.SignsMgr:GetIgnoreActors()) == 3 then
				break
			end
		end
	elseif MapResID == 5025 or MapResID == 5026 then
		local Actors = TArray(AActor)
		UGameplayStatics.GetAllActorsOfClass(_G.FWORLD(), ASgLayoutActorBase.StaticClass(), Actors)
		for Index = Actors:Length() ,1,-1 do
			local ActorName = Actors:Get(Index):GetName()

			if ActorName == "sg4600477" then
				_G.SignsMgr:AddIgnoreActor(Actors:Get(Index))
				break
			end
		end
	elseif MapResID == 8001 or MapResID == 8002 then
		local Actors = TArray(AActor)
		UGameplayStatics.GetAllActorsOfClass(_G.FWORLD(), ASgLayoutActorBase.StaticClass(), Actors)
		for Index = Actors:Length() ,1,-1 do
			local ActorName = Actors:Get(Index):GetName()

			if ActorName == "sg4616656" then
				_G.SignsMgr:AddIgnoreActor(Actors:Get(Index))
				break
			end
		end

		UGameplayStatics.GetAllActorsOfClass(_G.FWORLD(), AStaticMeshActor.StaticClass(), Actors)
		for Index = Actors:Length() ,1,-1 do
			local ActorName = Actors:Get(Index):GetName()
			if ActorName == "f1b1_terrain_a2_6" then
				_G.SignsMgr:AddIgnoreActor(Actors:Get(Index))
				break
			end
		end
	else
		--blockvolume不处理
		local Actors = TArray(AActor)
		UGameplayStatics.GetAllActorsOfClass(_G.FWORLD(), ABlockingVolume.StaticClass(), Actors)
		for Index = Actors:Length() ,1,-1 do
			_G.SignsMgr:AddIgnoreActor(Actors:Get(Index))
		end
	end
end

return SceneMarkersMainPanelView