local M = {}

---@param uri string
---@param port number
---@param token string
---@param messages APMStatsJson[]
function M.make_request(uri, port, token, messages)
    local uv = vim.loop
    local client = uv.new_tcp()

    client:connect(uri, port, function(err)
        if err == nil then
        else
            err = "vim-apm failed to connect to the APM server: " .. err
        end

        local ok, to_write = pcall(vim.json.encode, messages)
        if ok then
            local http_message = {
                "POST /stats HTTP/1.1",
                string.format("Authorization: Basic %s", token),
                string.format("Host: %s:%d", uri, port),
                "Content-Type: application/json",
                string.format("Content-Length: %d", #to_write),
                "Connection: close",
                "",
                to_write,
            }
            client:write(table.concat(http_message, "\r\n"))
        else
            err = "vim-apm failed to encode messages: " .. to_write
        end

        if err ~= nil then
            error(err)
        end
    end)

end

return M


