local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local CrafterWeaverCircleItemVM = require("Game/Crafter/Weaver/CrafterWeaverCircleItemVM")

---@class CrafterWeaverVM : UIViewModel
local CrafterWeaverVM = LuaClass(UIViewModel)

function CrafterWeaverVM:Ctor()
    self.bWeaverBottleDropEnter = false
    self.bWeaverNeedleItemVisable = true
    self.WeaverCircleItemVMList = UIBindableList.New(CrafterWeaverCircleItemVM)
    self.LastWeaverStates = {}
    self.LastIndex = 0
end

function CrafterWeaverVM:ResetParams()
    self.bWeaverBottleDropEnter = false
    self.bWeaverNeedleItemVisable = true
    self.WeaverCircleItemVMList:Clear()
    self.LastWeaverStates = {}
    self.LastIndex = 0
end

function CrafterWeaverVM:OnInit()

end

function CrafterWeaverVM:OnBegin()

end

function CrafterWeaverVM:OnEnd()

end

function CrafterWeaverVM:OnShutdown()
    
end

function CrafterWeaverVM:Reset()

end

function CrafterWeaverVM:OnDragStateChange(InDrag)
    if InDrag then
        self.bWeaverBottleDropEnter = true
        self.bWeaverNeedleItemVisable = false
    else
        self.bWeaverBottleDropEnter = false
        self.bWeaverNeedleItemVisable = true
    end
end

-- 状态球初始化
function CrafterWeaverVM:InitCircleItemList(WeaverStates)
    local State = nil
    self:ResetParams()
    -- 由于断线重连情况下的序列长度未知，因此这里采用从后往前遍历
    if WeaverStates and #WeaverStates.Balls > 0 then
        for i = 1, 7, 1 do
            local ItemVM = CrafterWeaverCircleItemVM.New()
            State = WeaverStates.Balls[#WeaverStates.Balls + 1 - i]
            ItemVM:UpdateCircleItemVM(State)
            self.WeaverCircleItemVMList:Insert(ItemVM,1)
            self.LastWeaverStates[#WeaverStates.Balls + 1 - i] = State
        end
    else
        for i = 1, 7, 1 do
            local ItemVM = CrafterWeaverCircleItemVM.New()
            self.WeaverCircleItemVMList:Add(ItemVM)
            self.LastWeaverStates[i] = State
        end
    end
    self.LastIndex = WeaverStates.Index or 0
end

-- 状态球更新
function CrafterWeaverVM:UpdateCircleItemList(WeaverStates)
    local State = nil
    if WeaverStates and #WeaverStates.Balls > 0 then
        for index = 1, #WeaverStates.Balls , 1 do
            State = WeaverStates.Balls[index]
            local ItemVM = self.WeaverCircleItemVMList:Get(index)
            ItemVM:UpdateCircleItemVM(State)
            self.LastWeaverStates[index] = State
        end
        self.LastIndex = WeaverStates.Index
    else
        FLOG_ERROR("Crafter CrafterWeaverVM:UpdateCircleItemList():WeaverStates size == 0")
    end
end

return CrafterWeaverVM