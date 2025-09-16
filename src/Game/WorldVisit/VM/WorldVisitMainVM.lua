local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local LoginMgr = require("Game/Login/LoginMgr")
local ServerListItemVM = require("Game/worldvisit/VM/WorldVisitServerItemVM")
local WorldVisitDefine =  require("Game/WorldVisit/WorldVisitDefine")
local ServerItemEntryType = WorldVisitDefine.WorldVisitEntryWidgetType
local WorldVisitMainVM = LuaClass(UIViewModel)

function WorldVisitMainVM:Ctor()
    self.ServerList = UIBindableList.New(ServerListItemVM)
end

function WorldVisitMainVM:InitServerList()
    local CurWorldID = _G.PWorldMgr:GetCurrWorldID()  --- 当前WorldID
    local OriginWorldID = LoginMgr:GetWorldID()  -- 原始WorldID
    local FinalData = {}
    for i, v in ipairs(WorldVisitDefine.TitleItem) do
        table.insert(FinalData, v)
    end

    local NodeList = LoginMgr.TreeInfo.NodeList
    local NodeCount = #NodeList
    for i = 1, NodeCount do
        local NodeWrapper = NodeList[i]
        if NodeWrapper.Type == UE.ETreeNodeType.TnTypeLeaf then
            local LeafNode = NodeWrapper.Leaf
            local ServerListItem = {
                WorldID = LeafNode.Id,
                Name = LeafNode.Name,
                State = LeafNode.Flag,
                IsOriginalServer = false,
                IsCurServer = false,
                EnterWidgetType = ServerItemEntryType.AllServerListItem,
                ListSort = WorldVisitDefine.ItemSortValue.AllSerTop + i
            }

            if CurWorldID == LeafNode.Id then
                ServerListItem.IsCurServer = true
                ServerListItem.ListSort = WorldVisitDefine.ItemSortValue.CurSerSort
                ServerListItem.EnterWidgetType = ServerItemEntryType.CurServerInfoItem
                table.insert(FinalData, ServerListItem)
                if OriginWorldID == CurWorldID then
                    local AllSerItemTemp = table.deepcopy(ServerListItem)
                    AllSerItemTemp.IsOriginalServer = true
                    AllSerItemTemp.IsCurServer = false
                    AllSerItemTemp.ListSort = WorldVisitDefine.ItemSortValue.OriginSort
                    table.insert(FinalData, AllSerItemTemp)
                end
            elseif OriginWorldID == LeafNode.Id  then
                ServerListItem.IsOriginalServer = true
                ServerListItem.ListSort = WorldVisitDefine.ItemSortValue.OriginSort
                ServerListItem.EnterWidgetType = ServerItemEntryType.CurServerInfoItem
                table.insert(FinalData, ServerListItem)
    
                local AllSerItemTemp = table.deepcopy(ServerListItem)
                AllSerItemTemp.EnterWidgetType = ServerItemEntryType.AllServerListItem
                AllSerItemTemp.ListSort = WorldVisitDefine.ItemSortValue.AllSerTop
                table.insert(FinalData, AllSerItemTemp)
            else
                table.insert(FinalData, ServerListItem)
            end
        end
    end

    table.sort(FinalData, function(a, b)
        return a.ListSort < b.ListSort
    end)

    self.ServerList:UpdateByValues(FinalData)
end

return WorldVisitMainVM
