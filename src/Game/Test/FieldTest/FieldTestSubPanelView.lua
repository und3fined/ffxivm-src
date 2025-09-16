---
--- Author: sammrli
--- DateTime: 2023-05-22 10:04
--- Description: 野外测试工具子面板
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBindableList = require("UI/UIBindableList")
local FieldTestItemVM = require("Game/Test/FieldTest/ViewModel/FieldTestItemVM")
local FieldTestProblemItemVM = require("Game/Test/FieldTest/ViewModel/FieldTestProblemItemVM")
local FateMgr = require("Game/Fate/FateMgr")
local FateMainCfgTable = require("TableCfg/FateMainCfg")
local FieldTestToolCfg = require("TableCfg/FieldTestToolCfg")
local MonsterCfgTable = require("TableCfg/MonsterCfg")
local ActorUtil = require("Utils/ActorUtil")
local MapUtil = require("Game/Map/MapUtil")
local MajorUtil = require("Utils/MajorUtil")
local FateAchievementCfgTable = require("TableCfg/FateAchievementCfg")
local FateAchievementEventCfgTable = require("TableCfg/FateAchievementEventCfg")
local BuffCfgTable = require("TableCfg/BuffCfg")
local ProtoRes = require("Protocol/ProtoRes")
local NpcCfgTable = require("TableCfg/NpcCfg")
--local InteractivedescCfg = require("TableCfg/InteractivedescCfg")
local PWorldMgr = _G.PWorldMgr
local NpcDialogMgr = _G.NpcDialogMgr
local InteractiveMgr = _G.InteractiveMgr
local PathMgr = require("Path/PathMgr")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local FieldTestMgr = require("Game/Test/FieldTest/FieldTestMgr")
local DataTypeDefine = FieldTestMgr.DataTypeDefine

---@class FieldTestSubPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bg UBorder
---@field BillText UMultiLineEditableText
---@field Border UBorder
---@field BtnBack UFButton
---@field BtnBill UFButton
---@field BtnCopy UFButton
---@field BtnNext UFButton
---@field BtnSave UFButton
---@field BtnSwitch UFButton
---@field CommSearchBar_UIBP CommSearchBarView
---@field CommSearchBar_UIBP_Chocobo CommSearchBarView
---@field EditableText UMultiLineEditableText
---@field ItemList UFTreeView
---@field ItemList_Chocobo UFTreeView
---@field ItemView UBorder
---@field ItemView_Chocobo UBorder
---@field ProblemList UTableView
---@field ProblemView UBorder
---@field Text1 UFTextBlock
---@field Text2 UFTextBlock
---@field Text3 UFTextBlock
---@field Text4 UFTextBlock
---@field TitleText UFTextBlock
---@field TitleText_Chocobo UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FieldTestSubPanelView = LuaClass(UIView, true)

function FieldTestSubPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bg = nil
	--self.BillText = nil
	--self.Border = nil
	--self.BtnBack = nil
	--self.BtnBill = nil
	--self.BtnCopy = nil
	--self.BtnNext = nil
	--self.BtnSave = nil
	--self.BtnSwitch = nil
	--self.CommSearchBar_UIBP = nil
	--self.CommSearchBar_UIBP_Chocobo = nil
	--self.EditableText = nil
	--self.ItemList = nil
	--self.ItemList_Chocobo = nil
	--self.ItemView = nil
	--self.ItemView_Chocobo = nil
	--self.ProblemList = nil
	--self.ProblemView = nil
	--self.Text1 = nil
	--self.Text2 = nil
	--self.Text3 = nil
	--self.Text4 = nil
	--self.TitleText = nil
	--self.TitleText_Chocobo = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.CurIndex = 0
	self.TotalItemNum = 0
	self.TotalItemNum_Chocobo = 0
	self.ParentView = nil
	self.OldList = nil
	self.OldList_Chocobo = nil
	self.IsSwitchProblemView = false
end

function FieldTestSubPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommSearchBar_UIBP)
	self:AddSubView(self.CommSearchBar_UIBP_Chocobo)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FieldTestSubPanelView:OnInit()
	self.ItemVMList = UIBindableList.New(FieldTestItemVM)
	self.AdapterItemList = UIAdapterTreeView.CreateAdapter(self, self.ItemList, self.OnSelectChanged)

	self.ItemVMList_Chocobo = UIBindableList.New(FieldTestItemVM)
	self.AdapterItemList_Chocobo = UIAdapterTreeView.CreateAdapter(self, self.ItemList_Chocobo, self.OnSelectChocoboChanged)

	self.ProblemVMList = UIBindableList.New(FieldTestProblemItemVM)
	self.AdapterProblemItemList = UIAdapterTableView.CreateAdapter(self, self.ProblemList, self.OnSelectProblem)

	--override
	self.ItemVMList.GetItemIndex = function(BindableList, Item)
		local Index = 0
		local Items = BindableList.Items
		for i = 1, #Items do
			Index = Index + 1
			if Items[i] == Item then
				return Index
			end

			local Children = Items[i].ChildrenVM
			if Children then
				for j=1, #Children do
					Index = Index + 1
					if Children[j] == Item then
						return Index
					end
				end
			end
		end
		return nil
	end

end

function FieldTestSubPanelView:OnDestroy()

end

function FieldTestSubPanelView:OnShow()
	self.FTextBlock_92:SetText(_G.LSTR(1440025))  --上一个
	self.FTextBlock:SetText(_G.LSTR(1440026))  --下一个
	self.FTextBlock_1:SetText(_G.LSTR(1440027))  --复制
	self.FTextBlock_2:SetText(_G.LSTR(1440028))  --提单
	self.FTextBlock_5:SetText(_G.LSTR(1440029))  --保存
	self.FTextBlock_3:SetText(_G.LSTR(1440031))  --切换列表
	--self:OnClickCancelSearchBar()
	UIUtil.SetIsVisible(self.CommSearchBar_UIBP.FImageSearchDark, false)
	UIUtil.SetIsVisible(self.CommSearchBar_UIBP.FImageSearchLight, false)
	UIUtil.CanvasSlotSetPosition(self.CommSearchBar_UIBP.TextInput,_G.UE.FVector2D(0, 13))

	UIUtil.SetIsVisible(self.CommSearchBar_UIBP_Chocobo.FImageSearchDark, false)
	UIUtil.SetIsVisible(self.CommSearchBar_UIBP_Chocobo.FImageSearchLight, false)
	UIUtil.CanvasSlotSetPosition(self.CommSearchBar_UIBP_Chocobo.TextInput,_G.UE.FVector2D(0, 13))
end

function FieldTestSubPanelView:OnHide()

end

function FieldTestSubPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBack, self.OnClickBackHandle)
	UIUtil.AddOnClickedEvent(self, self.BtnNext, self.OnClickNextHandle)
	UIUtil.AddOnClickedEvent(self, self.BtnCopy, self.OnClickCopyHandle)
	UIUtil.AddOnClickedEvent(self, self.BtnBill, self.OnClickBillHandle)
	UIUtil.AddOnClickedEvent(self, self.BtnSwitch, self.OnClickSwitchHandle)
	UIUtil.AddOnClickedEvent(self, self.BtnSave, self.OnClickSaveHandle)

	self.CommSearchBar_UIBP:SetCallback(self, self.OnSearchTextChange, nil, self.OnClickCancelSearchBar)
	self.CommSearchBar_UIBP_Chocobo:SetCallback(self, self.OnChocoboSearchTextChange, nil, self.OnClickCancelChocoboSearchBar)
end

function FieldTestSubPanelView:OnRegisterGameEvent()

end

function FieldTestSubPanelView:OnRegisterBinder()

end

function FieldTestSubPanelView:SetDataList(DataList)
	self.OldList = DataList
	self.ItemVMList:FreeAllItems()
	self.TotalItemNum = 0
	self.TotalKind = 0
	for i=1, #DataList do
		---@type FieldTestItemData
		local Data = DataList[i]
		self.ItemVMList:AddByValue(Data)
		--计算总数，包括子item
		self.TotalItemNum = self.TotalItemNum + 1
		self.TotalKind = self.TotalKind + 1
		local Children = Data.Children
		if Children and #Children > 1 then -- #Children 不大于1是不创建子item的
			self.TotalItemNum = self.TotalItemNum + #Children
		end
	end
	self.AdapterItemList:UpdateAll(self.ItemVMList)
	self.AdapterItemList:CollapseAll()

	self.TitleText:SetText(string.format("总数:%d", self.TotalKind or 0))
end

function FieldTestSubPanelView:SetChocoboDataList(DataList)
	self.OldList_Chocobo = DataList
	self.ItemVMList_Chocobo:FreeAllItems()

	self.TotalItemNum_Chocobo = 0
	self.TotalKind_Chocobo = 0
	for i=1, #DataList do
		---@type FieldTestItemData
		local Data = DataList[i]
		self.ItemVMList_Chocobo:AddByValue(Data)
		--计算总数，包括子item
		self.TotalItemNum_Chocobo = self.TotalItemNum_Chocobo + 1
		self.TotalKind_Chocobo = self.TotalKind_Chocobo + 1
		local Children = Data.Children
		if Children and #Children > 1 then -- #Children 不大于1是不创建子item的
			self.TotalItemNum_Chocobo = self.TotalItemNum_Chocobo + #Children
		end
	end
	self.AdapterItemList_Chocobo:UpdateAll(self.ItemVMList_Chocobo)
	self.AdapterItemList_Chocobo:CollapseAll()

	self.TitleText_Chocobo:SetText(string.format("总数:%d", self.TotalKind_Chocobo or 0))
end

function FieldTestSubPanelView:UpdateProblemDataList(Type)
	self.ProblemVMList:FreeAllItems()
	-- 增加传送带的固定问题按钮
	if Type == DataTypeDefine.Teleport then
		local Data = {}
		Data.Name = '问题'
		Data.ID = 80001
		Data.Action = 0
		self.ProblemVMList:AddByValue(Data)
		Data.ID = 80002
		self.ProblemVMList:AddByValue(Data)
	elseif Type == DataTypeDefine.Aether then
		local Data = {}
		Data.Name = '问题'
		Data.ID = 100001
		Data.Action = 0
		self.ProblemVMList:AddByValue(Data)
		Data.ID = 100002
		self.ProblemVMList:AddByValue(Data)
	else
		local AllCfg = FieldTestToolCfg:FindAllCfg()
		for _,Cfg in pairs(AllCfg) do
			if math.floor(Cfg.ID / 10000) == Type then
				local Data = {}
				Data.Name = Cfg.Name
				Data.ID = Cfg.ID
				Data.Action = Cfg.Action
				self.ProblemVMList:AddByValue(Data)
			end
		end
	end
	self.AdapterProblemItemList:UpdateAll(self.ProblemVMList)
end

-- 1, Name = "NPC"
-- 2, Name = "怪物"
-- 3, Name = "采集物"
-- 4, Name = "FATE"
-- 5, Name = "音效"
-- 6, Name = "天气"
-- 7, Name = "陆行鸟"
-- 8, Name = "传送带"
-- 9, Name = "钓场"
-- 10,Name = "风脉泉"
---@param ItemData FieldTestItemVM
function FieldTestSubPanelView:OnSelectChanged(Index, ItemData, ItemView, IsByClick)
	self.CurIndex = Index
	self.ItemData = ItemData
	if ItemData then
		local Text = ""
		if not ItemData.IsAutoExpand then
			local Point = ItemData.Point

			if ItemData.Type == DataTypeDefine.Teleport then
				Text = Text..string.format("地图:%s\n\n", ItemData.Name)
				Text = Text..string.format("ExitRangeID:%d\n\n", ItemData.ID)
				if self.ParentView then
					self.ParentView.Box = ItemData.Box
					self.ParentView.Cylinder = ItemData.Cylinder
				end
			elseif ItemData.Type == DataTypeDefine.Fish then
				Text = Text..string.format("钓场ID:%d\n\n", ItemData.ID)
				Text = Text..string.format("钓场名称:%s\n\n", ItemData.Name)
				Text = Text..string.format("钓场类型:%s\n\n", ItemData.FishLocationTye)
				Text = Text..string.format("区域ID:%d\n\n", ItemData.AreaID)
				if self.ParentView then
					self.ParentView.Box = ItemData.Box
					self.ParentView.Cylinder = ItemData.Cylinder
				end
			else
				if ItemData.Type == DataTypeDefine.Weather then
					Text = Text..string.format("ID:%d%s     类型:%s\n\n", ItemData.ID, ItemData.Name, ItemData.WeatherType)
				elseif ItemData.Type == DataTypeDefine.Aether then
					Text = Text..string.format("ID:%d\n\n", ItemData.ID)
					Text = Text..string.format("编辑器ID:%d\n\n", ItemData.AreaID)
				else
					Text = Text..string.format("ID:%d  名字:%s \n\n", ItemData.ID, ItemData.Name)
				end

				if Point then
					local location = string.format("位置:%d %d %d\n\n", Point.X, Point.Y, Point.Z)
					FLOG_INFO(location)
					Text = Text..location
				end

				if ItemData.Type == DataTypeDefine.SoundFX then
					Text = Text..string.format("路径:%s\n", ItemData.SoundPath)
					Text = Text..string.format("音效类型:%s        %s\n", ItemData.SoundType, ItemData.SoundSubType)
					Text = Text..string.format("最小范围:%.2f        \n", ItemData.MinRange)
					Text = Text..string.format("最大范围:%.2f        \n", ItemData.MaxRange)
					Text = Text..string.format("音量大小:%.2f        \n", ItemData.Volume)

					if self.ParentView then
						self.ParentView.SoundSelectedID = ItemData.SoundName
					end
				elseif ItemData.Type == DataTypeDefine.Weather then
					Text = Text..string.format("天气区域:%s\n\n", ItemData.WeatherEnv)
					Text = Text..string.format("资源路径:%s\n", ItemData.WeatherRes)
					if self.ParentView then
						self.ParentView.WeatherSelectedID = Index - 1
					end
				elseif ItemData.Type ~= DataTypeDefine.Aether then
					Text = Text..string.format("数量:%d\n\n", ItemData.Num)
					if ItemData.Type == DataTypeDefine.Monster then
						local Monster = MonsterCfgTable:FindCfgByKey(ItemData.ID)
						if Monster then
							Text = Text..string.format("资源ID:%s\nnormalAI:%s\n战斗AI：%s", tostring(Monster.ProfileName), tostring(ItemData.NormalAI), tostring(Monster.AITableID))
						end
					end

					if ItemData.Behavior ~= nil then
						Text = Text..string.format("BeHaviorID: %d\n\n", ItemData.Behavior)
					end
	
					if ItemData.IdleTimelinePath ~=nil then
						Text = Text..string.format("待机动画: %s\n\n", ItemData.IdleTimelinePath)
					end
				end
			end

			if ItemData.Type == DataTypeDefine.Fate and FateMgr.CurrActiveFateList[ItemData.ID] == nil then
				--移除最近结束时间的
				self:RemoveFate()
				--激活fate
				_G.GMMgr:ReqGM1(string.format("entertain fate start %d", ItemData.ID))
			else
                -- 通过列表选中才把玩家传送过去
				if IsByClick then
					if Point then
						_G.GMMgr:ReqGM1(string.format("cell move pos %d %d %d", Point.X, Point.Y, Point.Z))
					end
				end
			end

			self.EditableText:SetText(Text)
		end

		if ItemData.EntityID and self.ParentView then
			self.ParentView.SelectedEntityID = ItemData.EntityID
		end
	end
end

function FieldTestSubPanelView:OnSelectChocoboChanged(Index, ItemData, ItemView)
	if ItemData then
		self.ItemData_Chocobo = ItemData
		_G.GMMgr:ReqGM(string.format("role quest acceptf %d", ItemData.StartQuestID))
	end
end

---@param ItemData FieldTestProblemItemVM
function FieldTestSubPanelView:OnSelectProblem(Index, ProblemItemVM, ItemView)
	self.ProblemItemVM = ProblemItemVM
	if self.ItemData and ProblemItemVM then
		local ItemData = self.ItemData
		local Point = ItemData.Point
		local TaskID = 0
		if self.ItemData_Chocobo then
			TaskID = self.ItemData_Chocobo.ID
		end
		self.BillText:SetText(self:GetBillTitle(ItemData.Type, ItemData.ID, ProblemItemVM.Name, ItemData.Name, Point.X, Point.Y, Point.Z, ItemData.WeatherEnv, TaskID))
	end
end

function FieldTestSubPanelView:RemoveFate()
	local MinTime = nil
	local MinID = 0
	local FateList = FateMgr.CurrActiveFateList
	local num = table.length(FateList)
	if num < 10 then
		return
	end
	for K,V in pairs(FateList) do
		local FateMainCfg = FateMainCfgTable:FindCfgByKey(K)
		if FateMainCfg then
			local Time = V.StartTime + FateMainCfg.DurationM * 60000
			if not MinTime or Time < MinTime then
				MinTime = Time
				MinID = K
			end
		end
	end
	if MinID > 0 then
		_G.GMMgr:ReqGM1(string.format("entertain fate end %d", MinID))
	end
end

function FieldTestSubPanelView:OnClickBackHandle()
	if not self.CurIndex then
		return
	end

	local Index = self.CurIndex - 1
	if Index < 1 then
		Index = Index + self.TotalItemNum
	end

	self:SetSelectedItem(Index)
end

function FieldTestSubPanelView:OnClickNextHandle()
	if not self.CurIndex then
		return
	end

	local Index = self.CurIndex + 1
	if Index > self.TotalItemNum then
		Index = 1
	end

	self:SetSelectedItem(Index)
end

function  FieldTestSubPanelView:SetSelectedItem(Index)
	local TempIndex = 0
	local ItemList = self.ItemVMList:GetItems()
	if ItemList then
		for i=1, #ItemList do
			TempIndex = TempIndex + 1
			local ParentItem = ItemList[i]
			if ParentItem then
				if TempIndex == Index then
					self.AdapterItemList:SetSelectedItem(ParentItem)
					break
				end

				if ParentItem.ChildrenVM then
					for j=1, #ParentItem.ChildrenVM do
						TempIndex = TempIndex + 1
						local ChildItem = ParentItem.ChildrenVM[j]
						if ChildItem then
							if TempIndex == Index then
								self.AdapterItemList:SetSelectedItem(ChildItem)
								local Key = self.AdapterItemList:GetHash(ParentItem)
								self.AdapterItemList:SetIsExpansion(Key, true)
								return
							end
						end
					end
				end
			end
		end
	end
end

function FieldTestSubPanelView:OnClickCopyHandle()
	_G.CommonUtil.ClipboardCopy(self.EditableText:GetText())
end

function FieldTestSubPanelView:OnClickBillHandle()
	if self.ItemData and self.ProblemItemVM then
		local ProblemItemVM = self.ProblemItemVM
		local ItemData = self.ItemData
		local Point = ItemData.Point
		local ProfileName = 0
		if ItemData.Type == DataTypeDefine.Monster then
			local Monster = MonsterCfgTable:FindCfgByKey(ItemData.ID)
			if Monster then
				ProfileName = Monster.ProfileName
			end
		end
		local TaskID = 0
		if self.ItemData_Chocobo then
			TaskID = self.ItemData_Chocobo.ID
		end
		local Text = string.format("%s \n\n%s \n\n%s",
		self:GetBillTitle(ItemData.Type, ItemData.ID, ProblemItemVM.Name, ItemData.Name, Point.X, Point.Y, Point.Z, ItemData.WeatherEnv, TaskID),
		self:GetBillCommonInfo(ItemData.ID, ItemData.Name, Point.X, Point.Y, Point.Z, ProfileName),
		self:GetBillActionInfo(ProblemItemVM.Action))
		_G.CommonUtil.ClipboardCopy(Text)
	end
end

function FieldTestSubPanelView:GetBillTitle(Type, ID, ProblemName, Name, X, Y, Z, WeatherEnv, ChocoboTaskID)
	local TypeName = ""
	if Type == DataTypeDefine.NPC then
		TypeName = "NPC"
	elseif Type == DataTypeDefine.Monster then
		TypeName = "怪物"
	elseif Type == DataTypeDefine.Gather then
		TypeName = "采集物"
	elseif Type == DataTypeDefine.Fate then
		TypeName = "Fate"
	elseif Type == DataTypeDefine.SoundFX then
		TypeName = "音效"
	elseif Type == DataTypeDefine.Weather then
		TypeName = "天气"
		return string.format("【%s】 【%d%s】 【%s】%s, 坐标: x: %f, y: %f, z: %f", TypeName, ID, Name, ProblemName, WeatherEnv, X, Y, Z)
	elseif Type == DataTypeDefine.Chocobo then
		TypeName = "陆行鸟"
		return string.format("【%s】 【任务ID %d】, 坐标: x: %f, y: %f, z: %f", TypeName, ChocoboTaskID, X, Y, Z)
	elseif Type == DataTypeDefine.Teleport then
		TypeName = "传送带"
		return string.format("【%s】 【%d】 %s", TypeName, ID, Name)
	elseif Type == DataTypeDefine.Fish then
		TypeName = "钓场"
		return string.format("【%s】 【%d】 %s+%s", TypeName, ID, Name, ProblemName)
	elseif Type == DataTypeDefine.Aether then
		TypeName = "风脉泉"
		return string.format("【%s】【%s】%d, 坐标: x: %f, y: %f, z: %f", TypeName, Name, ID, X, Y, Z)
	end
	return string.format("【%s】 【%d】 【%s】%s, 坐标: x: %f, y: %f, z: %f", TypeName, ID, ProblemName, Name, X, Y, Z)
end

function FieldTestSubPanelView:GetBillCommonInfo(ID, Name, X, Y, Z, ProfileName)
	local RoleVM = MajorUtil.GetMajorRoleVM()
	local RoleName = RoleVM and RoleVM.Name or ""
	local Time = os.date("%Y/%m/%d  %H:%M:%S")
	local UIMapID = MapUtil.GetUIMapID(PWorldMgr:GetCurrMapResID())
	local MapName = MapUtil.GetMapName(UIMapID)
	return string.format("【基本信息】\n\n角色ID：%s \n\nbug发生时间: %s \n\n\n\n【问题信息】\nID: %d \n名字: %s \n所在地图: %s\n位置: x: %f, y: %f, z: %f\n资源id:%d",
	RoleName, Time, ID, Name, MapName, X, Y, Z, ProfileName)
end

function FieldTestSubPanelView:GetBillActionInfo(Action)
	local Text = ""
	if not self.ItemData then
		return Text
	end

	if Action == 1 then --动作文件名
		if self.ItemData.EntityID then
			local ActorType = ActorUtil.GetActorType(self.ItemData.EntityID)
			if ActorType == _G.UE.EActorType.Npc then
				local NCfg = NpcCfgTable:FindCfgByKey(self.ItemData.ID)
				if NCfg then
					Text = string.format("动作文件:%s", NCfg.AnimDAName)
				end
			elseif ActorType == _G.UE.EActorType.Monster then
				local Actor = ActorUtil.GetActorByEntityID(self.ItemData.EntityID)
				if Actor then
					local AnimComp = Actor:GetAnimationComponent()
					if AnimComp then
						local AnimInstance = AnimComp:GetAnimInstance()
						if AnimInstance then
							local Montage = AnimInstance:GetCurrentActiveMontage()
							if Montage and Montage.SlotAnimTracks then
								local AnimRef = Montage.SlotAnimTracks[1]
								if AnimRef and AnimRef.AnimTrack and  AnimRef.AnimTrack.AnimSegments then
									local AnimSegment = AnimRef.AnimTrack.AnimSegments[1]
									if AnimSegment and AnimSegment.AnimReference then
										Text = string.format("动作文件:%s", AnimSegment.AnimReference:GetName())
									end
								end
							end
						end
					end
				end
			end
		end
	elseif Action == 2 then --技能组ID
		if self.ItemData.EntityID then
			local Actor = ActorUtil.GetActorByEntityID(self.ItemData.EntityID)
			if Actor then
				local SkillComp = Actor:GetSkillComponent()
				if SkillComp and SkillComp.CurSkillBase then
					Text = string.format("技能组ID:%d", SkillComp.CurSkillBase.CurrentSkillID)
				end
			end
		end
	elseif Action == 3 then --AI名称
		local Monster = MonsterCfgTable:FindCfgByKey(self.ItemData.ID)
		if Monster then
			Text = string.format("AI名称:%d", Monster.AITableID)
		end
	elseif Action == 4 then --对话组ID
		local NCfg = NpcCfgTable:FindCfgByKey(self.ItemData.ID)
		if NCfg then
			if NCfg.DefaultDialogIDList then
				if #NCfg.DefaultDialogIDList == 0 then
					Text = string.format("没有配置对话ID")
				else
					for _,V in pairs(NCfg.DefaultDialogIDList) do
						Text = Text.." "..tostring(V)
					end
					Text = string.format("对话组ID:%s", Text)
				end
			end
		end
	elseif Action == 5 then --行为ID

	elseif Action == 6 then --交互类型
		local NCfg = NpcCfgTable:FindCfgByKey(self.ItemData.ID)
		if NCfg then
			if NCfg.InteractiveIDList then
				if #NCfg.InteractiveIDList == 0 then
					Text = string.format("没有配置交互ID")
				else
					for _,V in pairs(NCfg.InteractiveIDList) do
						Text = Text.." "..tostring(V)
					end
					Text = string.format("交互ID:%s", Text)
				end
			end
		end
	elseif Action == 7 then --奖励ID
	elseif Action == 8 then --条件ID
		local AchievementCfg = FateAchievementCfgTable:FindCfgByKey(self.ItemData.ID)
		if AchievementCfg ~= nil then
			Text = _G.LSTR("危命目标：\n")
			for _,Achievement in pairs(AchievementCfg.Achievements) do
				local EventCfg = FateAchievementEventCfgTable:FindCfgByKey(Achievement.EventID)
				if EventCfg and EventCfg.Config then
					local Param1 = self:GetCondiftionDesc(EventCfg.Config[1], Achievement.Params[1])
					local Param2 = self:GetCondiftionDesc(EventCfg.Config[2], Achievement.Params[2])
					local Param3 = self:GetCondiftionDesc(EventCfg.Config[3], Achievement.Params[3])
					Text = Text..string.format(EventCfg.Text, Param1, Param2, Param3).."\n"
				end
			end
		end
	elseif Action == 9 then --等级
		local Cfg = FateMainCfgTable:FindCfgByKey(self.ItemData.ID)
		if Cfg then
			Text = string.format("等级:%d", Cfg.Level or 0)
		end
	end

	return Text
end

function FieldTestSubPanelView:GetCondiftionDesc(ConfigType, ID)
	if not ConfigType or not ID then
		return ""
	end
	if ConfigType == ProtoRes.FateConditionEventConfig.MONSTER_ID then
		local MonsterCfg = MonsterCfgTable:FindCfgByKey(ID)
		if MonsterCfg ~= nil and MonsterCfg.Name ~= nil then
			return MonsterCfg.Name
		end
	elseif ConfigType == ProtoRes.FateConditionEventConfig.BUFF_ID then
		local BuffCfg = BuffCfgTable:FindCfgByKey(ID)
		if BuffCfg ~= nil and BuffCfg.BuffName ~= nil then
			return BuffCfg.BuffName
		end
	end
	return tostring(ID)
end

function FieldTestSubPanelView:OnClickSwitchHandle()
	self.IsSwitchProblemView = not self.IsSwitchProblemView
	UIUtil.SetIsVisible(self.ProblemView, self.IsSwitchProblemView)
	UIUtil.SetIsVisible(self.ItemView, not self.IsSwitchProblemView)
	if self.IsSwitchProblemView then
		self.TitleText:SetText("问题列表")
	else
		self.TitleText:SetText(string.format("总数:%d", self.TotalKind or 0))
	end
end

function FieldTestSubPanelView:OnShowChocoboView(showChocoboView)
	UIUtil.SetIsVisible(self.ItemView_Chocobo, showChocoboView)
	UIUtil.SetIsVisible(self.Border, showChocoboView)
	UIUtil.SetIsVisible(self.Bg, not showChocoboView)
end

-- 过滤信息
function FieldTestSubPanelView:OnSearchTextChange(SearchText, Length)
	if Length <= 0 then
        if self.OldList ~= nil then
			self:SetDataList(self.OldList)
		end
        return
    end

	local OldList = self.OldList

	if OldList == nil then
		return
	end

	self.ItemVMList:FreeAllItems()
	self.TotalItemNum = 0
	self.TotalKind = 0

	for i = 1, #OldList do
		local StrID = tostring(OldList[i].ID)
		local NameStr = OldList[i].Name
		if string.find(StrID, SearchText) or string.find(NameStr, SearchText) then
			local Data = OldList[i]
			self.ItemVMList:AddByValue(Data)
			--计算总数，包括子item
			self.TotalItemNum = self.TotalItemNum + 1
			self.TotalKind = self.TotalKind + 1
			local Children = Data.Children
			if Children and #Children > 1 then -- #Children 不大于1是不创建子item的
				self.TotalItemNum = self.TotalItemNum + #Children
			end
		end
	end

	self.AdapterItemList:UpdateAll(self.ItemVMList)
	self.AdapterItemList:CollapseAll()

	self.TitleText:SetText(string.format("总数:%d", self.TotalKind or 0))
end

function FieldTestSubPanelView:OnChocoboSearchTextChange(SearchText, Length)
	if Length <= 0 then
        if self.OldList_Chocobo ~= nil then
			self:SetChocoboDataList(self.OldList_Chocobo)
		end
        return
    end

	local OldList = self.OldList_Chocobo

	if OldList == nil then
		return
	end

	self.ItemVMList_Chocobo:FreeAllItems()
	self.TotalItemNum_Chocobo = 0
	self.TotalKind_Chocobo = 0

	for i = 1, #OldList do
		local StrID = tostring(OldList[i].ID)
		local NameStr = OldList[i].Name
		if string.find(StrID, SearchText) or string.find(NameStr, SearchText) then
			local Data = OldList[i]
			self.ItemVMList_Chocobo:AddByValue(Data)
			--计算总数，包括子item
			self.TotalItemNum_Chocobo = self.TotalItemNum_Chocobo + 1
			self.TotalKind_Chocobo = self.TotalKind_Chocobo + 1
			local Children = Data.Children
			if Children and #Children > 1 then -- #Children 不大于1是不创建子item的
				self.TotalItemNum_Chocobo = self.TotalItemNum_Chocobo + #Children
			end
		end
	end

	self.AdapterItemList_Chocobo:UpdateAll(self.ItemVMList_Chocobo)
	self.AdapterItemList_Chocobo:CollapseAll()

	self.TitleText_Chocobo:SetText(string.format("总数:%d", self.TotalKind_Chocobo or 0))
end

function FieldTestSubPanelView:OnClickCancelSearchBar()
	self.CommSearchBar_UIBP:SetText('')
	if self.OldList ~= nil then
		self:SetDataList(self.OldList)
	end
end

function FieldTestSubPanelView:OnClickCancelChocoboSearchBar()
	self.CommSearchBar_UIBP_Chocobo:SetText('')
	if self.OldList_Chocobo ~= nil then
		self:SetChocoboDataList(self.OldList_Chocobo)
	end
end

local function GetPath()
	local Time = _G.TimeUtil.GetLocalTimeFormat("%Y_%m_%d_%H_%M_%S")
	return string.format("%s/Logs/%s.txt", _G.FDIR_SAVED(), Time)
end

local function GetFormat()
	return string.format("===================================\n===================================")
end


function FieldTestSubPanelView:OnClickSaveHandle()
	if self.ProblemItemVM == nil then
		MsgTipsUtil.ShowErrorTips(_G.LSTR("信息不完整，无法保存。"))
	end

	if self.ItemData and self.ProblemItemVM then
		local ProblemItemVM = self.ProblemItemVM
		local ItemData = self.ItemData
		local Point = ItemData.Point
		local ProfileName = 0
		if ItemData.Type == DataTypeDefine.Monster then
			local Monster = MonsterCfgTable:FindCfgByKey(ItemData.ID)
			if Monster then
				ProfileName = Monster.ProfileName
			end
		end
		local TaskID = 0
		if self.ItemData_Chocobo then
			TaskID = self.ItemData_Chocobo.ID
		end
		local Text = string.format("%s\n%s \n\n%s \n\n%s\n%s",
		GetFormat(),
		self:GetBillTitle(ItemData.Type, ItemData.ID, ProblemItemVM.Name, ItemData.Name, Point.X, Point.Y, Point.Z, ItemData.WeatherEnv, TaskID),
		self:GetBillCommonInfo(ItemData.ID, ItemData.Name, Point.X, Point.Y, Point.Z, ProfileName),
		self:GetBillActionInfo(ProblemItemVM.Action),
		GetFormat())

		local Path = GetPath()
		local File = io.open(Path, "w")
		if File then
			if not File:write(Text) then
				File:close()
				os.remove(Path)
				return
			end
			File:flush()
			File:close()
		
			MsgTipsUtil.ShowTips(_G.LSTR("保存成功!"))
		end	
	end
end

return FieldTestSubPanelView