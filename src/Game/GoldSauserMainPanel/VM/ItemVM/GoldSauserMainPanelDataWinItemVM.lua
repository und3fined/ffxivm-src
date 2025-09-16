---
--- Author: star
--- DateTime: 2024-01-05 10:41
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local UIBindableList = require("UI/UIBindableList")
local GoldSauserMainPanelDataListItemVM = require("Game/GoldSauserMainPanel/VM/ItemVM/GoldSauserMainPanelDataListItemVM")
local ProtoRes = require("Protocol/ProtoRes")
local GoldSaucerDataItemCfg =  require("TableCfg/GoldSaucerDataItemCfg")
local RichTextUtil = require("Utils/RichTextUtil")
local GoldSauserDataItemFormatType = ProtoRes.GoldSauserDataItemFormatType
local FLOG_ERROR = _G.FLOG_ERROR
local LSTR = _G.LSTR
local FactorFromLimitToMin = 10000 -- 数据统计从计数上限到算出下限的因数


---@class GoldSauserMainPanelDataWinItemVM : UIViewModel

local GoldSauserMainPanelDataWinItemVM = LuaClass(UIViewModel)

---Ctor
function GoldSauserMainPanelDataWinItemVM:Ctor()
    self.DataItemList = nil
    self.HardPercentage = nil
    self.MiddlePercentage = nil
    self.SimplePercentage = nil
end

function GoldSauserMainPanelDataWinItemVM:OnInit()
    self.DataItemList = UIBindableList.New(GoldSauserMainPanelDataListItemVM)
    self.HardPercentage = 0
    self.MiddlePercentage = 0
    self.SimplePercentage = 0
    self.HardDataNum = 0
    self.MiddleDataNum = 0
    self.SimpleDataNum = 0
end

function GoldSauserMainPanelDataWinItemVM:SetInfo(EventPool, PercentList)
    local ItemList = {}
    self.HardDataNum = 0
    self.MiddleDataNum = 0
    self.SimpleDataNum = 0
    for GameDataItem, Num in pairs(EventPool) do -- 2024.7.29 服务器修改协议变量Map的Key为Int32类型（ProtoCS.GameDataItem）
        local DataItemCfg = GoldSaucerDataItemCfg:FindCfgByKey(GameDataItem)
        if DataItemCfg then
            local ListItemData = {ID = GameDataItem, Percentage = 0, DescriptionStr = "" }
            local Percent = PercentList[GameDataItem]
            if Percent then
                local PercentageContent = (1 - Percent) * 100 -- 2024.10.24 客户端处理
                local function MakeThePercentageByShowRule(Percent)
                    local Limit = DataItemCfg.Limit or 0
                    local Min = Limit / FactorFromLimitToMin -- 2025.4.24 应描述走上限计算下限，不走配表
                    if Percent >= 100 or Num <= Min then
                        return 99.9
                    elseif Percent <= 0.1 then
                        return 0.1
                    else
                        return Percent
                    end
                end
                local ClientItemPercentage = MakeThePercentageByShowRule(PercentageContent)
                ListItemData.Percentage = ClientItemPercentage
                if ClientItemPercentage < 10 then
                    self.HardDataNum = self.HardDataNum + 1
                elseif ClientItemPercentage < 30 then
                    self.MiddleDataNum = self.MiddleDataNum + 1
                elseif ClientItemPercentage < 70 then
                    self.SimpleDataNum = self.SimpleDataNum + 1
                end
            end
            local FormatType = DataItemCfg.ParamType
            local RightStr = ""
            if FormatType == GoldSauserDataItemFormatType.TypeNone then
                RightStr = string.format("%d", Num)
            elseif FormatType == GoldSauserDataItemFormatType.TypeKingDee then
                local NumStr = self:FormatNumber(Num) or ""
                -- while Num > 999  do
                --     local Temp = Num / 1000
                --     local Remainder = Num % 1000
                --     if Remainder < 100 then
                --         Remainder = "0"..Remainder
                --     elseif Remainder < 10 then  
                --         Remainder = "00"..Remainder
                --     end
                --     if Temp < 1000 then
                --         NumStr = Temp.."."..Remainder..NumStr
                --     else
                --         NumStr = "."..Remainder..NumStr
                --     end
                --     Num = Temp
                -- end
                RightStr = string.format("%s", NumStr)
            elseif FormatType == GoldSauserDataItemFormatType.TypeItemNum then
                RightStr = string.format(LSTR(350039), Num)
            elseif FormatType == GoldSauserDataItemFormatType.TypeFairyColorTicket then
                RightStr = string.format(LSTR(350040), Num)
            elseif FormatType == GoldSauserDataItemFormatType.TypePercentage then
                RightStr = string.format("%d%%", Num)
            elseif FormatType == GoldSauserDataItemFormatType.TypeTimes then
                RightStr = string.format(LSTR(350041), Num)
            end
            local RichTextStr = RichTextUtil.GetText(RightStr, "Ffa500")
            ListItemData.DescriptionStr = string.format("%s（%s）",DataItemCfg.EventName,RichTextStr)
            ListItemData.BgPath = self:GetTheListItemBgPath(ListItemData.Percentage)
            table.insert(ItemList, ListItemData)
        end
    end
    table.sort(ItemList,function(Item1,Item2)
        return Item1.Percentage < Item2.Percentage
    end)
    if ItemList then
        self.DataItemList:UpdateByValues(ItemList)
    end
    --[[local ListItemNum = #ItemList
    if ListItemNum == 0 then
        self.HardPercentage = "0.00%"
        self.MiddlePercentage = "0.00%"
        self.SimplePercentage = "0.00%"
    else

        --self.HardPercentage = string.format("%.2f%%",self.HardDataNum / ListItemNum * 100)
        --self.MiddlePercentage = string.format("%.2f%%",self.MiddleDataNum / ListItemNum * 100)
        --self.SimplePercentage = string.format("%.2f%%",self.SimpleDataNum / ListItemNum * 100)
    end--]]
end

--- 设定趣味数据Item背景资源
function GoldSauserMainPanelDataWinItemVM:GetTheListItemBgPath(Percentage)
    if Percentage <= 10 then
        return GoldSauserMainPanelDefine.WinDataItemBgSrcPath.Titan
	elseif Percentage <= 30 then
		return GoldSauserMainPanelDefine.WinDataItemBgSrcPath.Morbol
	elseif Percentage <= 70 then
		return GoldSauserMainPanelDefine.WinDataItemBgSrcPath.Sabotender
	else
        return GoldSauserMainPanelDefine.WinDataItemBgSrcPath.NotListed
	end
end

function GoldSauserMainPanelDataWinItemVM:FormatNumber(Number)
    
    local resultNum = Number
    if type(Number) == "number" then
        local inter, point = math.modf(Number)

        local StrNum = tostring(inter)
        local NewStr = ""
        local NumLen = string.len( StrNum )
        local Count = 0
        for i = NumLen, 1, -1 do
            if Count % 3 == 0 and Count ~= 0  then
                NewStr = string.format("%s,%s",string.sub( StrNum,i,i),NewStr) 
            else
                NewStr = string.format("%s%s",string.sub( StrNum,i,i),NewStr) 
            end
            Count = Count + 1
        end

        if point > 0 then
            --@desc 存在小数点，
            local strPoint = string.format( "%.2f", point )
            resultNum = string.format("%s%s",NewStr,string.sub( strPoint,2, string.len( strPoint ))) 
        else
            resultNum = NewStr
        end
    end
    
    return resultNum
end

function GoldSauserMainPanelDataWinItemVM:OnReset()

end

function GoldSauserMainPanelDataWinItemVM:OnBegin()

end

function GoldSauserMainPanelDataWinItemVM:OnEnd()

end

function GoldSauserMainPanelDataWinItemVM:OnShutdown()

end

return GoldSauserMainPanelDataWinItemVM
