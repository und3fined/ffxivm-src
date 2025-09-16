--
-- Author: ZhengJianChuan
-- Date: 2024-12-03 19:30
-- Description: 首充数据
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ActivityCfg = require("TableCfg/ActivityCfg")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ItemVM = require("Game/Item/ItemVM")
local OpsActivityFirstChargeRewardItemVM = require("Game/Ops/VM/OpsActivityFirstChargeRewardItemVM")
local ItemUtil = require("Utils/ItemUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local OpsActivityFirstChargeMgr = require("Game/Ops/OpsActivityFirstChargeMgr")
local ProtoCS = require("Protocol/ProtoCS")


---@class OpsActivityFirstChargePanelVM : UIViewModel
local OpsActivityFirstChargePanelVM = LuaClass(UIViewModel)

---Ctor
function OpsActivityFirstChargePanelVM:Ctor()
    self.RewardList = UIBindableList.New(OpsActivityFirstChargeRewardItemVM, {HideItemLevel = true, IsShowNumProgress = false,  IsShowSelectStatus = false})
    self.Title = ""
    self.SubTitle = ""
    self.Content = ""
    self.HelpID = 0
    self.RewardBtnText = ""
    self.RewardName = ""
    self.RewardDescVisible = false
    self.RewardID = nil
end

function OpsActivityFirstChargePanelVM:OnInit()

end

function OpsActivityFirstChargePanelVM:OnBegin()
end

function OpsActivityFirstChargePanelVM:OnEnd()
end

function OpsActivityFirstChargePanelVM:OnShutdown()
end

function OpsActivityFirstChargePanelVM:Process_text(text)
    local link_data = {}
    local replacements = {}
    
    -- 核心匹配替换逻辑
    local result = text:gsub("<linkid='(%d+)'>%[(.-)%]</>", function(id, content)
        table.insert(link_data, {id = id, content = content})
        table.insert(replacements, "%s")
        return "[%s]"  -- 立即替换为占位符
    end)
    
    -- 解构提取数据
    local linkids = {}
    local contents = {}
    for _, data in ipairs(link_data) do
        table.insert(linkids, data.id)
        table.insert(contents, data.content)
    end
    
    -- 清理残留方括号（处理非匹配内容）
    result = result:gsub("%[%s*]", "[]")
    
    return result, linkids, contents
end

-- 更新基本信息，死数据
function OpsActivityFirstChargePanelVM:UpdateBaseInfo()
    local Cfg =  ActivityCfg:FindCfgByKey(OpsActivityFirstChargeMgr:GetActivityID())
    if Cfg == nil then return end
    
    self.Title = Cfg.Title
    self.SubTitle = Cfg.SubTitle
    local Text =  Cfg.Info
    local Result, Ids, Texts = self:Process_text(Text)
    -- 生成超链接参数表
    local hyperlinks = {}
    for i = 1, math.max(#Texts, #Ids) do
        if Texts[i] and Ids[i] then
            hyperlinks[i] = RichTextUtil.GetHyperlink(
                Texts[i], 
                Ids[i], 
                nil, nil, nil, nil, nil, nil, "", nil
            )
        else
            hyperlinks[i] = ""  -- 处理缺失参数的情况
        end
    end

    -- 动态格式化字符串
    self.Content = string.format(_G.LSTR(Result), table.unpack(hyperlinks, 1, select("#", Result:gsub("%%s", ""))))
    self.HelpID = Cfg.ChinaActivityHelpInfoID
    self.RewardName = Cfg.Title
end

-- 更新奖励列表
function OpsActivityFirstChargePanelVM:UpdateRewardList()
    local Cfg = ActivityNodeCfg:FindCfgByKey(OpsActivityFirstChargeMgr:GetNodeID())
    if Cfg == nil then return end

    if (not table.is_nil_empty(Cfg.Rewards)) then
        -- self.RewardName = ItemUtil.GetItemName(Cfg.Rewards[1].ItemID)
        self.RewardID = Cfg.Rewards[1].ItemID
    end

    local Status = OpsActivityFirstChargeMgr:GetFirstChargerStatus() == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone
    local Status2 = OpsActivityFirstChargeMgr:GetFirstChargerStatus() == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet
    local ItemList = {}
    local Rewards = Cfg.Rewards or {}
    for _, v in ipairs(Rewards) do
        if v.ItemID and v.ItemID ~= 0 then
		    local Item = ItemUtil.CreateItem(v.ItemID, v.Num)
            Item.IsGet = false
            Item.IsGot = Status
            Item.BtnCheckVisible = ItemUtil.IsCanPreviewByResID(v.ItemID)
		    table.insert(ItemList, Item)
        end
    end

    self.RewardList:Clear()
    self.RewardList:UpdateByValues(ItemList)
end

-- 更新奖励按钮状态
function OpsActivityFirstChargePanelVM:UpdateRewardBtn()
    local Status = OpsActivityFirstChargeMgr:GetFirstChargerStatus()
    if Status == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
        self.RewardBtnText = _G.LSTR(900001)
    elseif Status == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
        self.RewardBtnText = _G.LSTR(900002)
    elseif Status == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
        self.RewardBtnText = _G.LSTR(900003)
    end
end

--要返回当前类
return OpsActivityFirstChargePanelVM