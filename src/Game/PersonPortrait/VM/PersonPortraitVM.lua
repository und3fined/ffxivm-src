---
--- Author: xingcaicao
--- DateTime: 2023-11-29 14:25:00
--- Description: 个人信息--肖像 ViewModel
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local Json = require("Core/Json")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local PortraitBaseCfg = require("TableCfg/PortraitBaseCfg")
local PortraitDesignCfg = require("TableCfg/PortraitDesignCfg")
local PortraitPredesignCfg = require("TableCfg/PortraitPredesignCfg")
local PersonPortraitDefine = require("Game/PersonPortrait/PersonPortraitDefine")
local PersonPortraitResItemVM = require("Game/PersonPortrait/VM/PersonPortraitResItemVM")
local PersonPortraitModelEditVM = require("Game/PersonPortrait/VM/PersonPortraitModelEditVM")
local ClientSetupID = require("Game/ClientSetup/ClientSetupID")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")

local TabTypes = PersonPortraitDefine.TabTypes
local FilterType = PersonPortraitDefine.FilterType
local ImgSaveStrategy = PersonPortraitDefine.ImgSaveStrategy

local DesignerType = ProtoCommon.DesignerType
local UnlockTypes = ProtoRes.PortraitUnlockType
local PortraitResState = ProtoCS.Role.Portrait.PortraitResState
local ResStateUnknown = PortraitResState.PortraitResStateUnknown
local ResStateUnlock = PortraitResState.PortraitResStateUnlock

--- 排序
---@param lhs any
---@param rhs any
local ResItemListSortFunc = function(lhs, rhs)
    if lhs.IsOwned ~= rhs.IsOwned then
        return lhs.IsOwned
    end

    if lhs.IsUnknown ~= rhs.IsUnknown then
        return not lhs.IsUnknown 
    end

    return (lhs.ID or 0) < (rhs.ID or 0)
end

---@class PersonPortraitVM : UIViewModel
local Class = LuaClass(UIViewModel)

---Ctor
function Class:Ctor()

end
	
function Class:OnInit()
    self.CurModelEditVM = PersonPortraitModelEditVM.New()

    self:Reset()
end

function Class:OnBegin()
end

function Class:OnEnd()

end

function Class:OnShutdown()
    self:Reset()
end

function Class:Reset()
    self:Clear()

    self.TabList = nil 
    self.ResStatusMap = {} -- 资源状态

    self.UnreadRedDotIDMap = {} 
    self.ReadRedDotIDs = {} 
    self.SaveImgUrlStrategy = ImgSaveStrategy.CurProf

    self.ShowingResItemVMList = self:ResetBindableList(self.ShowingResItemVMList, PersonPortraitResItemVM)
end

function Class:Clear()
    self.CurTab = nil 
    self.AppearUpdateProfIDs = {}

    self.ListPanelVisible = false
    self.DecoratePanelVisible = false
    self.EmotionPanelVisible = false
    self.DesignRetVisible = false

    self.RightPanelVisible = false
    self.ModelEditPanelVisible = false
    self.LightingPanelVisible = false
    self.PlayProbarPanelVisible = false

    self.DecorateVisible = true 

    -- 模型
    self.ScreenshotWidget = nil
    self.DecorateVisibleSet = false
    self.IsPositionValid = true 

    self:ResetProfData()
end

function Class:ResetProfData()
    self.CurProfID = nil
    self.CurEquipList = nil -- repeated common.EquipAvatar 
    self.CurSelectResID = nil

    self.CurProfSetResIDsServer = {} -- 当前职业的设置资源ID列表(服务器端)
    self.CurProfSetResIDsServerMap = {}
    self.CurModelEditDataServer = {}

    self.CurSelectPredesignID = nil
    self.CurSelectBgID = 0 
    self.CurSelectDecorateID = 0 
    self.CurSelectFrameID = 0 
    self.CurSelectActionID = 0 
    self.CurSelectEmotionID = 0 

    self.CurModelEditVM:Reset()
end

function Class:GetTabList()
    if nil == self.TabList then  
        local Tabs = {}
        local MainTabs = PersonPortraitDefine.MainTabs

        for _, v in ipairs(MainTabs) do
            local Info = { Key = v.Key, Name = v.Name, Children = {} }

            for _, v1 in ipairs(v.Children or {}) do
                local Cfg = PortraitBaseCfg:FindCfgByKey(v1.Key)
                if Cfg and Cfg.Hide ~= 1 then
                    table.insert(Info.Children, v1)
                end
            end

            table.insert(Tabs, Info)
        end

        self.TabList = Tabs
    end

    return self.TabList
end

function Class:GetCurSelectResID(Type)
    if Type == DesignerType.DesignerType_Predict then
        return self.CurSelectPredesignID

    elseif Type == DesignerType.DesignerType_BackGround then
       return self.CurSelectBgID

    elseif Type == DesignerType.DesignerType_Decoration then
        return self.CurSelectDecorateID

    elseif Type == DesignerType.DesignerType_Decoration_Frame then
        return self.CurSelectFrameID

    elseif Type == DesignerType.DesignerType_Action then
        return self.CurSelectActionID

    elseif Type == DesignerType.DesignerType_Emotion then
        return self.CurSelectEmotionID
    end
end

function Class:SetCurSelectResID(Type, ID)
    if Type == DesignerType.DesignerType_Predict then
        self.CurSelectPredesignID = ID

    elseif Type == DesignerType.DesignerType_BackGround then
        self.CurSelectBgID = ID

    elseif Type == DesignerType.DesignerType_Decoration then
        self.CurSelectDecorateID = ID

    elseif Type == DesignerType.DesignerType_Decoration_Frame then
        self.CurSelectFrameID = ID

    elseif Type == DesignerType.DesignerType_Action then
        if self.CurSelectActionID == ID then
            self.CurSelectActionID = PersonPortraitDefine.DefaultCancelActionID
        else
            self.CurSelectActionID = ID
        end
    elseif Type == DesignerType.DesignerType_Emotion then
        if self.CurSelectEmotionID == ID then
            self.CurSelectEmotionID = 0
        else
            self.CurSelectEmotionID = ID
        end
    end
end

function Class:GetCurSelectResIDs()
    return { self.CurSelectBgID, self.CurSelectDecorateID, self.CurSelectFrameID, self.CurSelectActionID, self.CurSelectEmotionID } 
end

function Class:GetCurSetResIDs()
    local Ret = {}

    local UpdateIDs = function(Type)
        local ID = self:GetCurSetResIDByType(Type)
        if ID and ID > 0 then
            table.insert(Ret, ID)
        end
    end

    UpdateIDs(DesignerType.DesignerType_BackGround)
    UpdateIDs(DesignerType.DesignerType_Decoration)
    UpdateIDs(DesignerType.DesignerType_Decoration_Frame)
    UpdateIDs(DesignerType.DesignerType_Action)
    UpdateIDs(DesignerType.DesignerType_Emotion)

    return Ret
end

function Class:GetCurSetResIDByType(Type)
    local CurSelectID = self:GetCurSelectResID(Type) or 0
    if Type == DesignerType.DesignerType_Emotion then
        ---表情可以取消选中，设置为0就是取消选中
        return CurSelectID
    else
        return CurSelectID > 0 and CurSelectID or self:GetPortraitSrcSetResID(Type)
    end
end

function Class:GetPortraitSrcSetResID(Type)
   return self.CurProfSetResIDsServerMap[Type]
end

function Class:SetCurTab(Tab)
    if self.CurTab == Tab then
        return
    end

    if (1 << Tab) & TabTypes.Design ~= 0 then
        self.ListPanelVisible = true 
        self.DecoratePanelVisible = true 
        self.EmotionPanelVisible = false 
        self.RightPanelVisible = true 

        self:UdpateShowingResItemVMList(Tab, FilterType.All)

    elseif (Tab == TabTypes.Action) or (Tab == TabTypes.Emotion) then
        self.ListPanelVisible = true 
        self.DecoratePanelVisible = false 
        self.EmotionPanelVisible = true 
        self.RightPanelVisible = true 

        self:UdpateShowingResItemVMList(Tab, FilterType.All)

    else
        self.ListPanelVisible = false 
        self.DecoratePanelVisible = false 
        self.EmotionPanelVisible = false 
        self.RightPanelVisible = Tab == TabTypes.Lighting 

        self.ShowingResItemVMList:Clear()
    end

    self.ModelEditPanelVisible = Tab == TabTypes.ModelEdit 
    self.LightingPanelVisible = Tab == TabTypes.Lighting 
    self.DesignRetVisible = Tab ~= TabTypes.Design and Tab ~= TabTypes.Character

    self:UpdateCurResInfo(self:GetCurSelectResID(Tab), Tab)

    self.CurTab = Tab
    self:UpdateDecorateVisible(self.DecorateVisibleSet)
end

function Class:UpdateServerResStatus(ResStatus)
    if nil == ResStatus then
        return
    end

    local IsUdpateRedDots = false
    local StatusMap = self.ResStatusMap

    for k, v in pairs(ResStatus) do
        local OldState = StatusMap[k]
        local NewState = v 
        if NewState == ResStateUnlock and OldState ~= NewState then -- 其他状态 -> 可使用
            -- 需要更新小红点
            IsUdpateRedDots = true

        elseif OldState == ResStateUnlock and OldState ~= NewState then -- 可使用状态 -> 其他状态
            -- 已解锁的资源被锁定了
            IsUdpateRedDots = true

            -- 删除小红点
            local Cfg = PortraitDesignCfg:FindCfgByKey(k)
            if Cfg then
                self:RemoveReadRedDotID(Cfg.RedDotID)
            end
        end

        StatusMap[k] = NewState -- 更新状态
    end

    if IsUdpateRedDots then
        self:UpdateUnreadRedDots()
    end
end

function Class:UpdateCurProfSetResIDsServer(IDs)
    IDs = IDs or {}

	local ResIDMap = {} 

	for _, v in ipairs(IDs) do
        local Cfg = PortraitDesignCfg:FindCfgByKey(v)
        if Cfg then
            local Type = Cfg.TypeID
			if Type then
				ResIDMap[Type] = v
			end
		end
	end

    -- 匹配预设
    local BgID = ResIDMap[DesignerType.DesignerType_BackGround]
    local DecorationID = ResIDMap[DesignerType.DesignerType_Decoration]
    local FrameID = ResIDMap[DesignerType.DesignerType_Decoration_Frame]

    local CfgList = PortraitPredesignCfg:GetPredesignInfos()

    for _, v in ipairs(CfgList) do
        if v.BgID == BgID and v.DecorationID == DecorationID and v.FrameID == FrameID then
            table.insert(IDs, v.ID)
            break
        end
    end

    self.CurProfSetResIDsServer = IDs
    self.CurProfSetResIDsServerMap = ResIDMap 
end

function Class:UpdateCurModelEditVM(JsonStr)
    local T = {}
    if not string.isnilorempty(JsonStr) then
        T = Json.decode(JsonStr) or {}
    end

    self.CurModelEditDataServer = T 
    self.CurModelEditVM:UpdateVM(self.CurModelEditDataServer)
end

function Class:UpdateCurSelectID(ID, Type)
    if nil == Type then
        return
    end

    if ID ~= nil then
        if Type == DesignerType.DesignerType_Predict then
            local Cfg = PortraitPredesignCfg:FindCfgByKey(ID)
            if Cfg then
                --背景
                local ResID = Cfg.BgID
                self.CurSelectBgID = ResID > 0 and ResID or nil

                --装饰
                ResID = Cfg.DecorationID
                self.CurSelectDecorateID = ResID > 0 and ResID or nil

                --装饰框
                ResID = Cfg.FrameID
                self.CurSelectFrameID = ResID > 0 and ResID or nil
            end

        else
            self.CurSelectPredesignID = nil 
        end
    end

    self:SetCurSelectResID(Type, ID)
    if Type ==  DesignerType.DesignerType_Emotion and self.CurSelectEmotionID == 0 then
        ---表情需要支持取消选中
        self:UpdateCurResInfo(0)
    elseif Type ==  DesignerType.DesignerType_Action and self.CurSelectActionID == PersonPortraitDefine.DefaultCancelActionID then
        ---动作需要支持取消选中
        self:UpdateCurResInfo(PersonPortraitDefine.DefaultCancelActionID)
    else
        self:UpdateCurResInfo(ID)
    end
end

function Class:UpdateCurResInfo(ID, Tab)
    self.CurSelectResID = ID
	local ItemVM = self.ShowingResItemVMList:Find(function(e) return ID == e.ID end) 

    Tab = Tab or self.CurTab
    self.PlayProbarPanelVisible = (Tab == TabTypes.Action or Tab == TabTypes.Emotion) and ItemVM and not ItemVM.ImgSecretVisible
end

function Class:GetCurSelectItemVM()
    local ID = self.CurSelectResID
    if nil == ID then
        return
    end

	return self.ShowingResItemVMList:Find(function(e) return ID == e.ID end) 
end

function Class:UpdateDecorateVisible(VisibleSet)
    self.DecorateVisibleSet = VisibleSet
    self.DecorateVisible = self.CurTab ~= TabTypes.ModelEdit or VisibleSet
end

function Class:UpdateIsPositionValid(IsValid)
    self.IsPositionValid = IsValid
end

---检测设置内容是否有变化
function Class:CheckIsSetsChanged()
    -- 1.背景、装饰、装饰框、动作ID、表情ID
    local SetIDsServer = self.CurProfSetResIDsServer  
    local IDs = self:GetCurSelectResIDs()

    for _, v in ipairs(IDs) do
        if v > 0 and not table.contain(SetIDsServer, v) then
            return true
        end
    end

    -- 2.模型编辑数据
    if self.CurModelEditVM:IsNotEqual(self.CurModelEditDataServer) then
        return true
    end

    return false
end

---更新展示的资源VM列表
---@param DesignType ProtoCommon.DesignerType @设计类型
---@param Filter PersonPortraitDefine.FilterType @类型 
function Class:UdpateShowingResItemVMList(DesignType, Filter)
    if nil == DesignType then
        return
    end

    local IsPreset = DesignType == DesignerType.DesignerType_Predict
    local CfgList = IsPreset and PortraitPredesignCfg:GetPredesignInfos() or PortraitDesignCfg:GetDesignInfosByType(DesignType)

    local StatusMap = self.ResStatusMap
    local Data = {}

    for _, v in ipairs(CfgList) do
        local IsOwned = false
        local IsSkip = false
        local IsUnknown = false
        local ResState = StatusMap[v.ID]

        if IsPreset then
            -- 预设背景
            local ID = v.BgID
            IsOwned = ID <= 0 or StatusMap[ID] == ResStateUnlock or PortraitDesignCfg:IsDefaultUnlock(ID)

            -- 预设装饰
            ID = v.DecorationID
            IsOwned = IsOwned and (ID <= 0 or StatusMap[ID] == ResStateUnlock or PortraitDesignCfg:IsDefaultUnlock(ID))

            -- 预设装饰框
            ID = v.FrameID
            IsOwned = IsOwned and (ID <= 0 or StatusMap[ID] == ResStateUnlock or PortraitDesignCfg:IsDefaultUnlock(ID))

            -- 预设包含的设置中有未解锁项时，不显示
            IsSkip = not IsOwned

        else
            IsOwned = (v.UnlockType == UnlockTypes.PortraitUnlockTypeDefault) or (ResState == ResStateUnlock)
        end

        if not IsOwned and v.Unknown == 1 then -- 防剧透
            IsUnknown = ResState == ResStateUnknown
        end

        if not IsSkip and ((Filter == FilterType.All) or (Filter == FilterType.Owned and IsOwned) or (Filter == FilterType.NotOwned and not IsOwned)) then
            table.insert(Data, {TypeID = v.TypeID, CfgData = v, IsOwned = IsOwned, IsUnknown = IsUnknown})
        end
    end

    self.ShowingResItemVMList:UpdateByValues(Data, ResItemListSortFunc)
end

---是否为防剧透且未解锁资源
---@param ResID numberr @资源ID
function Class:IsSecretAndLocked(ResID)
    if nil == ResID then
        return false
    end

    local ResState = self.ResStatusMap[ResID]
    if ResState == ResStateUnknown then -- 防剧透 
        return true
    end

    if ResState == ResStateUnlock then -- 已解锁
        return false
    end

    local Cfg = PortraitDesignCfg:FindCfgByKey(ResID)
    if nil == Cfg or Cfg.Unknown ~= 1 then -- 不是防剧透
        return false
    end

    return Cfg.UnlockType ~= UnlockTypes.PortraitUnlockTypeDefault
end

-------------------------------------------------------------------------------------------------------
--- 小红点

-- 更新未读红点
function Class:UpdateUnreadRedDots()
    local ReadRedDotIDs = self.ReadRedDotIDs
    if nil == ReadRedDotIDs then
        return
    end

    for k, v in pairs(self.ResStatusMap) do
        if v == ResStateUnlock then -- 已解锁
            local Cfg = PortraitDesignCfg:FindCfgByKey(k)
            if Cfg then
                local RedDotID = Cfg.RedDotID or 0
                if RedDotID > 0 and not table.contain(ReadRedDotIDs, RedDotID) then
                    self.UnreadRedDotIDMap[RedDotID] = true
                    RedDotMgr:SetRedDotNodeValueByID(RedDotID, 1, false)
                end
            end
        end 
    end
end

function Class:UpdateReadRedDotIDs(IDs)
    self.ReadRedDotIDs = IDs
    self:UpdateUnreadRedDots()
end

function Class:AddReadRedDotID(ID)
    if nil == ID or ID <= 0 then
        return
    end

    if not self.UnreadRedDotIDMap[ID] then
        return
    end

    local ReadRedDotIDs = self.ReadRedDotIDs   
    if table.contain(ReadRedDotIDs, ID) then
        self.UnreadRedDotIDMap[ID] = nil
        return
    end

    table.insert(ReadRedDotIDs, ID)
    self.UnreadRedDotIDMap[ID] = nil

    local Str = Json.encode(ReadRedDotIDs)
    if Str then 
        _G.ClientSetupMgr:SendSetReq(ClientSetupID.PortraitReadRedDotIDs, Str)
    end

    RedDotMgr:SetRedDotNodeValueByID(ID, 0, false)
end

--删除已读红点
function Class:RemoveReadRedDotID(ID)
    if nil == ID or ID <= 0 then
        return
    end

    if self.UnreadRedDotIDMap[ID] then
        self.UnreadRedDotIDMap[ID] = nil
    end

    local ReadRedDotIDs = self.ReadRedDotIDs   
    if not table.contain(ReadRedDotIDs, ID) then
        return
    end

	for i = #ReadRedDotIDs, 1, -1 do
        local RedDotID = ReadRedDotIDs[i]
        if RedDotID == ID then
            table.remove(ReadRedDotIDs, i)
            break
        end
	end

    local Str = Json.encode(ReadRedDotIDs)
    if Str then 
        _G.ClientSetupMgr:SendSetReq(ClientSetupID.PortraitReadRedDotIDs, Str)
    end

    RedDotMgr:SetRedDotNodeValueByID(ID, 0, false)
end

function Class:ClearAllRedDot()
    local IsChange = false
    local ReadRedDotIDs = self.ReadRedDotIDs   

    for k, v in pairs(self.ResStatusMap) do
        if v == ResStateUnlock then -- 已解锁
            local Cfg = PortraitDesignCfg:FindCfgByKey(k)
            if Cfg then
                local RedDotID = Cfg.RedDotID or 0
                if RedDotID > 0 and not table.contain(ReadRedDotIDs, RedDotID) then
                    table.insert(ReadRedDotIDs, RedDotID)
                    IsChange = true
                end
            end
        end
    end

    if not IsChange then
        return
    end

    local Str = Json.encode(ReadRedDotIDs)
    if Str then 
        _G.ClientSetupMgr:SendSetReq(ClientSetupID.PortraitReadRedDotIDs, Str)
    end

    -- 删除小红点

    for _, v in ipairs(ReadRedDotIDs) do
        RedDotMgr:SetRedDotNodeValueByID(v, 0, false)
    end
end

-------------------------------------------------------------------------------------------------------

--- 设置图片保存策略
---@param Strategy PersonPortraitDefine.ImgSaveStrategy @策略
---@param IsSaveSet boolean @是否保存设置
function Class:SetSaveImgUrlStrategy(Strategy, IsSaveSet)
    if nil == Strategy or self.SaveImgUrlStrategy == Strategy then
        return
    end

    self.SaveImgUrlStrategy = Strategy 

    if IsSaveSet then
        _G.ClientSetupMgr:SendSetReq(ClientSetupID.PortraitSaveImgUrlStrategy, tostring(Strategy))
    end
end

return Class