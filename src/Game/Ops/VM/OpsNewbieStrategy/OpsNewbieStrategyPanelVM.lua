local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local OpsNewbieStrategyTabItemVM = require("Game/Ops/VM/OpsNewbieStrategy/ItemVM/OpsNewbieStrategyTabItemVM")
local OpsNewbieStrategyDefine = require("Game/Ops/OpsNewbieStrategy/OpsNewbieStrategyDefine")
local OpsNewbieStrategyFirstChoicePanelVM = require("Game/Ops/VM/OpsNewbieStrategy/OpsNewbieStrategyFirstChoicePanelVM")
local OpsNewbieStrategyRecommendPanelVM = require("Game/Ops/VM/OpsNewbieStrategy/OpsNewbieStrategyRecommendPanelVM")
local OpsNewbieStrategyAdvancedPanelVM = require("Game/Ops/VM/OpsNewbieStrategy/OpsNewbieStrategyAdvancedPanelVM")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")
local ProtoRes = require("Protocol/ProtoRes")
---@class OpsNewbieStrategyPanelVM : UIViewModel
local OpsNewbieStrategyPanelVM = LuaClass(UIViewModel)

function OpsNewbieStrategyPanelVM:Ctor()
    ---页签列表
    self.MenuList = nil
    self.CurSelectedMenuItem = nil
    ---子界面显隐控制
    self.bFirstChoicePanel = nil
    self.bRecommendPanel = nil
    self.bAdvancedPanel = nil

    self.Name = nil
    self.Info = nil
    ---勇气嘉奖进度
    self.BraveryAwardProBar = nil
    self.BraveryAwardNumText = nil
    self.IsHaveGiveBraveryReward = nil
    self.IsBraveryRewardFinished = nil
end

function OpsNewbieStrategyPanelVM:OnInit()
    self.MenuList = UIBindableList.New( OpsNewbieStrategyTabItemVM )
    --self.MenuList:UpdateByValues(OpsNewbieStrategyDefine.OpsNewbieStrategyTabs)
    ---默认第一个页签/首选，打开界面时需要判断默认开哪个界面
    --self.CurSelectedMenuItem = self.MenuList:Get(1)
    --self.CurSelectedPanelKey = self.CurSelectedMenuItem.Key
    ---界面显示 --todo后续可改动态挂载
    self.bFirstChoicePanel = false
    self.bRecommendPanel = false
    self.bAdvancedPanel = false

    ---子界面VM
    --首选
    self.FirstChoicePanelVM = OpsNewbieStrategyFirstChoicePanelVM.New()
    self.FirstChoicePanelVM:Init()
    --推荐
    self.RecommendPanelVM = OpsNewbieStrategyRecommendPanelVM.New()
    self.RecommendPanelVM:Init()

    --推荐
    self.AdvancedPanelVM = OpsNewbieStrategyAdvancedPanelVM.New()
    self.AdvancedPanelVM:Init()

    ---勇气嘉奖
    self.BraveryAwardProBar = 0
end

function OpsNewbieStrategyPanelVM:GetMenuItems()
    local MenuItems = {}
    for _, TabData in ipairs(OpsNewbieStrategyDefine.OpsNewbieStrategyTabs) do
        local MenuItemData = {
            Index = TabData.Index,
            Key = TabData.Key,
            --Name = TabData.Name,
        }
        if TabData.NameUKey then
            ---页签文本
            MenuItemData.Name = LSTR(TabData.NameUKey)
        end
        local ActivityID
        --local IsUnLock
        if MenuItemData.Key == OpsNewbieStrategyDefine.PanelKey.FirstChoicePanel then
            ActivityID = OpsNewbieStrategyDefine.ActivityID.FirstChoiceActivityID
            MenuItemData.IsUnLock = true
        elseif MenuItemData.Key == OpsNewbieStrategyDefine.PanelKey.RecommendPanel then
            ActivityID = OpsNewbieStrategyDefine.ActivityID.RecommendActivityID
            MenuItemData.IsUnLock = true
        elseif MenuItemData.Key == OpsNewbieStrategyDefine.PanelKey.AdvancedPanel then
            ActivityID = OpsNewbieStrategyDefine.ActivityID.AdvancedActivityID
            MenuItemData.IsUnLock = false
        end
        --local RedDotName = _G.OpsNewbieStrategyMgr:GetRedDotNameByActivityID(ActivityID)
        local RedDotName = _G.OpsActivityMgr:GetRedDotName(OpsNewbieStrategyDefine.OpsNewbieStrategyMenuIndex, ActivityID)
        MenuItemData.RedDotName = RedDotName
        --local FirstRedDotName = RedDotName.."/".."FirstOpen"
        --local IsSaveDelRedDot = _G.RedDotMgr:GetIsSaveDelRedDotByName(FirstRedDotName)
        local Name = "First"
        if _G.OpsActivityMgr.OpsActivityRedDotFun[ProtoRes.RED_POINT_TYPE.FIRST_PROMPT] then
            Name = _G.OpsActivityMgr.OpsActivityRedDotFun[ProtoRes.RED_POINT_TYPE.FIRST_PROMPT].Name
        end
        local FirstRedDotName = _G.OpsActivityMgr:GetRedDotName(OpsNewbieStrategyDefine.OpsNewbieStrategyMenuIndex, ActivityID, Name)
        local IsFirstRedDot = _G.RedDotMgr:FindRedDotNodeByName(FirstRedDotName)
        if IsFirstRedDot then
            MenuItemData.RedDotStyle = RedDotDefine.RedDotStyle.SecondStyle
        else
            MenuItemData.RedDotStyle = RedDotDefine.RedDotStyle.NormalStyle
        end
        table.insert(MenuItems, MenuItemData)
    end
    return MenuItems
end

function OpsNewbieStrategyPanelVM:MenuUpdata()
    ---页签数据
    local MenuItems = self:GetMenuItems()
    self.MenuList:UpdateByValues(MenuItems)
end


--- 数据更新处理,只更新当前显示的，减少开销
function OpsNewbieStrategyPanelVM:UpdateOpsNewbieStrategyInfo(Data)
    --self.MenuList:UpdateByValues(OpsNewbieStrategyDefine.OpsNewbieStrategyTabs)
    if Data then
        ---更新主界面数据
        self.Name = Data.Name
        self.Info = Data
        ---更新子界面数据,只更新当前显示的界面
        local ActivityID
        if self.bFirstChoicePanel then
            ActivityID = OpsNewbieStrategyDefine.ActivityID.FirstChoiceActivityID
        elseif self.bRecommendPanel then
            ActivityID = OpsNewbieStrategyDefine.ActivityID.RecommendActivityID
        elseif self.bAdvancedPanel then
            self:UpdateAdvancedPanelData(Data)
        end

        if ActivityID then
            self:UpdateOpsNewbieStrategySubPanelVMByActivityID(Data, ActivityID)
        end
        ---更新勇气嘉奖数据BraveryAwardActivityID
        self:UpdateBraveryAwardData(Data)
        ---更新解锁数据
        if not self.bAdvancedPanel then
            ---如果当前显示不是进阶界面，单独更新一下进阶解锁状态
            local IsUnLock
            local ActivityList = Data.BindableActivityList:GetItems()
            for _, ActivityData in ipairs(ActivityList) do
                if  ActivityData:GetKey() == OpsNewbieStrategyDefine.ActivityID.AdvancedActivityID then
                    IsUnLock = ActivityData.Effected
                end
            end
            if IsUnLock ~= nil then
                self.AdvancedPanelVM:SetIsUnlock(IsUnLock)
            end
        end
        self:SetAdvancedIsUnLock()
    end
end

--- 打开界面数据更新处理，子VM全量更新
function OpsNewbieStrategyPanelVM:UpdateOpsNewbieStrategyInfoByOpen(Data)
    if Data then
        ---更新主界面数据
        self.Name = Data.Name
        self.Info = Data
        self:UpdateOpsNewbieStrategySubPanelVMByActivityID(Data, OpsNewbieStrategyDefine.ActivityID.FirstChoiceActivityID)
        self:UpdateOpsNewbieStrategySubPanelVMByActivityID(Data, OpsNewbieStrategyDefine.ActivityID.RecommendActivityID)
        self:UpdateAdvancedPanelData(Data)
        ---更新勇气嘉奖数据
        self:UpdateBraveryAwardData(Data)
        ---更新解锁数据
        self:SetAdvancedIsUnLock()
    end
end

--更新非进阶子界面数据
function OpsNewbieStrategyPanelVM:UpdateOpsNewbieStrategySubPanelVMByActivityID(Data, ActivityID)
    local ActivityList = Data.BindableActivityList:GetItems()
    local ActivityData = table.find_by_predicate(ActivityList, function(A)
        return A:GetKey() == ActivityID
    end)
    if ActivityData then
        if ActivityID == OpsNewbieStrategyDefine.ActivityID.FirstChoiceActivityID then
            self.FirstChoicePanelVM:UpdateOpsNewbieStrategyInfo(ActivityData)
            ---更新标题文本
            if self.bFirstChoicePanel then
                self.Name = ActivityData.Activity.Info
            end
        elseif ActivityID == OpsNewbieStrategyDefine.ActivityID.RecommendActivityID then
            self.RecommendPanelVM:UpdateOpsNewbieStrategyInfo(ActivityData)
            ---更新标题文本
            if self.bRecommendPanel then
                self.Name = ActivityData.Activity.Info
            end
        end 
    end
end

 ---进阶有多个子活动，特殊处理，非总活动ID(首选，推荐，进阶，勇气，新人攻略)，全部视为进阶活动
function OpsNewbieStrategyPanelVM:UpdateAdvancedPanelData(Data)
    local ActivityList = Data.BindableActivityList:GetItems()
    local AdvancedPanelData = {}
    for _, ActivityData in ipairs(ActivityList) do
        if  ActivityData:GetKey() == OpsNewbieStrategyDefine.ActivityID.AdvancedActivityID then
            AdvancedPanelData.ActivityData = ActivityData
        elseif ActivityData:GetKey() ~= OpsNewbieStrategyDefine.ActivityID.FirstChoiceActivityID and 
        ActivityData:GetKey() ~= OpsNewbieStrategyDefine.ActivityID.RecommendActivityID and 
        ActivityData:GetKey() ~= OpsNewbieStrategyDefine.ActivityID.OpsNewbieStrategyActivityID and
        ActivityData:GetKey() ~= OpsNewbieStrategyDefine.ActivityID.BraveryAwardActivityID then
            if AdvancedPanelData.SubActivityList == nil then
                AdvancedPanelData.SubActivityList = {}
            end
            table.insert(AdvancedPanelData.SubActivityList, ActivityData)
        end
    end
    if AdvancedPanelData and AdvancedPanelData.SubActivityList then
        self.AdvancedPanelVM:UpdateOpsNewbieStrategyInfo(AdvancedPanelData)
    end
    ---更新标题文本
    if self.bAdvancedPanel and AdvancedPanelData and AdvancedPanelData.ActivityData then
        self.Name = AdvancedPanelData.ActivityData.Activity.Info
    end
end

---Data = {
--- Activity = {ActivityID, EmergencyShutDown, Title, Info, PageName, ClassifyID, PutBottom, Priority, BPName}, 
--- Detail = {NodeList}
---}
--更新单独活动数据
function OpsNewbieStrategyPanelVM:UpdateOpsNewbieStrategySubActivityData(Data)
    local ActivityID = Data.Activity.ActivityID
    if ActivityID ==  OpsNewbieStrategyDefine.ActivityID.FirstChoiceActivityID then
        ---首选界面更新
        self.FirstChoicePanelVM:UpdateOpsNewbieStrategyInfoByActivityData(Data)
    elseif ActivityID ==  OpsNewbieStrategyDefine.ActivityID.RecommendActivityID then
        ---进阶界面更新
        self.RecommendPanelVM:UpdateOpsNewbieStrategyInfoByActivityData(Data)
    elseif ActivityID ==  OpsNewbieStrategyDefine.ActivityID.BraveryAwardActivityID then
        ---勇气嘉奖数据更新 
        self:UpdateBraveryAwardDataByNodeList(Data.Detail.NodeList)
    else
        ---进阶界面更新
        self.AdvancedPanelVM:UpdateOpsNewbieStrategySubActivity(Data)
    end
end

function OpsNewbieStrategyPanelVM:OnReset()
    self.FirstChoicePanelVM:OnReset()
    self.RecommendPanelVM:OnReset()
    self.AdvancedPanelVM:OnReset()
end

function OpsNewbieStrategyPanelVM:OnBegin()
    self.FirstChoicePanelVM:OnBegin()
    self.RecommendPanelVM:OnBegin()
    self.AdvancedPanelVM:OnBegin()
end

function OpsNewbieStrategyPanelVM:OnEnd()
    self.FirstChoicePanelVM:OnEnd()
    self.RecommendPanelVM:OnEnd()
    self.AdvancedPanelVM:OnEnd()
end

function OpsNewbieStrategyPanelVM:OnShutdown()
    self.FirstChoicePanelVM:OnShutdown()
    self.RecommendPanelVM:OnShutdown()
    self.AdvancedPanelVM:OnShutdown()
end

--- 设置页签选中
function OpsNewbieStrategyPanelVM:SetSelectedMenuItem(Key)
    if self.CurSelectedMenuItem then
        self.CurSelectedMenuItem:SetSelected(false)
    end
    self.CurSelectedMenuItem = self:FindMenuItem(Key)
    self.CurSelectedMenuItem:SetSelected(true)
    ---界面切换处理
    self.bFirstChoicePanel = Key == OpsNewbieStrategyDefine.PanelKey.FirstChoicePanel
    self.bRecommendPanel = Key == OpsNewbieStrategyDefine.PanelKey.RecommendPanel
    self.bAdvancedPanel = Key == OpsNewbieStrategyDefine.PanelKey.AdvancedPanel
    if self.Info then
        self:UpdateOpsNewbieStrategyInfo(self.Info)
    end
    ---首次红点消除
    local IsUnLock
    local ActivityID = self.CurSelectedMenuItem
    if self.CurSelectedMenuItem.Key == OpsNewbieStrategyDefine.PanelKey.FirstChoicePanel then
        ActivityID = OpsNewbieStrategyDefine.ActivityID.FirstChoiceActivityID
    elseif self.CurSelectedMenuItem.Key == OpsNewbieStrategyDefine.PanelKey.RecommendPanel then
        ActivityID = OpsNewbieStrategyDefine.ActivityID.RecommendActivityID
    elseif self.CurSelectedMenuItem.Key == OpsNewbieStrategyDefine.PanelKey.AdvancedPanel then
        ActivityID = OpsNewbieStrategyDefine.ActivityID.AdvancedActivityID
         ---进阶解锁特殊处理
        IsUnLock = self:GetAdvancedIsUnlock()
    end
    if ActivityID == OpsNewbieStrategyDefine.ActivityID.AdvancedActivityID and IsUnLock then
        ---进阶解锁特殊处理
        local Name = "First"
        local FirstRedDotName = _G.OpsActivityMgr:GetRedDotName(OpsNewbieStrategyDefine.OpsNewbieStrategyMenuIndex, OpsNewbieStrategyDefine.ActivityID.AdvancedActivityID, Name)
        _G.FLOG_INFO(string.format("%s %s","OpsNewbieStrategyPanelVM:SetSelectedMenuItem DelRedDotByName Name:", FirstRedDotName))
       _G.RedDotMgr:DelRedDotByName(FirstRedDotName)
    else
        ---排查真机包红点不消失问题
        local Name = "First"
        local FirstRedDotName = _G.OpsActivityMgr:GetRedDotName(OpsNewbieStrategyDefine.OpsNewbieStrategyMenuIndex, OpsNewbieStrategyDefine.ActivityID.AdvancedActivityID, Name)
        _G.FLOG_INFO(string.format("%s %s","OpsNewbieStrategyPanelVM:SetSelectedMenuItem -》_G.OpsActivityMgr:RecordRedDotClicked Name:", FirstRedDotName))
        _G.OpsActivityMgr:RecordRedDotClicked(ActivityID, _G.TimeUtil.GetServerTime())
        self.CurSelectedMenuItem:SetRedDotStyle(RedDotDefine.RedDotStyle.NormalStyle)
    end
end

--- 根据Key获取页签Item
function OpsNewbieStrategyPanelVM:FindMenuItem(Key)
    local Items = self.MenuList:GetItems()
    local Item = table.find_by_predicate(Items, function(A)
        return A.Key == Key
    end)
    if Item then
        return Item
    end
end

--------------------------------------------- 获取子界面VM start ----------------------------------------------------
function OpsNewbieStrategyPanelVM:GetFirstChoicePanelVM()
    return self.FirstChoicePanelVM
end

function OpsNewbieStrategyPanelVM:GetRecommendPanelVM()
    return self.RecommendPanelVM
end

function OpsNewbieStrategyPanelVM:GetAdvancedPanelVM()
    return self.AdvancedPanelVM
end
--------------------------------------------- 获取子界面VM end ----------------------------------------------------

---界面打开首次选中页签处理
function OpsNewbieStrategyPanelVM:SetFirstSelectedPanel()
    self:SetSubPanelShow(OpsNewbieStrategyDefine.PanelKey.FirstChoicePanel)
end

---代码设置界面显示，非玩家点击
function OpsNewbieStrategyPanelVM:SetSubPanelShow(Key)
    self:SetSelectedMenuItem(Key)
end

---获取当前选中页签index
function OpsNewbieStrategyPanelVM:GetSelectedMenuIndex()
    if self.CurSelectedMenuItem then
        return self.CurSelectedMenuItem:AdapterOnGetWidgetIndex() or 1
    else
        return 1
    end
end

---获取进入设置页签控件选中Index
function OpsNewbieStrategyPanelVM:GetOpenMenuIndex()
    local Index = 1
    local MenuItem
    ---判断打开默认页签下标
    if self.FirstChoicePanelVM and not self.FirstChoicePanelVM:GetIsFinished() or not self.FirstChoicePanelVM:GetIsGetAllReward() then
        ---首选没完成/未领奖，默认打开首选
        MenuItem = self:FindMenuItem(OpsNewbieStrategyDefine.PanelKey.FirstChoicePanel)
    elseif self.RecommendPanelVM and not self.RecommendPanelVM:GetIsFinished() or not self.RecommendPanelVM:GetIsGetAllReward() then
        ---首选完成/已领奖，推荐未完成/未领奖，默认打开推荐
        MenuItem = self:FindMenuItem(OpsNewbieStrategyDefine.PanelKey.RecommendPanel)
    elseif self.AdvancedPanelVM then
        ---首选完成，推荐完成，默认打开进阶
        MenuItem = self:FindMenuItem(OpsNewbieStrategyDefine.PanelKey.AdvancedPanel)
    end
    if MenuItem then
        Index =  MenuItem:AdapterOnGetWidgetIndex()
    end
    return Index or 1
end

---获取当前选中页签Key
function OpsNewbieStrategyPanelVM:GetSelectedMenuKey()
    if self.CurSelectedMenuItem then
        return self.CurSelectedMenuItem:GetKey() or 0
    else
        return 0
    end
end

---清理隐藏时需要清理的数据
function OpsNewbieStrategyPanelVM:ClearUIData()
    if self.CurSelectedMenuItem then
        self.CurSelectedMenuItem:SetSelected(false)
        self.CurSelectedMenuItem = nil
    end
end

function OpsNewbieStrategyPanelVM:GetAdvancedIsUnlock()
       ---判断是否解锁进阶
    -- if self.FirstChoicePanelVM and self.FirstChoicePanelVM:GetIsFinished() and
    --     self.RecommendPanelVM and  self.RecommendPanelVM:GetIsFinished() then
    --     ---首选完成，推荐完成，进阶解锁
    --     return true
    -- else
    --     return false
    -- end
    return self.AdvancedPanelVM:GetIsUnlock()
end

---勇气嘉奖更新
function OpsNewbieStrategyPanelVM:UpdateBraveryAwardData(Data)
    local ActivityList = Data.BindableActivityList:GetItems()
    local ActivityID = OpsNewbieStrategyDefine.ActivityID.BraveryAwardActivityID
    local ActivityData = table.find_by_predicate(ActivityList, function(A)
        return A:GetKey() == ActivityID
    end)
    if ActivityData == nil then
        return
    end
    self:UpdateBraveryAwardDataByNodeList(ActivityData.NodeList)
end

---勇气嘉奖更新
function OpsNewbieStrategyPanelVM:UpdateBraveryAwardDataByNodeList(NodeList)
    self.BraveryAwardProBar, self.BraveryAwardCurNum, self.BraveryAwardMaxNum, self.IsHaveGiveBraveryReward, self.IsBraveryRewardFinished  = _G.OpsNewbieStrategyMgr:GetBraveryAwardProgress(NodeList)
    if self.BraveryAwardCurNum and self.BraveryAwardMaxNum then
        self.BraveryAwardNumText = string.format("%s/%s", self.BraveryAwardCurNum, self.BraveryAwardMaxNum)
    end
end

---设置进阶页签是否解锁
function OpsNewbieStrategyPanelVM:SetAdvancedIsUnLock()
    local IsUnLock = self:GetAdvancedIsUnlock()
    local MenuItems = self.MenuList:GetItems()
    local AdvancedMenuItem = table.find_by_predicate(MenuItems, function(A)
        return A.Key == OpsNewbieStrategyDefine.PanelKey.AdvancedPanel
    end)
    if AdvancedMenuItem then
        AdvancedMenuItem:SetIsUnLock(IsUnLock)
    else
        return
    end
    ---进阶页签红点特殊处理
    if IsUnLock then
        local Name = "First"
        local FirstRedDotName = _G.OpsActivityMgr:GetRedDotName(OpsNewbieStrategyDefine.OpsNewbieStrategyMenuIndex, OpsNewbieStrategyDefine.ActivityID.AdvancedActivityID, Name)
        local IsShowRed = not _G.RedDotMgr:GetIsSaveDelRedDotByName(FirstRedDotName)
        if IsShowRed then
            _G.RedDotMgr:AddRedDotByName(FirstRedDotName, 1, true)
        end
        local IsFirstRedDot = _G.RedDotMgr:FindRedDotNodeByName(FirstRedDotName)
        if IsFirstRedDot then
            AdvancedMenuItem.RedDotStyle = RedDotDefine.RedDotStyle.SecondStyle
        else
            AdvancedMenuItem.RedDotStyle = RedDotDefine.RedDotStyle.NormalStyle
        end
    end
end

--要返回当前类
return OpsNewbieStrategyPanelVM