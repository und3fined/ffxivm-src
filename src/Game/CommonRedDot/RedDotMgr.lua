local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")

local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local ReddotCfg = require("TableCfg/ReddotCfg")
local ReddotNameCfg = require("TableCfg/ReddotNameCfg")
local SaveKey = require("Define/SaveKey")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")
local UIUtil = require("Utils/UIUtil")
local CommonBorderRedDotPanelVM

local USaveMgr

-- @class RedDotMgr : MgrBase
local RedDotMgr = LuaClass(MgrBase)

---@class RedDotNode
---@field RedDotName string  红点名/路径
---@field ParentRedDotNode RedDotNode 父红点节点
---@field SubRedDotList table<RedDotNode> 子红点节点列表
---@field IsLeafNode boolean 是否是单独红点路径的终点
---@field IsClientNode boolean 是否是客户端保存节点
---@field NodeValue boolean 节点值
---@field ItemVMMap table<RedDotItemVM> 节点值

function RedDotMgr:OnInit()
    USaveMgr = _G.UE.USaveMgr
    self.SaveDelNodeNameList = nil
    self.DetryDirtyNodeNameList = {}
    self.DetryDirtyListKeyList = {}
    self.ItemVMMap = {}
    ---用于检索更新边界红点
    self.ListRedDotKeysMap = {}
    self:ReadSaveKeyData()
    self:InitRedDotTree()
end

---初始化红点树
function RedDotMgr:InitRedDotTree()
    self.RootRedDotNode = {
        RedDotName = "Root",
        IsClientNode = false,
        IsLeafNode = false,
        NodeValue = 0, --子节点数量，用于控制显隐
        SubRedDotList = {},
    }
    local Cfg = ReddotCfg:FindAllCfg()
    for _, NodeData in ipairs(Cfg) do
        local IsHide = false
        for _, HideNodeName in pairs(self.SaveDelNodeNameList) do
            if NodeData.RedDotName == HideNodeName then
                IsHide = true
                break
            end
        end
        if not IsHide then
            self:AddRedDotByName(NodeData.RedDotName, 0, true)
        end
    end
end

function RedDotMgr:OnShutdown()
    --self:WriteSaveKeyData()
end

--- 切换角色需要存入，放OnEnd处理
function RedDotMgr:OnEnd()
    self:WriteSaveKeyData()
end

---------------------------------------- 持久化保存Start ----------------------------------------
--- 保存已读的客户端红点,改成实时存储，有系统反馈真机上直接杀进程不会保存
function RedDotMgr:SaveDelRedDot(RedDotName)
    for _, NodeName in pairs(self.SaveDelNodeNameList) do
        if RedDotName == NodeName then
            return
        end
    end
    
    table.insert(self.SaveDelNodeNameList, RedDotName)
    ---延迟一帧处理，防止短时间大量存入
    if self.SaveTimer == nil then
        self.SaveTimer = self:RegisterTimer(self.WriteSaveKeyData, 0.02)
    end
end

---清理重新显示的客户端保存已读红点
function RedDotMgr:CleanSaveShowRedDot(RedDotName)
    --self.SaveDelNodeNameList = {}
    local NodeIndex = 0
    for Index, NodeName in pairs(self.SaveDelNodeNameList) do
        if RedDotName == NodeName then
            NodeIndex = Index
        end
    end
    if NodeIndex ~= 0 then
        self.SaveDelNodeNameList[NodeIndex] = nil
    end
end

---读取持久化保存的数据
function RedDotMgr:ReadSaveKeyData()
    local HideRedDotStr = USaveMgr.GetString(SaveKey.HideRedDot, "", true)
    self.SaveDelNodeNameList = string.split(HideRedDotStr,",")
end

---持久化保存
function RedDotMgr:WriteSaveKeyData()
    local HideRedDotStr = ""
    for _, HideNodeName in pairs(self.SaveDelNodeNameList) do
        HideRedDotStr = string.format("%s,%s", HideRedDotStr, HideNodeName)
    end
    USaveMgr.SetString(SaveKey.HideRedDot, HideRedDotStr, true)
    if self.SaveTimer then
        self:UnRegisterTimer(self.SaveTimer)
        self.SaveTimer = nil
    end
end
---------------------------------------- 持久化保存End ----------------------------------------


---------------------------------------- 增start ----------------------------------------
--- 外部一般只操作叶子节点,不要往叶子节点下面继续添加节点，叶子节点的值与子节点无关
--- 通过父节点名生成并插入节点，自动命名节点
--- @param ParentRedDotName string 父节点名
--- @param NodeValue number 节点值
--- @param IsClientNode boolean 是否是客户端保存节点
--- @return AutoName string 自动生成的红点名
function RedDotMgr:AddRedDotByParentRedDotName(ParentRedDotName, NodeValue, IsClientNode)
    local ParentRedDot = self:FindRedDotNodeByName(ParentRedDotName)
    local AutoName
    if ParentRedDot then
        local SubNodeList = self:GetSubRedDotListByName(ParentRedDotName)
        local IsRepeat = true
        AutoName = ParentRedDot.AutoNameIndex or 1
        while IsRepeat do
            IsRepeat = false
            if nil == ParentRedDot.SubRedDotList then
                _G.FLOG_WARNING("RedDotMgr 尝试向叶子节点插入")
                return
            end 
            for _, Node in pairs(SubNodeList) do
                local ParentNameLen = #ParentRedDotName
                ---需要去掉 “/”
                local NodeSubName = string.sub(Node.RedDotName, ParentNameLen + 2)
                if NodeSubName == tostring(AutoName) then
                    IsRepeat = true
                    break
                end
            end
            if IsRepeat == true then
                AutoName = AutoName + 1
            end
        end 
        ParentRedDot.AutoNameIndex = AutoName
        AutoName = string.format("%s%s%d",ParentRedDotName, "/", AutoName)
    else
        AutoName = string.format("%s%s",ParentRedDotName, "/1")
    end
    self:AddRedDotByName(AutoName, NodeValue, IsClientNode)
    return AutoName
end

--- 外部一般只操作叶子节点,不要往叶子节点下面继续添加节点，叶子节点的值与子节点无关
--- 通过节点名生成并插入节点
--- @param RedDotName string 节点名
--- @param NodeValue number 节点值
--- @param IsClientNode boolean 是否是客户端保存的节点
function RedDotMgr:AddRedDotByName(RedDotName, NodeValue, IsClientNode)
   local SubNamelist =  string.split(RedDotName, "/")
   local InsertParentNode = self.RootRedDotNode
   local PathLength = #SubNamelist
    ---Root节点不查找，从第二级开始，找到则设置为叶子节点，找不到则从最后找到位置插入
   for i = 2, PathLength do
        local  SubNodeList = InsertParentNode.SubRedDotList
        local IsFind = false
        local CurPathName = "Root"
        for Index = 2, i do
            if SubNamelist[Index] then
                CurPathName = string.format("%s/%s", CurPathName, SubNamelist[Index])
            end
        end
        if nil == InsertParentNode.SubRedDotList then
            _G.FLOG_WARNING("RedDotMgr 尝试向叶子节点插入")
            return
        end 
        for _, Node in pairs(SubNodeList) do
            if i == PathLength then
                IsFind = RedDotName == Node.RedDotName
            else                
                IsFind = Node.RedDotName == CurPathName
            end
            if IsFind then
                InsertParentNode = Node
                break
            end
        end
        if not IsFind then
            self:AddSubNode(InsertParentNode, RedDotName, NodeValue, IsClientNode)
            return
        end
    end
end

--- 生成并插入节点
--- @param InsertParentNode RedDotNode 父节点
--- @param RedDotName string 需要生成的节点名
--- @param NodeValue number 节点值
--- @param IsClientNode boolean 是否是客户端保存读表的节点
function RedDotMgr:AddSubNode(InsertParentNode, RedDotName, NodeValue, IsClientNode)
    local NodeSubName = string.gsub(RedDotName, InsertParentNode.RedDotName, "")
    local SubNamelist = string.split(NodeSubName, "/")
    local ParentNode = InsertParentNode
    --local LeafNode = InsertParentNode
    for _, SubName in ipairs(SubNamelist) do
        local NewNode = {
            RedDotName = string.format("%s/%s", ParentNode.RedDotName, SubName),
            ParentRedDotNode = ParentNode,
            SubRedDotList = {},
            IsLeafNode = false,
            IsClientNode = false,
            NodeValue = 0,
            TotalNum = 0, --数字红点显示值，为子节点显示值总和
        }
        if nil == ParentNode.SubRedDotList then
            _G.FLOG_WARNING("RedDotMgr 尝试向叶子节点插入")
            return
        end 
        table.insert(ParentNode.SubRedDotList, NewNode)
        self:SetNodeValueChangeInternal(ParentNode, 1)
        self:SetDirtyNode(ParentNode)
        ParentNode = NewNode
    end
    local LeafNode = ParentNode
    LeafNode.IsClientNode = IsClientNode
    LeafNode.SubRedDotList = nil --叶子节点无子节点列表
    local NodeIndex
    --- 重新显示客户端保存已删除节点
    for Index, NodeName in pairs(self.SaveDelNodeNameList) do
        if RedDotName == NodeName then
            NodeIndex = Index
            LeafNode.IsClientNode = true
        end
    end
    if NodeIndex then
        self.SaveDelNodeNameList[NodeIndex] = nil
        self:CleanSaveShowRedDot(RedDotName)
    end
    LeafNode.IsLeafNode = true
    LeafNode.NodeValue = NodeValue or 1 -- 新增叶子节点默认值给1，防止添加节点不显示
    if LeafNode.ParentRedDotNode and LeafNode.ParentRedDotNode ~= self.RootRedDotNode then
        self:SetTotalNumChangeInternal(LeafNode.ParentRedDotNode, LeafNode.NodeValue)
    end
    self:SetDirtyNode(LeafNode)
end

--- 外部一般只操作叶子节点,不要往叶子节点下面继续添加节点，叶子节点的值与子节点无关
--- 通过节点名生成并插入节点
--- @param RedDotID number 节点ID
--- @param NodeValue number 节点值
--- @param IsClientNode boolean 是否是客户端保存节点
function RedDotMgr:AddRedDotByID(RedDotID, NodeValue, IsClientNode, CheckID)
    local RedDotName = self:GetRedDotNameByID(RedDotID)
    ---CheckID检查，非本系统调用提示/暂时只检查ID,自己组装的没办法获取CheckID，且组装路径存在误调用概率要小一些
    local CfgCheckID =  self:GetRedDotCheckIDByID(RedDotID)
    if CfgCheckID ~= 0 and CfgCheckID ~= nil and CheckID ~= CfgCheckID then
        _G.FLOG_WARNING(string.format("红点跨系统调用 调用CheckID为 %s 配置CheckID为 %s \n %s", tostring(CheckID), tostring(CfgCheckID), debug.traceback()))
    end
    self:AddRedDotByName(RedDotName, NodeValue, IsClientNode)
end

--- 外部一般只操作叶子节点,不要往叶子节点下面继续添加节点，叶子节点的值与子节点无关
--- 通过父节点名生成并插入节点，自动命名节点
--- @param ParentRedDotID number 父节点ID
--- @param NodeValue number 节点值
--- @param IsClientNode boolean 是否是客户端保存节点
function RedDotMgr:AddRedDotByParentRedDotID(ParentRedDotID, NodeValue, IsClientNode, CheckID)
    local RedDotName = self:GetRedDotNameByID(ParentRedDotID)
    ---CheckID检查，非本系统调用提示/暂时只检查ID,自己组装的没办法获取CheckID，且组装路径存在误调用概率要小一些
    local CfgCheckID =  self:GetRedDotCheckIDByID(ParentRedDotID)
    if CfgCheckID ~= 0 and CfgCheckID ~= nil and CheckID ~= CfgCheckID then
        _G.FLOG_WARNING(string.format("红点跨系统调用 调用CheckID为 %s 配置CheckID为 %s \n %s", tostring(CheckID), tostring(CfgCheckID), debug.traceback()))
    end
    return self:AddRedDotByParentRedDotName(RedDotName, NodeValue, IsClientNode)
end

---------------------------------------- 增end ----------------------------------------

---------------------------------------- 删start ----------------------------------------
---通过节点名删除节点, 叶子节点不会因为值被清空而被移除，需要手动移除
---@param RedDotName string 节点名
function RedDotMgr:DelRedDotByName(RedDotName)
    local DelNode =  self:FindRedDotNodeByName(RedDotName)
    if DelNode then
        self:DelRedDot(DelNode)
        return true
    else
        return false
    end
 end

 ---删除节点（外部正常不需要调用此函数，一般使用DelRedDotByID/DelRedDotByName）
function RedDotMgr:DelRedDot(DelNode)
    ---防止外部调用出错
    if type(DelNode) ~= "table" then
        return
    end
    local ParentNode = DelNode.ParentRedDotNode
    ---根节点不删除
    if nil == ParentNode then
        return
    end
    --- 子节点显示数量，非真实节点数量，用于显示数量
    local NodeNum
    if DelNode.IsLeafNode then
        NodeNum = DelNode.NodeValue or 1
    else
        NodeNum = DelNode.TotalNum or 0
    end
    if not DelNode.IsLeafNode then
        self:DelRedDotAllSubNode(DelNode)
    else
        DelNode.NodeValue = nil
    end
    local SubNodeList = ParentNode.SubRedDotList
    local RemoveIndex
    for Index, Node in pairs(SubNodeList) do
        if Node.RedDotName == DelNode.RedDotName then
            RemoveIndex = Index
        end
    end
    if RemoveIndex then
        SubNodeList[RemoveIndex] = nil
        --- 更新父节点的显示数量
        if ParentNode ~= self.RootRedDotNode and NodeNum ~= 0 then
            ParentNode.TotalNum = ParentNode.TotalNum - NodeNum
            if ParentNode.ParentRedDotNode and ParentNode.ParentRedDotNode ~= self.RootRedDotNode then
                self:SetTotalNumChangeInternal(ParentNode.ParentRedDotNode, -NodeNum)
            end
        end
        --- 更新父节点的子节点数量,此处可能触发递归删除操作，需要放到数据处理完成后执行
        self:SetNodeValueChangeInternal(ParentNode, -1)
        self:SetDirtyNode(ParentNode)
        self:SetDirtyNode(DelNode)
        if DelNode.IsClientNode == true then
            self:SaveDelRedDot(DelNode.RedDotName)
        end
    end
end

 ---删除节点所有子节点
 function RedDotMgr:DelRedDotAllSubNode(DelNode)
    local ParentNode = DelNode.ParentRedDotNode
    ---根节点不删除
    if nil == ParentNode then
        return
    end
    if DelNode.IsLeafNode then
        DelNode.NodeValue = nil
        return
    end
    if DelNode.SubRedDotList then
        for _, Node in pairs(DelNode.SubRedDotList) do
            self:DelRedDotAllSubNode(Node)
            self:SetDirtyNode(Node)
        end
    end
    DelNode.TotalNum = 0
    DelNode.NodeValue = nil
    DelNode.SubRedDotList = nil
    DelNode.AutoNameIndex = nil
end

--- 叶子节点不会因为值被清空而被移除，需要手动移除
---@param RedDotID number 节点名
function RedDotMgr:DelRedDotByID(RedDotID, CheckID)
    local RedDotName = self:GetRedDotNameByID(RedDotID)
        ---CheckID检查，非本系统调用提示/暂时只检查ID,自己组装的没办法获取CheckID，且组装路径存在误调用概率要小一些
        local CfgCheckID =  self:GetRedDotCheckIDByID(RedDotID)
        if CfgCheckID ~= 0 and CfgCheckID ~= nil and CheckID ~= CfgCheckID then
            _G.FLOG_WARNING(string.format("红点跨系统调用 调用CheckID为 %s 配置CheckID为 %s \n %s", tostring(CheckID), tostring(CfgCheckID), debug.traceback()))
        end
    return self:DelRedDotByName(RedDotName)
end


---------------------------------------- 删end ----------------------------------------

---------------------------------------- 改start ----------------------------------------

--- 用于希望其作为叶子节点继续存在，清理子节点，保留此节点
function RedDotMgr:CleanAllSubRedDotByName(RedDotName)
    local FindNode = self:FindRedDotNodeByName(RedDotName)
    self:DelRedDotAllSubNode(FindNode)
    FindNode.NodeValue = 0
    FindNode.IsLeafNode = true
    self:SetDirtyNode(FindNode)
end

--- 只能设置是叶子节点的值，非叶子节点由红点系统维护,叶子节点可以对应界面自己设置，减少开销
---@param RedDotName string 节点名
---@param InNodeValue number 节点值
function RedDotMgr:SetNodeValueByName(RedDotName, InNodeValue)
    local FindNode =  self:FindRedDotNodeByName(RedDotName)
    local IsLeafNode = true
    if FindNode and IsLeafNode then
        local ChangeNum = 0
        local OldNum = FindNode.NodeValue or 1
        if InNodeValue then
            ChangeNum = InNodeValue - OldNum
        end
        FindNode.NodeValue = InNodeValue
        self:SetDirtyNode(FindNode)
        if FindNode.ParentRedDotNode and FindNode.ParentRedDotNode ~= self.RootRedDotNode then
            self:SetTotalNumChangeInternal( FindNode.ParentRedDotNode, ChangeNum)
        end
        return true
    elseif FindNode then
        _G.FLOG_WARNING("RedDotMgr 操作非叶子红点节点值")
    end
    return false
end

--- 非叶子节点由红点系统维护
function RedDotMgr:SetNodeValueChangeInternal(RedDotNode, ChangeValue)
    RedDotNode.NodeValue = RedDotNode.NodeValue + ChangeValue
    if RedDotNode.NodeValue < 0 then
        _G.FLOG_WARNING("RedDotMgr 非法节点值")
    end 
    if RedDotNode.NodeValue == 0  and RedDotNode.IsLeafNode == false then
        self:DelRedDot(RedDotNode)
    end
end

---todo 如果有性能问题，后续改配表，加一列数字红点参数，非数字红点不更新TotalNum
function RedDotMgr:SetTotalNumChangeInternal(RedDotNode, ChangeValue)
    if ChangeValue ~= 0 and RedDotNode ~= self.RootRedDotNode then
        if nil == RedDotNode.TotalNum then
            RedDotNode.TotalNum = 0
        end
        RedDotNode.TotalNum = RedDotNode.TotalNum + ChangeValue
        self:SetDirtyNode(RedDotNode)
        if RedDotNode.ParentRedDotNode and RedDotNode.ParentRedDotNode ~= self.RootRedDotNode then
            self:SetTotalNumChangeInternal( RedDotNode.ParentRedDotNode, ChangeValue)
        end
    end
end

--- 用于希望其作为叶子节点继续存在，清理子节点，保留此节点
function RedDotMgr:CleanAllSubRedDotByID(RedDotID)
    local RedDotName = self:GetRedDotNameByID(RedDotID)
    self:CleanAllSubRedDotByName(RedDotName)
end

--- 只能设置是叶子节点的值，非叶子节点由红点系统维护,叶子节点可以对应界面自己设置，减少开销
---@param RedDotID number 节点ID
---@param InNodeValue number 节点值
function RedDotMgr:SetNodeValueByID(RedDotID, InNodeValue)
    local RedDotName = self:GetRedDotNameByID(RedDotID)
    self:SetNodeValueByName(RedDotName, InNodeValue)
end

---------------------------------------- 改end ----------------------------------------

---------------------------------------- 查start ----------------------------------------
--- 查找节点
function RedDotMgr:FindRedDotNodeByName(RedDotName)
    if nil == RedDotName then
        return
    end
    local SubNamelist =  string.split(RedDotName, "/")
    local FindNode = self.RootRedDotNode
    if self.RootRedDotNode == nil then
        return false
    end
    local PathLength = #SubNamelist
    ---Root节点不查找，从第二级开始
    for i = 2, PathLength do
        local  SubNodeList = FindNode.SubRedDotList
        local IsFind = false
        local CurPathName = "Root"
        for Index = 2, i do
            if SubNamelist[Index] then
                CurPathName = string.format("%s/%s", CurPathName, SubNamelist[Index])
            end
        end
        if SubNodeList then
            for _, Node in pairs(SubNodeList) do
                if i == PathLength then
                    IsFind = RedDotName == Node.RedDotName
                else
                    IsFind = Node.RedDotName == CurPathName
                end
                if IsFind then
                   FindNode = Node
                   break
                end
            end
        end
         if not IsFind then
             return false
         end
    end
     if FindNode ~= self.RootRedDotNode then
        return FindNode
     else
        return false
     end
end

--- 获取节点子节点列表
function RedDotMgr:GetSubRedDotListByName(RedDotName)
    local FindNode =  self:FindRedDotNodeByName(RedDotName)
    if FindNode then
        return FindNode.SubRedDotList
    end
end

--- 获取节点值
function RedDotMgr:GetNodeValueByName(RedDotName)
    local FindNode =  self:FindRedDotNodeByName(RedDotName)
    if FindNode then
        return FindNode.NodeValue
    end
end

--- 获取节点父节点
function RedDotMgr:GetParentRedDotByName(RedDotName)
    local FindNode =  self:FindRedDotNodeByName(RedDotName)
    if FindNode then
        return FindNode.ParentRedDotNode
    end
end

--- 通过节点名查询是否本地已消除红点
function RedDotMgr:GetIsSaveDelRedDotByName(RedDotName)
    if nil == RedDotName then
        return false
    end
    for _, SaveRedDotName in pairs(self.SaveDelNodeNameList) do
        if RedDotName == SaveRedDotName then
            return true
        end
    end
    return false
end

--- 只能设置是叶子节点的值，非叶子节点由红点系统维护,叶子节点可以对应界面自己设置，减少开销
function RedDotMgr:FindRedDotNodeByID(RedDotID)
    local RedDotName = self:GetRedDotNameByID(RedDotID)
    return self:FindRedDotNodeByName(RedDotName)
end

--- 获取节点子节点列表
function RedDotMgr:GetSubRedDotListByID(RedDotID)
    local RedDotName = self:GetRedDotNameByID(RedDotID)
    self:GetSubRedDotListByName(RedDotName)
end

--- 获取节点值
function RedDotMgr:GetNodeValueByID(RedDotID)
    local RedDotName = self:GetRedDotNameByID(RedDotID)
    return self:GetNodeValueByName(RedDotName)
end

--- 获取节点父节点
function RedDotMgr:GetParentRedDotByID(RedDotID)
    local RedDotName = self:GetRedDotNameByID(RedDotID)
    self:GetParentRedDotByName(RedDotName)
end

--- 通过ID获取节点名,查表获取
function RedDotMgr:GetRedDotNameByID(RedDotID)
    local RedDotCfg = ReddotNameCfg:FindCfgByKey(RedDotID)
    if RedDotCfg then
        return RedDotCfg.RedDotName
    end
end

--- 通过ID获取节点CheckID,查表获取
function RedDotMgr:GetRedDotCheckIDByID(RedDotID)
    local RedDotCfg = ReddotNameCfg:FindCfgByKey(RedDotID)
    if RedDotCfg then
        return RedDotCfg.CheckID
    end
end

--- 通过ID查询是否本地已消除红点
function RedDotMgr:GetIsSaveDelRedDotByID(RedDotID)
    local RedDotName = self:GetRedDotNameByID(RedDotID)
    return self:GetIsSaveDelRedDotByName(RedDotName)
end

function RedDotMgr:GetRedDotNameByParentID(ParentRedDotID, SubName)
    if nil == SubName then
        return
    end

    local ParentRedDotName = self:GetRedDotNameByID(ParentRedDotID)
    if nil == ParentRedDotName then
        return
    end

    local Ret = string.format("%s/%s",ParentRedDotName, SubName)
    return Ret
end

--- 获取父节点名
function RedDotMgr:GetParentRedDotNameByName(RedDotName)
    local ParentRedDotName = ""
    if RedDotName then
        local SubNamelist =  string.split(RedDotName, "/")
        local Length = #SubNamelist
        ParentRedDotName = SubNamelist[1]
        if Length >= 3 then
            for i = 2, Length - 1 do
                ParentRedDotName = string.format("%s/%s",ParentRedDotName, SubNamelist[i])
            end
        end
    end
    return ParentRedDotName
end

---------------------------------------- 查end ----------------------------------------

---------------------------------------- 更新start ----------------------------------------
--- 设置脏节点，一帧内统一刷新，防止频繁刷新的性能问题
function RedDotMgr:SetDirtyNode(RedDotNode)
    local ListKeys = self.ListRedDotKeysMap[RedDotNode.RedDotName]
    if ListKeys and #ListKeys > 0 then
        ---添加一下需要更新的列表红点/todo 可能存在不在父节点下面，但是在列表里的，需要处理
        for _, ListKey in ipairs(ListKeys) do
            self:SetDirtyListKey(ListKey)
        end
    end
    for _, SubName in pairs(self.DetryDirtyNodeNameList) do
        if RedDotNode.RedDotName == SubName then
            return
        end
    end
    table.insert(self.DetryDirtyNodeNameList, RedDotNode.RedDotName)
    --self:SendRedUpdateEvent()
    self:RedDotDataUpdate()
end

---延迟一帧发送事件，一帧内不再执行
-- function RedDotMgr:SendRedUpdateEvent()
--     if not self.IsUpdateNextFrame then
--         if self.UpdateNextTimer then
--             self:UnRegisterTimer(self.UpdateNextTimer)
--         end
--         self.IsUpdateNextFrame = true
--         self.UpdateNextTimer = self:RegisterTimer(function ()
--              --- 考虑到事件发送有延迟，保护处理
--             local EventParams = {}
--             for _, SubName in pairs(self.DetryDirtyNodeNameList) do
--                 table.insert(EventParams, SubName)
--             end
--             self.DetryDirtyNodeNameList = {}
--             EventMgr:SendEvent(EventID.RedDotUpdate, EventParams)
--             self.IsUpdateNextFrame = false
--         end, 0.02)
--     end
-- end

---延迟一帧更新数据，一帧内不再执行
function RedDotMgr:RedDotDataUpdate()
    if not self.IsUpdateNextFrame then
        if self.UpdateNextTimer then
            self:UnRegisterTimer(self.UpdateNextTimer)
        end
        self.IsUpdateNextFrame = true
        self.UpdateNextTimer = self:RegisterTimer(function ()
            self:UpdateItemVMData(self.DetryDirtyNodeNameList)
            self.DetryDirtyNodeNameList = {}
            self.IsUpdateNextFrame = false
        end, 0.02)
    end
end
---------------------------------------- 更新end ----------------------------------------

---todo GM 策划GM表配置了，先保留
function RedDotMgr:ChangeRedDotColor()
    -- RedDotDefine.RedDotIsYellow = not RedDotDefine.RedDotIsYellow
    -- EventMgr:SendEvent(EventID.RedDotColorAndStyleUpdate)
end

---todo GM GM 策划GM表配置了，先保留
function RedDotMgr:ChangeRedDotStyle()
    -- RedDotDefine.RedDotIsPointStyle = not RedDotDefine.RedDotIsPointStyle
    -- EventMgr:SendEvent(EventID.RedDotColorAndStyleUpdate)
end

--- GM用 手动添加/删除对应ID的红点
function RedDotMgr:ChangeRedDotStateForGM(ID)
    if not self:DelRedDotByID(ID) then
        self:AddRedDotByID(ID)
    end
end

--- GM用 输出保存的已删除的红点的信息到日志
function RedDotMgr:PrintSaveDelRedDot()
    for _, HideNodeName in ipairs(self.SaveDelNodeNameList) do
        print("RedDotSave:"..HideNodeName)
    end
end

--- GM用 输出保存的SaveKey信息到日志
function RedDotMgr:PrintSaveDelRedDotBySaveKey()
    local HideRedDotStr = USaveMgr.GetString(SaveKey.HideRedDot, "", true)
    print("RedDotSave:"..HideRedDotStr)
end

--- GM用 输出当前红点树的所有红点到日志
function RedDotMgr:PrintAllRedDotName()
    self:PrintAllSubRedDot(self.RootRedDotNode)
end

--- GM用 输出当前红点节点的所有子红点到日志
function RedDotMgr:PrintAllSubRedDot(RedDotNode)
    local SubNodeList = RedDotNode.SubRedDotList
    if SubNodeList and #SubNodeList > 0 then
        for _, SubNode in pairs(SubNodeList) do
            print(string.format("AllRedDotPrint:%s NodeValue:%s TotalNum:%s", SubNode.RedDotName, tostring(SubNode.NodeValue), tostring(SubNode.TotalNum)))
            self:PrintAllSubRedDot(SubNode)
        end
    end
end
-------------------------------------------------------------------------------------------------------

---------------------------------------- 数字红点接口Start ----------------------------------------

---通过红点ID设置节点值（自动添加和删除）
---@param RedDotID number @节点ID
---@param InNodeValue number @节点值
--- @param IsClientNode boolean @是否是客户端保存节点
function RedDotMgr:SetRedDotNodeValueByID(RedDotID, InNodeValue, IsClientNode)
    if self:FindRedDotNodeByID(RedDotID) then
        if InNodeValue <= 0 then
            self:DelRedDotByID(RedDotID)

        else
            self:SetNodeValueByID(RedDotID, InNodeValue)
        end
    else
        if InNodeValue > 0 then
            self:AddRedDotByID(RedDotID, InNodeValue, IsClientNode)
        end
    end
end

---通过红点名设置节点值（自动添加和删除）
---@param RedDotName string @节点名
---@param InNodeValue number @节点值
--- @param IsClientNode boolean @是否是客户端保存节点
function RedDotMgr:SetRedDotNodeValueByName(RedDotName, InNodeValue, IsClientNode)
    if self:FindRedDotNodeByName(RedDotName) then
        if InNodeValue <= 0 then
            self:DelRedDotByName(RedDotName)

        else
            self:SetNodeValueByName(RedDotName, InNodeValue)
        end
    else
        if InNodeValue > 0 then
            self:AddRedDotByName(RedDotName, InNodeValue, IsClientNode)
        end
    end
end

---设置节点值通过父节点ID（自动添加和删除）
---@param RedDotID number @父节点ID
---@param RedDotSubName string @子节点路径对应子字符串
---@param InNodeValue number @节点值
---@param IsClientNode boolean @是否是客户端保存节点
function RedDotMgr:SetRedDotNodeValueByParentID(ParentRedDotID, RedDotSubName, InNodeValue, IsClientNode)
    local ParentRedDotName = self:GetRedDotNameByID(ParentRedDotID)
    if nil == ParentRedDotName then
        return
    end
    local SubName
    if RedDotSubName then
        SubName = string.format("%s/%s",ParentRedDotName, RedDotSubName)
        if self:FindRedDotNodeByName(SubName) then
            if InNodeValue <= 0 then
                self:DelRedDotByName(SubName)
            else
                self:SetNodeValueByName(SubName, InNodeValue)
            end
        else
            if InNodeValue > 0 then
                self:AddRedDotByName(SubName, InNodeValue, IsClientNode)
            end
        end
    elseif InNodeValue > 0 then
        SubName = self:AddRedDotByParentRedDotName(ParentRedDotName, InNodeValue, IsClientNode)
    end
    return SubName
end

----------------------------------------数字红点接口end ----------------------------------------

----------------------------------------ItemVM数据更新start ------------------------------------
---在mgr维护一个显示中的VmMap，方便查询更新，由于性能原因，红点数据更新不走事件
---@param ItemVM RedDotItemVM @红点ItemVM
function RedDotMgr:AddRedDotItemVM(ItemVM)
    if ItemVM then
        local RedDotName = ItemVM:GetRedDotName()
        if RedDotName and self.ItemVMMap then
            --self.ItemVMMap[RedDotName] = ItemVM
            ---可能存在多个同名的ItemVM，由于ItemVM创建和绑定的时机无法保证获取到红点名，改为用表存储多个ItemVM
            if not self.ItemVMMap[RedDotName] then
                self.ItemVMMap[RedDotName] = {}
            else
                --- 防止重复添加
                for _, ReddotItemVM in ipairs(self.ItemVMMap[RedDotName]) do
                    if ReddotItemVM == ItemVM then
                        return
                    end
                end
            end
            table.insert(self.ItemVMMap[RedDotName], ItemVM)
        end
    end
end

---@param Name string @红点名
function RedDotMgr:RemoveRedDotItemVM(ItemVM)
    local Name
    if ItemVM then
        Name = ItemVM:GetRedDotName()
    end
    if not Name then
        return
    end
    if self.ItemVMMap and Name and self.ItemVMMap[Name]  then
        --self.ItemVMMap[Name] = nil
        local RemoveIndex
        for Index, ReddotItemVM in ipairs(self.ItemVMMap[Name]) do
            if ReddotItemVM == ItemVM then
                RemoveIndex = Index
                break
            end
        end
        if RemoveIndex then
            table.remove(self.ItemVMMap[Name], RemoveIndex)
        end
    end
end

---@param ItemVM string @红点VM
function RedDotMgr:FindRedDotItemVM(ItemVM)
    local Name
    if ItemVM then
        Name = ItemVM:GetRedDotName()
    end
    if not Name then
        return
    end
    if self.ItemVMMap and Name and self.ItemVMMap[Name]  then
        --self.ItemVMMap[Name] = nil
        local RemoveIndex
        for Index, ReddotItemVM in ipairs(self.ItemVMMap[Name]) do
            if ReddotItemVM == ItemVM then
                RemoveIndex = Index
                break
            end
        end
        if RemoveIndex then
            return true
        end
    end
    return false
end

function RedDotMgr:UpdateItemVMData(DetryDirtyNodeNameList)
    if self.ItemVMMap then
        for _, SubName in pairs(DetryDirtyNodeNameList) do
            local ItemVMArray = self.ItemVMMap[SubName]
            if ItemVMArray then
                --ItemVM:UpdateNodeDataByName(SubName)
                for _, ReddotItemVM in ipairs(ItemVMArray) do
                    ReddotItemVM:UpdateNodeDataByName(SubName)
                end
            end
        end
    end

end
----------------------------------------ItemVM数据更新end --------------------------------------
----------------------------------------列表红点 start --------------------------------------
----------------------------------------Add/Create start --------------------------------------
-- ---动态创建对应列表的所有边界红点
-- function RedDotMgr:CreateAllListReddotByListKey(ListKey, View, Panel, TriggerWidget, ShowType, Offset)
--     local ListReddots = {}
--     local ListRedDotShowType = RedDotDefine.ListRedDotPosMap[ShowType]
--     for _, PosType in pairs(ListRedDotShowType) do
--         local BorderRedDotView = self:CreateListReddotByListKey(ListKey, View, Panel, TriggerWidget, PosType, Offset)
--         ListReddots[PosType] = BorderRedDotView
--     end
--     return ListReddots
-- end

-- ---动态创建列表红点
-- function RedDotMgr:CreateListReddotByListKey(ListKey, View, Panel, TriggerWidget, PosType, Offset)
--     ---显示处理
--     local PanelWidget = Panel
--     local BorderRedDotPath = RedDotDefine.BorderRedDotPath
--     local BorderRedDotView = _G.UIViewMgr:CreateViewByName(BorderRedDotPath, nil, View, true, true)
--     PanelWidget:AddChildToCanvas(BorderRedDotView)
--     UIUtil.CanvasSlotSetSize(BorderRedDotView, _G.UE.FVector2D(0, 0))
--     --BorderRedDotView:SetPos(TriggerWidget, Offset, PosType)
--     self:RegisterTimer(function() 
--         BorderRedDotView:SetPos(TriggerWidget, Offset, PosType)
--     end, 0, 1, 1)
--     BorderRedDotView:SetListKey(ListKey)
--     --UIUtil.CanvasSlotSetZOrder(BorderRedDotView, 1)
--     return BorderRedDotView
-- end

---在红点节点上添加列表ID并返回，用于初始化数据
function RedDotMgr:AddNewListKeyByID(ParentNodeID, ShowType)
    local Name = self:GetRedDotNameByID(ParentNodeID)
    if Name then
        return self:AddNewListKeyByName(Name, ShowType)
    end
end

---在红点节点上添加列表ID并返回，用于初始化数据
function RedDotMgr:AddNewListKeyByName(ParentNodeName, ShowType)
    if ParentNodeName then
        local Type = ShowType or RedDotDefine.ListRedDotStyleType.TopAndBottom
        local ListKey = self:GetNewListKeyByName(ParentNodeName)
        self:AddListKeyToMapByName(ParentNodeName, ListKey)
        self:AddListRedDotBaseDataByKey(ListKey, RedDotDefine.ListRedDotPosMap[Type], ParentNodeName)
        return ListKey
    end
end

---存储红点的列表位置数据
function RedDotMgr:AddListRedDotIndexData(ListKey, RedDotName, Pos)
    self:CheckandCreateListDataByListKey(ListKey)
    if self.ListRedDotDataMap[ListKey].PosData == nil then
        self.ListRedDotDataMap[ListKey].PosData = {}
    end
    self.ListRedDotDataMap[ListKey].PosData[RedDotName] = Pos
    self:CheckIshaveNoSubNodeAndAddListKey(ListKey, RedDotName)
end

---批量存储红点的列表位置数据
---@param PosData table {RedDotName = Pos}
function RedDotMgr:AddBatchListRedDotIndexData(ListKey, PosData)
    self:CheckandCreateListDataByListKey(ListKey)
    self.ListRedDotDataMap[ListKey].PosData = PosData
    self:BatchCheckIshaveNoSubNodeAndAddListKey(ListKey)
end

---存储列表红点类型
function RedDotMgr:AddListRedDotTypeByKey(ListKey, Type)
    self:CheckandCreateListDataByListKey(ListKey)
    self.ListRedDotDataMap[ListKey].ListRedDotType = Type
end

---存储列表红点偏移
function RedDotMgr:AddListRedDotOffsetByKey(ListKey, Offset)
    self:CheckandCreateListDataByListKey(ListKey)
    self.ListRedDotDataMap[ListKey].Offset = Offset
end

---存储列表红点基础数据
function RedDotMgr:AddListRedDotBaseDataByKey(ListKey, Type, ParentNodeName)
    self:CheckandCreateListDataByListKey(ListKey)
    self.ListRedDotDataMap[ListKey].ListRedDotType = Type
    self.ListRedDotDataMap[ListKey].ParentNodeName = ParentNodeName
end

---存储列表红点全量数据
function RedDotMgr:AddListRedDotAllDataByKey(ListKey, Type, ParentNodeName, Offset, PosData)
    self:CheckandCreateListDataByListKey(ListKey)
    self.ListRedDotDataMap[ListKey].ListRedDotType = Type
    self.ListRedDotDataMap[ListKey].ParentNodeName = ParentNodeName
    self.ListRedDotDataMap[ListKey].Offset = Offset
    self.ListRedDotDataMap[ListKey].PosData = PosData
    self:BatchCheckIshaveNoSubNodeAndAddListKey(ListKey)
end

---在列表红点更新map上添加列表红点Key，用于更新
function RedDotMgr:AddListKeyToMapByName(NodeName, ListKey)
    if self.ListRedDotKeysMap == nil then
        self.ListRedDotKeysMap = {}
    end
    if self.ListRedDotKeysMap[NodeName] == nil then
        self.ListRedDotKeysMap[NodeName] = {}
    end
    local Ishave = table.find_by_predicate(self.ListRedDotKeysMap[NodeName], function(A)
        return A == ListKey
    end)
    if not Ishave then
        table.insert(self.ListRedDotKeysMap[NodeName], ListKey)
    end
end

-- ---添加触发的列表view,使用记得判断是否有效
-- function RedDotMgr:AddListRedDotTriggerViewByKey(ListKey, TriggerView,  TriggerWidget)
--     self:CheckandCreateListDataByListKey(ListKey)
--     if TriggerView and TriggerView.Object:IsValid() then
--         self.ListRedDotDataMap[ListKey].TriggerView = TriggerView
--         self.ListRedDotDataMap[ListKey].TriggerWidget = TriggerWidget
--     end
-- end

---检查对应列表红点数据，没有就创建空表
function RedDotMgr:CheckandCreateListDataByListKey(ListKey)
    if self.ListRedDotDataMap == nil then
        self.ListRedDotDataMap = {}
    end
    if self.ListRedDotDataMap[ListKey] == nil then
        self.ListRedDotDataMap[ListKey] = {}
    end
end

---批量检查对应列表红点数据，如果有非当前父节点的列表子红点，添加进更新表
function RedDotMgr:BatchCheckIshaveNoSubNodeAndAddListKey(ListKey)
    if self.ListRedDotDataMap == nil then
        self.ListRedDotDataMap = {}
    end
    if self.ListRedDotDataMap[ListKey] == nil then
        self.ListRedDotDataMap[ListKey] = {}
    end
    if self.ListRedDotDataMap[ListKey].PosData then
        for Name, _ in pairs(self.ListRedDotDataMap[ListKey].PosData) do
            self:CheckIshaveNoSubNodeAndAddListKey(ListKey, Name)
        end
    end
end

--检查是否是非当前父节点的列表子红点，如果是，添加进更新表
function RedDotMgr:CheckIshaveNoSubNodeAndAddListKey(ListKey, RedDotName)
    local ParentNodeName = self.ListRedDotDataMap[ListKey].ParentNodeName
    if ParentNodeName then
        local IsCurSubNode = self:GetParentRedDotNameByName(RedDotName) == ParentNodeName
        if IsCurSubNode then
            self:AddListKeyToMapByName(RedDotName, ListKey)
        end
    end
end

----------------------------------------Add/Create end --------------------------------------
----------------------------------------Del/Remove start --------------------------------------

---清理对应列表位置数据
function RedDotMgr:ClearListIndexData(ListKey)
    if self.ListRedDotDataMap == nil then
        return
    end
    self.ListRedDotDataMap[ListKey] = nil
end

---在列表红点key表上删除列表ID/低频操作，目前想不到会有红点突然不是列表父红点了
function RedDotMgr:DelListKeyToNode(ParentNode, ListKey)
    if self.ListRedDotKeysMap == nil then
        return
    end
    if self.ListRedDotKeysMap[ParentNode.RedDotName] == nil then
        return
    end
    local Ishave, Index = table.find_by_predicate(self.ListRedDotKeysMap[ParentNode.RedDotName], function(A)
        return A == ListKey
    end)
    if Ishave then
        table.remove(self.ListRedDotKeysMap[ParentNode.RedDotName], Index)
    end
end

----------------------------------------Del/Remove end--------------------------------------
-------------------------------------Find/Get start --------------------------------------
---获取一个新的listid，并创建空表
function RedDotMgr:GetNewListKeyByName(Name)
    if self.ListRedDotDataMap == nil then
        self.ListRedDotDataMap = {}
        self.ListRedDotDataMap[Name] = {}
        return Name
    end
    if self.ListRedDotDataMap[Name] == nil then
        self.ListRedDotDataMap[Name] = {}
        return Name
    else
        return self:GetNewListIDByOldKey(Name, 1)
    end
end

---获取一个新的listid
function RedDotMgr:GetNewListIDByOldKey(OldKey, Count)
    local Key = string.format("%s%s", OldKey, tostring(Count))
    if self.ListRedDotDataMap[Key] == nil then
        self.ListRedDotDataMap[Key] = {}
        return Key
    else
        return self:GetNewListIDByOldKey(Key, Count + 1)
    end
end

---获取对应列表红点数据
function RedDotMgr:GetListRedDotDataByListKey(ListKey)
    if self.ListRedDotDataMap == nil then
        return nil
    end
    if self.ListRedDotDataMap[ListKey] == nil then
        return nil
    else
        return self.ListRedDotDataMap[ListKey]
    end
end

-------------------------------------Find/Get end --------------------------------------
-------------------------------------Updata Start --------------------------------------
--- 设置脏节点，一帧内统一刷新，防止频繁刷新的性能问题/考虑到滑动时，更新操作可能频繁，后续有性能问题考虑延长更新间隔
function RedDotMgr:SetDirtyListKey(ListKey)
    for _, DirtyListKey in pairs(self.DetryDirtyListKeyList) do
        if ListKey == DirtyListKey then
            return
        end
    end
    table.insert(self.DetryDirtyListKeyList, ListKey)
    self:ListRedDotDataUpdate()
end

---延迟一帧发送事件，一帧内不再执行
function RedDotMgr:ListRedDotDataUpdate()
    if not self.IsUpdateListRedDotDNextFrame then
        if self.UpdateListRedDotNextTimer then
            self:UnRegisterTimer(self.UpdateListRedDotNextTimer)
        end
        self.IsUpdateListRedDotDNextFrame = true
        self.UpdateListRedDotextTimer = self:RegisterTimer(function ()
            self:UpdateListRedDotData(self.DetryDirtyListKeyList)
            self.DetryDirtyListKeyList = {}
            self.IsUpdateListRedDotDNextFrame = false
        end, 0.02)
    end
end

function RedDotMgr:UpdataListRedDotByListKey(ListKey)
    local MiniShowIndex
    local MiniHideIndex
    local MaxShowIndex
    local MaxHideIndex
    if self.ListRedDotDataMap and self.ListRedDotDataMap[ListKey] and self.ListRedDotDataMap[ListKey].PosData then
        local PosData = self.ListRedDotDataMap[ListKey].PosData
        local ParentNodeName = self.ListRedDotDataMap[ListKey].ParentNodeName
        local ParentNode = self:FindRedDotNodeByName(ParentNodeName)
        local SubNodeList
        ---可能存在列表中的红点的父节点不是同一个的情况，不能用父节点做显隐判断
        if ParentNode then
            SubNodeList = ParentNode.SubRedDotList
        end
        for Name, Pos in pairs(PosData) do
            local ItemVMArray = self.ItemVMMap[Name]
            local IsShow = false
            if ItemVMArray then
                for _, ReddotItemVM in ipairs(ItemVMArray) do
                    local ItemVMListKey = ReddotItemVM:GetListKey()
                    if ItemVMListKey == ListKey then
                        ---列表中可能存在无红点名的红点view，不能依靠itemvm遍历来确定显示区域
                        IsShow = true
                        break
                    end
                end
            end
            ---未显示节点，判断红点是否是激活但是被隐藏
            if not IsShow then
                ---是子节点用子节点列表查，特殊情况直接去红点树查
                local IsCurSubNode = self:GetParentRedDotNameByName(Name) == ParentNodeName
                local SubNode
                if IsCurSubNode and SubNodeList then
                    SubNode = table.find_by_predicate(SubNodeList, function(Node)
                        return Node.RedDotName == Name
                    end)
                else
                    SubNode = self:FindRedDotNodeByName(Name)
                end
                if SubNode then
                    --table.insert()
                    ---遍历出最小未显示激活红点
                    if MiniHideIndex then
                        MiniHideIndex = MiniHideIndex < Pos and MiniHideIndex or Pos
                    else
                        MiniHideIndex = Pos
                    end
                    ---遍历出最大未显示激活红点
                    if MaxHideIndex then
                        MaxHideIndex = MaxHideIndex > Pos and MaxHideIndex or Pos
                    else
                        MaxHideIndex = Pos
                    end
                end
            end
        end
        ---存在被隐藏的激活红点
        if MaxHideIndex or MiniHideIndex then
            MiniShowIndex = self.ListRedDotDataMap[ListKey].MiniShowIndex
            MaxShowIndex = self.ListRedDotDataMap[ListKey].MaxShowIndex
            if not MiniShowIndex or not MaxShowIndex then
                return
            end
            ---判断显示情况
            if MaxHideIndex < MiniShowIndex then
                ---只显示小于侧编辑红点 Top/Left
                self.ListRedDotDataMap[ListKey].MiniShow = true
                self.ListRedDotDataMap[ListKey].MaxShow = false
            elseif MiniHideIndex > MaxShowIndex then
                ---只显示大于侧编辑红点 Bottom/Right
                self.ListRedDotDataMap[ListKey].MiniShow = false
                self.ListRedDotDataMap[ListKey].MaxShow = true
            else
                ---两侧都有
                self.ListRedDotDataMap[ListKey].MiniShow = true
                self.ListRedDotDataMap[ListKey].MaxShow = true
            end
    
        else
            self.ListRedDotDataMap[ListKey].MiniShow = false
            self.ListRedDotDataMap[ListKey].MaxShow = false

        end
        if self.BorderRedDotViewMap and self.BorderRedDotViewMap[ListKey] then
            for _, View in pairs(self.BorderRedDotViewMap[ListKey]) do
                if View.Object:IsValid() then
                    View:UpdataIsShowByListKey(ListKey)
                end
            end
        end
    end
end

function RedDotMgr:UpdateListRedDotData(DetryDirtyListKeyList)
    for _, ListKey in ipairs(DetryDirtyListKeyList) do
        self:UpdataListRedDotByListKey(ListKey)
    end
end

----更新列表的显示范围 --todo 优化 一帧执行一次/需要保证在列表红点更新前
function RedDotMgr:UpdateShowIndexByOnShow(ListKey, Index)
    self:CheckandCreateListDataByListKey(ListKey)
    if self.ListRedDotDataMap[ListKey].ShowIndexList == nil then
        self.ListRedDotDataMap[ListKey].ShowIndexList = {}
    end
    local IsHave = self.ListRedDotDataMap[ListKey].ShowIndexList[Index]
    self.ListRedDotDataMap[ListKey].ShowIndexList[Index] = true
    if not IsHave then
        local MiniShowIndex =  self.ListRedDotDataMap[ListKey].MiniShowIndex
        if  MiniShowIndex then
            self.ListRedDotDataMap[ListKey].MiniShowIndex = MiniShowIndex < Index and MiniShowIndex or Index
        else
            self.ListRedDotDataMap[ListKey].MiniShowIndex = Index
        end
        local MaxShowIndex =  self.ListRedDotDataMap[ListKey].MaxShowIndex
        if  MaxShowIndex then
            self.ListRedDotDataMap[ListKey].MaxShowIndex = MaxShowIndex > Index and MaxShowIndex or Index
        else
            self.ListRedDotDataMap[ListKey].MaxShowIndex = Index
        end
    end
end

----更新列表的显示范围 --todo 优化 一帧执行一次/需要保证在列表红点更新前
function RedDotMgr:UpdateShowIndexByOnHide(ListKey, Index)
    self:CheckandCreateListDataByListKey(ListKey)
    if self.ListRedDotDataMap[ListKey].ShowIndexList == nil then
        self.ListRedDotDataMap[ListKey].ShowIndexList = {}
        self.ListRedDotDataMap[ListKey].MiniShowIndex = nil
        self.ListRedDotDataMap[ListKey].MaxShowIndex = nil
        return
    end
    local IsHave = self.ListRedDotDataMap[ListKey].ShowIndexList[Index]
    self.ListRedDotDataMap[ListKey].ShowIndexList[Index] = false
    if IsHave then
        local MiniShowIndex =  self.ListRedDotDataMap[ListKey].MiniShowIndex
        local MaxShowIndex =  self.ListRedDotDataMap[ListKey].MaxShowIndex
        if  MiniShowIndex and MiniShowIndex <= Index and MaxShowIndex and Index <= MaxShowIndex then
            ---如果hide的是在显示范围内的item，做一次显示范围的更新
            MiniShowIndex = nil
            MaxShowIndex = nil
            for ShowIndex, IsShow in pairs( self.ListRedDotDataMap[ListKey].ShowIndexList) do
                if IsShow then
                    if  MiniShowIndex then
                        MiniShowIndex = MiniShowIndex < ShowIndex and MiniShowIndex or ShowIndex
                    else
                        MiniShowIndex = ShowIndex
                    end
                    if  MaxShowIndex then
                        MaxShowIndex = MaxShowIndex > ShowIndex and MaxShowIndex or ShowIndex
                    else
                        MaxShowIndex = ShowIndex
                    end
                end
            end
            self.ListRedDotDataMap[ListKey].MiniShowIndex = MiniShowIndex
            self.ListRedDotDataMap[ListKey].MaxShowIndex = MaxShowIndex
        end
    end
end

function RedDotMgr:CollectBorderRedDotViewByShow(View)
    if self.BorderRedDotViewMap == nil then
        self.BorderRedDotViewMap = {}
    end
    local ListKey = View.ListKey
    local Type = View.Type
    if ListKey and View.Object:IsValid() and Type then
        if self.BorderRedDotViewMap[ListKey] == nil then
            self.BorderRedDotViewMap[ListKey] = {}
        end
        self.BorderRedDotViewMap[ListKey][Type] = View
    end
end

function RedDotMgr:RemoveBorderRedDotViewByHide(ListKey)
    if self.BorderRedDotViewMap == nil then
        return
    end
    self.BorderRedDotViewMap[ListKey] = nil
end
-------------------------------------Updata End ----------------------------------------

----------------------------------------列表红点 end --------------------------------------
return RedDotMgr