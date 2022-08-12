-- debug utils

-- print masco
function print_mascot()
    local mascot = [[                                                   
                            ____            ____      ,----..    
        ,----..           ,'  , `.        ,'  , `.   /   /   \   
       /   /   \       ,-+-,.' _ |     ,-+-,.' _ |  /   .     :  
      |   :     :   ,-+-. ;   , ||  ,-+-. ;   , || .   /   ;.  \ 
      .   |  ;. /  ,--.'|'   |  ;| ,--.'|'   |  ;|.   ;   /  ` ; 
      .   ; /--`  |   |  ,', |  ':|   |  ,', |  ':;   |  ; \ ; | 
      ;   | ;  __ |   | /  | |  |||   | /  | |  |||   :  | ; | ' 
      |   : |.' .''   | :  | :  |,'   | :  | :  |,.   |  ' ' ' : 
      .   | '_.' :;   . |  ; |--' ;   . |  ; |--' '   ;  \; /  | 
      '   ; : \  ||   : |  | ,    |   : |  | ,     \   \  ',  /  
      '   | '/  .'|   : '  |/     |   : '  |/       ;   :    /   
      |   :    /  ;   | |`-'      ;   | |`-'         \   \ .'    
       \   \ .'   |   ;/          |   ;/              `---`      
        `---`     '---'           '---'                          
                                                                  
    ]]
    print("\n"..mascot.."\n")
end

-- package 的搜索路径
function package_path()
	local package_path = package.path
	print("package path: "..package.path)
end

--pack
function str_pack(cmd, msg)
    return table.concat( msg, ",").."\r\n"
end

--unpack
function str_unpack(msgstr)
    local msg = {}

    while true do
        local arg, rest = string.match( msgstr, "(.-),(.*)")
        if arg then
            msgstr = rest
            table.insert(msg, arg)
        else
            table.insert(msg, msgstr)
            break
        end
    end

    return msg[1], msg
end

--dump table contents
--https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end

 ----计算table的个数
 function table_it(v)
    if type(v) ~= "table" then
        v = {}
    end

    return v
end

function count_table(t)
    local n = 0
    local t = table_it(t)
    for k, _  in pairs(t) do
        -- n += 1
        -- Lua 没有 += 
        n = n + 1
    end

    return n
end
