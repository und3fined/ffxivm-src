-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ActivityNodeCfg : CfgBase
local ActivityNodeCfg = {
	TableName = "c_activity_node_cfg",
    LruKeyType = "integer",
	KeyName = "NodeID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'NodeTitle',
            },
            {
                Name = 'NodeDesc',
            },
            {
                Name = 'NodeRule',
            },
            {
                Name = 'JumpButton',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(ActivityNodeCfg, { __index = CfgBase })

ActivityNodeCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY


function ActivityNodeCfg:FindCfgByKey(ID)
	if nil == ID then
		return
	end
    local IDIPData = _G.OpsActivityMgr:FindActivityNodeCfgByIDIP(ID)
    if IDIPData ~= nil then
        return IDIPData
    end

    return CfgBase.FindCfgByKey(self, ID)
end


--活动配置有部分数据走idip 所以屏蔽不支持该方法
function ActivityNodeCfg:FindCfg(SearchConditions)
end

--活动配置有部分数据走idip 所以屏蔽不支持该方法
function ActivityNodeCfg:FindAllCfg(SearchConditions)
end

return ActivityNodeCfg
