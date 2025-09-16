--
-- Author: loiafeng
-- Date: 2024-04-26 09:47:47
-- Description:
--
local ProtoRes = require("Protocol/ProtoRes")
local UIViewID = _G.UIViewID

local LoadingDefine = {
    -- 界面样式配置
    LoadingUIMap = {
        [ProtoRes.LoadingUIType.LOADING_UI_NONE] = UIViewID.LoadingDefault,
        [ProtoRes.LoadingUIType.LOADING_UI_MAIN_CITY] = UIViewID.LoadingMainCity,
        [ProtoRes.LoadingUIType.LOADING_UI_SINGLE_DUNGEON] = UIViewID.LoadingOther,
        [ProtoRes.LoadingUIType.LOADING_UI_TEAM_DUNGEON] = UIViewID.LoadingOther,
        [ProtoRes.LoadingUIType.LOADING_UI_CREATURE] = UIViewID.LoadingOther,
        [ProtoRes.LoadingUIType.LOADING_UI_LANDSCAPE] = UIViewID.LoadingOther,
    },

    -- 景观样式左下角标签图
    LandscapeImageMap = {
        [ProtoRes.LoadingType.LOADING_LANDSCAPE] = "PaperSprite'/Game/UI/Atlas/Loading/Frames/UI_Loading_Img_Tree_png.UI_Loading_Img_Tree_png'",
        [ProtoRes.LoadingType.LOADING_GOLD_SAUCER] = "PaperSprite'/Game/UI/Atlas/Loading/Frames/UI_Loading_Img_Cactus_png.UI_Loading_Img_Cactus_png'",
        [ProtoRes.LoadingType.LOADING_MISC] = "PaperSprite'/Game/UI/Atlas/Loading/Frames/UI_Loading_Img_Fishing_png.UI_Loading_Img_Fishing_png'"
    },

    ProfItemBPName = "Loading/Item/LoadingProfessionItem_UIBP",

    MapExclusiveMultiplier = 5,
}

return LoadingDefine
