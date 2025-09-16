---
--- Author: henghaoli
--- DateTime: 2024-4-30 16:02
--- Description: Cfg LruCache相关的配置
--- 
---配置参数说明:
--- KeyType - 支持""integer" / "string", 对应数据库主键的类型
--- Size - LruCache的大小
---



---@class CfgLruCacheConfig
local CfgLruCacheConfig = {
    DefaultSize = 50,  -- 默认LruCache的大小


    ["c_skill_sub_cfg"] = {
        KeyType = "integer",
        Size = 50,
    },

    ["c_skill_main_cfg"] = {
        KeyType = "integer",
        Size = 50,
    },

    ["c_emotion_cfg"] = {
        KeyType = "integer",
        Size = 15,
    },

    ["c_item_cfg"] = {
        KeyType = "integer",
        Size = 800,
    },
}

return CfgLruCacheConfig
