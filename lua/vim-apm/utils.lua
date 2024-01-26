local M = {}

local current_auto_group = nil
local function create_autogroup()
    current_auto_group = vim.api.nvim_create_augroup("VimApm", {})
end
create_autogroup()

function M.vim_apm_group_id()
    return current_auto_group
end

function M.del_group_id()
    if current_auto_group ~= nil then
        vim.api.nvim_del_augroup_by_id(current_auto_group)
    end
    create_autogroup()
end

function M.now()
    return vim.loop.now()
end

function M.on_close(buf_id, cb)
    vim.api.nvim_create_autocmd("BufUnload", {
        group = M.vim_apm_group_id(),
        buffer = buf_id,
        callback = function()
            cb()
        end,
    })
end

function M.normalize_number(x, precision)
    precision = precision or 100
    local y = x * precision
    if y % 10 >= 5 then
        return math.ceil(y) / precision
    end
    return math.floor(y) / precision
end

function M.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function M.stringify(item)
    if type(item) == "table" then
        item = vim.inspect(item)
    else
        item = tostring(item)
    end

    local items = M.split(item, "\n")
    return table.concat(items, " ")
end

function M.lineify(item)
    if type(item) == "table" then
        item = vim.inspect(item)
    else
        item = tostring(item)
    end

    return M.split(item, "\n")
end

function M.fit_string(left, right, max_len)
    local remaining = max_len - #left
    local white_space = remaining - #right

    local out = left
    for _ = 1, white_space do
        out = out .. " "
    end

    return out .. right
end

return M
