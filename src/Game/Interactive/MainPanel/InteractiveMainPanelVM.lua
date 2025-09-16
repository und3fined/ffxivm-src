
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local EntranceItemFactory = require("Game/Interactive/EntranceItemFactory")
local CommonUtil = require("Utils/CommonUtil")

---@class InteractiveMainPanelVM : UIViewModel
local InteractiveMainPanelVM = LuaClass(UIViewModel)

function InteractiveMainPanelVM:Ctor()
    self.EntranceItemList = {}
    self.FunctionItemList = {}
    self.SingleEntranceItem = nil

    self.MainPanelVisible = true
    self.EntranceVisible = false
    self.FunctionVisible = false
    self.FixedFunctionVisible = false
    self.PanelTargetSwitchVisible = false
    self.PanelPlayerSwitchVisible = false

    self.FuctionTableViewTop = 0
    self.EntranceTableViewTop = 0

    self.FixedFunctionItemList = {}
    --self.WorldViewObjEntranceItem = nil

    self.bNeedShowBranchLineEntrance = nil

    self.InteractiveTargetIndex = 1

    self.TargetName = ""
    self.PlayerName = ""

    self.NewEntranceItemList = {}
end

function InteractiveMainPanelVM:OnInit()
    --这2个绑定的数据，不检查是否有变化，必然OnValueChange
    -- local BindProperty = self:FindBindableProperty("EntranceItemList")
    -- if BindProperty then
    --     BindProperty:SetNoCheckValueChange(true)
    -- end

    local BindProperty = self:FindBindableProperty("FunctionItemList")
    if BindProperty then
        BindProperty:SetNoCheckValueChange(true)
    end

    BindProperty = self:FindBindableProperty("FixedFunctionItemList")
    if BindProperty then
        BindProperty:SetNoCheckValueChange(true)
    end

    BindProperty = self:FindBindableProperty("EntranceVisible")
    if BindProperty then
        BindProperty:SetNoCheckValueChange(true)
    end

    BindProperty = self:FindBindableProperty("FunctionVisible")
    if BindProperty then
        BindProperty:SetNoCheckValueChange(true)
    end

    BindProperty = self:FindBindableProperty("FixedFunctionVisible")
    if BindProperty then
        BindProperty:SetNoCheckValueChange(true)
    end

    BindProperty = self:FindBindableProperty("MainPanelVisible")
    if BindProperty then
        BindProperty:SetNoCheckValueChange(true)
    end

	self:SetNoCheckValueChange("FuctionTableViewTop", true)
end

function InteractiveMainPanelVM:OnBegin()
end

function InteractiveMainPanelVM:OnEnd()
    self.EntranceItemList = {}
    self.FunctionItemList = {}
end

function InteractiveMainPanelVM:OnShutdown()
end

function InteractiveMainPanelVM:SetEntranceItems(EntranceList, SingleEntranceItem)
    --_G.FLOG_INFO("InteractiveMainPanelVM:SetEntranceItems, EntranceVisible=%s",tostring(self.EntranceVisible))
    local EntranceItemNum = 0
    if nil ~= SingleEntranceItem then -- 临时处理，之后要把整个SingleEntrance相关都移除，改为放到正常function里
        if nil ~= EntranceList then
            EntranceList = table.deepcopy(EntranceList)
            table.insert(EntranceList, 1, SingleEntranceItem)
        else
            EntranceList = { SingleEntranceItem }
        end
    end
    if nil ~= EntranceList then
        EntranceItemNum = #EntranceList
    end
    if self.EntranceVisible then
        -- self.SingleEntranceItem = SingleEntranceItem
        -- local NewEntranceItemList = {}
        -- if #EntranceList > 0 then
        --     table.insert(NewEntranceItemList, EntranceList[1])
        -- end

        -- self.EntranceItemList = NewEntranceItemList

        if self.InteractiveTargetIndex > EntranceItemNum then
            self.InteractiveTargetIndex = 1
        end
        --_G.FLOG_INFO("InteractiveMainPanelVM:SetEntranceItems, InteractiveTargetIndex=%d",self.InteractiveTargetIndex)
        do
            local _ <close> = CommonUtil.MakeProfileTag("InteractiveMainPanelVM.SetEntranceItems.GenNewEntranceItems")
            self.EntranceItemList = self:GenNewEntranceItems(EntranceList)
        end

        local EntityID = 0
        if #self.EntranceItemList > 0 then
            EntityID = self.EntranceItemList[1].EntityID
        elseif nil ~= self.SingleEntranceItem then
            EntityID = self.SingleEntranceItem.EntityID
        end
        InteractiveMgr:TriggerObjInteraction(EntityID)
    end
    --self:SetEntranceTableViewTop(self.EntranceItemList)
    self:SetTargetSwitchVisible(self.EntranceVisible and EntranceItemNum > 1)
end

function InteractiveMainPanelVM:GenNewEntranceItems(EntranceList)
    local NewEntranceItems = {}
    if #EntranceList > 0 then
        local bNeedFirstEntrance = true
        local Entrance = EntranceList[self.InteractiveTargetIndex]
        self.TargetName = Entrance.TargetName
        local TargetType = Entrance.TargetType
        if (TargetType == _G.LuaEntranceType.NPC and
            (nil == Entrance.NpcID or not _G.NpcMgr:IsChocoboNpcByNpcID(Entrance.NpcID)))
            or TargetType == _G.LuaEntranceType.EOBJ then
            if TargetType == _G.LuaEntranceType.NPC and Entrance:IsNeedShowArmyExchangeEntrance() then
                --显示"调换军队"一级交互项
                local Params = { IntParam1 = _G.LuaEntranceType.ArmyNpc, ULongParam1 = Entrance.EntityID, ULongParam2 = Entrance.ResID }
                local IUnit = EntranceItemFactory:CreateEntrance(Params)
                if IUnit then
                    table.insert(NewEntranceItems, IUnit)
                end
                bNeedFirstEntrance = false
            else
                local EntranceItems
                do
                    local _ <close> = CommonUtil.MakeProfileTag("InteractiveMainPanelVM.GenNewEntranceItems")
                    EntranceItems = Entrance:GenInteractiveQuestEntranceItems(Entrance)
                end
                if #EntranceItems > 0 then
                    --有可交互的任务
                    for i = 1, #EntranceItems do
                        local bReuse = false
                        for Index = 1, #self.NewEntranceItemList do
                            local EntranceItem = self.NewEntranceItemList[Index]
                            if EntranceItem.TargetType == _G.LuaEntranceType.NPCQUEST and
                                EntranceItems[i].DisplayName == EntranceItem.DisplayName and
                                (nil ~= EntranceItems[i].QuestID and nil ~= EntranceItem.QuestID and EntranceItems[i].QuestID == EntranceItem.QuestID) and
                                EntranceItem.EntityID == Entrance.EntityID then
                                table.remove(self.NewEntranceItemList, Index)
                                table.insert(NewEntranceItems, EntranceItem)
                                bReuse = true
                                break
                            end
                        end

                        if not bReuse then
                            local Params = { IntParam1 = _G.LuaEntranceType.NPCQUEST,
                                            ULongParam1 = Entrance.EntityID,
                                            ULongParam2 = Entrance.ResID,
                                            ULongParam3 = Entrance.ListID }
                            local IUnit = EntranceItemFactory:CreateEntrance(Params, EntranceItems[i])
                            if IUnit then
                                --table.insert(NewEntranceItems, EntranceItems[i])
                                --_G.FLOG_INFO("InteractiveMainPanelVM:GenNewEntranceItems, EntityID=%d, DisplayName=%s",Entrance.EntityID, IUnit.DisplayName) 
                                table.insert(NewEntranceItems, IUnit)
                            end
                        end
                    end
                    if not Entrance:HasFunctionItems() then
                        bNeedFirstEntrance = false
                    end
                end
            end
        -- elseif TargetType == _G.LuaEntranceType.EOBJ then
        --     local EntranceItems = Entrance:GenInteractiveQuestEntranceItems(Entrance)
        --     if #EntranceItems > 0 then
        --         --有可交互的任务
        --         for i = 1, #EntranceItems do
        --             table.insert(NewEntranceItems, EntranceItems[i])
        --         end
        --         if not Entrance:HasFunctionItems() then
        --             bNeedFirstEntrance = false
        --         end
        --     end
        -- elseif TargetType == _G.LuaEntranceType.CRYSTAL then
        --     if nil == self.bNeedShowBranchLineEntrance then
        --         --bNeedFirstEntrance = false
        --     elseif self.bNeedShowBranchLineEntrance == true then
        --         --插入【切换副本区】交互选项
        --         local bReuse = false
        --         for Index = 1, #self.NewEntranceItemList do
        --             local EntranceItem = self.NewEntranceItemList[Index]
        --             if EntranceItem.TargetType == _G.LuaEntranceType.PWorldBranch and
        --                 EntranceItem.EntityID == Entrance.EntityID then
        --                 table.remove(self.NewEntranceItemList, Index)
        --                 table.insert(NewEntranceItems, EntranceItem)
        --                 bReuse = true
        --                 break
        --             end
        --         end

        --         if not bReuse then
        --             local Params = {}
        --             Params.IntParam1 =  _G.LuaEntranceType.PWorldBranch
        --             Params.ULongParam1 = Entrance.EntityID
        --             Params.ULongParam2 = Entrance.ResID
        --             local IUnit = EntranceItemFactory:CreateEntrance(Params)
        --             if IUnit then
        --                 table.insert(NewEntranceItems, IUnit)
        --             end
        --         end
        --     end
        end

        if bNeedFirstEntrance then
            table.insert(NewEntranceItems, Entrance)
        end
        --[[ _G.FLOG_INFO("InteractiveMainPanelVM:GenNewEntranceItems, ActorType=%d, EntityID=%d, ResID=%d, Items=%d",
            TargetType, Entrance.EntityID, Entrance.ResID, #NewEntranceItems) ]]
    end

    self.NewEntranceItemList = NewEntranceItems

    return NewEntranceItems
end

-- function InteractiveMainPanelVM:SetWorldViewObjEntranceItem(EntraceItem)
--     self.WorldViewObjEntranceItem = EntraceItem
-- end

function InteractiveMainPanelVM:SetEntranceTableViewTop(EntranceItems)
    local TopSizeY = 0
    local EntranceItemNum = #EntranceItems
    if EntranceItemNum > 0 then
        local EntranceItemSizeY = EntranceItems[1]:GetEntranceItemSizeY() / 2
        if EntranceItemNum < 3 then
            local Index = 3 - EntranceItemNum
            while Index > 0 do
                Index = Index - 1
                TopSizeY = TopSizeY - EntranceItemSizeY
            end
        end
    end

    self.EntranceTableViewTop = TopSizeY
end

function InteractiveMainPanelVM:SetFunctionItems(FunctionList)
    self.FunctionItemList = FunctionList
    self:SetFuctionTableViewTop(FunctionList)
    self:SetFunctionVisible(true)
end

function InteractiveMainPanelVM:SetFuctionTableViewTop(FunctionItems)
    local TopSizeY = 0
    local FunctionItemNum = #FunctionItems
    if FunctionItemNum > 0 then
        local FunctionItemSizeY = FunctionItems[1]:GetFunctionItemSizeY() / 2
        if FunctionItemNum < 3 then
            local Index = 3 - FunctionItemNum
            while Index > 0 do
                Index = Index - 1
                TopSizeY = TopSizeY - FunctionItemSizeY
            end
        end
    end

    self.FuctionTableViewTop = TopSizeY
end

function InteractiveMainPanelVM:SetFixedFunctionItems(ItemList)
    local FunctionList = {}
    if self.FixedFunctionVisible then
        local ItemListLength = #ItemList
        if ItemListLength > 0 then
            for i = 1, ItemListLength do
                table.insert(FunctionList, ItemList[i])
            end
        end
    end

    self.FixedFunctionItemList = FunctionList
end

function InteractiveMainPanelVM:MakeMainPanelVisible(bShow)
    --_G.FLOG_INFO("InteractiveMainPanelVM:MakeMainPanelVisible, bShow=%s", tostring(bShow))
    self.MainPanelVisible = bShow
end

--show/hide一级交互入口
function InteractiveMainPanelVM:SetEntrancesVisible(bShow)
    --_G.FLOG_INFO("InteractiveMainPanelVM:SetEntrancesVisible, bShow=%s", tostring(bShow))

    if self.FixedFunctionVisible == true then
        self.EntranceVisible = false
        self.FunctionVisible = false
        return
    end

    self.EntranceVisible = bShow

    --有互斥逻辑
    if bShow then
        self.FunctionVisible = false
        InteractiveMgr:SetFunctionListShowState(false)
        --InteractiveMgr:ResetWorldViewObjEntranceItem()
    end

    if self.EntranceVisible == false then
        self:SetTargetSwitchVisible(false)
    end

    InteractiveMgr:OnEntranceVisible(bShow)
end

function InteractiveMainPanelVM:GetEntrancesVisible()
    return self.EntranceVisible
end

--show/hide二级交互功能项
function InteractiveMainPanelVM:SetFunctionVisible(bShow)
    --_G.FLOG_INFO("InteractiveMainPanelVM:SetFunctionVisible, bShow=%s", tostring(bShow))
    if not _G.GoldSaucerMiniGameMgr:CheckIsInMiniGame() then
        InteractiveMgr:ShowOrHideMainPanel(not bShow)
    end

    if self.FixedFunctionVisible == true then
        self.EntranceVisible = false
        self.FunctionVisible = false
        return
    end

    self.FunctionVisible = bShow

    --有互斥逻辑
    if bShow then
        self.EntranceVisible = false
        self:SetTargetSwitchVisible(false)
        --InteractiveMgr:ResetWorldViewObjEntranceItem()
    end
    InteractiveMgr:SetFunctionListShowState(bShow)
end

--show/hide点选固定交互功能项
function InteractiveMainPanelVM:SetFixedFunctionVisible(bShow)
    --_G.FLOG_INFO("InteractiveMainPanelVM:SetFixedFunctionVisible, bShow=%s", tostring(bShow))
    self.FixedFunctionVisible = bShow

    --有互斥逻辑
    if bShow then
        self.EntranceVisible = false
        self.FunctionVisible = false
        self:SetTargetSwitchVisible(false)
        --InteractiveMgr:ResetWorldViewObjEntranceItem()
    end
end

function InteractiveMainPanelVM:GetFunctionVisible()
    return self.FunctionVisible
end

function InteractiveMainPanelVM:GetFixedFunctionVisible()
    return self.FixedFunctionVisible
end

function InteractiveMainPanelVM:SetEnableShowBranchLineEntrance(bFlag)
    self.bNeedShowBranchLineEntrance = bFlag
end

function InteractiveMainPanelVM:SetInteractiveTargetIndex(Index)
    self.InteractiveTargetIndex = Index
end

function InteractiveMainPanelVM:SetTargetSwitchVisible(bFlag)
    --_G.FLOG_INFO("InteractiveMainPanelVM:SetTargetSwitchVisible, bFlag=%s", tostring(bFlag))
    self.PanelTargetSwitchVisible = bFlag
end

function InteractiveMainPanelVM:SetPlayerSwitchVisible(bFlag)
    self.PanelPlayerSwitchVisible = bFlag
end

function InteractiveMainPanelVM:SetPlayerName(PlayerName)
    self.PlayerName = PlayerName
end

-- function InteractiveMainPanelVM:UnRegisterBinder(PropertyName, Binder)
--  _G.FLOG_ERROR("InteractiveMainPanelVM:UnRegisterBinder, %s", debug.traceback())
-- 	_G.FLOG_INFO("InteractiveMainPanelVM:UnRegisterBinder, PropertyName:%s,Binder:%s",PropertyName,Binder)
-- 	local BindableProperty = self:FindBindableProperty(PropertyName)
-- 	if nil == BindableProperty then
-- 		return
-- 	end

-- 	BindableProperty:UnRegisterBinder(Binder)
-- end

return InteractiveMainPanelVM