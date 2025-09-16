local HelpCfg = require("TableCfg/HelpCfg")
local HelpGroupCfg = require("TableCfg/HelpGroupCfg")
local UIViewMgr = require("UI/UIViewMgr")
local TipsUtil = require("Utils/TipsUtil")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local FLOG_INFO = _G.FLOG_INFO
local FVector2D = _G.UE.FVector2D

local HelpInfoType =
{
    Normal = 0,
    Large = 1,
    Mid = 2,
    Tips = 3,
    NewTips = 4,
    NewTipsBright = 5,
}

local TIPS_DIR =
{
    TOP_LEFT = 1,        -- Tip顶部对齐按钮顶部，左方
    TOP_RIGHT = 2,       -- Tip顶部对齐按钮顶部，右方
    RIGHT_TOP = 3,       -- Tip右边对其按钮右边，上方
    LEFT_TOP = 4,        -- Tip左边对其按钮左边，上方
    BOTTOM_LEFT = 5,     -- Tip底部对齐按钮底部，左方
    BOTTOM_RIGHT = 6,    -- Tip底部对齐按钮底部，右方
    RIGHT_BOTTOM  = 7,   -- Tip右边对其按钮右边，下方
    LEFT_BOTTOM = 8,     -- Tip左边对其按钮左边，下方
}

local GroupStartID = 1000000

---@class HelpInfoUtil
local HelpInfoUtil  = {}

---解析数据，分出标题，跟段落内容
---@param  Cfgs table<HelpCfg> 帮助说明配置
---@return ResList table<Title,Section> 解析出标题文本
function HelpInfoUtil.ParseContent(Cfgs, ...)
    local args = { ... } -- 将可变参数转为表
    local ResList = {}
    local lastTitleID = 0 -- 使用更明确的变量名

    -- 安全格式化函数
    local function safe_format(fmt, ...)
        if type(fmt) ~= "string" then return tostring(fmt) end
        local success, ret = pcall(string.format, fmt, ...)
        return success and ret or fmt
    end

    for index, cfg in ipairs(Cfgs) do
        local titleID = cfg.TitleID
        lastTitleID = titleID -- 记录最后处理的ID

        -- 初始化标题组
        if not ResList[titleID] then
            ResList[titleID] = {
                HelpName = safe_format(cfg.HelpName, table.unpack(args)),
                SecTitle = safe_format(cfg.TitleName, table.unpack(args)),
                SecContent = {}
            }
        end

        -- 格式化并添加内容
        local formatted_content = safe_format(cfg.SecContent, table.unpack(args))
        --格式化的内容覆盖
        cfg.SecContent = formatted_content
        table.insert(ResList[titleID].SecContent, Cfgs[index])
    end

    return ResList, lastTitleID
end

--- 把标题，段落内容组合成一个Str
---@return Str string 文本内容
function HelpInfoUtil.ParseText(Content, ...)
    if not Content or #Content == 0 then
        return {}
    end

    local args = { ... }  -- 将可变参数转为表
    local Ret = {}

    -- 安全格式化函数（带错误处理）
    local function safe_format(fmt, ...)
        if not fmt or fmt == "" then return fmt end
        if select("#", ...) == 0 then return fmt end
        
        local success, ret = pcall(string.format, fmt, ...)
        return success and ret or fmt
    end

    for _, v in ipairs(Content) do
        -- 处理标题
        local formatted_title = safe_format(v.SecTitle, table.unpack(args))
        
        -- 处理内容
        local formatted_content = {}
        for _, content_item in ipairs(v.SecContent) do
            table.insert(formatted_content, 
                safe_format(content_item.SecContent, table.unpack(args)))
        end

        table.insert(Ret, {
            Title = formatted_title,
            Content = formatted_content
        })
    end

    return Ret

end

--- 支持对特定子内容进行一次自定义占位符替换
function HelpInfoUtil.ParseTextWithPlaceholders(Content, FilterFunction, ...)
    if Content == nil or #Content == 0 then
        return ""
    end
    local Ret = {}
    for _, v in ipairs(Content) do
        local Title = v.SecTitle
        local Content = {}
        for index, value in ipairs(v.SecContent) do
            local SecContent = value.SecContent
            if FilterFunction(index, value) then
                SecContent = string.format(value.SecContent, ...)
            end
            table.insert(Content, SecContent)
        end
        table.insert(Ret, {Title= Title, Content = Content})
    end

    return Ret
end

function HelpInfoUtil.IsAGroupInfo(ID)
    return type(ID) == 'number' and ID >= GroupStartID
end

---@param ID number 说明ID
---@return ViewID number or Nil
function HelpInfoUtil.ShowHelpInfoByID(ID, ...)
    if HelpInfoUtil.IsAGroupInfo(ID) then
        HelpInfoUtil.ShowHelpInfoMenuWin(ID)
        return
    end

    local HelpCfgs = HelpCfg:FindAllHelpIDCfg(ID)

    if #HelpCfgs == 0 then
        return
    end

    if HelpCfgs[1].Type == nil then
        return
    end

    local Type = HelpCfgs[1].Type
    local Params = {}
    Params.Cfgs = HelpInfoUtil.ParseContent(HelpCfgs, ...)

    -- 不支持Tips类型
    if Type == HelpInfoType.Large then
        UIViewMgr:ShowView(UIViewID.HelpInfoLargeWinView, Params)
        return UIViewID.HelpInfoLargeWinView
    elseif Type == HelpInfoType.Mid then
        UIViewMgr:ShowView(UIViewID.HelpInfoMidWinView, Params)
        return UIViewID.HelpInfoMidWinView
    end
end

---@param ID number 说明ID
---@param Button UButton 说明按钮
---@param HidePopUpBG bool 使用CommHelpTips时是否隐藏通用背部按钮
function HelpInfoUtil.ShowHelpInfo(ButtonView, HidePopUpBG, ...)
    local ID = ButtonView.HelpInfoID

    if ID == nil then
        return
    end

    if HelpInfoUtil.IsAGroupInfo(ID) then
        HelpInfoUtil.ShowHelpInfoMenuWin(ID)
        return
    end

    local HelpCfgs = HelpCfg:FindAllHelpIDCfg(ID)

    if #HelpCfgs == 0 then
        return
    end

    if HelpCfgs[1].Type == nil then
        return
    end

    local Type = HelpCfgs[1].Type
    local Params = {}
    Params.Cfgs = HelpInfoUtil.ParseContent(HelpCfgs, ...)

    if Type == HelpInfoType.Large then
        UIViewMgr:ShowView(UIViewID.HelpInfoLargeWinView, Params)
    elseif Type == HelpInfoType.Mid then
        UIViewMgr:ShowView(UIViewID.HelpInfoMidWinView, Params)
    elseif Type == HelpInfoType.Tips or Type == HelpInfoType.NewTips or Type == HelpInfoType.NewTipsBright then
        local Content = HelpInfoUtil.ParseText(Params.Cfgs, ...)
        local Dir = HelpCfgs[1].Direction and HelpCfgs[1].Direction or 1
        local Offset, Alignment = HelpInfoUtil.GetOffsetAndAlignment(ButtonView.BtnInfor, Dir)
        -- 判断是否有标题
        if not table.is_nil_empty(Content)  then
            if Content[1].Title == "" then 
                TipsUtil.ShowInfoTips(Content, ButtonView.BtnInfor, Offset, Alignment, HidePopUpBG)
            else
                TipsUtil.ShowInfoTitleTips(Content, ButtonView.BtnInfor, Offset, Alignment, false)
            end
        end
    end

end

--- 说明id
function HelpInfoUtil.ShowHelpInfoMenuWin(ID)
    local Params = HelpInfoUtil.GetGroupMenuParams(ID)
    if Params then
        UIViewMgr:ShowView(UIViewID.HelpInfoMenuWinView, Params)
    end
end

function HelpInfoUtil.GetGroupMenuParams(ID)
    local Params = {}
    local HelpGroup = HelpGroupCfg:FindCfgByKey(ID)
    if HelpGroup == nil then
        _G.FLOG_ERROR("invalid group help id %s" , tostring(ID))
        return
    end
    Params.MenuList = {}
    Params.Title = HelpGroup.Title
    local DataList = {}
    for _, v in ipairs(HelpGroup.HID) do
        local Help = HelpCfg:FindAllHelpIDCfg(v)
        if #Help == 0 then
            _G.FLOG_ERROR("invalid help id (HID) %s for group id %s" , tostring(v), tostring(ID))
            return
        end
        local Cfgs, TitleID = HelpInfoUtil.ParseContent(Help)
        if Cfgs[TitleID] ~= nil then
            local Data = {}
            Data.Name = Cfgs[TitleID].HelpName
            Data.Content = {}
            for k , value in ipairs(Cfgs) do
                table.insert(Data.Content, value)
            end

            table.insert(Params.MenuList, Data)
        end
    end

    return Params
end

function HelpInfoUtil.GetOffsetAndAlignment(TargetBtn, Dir)
    if Dir == nil or TargetBtn == nil then
        return
    end

	local ButtonSize = UIUtil.GetLocalSize(TargetBtn)
	local Offset = FVector2D(0, 0)
	local Alignment = FVector2D(0, 0)

    if Dir == TIPS_DIR.TOP_LEFT then
		Alignment = FVector2D(1, 0)
	    Offset = FVector2D(-ButtonSize.X, 5)
	elseif Dir == TIPS_DIR.TOP_RIGHT then
		Alignment = FVector2D(0, 0)
		Offset = FVector2D(0, 5)
	elseif Dir == TIPS_DIR.RIGHT_TOP then
		Alignment = FVector2D(1, 1)
	    Offset = FVector2D(-5, 0)
	elseif Dir == TIPS_DIR.LEFT_TOP then
		Alignment = FVector2D(0, 1)
	    Offset = FVector2D(-ButtonSize.X + 5, 0)
	elseif Dir == TIPS_DIR.BOTTOM_LEFT then
		Alignment = FVector2D(1, 1)
	    Offset = FVector2D(-ButtonSize.X, ButtonSize.Y  - 5)
	elseif Dir == TIPS_DIR.BOTTOM_RIGHT then
	    Offset = FVector2D(0, ButtonSize.Y - 5)
		Alignment = FVector2D(0, 1)
	elseif Dir == TIPS_DIR.RIGHT_BOTTOM then
		Alignment = FVector2D(1, 0)
		Offset = FVector2D(-5, ButtonSize.Y)
	elseif Dir == TIPS_DIR.LEFT_BOTTOM then
		Alignment = FVector2D(0, 0)
	    Offset = FVector2D(-ButtonSize.X + 5, ButtonSize.Y)
	end

    return Offset, Alignment

end

function HelpInfoUtil.GetHelpType(ID)
    if ID == nil then
        return
    end

    local HelpCfgs = HelpCfg:FindAllHelpIDCfg(ID)
    if #HelpCfgs == 0 then
        return
    end

    return HelpCfgs[1].Type
end

HelpInfoUtil.HelpInfoType = HelpInfoType
HelpInfoUtil.GroupStartID = GroupStartID

--要返回当前类
return HelpInfoUtil