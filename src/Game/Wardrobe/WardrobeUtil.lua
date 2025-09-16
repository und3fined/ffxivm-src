---
--- Author: ZhengJianChuan
--- DateTime: 2024-02-29 15:55
--- Description:
---
---
local MajorUtil = require("Utils/MajorUtil")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local WardrobeDefine = require("Game/Wardrobe/WardrobeDefine")
local CondCfg = require("TableCfg/CondCfg")
local ClosetCfg = require("TableCfg/ClosetCfg")
local ClosetClassifyCfg = require("TableCfg/ClosetClassifyCfg")
local ClosetCharismCfg = require("TableCfg/ClosetCharismCfg")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ProfClassCfg = require("TableCfg/ProfClassCfg")
local DyeColorCfg = require("TableCfg/DyeColorCfg")
local BagMgr = require("Game/Bag/BagMgr")
local ProfMgr = require("Game/Profession/ProfMgr")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local BitUtil = require("Utils/BitUtil")
local ItemCondType = ProtoRes.CondType
local LSTR = _G.LSTR
local BitUtil = require("Utils/BitUtil")
local ProfUtil = require("Game/Profession/ProfUtil")

local WardrobeUtil = {
}

-- 解析染色数据
function WardrobeUtil.ParseStainByte(Bytes)
    local ByteArray = BitUtil.StringToByteArray(Bytes)
    local baseID = 0
    local ColorIDList = {}
    for _, Byte in ipairs(ByteArray) do
        if Byte ~= 0 then
            for Index = 0, 7 do
                if BitUtil.IsBitSet(Byte, Index, false) then
                    local ColorID = baseID + Index
                    table.insert(ColorIDList, ColorID)
                end
            end
        end
        baseID = baseID + 8
    end
    return ColorIDList
end 

-- 解析染色区域对应分片数据
function WardrobeUtil.ParseSectionIDList(AppID, SocketID)
    local SectionList = {}
	local AppCfg = ClosetCfg:FindCfgByKey(AppID)
	if AppCfg == nil then
		return {}
	end
	local StainAeraData
	for index, v in ipairs(AppCfg.StainAera) do
		if index == SocketID then
			StainAeraData = AppCfg.StainAera[SocketID]
			break
		end
	end
	if StainAeraData ~= nil then
		SectionList = _G.StringTools.StringSplit(StainAeraData.List, ",")
	end
    return SectionList
end

function WardrobeUtil.IsAppRegionDye(AppID)
    local AppCfg = ClosetCfg:FindCfgByKey(AppID)
    if AppCfg == nil then
		_G.FLOG_INFO(string.format("WardrobeUtil.ParseSectionIDList AppCfg Is nil  %s", tostring(AppID)))
		return false
	end

    for index, v in ipairs(AppCfg.StainAera) do
        if v.List ~= "" then
            return true
        end
    end

    return false
end

function WardrobeUtil.IsDyeColorRegionDye(StainAera)
    if table.is_nil_empty(StainAera) then
        return false
    end

    for index, v in ipairs(StainAera) do
        if v.ColorID ~= 0 then
            return true
        end
    end

    return false
end

function WardrobeUtil.GetRegionDyeColor(StainAera, SocketID)
    if table.is_nil_empty(StainAera) then
        return  0
    end

    for index, v in ipairs(StainAera) do
        if SocketID == v.ID then
            return v.ColorID
        end
    end
    return 0
end

-- 获取多区域染色内部同一种颜色
function WardrobeUtil.GetUnifyRegionDyeColor(AppID, StainAera)
    local Color = nil
    if table.is_nil_empty(StainAera) then
        return  0
    end

    local Cfg = ClosetCfg:FindCfgByKey(AppID)
    if  Cfg == nil then
        return 0
    end

    local TempStainAera = {}
    for index, v in ipairs(Cfg.StainAera) do
        if v.List ~= "" and v.Ban ~= 1 then
            table.insert(TempStainAera, v)
        end
    end

    if #TempStainAera > #StainAera then
        return 0
    end

    for index, v in ipairs(StainAera) do
        if v.Ban ~= 1 then
            if Color == nil then
                Color = v.ColorID
            end
            if Color ~= v.ColorID or v.ColorID == 0  then
                return 0
            end
        end
    end

    if Color == nil then
        return 0
    end

    return Color
end

function WardrobeUtil.GetRegionDye(AppID, RegionDye)
    local TempStainAera = {}
    local CCfg = ClosetCfg:FindCfgByKey(AppID)
	if CCfg ~= nil and CCfg.StainAera ~= nil then
		for index, v in ipairs(CCfg.StainAera) do
            if v.Ban ~= 1 and v.List ~= "" then
			    table.insert(TempStainAera, {ID = index, ColorID = 0})
            end
		end
        for _, value in ipairs(RegionDye) do
		    for index , v in ipairs(TempStainAera) do
                if v.ID == value.ID then
                    TempStainAera[index].ColorID = value.ColorID
                end
            end
		end
	end
    return TempStainAera
end

--- 十进制转16进制色值字符串
---@param Value number@ 十进制数值
---@return string 16进制色值字符串
function WardrobeUtil.Dec2HexColor(Value)
    if Value == nil then
        return ""
    end
    local DecStr = tostring(Value)
    return string.format("%06X", DecStr) .. "ff"
end

function WardrobeUtil.GetColor(ColroID)
    local ColorCfg = DyeColorCfg:FindCfgByKey(ColroID)
    if ColorCfg == nil then
        return ""
    end
    return  WardrobeUtil.Dec2HexColor(ColorCfg.Color)
end

---@return string 返回菜单的的默认装备icon
function WardrobeUtil.GetEquipmentDefaultIcon(EquipmentID)
    local Cfg = ClosetClassifyCfg:FindCfgByKey(EquipmentID)
    return (Cfg == nil or Cfg.Icon == nil) and "" or Cfg.Icon
end

function WardrobeUtil.GetEquipmentDefaultSelectIcon(EquipmentID)
    local Cfg = ClosetClassifyCfg:FindCfgByKey(EquipmentID)
    return (Cfg == nil or Cfg.SelectIcon == nil) and "" or Cfg.SelectIcon
end


---@return string 返回菜单列表的外观icon
function WardrobeUtil.GetEquipmentAppearanceIcon(AppearanceID)
    local IsSpecial = WardrobeUtil.GetIsSpecial(AppearanceID)
    local ECfg = EquipmentCfg:FindAllCfgByAppearanceID(AppearanceID)
    if table.is_nil_empty(ECfg) then
        return ""
    end

    return UIUtil.GetIconPath(ItemUtil.GetItemIcon(IsSpecial and WardrobeUtil.GetUnlockCostItemID(AppearanceID) or ECfg[1].ID))
end

---@return string 返回外观名称
function WardrobeUtil.GetEquipmentAppearanceName(AppearanceID)
    local IsSpecial = WardrobeUtil.GetIsSpecial(AppearanceID)
    local ECfg = EquipmentCfg:FindAllCfgByAppearanceID(AppearanceID)
    if table.is_nil_empty(ECfg) then
        return ""
    end

    local Cfg = ItemCfg:FindCfgByKey(IsSpecial and WardrobeUtil.GetUnlockCostItemID(AppearanceID) or ECfg[1].ID)

    if Cfg == nil then
        return ""
    end

    return Cfg.ItemName
end

---@return Part 
function WardrobeUtil.GetPartByAppearanceID(AppearanceID)
    local ECfg = EquipmentCfg:FindAllCfgByAppearanceID(AppearanceID)
    if table.is_nil_empty(ECfg) then
        return
    end

    return ECfg[1].Part
end

---@param ProfID number@职业ID
---@return 返回收藏界面里的item图标
function WardrobeUtil.GetCollectIconByProfID(ProfID)
    if WardrobeDefine.ProfInfo[ProfID] ~= nil then
        return WardrobeDefine.ProfInfo[ProfID].CollectIcon
    end
    return
end

---@return boolean 返回是否是特殊外观
function WardrobeUtil.GetIsSpecial(AppID)
    local Cfg = ClosetCfg:FindCfgByKey(AppID)
    if Cfg ~= nil and Cfg.Special ~= nil then
        return Cfg.Special == 1
    end
    return false
end

---@return int 返回解锁外观消耗道具ID
function WardrobeUtil.GetUnlockCostItemID(AppID)
    local Cfg = ClosetCfg:FindCfgByKey(AppID)
    if Cfg ~= nil and Cfg.UnlockCostItemID ~= nil then
        return Cfg.UnlockCostItemID or 0
    end
    return 0
end

---@return int 返回解锁外观消耗道具数量
function WardrobeUtil.GetUnlockCostItemNum(AppID)
    local Cfg = ClosetCfg:FindCfgByKey(AppID)
    if Cfg ~= nil and Cfg.UnlockCostItemNum ~= nil then
        return Cfg.UnlockCostItemNum
    end
    return 0
end

function WardrobeUtil.GetClosetCfgEquipIDByAppearanceID(AppearanceID)
    local Cfg = ClosetCfg:FindCfgByKey(AppearanceID)
    if Cfg ~= nil  then
        return Cfg.EquipID
    end
    return 0
end

---@return table<int> 返回成就idList
function WardrobeUtil.GetAchievementIDList(AppID)
    local Cfg = ClosetCfg:FindCfgByKey(AppID)
    if Cfg ~= nil and not table.is_nil_empty(Cfg.AchievementID) then
        return Cfg.AchievementID
    end
    return {}
end

---@return boolean 是否有背包里解锁的外观ID(不需要判断棱晶)
function WardrobeUtil.JudgeUnlockAppearanceWithouItem(AppID)
    -- 传奇武器可以直接进入解锁界面
    if not table.is_nil_empty(WardrobeUtil.GetAchievementIDList(AppID)) then
        return true
    else
        return WardrobeUtil.GetIsBagOwnAppearanceEquipment(AppID)
    end
end

---@return boolean 是否有背包里解锁的外观ID(需要判断棱晶)
function WardrobeUtil.JudgeUnlockAppearanceItem(AppID)
    -- 传奇武器可以直接进入解锁界面
    if not table.is_nil_empty(WardrobeUtil.GetAchievementIDList(AppID)) then
        return true
    else
        if WardrobeUtil.GetIsSpecial(AppID) then
            return WardrobeUtil.GetIsBagOwnAppearanceEquipment(AppID)
        else
            return WardrobeUtil.GetIsBagOwnAppearanceEquipment(AppID) and BagMgr:GetItemNum(WardrobeUtil.GetUnlockCostItemID(AppID)) > 0
        end
    end
end

---@return boolean 背包里是否拥有的同模装备列表
function WardrobeUtil.GetIsBagOwnAppearanceEquipment(AppID)
    local EquipmentCfgs = EquipmentCfg:FindAllCfgByAppearanceID(AppID)
    if EquipmentCfgs == nil then
        return false
    end
    
    -- 特殊外观判断的是道具
    if WardrobeUtil.GetIsSpecial(AppID) then
        if BagMgr:GetItemNum(WardrobeUtil.GetUnlockCostItemID(AppID)) > 0 then            
            return true
        end
    else
        local EquipmentCfgs = EquipmentCfg:FindAllCfgByAppearanceID(AppID)
        for _, v in ipairs(EquipmentCfgs) do
            local ItemNum = BagMgr:GetItemNum(v.ID) + _G.EquipmentMgr:GetEquipedItemNum(v.ID)
            if ItemNum > 0 then            
                return true
            end
        end
    end

    return false
end

---@return table 背包里拥有的同模装备列表
function WardrobeUtil.GetBagOwnAppearanceEquipmentList(AppID)
    local Ret = {}
    if WardrobeUtil.GetIsSpecial(AppID) then
        if BagMgr:GetItemNum(WardrobeUtil.GetUnlockCostItemID(AppID)) > 0 then
            local Item = BagMgr:GetItemByResID(WardrobeUtil.GetUnlockCostItemID(AppID))
            if Item ~= nil then
                table.insert(Ret, Item)
            end
        end
    else
        local EquipmentCfgs = EquipmentCfg:FindAllCfgByAppearanceID(AppID)
        if  not table.is_nil_empty(EquipmentCfgs) then
            for _, v in ipairs(EquipmentCfgs) do
                local Item = BagMgr:GetItemByResID(v.ID)
                local EquipedItem = _G.EquipmentMgr:GetEquipedItemByResID(v.ID) 
                if Item then
                    table.insert(Ret, Item)
                end
                if EquipedItem then
                    table.insert(Ret, EquipedItem)
                end
            end
        end
    end
    return Ret
end


---@return table 返回同模装备列表
function WardrobeUtil.GetSameAppearanceEquipmentList(ID)
    local Ret = {}
    local EquipmentCfgs = EquipmentCfg:FindAllCfgByAppearanceID(ID)
    if not table.is_nil_empty(EquipmentCfgs) then
        for _, v in ipairs(EquipmentCfgs) do
            table.insert(Ret, v.ID)
        end
    end

    return Ret
end

---@return ProtoCommon.role_gender 获取客户端性别条件
function WardrobeUtil.GetClientGenderCond(UseCondID)
    local CondCfg = CondCfg:FindCfgByKey(UseCondID)
    if CondCfg == nil then
        return ProtoCommon.role_gender.GENDER_UNKNOWN
    end

    for _, Cond in pairs(CondCfg.Cond) do
        if Cond.Type == ItemCondType.GenderLimit then
            return Cond.Value[1]
        end
    end

    return ProtoCommon.role_gender.GENDER_UNKNOWN
end

---@return boolean 判断是否满足种族条件
function WardrobeUtil.JudgeRaceCond(RaceCond)
    if RaceCond == 0 then
        return true
    end

    return RaceCond == MajorUtil.GetMajorRaceID()
end

---@return ProtoCommon.race_type  获取客户端种族条件
function WardrobeUtil.GetClientRaceCond(UseCondID)
    local CondCfg = CondCfg:FindCfgByKey(UseCondID)
    if CondCfg == nil then
        return ProtoCommon.race_type.RACE_TYPE_NULL
    end

    for _, Cond in pairs(CondCfg.Cond) do
        if Cond.Type == ItemCondType.RaceLimit then
            return Cond.Value[1]
        end
    end

    return ProtoCommon.race_type.RACE_TYPE_NULL
end

---@return string 返回种族条件
function WardrobeUtil.GetRaceCondText(RaceLimit)
    if RaceLimit == 0 then
        return LSTR(1080014), ProtoCommon.race_type.RACE_TYPE_NULL
    end
  
    return ProtoEnumAlias.GetAlias(ProtoCommon.race_type, RaceLimit), RaceLimit
end

--- 职业分类数据
function WardrobeUtil.GetClassTypeData()
    local ClassTypeData = WardrobeDefine.ClassTypeData
    if not next(ClassTypeData) then
        local RoleInitCfg = RoleInitCfg:FindAllCfg()
        for i, v in ipairs(RoleInitCfg) do
            if not WardrobeDefine.ClassTypeData[v.Class] then
                WardrobeDefine.ClassTypeData[v.Class] = {}
            end

            table.insert(WardrobeDefine.ClassTypeData[v.Class], v.Prof)
        end
    end

    return WardrobeDefine.ClassTypeData
end

local function GetBelongClassType(ProfTableCondition)
    local BelongData = {}
    local ClassTypeData = WardrobeUtil.GetClassTypeData()
    for ClassType, TypeData in ipairs(ClassTypeData) do
        local IsAllBelong = true
        for i, v in ipairs(TypeData) do
            local Level = MajorUtil.GetMajorLevelByProf(v)
            if not ProfTableCondition[v] or not Level then
                IsAllBelong = false
                break
            end
        end

        if IsAllBelong then
            BelongData[ClassType] = true
        end
    end

    return BelongData
end

---@return string 返回职业条件
function WardrobeUtil.GetSimpleProfCondText(ProfTable, ClassLimitList)
    --- 判断职业条件是否达成
    local IsCheck = WardrobeUtil.JudgeProfCond(ProfTable, ClassLimitList)
    if not IsCheck then
        return LSTR(1080015)
    end

    if (table.is_nil_empty(ProfTable) or ProfTable[1] == 0) and (table.is_nil_empty(ClassLimitList) or ClassLimitList[1] == 0 ) then
        return _G.LSTR(1080016)
    end

    local CurProfID = MajorUtil.GetMajorProfID() 

    for _, v in ipairs(ClassLimitList) do
        if v ~= 0 and ProfMgr.CheckProfClass(CurProfID, v) and v < 8 then
            return ProtoEnumAlias.GetAlias(ProtoCommon.class_type, v)
        end
    end
 
    local ProfTableCondition = {}
    for i, v in ipairs(ProfTable) do
        ProfTableCondition[v] = 1
    end

    local BelongClassData = GetBelongClassType(ProfTableCondition)
    if next(BelongClassData) then
        for i, _ in ipairs(BelongClassData) do
            return ProtoEnumAlias.GetAlias(ProtoCommon.class_type, i)
        end
    else
        local MajorProfID = MajorUtil:GetMajorProfID()
        return RoleInitCfg:FindRoleInitProfName(MajorProfID)
    end

    return ""
end

function WardrobeUtil.GetMajorUnlockProfList()
    local RoleDetail = _G.ActorMgr:GetMajorRoleDetail()
    if nil == RoleDetail then
        return
    end
    local ProfList = (RoleDetail.Prof or {}).ProfList
    if nil == ProfList then
        return
    end
    local LockList = {}
    local ProfType = ProtoCommon.prof_type
    for _, v in pairs(ProfType) do
        local bAdvancedProf = ProfUtil.IsAdvancedProf(v)
        if not bAdvancedProf then
            local AdvancedProfID = ProfUtil.GetAdvancedProf(v)
            if ProfList[v] == nil and ProfList[AdvancedProfID] == nil then
                LockList[v] = true
            end
        end
    end

    for k, _ in pairs(ProfList) do
        LockList[k] = true
    end

    return LockList
end

---@return string 返回职业要求所有职业
function WardrobeUtil.GetDetailProfCondText(ProfTable, ClassLimit)
    if (table.is_nil_empty(ProfTable) or ProfTable[1] == 0) and (table.is_nil_empty(ClassLimit) or ClassLimit[1] == 0 ) then
        return _G.LSTR(1080016)
    end

    local RetProfTable = {}
    if #ClassLimit > 0 then
        for i = 1 , #ClassLimit do
            local Cfg = ProfClassCfg:FindCfgByKey(ClassLimit[i])
            if Cfg ~= nil then
                for index, subProf in ipairs(Cfg.Prof) do
                    if not table.contain(RetProfTable, subProf) then
                        table.insert(RetProfTable, subProf)
                    end
                end
            end
        end
    end

    if #ProfTable > 0 then
        for i = 1, #ProfTable do
            if not table.contain(RetProfTable, ProfTable[i]) then
                table.insert(RetProfTable, ProfTable[i])
            end
        end
    end

    table.sort(RetProfTable, function(a, b) return  a < b end)
    local Result = {}
    local exists = {}  -- 哈希表用于O(1)复杂度查重
    for _, profID in ipairs(RetProfTable) do
        local Cfg = RoleInitCfg:FindCfgByKey(profID)
        if Cfg then
            -- 处理有进阶职业的情况
            if Cfg.AdvancedProf and Cfg.AdvancedProf ~= 0 then
                local advanceID = Cfg.AdvancedProf
                local isAdvanceActive = MajorUtil.GetMajorLevelByProf(advanceID) ~= nil
                local targetID = isAdvanceActive and advanceID or profID
            
                if not exists[targetID] then
                    exists[targetID] = true
                    table.insert(Result, targetID)
                end
            
            -- 处理无进阶职业的情况
            else
                local NNCfg = RoleInitCfg:FindProfForPAdvance(profID)
                local targetID = nil
            
                -- 无基职直接使用当前职业
                if not NNCfg then
                    targetID = profID
                -- 有基职判断激活状态
                else
                   -- 有基职判断激活状态, 判断一下职业里还有重复的值
                   local isSpecialActive = MajorUtil.GetMajorLevelByProf(profID) ~= nil
                   -- 特职没有激活， 如果后面没有基值的，那就直接特职
                   if not isSpecialActive then
                       if not table.contain(RetProfTable, NNCfg.Prof) then
                           targetID = profID
                       else
                           targetID = NNCfg.Prof
                       end
                   else
                       targetID = isSpecialActive and profID
                   end
                end
            
                if targetID ~= nil and not exists[targetID] then
                    exists[targetID] = true
                    table.insert(Result, targetID)
                end
            end
        end
    end

    local ProfLimitDes = ""
    if #Result > 0 then
        local ProfNames = {}
        for i = 1, #Result do
            if _G.EquipmentMgr:GetProfName(Result[i]) then
                table.insert(ProfNames, _G.EquipmentMgr:GetProfName(Result[i]))
            end
        end
        ProfNames = table.concat(ProfNames, "、", 1, #ProfNames)
        ProfLimitDes = ProfNames
    end
    local Title = RichTextUtil.GetText(LSTR(1080017), "D1BA8EFF")
    ProfLimitDes = string.format("%s\n%s", Title, ProfLimitDes) 
    return ProfLimitDes

end

---@return boolean 是否显示职业详情
function WardrobeUtil.GetDetailProfVisible(ProfTable, ClassLimit)
    if (table.is_nil_empty(ProfTable) or ProfTable[1] == 0) and (table.is_nil_empty(ClassLimit) or ClassLimit[1] == 0 ) then
        return false
    end

    local RetProfTable = {}
    if #ClassLimit > 0 then
        for i = 1 , #ClassLimit do
            local Cfg = ProfClassCfg:FindCfgByKey(ClassLimit[i])
            if Cfg ~= nil then
                for index, subProf in ipairs(Cfg.Prof) do
                    if not table.contain(RetProfTable, subProf) then
                        table.insert(RetProfTable, subProf)
                    end
                end
            end
        end
    end

    if #ProfTable > 0 then
        for i = 1, #ProfTable do
            if not table.contain(RetProfTable, ProfTable[i]) then
                table.insert(RetProfTable, ProfTable[i])
            end
        end
    end

    table.sort(RetProfTable, function(a, b) return  a < b end)
    local Result = {}
    local exists = {}  -- 哈希表用于O(1)复杂度查重
    for _, profID in ipairs(RetProfTable) do
        local Cfg = RoleInitCfg:FindCfgByKey(profID)
        if Cfg then
            -- 处理有进阶职业的情况
            if Cfg.AdvancedProf and Cfg.AdvancedProf ~= 0 then
                local advanceID = Cfg.AdvancedProf
                local isAdvanceActive = MajorUtil.GetMajorLevelByProf(advanceID) ~= nil
                local targetID = isAdvanceActive and advanceID or profID
            
                if not exists[targetID] then
                    exists[targetID] = true
                    table.insert(Result, targetID)
                end
            
            -- 处理无进阶职业的情况
            else
                local NNCfg = RoleInitCfg:FindProfForPAdvance(profID)
                local targetID = nil
                -- 无基职直接使用当前职业
                if not NNCfg then
                    targetID = profID
                else
                    -- 有基职判断激活状态, 判断一下职业里还有重复的值
                    local isSpecialActive = MajorUtil.GetMajorLevelByProf(profID) ~= nil
                    -- 特职没有激活， 如果后面没有基值的，那就直接特职
                    if not isSpecialActive then
                        if not table.contain(RetProfTable, NNCfg.Prof) then
                            targetID = profID
                        else
                            targetID = NNCfg.Prof
                        end
                    else
                        targetID = isSpecialActive and profID
                    end
                end
            
                if targetID ~= nil and not exists[targetID] then
                    exists[targetID] = true
                    table.insert(Result, targetID)
                end
            end
        end
    end
    return not (table.is_nil_empty(Result) or #Result == 1)
end

---@return string 返回等级条件
function WardrobeUtil.GetLevelCondText(LevelCond)
    local Level = LevelCond
    if Level == 0 or type(Level) ~= "number" then
        return LSTR(1080018)
    end
    
    return string.format(LSTR(1080019), tonumber(Level))
end

---@return boolean 判断是否满足性别条件
function WardrobeUtil.JudgeGenderCond(MajorGenderCond)

    local MajorGender = MajorUtil.GetMajorGender()

    if MajorGenderCond == ProtoCommon.role_gender.GENDER_UNKNOWN or MajorGenderCond == ProtoCS.GenderLimit.GENDER_ALL then
        return true
    end

    return MajorGender == MajorGenderCond
end

---@return string 返回性别条件
function WardrobeUtil.GetGenderCondText(MajorGender)
    if MajorGender ~= ProtoCommon.role_gender.GENDER_MALE and MajorGender ~= ProtoCommon.role_gender.GENDER_FEMALE then
        return LSTR(1080020)
    else
        return MajorGender ~= ProtoCommon.role_gender.GENDER_MALE and LSTR(1080021) or LSTR(1080022)
    end
end


---@return boolean 判断是否满足职业条件
function WardrobeUtil.JudgeProfCond(ProfTable, ClassLimitList)

    if (table.is_nil_empty(ProfTable) or ProfTable[1] == 0) and (table.is_nil_empty(ClassLimitList) or ClassLimitList[1] == 0) then
        return true
    end

    local CurProfID = MajorUtil.GetMajorProfID()
    for _, v in ipairs(ClassLimitList) do
        if v ~= 0 then
            if ProfMgr.CheckProfClass(CurProfID, v) then
                return true
            end
        end
    end

    for i = 1, #ProfTable do
        local Prof = ProfTable[i]
        local CurProfID = MajorUtil.GetMajorProfID()
        if Prof == CurProfID and Prof ~= 0 then
            return true
        end 
    end

    return false
end

---@return boolean 判断是否满足等级条件
function WardrobeUtil.JudgeLevelCond(LevelCond)
    local ProfID = MajorUtil.GetMajorProfID() 
    local ProfLevel = MajorUtil.GetMajorLevelByProf(ProfID)
    return ProfLevel >= LevelCond
end

---@return number 转换成职业,判断需要满足多少个职业
function WardrobeUtil.ConvertProfCondNum(ProfCond)
    return table.is_nil_empty(ProfCond) and 0 or #ProfCond
end

---@return boolean 物品是否能染色
function WardrobeUtil.GetAppearanceCanBeDyed(AppearanceID)
    local EquipmentCfgs = EquipmentCfg:FindAllCfgByAppearanceID(AppearanceID)
    if not table.is_nil_empty(EquipmentCfgs) then
        for _, v in ipairs(EquipmentCfgs) do
            if v.CanBeDyed == 1 then
                return true
            end
        end
    end

    return false
end


function WardrobeUtil.GetMajorAppearanceAndColorByPartID(PartID)
    local RoleSimple = MajorUtil.GetMajorRoleSimple()
    if RoleSimple and RoleSimple.Avatar and RoleSimple.Avatar.EquipList then
        local EquipList = RoleSimple.Avatar.EquipList
        for idx = 1, #EquipList do
            local Equip = EquipList[idx]
            if Equip.Part == PartID then
               return Equip.ResID, Equip.ColorID, Equip.RandomID
            end
        end
    end
    return 0,0
end

function WardrobeUtil.GetEquipIDByAppearanceID(AppearanceID)
    -- local ECfg = EquipmentCfg:FindAllCfgByAppearanceID(AppearanceID)
	-- if not table.is_nil_empty(ECfg) then
		-- return WardrobeUtil.GetIsSpecial(AppearanceID) and WardrobeUtil.GetClosetCfgEquipIDByAppearanceID() or ECfg[1].ID
	-- end
    return WardrobeUtil.GetClosetCfgEquipIDByAppearanceID(AppearanceID)
end




function WardrobeUtil.GetPartIDByAppearanceID(AppearanceID)
    local ECfg = EquipmentCfg:FindAllCfgByAppearanceID(AppearanceID)
	if not table.is_nil_empty(ECfg) then
		return ECfg[1].Part
	end
end


-- 获取外观的PartSubID
function WardrobeUtil.GetPartSubIDByAppearanceID(AppearanceID)
    local ECfg = EquipmentCfg:FindAllCfgByAppearanceID(AppearanceID)
	if not table.is_nil_empty(ECfg) then
		return ECfg[1].ClosetPartSubID
	end
    return ""
end

function WardrobeUtil.GetWeaponEquipIDByAppearanceID(AppID)
    return WardrobeUtil.GetIsSpecial(AppID) and WardrobeUtil.GetUnlockCostItemID(AppID) or  WardrobeUtil.GetEquipIDByAppearanceID(AppID)
end

function WardrobeUtil.IsAppearanceByItemID(ItemResID)
    local Cfg = EquipmentCfg:FindCfgByKey(ItemResID)
    if Cfg == nil then
        Cfg = EquipmentCfg:FindCfgByKey(ItemResID - WardrobeDefine.SpecialShiftID)
    end
    if Cfg ~= nil and Cfg.AppearanceID ~= nil and Cfg.AppearanceID ~= 0 then
        return Cfg.AppearanceID
    end
    return 
end

function WardrobeUtil.GetEquipID(EquipID, AppearanceID, RandomID)
	local ResultID = EquipID
	if nil ~= RandomID and RandomID > 0 then
		ResultID = RandomID
	elseif nil ~= AppearanceID and AppearanceID > 0 then
		local MappedEquipID = WardrobeUtil.GetEquipIDByAppearanceID(AppearanceID)
		if nil ~= MappedEquipID and MappedEquipID > 0 then
			ResultID = MappedEquipID
		end
	end
	return ResultID
end

local function CanItemDataBeFiltered(ID, ItemData, FilterFunc)
    local DataList = FilterFunc(ID, { ItemData })

    if #DataList == 1 then
        return true
    end
    return false
end

--- 获取下拉列表的第一个可以将传入的ItemData过滤出来的选项
---@param ItemData table
---@param DropDownDataList table
---@param FilterFunc function
---@param PremierIndex number 优先考虑的Index
function WardrobeUtil.GetFirstDropDownIndexByItemData(ItemData, DropDownDataList, FilterFunc, PremierIndex)
    local PremierData = DropDownDataList[PremierIndex]
    if PremierData and CanItemDataBeFiltered(PremierData.ID, ItemData, FilterFunc) then
        return PremierIndex
    end

	-- 从最后一个选项开始, 优先选择范围最窄的选项
	for i = #DropDownDataList, 1, -1 do
		local Data = DropDownDataList[i]
		if CanItemDataBeFiltered(Data.ID, ItemData, FilterFunc) then
            return i
        end
	end
end

return WardrobeUtil