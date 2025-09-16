-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ClosetClassifyCfg : CfgBase
local ClosetClassifyCfg = {
	TableName = "c_closet_classify_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'SubID',
            },
		}
    },
    DefaultValues = {
        ID = 1,
        Icon = 'Texture2D\'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Ring_Noraml.UI_Icon_Tab_Bag_Equip_Ring_Noraml\'',
        SelectIcon = 'Texture2D\'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Ring_Select.UI_Icon_Tab_Bag_Equip_Ring_Select\'',
        SuitIcon = '',
        _SubIDNum = 3,
    },
	LuaData = {
        {
            Icon = 'Texture2D\'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Master_Noraml.UI_Icon_Tab_Bag_Equip_Master_Noraml\'',
            SelectIcon = 'Texture2D\'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Master_Select.UI_Icon_Tab_Bag_Equip_Master_Select\'',
        },
        {
            ID = 2,
            Icon = 'Texture2D\'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Deputies_Noraml.UI_Icon_Tab_Bag_Equip_Deputies_Noraml\'',
            SelectIcon = 'Texture2D\'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Deputies_Select.UI_Icon_Tab_Bag_Equip_Deputies_Select\'',
        },
        {
            ID = 3,
            Icon = 'Texture2D\'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Head_Noraml.UI_Icon_Tab_Bag_Equip_Head_Noraml\'',
            SelectIcon = 'Texture2D\'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Head_Select.UI_Icon_Tab_Bag_Equip_Head_Select\'',
        },
        {
            ID = 4,
            Icon = 'Texture2D\'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Body_Noraml.UI_Icon_Tab_Bag_Equip_Body_Noraml\'',
            SelectIcon = 'Texture2D\'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Body_Select.UI_Icon_Tab_Bag_Equip_Body_Select\'',
        },
        {
            ID = 5,
            Icon = 'Texture2D\'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Hand_Noraml.UI_Icon_Tab_Bag_Equip_Hand_Noraml\'',
            SelectIcon = 'Texture2D\'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Hand_Select.UI_Icon_Tab_Bag_Equip_Hand_Select\'',
        },
        {
            ID = 6,
            Icon = 'Texture2D\'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Leg_Noraml.UI_Icon_Tab_Bag_Equip_Leg_Noraml\'',
            SelectIcon = 'Texture2D\'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Leg_Select.UI_Icon_Tab_Bag_Equip_Leg_Select\'',
        },
        {
            ID = 7,
            Icon = 'Texture2D\'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Foot_Noraml.UI_Icon_Tab_Bag_Equip_Foot_Noraml\'',
            SelectIcon = 'Texture2D\'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Foot_Select.UI_Icon_Tab_Bag_Equip_Foot_Select\'',
        },
        {
            ID = 8,
            Icon = 'Texture2D\'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Neck_Noraml.UI_Icon_Tab_Bag_Equip_Neck_Noraml\'',
            SelectIcon = 'Texture2D\'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Neck_Select.UI_Icon_Tab_Bag_Equip_Neck_Select\'',
        },
        {
            ID = 9,
        },
        {
            ID = 10,
        },
        {
            ID = 11,
            Icon = 'Texture2D\'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Finesse_Noraml.UI_Icon_Tab_Bag_Equip_Finesse_Noraml\'',
            SelectIcon = 'Texture2D\'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Finesse_Select.UI_Icon_Tab_Bag_Equip_Finesse_Select\'',
        },
        {
            ID = 12,
            Icon = 'Texture2D\'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Eardrops_Noraml.UI_Icon_Tab_Bag_Equip_Eardrops_Noraml\'',
            SelectIcon = 'Texture2D\'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Eardrops_Select.UI_Icon_Tab_Bag_Equip_Eardrops_Select\'',
        },
	},
}

setmetatable(ClosetClassifyCfg, { __index = CfgBase })

ClosetClassifyCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return ClosetClassifyCfg
