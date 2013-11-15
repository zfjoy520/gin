-- dependencies
local lfs = require 'lfs'
local prettyprint = require 'pl.pretty'

-- perf
local iopen = io.open
local ipairs = ipairs
local sfind = string.find
local sgsub = string.gsub
local smatch = string.match
local ssub = string.sub
local tinsert = table.insert


local Helpers = {}

-- try to require
function Helpers.try_require(module_name, default)
    local ok, module_or_err = pcall(function() return require(module_name) end)

    if ok == true then return module_or_err end

    if ok == false and smatch(module_or_err, "'" .. module_name .. "' not found") then
        return default
    else
        error(module_or_err)
    end
end

-- read file
function Helpers.read_file(file_path)
    local f = iopen(file_path, "rb")
    local content = f:read("*all")
    f:close()
    return content
end

-- check if folder exists
function Helpers.folder_exists(folder_path)
    return lfs.attributes(sgsub(folder_path, "\\$",""), "mode") == "directory"
end

-- split function
function Helpers.split(str, pat)
    local t = {}
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = sfind(str, fpat, 1)

    while s do
        if s ~= 1 or cap ~= "" then
            tinsert(t,cap)
        end
        last_end = e+1
        s, e, cap = sfind(str, fpat, last_end)
    end

    if last_end <= #str then
        cap = ssub(str, last_end)
        tinsert(t, cap)
    end

    return t
end

-- split a path in individual parts
function Helpers.split_path(str)
   return Helpers.split(str, '[\\/]+')
end

-- recursively make directories
function Helpers.mkdirs(file_path)
    -- get dir path and parts
    dir_path = smatch(file_path, "(.*)/.*")
    parts = Helpers.split_path(dir_path)
    -- loop
    local current_dir = nil
    for _, part in ipairs(parts) do
        if current_dir == nil then
            current_dir = part
        else
            current_dir = current_dir .. '/' .. part
        end
        lfs.mkdir(current_dir)
    end
end

-- value in table?
function Helpers.included_in_table(t, value)
    for _, v in ipairs(t) do
        if v == value then return true end
    end
    return false
end

-- reverse table
function Helpers.reverse_table(t)
    local size = #t + 1
    local reversed = {}
    for i, v in ipairs(t) do
        reversed[size - i] = v
    end
    return reversed
end

-- pretty print to file
function Helpers.pp_to_file(o, file_path)
    prettyprint.dump(o, file_path)
end

-- pretty print
function Helpers.pp(o)
    prettyprint.dump(o)
end

-- check if folder exists
function folder_exists(folder_path)
    return lfs.attributes(sgsub(folder_path, "\\$",""), "mode") == "directory"
end

-- get the lua module name
function Helpers.get_lua_module_name(file_path)
    return string.match(file_path, "(.*)%.lua")
end

-- require recursively in a directory
function Helpers.require_recursive(path)
    local module_list = {}

    if folder_exists(path) then
        for file_name in lfs.dir(path) do
            if file_name ~= "." and file_name ~= ".." then
                local file_path = path .. '/' .. file_name
                local attr = lfs.attributes(file_path)
                assert(type(attr) == "table")
                if attr.mode == "directory" then
                    -- recursive call for all subdirectories inside of directory
                    require_recursive(file_path)
                else
                    local module_name = Helpers.get_lua_module_name(file_path)
                    -- require initializer
                    if module_name ~= nil then
                        require(module_name)
                        tinsert(module_list, module_name)
                    end
                end
            end
        end
    end

    return module_list
end

-- shallow copy of a table
function Helpers.shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

return Helpers






-- -- dependencies
-- local lfs = require 'lfs'
-- local prettyprint = require 'pl.pretty'

-- -- perf
-- local smatch = string.match
-- local sfind = string.find
-- local ssub = string.sub
-- local sgsub = string.gsub
-- local tinsert = table.insert
-- local ipairs = ipairs
-- local assert = assert
-- local type = type
-- local require = require

-- -- read file
-- function read_file(file_path)
--     local f = io.open(file_path, "rb")
--     local content = f:read("*all")
--     f:close()
--     return content
-- end

-- -- check if folder exists
-- function folder_exists(folder_path)
--     return lfs.attributes(sgsub(folder_path, "\\$",""), "mode") == "directory"
-- end

-- -- split function
-- function split(str, pat)
--     local t = {}
--     local fpat = "(.-)" .. pat
--     local last_end = 1
--     local s, e, cap = sfind(str, fpat, 1)

--     while s do
--         if s ~= 1 or cap ~= "" then
--             tinsert(t,cap)
--         end
--         last_end = e+1
--         s, e, cap = sfind(str, fpat, last_end)
--     end

--     if last_end <= #str then
--         cap = ssub(str, last_end)
--         tinsert(t, cap)
--     end

--     return t
-- end

-- -- split a path in individual parts
-- function split_path(str)
--    return split(str, '[\\/]+')
-- end

-- -- recursively make directories
-- function mkdirs(file_path)
--     -- get dir path and parts
--     dir_path = smatch(file_path, "(.*)/.*")
--     parts = split_path(dir_path)
--     -- loop
--     local current_dir = nil
--     for _, part in ipairs(parts) do
--         if current_dir == nil then
--             current_dir = part
--         else
--             current_dir = current_dir .. '/' .. part
--         end
--         lfs.mkdir(current_dir)
--     end
-- end

-- -- get the lua module name?
-- function get_lua_module_name(file_path)
--     return string.match(file_path, "(.*)%.lua")
-- end

-- -- require recursively in a directory
-- function require_recursive(path)
--     local module_list = {}

--     if folder_exists(path) then
--         for file_name in lfs.dir(path) do
--             if file_name ~= "." and file_name ~= ".." then
--                 local file_path = path .. '/' .. file_name
--                 local attr = lfs.attributes(file_path)
--                 assert(type(attr) == "table")
--                 if attr.mode == "directory" then
--                     -- recursive call for all subdirectories inside of directory
--                     require_recursive(file_path)
--                 else
--                     local module_name = get_lua_module_name(file_path)
--                     -- require initializer
--                     if module_name ~= nil then
--                         require(module_name)
--                         tinsert(module_list, module_name)
--                     end
--                 end
--             end
--         end
--     end

--     return module_list
-- end

-- -- reverse indexed table
-- function table.reverse(tab)
--     local size = #tab + 1
--     local reversed = {}
--     for i, v in ipairs(tab) do
--         reversed[size - i] = v
--     end
--     return reversed
-- end

-- -- included in array
-- function included(t, value)
--     for _, v in ipairs(t) do
--         if v == value then return true end
--     end
--     return false
-- end

-- -- pretty print
-- function pp(o)
--     prettyprint.dump(o)
-- end

-- -- pretty print to file
-- function pp_to_file(o, file_path)
--     prettyprint.dump(o, file_path)
-- end

-- -- try to require
-- function try_require(module_name, default)
--     local ok, module_or_err = pcall(function() return require(module_name) end)

--     if ok == true then return module_or_err end

--     if ok == false and smatch(module_or_err, "'" .. module_name .. "' not found") then
--         return default
--     else
--         error(module_or_err)
--     end
-- end
