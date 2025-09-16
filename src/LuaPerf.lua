local LuaPerf = {}

local mri = nil

function LuaPerf.Start()
    mri = require("MemoryReferenceInfo")

    -- Set config
    mri.m_cConfig.m_bAllMemoryRefFileAddTime = true
    --mri.m_cConfig.m_bSingleMemoryRefFileAddTime = false
    --mri.m_cConfig.m_bComparedMemoryRefFileAddTime = false

    _G.LuaPerf = LuaPerf
end

--给Dump出的内存文件一个字符串标记，方便比对
local MemFileTag = {}

function LuaPerf.LogDir()
    return _G.FDIR_LOG()
end

function LuaPerf.LuaGC()
    if mri == nil then
        return
    end

    local GCNum = collectgarbage("count")
    collectgarbage("collect")
    collectgarbage("collect")
    collectgarbage("collect")
    print("LuaGC Number: "..tostring(GCNum - collectgarbage("count")))
    FLOG_ERROR("LuaGC Number: "..tostring(GCNum - collectgarbage("count")))
end

--Dump所有Lua内存快照
--ShortTag：字符串型，文件的一个标记
function LuaPerf.DumpMem(ShortTag)
    if mri == nil then
        return
    end

    if ShortTag == nil then
        ShortTag = tostring(_G.TimeUtil.GetLocalTimeMS())
    end

    collectgarbage("collect")
    collectgarbage("collect")
    collectgarbage("collect")
    local FilePath = mri.m_cMethods.DumpMemorySnapshot(_G.FDIR_LOG(), "All", -1, "_G", _G)
    MemFileTag[ShortTag] = FilePath
    FLOG_ERROR("Dump Lua Mem success, file tag: "..ShortTag..", file path: "..FilePath)
    return FilePath
end

--Dump单个引用
--用ShortTag2去对比ShortTag1
function LuaPerf.DumpCompare(ShortTag1, ShortTag2)
    if mri == nil then
        return
    end

    if MemFileTag[ShortTag1] == nil then
        FLOG_ERROR("Dump Compare failed, file1 not exist: "..tostring(MemFileTag[ShortTag1]))
        return
    end
    
    if MemFileTag[ShortTag2] == nil then
        FLOG_ERROR("Dump Compare failed, file2 not exist: "..tostring(MemFileTag[ShortTag2]))
        return
    end

    local FilePath = mri.m_cMethods.DumpMemorySnapshotComparedFile(_G.FDIR_LOG(), "Diff", -1, MemFileTag[ShortTag1], MemFileTag[ShortTag2])
    FLOG_ERROR("Dump Compare success, base file: "..ShortTag1..", new file: "..ShortTag2..", diff file path: "..FilePath)
    return FilePath
end

return LuaPerf
