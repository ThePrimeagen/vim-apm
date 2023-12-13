---@class ApmFloat
---@field apm_state ApmState
---@field buf_id number
---@field win_id number
local ApmFloat = {}
ApmFloat.__index = ApmFloat

local function close_window(win_id, buf_id)
    if vim.api.nvim_win_is_valid(win_id) then
        vim.api.nvim_win_close(win_id, true)
    end

    if vim.api.nvim_buf_is_valid(buf_id) then
        vim.api.nvim_buf_delete(buf_id, { force = true })
    end
end

local function create_window()
    local buf_id = vim.api.nvim_create_buf(false, true)
    local ui = vim.api.nvim_list_uis()[1]
    local col = 12
    if ui ~= nil then
        col = math.max(ui.width - 13, 0)
    end

    local win_id = vim.api.nvim_open_win(buf_id, false, {
        relative='win',
        anchor="NW",
        row=1,
        col=col,
        width=12,
        height=3,
        border="rounded",
        title="apm",
        title_pos="center",
        style="minimal",
    })

    return buf_id, win_id
end

function ApmFloat.new(apm_state)
    local self = setmetatable({
        apm_state = apm_state,
        buf_id = nil,
        win_id = nil,
    }, ApmFloat)
    return self
end

function ApmFloat:toggle()
    if self.buf_id == nil then
        local buf_id, win_id = create_window()
        self.buf_id = buf_id
        self.win_id = win_id
    else
        close_window(self.win_id, self.buf_id)
        self.buf_id = nil
        self.win_id = nil
    end
end

return ApmFloat:new()

