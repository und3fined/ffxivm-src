--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-02-10 15:04:43
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-02-10 15:05:46
--]]

local WorldVisitEntryWidgetType = {
	SeverItemTitle = 0, -- 服务器信息Title
	CurServerInfoItem = 1, -- 当前及原始服务器Item类型
    AllServerListItem = 2, -- 所有服务器Item
}

local ItemSortValue = {
    TopTitle = 0,
    OriginSort = 1,
    CurSerSort = 2,
    SubTitle = 3,
    AllSerTop = 4,
}

local TitleItem = {
    [1] = {
        Name = _G.LSTR(1530002),
        ListSort = ItemSortValue.TopTitle,
        EnterWidgetType = WorldVisitEntryWidgetType.SeverItemTitle,
        IsTitle = true,
    },

    [2] = {
        Name = _G.LSTR(1530003),
        ListSort = ItemSortValue.SubTitle,
        EnterWidgetType = WorldVisitEntryWidgetType.SeverItemTitle,
        IsTitle = true,
    }
}

local WorldVisitDefine = {
    WorldVisitEntryWidgetType = WorldVisitEntryWidgetType,
    TitleItem = TitleItem,
    ItemSortValue = ItemSortValue,
}

return WorldVisitDefine