local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local LegendaryWeaponTopicCfg = require("TableCfg/LegendaryWeaponTopicCfg")         --传奇武器主题表
local LegendaryWeaponChapterCfg = require("TableCfg/LegendaryWeaponChapterCfg")     --传奇武器章节表
local LegendaryWeaponCfg = require("TableCfg/LegendaryWeaponCfg")                   --传奇武器表
local ItemCfg = require("TableCfg/ItemCfg")
local EquipmentMgr = require("Game/Equipment/EquipmentMgr")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local AttrDefCfg = require("TableCfg/AttrDefCfg")
local ProtoRes = require("Protocol/ProtoRes")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local LegendaryWeaponMgr = require("Game/LegendaryWeapon/LegendaryWeaponMgr")
local UIBindableList = require("UI/UIBindableList")
local CommDropDownListItemNewVM = require("Game/Common/DropDownList/VM/CommDropDownListItemNewVM")
local LegendaryWeaponDefine = require("Game/LegendaryWeapon/LegendaryWeaponDefine")
local ProtoCommon = require("Protocol/ProtoCommon")

---@class LegendaryWeaponMainPanelVM : UIViewModel
local LegendaryWeaponMainPanelVM = LuaClass(UIViewModel)

function LegendaryWeaponMainPanelVM:Ctor()
end

function LegendaryWeaponMainPanelVM:OnInit()
    self.CameraFOV = 60
    self.SelectWeaponID = 0
    self.SelectSubWeaponID = 0
    self.SelectWeaponIndex = 1  --选中的武器序号
    self.TopicID = 1            --选中的主题ID
    self.ChapterID = 1          --选中的章节序号
    self.WeaponDesc = ""
    self.SelectID = 0
    self.IsComposeMode = false  -- 是否为制造模式(切换展示武器或材料界面)
    self.IsShowWeaponModel = true   --- 是否显示武器模型
end

function LegendaryWeaponMainPanelVM:OnShow()
    self.BP_SceneActor = nil        --- 蓝图场景
    self.Render2DActor = nil        --- 2D角色
    self.bIsCompletion = false      --- 当前武器已制作
    self.MaterialResID = nil        --- 选中的材料
    self.DownListVMList = UIBindableList.New(CommDropDownListItemNewVM) --职业切换列表
    LegendaryWeaponMgr:SendQueryMsg()
end

function LegendaryWeaponMainPanelVM:OnEnd()
    self.CameraFOV = 60
    self.SelectWeaponID = 0
    self.SelectSubWeaponID = 0
    self.SelectWeaponIndex = 1
    self.TopicID = 1
    self.ChapterID = 1
    self.WeaponDesc = ""
    self.SelectID = 0
    self.IsComposeMode = false
    self.IsShowWeaponModel = true
end

--- 获取主题
function LegendaryWeaponMainPanelVM:GetTopicTabList()
    local IsModuleOpen = _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDLegendaryWeapon)
    if not IsModuleOpen then    --系统未解锁
        return {}
    end
	local TopicTabList = {}     --这里要提前定义一个空的
    local TopicCfg = LegendaryWeaponTopicCfg:FindAllCfg()
	for _, Value in ipairs(TopicCfg) do
        local IsUnLock = LegendaryWeaponMgr.TopicVersion and LegendaryWeaponMgr.TopicVersion[Value.TopicID] == true
        if IsUnLock == true then
            local IsLock = not IsUnLock     --这里需要反向一下即解锁（继2.1.5版本以后这里还需判断前置任务）
            table.insert(TopicTabList, {IconPath = Value.Logo, SelectIcon = Value.Logo, Name = Value.Name, IsLock = IsLock, 
                                ID = Value.TopicID, ShopID = Value.ShopID, FirstType = Value.FirstType})    
        end
	end
    self.TopicTabList = TopicTabList
	return TopicTabList
end

--- 获取章节
---@param index 当前主题的章节
function LegendaryWeaponMainPanelVM:GetChapterList(index)
    if not self.TopicTabList or not self.TopicTabList[index] or not self.TopicTabList[index].ID then
        return {}
    end
	local TopicTabInfo = self.TopicTabList[index]
    local ChapterCfgList  = LegendaryWeaponChapterCfg:FindAllCfg(string.format("TopicID == %d", TopicTabInfo.ID))
	local ChapterList = {}

	for _, ChapterInfo in pairs(ChapterCfgList) do
        local bUnLock = LegendaryWeaponMgr.ChapterVersion and LegendaryWeaponMgr.ChapterVersion[ChapterInfo.ID] == true
        table.insert(ChapterList, {ID = ChapterInfo.ChapterID, IsUnLock = bUnLock, SpecialItemsHelp = ChapterInfo.SpecialItemsHelp})
	end
    table.sort(ChapterList, function(A, B)
        return A.ID < B.ID
    end)
    self.ChapterList = ChapterList
	return ChapterList
end

function LegendaryWeaponMainPanelVM:GetProfList(TopicID, ChapterID)
    TopicID = TopicID or self.TopicID
    ChapterID = ChapterID or self.ChapterID
    if nil == TopicID or ChapterID == nil then return end

    local TempList = LegendaryWeaponCfg:FindAllCfg(string.format("TopicID == %d AND ChapterID == %d", TopicID, ChapterID))
    self.ProfList = {}
    for _, WeaponInfo in pairs(TempList) do 
        local Cfg = ItemCfg:FindCfgByKey(WeaponInfo.EquipmentID)
        if nil ~= Cfg then
            local ProfName = EquipmentMgr:GetProfName(Cfg.ProfLimit[1])
            if not string.isnilorempty(ProfName) then
                local ProfIcon = RoleInitCfg:FindRoleInitProfIcon(Cfg.ProfLimit[1])
                table.insert(self.ProfList, {Name = ProfName, IconPath = ProfIcon, Prof = Cfg.ProfLimit[1], IsShowIcon = true, WeaponCfg = WeaponInfo})
            end
        end
    end
    return self.ProfList
end

function LegendaryWeaponMainPanelVM:GetOwnerWeaponList()
    local OwnerWeaponList = {}
    if LegendaryWeaponMgr.QueryList == nil then
        return
    end
	for key, value in pairs(LegendaryWeaponMgr.QueryList) do
		if value == true then
            local WeaponCfg = LegendaryWeaponCfg:FindCfgByKey(key)
            table.insert(OwnerWeaponList, {ID = key, TopicID = WeaponCfg.TopicID, ChapterID = WeaponCfg.ChapterID})
        end
	end
    return OwnerWeaponList
end

--- 查询第N章的武器已拥有
function LegendaryWeaponMainPanelVM:QueryOwnerChapter(WeaponID, ChapterID)
    local OwnerWeaponList = self:GetOwnerWeaponList()
	if OwnerWeaponList == nil or OwnerWeaponList == {} then
		return
	end
    table.sort(OwnerWeaponList, function(A, B)
        return A.ID < B.ID
    end)
    for _, value in pairs(OwnerWeaponList) do
        if value.ChapterID == ChapterID then
            if value.ID == WeaponID then
                return true
            end
        end
    end
end

--- 切换武器、章节、职业时，会执行到这里
function LegendaryWeaponMainPanelVM:SelectWeapon(Index)
    local ProfInfo = self.ProfList[Index]
    if ProfInfo ~= nil then
        self.ProfInfo = ProfInfo
        self.WeaponCfg = ProfInfo.WeaponCfg
        self.SelectWeaponIndex = Index
        self.SelectSubWeaponID = self.WeaponCfg.SubEquipmentID
        self.SelectWeaponID = self.WeaponCfg.EquipmentID
        self.WeaponDesc = self.WeaponCfg.Description
        self.SelectID = self.WeaponCfg.ID
    end
end

--- 获取武器的各项属性
function LegendaryWeaponMainPanelVM:GetAttriInfo(EuqipID)
	local ECfg = EquipmentCfg:FindCfgByKey(EuqipID)
	if ECfg == nil then
		return
	end
    local LAttrMsg = {}
    local SAttrMsg = {}
    if EquipmentMgr:IsWeapon(ECfg.Part) and ECfg.ArmRatio > 0 then
        local AttrText = string.format(LSTR(220045))    --"武器伤害倍率"
        local AttrValue = string.format("%.2f%%", ECfg.ArmRatio/100.0)
        table.insert(LAttrMsg, {Attr = AttrText, Value = AttrValue })
    end
    -- 遍历属性
    for i = 1, #ECfg.Attr do
        local Attr = ECfg.Attr[i]
        local Value = Attr.value
        local Attr = Attr.attr
        if Value and Attr ~= nil and Value ~= 0 then
            local AttrText = AttrDefCfg:GetAttrNameByID(Attr)
            local AttrValue = string.format("+%d", Value)
            if Value < 0 then
                AttrValue = string.format("%d", Value)
            end
            if AttrText and #AttrText > 6 then
                table.insert(LAttrMsg, {Attr = AttrText, Value = AttrValue })
            else
                table.insert(SAttrMsg, {Attr = AttrText, Value = AttrValue })
            end
        end
    end
    return LAttrMsg, SAttrMsg
end

--- 判断当前阶段的武器材料是否足够
function LegendaryWeaponMainPanelVM:CheckMaterialEnough()
    local WeaponCfg = self.ProfInfo.WeaponCfg
    self.IsMaterialEnough = LegendaryWeaponMgr:FindMaterialEnough(WeaponCfg)
    return self.IsMaterialEnough
end

-- 判断特殊材料是否足够
function LegendaryWeaponMainPanelVM:CheckSpecialMaterialEnough()
    local WeaponCfg = self.ProfInfo.WeaponCfg
    for _, ConsumeItem in pairs(WeaponCfg.SpecialItems) do
        local CurNumber = _G.BagMgr:GetItemNum(ConsumeItem.ResID)
        if CurNumber < ConsumeItem.Num then
            return false
        end
    end
    return true
end

function LegendaryWeaponMainPanelVM:OnBtnCraftClick()
    if not self.IsMaterialEnough then
        return 
    end
    
    --在触发获得奖励弹窗前，将奖励飘字设置为延迟，待通屏弹窗关闭后再播放奖励获得的飘字
    _G.LootMgr:SetDealyState(true)

    --发送制作请求
    LegendaryWeaponMgr:SendProdsuceMsg(self.ProfInfo.Prof, self.SelectID)
end

function LegendaryWeaponMainPanelVM:GetItemColor(ItemID)
    local ItemColor = 0
    local Cfg = ItemCfg:FindCfgByKey(ItemID)
	if Cfg ~= nil then
        ItemColor = nil ~= Cfg.ItemColor and Cfg.ItemColor or ProtoRes.ITEM_COLOR_TYPE.ITEM_COLOR_NONE
    end
    if LegendaryWeaponDefine.ItemQualityColor then
        return LegendaryWeaponDefine.ItemQualityColor[ItemColor]
    end
    return nil
end

--- 根据传入的物品ID跳转位置
function LegendaryWeaponMainPanelVM:GoToWeaponByItemID(ItemID)
    if ItemID == nil or ItemID == 0 then return end
    local Cfg = LegendaryWeaponCfg:FindAllCfg(string.format("EquipmentID = "..ItemID))
	if Cfg[1] == nil then return end
    local TopicID = Cfg[1].TopicID
    local ChapterID = Cfg[1].ChapterID  --判断ID是否在当前版本可解锁
    if LegendaryWeaponMgr.TopicVersion[TopicID] and LegendaryWeaponMgr.ChapterVersion[ChapterID] then
        local ItemCfg = ItemCfg:FindCfgByKey(ItemID)
        if nil == ItemCfg then return end
        local ProfID = ItemCfg.ProfLimit[1]
        ProfID = LegendaryWeaponDefine.ProfIdToWeaponProf[ProfID]
        self:GetProfList(TopicID, ChapterID)
        if self.ProfList == nil then return end
        for i, value in ipairs(self.ProfList) do
            if value.Prof == ProfID then
                self.SelectWeaponIndex = i
                self.TopicID = TopicID
                self.ChapterID = ChapterID
                return
            end
        end
    end
end

function LegendaryWeaponMainPanelVM:IsOpenChapter(TopicID, ChapterID)
    local Cfgs = LegendaryWeaponChapterCfg:FindAllCfg(string.format("TopicID == %d AND ChapterID == %d", TopicID, ChapterID))
    if Cfgs and Cfgs[1] then
        local ID = Cfgs[1].ID
        local bOpen = LegendaryWeaponMgr.ChapterVersion[ID]
        return bOpen
    end
end

return LegendaryWeaponMainPanelVM