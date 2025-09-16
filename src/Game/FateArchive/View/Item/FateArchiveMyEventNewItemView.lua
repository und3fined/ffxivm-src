---
--- Author: michaelyang_lightpaw
--- DateTime: 2024-08-28 14:28
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local FateMyEventCfg = require("TableCfg/FateMyEventCfg")
local MapMap2areaCfgTable = require("TableCfg/MapMap2areaCfg")
local FateMainCfgTable = require("TableCfg/FateMainCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")

---@class FateArchiveMyEventNewItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field ImgNormalIcon UFImage
---@field ImgRareIcon UFImage
---@field RichTextContent URichTextBox
---@field TextComplete UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateArchiveMyEventNewItemView = LuaClass(UIView, true)

function FateArchiveMyEventNewItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.ImgNormalIcon = nil
	--self.ImgRareIcon = nil
	--self.RichTextContent = nil
	--self.TextComplete = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateArchiveMyEventNewItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateArchiveMyEventNewItemView:OnInit()
end

function FateArchiveMyEventNewItemView:OnDestroy()
end

local AddColor = function(Str)
    local Result = string.format('<span color="%s">%s</>', "#BD8213FF", Str)
    return Result
end

function FateArchiveMyEventNewItemView:OnShow()
    local Param = self.Params
    if nil == Param then
        return
    end
    local EventInfo = Param.Data
    if EventInfo.Percent >= 10 then
        self.TextComplete:SetText(string.format("%.0f%%", EventInfo.Percent))
    else
        self.TextComplete:SetText(string.format("%.1f%%", EventInfo.Percent))
    end
    local EventCfg = FateMyEventCfg:FindCfgByKey(EventInfo.ID)
    local Content = nil
    if (EventCfg == nil) then
        _G.FLOG_ERROR("无法获取 FateMyEventCfg 数据，ID是:" .. EventInfo.ID)
        Content = _G.LSTR(190115)
    else
        -- 职业配置 RoleInitCfg:FindRoleInitProfName(Prof)
        -- 根据类型拼装要显示的文本
        if (type(EventInfo.Param) == "table") then
            if #EventInfo.Param == 1 then
                Content = string.format(EventCfg.Describe, AddColor(EventInfo.Param[1]))
            else
                if EventInfo.ID == 4 then
                    local MapMap2areaCfg = MapMap2areaCfgTable:FindCfgByKey(EventInfo.Param[1])
                    if MapMap2areaCfg ~= nil and EventCfg.Describe and EventInfo.Param[2] then
                        Content =
                            string.format(
                            EventCfg.Describe,
                            AddColor(MapMap2areaCfg.MapName),
                            AddColor(EventInfo.Param[2])
                        )
                    end
                elseif EventInfo.ID == 5 then
                    local MapMap2areaCfg = MapMap2areaCfgTable:FindCfgByKey(EventInfo.Param[1])
                    if MapMap2areaCfg ~= nil and EventCfg.Describe and EventInfo.Param[2] then
                        Content =
                            string.format(
                            EventCfg.Describe,
                            AddColor(MapMap2areaCfg.MapName),
                            AddColor(EventInfo.Param[2] .. "%")
                        )
                    end
                elseif EventInfo.ID == 9 then
                    local FateCfg = FateMainCfgTable:FindCfgByKey(EventInfo.Param[1])
                    if (FateCfg ~= nil) then
                        Content = string.format(EventCfg.Describe, AddColor(FateCfg.Name), AddColor(EventInfo.Param[2]))
                    else
                        _G.FLOG_ERROR("无法获取 Fate表的数据, ID是:%s", EventInfo.Param[1])
                    end
                elseif EventInfo.ID == 10 then
                    local ProfName = RoleInitCfg:FindRoleInitProfName(EventInfo.Param[1])
                    Content = string.format(EventCfg.Describe, AddColor(ProfName), AddColor(EventInfo.Param[2]))
                end
            end
        else
            Content = string.format(EventCfg.Describe, AddColor(EventInfo.Param or 0))
        end
    end

    self.RichTextContent:SetText(Content)
    --判断多少百分比一下是稀有
    local bIsRare = (EventInfo.Percent >= 90)
    UIUtil.SetIsVisible(self.ImgNormalIcon, not bIsRare)
    UIUtil.SetIsVisible(self.ImgRareIcon, bIsRare)
end

function FateArchiveMyEventNewItemView:OnHide()
end

function FateArchiveMyEventNewItemView:OnRegisterUIEvent()
end

function FateArchiveMyEventNewItemView:OnRegisterGameEvent()
end

function FateArchiveMyEventNewItemView:OnRegisterBinder()
end

return FateArchiveMyEventNewItemView
