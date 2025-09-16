-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class TitleCfg : CfgBase
local TitleCfg = {
	TableName = "c_Title_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'MaleName',
            },
            {
                Name = 'FemaleName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(TitleCfg, { __index = CfgBase })

TitleCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

--[[
	int32   ID = 1[(org.xresloader.ue.key_tag) = 1];
	string  MaleName = 2;
	string  FemaleName = 3;
	int32   priority = 4;
	bool    Front = 5;     // 1 是名称上  0 是名称下显示
	bool    Display = 6;   // 1 未获得不能显示在列表中   0 未获取也可以显示在列表中
	int32   ConditionType = 7;
	string  Type = 8;
	string  Condition = 9;
]]--

function TitleCfg:GetTypeList( )
	local AllCfg = self:FindAllCfg()
	local TypeList = {}
	for _, Value in pairs(AllCfg) do
		if not table.contain(TypeList, Value.Type) then
			table.insert(TypeList, Value.Type )
		end
	end
	return TypeList
end


return TitleCfg
