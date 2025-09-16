local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local OpsCommTabParentItemVM = require("Game/Ops/VM/OpsCommTabParentItemVM")

---@class OpsActivityMainVM : UIViewModel
local OpsActivityMainVM = LuaClass(UIViewModel)

local OpsActivityMgr 
local RedDotMgr
function OpsActivityMainVM:Ctor()
    self.ActivityTreeList = nil
end

function OpsActivityMainVM:OnInit()
    self.ActivityTreeList = UIBindableList.New( OpsCommTabParentItemVM )
    OpsActivityMgr = _G.OpsActivityMgr
    RedDotMgr = _G.RedDotMgr
end

function OpsActivityMainVM:UpdateOpsActivityInfo()
    if self.ActivityTreeList then
        self.ActivityTreeList:UpdateByValues(OpsActivityMgr:GetCommonClassifyList())
    end
end

function OpsActivityMainVM:GetDefaultKey()
    local ClassifyVM  = self.ActivityTreeList:Get(1)
    if ClassifyVM ~= nil then
        if ClassifyVM.CanExpanded == true then
            return ClassifyVM:GetFirstActivityID()
        end
        return ClassifyVM:GetKey()
    end

    return nil
end


function OpsActivityMainVM:SetSelectedActivityID(ActivityID)
    for i = 1, self.ActivityTreeList:Length() do
        local ClassifyVM = self.ActivityTreeList:Get(i)
        if ClassifyVM ~= nil then
            ClassifyVM:SetSelectedVisible(ClassifyVM:HasActivityID(ActivityID) == true or ActivityID == ClassifyVM:GetKey())
        end
    end

end

function OpsActivityMainVM:GetItemRealIndex(ActivityID)
    local Index = 1
    for i = 1, self.ActivityTreeList:Length() do
        local ClassifyVM = self.ActivityTreeList:Get(i)
        if ClassifyVM ~= nil then
            if ClassifyVM:GetKey() == ActivityID then
                return Index
            end

            for j = 1, ClassifyVM.BindableActivityList:Length() do
                Index = Index +1
                local ActivityVM = ClassifyVM.BindableActivityList:Get(j)
                if ActivityVM~= nil then
                    if ActivityVM:GetKey() == ActivityID then
                        return Index
                    end
                end
            end
            Index = Index + 1
        end
    end
end

--- 父页签未展开时真实的Index
function OpsActivityMainVM:GetItemParentRealIndex(ClasscifyID)
    if not ClasscifyID then return 1 end
    for i = 1, self.ActivityTreeList:Length() do
        local ClassifyVM = self.ActivityTreeList:Get(i)
        if ClassifyVM ~= nil then
            if ClassifyVM:GetKey() == ClasscifyID then
                return i
            end
        end
    end

    return 1
end

-- 子页签在父页签下面真实的Index
function OpsActivityMainVM:GetItemChildRealIndexInParent(ClasscifyID, ActivityID)
    if not ClasscifyID or not ActivityID then return 0 end 
    for i = 1, self.ActivityTreeList:Length() do
        local ClassifyVM = self.ActivityTreeList:Get(i)
        if ClassifyVM ~= nil then
            if ClassifyVM:GetKey() == ClasscifyID then
                local Items = ClassifyVM.BindableActivityList and ClassifyVM.BindableActivityList:GetItems() or {}
                if next(Items) then
                    for i = 1, #Items do
                        if Items[i].ActivityID == ActivityID then
                            return i
                        end
                    end
                end
            end
        end
    end

    return 0
end



--要返回当前类
return OpsActivityMainVM