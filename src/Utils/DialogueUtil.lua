--
-- Author: chunfengluo
-- Date: 2022-7-22 15:21:12
-- Description:
--

local MajorUtil = require("Utils/MajorUtil")
local UTF8Util = require("Utils/UTF8Util")
local TimeUtil = require("Utils/TimeUtil")
local ColorUtil = require("Utils/ColorUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local MapUtil = require("Game/Map/MapUtil")
local MonsterCfg = require("TableCfg/MonsterCfg")
local NpcCfg = require("TableCfg/NpcCfg");
local ItemCfg = require("TableCfg/ItemCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local EobjCfg = require("TableCfg/EobjCfg")
local StoryDefine = require("Game/Story/StoryDefine")
local GoldSaucerCfg = require("TableCfg/GoldSaucerCfg")

local LSTR = _G.LSTR

---@class DialogueUtil
local DialogueUtil = {}

-- 标签列表，函数名称全部采用小写，在读取标签的时候用string.lower转换了一下，方便策划输入
DialogueUtil.FuncList = {
    ["plaintext"] = function(Text)
        -- return "<span outline=\"2;#ffffff00\">"..Text[1].."</>"
        return Text[1];
    end,

    -- 主角名称
    ["player"] = function()
        local Attr = MajorUtil.GetMajorAttributeComponent()
        if Attr ~= nil then
            return Attr.ActorName
        end
        return ""
    end,

    -- 根据主角性别选择文本
    ["swplayergender"] = function(params)
        local Attr = MajorUtil.GetMajorAttributeComponent()
        if Attr ~= nil then
            local Gender = Attr.Gender
            return params[Gender]
        end
        return ""
    end,

    -- 根据主角种族选择文本
    ["swrace"] = function(params)
        local Attr = MajorUtil.GetMajorAttributeComponent()
        if Attr ~= nil then
            -- 端游和手游的硌狮族和维埃拉族的RaceID是反的(7和8)，读取标签时交换两个RaceID的值
            local Race = 1
            if Attr.RaceID == 7 then
                Race = 8
            elseif Attr.RaceID == 8 then
                Race = 7
            elseif Attr.RaceID >= 1 and Attr.RaceID <= 6 then
                Race = Attr.RaceID
            end
            return params[Race]
        end
        return ""
    end,

    -- 根据主角种族选择文本
    ["chsswrace"] = function(params)
        return DialogueUtil.FuncList.swrace(params)
    end,

    -- 根据主角职业选择文本
    ["classname"] = function()
        local Attr = MajorUtil.GetMajorAttributeComponent()
            if Attr ~= nil then
            return RoleInitCfg:FindRoleInitProfName(Attr.ProfID)
        end
        return ""
    end,

    ["ifcomsea"] = function(params)
        return params[1]
    end,

    ["ifcomfst"] = function(params)
        return params[1]
    end,

    ["ifcomwil"] = function(params)
        return params[1]
    end,

    ["minicactpotterm"] = function(Color)
        local NeedColor = tostring(Color[1]) or "#d1906dFF"
        return RichTextUtil.GetText(tostring(_G.MiniCactpotMgr:GetCurTurm()), NeedColor)
    end,

    -- 根据怪物id显示怪物名称
    ["bnpcname"] = function(params)
        local CfgTable = MonsterCfg:FindCfgByKey(params[1])
        if (CfgTable == nil) then
            return ""
        else
            return CfgTable.Name
        end
    end,

    -- 根据npc id显示怪物名称
    ["eobjname"] = function(params)
        local CfgTable = EobjCfg:FindCfgByKey(params[1])
        if (CfgTable == nil) then
            return ""
        else
            return CfgTable.Name
        end
    end,

    -- 根据任务物品id显示物品名称
    ["eventitem"] = function(params)
        return DialogueUtil.FuncList.itemname(params)
    end,

    -- 根据物品id显示物品名称
    ["itemname"] = function(params)
        local CfgTable = ItemCfg:FindCfgByKey(params[1])
        if (CfgTable == nil) then
            return ""
        else
            local ItemName = ItemCfg:GetItemName(params[1])
            if params:Length() > 1 and params[2] ~= nil then
                return  RichTextUtil.GetText(ItemName, params[2])  -- "<span color=\"#"..params[2].."\">"..CfgTable.ItemName.."</>"
            end
            local Color = CfgTable.ItemColor
            local ColorHex = ColorUtil.GetItemHexColor(Color)
            return DialogueUtil.CreateStyledText(ItemName, "#"..ColorHex, "2;#0000007F")
        end
    end,

    -- 根据性别替换称呼
    ["swcallbygender"] = function ()
        local Attr = MajorUtil.GetMajorAttributeComponent()
        if Attr ~= nil then
            local Gender = Attr.Gender
            if Gender == 1 then
                return LSTR(10054)           ---"大哥哥"
            elseif Gender == 2 then
                return LSTR(10055)           ---"大姐姐"
            end
        end
        return ""
    end,

    -- 仙人仙彩获得了几等奖
    -- ["jumbocactlevel"] = function()
    --     return _G.JumboCactpotMgr:GetBestPrize()
    -- end,

    ["jumblottoryterm"] = function()
        return _G.JumboCactpotMgr:GetLottoryTerm()
    end,
    ["jumbocactterm"] = function()
        return _G.JumboCactpotMgr:GetTerm()
    end,

    ["jumblottorynum"] = function()
        return _G.JumboCactpotMgr:GetLottoryNum()
    end,
    
    ["jumbnewterm"] = function()
        return _G.JumboCactpotMgr:GetLottoryTerm() + 1
    end,

    ["jumbocactnum"] = function()
        return _G.JumboCactpotMgr:GetRemainumbCount()
    end,
    ["jumbolottoryname"] = function(params)
        return _G.JumboCactpotLottoryCeremonyMgr:GetLottoryPlayerName(params[1])
    end,
    ["jumbolottoryround"] = function()
        return _G.JumboCactpotLottoryCeremonyMgr:GetCurRaffleRound()
    end,
    ["jumbolottoryrewardnum"] = function(params)
        return _G.JumboCactpotLottoryCeremonyMgr:GetCurRoundRewardNum(params[1])
    end,



    -- 下一个机遇活动的名称
    ["activityname"] = function()
        return _G.GoldSauserMgr:GetNextActivityName()
    end,

    -- 下一个机遇活动的时间
    ["activitytime"] = function()
        return _G.GoldSauserMgr:GetNextActivityTime()
    end,

    -- 下一个机遇活动的地点
    ["activityloc"] = function()
        return _G.GoldSauserMgr:GetNextActivityLoc()
    end,

   -- 地图超链接
   ["maphyperlink"] = function(Params)
        local MapID = Params[1]
        local PosText = Params[2] .. " , " .. Params[3]
        local LinkID = tonumber(Params[4])
        local NpcID = tonumber(Params[5])

        local ShowText = (MapUtil.GetMapName(MapUtil.GetUIMapID(MapID)) or "" ) .. " ( " .. PosText .. " )"
        _G.MailMainVM:StoreMapHyperLink({ LinkID = LinkID, MapID = MapID, NpcID = NpcID, PosX = tonumber(Params[2]), PosY = tonumber(Params[3]) })
        return RichTextUtil.GetHyperlink(ShowText, LinkID, "#4d85b4" )
    end,

    -- 邮件文本中任务的解析
    ["mailquesthyperlink"] = function(Params)
        local LinkID = Params[1]
        local ChapterID = Params[2]
        local ShowText = Params[3]
        _G.MailMainVM:StoreMapHyperLink({ LinkID = tonumber(LinkID), ChapterID = tonumber(ChapterID) })
        return RichTextUtil.GetHyperlink(ShowText or "", LinkID, "#4d85b4" )
    end,

    -- 幻卡大赛名称
    ["tourneyname"] = function()
        return _G.MagicCardTourneyMgr:GetTourneyName()
    end,
    
    -- 下次幻卡大赛倒计时
    ["tourneycd"] = function()
        return _G.MagicCardTourneyMgr:GetNextTourneyCD()
    end,

    -- FateID 换名字
    ["fateid"] = function(Params)
        local FateID = Params[1]
        local FateCfg = _G.FateMgr:GetFateCfg(tonumber(FateID))
        if FateCfg == nil then
            return LSTR(10050)           --"未知FATE"
        end
        return FateCfg.Name
    end,

    -- fate结果文本转换
    ["success"] = function(Params)
        local Ret = Params[1]
        if Ret == "true" then
            return LSTR(10051)           -- "成功"
        elseif Ret == "false" then
            return LSTR(10052)           -- "失败"
        end
        return LSTR(10053)          --- 未知结果
    end,
    
    ["racename"] = function()
        return MajorUtil.GetMajorRaceName()
    end,

    ["chscomrankfst"] = function()
        return _G.CompanySealMgr:GetGrandCompanyRankName()
    end,

    ["chscomranksea"] = function()
        return _G.CompanySealMgr:GetGrandCompanyRankName()
    end,

    ["chscomrankwil"] = function()
        return _G.CompanySealMgr:GetGrandCompanyRankName()
    end,

    ["mychocobo"] = function()
        return _G.BuddyMgr:GetBuddyName()
    end,

    -- 邮件附件列表解析    “item1:num,item2:num,item3:num”
    ["attachmentlist"] = function(Params)
        local RetStr = " "
        for i = 1, Params:Length() do
            local ItemStr = Params[i]
            local ItemArr = string.split(ItemStr, ':')
            local CfgTable = ItemCfg:FindCfgByKey(ItemArr[1])
            if (CfgTable ~= nil) then
                RetStr = RetStr .. CfgTable.ItemName .. "x" .. tostring(ItemArr[2] or "")  .. " "
            end
        end
        return RetStr
    end,

    ["totalgameduration"] = function()
        return _G.MentorMgr:GetTotalGameDurationText()
    end,

    -- 金碟主界面
    ["goldsausermaineventtasknum"] = function(Params)
        local EvtID = Params[1]
        if EvtID then
            local Cfg = GoldSaucerCfg:FindCfgByKey(EvtID)
            if Cfg then
                local Num = Cfg.TaskNum or 0
                if Num > 0 then
                    return tostring(Num)
                else
                    return ""
                end
                
            end
        end
        return ""
    end,

    ["goldsausermaineventtaskparam"] = function(Params)
        local EvtID = Params[1]
        if EvtID then
            local Cfg = GoldSaucerCfg:FindCfgByKey(EvtID)
            if Cfg then
                local Num =  Cfg.TaskParam or 0
                if Num > 0 then
                    return tostring(Num)
                else
                    return ""
                end
            end
        end
        return ""
    end,

    ["ampm"] = function(Params)
        local morn = Params[1]
        local day = Params[2]
        local eve = Params[3]
        local Hour = TimeUtil.GetAozyHour()
        if Hour > 17 or Hour < 4 then
            return eve
        elseif Hour >= 4 and Hour < 12 then
            return morn
        elseif Hour >= 12 and Hour <= 17 then
            return day
        end
    end,

    ["ampm_game"] = function(Params)
        return DialogueUtil.FuncList.ampm(Params)
    end,

    ["ifcomseaorn"] = function(Params)
        local CompoanyInfo = _G.CompanySealMgr:GetCompanySealInfo()
        return (CompoanyInfo.GrandCompanyID == 1) and Params[1] or Params[2]
    end,

    ["ifcomfstorn"] = function(Params)
        local CompoanyInfo = _G.CompanySealMgr:GetCompanySealInfo()
        return (CompoanyInfo.GrandCompanyID == 2) and Params[1] or Params[2]
    end,

    ["ifcomwilorn"] = function(Params)
        local CompoanyInfo = _G.CompanySealMgr:GetCompanySealInfo()
        return (CompoanyInfo.GrandCompanyID == 3) and Params[1] or Params[2]
    end,
}

function DialogueUtil.HandlePlainTextStyle(Text)
    --return "<span outline=\"2;#ffffff00\">"..Text.."</>"
    return Text
end

function DialogueUtil.CreateStyledText(Text, Color, Outline)
    --return "<span color=\""..Color.."\">"..Text.."</>"
    return "<span color=\""..Color.."\" outline=\""..Outline.."\">"..Text.."</>"
end

function DialogueUtil.ParseLabel(Text)
    if Text == nil then return "" end
    local Text1 = string.gsub(Text, "\\([<>])", "%1")
    return _G.UE.UDialogUtil.ParseLabel(Text1)
end

function DialogueUtil.GetAutoPlayTime(RichTextLen, SpeedLevel)
    if (RichTextLen == nil) or (SpeedLevel == nil) then return 0 end
    local SpeedData = StoryDefine.SpeedLevelData[SpeedLevel] or 1
    return RichTextLen * 0.09 * SpeedData
end


return DialogueUtil


