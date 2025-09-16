-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FashionDecorateSkillCfg : CfgBase
local FashionDecorateSkillCfg = {
	TableName = "c_FashionDecorateSkill_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'SkillName',
            },
		}
    },
    DefaultValues = {
        HumanActiontimeline = 'ornament_sp/m6001/onm_sp01',
        ID = 1,
        Icon = 'Texture2D\'/Game/Assets/Icon/ItemIcon/008000/UI_Icon_008104.UI_Icon_008104\'',
        OtherActiontimeline = '',
        cd = 0,
    },
	LuaData = {
        {
            Icon = 'Texture2D\'/Game/Assets/Icon/ItemIcon/008000/UI_Icon_008103.UI_Icon_008103\'',
        },
        {
            HumanActiontimeline = 'ornament_sp/m6001/onm_sp02',
            ID = 2,
            Icon = 'Texture2D\'/Game/Assets/Icon/ItemIcon/008000/UI_Icon_008102.UI_Icon_008102\'',
        },
        {
            HumanActiontimeline = 'org/cblm_onm_sp01',
            ID = 3,
            OtherActiontimeline = 'org/ornament_sp/m90009/cblm_sp01_l',
        },
        {
            HumanActiontimeline = 'normal/item_start',
            ID = 4,
            Icon = '',
        },
        {
            HumanActiontimeline = '',
            ID = 5,
            Icon = '',
        },
        {
            HumanActiontimeline = 'org/org_cblm_onm_sp01',
            ID = 6,
            OtherActiontimeline = 'org/ornament_sp/m6003/cblm_sp01_n',
        },
	},
}

setmetatable(FashionDecorateSkillCfg, { __index = CfgBase })

FashionDecorateSkillCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return FashionDecorateSkillCfg
