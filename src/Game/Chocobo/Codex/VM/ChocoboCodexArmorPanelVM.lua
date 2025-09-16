--Author:Easy
--DateTime: 2023/12/25

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local RichTextUtil = require("Utils/RichTextUtil")
local UIBindableList = require("UI/UIBindableList")
local ChocoboCodexArmorItemVM = require("Game/Chocobo/Codex/VM/ChocoboCodexArmorItemVM")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIViewID = require("Define/UIViewID")

local BuddySuitCfg  = require("TableCfg/BuddySuitCfg")
local ChocoboAwardCfg = require("TableCfg/ChocoboAwardCfg")

local EToggleButtonState = _G.UE.EToggleButtonState

local ChocoboCodexArmorPanelVM = LuaClass(UIViewModel)
function ChocoboCodexArmorPanelVM:Ctor()
	self.TextName = "" 
	self.TextArmorName = "" 
    self.Description = ""
	self.TextProcess = ""
	self.RadialProcess = 0 
	self.RichTextID = "" 

	self.EmptyVisible = false
    self.EmptyArmorsVisible = false
    self.ShowCollected = true
    
    self.PanelRightVisible = false
    self.GestureVisible = false
    self.BtnsVisible = false
    self.ChocoboNameVisible = false

    self.ToggleSwitchChecked = nil
    self.ToggleShowRoleChecked = nil 
    self.ToggleMountChecked = nil 
    self.BtnSwitchVisible = nil
end

function ChocoboCodexArmorPanelVM:OnInit()   
    self.CollectAwardList = {}
	self:InitArmor()
    self:InitArmorReward()
    self.ResultArmorSuits = {}
    self.NewGetSuitIDList = {}    

    self.ToggleSwitchChecked = EToggleButtonState.Unchecked
    self.ToggleShowRoleChecked = EToggleButtonState.Checked
    self.ToggleMountChecked = EToggleButtonState.Checked
    self.ArmorList = UIBindableList.New(ChocoboCodexArmorItemVM)
end

function ChocoboCodexArmorPanelVM:OnBegin()
end

function ChocoboCodexArmorPanelVM:Clear()
end

function ChocoboCodexArmorPanelVM:OnEnd()
end

function ChocoboCodexArmorPanelVM:OnShutdown()
end


function ChocoboCodexArmorPanelVM:SetSwitchChecked(bChecked)
    if bChecked then
        self.ToggleSwitchChecked = EToggleButtonState.Checked
    else
        self.ToggleSwitchChecked = EToggleButtonState.Unchecked
    end
end

function ChocoboCodexArmorPanelVM:SwitchChecked()
    return self.ToggleSwitchChecked == EToggleButtonState.Checked
end

function ChocoboCodexArmorPanelVM:SetShowRoleChecked(bChecked)
    if bChecked then
        self.ToggleShowRoleChecked = EToggleButtonState.Checked
    else
        self.ToggleShowRoleChecked = EToggleButtonState.Unchecked
    end
end

function ChocoboCodexArmorPanelVM:ShowRoleChecked()
    return self.ToggleShowRoleChecked == EToggleButtonState.Checked
end

function ChocoboCodexArmorPanelVM:SetMountChecked(bChecked)
    if bChecked then
        self.ToggleMountChecked = EToggleButtonState.Checked
    else
        self.ToggleMountChecked = EToggleButtonState.Unchecked
    end
end

function ChocoboCodexArmorPanelVM:MountChecked()
    return self.ToggleMountChecked == EToggleButtonState.Checked
end

-- 读取配置表中的陆行鸟装甲信息
function ChocoboCodexArmorPanelVM:InitArmor()
	self.SuitOwnedCount = 0
    self.SuitCount = 0    
    self.PartOwnedCount = 0
    self.PartCount = 0

    self.SrcArmorSuits = {}
    local CfgSearchCond = string.format("UIPriority != 0")
    local ArmorSuitCfgs = BuddySuitCfg:FindAllCfg(CfgSearchCond)
    if ArmorSuitCfgs ~= nil then 
        table.sort( ArmorSuitCfgs, function(a,b)
            if a.UIPriority < b.UIPriority then 
                return true 
            end
            return false 
        end)

        self.SuitCount = #ArmorSuitCfgs
        for i = 1,self.SuitCount do
            local ArmorSuit = {}
            local PartCount = 0
            ArmorSuit.ID = ArmorSuitCfgs[i].ID
            ArmorSuit.Name = ArmorSuitCfgs[i].Name
            ArmorSuit.UIPriority = ArmorSuitCfgs[i].UIPriority
            ArmorSuit.IconID = ArmorSuitCfgs[i].IconID
            ArmorSuit.Description = ArmorSuitCfgs[i].Description
            ArmorSuit.IsSpoiler = ArmorSuitCfgs[i].IsSpoiler
            if ArmorSuitCfgs[i].HeadItemID > 0 then 
                ArmorSuit.HeadItem = { ItemID = ArmorSuitCfgs[i].HeadItemID,Owned = false}
                PartCount = PartCount + 1
            else 
                ArmorSuit.HeadItem = nil
            end
            if ArmorSuitCfgs[i].BodyItemID > 0 then 
                ArmorSuit.BodyItem = { ItemID = ArmorSuitCfgs[i].BodyItemID,Owned = false}
                PartCount = PartCount + 1
            else
                ArmorSuit.BodyItem = nil 
            end
            if ArmorSuitCfgs[i].FootItemID > 0 then
                ArmorSuit.FootItem = { ItemID = ArmorSuitCfgs[i].FootItemID,Owned = false} 
                PartCount = PartCount + 1
             else
                ArmorSuit.FootItem = nil 
            end
            ArmorSuit.PartCount = PartCount 
            self.PartCount = self.PartCount + PartCount
            ArmorSuit.PartOwnedCount = 0
           
            table.insert(self.SrcArmorSuits, ArmorSuit)
        end
    end
end

function ChocoboCodexArmorPanelVM:GetArmorSuits()
    return self.ResultArmorSuits
end

function ChocoboCodexArmorPanelVM:GetSuitCount()
    return self.SuitCount
end

function ChocoboCodexArmorPanelVM:GetPartCount()
    return self.PartCount
end

function ChocoboCodexArmorPanelVM:GetPartOwnedCount()
    return self.PartOwnedCount
end

function ChocoboCodexArmorPanelVM:GetSuitOwnedCount()
    return self.SuitOwnedCount
end

function ChocoboCodexArmorPanelVM:CollectedArmorSuits(SrcData)
    local SrcArmorSuits =  SrcData

    local ArmorSuits = {}
    for i = 1,#SrcArmorSuits do
        local ArmorSuit = SrcArmorSuits[i]
        local PartCount = ArmorSuit.PartCount
        local OwnedPartCount = ArmorSuit.PartOwnedCount
        if PartCount ~= OwnedPartCount then
            table.insert(ArmorSuits,ArmorSuit)
        end
    end

    return ArmorSuits
end 

function ChocoboCodexArmorPanelVM:IsCollected(ArmorSuit)
    local PartCount = ArmorSuit.PartCount
    local OwnedPartCount = ArmorSuit.PartOwnedCount
    if PartCount ~= OwnedPartCount then
        return false
    end

    return true
end

-- 更新当前所有陆行鸟装甲信息
function ChocoboCodexArmorPanelVM:UpdateAllSuit(SuitList)
	if SuitList == nil then return end
    self.PartOwnedCount = 0
    self.SuitOwnedCount = 0

    local function addUnique(t,value)
        -- 检查值是否已存在
        for _, v in ipairs(t) do
            if v == value then
                return -- 如果值已存在，则直接返回，不执行插入操作
            end
        end
        -- 如果值不存在，则将其添加到数组末尾
        table.insert(t, value)
    end

    self.NewGetSuitIDList = {}  
    for i = 1,#SuitList do
        for j = 1,#self.SrcArmorSuits do 
            if SuitList[i].SuitID == self.SrcArmorSuits[j].ID then
                local PartList = SuitList[i].PartList
                local PartCount = #PartList
                if PartCount == self.SrcArmorSuits[j].PartCount then 
                    self.SuitOwnedCount = self.SuitOwnedCount + 1
                end

                local PartOwnedCount = 0
                for k = 1,PartCount do
                    if self.SrcArmorSuits[j].HeadItem ~= nil then
                    	if PartList[k] == self.SrcArmorSuits[j].HeadItem.ItemID then
                            self.SrcArmorSuits[j].HeadItem.Owned = true 
                            if self:AddReddot(PartList[k]) then
                                addUnique(self.NewGetSuitIDList,j)
                            end
                            PartOwnedCount = PartOwnedCount + 1
                        end
                    end
                    if self.SrcArmorSuits[j].BodyItem ~= nil then
                        if PartList[k] == self.SrcArmorSuits[j].BodyItem.ItemID then 
                            self.SrcArmorSuits[j].BodyItem.Owned = true
                            if self:AddReddot(PartList[k]) then
                                addUnique(self.NewGetSuitIDList,j)
                            end
                            PartOwnedCount = PartOwnedCount + 1
                        end
                    end
                    if self.SrcArmorSuits[j].FootItem ~= nil then
                        if PartList[k] == self.SrcArmorSuits[j].FootItem.ItemID then 
                        	self.SrcArmorSuits[j].FootItem.Owned = true
                            if self:AddReddot(PartList[k]) then
                                addUnique(self.NewGetSuitIDList,j)
                            end
                            PartOwnedCount = PartOwnedCount + 1
                        end
                    end
                end      
                self.SrcArmorSuits[j].PartOwnedCount = PartOwnedCount
                if PartOwnedCount > 0 then
                    self.SrcArmorSuits[j].IsSpoiler = 0
                end
                self.PartOwnedCount = self.PartOwnedCount + PartOwnedCount
            end
        end
    end

    -- 如果界面打开的，就刷新
    if _G.UIViewMgr:IsViewVisible(UIViewID.ChocoboCodexArmorPanelView) then 
        _G.EventMgr:SendEvent(_G.EventID.ChocoboCodexArmorUpdate)
    end
end

function ChocoboCodexArmorPanelVM:RemoveAllRedDot()
    self.NewGetSuitIDList = {}
    for j = 1,#self.SrcArmorSuits do 
        local PartCount = self.SrcArmorSuits[j].PartCount
        for k = 1,PartCount do
            if self.SrcArmorSuits[j].HeadItem ~= nil then
                self:RemoveReddot(self.SrcArmorSuits[j].HeadItem.ItemID)
            end 
            if self.SrcArmorSuits[j].BodyItem ~= nil then
                self:RemoveReddot(self.SrcArmorSuits[j].BodyItem.ItemID)
            end
            if self.SrcArmorSuits[j].FootItem ~= nil then
                self:RemoveReddot(self.SrcArmorSuits[j].FootItem.ItemID)
            end
        end 
    end
end

function ChocoboCodexArmorPanelVM:GetRewardWinVM()
	return self.ArmorAwardWinVM 
end

function ChocoboCodexArmorPanelVM:SetShowCollected(Value)
    self.ShowCollected = Value  
end

function ChocoboCodexArmorPanelVM:UpdateChocobo()
    local _IsModuelOpen = _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDBuddy)
    local ChocoboVM, IsSuc = _G.ChocoboMgr:GetRaceChocoboVM()
    self.BtnSwitchVisible = IsSuc and _IsModuelOpen
    if IsSuc then
	   self.TextName = ChocoboVM.Name
       self.EmptyVisible = false
    end
end

function ChocoboCodexArmorPanelVM:UpdateSuit(ArmorSuit)
	if ArmorSuit == nil then return end

    self.EmptyArmorsVisible = false
    self.PanelRightVisible = true

	if ArmorSuit.IsSpoiler == 1 then
		self.GestureVisible = false
		self.BtnsVisible = false
        self.EmptyVisible = true
        self.ChocoboNameVisible = false

        self.TextArmorName = LSTR("???") 
	else 
    	self.GestureVisible = true
		self.BtnsVisible = true
        self.EmptyVisible = false
        self.ChocoboNameVisible = true

        self.TextArmorName = ArmorSuit.Name 
        self.Description = ArmorSuit.Description
	end
    
    if ArmorSuit.UIPriority ~= nil then 
        if ArmorSuit.UIPriority ~= 0 then
            -- LSTR string: 编号：%s
            self.RichTextID = string.format(LSTR(670012), RichTextUtil.GetText(string.format("%d",ArmorSuit.UIPriority), "FFEEBBFF"))  --编号：%s
        else
            -- LSTR string: 编号：???
            self.RichTextID = LSTR(670013)  --编号：???
        end
    else
        self.RichTextID = ""
    end
end

function ChocoboCodexArmorPanelVM:UpdateArmorList()
    local bFindSuit = #self.ResultArmorSuits == 0

    self.EmptyArmorsVisible = bFindSuit
    self.PanelRightVisible = not bFindSuit
    self.GestureVisible = not bFindSuit
    self.BtnsVisible = not bFindSuit
    self.ArmorList:UpdateByValues(self.ResultArmorSuits)

    local PartCount  = self:GetPartCount()
	local PartOwnedCount =  self:GetPartOwnedCount()
	-- LSTR string: 部件数量：%d/%d
	self.TextProcess =  string.format(LSTR(670014),PartOwnedCount,PartCount)  --部件数量：%d/%d
	self.RadialProcess = PartOwnedCount/PartCount
end

-- 奖励相关
function ChocoboCodexArmorPanelVM:InitArmorReward()
    self.AwardCfgs = ChocoboAwardCfg:FindAllCfg("Type == 2")
    if self.AwardCfgs == nil then
        FLOG_ERROR("Cann't Find ChocoboAwardCfg!")
    end
end

-- 套装奖励相关,目前没有套装奖励
function ChocoboCodexArmorPanelVM:UpdateSuitAward(SuitAwardCollected)
	if SuitAwardCollected ==  nil then return end
end

function ChocoboCodexArmorPanelVM:UpdateSuitProcessAward(SuitProcessAward)
	if SuitProcessAward == nil then return end
end

-- 部件套装相关
function ChocoboCodexArmorPanelVM:UpdatePartAward(PartAwardCollected)
	if PartAwardCollected ==  nil then return end

    self.CollectAwardList = {}
    local OwnedPartCount = self:GetPartOwnedCount()
    local CollectAwardList = self.AwardCfgs
    for index, AwardCfg in ipairs(CollectAwardList) do
        local IsCollectioned = false 
        if PartAwardCollected[index] == 1 then  
            IsCollectioned = true
        else
            IsCollectioned = false
        end

        local AwardData = {
            CollectNum = AwardCfg.Process,
            AwardID = AwardCfg.Item[1].ID,
            AwardNum = AwardCfg.Item[1].Num,
            IsCollectedAward = IsCollectioned,
        }
        table.insert(self.CollectAwardList, AwardData)
    end
end

function ChocoboCodexArmorPanelVM:UpdatePartProcessAward(PartProcessAward)
	if PartProcessAward ==  nil then return end
	self.ArmorAwardWinVM:UpdatePartProcessAward(PartProcessAward)
end

function ChocoboCodexArmorPanelVM:GetCollectedAward()
    return self.CollectAwardList
end

-- 查找字符
--local function FindContains(haystack,needle)
--    -- 使用 find 方法，不区分大小写
--    local pos = haystack:lower():find(needle:lower())
--    -- 如果找到位置则返回 true，否则返回 false
--    return pos ~= nil
--end

local function FindContains(Haystack, Needle)
    if not Needle or Needle == "" then
        return false
    end

    local HaystackLower = Haystack:lower()
    local NeedleLower = Needle:lower()

    local NeedleLen = #NeedleLower
    for i = 1, #HaystackLower - NeedleLen + 1 do
        local Match = true
        for j = 1, NeedleLen do
            if HaystackLower:byte(i + j - 1) ~= NeedleLower:byte(j) then
                Match = false
                break
            end
        end
        if Match then
            return true
        end
    end
    return false
end


function ChocoboCodexArmorPanelVM:SearchData(SearchText)
    local IsSearch = true
    if not string.isnilorempty(SearchText) then
        local strL1 = string.gsub(SearchText, "%s+", "")
        if string.isnilorempty(strL1) then 
            IsSearch = false
        end
    else 
        IsSearch = false
    end

    local UIPriority = tonumber(SearchText)

    local SearchResults = {}
    local SearchSrcArmorSuits = self.SrcArmorSuits 
    if not self.ShowCollected then 
        SearchSrcArmorSuits = self:CollectedArmorSuits(self.SrcArmorSuits)
    end

    for k,v in pairs(SearchSrcArmorSuits) do
        if UIPriority then 
            if UIPriority == v.UIPriority then
                table.insert(SearchResults,v)
            end
        else 
            if IsSearch then
                if v.IsSpoiler ~= 1 then
                    if FindContains( v.Name,SearchText) then
                        table.insert(SearchResults,v)
                    end
                end
            else 
                table.insert(SearchResults,v)
            end
        end
    end

    self.ResultArmorSuits = SearchResults
end

function ChocoboCodexArmorPanelVM:GetNewSuitIndex()
    local MinNewGetSuit = math.huge
    if #self.NewGetSuitIDList > 0 then
        for _, SuitID in ipairs(self.NewGetSuitIDList) do
            if SuitID < MinNewGetSuit then
                MinNewGetSuit = SuitID
            end
        end
    else
        MinNewGetSuit = 1
    end

    return MinNewGetSuit
end


-- 在新的列表内找出当前选中的索引
function ChocoboCodexArmorPanelVM:FindSuitIndex(ArmorSuit)
    local NewIndex = 1
    if ArmorSuit ~= nil then  
        for k, v in pairs(self.ResultArmorSuits) do
            if v.ID == ArmorSuit.ID then 
                return k 
            end
        end
    end
    return NewIndex
end


function ChocoboCodexArmorPanelVM:AddReddot(ItemID)
    local RedDotName = string.format("Root/ChocoboArmorNew/%s", tostring(ItemID))
    local IsSaved = _G.RedDotMgr:GetIsSaveDelRedDotByName(RedDotName)
    if not IsSaved then   
        _G.RedDotMgr:AddRedDotByName(RedDotName,1,true)
        return true 
    end
    return false
end

function ChocoboCodexArmorPanelVM:RemoveReddot(ItemID)
    local RedDotName = string.format("Root/ChocoboArmorNew/%s", tostring(ItemID))
    _G.RedDotMgr:DelRedDotByName(RedDotName,1)
end

function ChocoboCodexArmorPanelVM:CheckItemUsed(ItemID)
    local count = #self.SrcArmorSuits
    for i = 1,count do
        local ArmorSuit = self.SrcArmorSuits[i]
        if ArmorSuit.HeadItem ~= nil then
            if ItemID == ArmorSuit.HeadItem.ItemID then 
                return ArmorSuit.HeadItem.Owned
            end 
        end
        if ArmorSuit.BodyItem ~= nil then
            if ItemID == ArmorSuit.BodyItem.ItemID then 
                return ArmorSuit.BodyItem.Owned
            end 
        end
        if ArmorSuit.FootItem ~= nil then
            if ItemID == ArmorSuit.FootItem.ItemID then 
                return ArmorSuit.FootItem.Owned
            end 
        end
    end 

    FLOG_INFO("ChocoboCodexArmorPanelVM:CheckItemUsed: Cann't find Item: %s",ItemID)
    return false
end

return ChocoboCodexArmorPanelVM
