-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ActivityCfg : CfgBase
local ActivityCfg = {
	TableName = "c_activity_cfg",
    LruKeyType = "integer",
	KeyName = "ActivityID",
    bEncrypted = true,
	Localization = {
        Config = {
            {
                Name = 'PageName',
            },
            {
                Name = 'Title',
            },
            {
                Name = 'SubTitle',
            },
            {
                Name = 'Info',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(ActivityCfg, { __index = CfgBase })

ActivityCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function ActivityCfg:FindCfgByKey(ID)
	if nil == ID then
		return
	end
    local IDIPData = _G.OpsActivityMgr:FindActivityCfgByIDIP(ID)
    if IDIPData ~= nil then
        return IDIPData
    end

    return CfgBase.FindCfgByKey(self, ID)
end

--活动配置有部分数据走idip 所以屏蔽不支持该方法
function ActivityCfg:FindCfg(SearchConditions)
end

--活动配置有部分数据走idip 所以屏蔽不支持该方法
function ActivityCfg:FindAllCfg(SearchConditions)
end

--只查询本地表格，不会有idip数据 需要确定数据不走idip才可以用
function ActivityCfg:FindLocalAllCfg(SearchConditions)
    local Cfg = CfgBase.FindAllCfg(self, SearchConditions)

    return Cfg
end

return ActivityCfg
