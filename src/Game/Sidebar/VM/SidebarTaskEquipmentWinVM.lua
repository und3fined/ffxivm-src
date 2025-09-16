---
--- Author: sammrli
--- DateTime: 2024-06-06 15:54
--- Description:一键穿戴侧边栏 ViewModel
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local MajorUtil = require("Utils/MajorUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

local UIBindableList = require("UI/UIBindableList")

local ItemCfg = require("TableCfg/ItemCfg")

local EquipmentSlotItemVM = require("Game/Equipment/VM/EquipmentSlotItemVM")

---@class SidebarTaskEquipmentWinVM : UIViewModel
---@field EquipmentList UIBindableList @可穿戴装备列表
local SidebarTaskEquipmentWinVM = LuaClass(UIViewModel)

function SidebarTaskEquipmentWinVM:Ctor()
    self.TextTitle = _G.LSTR(596202) --596202("任务所需装备")
    self.TextBtn = _G.LSTR(596203) --596203("装备")
    self.EquipmentList = UIBindableList.New(EquipmentSlotItemVM)
end

---@param MissItemList table<number, table>
function SidebarTaskEquipmentWinVM:UpdateView(MissItemList)
    self.EquipmentList:Clear()

    if not MissItemList then
        return
    end

    local ShowTable = {}

    local AllEquipItem = _G.BagMgr:FilterItemByCondition(function(Item)
        return Item and Item.Attr and Item.Attr.Equip
    end)

    local ProfID = MajorUtil.GetMajorProfID()

    for Part, NeedItem in pairs(MissItemList) do
        for i=1, #AllEquipItem do
            local EquipItem = AllEquipItem[i]
            if EquipItem and EquipItem.Attr.Equip.Part == Part then
                if _G.EquipmentMgr:CanEquiped(EquipItem.ResID, false, ProfID) then --职业
                    local MeetID = false
                    local MeetLevel = false
                    if NeedItem.ID and NeedItem.ID > 0 then
                        MeetID = EquipItem.ResID == NeedItem.ID
                    else
                        MeetID = true
                    end
                    if NeedItem.Level then
                        local ItemCfgItem = ItemCfg:FindCfgByKey(EquipItem.ResID)
                        if ItemCfgItem then
                            MeetLevel = ItemCfgItem.ItemLevel >= NeedItem.Level
                        end
                    else
                        MeetLevel = true
                    end
                    if MeetID and MeetLevel then
                        ShowTable[EquipItem.ResID] = EquipItem
                        AllEquipItem[i] = nil
                        break
                    end
                end
            end
        end
    end

    local function OnSlotItemClick(EquipmentSlotItemVM)
        local OnSlotItemClickCallback = self.OnSlotItemClickCallback
        if OnSlotItemClickCallback then
            OnSlotItemClickCallback(EquipmentSlotItemVM)
        end
        if EquipmentSlotItemVM then
            local ItemVMs = self.EquipmentList:GetItems()
            for i=1, #ItemVMs do
                local ItemVM = ItemVMs[i]
                ItemVM.bSelect = ItemVM.GID == EquipmentSlotItemVM.GID
            end
        end
    end

    local EquipSlotVMList = {}
    for _,EquipItem in pairs(ShowTable) do
        local EquipSlotVM = {}
        EquipSlotVM.Part = EquipItem.Attr.Equip.Part
        EquipSlotVM.ResID = EquipItem.ResID
        EquipSlotVM.GID = EquipItem.GID
        EquipSlotVM.ParentType = 1
        EquipSlotVM.bBtnVisibel = true
        EquipSlotVM.OnClick = OnSlotItemClick
        table.insert(EquipSlotVMList, EquipSlotVM)
    end

    self.EquipmentList:UpdateByValues(EquipSlotVMList)
end

-- 一键穿戴
function SidebarTaskEquipmentWinVM:OneKeyWear()
    local Num = self.EquipmentList:Length()
    if Num == 0 then
        return
    end
    --检查穿戴条件
    if not _G.EquipmentMgr:CheckCanOperate(LSTR(1050178), true) then
		return
	end
    local lstEquipInfo = {}
    for i=1, Num do
        local Equipment = self.EquipmentList:Get(i)
        table.insert(lstEquipInfo, { Part=Equipment.Part, GID=Equipment.GID})
    end
    _G.EquipmentMgr:SendEquipOn(lstEquipInfo)
end

function SidebarTaskEquipmentWinVM:RegisterSlotItemClick(OnSlotItemClickCallback)
    self.OnSlotItemClickCallback = OnSlotItemClickCallback
end

return SidebarTaskEquipmentWinVM