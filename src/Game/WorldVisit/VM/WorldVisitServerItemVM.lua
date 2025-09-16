local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local WorldVisitDefine =  require("Game/WorldVisit/WorldVisitDefine")
local ServerItemEntryType = WorldVisitDefine.WorldVisitEntryWidgetType
local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")

local WorldVisitServerItemVM = LuaClass(UIViewModel)

function WorldVisitServerItemVM:Ctor()
    self.EnterWidgetType = ServerItemEntryType.SeverItemTitle
    self.ServerTitle = nil              --- 服务器标题 
    self.ServerState = nil              --- 服务器网络状态Image

    self.IsShowServerImg = false        --- 服务器图标显示
    self.ServerImg = nil                --- 服务器图标
    self.SubServerName = nil            --- 服务器副标题(当前服务器 及原始服务器名)
    self.WorldID = 0                    --- WorldID
end

function WorldVisitServerItemVM:AdapterOnGetWidgetIndex()
    return self.EnterWidgetType
end

function WorldVisitServerItemVM:UpdateVM(Value)
    self.IsShowServerImg = false
    self.EnterWidgetType = Value.EnterWidgetType
    self.ServerTitle = Value.Name
    if Value.IsTitle then return end
    
    self.State = Value.State
    self.WorldID = Value.WorldID

    for i = 1, #LoginNewDefine.ServerStateConfig do
        local ServerState = LoginNewDefine.ServerStateConfig[i]
        if ServerState.State == Value.State then
            self.ServerState = ServerState.Icon
            break
        end
    end

    if Value.IsCurServer or Value.IsOriginalServer then
        self.IsShowServerImg = true
        if Value.IsCurServer then
            self.SubServerName = _G.LSTR(1530006)
            self.ServerImg = "Texture2D'/Game/UI/Texture/WorldVisit/UI_WorldVisit_Icon_CurrentServer.UI_WorldVisit_Icon_CurrentServer'"
        else
            self.SubServerName = _G.LSTR(1530007)
            self.ServerImg = " Texture2D'/Game/UI/Texture/WorldVisit/UI_WorldVisit_Icon_OriginalServer.UI_WorldVisit_Icon_OriginalServer'"
        end
    end
end

function WorldVisitServerItemVM:IsEqualVM(Value)
	return Value and Value.WorldID == self.WorldID
end

return WorldVisitServerItemVM