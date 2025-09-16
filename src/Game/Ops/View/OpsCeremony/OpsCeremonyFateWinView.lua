---
--- Author: Michaelyang_lightpaw
--- DateTime: 2025-03-03 19:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LootMappingCfg = require("TableCfg/LootMappingCfg")
local LootCfg = require("TableCfg/LootCfg")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

---@class OpsCeremonyFateWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonFateThroughFrame_UIBP CommonFateThroughFrameView
---@field TableViewTask UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsCeremonyFateWinView = LuaClass(UIView, true)

function OpsCeremonyFateWinView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.CommonFateThroughFrame_UIBP = nil
    --self.TableViewTask = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsCeremonyFateWinView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.CommonFateThroughFrame_UIBP)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsCeremonyFateWinView:OnInit()
    self.AdapterEventTabList = UIAdapterTableView.CreateAdapter(self, self.TableViewTask, nil)
end

function OpsCeremonyFateWinView:OnDestroy()
end

function OpsCeremonyFateWinView:OnShow()
    self.CommonFateThroughFrame_UIBP.PopUpBG:SetHideOnClick(false)
    self.CommonFateThroughFrame_UIBP.TextTitle:SetText(LSTR(190140)) -- 庆典结束
    self.CommonFateThroughFrame_UIBP.BtnCheck1:SetBtnName(LSTR(10010)) -- 退出

    if (self.Params == nil) then
        _G.FLOG_ERROR("错误，传入的数据为空，请检查")
        self:Hide()
        return
    end

    Datas = self.Params.ActivityRewards

    if (Datas == nil or #Datas < 1) then
        _G.FLOG_ERROR("服务器下发数据有误，请检查")
        return
    end

    local DataList = {}

    local OriginDataList = {}
    OriginDataList[1] = {}
    OriginDataList[1].TitleText = LSTR(190135)
    OriginDataList[1].FateID = 2002

    OriginDataList[2] = {}
    OriginDataList[2].TitleText = LSTR(190136)
    OriginDataList[2].FateID = 2003

    OriginDataList[3] = {}
    OriginDataList[3].TitleText = LSTR(190137)
    OriginDataList[3].FateID = 2004

    for Index = 1, 3 do
        local Value = nil
        for Key, TempValue in pairs(Datas) do
            if (TempValue.FateID ==  OriginDataList[Index].FateID) then
                Value = TempValue
                break
            end
        end
        
        local TargetFateID = OriginDataList[Index].FateID
        local TargetCount = 0
        local TargetLootID = 0
        local TargetTitleStr = OriginDataList[Index].TitleText
        if (Value ~= nil) then
            TargetFateID = Value.FateID
            TargetCount = Value.Count
            TargetLootID = Value.LootID
        end

        local TargetCfg = _G.FateMgr:GetFateCfg(TargetFateID)
        local TitleText = nil
        if (TargetCfg ~= nil) then
            TitleText = TargetCfg.Name
        end

        local LootMapId = TargetLootID
        local SearchStr = string.format("ID == %d", LootMapId)
        local LootMapping = LootMappingCfg:FindCfg(SearchStr)
        local Num = 0
        local ItemResID = 65800001
        if (LootMapping ~= nil) then
            local LootId = LootMapping.Programs[1].ID
            local LootTableData = LootCfg:FindCfgByKey(LootId)
            if (LootTableData == nil) then
                _G.FLOG_ERROR("无法获取 LootCfg 表格数据，ID是" .. LootId)
            else
                ItemResID = LootTableData.Produce[1].ID
                Num = LootTableData.Produce[1].MinValue
            end
        end

        local SingleData = {}
        SingleData.TitleText = TitleText
        SingleData.Num = Num
        SingleData.InfoText = string.format(TargetTitleStr, TargetCount)
        SingleData.ItemResID = ItemResID    
       
        table.insert(DataList, SingleData)
    end
    self.AdapterEventTabList:UpdateAll(DataList, #DataList)
end

function OpsCeremonyFateWinView:OnHide()
    _G.LootMgr:SetDealyState(false)
end

function OpsCeremonyFateWinView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.CommonFateThroughFrame_UIBP.BtnCheck1, self.OnClickQuitBtn)
end

function OpsCeremonyFateWinView:OnClickQuitBtn()
    self:Hide()
end

function OpsCeremonyFateWinView:OnRegisterGameEvent()
end

function OpsCeremonyFateWinView:OnRegisterBinder()
end

return OpsCeremonyFateWinView
