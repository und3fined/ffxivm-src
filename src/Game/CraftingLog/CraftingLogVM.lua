local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ItemTypeCfg = require("TableCfg/ItemTypeCfg")
local CommLight152Slot = require("Game/Common/Slot/CommLight152SlotView")
local ItemCfg = require("TableCfg/ItemCfg")
local CraftingLogPropItemVM = require("Game/CraftingLog/ItemVM/CraftingLogPropItemVM")
local CraftingLogConditionItemVM = require("Game/CraftingLog/ItemVM/CraftingLogConditionItemVM")
local GatheringSearchRescordVM = require("Game/GatheringLog/ItemVM/GatheringSearchRescordVM")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local CollectInfoCfg = require("TableCfg/CollectInfoCfg")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local CraftingLogDefine = require("Game/CraftingLog/CraftingLogDefine")
local CraftingLogMgr = require("Game/CraftingLog/CraftingLogMgr")
local DataReportUtil = require("Utils/DataReportUtil")
local CraftingLogTextItemVM = require("Game/CraftingLog/ItemVM/CraftingLogTextItemVM")
local CraftingLogMaterialListItemVM = require("Game/CraftingLog/ItemVM/CraftingLogMaterialListItemVM")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local LSTR = _G.LSTR

---@class CraftingLogVM : UIViewModel
---@field bBtnCloseShow boolean @关闭按键
---@field bBtnBackShow boolean @返回按键
---@field TitleName string @标题名称
---@field SubTitle string @职业名称
---
---@field bVerIconTabsShow boolean @职业列表
---@field bDropDownShow boolean @下拉筛选
---@field PropItemTabAdapter UIBindableList @道具列表
---@field bPanelInfoShow boolean @右侧道具详情
---@field InUseItemName string @右侧名称
---@field MaterialItemAdapter UIBindableList @制作耗材列表
---@field ConditionItemAdapter UIBindableList @制作说明
---@field InUseItemDes string @描述
---@field TextNoticeTips string @描述
---@field InUseItemRecipeDetail string @配方信息
---@field bImgSubtractShow boolean @数量减少
---@field bImgSubtractDisableShow boolean @数量最少
---@field bImgAddShow boolean @数量增加
---@field bImgAddDisableShow boolean @数量最多
---@field bPanelAmountRootShow boolean @数量节点
---@field bPanelListEmptyShow boolean @列表为空
---
---@field CraftingTextAmount string @当前制作数量
---@field CraftingTextAmountColor string @当前制作数量颜色
---@field bBorderNoticeShow boolean @tips显影
---
---@field TableViewHistoryAdapter UIBindableList @搜索历史记录
local CraftingLogVM = LuaClass(UIViewModel)

---Ctor
function CraftingLogVM:Ctor()
    self.PropItemTabAdapter = UIBindableList.New(CraftingLogPropItemVM)
    self.ConditionItemAdapter = UIBindableList.New(CraftingLogConditionItemVM)
    self.MaterialItemAdapter = UIBindableList.New(CraftingLogMaterialListItemVM)
    self.CrystalItemAdapter = UIBindableList.New(CraftingLogMaterialListItemVM)
    self.TableViewHistoryAdapter = UIBindableList.New(GatheringSearchRescordVM)
    self:Reset()
end

function CraftingLogVM:OnInit()
end

function CraftingLogVM:OnBegin()
end

function CraftingLogVM:OnEnd()
end

function CraftingLogVM:OnShutdown()
    self:Reset()
end

function CraftingLogVM:Reset()
    self.PropItemTabAdapter:Clear()
    self.ConditionItemAdapter:Clear()
    self.MaterialItemAdapter:Clear()
    self.CrystalItemAdapter:Clear()
    self.TableViewHistoryAdapter:Clear()
    self.TitleName = LSTR(80041) --制作笔记
    self.SubTitle = ""
    self.TextCraftTips = ""

    self.InUseItemName = ""
    self.bSlotTextNumShow = true
    self.InUseItemDes = ""
    self.TextNoticeTips = ""
    self.InUseItemRecipeDetail = ""
    self.CraftingTextAmount = ""
    self.CraftingTextAmountColor = "FFFFFFFF"
    self.bBorderNoticeShow = false
    self.IconID = nil
    self.ItemQualityImg = nil
    self.TextNum = ""
    self.bLeveQuestMarked = false

    self.BtnCraftText = ""
    self.bBtnBackShow = false
    self.bBtnCloseShow = true
    self.bImgSubtractShow = true
    self.bImgSubtractDisableShow = false
    self.bImgAddShow = true
    self.bImgAddDisableShow = false
    self.bImgMaxNormalShow = true
    self.bPanelAmountRootShow = true
    self.bPanelListEmptyShow = true
    self.TextListEmpty = ""
    self.bBatchMakeShow = false
    self.bTrainMakeShow = false

    self.bVerIconTabsShow = false
    self.bDropDownShow = false
    self.bDropDownTextQuantityShow = false
    self.bPanelInfoShow = false
    
    self.bSetFavor = false
    self.bSearchHistoryShow = false
    self.bBtnDeleteShow = false
    self.bBuyShow = true
end

--获取配方VM
function CraftingLogVM:GetItemVMByItemID(ID)
    if ID == nil then
        FLOG_ERROR("CraftingLogVM:GetItemVMByItemID ItemID is nil")
        return
    end
    if self.PropItemTabAdapter == nil then
        return
    end
    local AllItemVMs = self.PropItemTabAdapter:GetItems()
    for _, v in pairs(AllItemVMs) do
        if v.ID == ID then
            return v
        end
    end
end

--获取配方配置数据
function CraftingLogVM:GetPropItemByID(ID)
    local AllItemList = self:GetPropItemList()
    for _, value in pairs(AllItemList) do
        if value.ID == ID then
            return value
        end
    end
end

---获取当前显示的道具列表
function CraftingLogVM:GetPropItemList()
    local AllItemList = self.PropItemTabAdapter:GetItems() or {}
    return AllItemList
end

---刷新装备列表
---@param PropData table<number, PropData> @道具数据
function CraftingLogVM:UpdatePropItemListTab(PropData, NowRecipeIndex)
    PropData = PropData or {}
    local ProfID = CraftingLogMgr.LastChoiceCareer
    local MarkedItemID = _G.LeveQuestMgr:GetMarkedItemByProfID(ProfID)
    for _, value in pairs(PropData) do
        value.bSelect = false
        value.bLeveQuestMarked = MarkedItemID and (MarkedItemID == value.ProductID or MarkedItemID == value.HQProductID)
    end
    local ThisPropData = PropData[NowRecipeIndex]
    if ThisPropData then
        ThisPropData.bSelect = true
    end
    if self.PropItemTabAdapter == nil then
        _G.FLOG_ERROR("CraftingLogVM.PropItemTabAdapter is nil")
        return
    end
    self.PropItemTabAdapter:Clear()
    local HaveRecipe = false
    for _, Elem in pairs(PropData) do
        local VM = nil
        if Elem.TextTips ~= nil then
            VM = _G.ObjectPoolMgr:AllocObject(CraftingLogTextItemVM)
        else
            VM = _G.ObjectPoolMgr:AllocObject(CraftingLogPropItemVM)
            HaveRecipe = true
        end
        VM:UpdateVM(Elem)
        self.PropItemTabAdapter:Add(VM)
    end
    -- 没有如何符合条件道具
    if PropData == nil or #PropData <= 0 then
        self:NoAnyFormula()
        if CraftingLogMgr.CraftingState == CraftingLogDefine.CraftingLogState.Searching then
            CraftingLogMgr.NowSearchPropData = nil
        else
            CraftingLogMgr.NowChoicePropData = nil
        end
        return
    end
    self:PropItemOnClick(ThisPropData)
    local StatePick = CraftingLogDefine.CraftingLogState.Picking
    if CraftingLogMgr.CraftingState == StatePick then
        CraftingLogVM:PanleInit()
    end
    --如果是列表中只有传承录提示item，也要展示空页签在右侧
    if HaveRecipe == false and CraftingLogMgr.LastHorTabIndex == CraftingLogDefine.FilterALLType.Career then
        self.bPanelListEmptyShow = true
        self.TextListEmpty = LSTR(CraftingLogDefine.SpecialListEmpty)
    end
end

---刷新制作材料列表
---@param MaterialData any @ 材料
---@param CrystalTypeData any @ 触媒
function CraftingLogVM:UpdateMaterialListTab(MaterialData, CrystalTypeData)
    if MaterialData == nil then
        return
    end
    self.MaterialItemAdapter:Clear()
    CraftingLogMgr:ToGetMakeUpperLimit(MaterialData, CrystalTypeData) -- 制作数量上线
    self.MaterialItemAdapter:UpdateByValues(MaterialData, nil)
    self:UpdateCrystalListTab(CrystalTypeData)
end

---刷新触媒列表
---@param CrystalTypeData any @ 触媒
function CraftingLogVM:UpdateCrystalListTab(CrystalTypeData)
    if not CrystalTypeData then
        return
    end

    self.CrystalItemAdapter:Clear()
    for _, value in pairs(CrystalTypeData) do
        self.CrystalItemAdapter:AddByValue(value, nil, true)
    end
    local CrystalList = self.CrystalItemAdapter:GetItems()
    for _, value in pairs(CrystalList) do
        value:UpdataTextNum(CraftingLogMgr.NowMakeCount)
    end
end

---左侧道具被点击
---@param PropData table @道具数据
function CraftingLogVM:PropItemOnClick(PropData)
    if PropData == nil or PropData.TextTips ~= nil then
        return
    end
    --CraftingLogMgr:SendMsgQueryProductionRecipe(PropData.ID)
    local State = CraftingLogDefine.CraftingLogState
    if CraftingLogMgr.CraftingState == State.InFunSearch then
        _G.EventMgr:SendEvent(_G.EventID.CraftingLogExitSearchState)
    end
    CraftingLogMgr:SetNowChoicePropData(PropData)
    CraftingLogMgr:ChangeNowProfData()
    self:SetCareerTitle(RoleInitCfg:FindRoleInitProfName(PropData.Craftjob))
    self:RefreshPropInfo(PropData)

    local CollectionList = CraftingLogMgr.CollectListData[PropData.Craftjob]
    if CollectionList then
        self.bSetFavor = CollectionList[PropData.ID] or false
    else
        self.bSetFavor = false
    end
end

---刷新道具信息
---@param PropData table @道具数据
function CraftingLogVM:RefreshPropInfo(PropData)
    if (PropData == nil) then
        return
    end
    -- 高亮
    self:PropItemChoiceStateById(PropData.ID)

    -- 制作按钮四种状态，批量是否显示
    self:SetMakeBtnState(PropData)

    -- 具体详情（根据是否达到快速制作条件，显示HQ/NQ）
    self:PropItemChoiceRefiesh(PropData)

    -- 花费（会检验素材,精度制作条件(依赖制作按钮状态)）
    self:UpdateMaterialListTab(
        CraftingLogMgr:GetPropMaterialData(PropData.Material, PropData.IsRequireHQ or {}), PropData.CrystalType)

    -- 最大制作数量(依赖制作条件检验)
    self:RefieshMaxAmount(CraftingLogMgr.MaxMakeCount)

    -- 制作说明(依赖制作按钮状态)
    local ConditionData = CraftingLogMgr:GetItmeExplainData(PropData)
    if ConditionData ~= nil then
        self.ConditionItemAdapter:UpdateByValues(ConditionData, nil)
    end

    -- 按键处理
    CraftingLogMgr:ButtonState()
end

---道具被点击高亮
function CraftingLogVM:PropItemChoiceStateById(Id)
    local AllItemList = self:GetPropItemList()
    for _, value in pairs(AllItemList) do
        if value.ItemData then
            value.SelectShow = value.ItemData.ID == Id
        end
    end
end

---道具点击刷新 具体详情
function CraftingLogVM:PropItemChoiceRefiesh(Data)
    if Data == nil then
        return
    end
    self.bPanelInfoShow = true

    --基础信息
    local IsFast = self.MakeBtnState == CraftingLogDefine.MakeBtnState.Fast
    local ProductID = IsFast and Data.HQProductID or Data.ProductID
    self.InUseItemName = ItemCfg:GetItemName(ProductID)
    local Cfg = ItemCfg:FindCfgByKey(ProductID)
    if Cfg then
        if 1 == Cfg.IsHQ then
            self.ItemQualityImg = CommLight152Slot.ItemHQColorType[Cfg.ItemColor]
        else
            self.ItemQualityImg = CommLight152Slot.ItemColorType[Cfg.ItemColor]
        end
        self.TypeName = ItemTypeCfg:GetTypeName(Cfg.ItemType)
        self.IconID = Cfg.IconID
    end
    self.TextNum = Data.ProductNum > 1 and Data.ProductNum or ""
    self.bLeveQuestMarked = Data.bLeveQuestMarked

    --制作工具：主副手
    local MakeToolData = CraftingLogMgr:GetCraftToolData(Data.Craftjob, Data.MainSubTool)
    if MakeToolData then
        self.InUseItemDes = string.format("%s%s", LSTR(80063), MakeToolData.ToolName) --80063 制作工具
    else
        self.InUseItemDes = ""
    end
    if MakeToolData and MakeToolData.MainSubTool == 1 then
        CraftingLogMgr.CurrentToolName = self.InUseItemDes
    else
        -- 只需要主手裝備
        CraftingLogMgr.CurrentToolName = ""
    end

    --配方信息
    if Data.CanHQ == 0 then
        local SpecialCharacterCfg = require("TableCfg/SpecialCharacterCfg")
		local cfg = SpecialCharacterCfg:FindCfgByKey(10000)
        local Unicode = cfg and tonumber(cfg.Unicode) or ""
        local Text = utf8.char(Unicode)
        -- 80022 该配方不可制作优质   80058 道具
        self.InUseItemRecipeDetail = string.format('%s<span color="#313131" size="25">%s</>%s', LSTR(80022), Text, LSTR(80058))
    else
        if Data.IsCollection == 1 then
            local CollectInfo = CollectInfoCfg:FindCfgByKey(Data.ProductID)
            local MaxQuality = CollectInfo.CollectValue[3] or 0
            --80042 进展要求   80043 耐久   80059 最高品质需求   80060 品质上限
            self.InUseItemRecipeDetail =
            string.format("%s：%d \n%s：%d \n%s：%d", LSTR(80042), Data.ProgressMax, LSTR(80043), Data.Durability, LSTR(80059), MaxQuality) --进展要求
        else
            self.InUseItemRecipeDetail =
            string.format("%s：%d \n%s：%d \n%s：%d", LSTR(80042), Data.ProgressMax, LSTR(80043), Data.Durability, LSTR(80060), Data.QualityMax)
        end
    end

    --一键购买状态
    --local Level = MajorUtil.GetMajorLevelByProf(Data.Craftjob) or 0
    --self.bBuyShow = Data.RecipeLevel - Level < 10

    --制作条件文字
    if Data.CanHQ == 0 then
        self.TextCraftTips = LSTR(80075) --简易制作条件80075
    elseif Data.FastCraft == 1 then --（即使按钮为开始制作，但可以快速制作就显示快速制作条件）
        self.TextCraftTips = LSTR(80074) --快速制作条件80074
    else
        self.TextCraftTips = LSTR(80049) --制作条件80049
    end
end

--设置制作按钮的四种状态
function CraftingLogVM:SetMakeBtnState(Data)
    local MakeBtnState = CraftingLogDefine.MakeBtnState
    self.bTrainMakeShow = false
    self.bBatchMakeShow = false
    if CraftingLogMgr:GetProfIsLock(Data.Craftjob) then
        self.MakeBtnState = MakeBtnState.UnLockProf
        self.BtnCraftText = LSTR(80065)--"前往转职"
        if Data.CanHQ == 1 then
            self.bTrainMakeShow = true
        end
    elseif Data.CanHQ == 0 then
        self.MakeBtnState = MakeBtnState.Easy
        self.BtnCraftText = LSTR(80044) --简易制作
    else
        self.MakeBtnState = MakeBtnState.Normal
        self.BtnCraftText = LSTR(80045) --开始制作
        self.bTrainMakeShow = true

        --批量制作是否显示
        local IsDone = CraftingLogMgr:GetIsDone(Data)
        self.bBatchMakeShow = Data.BatchNum > 0 and IsDone

        --快速制作解锁条件判断
        if Data.FastCraft ~= nil and Data.FastCraft == 1 and IsDone then
            local AttrWorkPrecision = _G.UE.UActorUtil.GetActorAttrValue(MajorUtil.GetMajorEntityID(),
                ProtoCommon.attr_type.attr_work_precision)
            local AttrProducePrecision = _G.UE.UActorUtil.GetActorAttrValue(MajorUtil.GetMajorEntityID(),
                ProtoCommon.attr_type.attr_produce_precision)
            if AttrWorkPrecision >= Data.HQFastCraftmanShipNeed and AttrProducePrecision >= Data.HQFastCraftControlNeed then
                self.MakeBtnState = MakeBtnState.Fast
                self.BtnCraftText = LSTR(80072) --快速制作80072
                self.bTrainMakeShow = false
                self.bBatchMakeShow = false
            end
        end
    end
end

---刷新最大制作数量
---@param Count number @数量
function CraftingLogVM:RefieshMaxAmount(Count)
    local AmountState = CraftingLogDefine.AmountState
    CraftingLogMgr:SetMaxMakeCount(Count)
    CraftingLogMgr.NowMakeCount = 1

    -- self:OnAmountPromptChange(Count <= 0 and AmountState.Zero or AmountState.Maximum)
    self:OnAmountPromptChange(AmountState.Minimum)

    self:OnAmountChange(0)
end

---制作数量变化
---@param Count number @数量
function CraftingLogVM:OnAmountChange(Count)
    local MakeCount = Count
    if Count == 0 then
        MakeCount = CraftingLogDefine.NormalLowestMakeCount
    end
    self.CraftingTextAmount = MakeCount
    local NowPropData = CraftingLogMgr.NowPropData
    if not NowPropData or not NowPropData.Material then
        return
    end

    local Material = NowPropData.Material
    local MaterialList = self.MaterialItemAdapter:GetItems()
    for key, value in pairs(MaterialList) do
        if (Material[key].ItemID ~= 0) then
            value:UpdataTextNum(Count)
        end
    end

    local CrystalTypeData = NowPropData.CrystalType
    local CrystalList = self.CrystalItemAdapter:GetItems()
    for key, value in pairs(CrystalList) do
        if (CrystalTypeData[key].ItemID ~= 0) then
            value:UpdataTextNum(MakeCount)
        end
    end
end

---数量变化
---@field Type CraftingLogDefine.AmountState
function CraftingLogVM:OnAmountPromptChange(Type)
    self.bImgMaxNormalShow = true
    if Type == CraftingLogDefine.AmountState.Minimum then
        self.bImgSubtractShow = false
        self.bImgSubtractDisableShow = true
        if CraftingLogMgr:GetMaxMakeCount() <= 1 then
            self.bImgAddShow = false
            self.bImgAddDisableShow = true
            self.bImgMaxNormalShow = false
        else
            self.bImgAddShow = true
            self.bImgAddDisableShow = false
        end
    elseif Type == CraftingLogDefine.AmountState.Maximum then
        self.bImgSubtractShow = true
        self.bImgSubtractDisableShow = false
        self.bImgAddShow = false
        self.bImgAddDisableShow = true
        self.bImgMaxNormalShow = false
    elseif Type == CraftingLogDefine.AmountState.Zero then
        self.bImgSubtractShow = false
        self.bImgSubtractDisableShow = true
        self.bImgAddShow = false
        self.bImgAddDisableShow = true
        self.CraftingTextAmountColor = "FF0000FF"
        return
    else
        self.bImgSubtractShow = true
        self.bImgSubtractDisableShow = false
        self.bImgAddShow = true
        self.bImgAddDisableShow = false
    end
    self.CraftingTextAmountColor = "DAB371FF"

    -- 如果当前选择数量大于最大可制作数量
    if CraftingLogMgr.NowMakeCount > CraftingLogMgr.MaxMakeCount then
        self.CraftingTextAmountColor = "FF0000FF"
        self.bImgAddShow = false
        self.bImgAddDisableShow = true
        return
    end
end

---设置小标题
function CraftingLogVM:SetCareerTitle(SubTitleInfo)
    self.SubTitle = SubTitleInfo
end

---刷新搜索历史列表
function CraftingLogVM:UpdateSearchHistoryListTab(SearchHistoryData)
    if SearchHistoryData == nil or #SearchHistoryData <= 0 then
        self.bBtnDeleteShow = false
        return
    end
    self.TableViewHistoryAdapter:UpdateByValues(SearchHistoryData, nil)
    self.bBtnDeleteShow = true
end

---清空历史记录
function CraftingLogVM:ClearSearchHistory()
    CraftingLogMgr.SearchHistory = {}
    self.TableViewHistoryAdapter:Clear()
    self.bBtnDeleteShow = false
end

---制作历史初始化
function CraftingLogVM:HistoryInitChangeState()
    local AllItemList = self:GetPropItemList()
    for _, value in pairs(AllItemList) do
        value:SetImgDoneShow()
    end
end

---收藏初始化
function CraftingLogVM:CollectInitChangeState()
    local AllItemList = self:GetPropItemList()
    for _, value in pairs(AllItemList) do
        value:SetCollectShow()
    end

    local PropData = CraftingLogMgr.NowPropData
    if PropData then
        local CollectionList = CraftingLogMgr.CollectListData[PropData.Craftjob]
        if CollectionList then
            self.bSetFavor = CollectionList[PropData.ID] or false
        end
    end
end

function CraftingLogVM.ItemTypePredicate(Left, Right)
    return (Left.GatheringLabel or 0) < (Right.GatheringLabel or 0)
end

-------------------------------Panel-----------------------
---面板初始化
function CraftingLogVM:PanleInit()
    self.bBtnBackShow = false
    self.bBtnCloseShow = true
    self.bVerIconTabsShow = true
    self.bDropDownShow = true
    self.bPanelInfoShow = CraftingLogMgr.NowPropData ~= nil
    self.bPanelListEmptyShow = false
end

--没有任何配方
function CraftingLogVM:NoAnyFormula()
    self.bBtnBackShow = false
    self.bBtnCloseShow = true
    self.bVerIconTabsShow = true
    self.bPanelInfoShow = false
    self.bPanelListEmptyShow = true
    if CraftingLogMgr.CraftingState ~= CraftingLogDefine.CraftingLogState.Picking then
        return
    end
    self.bDropDownShow = false --搜索状态下下拉框 不隐藏
    if CraftingLogMgr.LastHorTabIndex and CraftingLogMgr.LastHorTabIndex == CraftingLogDefine.FilterALLType.Career  then
        self.TextListEmpty = LSTR(CraftingLogDefine.SpecialListEmpty)
    elseif CraftingLogMgr.LastHorTabIndex and CraftingLogMgr.LastHorTabIndex == CraftingLogDefine.FilterALLType.Collect then
        self.TextListEmpty = LSTR(CraftingLogDefine.CollectListEmpty)
    else
        self.TextListEmpty = LSTR(CraftingLogDefine.TextListEmpty)
    end
end
-------------------------

---制作
function CraftingLogVM:MakeProps(bIsTrain)
    bIsTrain = bIsTrain or false
    local NowPropData = CraftingLogMgr.NowPropData
    if nil == NowPropData then
        return
    end
    local State = CraftingLogDefine.MakeBtnState
    if not bIsTrain and self.MakeBtnState == State.UnLockProf then
        self:GoToSwichProf(NowPropData.Craftjob)
        return
	end

    if self.MakeBtnState == State.Easy or self.MakeBtnState == State.Fast then
        -- 简易制作没有对应的训练制作
        if bIsTrain then
            return
        end
        --当Z.制作配方表的CanHQ列填0时，使用简易制作来完全替代开始制作
        self:EaseMakeProps()
        CraftingLogMgr.MakeState = CraftingLogDefine.MakeRecipeState.Easy
        return
    end
    CraftingLogMgr:SendStartMakeReq(bIsTrain)
    CraftingLogMgr.MakeState = CraftingLogDefine.MakeRecipeState.Normal

    --制作笔记制作点击流水
    self:SendDataReportor(bIsTrain, NowPropData)
end

---简易制作
function CraftingLogVM:EaseMakeProps() 
    local NowPropData = CraftingLogMgr.NowPropData
    if nil == NowPropData then
        return
    end

    if CraftingLogMgr:CheckMakeState() and CraftingLogMgr:CheckBagCapacity() and CraftingLogMgr:CheckSlaveHand() and
        _G.CrafterMgr:PreCheck(_G.CraftingLogMgr:GetNowRecipeID())
    then
        _G.UIViewMgr:ShowView(_G.UIViewID.CraftingLogSetCraftTimesWinView)
    end
end

--前往转职
function CraftingLogVM:GoToSwichProf(Prof)
    if _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDJobQuest) then
        _G.AdventureCareerMgr:JumpToTargetProf(Prof)
        return
    end
    local StartQuestCfg = _G.AdventureCareerMgr:GetCurProfChangeProfData(Prof)
	if not StartQuestCfg or not next(StartQuestCfg) then
        FLOG_ERROR("CraftingLogVM:GoToSwichProf StartQuestCfg is nil")
        return 
    end
    local MapID = StartQuestCfg.AcceptMapID
    --如果是沙都乌尔达哈，打开地图
    if MapID == 12001 or MapID == 12002 then
        _G.WorldMapMgr:ShowWorldMapQuest(MapID, StartQuestCfg.AcceptUIMapID, StartQuestCfg.StartQuestID)
        if self.MapAnimationTimer and self.MapAnimationTimer ~= 0 then
            _G.TimerMgr:CancelTimer(self.MapAnimationTimer)
        end
        local WorldMapPanel = _G.UIViewMgr:FindView(_G.UIViewID.WorldMapPanel)
        local MarkerView = WorldMapPanel.MapContent:GetMapMarkerByID(StartQuestCfg.StartQuestID)
        self.MapAnimationTimer = CraftingLogMgr:RegisterTimer(function()
            if MarkerView then
                MarkerView:playAnimation(MarkerView.AnimNew)
            end
        end, 0, 2.97, 3)
    else
        MsgTipsUtil.ShowTips(LSTR(80068))--"冒险笔记尚未解锁，完成10级主线任务后可查看"
    end
end

function CraftingLogVM:GetSwichProfState(Prof)
    if not _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDJobQuest) then
        local StartQuestCfg = _G.AdventureCareerMgr:GetCurProfChangeProfData(Prof)
        if StartQuestCfg and StartQuestCfg.AcceptMapID and StartQuestCfg.AcceptMapID ~= 12001 and StartQuestCfg.AcceptMapID ~= 12002 then
            return false
        end
    end
    return true
end

function CraftingLogVM:SendDataReportor(bIsTrain, NowPropData)
    local OpType = bIsTrain and 2 or 1 --1-制作物品（不含练习制作）、2-练习制作
    local ProductionID = NowPropData.ProductID --制作物的物品ID
    local ProductionTab = CraftingLogMgr.LastHorTabIndex --制作物品时所处的页签
    local CollectingType = NowPropData.Craftjob --制作物品对应的职业ID
    DataReportUtil.ReportSystemFlowData("ProductionnotesClickFlow", OpType, ProductionID, ProductionTab, CollectingType)
end
return CraftingLogVM
