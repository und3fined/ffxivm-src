local DynamicReloadLuaMgr = DynamicReloadLuaMgr or {}
local UIViewID = require("Define/UIViewID")
DynamicReloadLuaMgr.IsEnable = true
DynamicReloadLuaMgr.IsInit = true

--[[ 判断是否是Table类型 ]]
function IsTable(val)
    local backData = false;
    if val~=nil and type(val) == "table" then
        backData=true;
    end
    return backData;
end

DynamicReloadLuaMgr.CheckFolder = {
    "Game",
}


function DynamicReloadLuaMgr.Init()
    
end

function DynamicReloadLuaMgr.Shutdown()
    
end

function DynamicReloadLuaMgr.Tick()
end

function DynamicReloadLuaMgr.BeginModule()
    -- DynamicReloadLuaMgr.IsInit =  true
end

function DynamicReloadLuaMgr.EndModule()
    -- DynamicReloadLuaMgr.IsInit = false
end

function DynamicReloadLuaMgr.HandleEditorWindowDeActived()
    print("DynamicReloadLuaMgr.HandleEditorWindowDeActived")
    if DynamicReloadLuaMgr.IsEnable and DynamicReloadLuaMgr.IsInit then
        local Module = _G.UE.UDynamicReloadLuaModule:Get()
        Module:SetInRecord(true)
        for Index = 1,#DynamicReloadLuaMgr.CheckFolder do
            Module:RecordFiles(DynamicReloadLuaMgr.CheckFolder[Index])
        end
    end

end

function DynamicReloadLuaMgr.HandleEditorWindowActived()
    print("DynamicReloadLuaMgr.HandleEditorWindowActived")
    if DynamicReloadLuaMgr.IsEnable and DynamicReloadLuaMgr.IsInit then
        local Module = _G.UE.UDynamicReloadLuaModule:Get()
        Module:SetInRecord(false)
        
        local ChangeCount = Module:CompareChangedFiles()
        if ChangeCount > 0 then
            --print("UDynamicReloadLuaModule FileChange "..ChangeCount)
            DynamicReloadLuaMgr.HandleReloadFile(ChangeCount , Module)
        else
            --print("UDynamicReloadLuaModule UnFileChange")
        end
    end

end

function DynamicReloadLuaMgr.HandleReloadFile(ChangeCount , Module)

    DynamicReloadLuaMgr.BeforeHandleClear()
    for i=1,ChangeCount do

        local File,Type = "" , -1
        File , Type = Module:GetChangedFilesInfo(i-1 , File , Type)
        File = string.gsub(File, "//", "/")
        --print("UDynamicReloadLuaModule FileChange File "..File)
        --print("UDynamicReloadLuaModule FileChange Type "..Type)
        if Type == 0 then
            -- if string.find( File,"BaseModule/") then
            --     local FilePath = DynamicReloadLuaMgr.NormalizePathStr(File , "BaseModule/")
            --     DynamicReloadLuaMgr.HandleReloadModuleFile(FilePath)
            if string.find( File,"VM/") then
                local FilePath = DynamicReloadLuaMgr.NormalizePathStr(File , "/Game/")
                DynamicReloadLuaMgr.HandleReloadViewModelFile(FilePath)
            elseif string.find( File,"View/") then
                local FilePath = DynamicReloadLuaMgr.NormalizePathStr(File , "/Game/")
                DynamicReloadLuaMgr.HandleReloadViewFile(FilePath)
            end
        end
    end
    DynamicReloadLuaMgr.AfterHandleClear()
end

--处理前清理
function DynamicReloadLuaMgr.BeforeHandleClear()
    print("DynamicReloadLuaMgr.BeforeHandleClear") 
    -- 现在不强制关闭界面，自己手动重新打开
    if LoginMgr.RoleID ~= nil then
        UIViewMgr:HideAllUI()
        _G.BusinessUIMgr:ShowMainPanel(_G.UIViewID.MainPanel)
    end
end

--处理后清理
function DynamicReloadLuaMgr.AfterHandleClear()
    print("DynamicReloadLuaMgr.AfterHandleClear")
    -- FashionShowSceneModule:ExitShowScene(false)
    -- ReplaceState(MainPanelState)

end

--处理BaseModule下的文件
function DynamicReloadLuaMgr.HandleReloadModuleFile( FilePath )

    print("UDynamicReloadLuaModule HandleReloadModuleFile "..FilePath)
    --只处理Gameing
   
    --有些view的文件也是工具类先重载下
    DynamicReloadLuaMgr.ReloadBaseModule(FilePath)   
end
--处理View文件夹下的文件
function DynamicReloadLuaMgr.HandleReloadViewFile( FilePath )
    print("UDynamicReloadLuaModule HandleReloadViewFile "..FilePath)
    local FilePath = string.gsub(FilePath, "/", ".")
    DynamicReloadLuaMgr.ReloadModule(FilePath)  
end

--处理VM文件夹下的文件
function DynamicReloadLuaMgr.HandleReloadViewModelFile( FilePath )
    print("UDynamicReloadLuaModule HandleReloadViewModelFile "..FilePath)
    DynamicReloadLuaMgr.ReloadModule(FilePath)
    --FMGame这边没有缓存ViewModel的管理器，不需要更新
    -- local FileName = DynamicReloadLuaMgr.GetFileName(FilePath)
    -- if ViewModelMgr:Get(FileName) then
    --     --
    --     print("UDynamicReloadLuaModule MainVM = "..FileName)
    --     local ChangeVM = require(FilePath)
       
    --     local NewVM = InstantiateViewModel(ChangeVM)
    --     if NewVM.OnInit then
    --         NewVM:OnInit()
    --     end
    --     ViewModelMgr.allViewModels[FileName] = NewVM
    --     if NewVM.Tick then
    --         ViewModelMgr.allTickViewModels[FileName] = NewVM
    --     else
    --         ViewModelMgr.allTickViewModels[FileName] = nil
    --     end
    -- end
end

function DynamicReloadLuaMgr.NormalizePathStr(FilePath , SignStr)

    local Num = string.find( FilePath,SignStr)
    local Result = string.sub( FilePath, Num)
    local Length = string.len( Result )
    return string.sub( Result, 2 , Length - 4)
end

function DynamicReloadLuaMgr.GetFileName(FilePath)

    local Result = FilePath
    local Num = string.find( Result,"/")
    
    while true do
        Num = string.find( Result,"/")
        if not Num then
            break
        end
        Result = string.sub( Result, Num+1)
    end

    return Result

    
end

function DynamicReloadLuaMgr.ReloadModule(module_name)
    print("DynamicReloadLuaMgr.ReloadModule Start====:",module_name)
    local old_module = package.loaded[module_name]
    if old_module == nil then
        print("DynamicReloadLuaMgr.ReloadModule module not found:",module_name)
        return
    end
    package.loaded[module_name] = nil
    local new_module = origin_require(module_name)
    if old_module and new_module and IsTable(new_module) then
        
        for k, v in pairs(new_module) do
            old_module[k] = v
        end
        package.loaded[module_name] = old_module
    end
end

function DynamicReloadLuaMgr.ReloadBaseModule(module_path)
    
    --local module_path = "BaseModule/PowerSaveMgr/TestLoadModule"
    local module_name = DynamicReloadLuaMgr.GetFileName(module_path) 
    print("UDynamicReloadLuaModule ReloadBaseModule = "..module_name)

    local old_module = _G[module_name]
    if not old_module then
        return
    end
    local CollectUpVaue = {}
    local CollectVar = DynamicReloadLuaMgr.CollectModuleVar(old_module , CollectUpVaue)
    
    --_G[module_name] = nil
    package.loaded[module_path] = nil
    require(module_path)
    local new_module = _G[module_name]
    if new_module and IsTable(new_module) then
        
        for k, v in pairs(new_module) do

            if CollectVar[k] then
                new_module[k] = CollectVar[k]
            elseif type(v) == "function" then
                DynamicReloadLuaMgr.UpdateUpValue(v, CollectUpVaue[k]) 
            end
        end
        
    end
end

-- function DynamicReloadLuaMgr.TestGetFileName()

--     local module_name = "UMG/ViewModel/Cook/CookViewModel"
--     local res = DynamicReloadLuaMgr.GetFileName(module_name)
--     print("UDynamicReloadLuaModule res = "..res)

-- end

-- function DynamicReloadLuaMgr.TestLoadModule()


--     local Old1 = require("UMG/ViewModel/Cook/CookViewModel")
--     DynamicReloadLuaMgr.Old2 = require("UMG/ViewModel/Cook/CookViewModel")
--     Old1.TestValue = 10
    

--     print("Old2 TestValue "..DynamicReloadLuaMgr.Old2.TestValue)

-- end

-- function DynamicReloadLuaMgr.TestLoadModule2()

--     local module_name = "UMG/ViewModel/Cook/CookViewModel"
--     --[[local OldModule = package.loaded[module_name]
   
--     package.loaded[module_name] = nil
--     local NewModule = require(module_name)

--     for k, v in pairs(NewModule) do
--         OldModule[k] = v
--     end]]
--     DynamicReloadLuaMgr.ReloadModule(module_name)
    
--     --DynamicReloadLuaMgr.Old2 = require("UMG/ViewModel/Cook/CookViewModel")
--     print("Old2 TestValue "..DynamicReloadLuaMgr.Old2.TestValue)
--     --print("Old TestValue "..OldModule.TestValue)
-- end

-- function DynamicReloadLuaMgr.TestBaseModule3()
    
--     local module_path = "BaseModule/PowerSaveMgr/TestLoadModule"
--     local module_name = "TestLoadModule"

--     --require(module_path)
--     local old_module = _G[module_name]
--     local CollectUpVaue = {}
--     local CollectFunc = {}
--     local CollectVar = DynamicReloadLuaMgr.CollectModuleVar(old_module , CollectUpVaue)
    
--     --_G[module_name] = nil
--     package.loaded[module_path] = nil
--     require(module_path)
--     local new_module = _G[module_name]
--     if new_module and IsTable(new_module) then
        
--         for k, v in pairs(new_module) do

--             if CollectVar[k] then
--                 new_module[k] = CollectVar[k]
--             elseif type(v) == "function" then
--                 DynamicReloadLuaMgr.UpdateUpValue(v, CollectUpVaue[k])
--                 CollectFunc[k] = v
--             end
--         end
        
--     end

--     print("DynamicReloadLuaMgr new_module TestValue" , new_module.TestValue)
--     new_module:Print()
-- end


function DynamicReloadLuaMgr.CollectModuleVar(module , CollectUpVaue)

    local CollectVar = {}
    for k, v in pairs(module) do
        if type(v) ~= "function" then
            --print(k , v)
            CollectVar[k] = v
        else
            CollectUpVaue[k] = {}
            DynamicReloadLuaMgr.CollectUpValue(v , CollectUpVaue[k])
        end
    end

    return CollectVar
end

function DynamicReloadLuaMgr.CollectUpValue(f , uv)

    local i = 1
    while true do
        local name, value = debug.getupvalue(f, i)
        if name == nil then
            break
        end
        
        if not uv[name] then
            uv[name] = value
            print("collect up value" , name , f , value)
            if type(value) == "function" then
                DynamicReloadLuaMgr.CollectUpValue(value, uv)
            end
        end

        i = i + 1
    end
end

function DynamicReloadLuaMgr.UpdateUpValue(f, uv) 
    local i = 1
    while true do
        local name, value = debug.getupvalue(f, i)
        print("update test up value" , name , value)
        if name == nil then
            break
        end
        -- value 值为空，并且这个 name 在 旧的函数中存在
        if uv[name] then 
            local desc = uv[name]
            -- 将新函数 f 的第 i 个上值引用旧模块 func 的第 index 个上值
            --debug.upvaluejoin(f, i, desc.func, desc.index)
            print("update up value" , name , f , desc)
            debug.setupvalue(f, i, desc)
        end

         -- 只对 function 类型进行递归更新，对基本数据类型（number、boolean、string） 不管
        if type(value) == "function" then
            DynamicReloadLuaMgr.UpdateUpValue(value, uv)
        end

        i = i + 1
    end
end

print("DynamicReloadLuaMgr LuaModule Loaded!")
return DynamicReloadLuaMgr