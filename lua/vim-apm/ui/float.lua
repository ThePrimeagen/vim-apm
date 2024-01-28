local Events = require("vim-apm.event_names")
local utils = require("vim-apm.utils")
local APMBussin = require("vim-apm.bus")

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
        row = 0,
        col = col,
        width = 40,
        height = 1,
        border = "none",
        title = "",
        style = "minimal",
    }
end

local function create_window()
    local buf_id = vim.api.nvim_create_buf(false, true)
    local config = create_window_config()
    local win_id = vim.api.nvim_open_win(buf_id, false, config)

    return buf_id, win_id
end

local function create_display()
    return {
        utils.fit_string("m:", "0", 5), -- 0 - 5
        utils.fit_string("w:", "0", 7), -- 6 - 13
        utils.fit_string("b:", "0", 7), -- 14 - 20
    }
end

local function writes(display, count)
    display[2] = utils.fit_string("w:", tostring(count), 7)
end

local function bufs(display, count)
    display[3] = utils.fit_string("b:", tostring(count), 7)
end

local function motions(display, count)
    display[1] = utils.fit_string("m:", tostring(count), 7)
end

function APMFloat.new()
    local self = setmetatable({
        buf_id = nil,
        win_id = nil,
        closing = false,
        _display = create_display(),
    }, APMFloat)
    return self
end

function APMFloat:enable()
    APMBussin:listen(Events.APM_REPORT, function(event)
        motions(self._display, event)
        self:_display_contents()
    end)

    ---@param stats APMStatsJson
    APMBussin:listen(Events.STATS, function(stats)
        writes(self._display, stats.write_count)
        bufs(self._display, stats.buf_enter_count)
        self:_display_contents()
    end)

    APMBussin:listen(Events.RESIZE, function()
        self:resize()
    end)
end

function APMFloat:_display_contents()
    if self.buf_id ~= nil then
        if self._display == nil then
            self._display = create_display()
        end
        vim.api.nvim_buf_set_lines(
            self.buf_id,
            0,
            -1,
            false,
            { table.concat(self._display, " ") }
        )
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

function APMFloat:close()
    if self.buf_id ~= nil then
        self.closing = true
        close_window(self.win_id, self.buf_id)
        self.buf_id = nil
        self.win_id = nil
        self.closing = false
    end
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

            close_window(self.win_id, nil)
            self.buf_id = nil
            self.win_id = nil
        end)
    else
        self:close()
    end
end

return APMFloat
