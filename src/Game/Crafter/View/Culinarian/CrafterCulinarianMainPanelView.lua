---
--- Author: henghaoli
--- DateTime: 2024-01-04 15:37
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local CrafterCulinarianVM = require("Game/Crafter/View/Culinarian/CrafterCulinarianVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local MajorUtil = require("Utils/MajorUtil")
local AudioUtil = require("Utils/AudioUtil")
local SkillUtil = require("Utils/SkillUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgTipsID = require("Define/MsgTipsID")

local CrafterConfig = require("Define/CrafterConfig")
local ProtoCommon = require("Protocol/ProtoCommon")
local SkillCheckErrorCode = CrafterConfig.SkillCheckErrorCode
local CulinarianConfig = CrafterConfig.ProfConfig[ProtoCommon.prof_type.PROF_TYPE_CULINARIAN]
local EElementItemViewType = CulinarianConfig.EElementItemViewType
local MenphinaBuffID = CulinarianConfig.MenphinaBuffID
local InspireStormBuffID = CulinarianConfig.InspireStormBuffID
local TripleSkillID = CulinarianConfig.TripleSkillID
local ShineSkillID = CulinarianConfig.ShineSkillID

local culinary_element_type = ProtoRes.culinary_element_type

local CULINARY_ELEMENT_TYPE_NONE <const> = culinary_element_type.CULINARY_ELEMENT_TYPE_NONE
local CULINARY_ELEMENT_TYPE_EMPTY <const> = culinary_element_type.CULINARY_ELEMENT_TYPE_EMPTY
local CULINARY_ELEMENT_TYPE_PHANTOM <const> = culinary_element_type.CULINARY_ELEMENT_TYPE_PHANTOM

local MaxElementCount = 5   -- 元素最多的情况: 本来有2个, 随到了3个一样的 2 + 3 = 5

local FlyAnimDelay         = 0.3  -- 飘带动效播放延迟
local AddAnimDelay         = 0.6  -- 添加元素动效播放时间
local EliminationAnimDelay = 0.9  -- 三消动效播放时间

local EObjectGC = _G.UE.EObjectGC

-- 味之本源激活音效
local CulinarianOriginSoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/Characters/Common/Trans_Weapon/Play_craft_cook_1.Play_craft_cook_1'"
-- 灵感三连音效
local AfflatusTripleSoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/Characters/Common/Trans_Weapon/Play_craft_cook_2.Play_craft_cook_2'"
-- 三消音效
local EliminateSoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/Characters/Common/Trans_Weapon/Play_craft_cook_3.Play_craft_cook_3'"

---@class CrafterCulinarianMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Afflatus1 CrafterCulinarianAfflatusItemView
---@field Afflatus2 CrafterCulinarianAfflatusItemView
---@field Afflatus3 CrafterCulinarianAfflatusItemView
---@field BorderEFF1 UBorder
---@field BorderEFF2 UBorder
---@field BorderEFF3 UBorder
---@field BtnAfflatus CrafterCulinarianSkillItemView
---@field BtnImpulse CrafterCulinarianSkillItemView
---@field BtnMemory CrafterCulinarianSkillItemView
---@field PanelHad UFCanvasPanel
---@field PanelSource UFCanvasPanel
---@field PanelSourceTips UFCanvasPanel
---@field SourceItem1 CrafterCulinarianElementItemView
---@field SourceItem2 CrafterCulinarianElementItemView
---@field TableViewAroma UTableView
---@field TableViewColor UTableView
---@field TableViewFlavor UTableView
---@field TableViewHad UTableView
---@field TableViewQuality UTableView
---@field TableViewTaste UTableView
---@field TextSource UFTextBlock
---@field AnimAfflatus1 UWidgetAnimation
---@field AnimAfflatus2 UWidgetAnimation
---@field AnimAfflatus3 UWidgetAnimation
---@field AnimAfflatusTemp UWidgetAnimation
---@field AnimAfflatusThreeIn UWidgetAnimation
---@field AnimAfflatusThreeOut UWidgetAnimation
---@field AnimBenchAdd1 UWidgetAnimation
---@field AnimBenchAdd2 UWidgetAnimation
---@field AnimBenchAdd3 UWidgetAnimation
---@field AnimBenchAdd4 UWidgetAnimation
---@field AnimBenchAdd5 UWidgetAnimation
---@field AnimBenchEliminate1 UWidgetAnimation
---@field AnimBenchEliminate2 UWidgetAnimation
---@field AnimBenchEliminate3 UWidgetAnimation
---@field AnimBenchEliminate4 UWidgetAnimation
---@field AnimBenchEliminate5 UWidgetAnimation
---@field AnimBenchTableResume1 UWidgetAnimation
---@field AnimBenchTableResume2 UWidgetAnimation
---@field AnimBenchTableResume3 UWidgetAnimation
---@field AnimBenchTableResume4 UWidgetAnimation
---@field AnimBenchTableResume5 UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimSourceTipsIn UWidgetAnimation
---@field ElementItemColor1 LinearColor
---@field ElementItemColor2 LinearColor
---@field ElementItemColor3 LinearColor
---@field ElementItemColor4 LinearColor
---@field ElementItemColor5 LinearColor
---@field ElementItemColor6 LinearColor
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterCulinarianMainPanelView = LuaClass(UIView, true)

function CrafterCulinarianMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Afflatus1 = nil
	--self.Afflatus2 = nil
	--self.Afflatus3 = nil
	--self.BorderEFF1 = nil
	--self.BorderEFF2 = nil
	--self.BorderEFF3 = nil
	--self.BtnAfflatus = nil
	--self.BtnImpulse = nil
	--self.BtnMemory = nil
	--self.PanelHad = nil
	--self.PanelSource = nil
	--self.PanelSourceTips = nil
	--self.SourceItem1 = nil
	--self.SourceItem2 = nil
	--self.TableViewAroma = nil
	--self.TableViewColor = nil
	--self.TableViewFlavor = nil
	--self.TableViewHad = nil
	--self.TableViewQuality = nil
	--self.TableViewTaste = nil
	--self.TextSource = nil
	--self.AnimAfflatus1 = nil
	--self.AnimAfflatus2 = nil
	--self.AnimAfflatus3 = nil
	--self.AnimAfflatusTemp = nil
	--self.AnimAfflatusThreeIn = nil
	--self.AnimAfflatusThreeOut = nil
	--self.AnimBenchAdd1 = nil
	--self.AnimBenchAdd2 = nil
	--self.AnimBenchAdd3 = nil
	--self.AnimBenchAdd4 = nil
	--self.AnimBenchAdd5 = nil
	--self.AnimBenchEliminate1 = nil
	--self.AnimBenchEliminate2 = nil
	--self.AnimBenchEliminate3 = nil
	--self.AnimBenchEliminate4 = nil
	--self.AnimBenchEliminate5 = nil
	--self.AnimBenchTableResume1 = nil
	--self.AnimBenchTableResume2 = nil
	--self.AnimBenchTableResume3 = nil
	--self.AnimBenchTableResume4 = nil
	--self.AnimBenchTableResume5 = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimSourceTipsIn = nil
	--self.ElementItemColor1 = nil
	--self.ElementItemColor2 = nil
	--self.ElementItemColor3 = nil
	--self.ElementItemColor4 = nil
	--self.ElementItemColor5 = nil
	--self.ElementItemColor6 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterCulinarianMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Afflatus1)
	self:AddSubView(self.Afflatus2)
	self:AddSubView(self.Afflatus3)
	self:AddSubView(self.BtnAfflatus)
	self:AddSubView(self.BtnImpulse)
	self:AddSubView(self.BtnMemory)
	self:AddSubView(self.SourceItem1)
	self:AddSubView(self.SourceItem2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterCulinarianMainPanelView:OnInit()
	self.CrafterCulinarianVM = CrafterCulinarianVM.New()
	self.AdapterColorElementList = UIAdapterTableView.CreateAdapter(self, self.TableViewColor)
	self.AdapterAromaElementList = UIAdapterTableView.CreateAdapter(self, self.TableViewAroma)
	self.AdapterTasteElementList = UIAdapterTableView.CreateAdapter(self, self.TableViewTaste)
	self.AdapterQualityElementList = UIAdapterTableView.CreateAdapter(self, self.TableViewQuality)
	self.AdapterFlavorElementList = UIAdapterTableView.CreateAdapter(self, self.TableViewFlavor)
	self.AdapterStormList = UIAdapterTableView.CreateAdapter(self, self.TableViewHad)

	local AfflatusMaskTable = {}
	setmetatable(AfflatusMaskTable, { __mode = "k" })
	-- bHasAfflatus取key值时, 需不需要加Mask
	AfflatusMaskTable[self.BtnImpulse]  = { [false] = true,  [true] = false }  -- 实践
	AfflatusMaskTable[self.BtnAfflatus] = { [false] = false, [true] = false }  -- 灵感
	local AfflatusSkillMask =             { [false] = true,  [true] = false }  -- 秘技
	AfflatusMaskTable[self.Afflatus1] =   AfflatusSkillMask
	AfflatusMaskTable[self.Afflatus2] =   AfflatusSkillMask
	AfflatusMaskTable[self.Afflatus3] =   AfflatusSkillMask

	self.AfflatusMaskTable = AfflatusMaskTable

	self.AfflatusList = { self.Afflatus1, self.Afflatus2, self.Afflatus3 }

	self.TextSource:SetText(_G.LSTR(150011))
end

function CrafterCulinarianMainPanelView:OnDestroy()

end

function CrafterCulinarianMainPanelView:OnShow()
	self.CachedOriginElements = {}
	self.bShouldRevise = false
	self.CachedInspireElement = {}
	self.Features = {}
	self.AccumulateElementCount = nil
	self.CurrentSkillID = nil

	local VM = self.CrafterCulinarianVM
	VM:ResetParams()

	local Params = self.Params
	if not Params or not Params.bIsReconnect then
		return
	end
	LifeSkillBuffMgr:MajorInitAllBuffInView(self, self.OnBuffAdd)
end

function CrafterCulinarianMainPanelView:OnHide()
	local VM = self.CrafterCulinarianVM
	_G.CrafterMgr.CachedReconnectionInfo = {
		bHasAfflatusFirstly = VM.bHasAfflatusFirstly,
		AfflatusLockIndex = VM.AfflatusLockIndex,
	}
end

function CrafterCulinarianMainPanelView:OnRegisterUIEvent()

end

function CrafterCulinarianMainPanelView:OnRegisterGameEvent()
	local EventID = _G.EventID
	self:RegisterGameEvent(EventID.CrafterSkillRsp, self.OnEventCrafterSkillRsp)
	self:RegisterGameEvent(EventID.CrafterCulinaryOrigin, self.OnEventCrafterCulinaryOrigin)
	self:RegisterGameEvent(EventID.CrafterCulinaryStorm, self.OnEventCrafterCulinaryStorm)
	self:RegisterGameEvent(EventID.MajorAddBuffLife, self.OnBuffAdd)
	self:RegisterGameEvent(EventID.MajorRemoveBuffLife, self.OnBuffRemove)
end

function CrafterCulinarianMainPanelView:OnRegisterBinder()
	local VM = self.CrafterCulinarianVM
	self.VMElementListMap = {
		-- [culinary_element_type.CULINARY_ELEMENT_TYPE_EMPTY] = nil,
		[culinary_element_type.CULINARY_ELEMENT_TYPE_COLOR] = VM.ColorElementList,
		[culinary_element_type.CULINARY_ELEMENT_TYPE_SWEET] = VM.AromaElementList,
		[culinary_element_type.CULINARY_ELEMENT_TYPE_TASTE] = VM.TasteElementList,
		[culinary_element_type.CULINARY_ELEMENT_TYPE_TEXTURE] = VM.QualityElementList,
		[culinary_element_type.CULINARY_ELEMENT_TYPE_SMELL] = VM.FlavorElementList,
		-- [culinary_element_type.CULINARY_ELEMENT_TYPE_PHANTOM] = nil,
	}
	-- 避免RegisterBinder的时候触发回调
	VM:RawSetBindableProperty("ServerPoolElementCountList", {})

	local Binders = {
		{ "ColorElementList", UIBinderUpdateBindableList.New(self, self.AdapterColorElementList) },
		{ "AromaElementList", UIBinderUpdateBindableList.New(self, self.AdapterAromaElementList) },
		{ "TasteElementList", UIBinderUpdateBindableList.New(self, self.AdapterTasteElementList) },
		{ "QualityElementList", UIBinderUpdateBindableList.New(self, self.AdapterQualityElementList) },
		{ "FlavorElementList", UIBinderUpdateBindableList.New(self, self.AdapterFlavorElementList) },
		{ "PoolElementCountList", UIBinderValueChangedCallback.New(self, nil, self.OnPoolElementCountListChanged) },
		{ "ServerPoolElementCountList", UIBinderValueChangedCallback.New(self, nil, self.OnServerPoolElementCountListChanged) },
		{ "bIsAfflatusTriple", UIBinderValueChangedCallback.New(self, nil, self.OnAfflatusTripleChanged) },
		{ "bHasAfflatus", UIBinderValueChangedCallback.New(self, nil, self.OnHasAfflatusChanged) },
		{ "bHasAfflatusFirstly", UIBinderValueChangedCallback.New(self, nil, self.OnHasAfflatusFirstlyChanged) },
		{ "AfflatusLockIndex", UIBinderValueChangedCallback.New(self, nil, self.OnAfflatusLockIndexChanged) },
		{ "bIsPanelSourceVisible", UIBinderSetIsVisible.New(self, self.PanelSourceTips) },
		{ "bPanelInspireStormVisible", UIBinderSetIsVisible.New(self, self.PanelHad) },  -- 灵感风暴
		{ "bPanelInspireStormVisible", UIBinderValueChangedCallback.New(self, nil, self.OnInspireStormVisibleChanged) },
		{ "StormElementList", UIBinderUpdateBindableList.New(self, self.AdapterStormList) },
	}
	self:RegisterBinders(VM, Binders)

	self:InitElementTableView()
end

local function ElementListSortPredFunc(A, B)
	return A.Index > B.Index
end

function CrafterCulinarianMainPanelView:InitElementTableView()
	local VMElementListMap = self.VMElementListMap
	for _, ElementType in pairs(culinary_element_type) do
		local ElementList = VMElementListMap[ElementType]
		if ElementList then
			local ItemList = {}
			for Index = 1, MaxElementCount do
				table.insert(ItemList, {
					ElementType = ElementType,
					Index = Index,
					ElementItemViewType = EElementItemViewType.TableItem
				})
			end
			ElementList:UpdateByValues(ItemList, ElementListSortPredFunc)
		end
	end
end

local function IsValidPoolElement(ElementType)
	return
		ElementType ~= CULINARY_ELEMENT_TYPE_NONE and
		ElementType ~= CULINARY_ELEMENT_TYPE_EMPTY and
		ElementType ~= CULINARY_ELEMENT_TYPE_PHANTOM
end

function CrafterCulinarianMainPanelView:OnServerPoolElementCountListChanged(
	ServerPoolElementCountList, LastServerPoolElementCountList)
	if ServerPoolElementCountList == nil then
		return
	end

	-- 三消的时候服务器下发的是消除之后的count, 但是客户端要根据上一个数据进行修正
	-- 只有实践技能需要这个修正
	local PoolElementCountListThisFrame = {}
	local ColumnToEliminate = {}  -- 需要播放三消的列
	local ColumnToAdd = {}        -- 需要播放Add动画的列
	local CachedInspireCount = {}

	local CachedInspireElement = self.CachedInspireElement or {}
	local AccumulateElementCount = self.AccumulateElementCount

	if AccumulateElementCount and next(AccumulateElementCount) then
		for ElementType, ElementNum in pairs(AccumulateElementCount) do
			CachedInspireCount[ElementType] = ElementNum
		end
	else
		for _, ElementType in pairs(CachedInspireElement) do
			CachedInspireCount[ElementType] = (CachedInspireCount[ElementType] or 0) + 1
		end
	end

	if LastServerPoolElementCountList then
		for ElementType, ElementCount in pairs(ServerPoolElementCountList) do
			local LastElementCount = LastServerPoolElementCountList[ElementType] or 0
			local ElementCountThisFrame = LastElementCount + (CachedInspireCount[ElementType] or 0)
			if self.bShouldRevise and ElementCountThisFrame ~= ElementCount and IsValidPoolElement(ElementType) then
				PoolElementCountListThisFrame[ElementType] = ElementCountThisFrame
				table.insert(ColumnToEliminate, ElementType)
			else
				PoolElementCountListThisFrame[ElementType] = ElementCount
			end

			if ElementCountThisFrame > LastElementCount then
				table.insert(ColumnToAdd, ElementType)
			end
		end
	else
		PoolElementCountListThisFrame = table.deepcopy(ServerPoolElementCountList)
	end

	local VM = self.CrafterCulinarianVM
	self:RegisterTimer(function()
		VM.PoolElementCountList = PoolElementCountListThisFrame

		-- 播放Add动画
		if self.bShouldRevise then
			for _, ElementType in pairs(ColumnToAdd) do
				self:PlayAnimation(self["AnimBenchAdd" .. tostring(ElementType - 1)])
			end
		end
	end, AddAnimDelay, nil, 1)

	if next(ColumnToEliminate) then
		self:RegisterTimer(function()
			local UWidgetAnimationPlayCallbackProxy = _G.UE.UWidgetAnimationPlayCallbackProxy
			AudioUtil.LoadAndPlay2DSound(EliminateSoundPath, EObjectGC.Cache_Map)
			for _, ElementType in pairs(ColumnToEliminate) do
				VM.PoolElementCountList = table.deepcopy(ServerPoolElementCountList)
				local CallbackProxy = UWidgetAnimationPlayCallbackProxy.CreatePlayAnimationProxyObject(
					nil, self, self["AnimBenchEliminate" .. tostring(ElementType - 1)])
				local Ref = UnLua.Ref(CallbackProxy)
				local OnEliminateAnimFinished = function()
					UnLua.Unref(CallbackProxy)
					Ref = nil
					self:PlayAnimation(self["AnimBenchTableResume" .. tostring(ElementType - 1)])
				end
				CallbackProxy.Finished:Add(self, OnEliminateAnimFinished)
			end
		end, EliminationAnimDelay, nil, 1)
	end
end

function CrafterCulinarianMainPanelView:OnAfflatusTripleChanged(bIsAfflatusTriple)
	if bIsAfflatusTriple then
		self:PlayAnimation(self.AnimAfflatusThreeIn)
	else
		self:PlayAnimation(self.AnimAfflatusThreeOut)
	end

	local AfflatusList = self.AfflatusList
	for _, AfflatusItem in pairs(AfflatusList) do
		AfflatusItem:SetIsTriple(bIsAfflatusTriple)
	end
end

function CrafterCulinarianMainPanelView:OnHasAfflatusChanged(bHasAfflatus)
	local AfflatusMaskTable = self.AfflatusMaskTable
	for SkillItemView, Mask in pairs(AfflatusMaskTable) do
		SkillItemView:UpdateCulinarianMaskFlag(Mask[bHasAfflatus])
	end

	if bHasAfflatus then
		self.CrafterCulinarianVM.bHasAfflatusFirstly = true
	end
end

function CrafterCulinarianMainPanelView:OnHasAfflatusFirstlyChanged(bHasAfflatusFirstly)
	local AfflatusList = self.AfflatusList
	for _, AfflatusItem in pairs(AfflatusList) do
		AfflatusItem.BaseBtnVM.bRefreshPanelVisible = bHasAfflatusFirstly
		AfflatusItem:UpdateAfflatusFirstlyMaskFlag(not bHasAfflatusFirstly)

		AfflatusItem:SetHasElement(bHasAfflatusFirstly)
	end
end

function CrafterCulinarianMainPanelView:OnAfflatusLockIndexChanged(AfflatusLockIndex)
	local AfflatusList = self.AfflatusList
	for _, AfflatusItem in pairs(AfflatusList) do
		AfflatusItem:UpdateAfflatusLockMaskFlag(
			AfflatusLockIndex ~= -1 and AfflatusLockIndex ~= AfflatusItem.AfflatusIndex)
	end
end

-- 更新元素可见性
local function UpdateElementListItems(ElementList, ElementCount, bIsShineSkill)
	if ElementList then
		for Index = 1, MaxElementCount do
			-- items是倒序的, 需要把下标转一下
			local Item = ElementList:Get(MaxElementCount - Index + 1)
			if Item then
				local bLastIsVisible = Item.bIsVisible
				local bIsVisible = Index <= ElementCount
				Item.bIsVisible = bIsVisible
				if bIsVisible ~= bLastIsVisible then
					Item.bShine = bIsVisible and bIsShineSkill
				end
			end
		end
	end
end

function CrafterCulinarianMainPanelView:OnPoolElementCountListChanged(PoolElementCountList)
	if PoolElementCountList == nil then
		return
	end

	local SkillID = self.CurrentSkillID
	local bIsShineSkill = SkillID == ShineSkillID
	local VMElementListMap = self.VMElementListMap
	for ElementType, ElementCount in pairs(PoolElementCountList) do
		local ElementList = VMElementListMap[ElementType]
		UpdateElementListItems(ElementList, ElementCount, bIsShineSkill)
	end
end

-- 转为下标从0开始的数组
local function ServerArrayToLua(ServerArray)
	local LuaArray = {}
	ServerArray = ServerArray or {}
	for Key, Value in pairs(ServerArray) do
		LuaArray[Key - 1] = Value
	end
	return LuaArray
end

-- table.find_item是从下标1开始顺次遍历, 如果key不连续或者从0开始就会出问题
local function TableFindItem(T, E)
	if not T then
		return
	end

	for k, v in pairs(T) do
		if E == v then
			return E, k
		end
	end
end

-- 判断是否触发味之本源
function CrafterCulinarianMainPanelView:CheckCulinaryOrigin(InspireElement)
	InspireElement = table.deepcopy(InspireElement)
	if InspireElement == nil or next(InspireElement) == nil then
		return false
	end

	local CachedOriginElements = self.CachedOriginElements
	if CachedOriginElements == nil or next(CachedOriginElements) == nil then
		return false
	end

	-- 返回激活味之本源的 Type -> Index 表
	local TypeIndexMap = {}
	for Type, _ in pairs(CachedOriginElements) do
		local _, Index = TableFindItem(InspireElement, Type)
		-- 尝试查找幻之味
		if not Index then
			_, Index = TableFindItem(InspireElement, CULINARY_ELEMENT_TYPE_PHANTOM)
		end

		-- 仍然找不到, 返回false
		if not Index then
			return false
		end
		InspireElement[Index] = CULINARY_ELEMENT_TYPE_NONE
		TypeIndexMap[Type] = Index
	end

	return TypeIndexMap
end

local function CheckTriple(InspireElement)
	-- 检查是否存在三连
	-- 彩球可以当成任意一种元素
	if not SkillUtil.IsMajorSkillLearned(TripleSkillID) then
		return false
	end

	if InspireElement == nil or next(InspireElement) == nil then
		return false
	end

	local TypeList = {}
	for _, Type in pairs(InspireElement) do
		if TableFindItem(TypeList, Type) == nil then
			table.insert(TypeList, Type)
		end
	end

	if TableFindItem(TypeList, CULINARY_ELEMENT_TYPE_EMPTY) then
		return false
	end
	if TableFindItem(TypeList, CULINARY_ELEMENT_TYPE_NONE) then
		return false
	end

	local TypeNum = #TypeList
	if TypeNum == 1 then
		return true
	end
	if TypeNum == 2 and TableFindItem(TypeList, CULINARY_ELEMENT_TYPE_PHANTOM) then
		return true
	end
	return false
end

function CrafterCulinarianMainPanelView:OnEventCrafterSkillRsp(MsgBody)
	local CrafterSkill = MsgBody.CrafterSkill
	self.CurrentSkillID = MsgBody.LifeSkillID
	if CrafterSkill then
		self.Features = CrafterSkill.Features

        local MajorEntityID = MajorUtil.GetMajorEntityID()
		if MajorEntityID == MsgBody.ObjID then
			local Culinary = CrafterSkill.Culinary
			if nil == Culinary then
				return
			end
			if CrafterSkill.Success ~= true then
				return
			end

			-- 更新实践状态
			local LifeSkillID = MsgBody.LifeSkillID
			local VM = self.CrafterCulinarianVM
			local bHasAfflatus = VM.bHasAfflatus
			if LifeSkillID == self.BtnImpulse.BtnSkillID and bHasAfflatus then
				VM.bHasAfflatus = false
				VM.AfflatusLockIndex = -1
			elseif LifeSkillID == self.BtnAfflatus.BtnSkillID then
				VM.AfflatusLockIndex = -1
				if not bHasAfflatus then
					VM.bHasAfflatus = true
				end
			end

			local InspireElement = ServerArrayToLua(Culinary.InspireElement)
			local CachedInspireElement = self.CachedInspireElement

			local AccumulateElementCount = Culinary.AccumulateElementCount
			self.AccumulateElementCount = ServerArrayToLua(AccumulateElementCount)

			-- 只有实践技能需要修正
			if LifeSkillID == self.BtnImpulse.BtnSkillID then
				self.bShouldRevise = true
				local AfflatusList = self.AfflatusList
				for AfflatusIndex, ElementType in pairs(CachedInspireElement) do
					local IndexStr = tostring(AfflatusIndex + 1)
					local Border = self["BorderEFF" .. IndexStr]  -- 为什么这里又＋1了? 因为美术定义的下标从1开始
					local ElementItemColor = self["ElementItemColor" .. tostring(ElementType - 1)]
					if Border and ElementItemColor then
						Border:SetContentColorAndOpacity(ElementItemColor)
						self:RegisterTimer(function()
							self:PlayAnimation(self["AnimAfflatus" .. IndexStr])
						end, FlyAnimDelay, nil, 1)
						local AfflatusWidget = AfflatusList[AfflatusIndex + 1]
						if ElementType > 0 then
							AfflatusWidget:PlayAnimation(AfflatusWidget.AnimDrop)
						end
					end
				end
			elseif AccumulateElementCount and next(AccumulateElementCount) then  -- 如果下发了AccumulateElementCount, 也需要修正
				self.bShouldRevise = true
			else
				self.bShouldRevise = false
			end

			VM.ServerPoolElementCountList = ServerArrayToLua(Culinary.PoolElementCount)

			-- 判断是不是有三连
			if CheckTriple(InspireElement) then
				VM.bIsAfflatusTriple = true
				if self:IsSkillChangeInspireElement(LifeSkillID) then
					AudioUtil.LoadAndPlay2DSound(AfflatusTripleSoundPath)
				end
			else
				VM.bIsAfflatusTriple = false
			end

			-- 判断是不是应该播放味之本源的音效
			local CulinaryOriginTypeIndexMap = self:CheckCulinaryOrigin(InspireElement)
			if CulinaryOriginTypeIndexMap then
				local LastCulinaryOriginTypeIndexMap = self:CheckCulinaryOrigin(self.CachedInspireElement) or {}
				if not table.compare_table(CulinaryOriginTypeIndexMap, LastCulinaryOriginTypeIndexMap) then
					AudioUtil.LoadAndPlay2DSound(CulinarianOriginSoundPath, EObjectGC.Cache_Map)
				end
			end
			self.CachedInspireElement = InspireElement
		end
	end
end

function CrafterCulinarianMainPanelView:OnEventCrafterCulinaryOrigin(MsgBody)
	if not MsgBody then
		return
	end

	local Origin = MsgBody.Origin
	if Origin then
		-- 保证味之本源的两个元素一定不是同一种
		local OriginElement = Origin.OriginElement
		local CachedOriginElements = self.CachedOriginElements
		for Index, ElementType in pairs(OriginElement) do
			CachedOriginElements[ElementType] = true
			self["SourceItem" .. tostring(Index)].VM.ElementType = ElementType
		end

		-- 隐藏BtnMemory
		self.BtnMemory.BaseBtnVM.bIsVisible = false
		local VM = self.CrafterCulinarianVM
		VM.bIsPanelSourceVisible = true
		self:PlayAnimation(self.AnimSourceTipsIn)
	end
end

function CrafterCulinarianMainPanelView:OnEventCrafterCulinaryStorm(MsgStorm)
	if not MsgStorm then
		return
	end
	local Elements = MsgStorm.StormElement
	local Count = #Elements
	if Count ~= 2 then  -- 灵感风暴固定两个元素
		_G.FLOG_ERROR("[CrafterCulinarian] Culinary storm num of elements: %d, 2 expected.", Count)
		return
	end

	local ItemList = {}
	for Index = 1, Count do
		table.insert(ItemList, {
			ElementType = Elements[Index],
			Index = Index,
			ElementItemViewType = EElementItemViewType.StormItem
		})
	end
	local VM = self.CrafterCulinarianVM
	VM.StormElementList:UpdateByValues(ItemList)
end

-- buff相关
function CrafterCulinarianMainPanelView:SetInspireStormMask(bHasMask)
	local AfflatusList = self.AfflatusList
	for _, View in pairs(AfflatusList) do
		View:UpdateAfflatusInspireStormMaskFlag(bHasMask)
	end
	local VM = self.CrafterCulinarianVM
	if VM then
		VM.bPanelInspireStormVisible = bHasMask
	end
end

function CrafterCulinarianMainPanelView:OnBuffAdd(BuffInfo)
	local BuffID = BuffInfo.BuffID
	self.CrafterCulinarianVM:OnBuffChanged(BuffID, true)

	if BuffID == MenphinaBuffID then
		local AfflatusElementList = { self.Afflatus1.Element, self.Afflatus2.Element, self.Afflatus3.Element }

		-- 初始元素三个元素不是空, 不应该播特效
		if not self.CrafterCulinarianVM.bHasAfflatusFirstly then
			return
		end

		-- 刚添加buff的时候, 需要把已经存在的空播一下动画
		for _, ElementView in pairs(AfflatusElementList) do
			local ElementType = ElementView.VM.ElementType
			if ElementType == CULINARY_ELEMENT_TYPE_EMPTY then
				ElementView:OnElementTypeChanged(ElementType)
			end
		end
	end

	if BuffID == InspireStormBuffID then
		self:SetInspireStormMask(true)
	end
end

function CrafterCulinarianMainPanelView:OnBuffRemove(BuffInfo)
	local BuffID = BuffInfo.BuffID
	self.CrafterCulinarianVM:OnBuffChanged(BuffID, false)

	if BuffID == InspireStormBuffID then
		self:SetInspireStormMask(false)
	end
end

-- 技能是否会改变灵感槽里面的元素
function CrafterCulinarianMainPanelView:IsSkillChangeInspireElement(SkillID)
	if SkillID == self.BtnAfflatus.BtnSkillID or SkillID == self.Afflatus1.BtnSkillID then
		return true
	end
	return false
end

-- 2: 推进; 9: 秘技; 6: 灵感; 7: 实践; 19: 食神的记忆
local CheckSkillIndexList = { 2, 9, 6, 7, 19 }
function CrafterCulinarianMainPanelView:CustomCheckSkillValid(Index, SkillID, ExtraParams)
	if TableFindItem(CheckSkillIndexList, Index) == nil then
		return true
	end

	if Index == 2 then
		local CrafterMainPanelView = _G.UIViewMgr:FindView(_G.UIViewID.CrafterMainPanel)
		if CrafterMainPanelView == nil then
			return true
		end

		local VM = CrafterMainPanelView.SidebarPanelNew.ViewModel
		if nil == VM then
			return true
		end

		local RecipeConfig = VM.RecipeConfig
		if nil == RecipeConfig then
			return true
		end

		local Features = self.Features or {}  -- 第一次调用的时候, 可能没有Feature
		local ProgressValue = Features[ProtoCS.FeatureType.FEATURE_TYPE_PROGRESS] or 0
		local QualityValue = Features[ProtoCS.FeatureType.FEATURE_TYPE_QUALITY] or 0

		local ProgressPercent = ProgressValue / RecipeConfig.ProgressMax
		local QualityPercent = QualityValue / RecipeConfig.QualityMax

		if ProgressPercent > QualityPercent then
			MsgTipsUtil.ShowTipsByID(MsgTipsID.CulinarianPushNotValid)
			return false, SkillCheckErrorCode.CulinarianPushNotValid
		end
	else
		local SkillViews = _G.CrafterMgr:GetSkillViewsByIndex(Index) or {}
		for _, View in pairs(SkillViews) do
			if View:CheckViewCorrespondingToSkill(Index, SkillID, ExtraParams) then
				if View.CheckCanCastSkill then
					return View:CheckCanCastSkill()
				end
			end
		end
	end
	return true, nil
end

-- 处理断线重连
function CrafterCulinarianMainPanelView:OnCrafterReconnectionRsp(CrafterGet)
	local GetCulinary = CrafterGet.GetCulinary
	if not GetCulinary then
		return
	end

	local VM = self.CrafterCulinarianVM
	VM.bHasAfflatus = GetCulinary.InInspireStatus

	local Params = self.Params or {}
	local CachedReconnectionInfo = Params.CachedReconnectionInfo or {}
	VM.bHasAfflatusFirstly = CachedReconnectionInfo.bHasAfflatusFirstly

	if GetCulinary.SecretUsed then
		VM.AfflatusLockIndex = GetCulinary.SecretIndex
	else
		VM.AfflatusLockIndex = -1
	end

	local OriginElement = GetCulinary.OriginElement
	-- 和服务器约定不为空表示味之本源已经激活
	if OriginElement and next(OriginElement) then
		_G.EventMgr:SendEvent(_G.EventID.CrafterCulinaryOrigin, {
			Origin = { OriginElement = OriginElement }
		})
	end
end

function CrafterCulinarianMainPanelView:OnInspireStormVisibleChanged(bVisible)
	local BtnAfflatus = self.BtnAfflatus
	if not BtnAfflatus then
		return
	end
	if bVisible then
		BtnAfflatus:PlayAnimation(BtnAfflatus.AnimInspirationStormShow)
	else
		BtnAfflatus:PlayAnimation(BtnAfflatus.AnimInspirationStormHide)
	end
end

return CrafterCulinarianMainPanelView