local utils = require("vim-apm.utils")
local APMBussin = require("vim-apm.bus")
local CALCULATOR_MOTION = require("vim-apm.calculator").CALCULATED_MOTION

---@class APMFloat
---@field buf_id number
---@field win_id number
---@field _display table<string>
---@field closing boolean
local APMFloat = {}
APMFloat.__index = APMFloat

local function close_window(win_id, buf_id)
    if win_id ~= nil and vim.api.nvim_win_is_valid(win_id) then
        vim.api.nvim_win_close(win_id, true)
    end

    if buf_id ~= nil and vim.api.nvim_buf_is_valid(buf_id) then
        vim.api.nvim_buf_delete(buf_id, { force = true })
    end
end

local function create_window_config()
    local ui = vim.api.nvim_list_uis()[1]
    local col = 12
    if ui ~= nil then
        col = math.max(ui.width - 13, 0)
    end

    return {
        relative = "editor",
        anchor = "NW",
        row = 1,
        col = col,
        width = 12,
        height = 3,
        border = "rounded",
        title = "apm",
        title_pos = "center",
        style = "minimal",
    }
end

local function create_window()
    local buf_id = vim.api.nvim_create_buf(false, true)
    local config = create_window_config()
    local win_id = vim.api.nvim_open_win(buf_id, false, config)

    return buf_id, win_id
end

function APMFloat.new()
    local self = setmetatable({
        buf_id = nil,
        win_id = nil,
        closing = false,
        _display = { "NONE YET" },
    }, APMFloat)

    APMBussin:listen(CALCULATOR_MOTION, function(event)
        self:_display_contents(event)
    end)

    return self
end

--- TODO: This rubs me the wrong way
function APMFloat:_display_contents(calc_event)
    if calc_event ~= nil and calc_event.apm ~= nil then
        local contents = utils.lineify(calc_event)
        self._display = contents
    end

    if self.buf_id ~= nil then
        if self._display == nil then
            self._display = { "NONE YET" }
        end
        vim.api.nvim_buf_set_lines(self.buf_id, 0, -1, false, self._display)
    end
end

function APMFloat:resize()
    if self.win_id == nil then
        return
    end

    if not vim.api.nvim_win_is_valid(self.win_id) then
        close_window(nil, self.buf_id)
        self.win_id = nil
        self.buf_id = nil
        self.closing = false
        return
    end

    local config = create_window_config()
    vim.api.nvim_win_set_config(self.win_id, config)
end

function APMFloat:toggle()
    if self.buf_id == nil then
        local buf_id, win_id = create_window()
        self.buf_id = buf_id
        self.win_id = win_id

        self:_display_contents()

        utils.on_close(buf_id, function()
            if self.closing then
                return
            end

            -- TODO: Probablly refuctorc
            close_window(self.win_id, nil)
            self.buf_id = nil
            self.win_id = nil
        end)
    else
        self.closing = true
        close_window(self.win_id, self.buf_id)
        self.buf_id = nil
        self.win_id = nil
        self.closing = false
    end
end

return APMFloat
