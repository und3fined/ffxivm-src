---
--- Author: xingcaicao
--- DateTime: 2023-11-29 14:25:00
--- Description: 个人信息--肖像 ViewModel
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local Json = require("Core/Json")
local ProtoCommon = require("Protocol/ProtoCommon")
local PortraitBaseCfg = require("TableCfg/PortraitBaseCfg")
local PortraitDesignCfg = require("TableCfg/PortraitDesignCfg")
local PortraitPredesignCfg = require("TableCfg/PortraitPredesignCfg")
local PersonPortraitDefine = require("Game/PersonPortraitHead/PersonPortraitHeadDefine")
local EditVM = require("Game/PersonPortraitHead/VM/PersonPortraitHeadEditVM")
local EmotionMgr = require("Game/Emotion/EmotionMgr")
local MajorUtil = require("Utils/MajorUtil")
local TabTypes = PersonPortraitDefine.TabTypes
local FilterType = PersonPortraitDefine.FilterType

local DesignerType = ProtoCommon.DesignerType
local UnlockTypes = ProtoCommon.PersonalPortraitUnlockType

local USaveMgr = _G.UE.USaveMgr
local SaveKey = require("Define/SaveKey")

local LOG = _G.FLOG_INFO

local BagMgr

local function LOG_S(K, S)
    LOG(string.format('[PersonHead][PersonPortraitHeadVM][%s] %s', tostring(K), tostring(S)))
end

local HeadFrameCfg = require("TableCfg/HeadFrameCfg")
local HeaderFrameTabCfg = require("TableCfg/HeaderFrameTabCfg")

local HeadPortraitCfg = require("TableCfg/HeadPortraitCfg")
local HeadEditEmoCfg = require("TableCfg/HeadEditEmoCfg")


local PersonPortraitHeadDefine = require("Game/PersonPortraitHead/PersonPortraitHeadDefine")

local HeadFixedItemVM = require("Game/PersonPortraitHead/VM/Item/PersonPortraitHeadItemVM")
local HeadCustItemVM = require("Game/PersonPortraitHead/VM/Item/PersonPortraitHeadCustItemVM")
local FrameItemVM = require("Game/PersonPortraitHead/VM/Item/PersonInfoPortraitFrameVM")
local HeadEmoItemVM = require("Game/PersonPortraitHead/VM/Item/PersonInfoHeadPortraiEmoVM")


local FrameType = PersonPortraitHeadDefine.FrameType
local PersonPortraitHeadMgr


local LOG = _G.FLOG_INFO

--- 私聊会话排序算法
---@param lhs any
---@param rhs any
local ItemListSortFunc = function(lhs, rhs)
    if lhs.IsOwned ~= rhs.IsOwned then
        return lhs.IsOwned
    end

    if lhs.Unknown ~= rhs.Unknown then
        return not lhs.Unknown 
    end

    return (lhs.ID or 0) < (rhs.ID or 0)
end

---@class PersonPortraitHeadVM : UIViewModel
local Class = LuaClass(UIViewModel)

---Ctor
function Class:Ctor()

end
	
function Class:OnInit()
    PersonPortraitHeadMgr = _G.PersonPortraitHeadMgr
    BagMgr = _G.BagMgr

    self.CurModelEditVM = EditVM.New()
    self.DebugPanelVisible = false

    self:Reset()
end

function Class:OnBegin()
end

function Class:OnEnd()

end

function Class:OnShutdown()
    self:Reset()
end

function Class:Reset()
    self:Clear()

    self.TabList = nil 
    self.UnlockResIDMap = {} -- 已解锁的部分资源ID（配置类型为非默认解锁）

    --- frame
    self.FrameVMList = self:ResetBindableList(self.FrameVMList, FrameItemVM)

    --- head mian
    self.HeadMainFixedVMList = self:ResetBindableList(self.HeadMainFixedVMList, HeadFixedItemVM)
    self.HeadMainCustVMList = self:ResetBindableList(self.HeadMainCustVMList, HeadCustItemVM)
    self.HeadHistoryHeadVMList = self:ResetBindableList(self.HeadHistoryHeadVMList, HeadCustItemVM)

    --- edit panel
    self.EmoItemVMList = self:ResetBindableList(self.EmoItemVMList, HeadEmoItemVM)
    self.CurEmoVM = nil
end

function Class:Clear()
    self.CurTab = nil 
    self.AppearUpdateProfIDs = {}

    self.ListPanelVisible = false
    self.DecoratePanelVisible = false
    self.EmotionPanelVisible = false
    self.DesignRetVisible = false

    self.RightPanelVisible = false
    self.ModelEditPanelVisible = false
    self.LightingPanelVisible = false
    self.PlayProbarPanelVisible = false

    self.DecorateVisible = true 

    -- 模型
    self.ScreenshotWidget = nil
    self.DecorateVisibleSet = false
    self.IsPositionValid = true 

    self:ResetProfData()


    --- frame
    self.FrameType = nil
    self.CurFrameVM = nil
    self.InUseFrameID = nil

    --- head
    self.CurHeadVM = nil
    self.CurHeadInfo = nil

    --- main panel staff
    self.IsShowHeadPanel = false
    self.IsShowFramePanel = false
    self.CurTabKey = nil

    --- edit panel staff
    self.IsEditShowDelete = false
    self.CustHeadCnt = '(0/8)'
    self.IsEnableHeadSave = false
    self.IsEnableUse = (USaveMgr:GetInt(SaveKey.HeadEditSaveAndUse, 1, true) or 1) == 1

    --- history heads
    self.HasHistoryHeads = false
    self.IsShow8HistoryHead = false

    ---
    self.LastUseCustHead = nil
end

function Class:UpdIsEnableUse()
    local V = USaveMgr.GetInt(SaveKey.HeadEditSaveAndUse, 1, true)
    self.IsEnableUse = (V or 1) == 1
end

function Class:SetIsEnableUse(V)
    self.IsEnableUse = V
    USaveMgr.SetInt(SaveKey.HeadEditSaveAndUse, V and 1 or 0, true)
end

function Class:ResetProfData()
    self.CurProfID = nil
    self.CurEquipScheme = nil
    self.CurSelectItemVM = nil
    self.IsEnabledSaveBtn = false

    self.CurProfSetResIDsServer = {} -- 当前职业的设置资源ID列表(服务器端)
    self.CurProfSetResIDsServerMap = {}
    self.CurModelEditDataServer = {}

    self.CurSelectPredesignID = nil
    self.CurSelectBgID = 0 
    self.CurSelectDecorateID = 0 
    self.CurSelectFrameID = 0 
    self.CurSelectActionID = 0 
    self.CurSelectEmotionID = 0 

    self.CurModelEditVM:Reset()
end

function Class:UpdateCurModelEditVM(JsonStr)
    local T = {}
    if not string.isnilorempty(JsonStr) then
        T = Json.decode(JsonStr) or {}
    end

    LOG_S('UpdateCurModelEditVM', string.format('Json = %s', table.tostring(T)))
    LOG_S('UpdateCurModelEditVM', string.format('FOV = %s', tostring(T.FOV)))
    self.CurModelEditDataServer = T
    self.CurModelEditVM:UpdateVM(self.CurModelEditDataServer)
end

function Class:UpdateDecorateVisible(VisibleSet)
    self.DecorateVisibleSet = VisibleSet
    self.DecorateVisible = self.CurTab ~= TabTypes.ModelEdit or VisibleSet
end

function Class:UpdateIsPositionValid(IsValid)
    self.IsPositionValid = IsValid
    self:UpdateSaveBtnState()
end

function Class:UpdateSaveBtnState()
    if not self.IsPositionValid then
        self.IsEnabledSaveBtn = true 
        return
    end

    if self:CheckIsSetsChanged() then
        self.IsEnabledSaveBtn = true 
        return
    end

    self.IsEnabledSaveBtn = false 
end

---检测设置内容是否有变化
function Class:CheckIsSetsChanged()

    if self.CurModelEditVM:IsNotEqual(self.CurModelEditDataServer) then
        return true
    end

    return false
end

---检查当前设置是否有未解锁资源
function Class:CheckHaveLockRes()
    local CurSetResIDs = self:GetCurSetResIDs()
    local UnlockIDMap = self.UnlockResIDMap

    for _, v in pairs(CurSetResIDs) do
        local Cfg = v > 0 and PortraitDesignCfg:FindCfgByKey(v) or nil
        if Cfg then
            local Type = Cfg.TypeID

            -- 背景、装饰、装饰框
            if Type == DesignerType.DesignerType_BackGround or Type == DesignerType.DesignerType_Decoration or Type == DesignerType.DesignerType_Decoration_Frame then
                if nil == UnlockIDMap[v] and Cfg.UnlockType ~= UnlockTypes.PersonalPortraitUnlockDefault then
                    return true, Type
                end

            elseif Type == DesignerType.DesignerType_Emotion or Type == DesignerType.DesignerType_Action then -- 表情、动作
                if not EmotionMgr:IsActivated(Cfg.EmotionID) then
                    return true, Type
                end
            end
       end
	end

    return false
end

---更新动作表情项VM列表
---@param DesignType ProtoCommon.DesignerType @设计类型
---@param Filter PersonPortraitDefine.FilterType @类型 
function Class:UdpateEmotionItemVMList(DesignType, Filter)
    if nil == DesignType then
        return
    end

    local CfgList = PortraitDesignCfg:GetDesignInfosByType(DesignType)

    local Data = {}

    for _, v in ipairs(CfgList) do
        local IsOwned = EmotionMgr:IsActivated(v.EmotionID) 
        if (Filter == FilterType.All) or (Filter == FilterType.Owned and IsOwned) or (Filter == FilterType.NotOwned and not IsOwned) then
            table.insert(Data, {TypeID = v.TypeID, CfgData = v, IsOwned = IsOwned})
        end
    end

    self.EmotionItemVMList:UpdateByValues(Data, ItemListSortFunc)
	self.ShowingItemVMList = self.EmotionItemVMList
end

---是否为防剧透且未解锁资源
---@param ResID numberr @资源ID
function Class:IsSecretAndLocked(ResID)
    if nil == ResID then
        return false
    end

    local UnlockIDMap = self.UnlockResIDMap
    if UnlockIDMap[ResID] then
       return false
    end

    local Cfg = PortraitDesignCfg:FindCfgByKey(ResID)
    if nil == Cfg or Cfg.Unknown ~= 1 then -- 不是防剧透
        return false
    end

    local Type = Cfg.TypeID

    -- 背景、装饰、装饰框
    if Type == DesignerType.DesignerType_BackGround 
        or Type == DesignerType.DesignerType_Decoration 
        or Type == DesignerType.DesignerType_Decoration_Frame then
        return Cfg.UnlockType ~= UnlockTypes.PersonalPortraitUnlockDefault
    end

    -- 表情、动作
    if Type == DesignerType.DesignerType_Emotion or Type == DesignerType.DesignerType_Action then
        return not EmotionMgr:IsActivated(Cfg.EmotionID)
    end

    return false
end

-------------------------------------------------------------------------------------------------------
---@region panel menu

function Class:GetEditPanelTab()
    local All = HeadFrameCfg:FindAllCfg()

    local FrameTable = {}
    local FrameInfo = {}

    FrameTable[1] = true
    for _, Cfg in pairs(All or {}) do
        FrameTable[Cfg.FrameType] = true
    end
    
    for TabID, _ in pairs(FrameTable) do
        local TabCfg = HeaderFrameTabCfg:FindCfgByKey(TabID)

        -- local TabCfg = {
        --     ID = TabID,
        --     Name = "测试" .. TabID
        -- }

        if TabCfg then
            local Info = {
                Key = TabCfg.ID + PersonPortraitHeadDefine.TFrame,
                Name = TabCfg.Name,
            }

            table.insert(FrameInfo, Info)
        end
    end
    
    local Tabs = table.clone(PersonPortraitHeadDefine.EditTabs) 

    Tabs[2].Children = FrameInfo

    self.Tabs = Tabs

    return self.Tabs
end

function Class:SetEditCurTab(Key)
    LOG('[PersonInfo][PersonPortraitHeadVM][SetEditCurTab] Tab =' .. tostring(Key))
    
    if self.CurTabKey == Key then
        return 
    end

    self.CurTabKey = Key

    if Key >> 8 == 0 then
        self.IsShowHeadPanel = false
        self.IsShowFramePanel = true
        
        if Key == 0 then
        else
            self:UpdFrameList()
        end
    else

        self.IsShowHeadPanel = true
        self.IsShowFramePanel = false
        self:UpdHeadFixedList()
        self:UpdHeadCustList()
    end
end

-------------------------------------------------------------------------------------------------------
---@region head

function Class:UpdHeadFixedList()
    local All = HeadPortraitCfg:GetHeadPortraitList()
    local Data = {}

    local RoleVM = MajorUtil.GetMajorRoleVM()

    local Race = RoleVM.HeadInfo.Race or 1

    for ResID, Item in pairs(All) do
        if Item.RaceID == Race then
            for Idx = 1, 4 do
                if not string.isnilorempty(Item.Icon[Idx]) then
                    table.insert(Data, {
                        HeadResID = ResID,
                        HeadIdx = Idx,
                        HeadIcon = Item.Icon[Idx],
                        HeadName = Item.Name[Idx],
                    })
                end
            end
        end
    end

    self.HeadMainFixedVMList:UpdateByValues(Data)
end

function Class:UpdHeadCustList()
    local Data = PersonPortraitHeadMgr.HeadCustList 
    local Num = #(Data or {})

    self.IsEnableHeadSave = Num < 8

    self.CustHeadCnt = string.format('(%s/8)', tostring(Num))
    local List = {}
    for Idx = 1, 8 do
        local Item = {}
        local DataEle = Data[Idx] or {}
        Item.HeadCustID = DataEle.HeadID
        Item.HeadUrl = DataEle.HeadUrl
        Item.Idx = Idx
        table.insert(List, Item)
    end
    self.HeadMainCustVMList:UpdateByValues(List)

    if self.CurHeadVM then
        if self.CurHeadVM.HeadType == PersonPortraitHeadDefine.HeadType.Custom then
            if self.CurHeadVM.Idx > Num then
                self.CurHeadVM = nil
            end
            if not self.HeadMainCustVMList:ContainEqualVM(self.CurHeadVM) then
                self.CurHeadVM = nil
            end
        end
    end
end

-------------------------------------------------------------------------------------------------------
---@region history heads 

function Class:UpdHistoryHeadInfo()
    local Data = PersonPortraitHeadMgr.HistoryHeadList

    if not Data or table.empty(Data) then
        self.HasHistoryHeads = false
        return
    end

    self.HasHistoryHeads = true

    local List = {}

    for Idx, DataEle in pairs(Data or {}) do
        local Item = {}
        Item.HeadCustID = DataEle.head_id
        Item.HeadUrl = DataEle.head_url
        Item.IsHistory = true
        Item.Idx = Idx
        table.insert(List, Item)
    end

    self.HeadHistoryHeadVMList:UpdateByValues(List)
    self.IsShow8HistoryHead = #List > 4
end

-------------------------------------------------------------------------------------------------------
---@region head frame

function Class:UpdFrameList()
    local Key = self.CurTabKey
    if not Key or Key >> 8 ~= 0 or Key == (1 << 7) then
        return
    end

   local Type = Key - (1 << 7)

   local ServeData = PersonPortraitHeadMgr.FrameMap or {}

   -- 默认第一个解锁
   ServeData[1] = {}

   local All = HeadFrameCfg:FindAllCfg()

--    LOG('[PersonInfo][PersonPortraitHeadVM][UpdFrameList] All = ' .. table.tostring(All))
   local Data = {}

   for _, Cfg in pairs(All or {}) do
        local ID = Cfg.ID
        if ID ~= nil then
            -- LOG('[PersonInfo][PersonPortraitHeadVM][UpdFrameList] FrameType = ' .. tostring(Item.FrameType))
            if (Type == 1) or (Cfg.FrameType == Type) then
                local Item = ServeData[ID]
                table.insert(Data, {FrameResID = ID, CfgData = Cfg, IsUnlock = Item ~= nil})
            end
        end
   end

--    LOG('[PersonInfo][PersonPortraitHeadVM][UpdFrameList] Type = ' .. tostring(Type))
--    LOG('[PersonInfo][PersonPortraitHeadVM][UpdFrameList] Data = ' .. table.tostring(Data))

   self.FrameVMList:UpdateByValues(Data)
end

function Class:UpdFrameListInUse()
    if not self.FrameVMList then return end

    for _, Item in pairs(self.FrameVMList:GetItems()) do
        Item:UpdInUse()
   end
end

-------------------------------------------------------------------------------------------------------
---@region head edit

function Class:UpdEditInfo()
    self:UpdHeadEmoList()
end

function Class:UpdHeadEmoList()
    local All = HeadEditEmoCfg:FindAllCfg()
    local Data = {}
    table.insert(Data, {})
    for _, Item in pairs(All or {}) do
        table.insert(Data, {EmoID = Item.EmoID})
    end

    self.EmoItemVMList:UpdateByValues(Data)
end

return Class