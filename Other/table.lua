function table.map(array, func)
  local new_array = {}
  for i,v in pairs(array) do
    new_array[#new_array+1] = func(v)
  end
  return new_array
end

function table.deep_copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[table.deep_copy(orig_key)] = table.deep_copy(orig_value)
        end
        setmetatable(copy, table.deep_copy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


function table.compare(array, compare_func)
  local highest = nil

  for i, v in ipairs(array) do
    if (highest == nil or compare_func(v, highest)) then
      highest = v
    end
  end

  return highest
end

function table.find_index(array, match)
  for i, v in ipairs(array) do
    if v == match then return i end
  end

  return -1
end

function table.find_all(array, func)
  results = {}

  for i, v in ipairs(array) do
    if func(v) then
      results[#results+1] = v
    end
  end

  return results
end

function table.find_first(array, func)
  results = {}

  for i, v in ipairs(array) do
    if func(v) then
      return v
    end
  end

  return nil
end

function table.insert_table(array, insert_array, index)
  new_table = table.deep_copy(array)

  index = index == nil and #array or index
  for i, v in ipairs(insert_array) do
    table.insert(new_table, index+i, v)
  end

  return new_table
end

function table.slice_of(tbl, first, last, step)
  local sliced = {}

  for i = first or 1, last or #tbl, step or 1 do
    sliced[#sliced+1] = tbl[i]
  end

  return sliced
end

function table.sample(tbl)
    local keys = {}
    for key, value in pairs(tbl) do
        keys[#keys+1] = key --Store keys in another table
    end
    index = keys[math.random(1, #keys)]
    return tbl[index]
end


