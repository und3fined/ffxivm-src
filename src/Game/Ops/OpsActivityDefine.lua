
local ActivityPageCfg = require("TableCfg/ActivityPageCfg")

local function SortPagePredicate(Left, Right)
    local LeftCfg = ActivityPageCfg:FindCfgByKey(Left.Classcify)
    local RightCfg = ActivityPageCfg:FindCfgByKey(Right.Classcify)
	if LeftCfg == nil then
        return false
    end

    if RightCfg == nil then
        return true
    end

    local LeftPutBottom = false
    if LeftCfg.PutBottomFunc and string.isnilorempty(LeftCfg.PutBottomFunc) == false then
        local LuaFunc = _G.load(string.format("return %s", LeftCfg.PutBottomFunc))
        if LuaFunc then
            LeftPutBottom = LuaFunc()
        end
    end

    local RightPutBottom = false
    if RightCfg.PutBottomFunc and string.isnilorempty(RightCfg.PutBottomFunc) == false then
        local LuaFunc = _G.load(string.format("return %s", RightCfg.PutBottomFunc))
        if LuaFunc then
            RightPutBottom = LuaFunc()
        end
    end

    if LeftPutBottom == RightPutBottom then
        return LeftCfg.PageSort > RightCfg.PageSort
    else
        if LeftPutBottom == true then
            return false
        else
            return true
        end
    end
    
end

--@Activity -ActivityCfg 
--@Detail - ActivityNodeList, IsFinish
local function SortActivityPredicate(Left, Right)
    local LeftCfg = Left.Activity
    local RightCfg = Right.Activity

    local LeftDetail = Left.Detail
    local RightDetail = Right.Detail

    if LeftCfg.PutBottom == 1 and LeftDetail.ActivityFinish == true then
        if RightCfg.PutBottom == 0 or RightDetail.ActivityFinish == false then
            return false
        end
    end

    if RightCfg.PutBottom == 1 and RightDetail.ActivityFinish == true then
        if LeftCfg.PutBottom == 0 or LeftDetail.ActivityFinish == false then
            return true
        end
    end

    return LeftCfg.Priority > RightCfg.Priority
end

local LocalStrID = {
    OwnedAllReward = 100022, -- 已获得全部奖励，下次再参与吧
    Owned = 100023, -- 已获得
    NextLotteryProbality = 100024,  --下一次抽取奖励概率
    And = 100010, -- 且
    Or =100011, -- 或
    LeftToPurchase = 100026, --- 剩余可购：%s/%s
}

-- 道具框类型
local PropBoxType = {
    OrdinaryProp = "PaperSprite'/Game/UI/Atlas/Ops/OpsActivity/Frames/UI_OpsSupplyStation_Img_SignInBG_Blue_png.UI_OpsSupplyStation_Img_SignInBG_Blue_png'",
    AdvancedProp = "PaperSprite'/Game/UI/Atlas/Ops/OpsActivity/Frames/UI_OpsSupplyStation_Img_SignInBG_Red_png.UI_OpsSupplyStation_Img_SignInBG_Red_png'",
    AvailableProp = "PaperSprite'/Game/UI/Atlas/Ops/OpsActivity/Frames/UI_OpsSupplyStation_Img_SignInBG_Yellow_png.UI_OpsSupplyStation_Img_SignInBG_Yellow_png'",
}

local BindState = {
    None = 0,   --未绑定
    Binded = 1, --已绑定
    Expired = 2,    --绑定过期
}

local ActivityPageTag = {
    ActivityPageTagInvalid = 0,
    ActivityPageTagHot = 1, --火爆
    ActivityPageTagTimeLimit = 2, --限时
    ActivityNodeTypeNewcomers = 3, --新手
}

local RedDotID = 16001
local RedDotName = "Root/OpsActivity"

local OpsActivityDefine =
{
    SortPagePredicate = SortPagePredicate,
    SortActivityPredicate = SortActivityPredicate,
    RedDotID = RedDotID,
    RedDotName = RedDotName,
    LocalStrID = LocalStrID,
    PropBoxType = PropBoxType,
    BindState = BindState,
    ActivityPageTag = ActivityPageTag,
}

return OpsActivityDefine