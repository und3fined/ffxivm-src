local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ActivityCfg = require("TableCfg/ActivityCfg")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")
local LSTR = _G.LSTR

---@class OpsCeremonyEntranceItemVM : UIViewModel
local OpsCeremonyEntranceItemVM = LuaClass(UIViewModel)
---Ctor
function OpsCeremonyEntranceItemVM:Ctor()
    self:Reset()
end

function OpsCeremonyEntranceItemVM:Reset()
    self.IsUnLock = nil ---该Item是否被锁定
    self.IconPromVisible = nil ---任务图标是否可见
    self.TextTitleProm = nil ---活动标题
    self.StartTime = nil ---活动开始时间
    self.StartTimeVisible = nil ---活动开始时间是否可见
    self.IconPassedPromVisible = nil ---是否显示已完成图标
    self.Icon = nil ---活动图标
    self.RedDotName = nil ---红点名称
    self.RedDotStyle = nil ---红点样式
end

---更新Item的各项参数，初始化时用
function OpsCeremonyEntranceItemVM:Update(Params)
    --- 来自活动节点的信息会初始化活动完成、锁定等情况，若没有提取到相关信息，说明活动节点被紧急关闭，统一显示锁定
    local Node = Params.Node
    if not Node then
        return
    end
    self.TextTitleProm = Params.Title
    self.StartTimeVisible = Params.StartTimeVisible or false
    self.Icon = Params.Icon
    self.IsLock = Params.IsLock or false
    self.IconPromVisible = Params.IconPromVisible or false
    self.IconPassedPromVisible = Params.IconPassedPromVisible or false
    self.RedDotName = Params.RedDotName
    self.RedDotStyle = RedDotDefine.RedDotStyle.NormalStyle
    self.StartTime = Params.StartTimeText
    -- self.StartTimeVisible = Params.StartTimeVisible or false
    -- local RedPoints = Cfg.RedPointList
	-- if string.isnilorempty(RedPoints) then
	-- 	return
	-- end

end


return OpsCeremonyEntranceItemVM