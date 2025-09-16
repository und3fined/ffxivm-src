
---技能资源加载的NoCache方案

local ObjectMgr = _G.ObjectMgr
local UnLuaRef = _G.UnLua.Ref
local UnLuaUnref = _G.UnLua.Unref
local EObjectGC = _G.UE.EObjectGC

---@class SkillAssetLoader
local SkillAssetLoader = {}
local ListennerName = "SkillAssetLoader"

local RefProxyList = {}
local function AddRef(Asset)
    if Asset then
        table.insert(RefProxyList, UnLuaRef(Asset))
    end
    return Asset
end

local MT = {
    __newindex = function(Table, Key, Value)
        rawset(Table, Key, AddRef(Value))
    end
}

local ObjectList

function SkillAssetLoader.Init()
    ObjectList = setmetatable({}, MT)

    EventMgr:RegisterEvent(EventID.PWorldMapExit, nil, SkillAssetLoader.UnloadAll, ListennerName)
    EventMgr:RegisterEvent(EventID.MajorProfSwitch, nil, SkillAssetLoader.UnloadAll, ListennerName)
end

function SkillAssetLoader.UnInit()
    SkillAssetLoader.UnloadAll()
    EventMgr:UnRegisterEvent(EventID.PWorldMapExit, nil, SkillAssetLoader.UnloadAll)
    EventMgr:UnRegisterEvent(EventID.MajorProfSwitch, nil, SkillAssetLoader.UnloadAll)
end

function SkillAssetLoader.LoadObjectSync(FullPath)
    local Asset = ObjectList[FullPath]
    if Asset then
        return Asset
    end
    Asset = ObjectMgr:LoadObjectSync(FullPath, EObjectGC.NoCache)
    ObjectList[FullPath] = Asset
end

function SkillAssetLoader.LoadClassSync(FullPath)
    local Asset = ObjectList[FullPath]
    if Asset then
        return Asset
    end
    Asset = ObjectMgr:LoadClassSync(FullPath, EObjectGC.NoCache)
    ObjectList[FullPath] = Asset
end

function SkillAssetLoader.LoadObjectAsync(FullPath, SuccessCallBack)
    local Asset = ObjectList[FullPath]
    if Asset then
        return Asset
    end

    local function Callback()
        ObjectList[FullPath] = ObjectMgr:GetObject(FullPath)
        if SuccessCallBack then
            SuccessCallBack()
        end
    end

    ObjectMgr:LoadObjectAsync(FullPath, Callback, EObjectGC.NoCache)
end

function SkillAssetLoader.LoadClassAsync(FullPath, SuccessCallBack)
    local Asset = ObjectList[FullPath]
    if Asset then
        return Asset
    end

    local function Callback()
        ObjectList[FullPath] = ObjectMgr:GetObject(FullPath)
        if SuccessCallBack then
            SuccessCallBack()
        end
    end

    ObjectMgr:LoadClassAsync(FullPath, Callback, EObjectGC.NoCache)
end

function SkillAssetLoader.LoadObjectsAsync(FullPaths, SuccessCallBack)

    local function Callback()

        for i = 1, FullPaths:Length() do
            local FullPath = FullPaths:GetRef(i)
            local Object = ObjectMgr:GetObject(FullPath)
            ObjectList[FullPath] = Object
        end
        if SuccessCallBack then
            SuccessCallBack()
        end
    end
    ObjectMgr:LoadObjectsAsync(FullPaths, Callback, EObjectGC.NoCache, nil)
end

function SkillAssetLoader.GetObject(FullPath)
    local Asset = ObjectList[FullPath]
    if Asset then
        return Asset
    end

    return ObjectMgr:GetObject(FullPath)
end


function SkillAssetLoader.UnloadAll()
    for i = 1, #RefProxyList do
        local Object = RefProxyList[i]:GetObject()
        if Object then
            UnLuaUnref(Object)  -- 手动Unref, 稍微提前一点回收的时间
        end
        RefProxyList[i] = nil
    end

    ObjectList = setmetatable({}, MT)

    UE.USkillMgr.Get():Unload()
end

return SkillAssetLoader