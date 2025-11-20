--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2025-08-19 11:24:02
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-08-19 14:37:01
FilePath: \Client\Source\Script\Game\StarlightCelebration\StarLightNewYearActivityMgr.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local MajorUtil = require("Utils/MajorUtil")
local ChatDefine = require("Game/Chat/ChatDefine")
local ProtoRes = require("Protocol/ProtoRes")
local TimeUtil = require("Utils/TimeUtil")
local MapMainCityCfg = require("TableCfg/MapMainCityCfg")
local CrystalPortalCfg = require("TableCfg/TeleportCrystalCfg")
local CrystalPortalMgr = require("Game/PWorld/CrystalPortal/CrystalPortalMgr")
local ProtoCS = require("Protocol/ProtoCS")
local NodeType = ProtoRes.Game.ActivityNodeType

---@class StarLightNewYearActivityMgr : MgrBase
local StarLightNewYearActivityMgr = LuaClass(MgrBase)

function StarLightNewYearActivityMgr:Ctor()

end

function StarLightNewYearActivityMgr:OnInit()
    self.RegisteredGameEvent = false
    self.UnRegisteredGameEvent = false
end

function StarLightNewYearActivityMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.OpsActivityUpdate, self.OnOpsActivityUpdateInfo)
    self:RegisterGameEvent(_G.EventID.OpsActivityUpdateInfo, self.OnOpsActivityUpdateInfo)
end

--节点开启后 开始监听
function StarLightNewYearActivityMgr:OnOpsActivityUpdateInfo()
    if self.RegisteredGameEvent then
        return
    end
    local Activity = _G.OpsSeasonActivityMgr:GetSeasonActivity()
    if Activity ~= nil and Activity.BPName == "StarlightCelebration/StarlightCelebrationMain_UIBP" then
        local Detail = _G.OpsActivityMgr.ActivityNodeMap[Activity.ActivityID] or {}
        local NodeList = Detail.NodeList or {}
        local Node, ActivityNode = _G.OpsSeasonActivityMgr:NodeByNodeTitle(NodeList, _G.LSTR(1700045))
        if Node and ActivityNode then
            self.NodeCfg = ActivityNode
            self.NodeParams = Node
            local StartTime = _G.OpsActivityMgr:GetTimeStampByTimeStr(ActivityNode.StartTime)
            if StartTime <= TimeUtil.GetServerLogicTime() then
                self:RegisterGameEvent(_G.EventID.ChatMsgPushed, self.OnChatSharePush)
                self.RegisteredGameEvent = true
            end
        end
    end
end

--节点结束后/已发送后 取消监听
function StarLightNewYearActivityMgr:UnRegisterChatShareGameEvent()
    if self.UnRegisteredGameEvent then
        return
    end
    self:UnRegisterGameEvent(_G.EventID.ChatMsgPushed, self.OnChatSharePush)
    self.UnRegisteredGameEvent = true
end

---@type 发送成功后上报节点
function StarLightNewYearActivityMgr:OnChatSharePush(Data)
    if self.NodeCfg == nil or Data == nil or Data.Channel == nil or Data.Msg == nil or Data.Fail then
		return
    end

	--活动时间到了就不再上报
	local EndTime = _G.OpsActivityMgr:GetTimeStampByTimeStr(self.NodeCfg.EndTime)
	if EndTime <= TimeUtil.GetServerLogicTime() then
		self:UnRegisterChatShareGameEvent()
	end
	
	if Data.Msg.Sender ~= MajorUtil.GetMajorRoleID() then
		return
	end

    -- 容错处理:允许首尾空格差异
    local SendContent = Data.Msg.Data and Data.Msg.Data.Content and Data.Msg.Data.Content:gsub("^%s*(.-)%s*$", "%1")
    if SendContent ~= self.NodeCfg.StrParam then
        return
    end
    
	-- 区域频道
	if not (Data.Channel.Type and Data.Channel.Type == ChatDefine.ChatChannel.Area) then
		return
	end
	
	-- 需在主城
	if not self:IsInMainCity() then
		return
	end

	if self.NodeCfg.Params and self.NodeCfg.Params[1] then 
		_G.OpsActivityMgr:SendActivityEventReport(NodeType.ActivityNodeTypeCommClientReport, {self.NodeCfg.Params[1]})
	end
end

---@type 是否在主城
function StarLightNewYearActivityMgr:IsInMainCity()
	local CurrMapID = _G.PWorldMgr:GetCurrMapResID()
	local UIMapID = _G.MapMgr:GetUIMapID()
	local AllCfg = MapMainCityCfg:FindAllCfg()
	if AllCfg ~= nil and #AllCfg > 0 then
		for _, MapMainCityCfgData in ipairs(AllCfg) do
			if table.contain(MapMainCityCfgData.MapIDList, CurrMapID)
				and table.contain(MapMainCityCfgData.UIMapIDList, UIMapID) then
				return true
			end
		end
	end
	return false
end

---@type 前往任意主城_并选中大水晶
function StarLightNewYearActivityMgr:ShowWorldMapSelectCrystal()
	local CrystalID = nil
	local ToMapID = nil

	local AllCfg = MapMainCityCfg:FindAllCfg()
	for _, MapMainCityCfgData in ipairs(AllCfg) do
		for _, MapID in pairs(MapMainCityCfgData.MapIDList) do
			local CrystalCfgs =  CrystalPortalCfg:FindAllCfg(string.format("MapID = %d AND Type = %d", MapID, ProtoRes.TELEPORT_CRYSTAL_TYPE.TELEPORT_CRYSTAL_ACROSSMAP)) or {}
			if #CrystalCfgs > 0 then
				for _, Cfg in ipairs(CrystalCfgs) do
					--优先选激活的水晶
					if CrystalPortalMgr:IsExistActiveCrystal(Cfg.ID) then
						_G.WorldMapMgr:ShowWorldMapCrystal(MapID, Cfg.ID)
						return
					end
					if CrystalID == nil then
						CrystalID = Cfg.ID
						ToMapID = MapID
					end
				end
			end
		end
	end
	_G.WorldMapMgr:ShowWorldMapCrystal(ToMapID, CrystalID)
end


return StarLightNewYearActivityMgr
