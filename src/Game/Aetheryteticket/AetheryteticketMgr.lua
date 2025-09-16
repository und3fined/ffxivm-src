--[[
Date: 2024-8-15 9:31:25
LastEditors: leo
--]]

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local AetheryteticketDefine = require("Game/Aetheryteticket/AetheryteticketDefine")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local FuncCfg = require("TableCfg/FuncCfg")
local TransCfg = require("TableCfg/TransCfg")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local PWorldMgr = require("Game/PWorld/PWorldMgr")
local ProtoCS = require("Protocol/ProtoCS")
local AetheryteticketVM = require("Game/Aetheryteticket/AetheryteticketVM")
local ItemCfg = require("TableCfg/ItemCfg")
local RichTextUtil = require("Utils/RichTextUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local CondCfg = require("TableCfg/CondCfg")
local ConditionMgr = require("Game/Interactive/ConditionMgr")
local ProtoRes = require("Protocol/ProtoRes")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local CondType = ProtoRes.CondType

local LSTR = _G.LSTR
local FLOG_ERROR = _G.FLOG_ERROR

local AetheryteticketMgr = LuaClass(MgrBase)

function AetheryteticketMgr:OnInit()

end

function AetheryteticketMgr:OnBegin()
end

function AetheryteticketMgr:OnEnd()
end

function AetheryteticketMgr:OnShutdown()

end

function AetheryteticketMgr:OnRegisterNetMsg()

end

function AetheryteticketMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.BagUseItemSucc, self.OnBagUseItemSucc)
end

function AetheryteticketMgr:OnBagUseItemSucc(Params)
    if Params == nil then
        return
    end
    local Cfg = ItemCfg:FindCfgByKey(Params.ResID)
    if Cfg == nil then return end

    if (Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.MISCELLANY_AETHERYTETICKET) then
        self:OnUseAetherytetickeSuccess(Params.ResID)
    end

end

--- @type 当成功使用传送网格券
function AetheryteticketMgr:OnUseAetherytetickeSuccess(ResID)
    if UIViewMgr:IsViewVisible(UIViewID.BagMain) then
        UIViewMgr:HideView(UIViewID.BagMain)
    end

    if UIViewMgr:IsViewVisible(UIViewID.WorldMapUsePortal) then
        UIViewMgr:HideView(UIViewID.WorldMapUsePortal)
    end

    if UIViewMgr:IsViewVisible(UIViewID.WorldMapPanel) then
        UIViewMgr:HideView(UIViewID.WorldMapPanel)
    end

    if UIViewMgr:IsViewVisible(UIViewID.WorldMapTransferPanel) then
        UIViewMgr:HideView(UIViewID.WorldMapTransferPanel)
    end
end

--- @type 尝试使用传送券道具进行传送
function AetheryteticketMgr:TryUseAetheryteticke(Func, GID, Num, UseType, UseForm)
    local bCommAethery = #Func > 0
    local TranID
    if not bCommAethery then
        local ProfID = MajorUtil.GetMajorProfID()
        local Cfg = RoleInitCfg:FindCfgByKey(ProfID)
        if not Cfg then
            return
        end
        TranID = Cfg.HomePlace
    end

    if not TranID then
        TranID = Func[1]
    end
    
    local Cfg = TransCfg:FindCfgByKey(TranID)
    if Cfg == nil then
        FLOG_ERROR("TransCfs Is InVaild   TranID = %s", TranID)
        return
    end

    local function TrySendUseMsg()
        --[[if self:CheckIsOutDistance(Cfg) then
            MsgTipsUtil.ShowTips(LSTR(290001)) -- 已到达目标区域，请勿重复传送
            return
        end--]]

        _G.BagMgr:UseItem(GID, nil)
        -- _G.BagMgr:SendMsgUseItemReq(GID, Num, UseType, nil, UseForm)
    end

    local Message = Cfg.Question
    if Message ~= "" then
        Message = "\n"..Message                     -- 提 示                                                        -- 取 消        -- 使 用
        MsgBoxUtil.ShowMsgBoxTwoOp(self ,LSTR(10004), Message, TrySendUseMsg, nil, LSTR(10003), LSTR(290002), nil)
    else
        TrySendUseMsg()
    end
end

--- @type 检测是否走出了一定距离_范围太近不能传送
function AetheryteticketMgr:CheckIsOutDistance(TransCfgInst)
    local function Parse_Position(s)
        -- 初始化结果table
        local result = {}
        
        -- 去除不必要的字符并准备解析
        s = string.gsub(s, "[{}\"]", "") -- 移除大括号和双引号简化解析
        for pair in string.gmatch(s, '([^,]+)') do
            local key, value = string.match(pair, '(%u+):([-%d]+)')
            if key and value then
                result[key] = tonumber(value) -- 将值从字符串转换为数字
            end
        end
        
        return result
    end

    local CurMapID = TransCfgInst.MapID
    local BaseInfo = PWorldMgr.BaseInfo
    if BaseInfo.CurrMapResID == CurMapID then
        local Pos = TransCfgInst._Position
        local PosTab = Parse_Position(Pos)--assert(load("return " .. Pos))()
        local TargetLocation = _G.UE.FVector(PosTab.X, PosTab.Y, PosTab.Z)
        local Major = MajorUtil.GetMajor()
        local MajorLoc = Major:FGetActorLocation()
        if _G.UE.FVector.Dist(MajorLoc, TargetLocation) <= 500 then -- 临时后面改配置
            return true
        end
    end
    return false
end

--- @type 打开网格使用券页面
function AetheryteticketMgr:OpenAetheryteticketPanel()
    local AetheryteticketID = self:FilterAetheryteticketID()
    
    local Data = {}
    for _, v in pairs(AetheryteticketID) do
        local ResID = v
        local TmpData = {}
        local ItemNum = _G.BagMgr:GetItemNum(ResID)
        TmpData.ResID = ResID
        TmpData.OwnNum = string.format(LSTR(290003), ItemNum) -- 拥有：%s

        local Cfg = ItemCfg:FindCfgByKey(ResID)
        local CanUse = self:CheckUseCondition(ResID, false)
        -- 是否国防联军限制
        if ItemNum > 0 then
            if self:CheckGroupGrandCompanyLimit(ResID) then
                local RichText = RichTextUtil.GetText(LSTR(290004), "#d1906d") --   ( 军队不符 )
                TmpData.OwnNum = TmpData.OwnNum..RichText
            end
        end
        TmpData.Name = ItemCfg:GetItemName(ResID)
        --TmpData.bDisable = ItemNum <= 0 or not CanUse
        TmpData.bEnable = ItemNum > 0 and CanUse
        TmpData.IconColor = ItemNum <= 0 and "828282FF" or "FFFFFFFF"
        TmpData.UseTextColor = TmpData.bEnable and "FFFCF1FF" or "828282FF"
        if Cfg ~= nil then
            TmpData.IconPath = ItemCfg.GetIconPath(Cfg.IconID)
        end
        table.insert(Data, TmpData)
    end
    table.sort(Data, function(l, r) return l.ResID < r.ResID end)
    AetheryteticketVM:UpdateAetheryteticketList(Data)
    UIViewMgr:ShowView(UIViewID.WorldMapUsePortal)
end

--- @type 地图界面使用传送网使用权
function AetheryteticketMgr:OnUseBtnClickInMapPanel(ResID)
    -- 临时代码，后续在表格中增加禁止传送 2025-4-18
    if (_G.GoldSauserLeapOfFaithMgr ~= nil and _G.GoldSauserLeapOfFaithMgr:IsCurMapLeapOfFaith()) then
        local MsgID = 146078
        MsgTipsUtil.ShowTipsByID(MsgID)
        return
    end
    local Num = _G.BagMgr:GetItemNum(ResID)
    if Num == 0 then
        MsgTipsUtil.ShowTips(LSTR(290005)) -- 数量不足
        return
    end

    -- 出现不在同一个国防联军提示 --2025.4.2 将条件限制移至物品使用部分
    --[[if not self:CheckUseCondition(ResID, true) then
        return
    end--]]

	local Cfg = ItemCfg:FindCfgByKey(ResID)
	if Cfg then
		local FuncCfg = FuncCfg:FindCfgByKey(Cfg.UseFunc) --物品使用没有函数调用
        if FuncCfg ~= nil then
            local Func = FuncCfg.Func
            -- local TranID = Func[1].Value[1]
            local GID = _G.BagMgr:GetItemGIDByResID(ResID)
            self:TryUseAetheryteticke(Func[1].Value, GID, 1, 0, ProtoCS.ITEM_USE_FROM.ITEM_USE_FROM_MAP)
        end
    end
end

function AetheryteticketMgr:CheckUseCondition(ItemID, bShowErrorTips)
    if ItemID == nil then
		return true, {}
	end

	local Cfg = ItemCfg:FindCfgByKey(ItemID)
	if Cfg == nil then
		return true, {}
	end

	local Cond = CondCfg:FindCfgByKey(Cfg.UseCond) --物品状态/限制
	if Cond == nil then
		return true, {}
	end

    local bMajorDead = MajorUtil.IsMajorDead()
    if bMajorDead then
        return false, {}
    end

	local CondRlt, CondFailReasonList = ConditionMgr:CheckCondition(Cond, {}, bShowErrorTips)
    return CondRlt, CondFailReasonList
end

-- @type 条件原因时国防联军限制
function AetheryteticketMgr:CheckGroupGrandCompanyLimit(ItemID)
    local bIsSameAllied, CondFailReasonList = self:CheckUseCondition(ItemID, false)
    if not bIsSameAllied then
        for ReasonType, Value in pairs(CondFailReasonList) do
            if Value then
                if ReasonType == CondType.GrandCompanyLimit then
                    return true
                end        
            end
        end
    end
    return false
end

function AetheryteticketMgr:FilterAetheryteticketID()
    local IDTable = {}
    local Cfgs = ItemCfg:FindAllCfg(string.format("ItemType == %d", ProtoCommon.ITEM_TYPE_DETAIL.MISCELLANY_AETHERYTETICKET))
    for i = 1, #Cfgs do
        local Elem = Cfgs[i]
        local UseFuncID = Elem.UseFunc
        local FCfg = FuncCfg:FindCfgByKey(UseFuncID)
        if FCfg then
            local NeedValue = FCfg.Func[2].Value[1]
            if NeedValue ~= nil and NeedValue == 1 then -- 是否在地图传送券界面显示
                table.insert(IDTable, Elem.ItemID)
            end        
        end
    end
    return IDTable
end

return AetheryteticketMgr