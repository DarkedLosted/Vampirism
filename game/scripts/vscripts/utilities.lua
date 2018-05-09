function getIndex(list, element)
    if list == nil then return false end
    for i=1,#list do
        if list[i] == element then
            return i
        end
    end
    return -1
end
function ConvertToTime( value )
    local value = tonumber( value )

  if value <= 0 then
    return "00:00:00";
  else
      hours = string.format( "%02.f", math.floor( value / 3600 ) );
      mins = string.format( "%02.f", math.floor( value / 60 - ( hours * 60 ) ) );
      secs = string.format( "%02.f", math.floor( value - hours * 3600 - mins * 60 ) );
      if math.floor( value / 3600 ) == 0 then
        return mins .. ":" .. secs
      end
      return hours .. ":" .. mins .. ":" .. secs
  end
end

function TableFindKey( table, val )
  if table == nil then
    print( "nil" )
    return nil
  end

  for k, v in pairs( table ) do
    if v == val then
      return k
    end
  end
  return nil
end

function StringStartsWith( fullstring, substring )
    local strlen = string.len(substring)
    local first_characters = string.sub(fullstring, 1 , strlen)
    return (first_characters == substring)
end

function DebugPrint(...)
    local spew = Convars:GetInt('debug_spew') or -1
    if spew == -1 and DEBUG_SPEW then
        spew = 1
    end

    if spew == 1 then
        print(...)
    end
end

function VectorString(v)
    return '[' .. math.floor(v.x) .. ', ' .. math.floor(v.y) .. ', ' .. math.floor(v.z) .. ']'
end

function tobool(s)
    if s=="true" or s=="1" or s==1 then
        return true
    else --nil "false" "0"
        return false
    end
end

function PrintTable(t, indent, done)
  --print ( string.format ('PrintTable type %s', type(keys)) )
  if type(t) ~= "table" then return end

  done = done or {}
  done[t] = true
  indent = indent or 0

  local l = {}
  for k, v in pairs(t) do
    table.insert(l, k)
  end

  table.sort(l)
  for k, v in ipairs(l) do
    -- Ignore FDesc
    if v ~= 'FDesc' then
      local value = t[v]

      if type(value) == "table" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..":")
        PrintTable (value, indent + 2, done)
      elseif type(value) == "userdata" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
      else
        if t.FDesc and t.FDesc[v] then
          print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
        else
          print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        end
      end
    end
  end
end

function ColorText( pID )
  local teamcolors={
    "#ff0000",
    "#0000ff",
    "#00ffff",
    "#663399",
    "#ffff00",
    "#ffa500",
    "#32cd32",
    "#ff69b4",
    "#a9a9a9",
    "#89cff0",
    "#006a4e",
    "#4b3621"
}
  return teamcolors[pID+1]
end