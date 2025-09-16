---
--- Author: Leo
--- DateTime: 2023-05-04 11:47:17
--- Description: 收藏品系统
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local CollectablesDefine = require("Game/Collectables/CollectablesDefine")
local CollectablesMgr = require("Game/Collectables/CollectablesMgr")
local CollectablesMarketItemVM = require("Game/Collectables/ItemVM/CollectablesMarketItemVM")
local CollectablesPropItemVM = require("Game/Collectables/ItemVM/CollectablesPropItemVM")
local CollectablesTransactionItemVM = require("Game/Collectables/ItemVM/CollectablesTransactionItemVM")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local ProtoRes = require("Protocol/ProtoRes")
local ItemCfg = require("TableCfg/ItemCfg")
local CollectInfoCfg = require("TableCfg/CollectInfoCfg")
local RichTextUtil = require("Utils/RichTextUtil")
local MajorUtil = require("Utils/MajorUtil")

local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local ActorMgr = _G.ActorMgr
local LSTR = _G.LSTR
local EToggleButtonState = _G.UE.EToggleButtonState
---@class CollectablesVM : UIViewModel
---@param TicketRewardNum number @当前选择的收藏品可获得工票奖励数量
---@param ExpRewardNum number @当前选择的收藏品可获得经验奖励数量
---@param TicketID string @工票图标ID
---@param bBtnWarnVisible boolean @工票数量超过上限时的警告图标是否显示
---@param bBeyondMaxTicketTipVisible boolean @工票数量超过上限时的提示是否显示
---@param bBtnImgRecommendVisible boolean @按钮可点击图标是否显示
---@param bTextEmptyVisible boolean @收藏品列表为空时的提示是否显示
---@param bTableViewPropVisible boolean @收藏品列表是否显示
---@param CurCollectionVMList UIBindableList @当前收藏品列表
---@param CurTransactionVMList UIBindableList @当前交易可获得奖励列表
---@param PossessCollectablesVMList UIBindableList @拥有的收藏品列表
---
---@param bMaxRecordVisible boolean @最高记录是否显示
---@param MaxRecordText string @最高记录文本
---@param MaxRecordName string @最高记录自己名字
---@param SevenDaySecond number @七天倒计时
---
---@param RecordIconPath string @最高记录图标路径
---@param RecordCollectionName string @最高记录收藏品名称
---@param bRewardVisible boolean @是否显示奖励
---@param TimeTipText number @时间提示文本
---@param LowTicketScoreID string @低级工票积分id
---@param HighTicketScoreID string @高级工票积分id

local CollectablesVM = LuaClass(UIViewModel)

function CollectablesVM:Ctor()

end

function CollectablesVM:OnInit()
    self.TicketRewardNum = 0
    self.ExpRewardNum = 0
    self.TicketID = 0
    self.SelectID = 0
    self.bBtnWarnVisible = false
    self.bBeyondMaxTicketTipVisible = false

    self.bBtnImgRecommendVisible = false
    self.bTextEmptyVisible = true
    self.bTableViewPropVisible = false

    self.bBtnCardVisible = false
    self.bMaxRecordVisible = false
    self.MaxRecordText = CollectablesDefine.MaxRecordBasisText
    self.MaxRecordName = CollectablesDefine.MaxRecordNameBasisText
    self.SevenDaySecond = 5

    self.RecordIconPath = ""
    self.RecordCollectionName = ""
    self.bRewardVisible = true

    self.LowTicketScoreID = ProtoRes.SCORE_TYPE.SCORE_TYPE_HAND_BLUE_CODE
    self.HighTicketScoreID = ProtoRes.SCORE_TYPE.SCORE_TYPE_HAND_BLUE_CODE

    self.PossessCollectRefresh = false
    self.CurCollectionVMList = UIBindableList.New(CollectablesMarketItemVM)
    self.CurTransactionVMList = UIBindableList.New(CollectablesTransactionItemVM)
    self.PossessCollectablesVMList = UIBindableList.New(CollectablesPropItemVM)
end

function CollectablesVM:OnBegin()

end

function CollectablesVM:OnEnd()

end

function CollectablesVM:OnShutdown()
    self.CurCollectionVMList = nil
    self.CurTransactionVMList = nil
    self.PossessCollectablesVMList = nil
end

---@type 更新一下右上角工票图标
function CollectablesVM:UpdateTicketIcon(ProfID)
    local ScoreType = ProtoRes.SCORE_TYPE
    local MinEarHandsProfIndex = CollectablesDefine.MinEarthHandsProfID
    if ProfID < MinEarHandsProfIndex then
        self.LowTicketScoreID = ScoreType.SCORE_TYPE_HAND_BLUE_CODE
		self.HighTicketScoreID = ScoreType.SCORE_TYPE_HAND_RED_CODE
    elseif ProfID >= MinEarHandsProfIndex then
        self.LowTicketScoreID = ScoreType.SCORE_TYPE_GROUND_BLUE_CODE
		self.HighTicketScoreID = ScoreType.SCORE_TYPE_GROUND_RED_CODE
    end
end

---@type 加载采集物列表
---@param AllCollectionData table<number, CollectablesData> @所有采集物数据
function CollectablesVM:UpdateCollectionList(AllCollectionData)
    local CollectionVMList = self.CurCollectionVMList
    CollectionVMList:Clear()
    for i = 1, #AllCollectionData do
        CollectionVMList:AddByValue(AllCollectionData[i])
    end

    local VMNum = CollectionVMList:Length()
    if VMNum < 1 then
        self.bRewardVisible = false
        self.bMaxRecordVisible = false
        return
	end

    local LastSelectData = CollectablesMgr.LastSelectData
    local LastSelectID = LastSelectData.CollectIDMap[LastSelectData.ProfID]
    local DefaultIndex = 1
    if LastSelectID then
        DefaultIndex = CollectionVMList:GetItemIndexByPredicate(function(Item) return LastSelectID == Item.ID end) or 1
    end
    LastSelectData.CurCollectSelectIndex = DefaultIndex
    self:OnSelectChanged(AllCollectionData[DefaultIndex].ID)
end

---@type 设置选择高亮并返回选中的收藏品
function CollectablesVM:GetSelectCollect(ID)
    local AllCollectionItem = self.CurCollectionVMList:GetItems()
    local Color = CollectablesDefine.Color
    local SelectCollection = {}
    --设置颜色与选中状态
    for _, v in pairs(AllCollectionItem) do
        local Elem = v
        if Elem.ID == ID then
            Elem.bIsSelect = EToggleButtonState.Checked
            Elem.bSelect = true
            Elem.Color = Color.White
            Elem.bIsInGrey = false
            SelectCollection = Elem
        else
            Elem.bIsSelect = EToggleButtonState.Unchecked
            Elem.bSelect = false
            if Elem.HoldingNum == 0 then
                Elem.Color = Color.Grey
                Elem.bIsInGrey = true
            else
                Elem.Color = Color.White
                Elem.bIsInGrey = false
            end
        end
    end
    return SelectCollection
end

---@type 根据ID更新选中的收藏品
---@param ID number @收藏品ID
function CollectablesVM:OnSelectChanged(ID)
    local LastSelectData = CollectablesMgr.LastSelectData
    LastSelectData.CollectIDMap[LastSelectData.ProfID] = ID
    self.SelectID = ID
    local SelectCollection = self:GetSelectCollect(ID)
    UIViewMgr:HideView(UIViewID.CollectablesTransactionTipsView)
    --更新右下角工票图标
    self.TicketID = SelectCollection.TicketID
 
    --切换并更新收藏品记录
	if SelectCollection.ProfessionIndex < CollectablesDefine.MinEarthHandsProfID and
     SelectCollection.bIsMaxLevelCollect == 1 then
        self.bMaxRecordVisible = true
	else
        self.bMaxRecordVisible = false
    end
    --更新背包拥有的收藏品
    local AllPossessCollectables = CollectablesMgr:GetCollectionInBag(ID)
    local DataLength = #AllPossessCollectables
    self.bTextEmptyVisible = DataLength < 1
    self.bBtnImgRecommendVisible = DataLength >= 1
    if DataLength >= 1 then
        self.bRewardVisible = true
        self:UpdatePossCollectList(AllPossessCollectables)
    else
        self.bRewardVisible = false
    end
    local bTextEmptyVisible = self.bTextEmptyVisible
    if bTextEmptyVisible then
        self.TicketRewardNum = 0
        self.ExpRewardNum = 0
        self.TicketID = 0
    end
    self.bTableViewPropVisible = not bTextEmptyVisible
    if not self.bTableViewPropVisible then
        self.bBtnWarnVisible = false
    end
    if SelectCollection.ProfessionIndex < CollectablesDefine.MinEarthHandsProfID then
        self:UpdateRecord(ID)
        --CollectablesMgr:SendMsgGetRecordinfo()
    end
end

---@type 加载报酬TableView列表
---@param AllCollectablesRewardData table<number, CollectablesRewardData> @所有报酬数据
---@param bIsMaxLevelCollect boolean @是否是最高等级的收藏品
function CollectablesVM:UpdateRewardList(AllCollectablesRewardData)
    local TransactionVMList = self.CurTransactionVMList
    TransactionVMList:Clear()
    for _, v in pairs(AllCollectablesRewardData) do
        local Elem = v
        TransactionVMList:AddByValue(Elem)
    end
end

---@type 加载背包内有的收藏品列表 Poss = Possess
---@param AllPossessCollectablesData table<number, CollectablesData> @所有拥有的收藏品数据
function CollectablesVM:UpdatePossCollectList(AllPossessCollectablesData)
    local PossessCollectablesVMList = self.PossessCollectablesVMList
    PossessCollectablesVMList:Clear()
    for _, v in pairs(AllPossessCollectablesData) do
        local Elem = v
        PossessCollectablesVMList:AddByValue(Elem)
    end
    self.PossessCollectRefresh = not self.PossessCollectRefresh
    local DeafultIndex = 1
    local DefaultItem = PossessCollectablesVMList:Get(DeafultIndex)
    self:OnPossSelectChanged(DefaultItem)
end

---@type 更新选择拥有的收藏品 应该是根据GID来判断的 Poss = Possess
---@param SelectItem CollectablesPropItemVM @选择的收藏品
function CollectablesVM:OnPossSelectChanged(SelectItem)
    if SelectItem == nil then
        self.bRewardVisible = false
        return
    end
    --设置能获得的报酬和经验
    self:UpdateReward(SelectItem)
    --设置高亮
    local AllPossessCollectables = self.PossessCollectablesVMList:GetItems()
    for _, v in pairs(AllPossessCollectables) do
        local Elem = v
        if Elem == SelectItem then
            Elem.bIsSelect = true
        else
            Elem.bIsSelect = false
        end
    end
end

---@type 设置能获得的报酬和经验
---@param SelectItem CollectablesPropItemVM @选择的收藏品
function CollectablesVM:UpdateReward(SelectItem)
    local ID = SelectItem.ID
    local SelectItemValue = SelectItem.CollectValue
    local CollectionCfg = CollectInfoCfg:FindCfgByKey(ID)
    local CollectValue = CollectionCfg.CollectValue
    local LevelRange = 0
    for i = 1, #CollectValue do
        local Elem = CollectValue[i]
        if SelectItemValue >= Elem then
            LevelRange = i
        end
    end
    local TicketReward
    local SelectCollect = CollectablesVM:GetSelectCollectItem()
    if SelectCollect.bIsMaxLevelCollect == 1 then
        CollectablesMgr.bSelectIsMaxLevelCollection = true
        TicketReward = SelectCollect.HighTicketReward[LevelRange]
    else
        CollectablesMgr.bSelectIsMaxLevelCollection = false
        TicketReward = SelectCollect.LowTicketReward[LevelRange]
    end
    self.TicketRewardNum = TicketReward or 0
    self.ExpRewardNum = SelectCollect.ExperienceReward[LevelRange]

    --判断是警告图片是否显示
    self:UpdateWarnImgVisbile()
end

---@type 判断是警告图片是否显示
function CollectablesVM:UpdateWarnImgVisbile()
    local ProfessData = CollectablesMgr.ProfessionData
    local LastSelectData = CollectablesMgr.LastSelectData
    local SelectProfID = LastSelectData.ProfID or ProfessData[1].ProfID
    local bIsMaxLevelCollect = CollectablesMgr.bSelectIsMaxLevelCollection
    local TicketReward = self.TicketRewardNum
    if SelectProfID < CollectablesDefine.MinEarthHandsProfID then
        if bIsMaxLevelCollect then
            self.bBtnWarnVisible = CollectablesMgr.CHandsHTickets + TicketReward > CollectablesMgr.MHandsHTickets
        else
            self.bBtnWarnVisible = CollectablesMgr.CHandsLTickets + TicketReward > CollectablesMgr.MHandsLTickets
        end
    else
        if bIsMaxLevelCollect then
            self.bBtnWarnVisible = CollectablesMgr.CEarHTickets + TicketReward > CollectablesMgr.MEarHTickets
        else
            self.bBtnWarnVisible = CollectablesMgr.CEarLTickets + TicketReward > CollectablesMgr.MEarLTickets
        end
    end
    -- 当增加工票报酬会超过可拥有最大工票值则只增加到最大值最终显示差值
    if self.bBtnWarnVisible then
        self:SetTicketRewardUnderMax()
    end
end

---@type 当增加工票报酬会超过可拥有最大工票值则只增加到最大值最终显示差值
function CollectablesVM:SetTicketRewardUnderMax()
    local ProfessData = CollectablesMgr.ProfessionData
    local LastSelectData = CollectablesMgr.LastSelectData
    local SelectProfID = LastSelectData.ProfID or ProfessData[1].ProfID
    local bIsMaxLevelCollect = CollectablesMgr.bSelectIsMaxLevelCollection
    if SelectProfID < CollectablesDefine.MinEarthHandsProfID then
        if bIsMaxLevelCollect then
            self.TicketRewardNum = CollectablesMgr.MHandsHTickets - CollectablesMgr.CHandsHTickets
        else
            self.TicketRewardNum = CollectablesMgr.MHandsLTickets - CollectablesMgr.CHandsLTickets
        end
    else
        if bIsMaxLevelCollect then
            self.TicketRewardNum = CollectablesMgr.MEarHTickets - CollectablesMgr.CEarHTickets
        else
            self.TicketRewardNum = CollectablesMgr.MEarLTickets - CollectablesMgr.CEarLTickets
        end
    end
end

---@type 点击交换按钮请求交换
function CollectablesVM:OnBtnExchangeClick()
    local SelectPossCollect = self:GetSelectPossCollect()
    if SelectPossCollect == nil then return end
    CollectablesMgr:SendMsgExchangeinfo(SelectPossCollect.GID, SelectPossCollect.ID)
end

---@type 让选中的收藏品消失
function CollectablesVM:RemovePossCollect()
    local function Predicate(ViewModel)
		if ViewModel.bIsSelect then
			return true
		end
	end
	self.PossessCollectablesVMList:RemoveByPredicate(Predicate)
    local Length = self.PossessCollectablesVMList:Length()
    self.bTextEmptyVisible = Length < 1
    self.bBtnImgRecommendVisible = Length >= 1
    if self.bTextEmptyVisible then
        self.TicketRewardNum = 0
        self.ExpRewardNum = 0
    end
    --更新一下持有数量
    local SelectCollection = self:GetSelectCollectItem()
    SelectCollection:SetHoldingNum()
    --扣除后自动选择第一个道具
    local DefaultIndex = 1
    local DefaultItem = self.PossessCollectablesVMList:Get(DefaultIndex)
    self:OnPossSelectChanged(DefaultItem)
    self.PossessCollectRefresh = not self.PossessCollectRefresh
end

---@type 更新最高纪录数据即查看该收藏品的最高纪录
---@param ID number 收藏品ID
function CollectablesVM:UpdateRecord(ID)
    local RecordInfo = self:GetRecordInfoByID(ID)
    if nil == RecordInfo then
        self.MaxRecordText = CollectablesDefine.MaxRecordBasisText .. "0"
        self.MaxRecordName = CollectablesDefine.MaxRecordNameBasisText .. RichTextUtil.GetText(LSTR(770017), "D8D8D8")
        self.bBtnCardVisible = false
        return
    end

	local RoleID = RecordInfo.RoleID
    CollectablesMgr.RecordRoleID = RoleID
    local RoleDetail = RoleInfoMgr:FindRoleVM(RoleID)
    local Name = RoleDetail.Name
    if Name ~= "" then
        local NameColor = RoleID == MajorUtil.GetMajorRoleID() and "D8D8D8" or "97C3FF"
        Name = CollectablesDefine.MaxRecordNameBasisText .. RichTextUtil.GetText(Name, NameColor)
        self.bBtnCardVisible = true
    else
        Name = CollectablesDefine.MaxRecordNameBasisText ..  RichTextUtil.GetText(LSTR(770016), "D8D8D8")
        self.bBtnCardVisible = false
    end
    self.MaxRecordName = Name
    self.MaxRecordText = CollectablesDefine.MaxRecordBasisText .. tostring(RecordInfo.MaxValue or 0)
end

---@type 根据收藏品的ID获得其记录信息
---@param ID number 收藏品ID
function CollectablesVM:GetRecordInfoByID(ID)
    local AllRecordInfo = CollectablesMgr.AllRecordData
    local RecordList = AllRecordInfo.RecordList
    if nil == RecordList then
        return
    end
    for i = 1, #RecordList do
        local RecordInfo = RecordList[i]
        if RecordInfo.CollectID == ID then
            return RecordInfo
        end
    end
end

---@type 更新打破纪录提示在自己打破纪录时调用
---@param SelectCollection CollectablesItemVM 选中的收藏品
function CollectablesVM:UpdateImproveRecordTips(SelectCollection)
    local ID = SelectCollection.ID
    local Cfg = ItemCfg:FindCfgByKey(ID)
    self.RecordIconPath = ItemCfg.GetIconPath(Cfg.IconID)
    self.RecordCollectionName = ItemCfg:GetItemName(ID)
    local Simple = ActorMgr:GetMajorRoleDetail().Simple

    self.MaxRecordName = CollectablesDefine.MaxRecordNameBasisText .. RichTextUtil.GetText(Simple.Name, "D8D8D8")
    self.MaxRecordText = CollectablesDefine.MaxRecordBasisText .. tostring(SelectCollection.CollectValue or 0) 
    --如果打破记录了更新一下所有的记录信息
	CollectablesMgr:SendMsgGetRecordinfo()
    self:RemovePossCollect()
    CollectablesMgr.RecordRoleID = MajorUtil.GetMajorRoleID()
    self.bBtnCardVisible = true
    local View = _G.UIViewMgr:FindVisibleView(UIViewID.CollectablesMainPanelView)
    if View ~= nil then
        View:RefreshRecordedEffect(self.RecordCollectionName)
    end
    _G.LootMgr:SetDealyState(false)
end

---@type 得到选中的物品
function CollectablesVM:GetSelectPossCollect()
    local AllCollectionData = self.PossessCollectablesVMList:GetItems()
    for _, Elem in pairs(AllCollectionData) do
        if Elem.bIsSelect then
            return Elem
        end
    end
end

---@type 得到选中的收藏品种类
function CollectablesVM:GetSelectCollectItem()
    local AllCollectionData = self.CurCollectionVMList:GetItems()
    for _, Elem in pairs(AllCollectionData) do
         if Elem.bIsSelect == EToggleButtonState.Checked then
             return Elem
         end
    end
end

---@type 刷新当前收藏品列表中各种类收藏品的个数
---@param ResIDList 变动物品的ResID列表
function CollectablesVM:RefreshCollectiblesNum(ResIDList)
    local AllCollectionData = self.CurCollectionVMList:GetItems() or {}
    for i = 1, #AllCollectionData do
        if AllCollectionData[i] and table.contain(ResIDList, AllCollectionData[i].ID) then
            AllCollectionData[i]:SetHoldingNum()
        end
    end
end

return CollectablesVM