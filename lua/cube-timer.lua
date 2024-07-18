local M = {}

local api = vim.api

M.state = {
    timer_running = false,

    size = 0.9,

    scramble = nil,
    scramble_type = "3x3",
    scramble_lenghts = { ["2x2"] = 9, ["3x3"] = 21, ["4x4"] = 42 },

    buf = nil,
    win_handle = nil,

    programatic_change = false,

    screen = {},

    timer = nil,
    last_time = nil,
    times = {},
}

function M.generate_scramble()
    -- NOTE: improve scramble generation algorithms?
    local moves, scramble = {}, {}
    if M.state.scramble_type == "2x2" then
        moves = { "R", "R'", "R2", "U", "U'", "U2", "F", "F'", "F2" }
    elseif M.state.scramble_type == "3x3" then
        moves = { "R", "R'", "R2", "L", "L'", "L2", "U", "U'", "U2", "D", "D'", "D2", "F", "F'", "F2", "B", "B'", "B2" }
    elseif M.state.scramble_type == "4x4" then
        moves = {
            "R", "Rw", "R'", "Rw'", "R2", "Rw2",
            "L", "Lw", "L'", "Lw'", "L2", "Lw2",
            "U", "Uw", "U'", "Uw'", "U2", "Uw2",
            "D", "Dw", "D'", "Dw'", "D2", "Dw2",
            "F", "Fw", "F'", "Fw'", "F2", "Fw2",
            "B", "Bw", "B'", "Bw'", "B2", "Bw2"
        }
    else
        return ""
    end
    for _ = 0, M.state.scramble_lenghts[M.state.scramble_type] do
        local rand_i = math.random(1, #moves)
        if #scramble ~= 0 then
            while string.sub(scramble[#scramble], 1, 1) == string.sub(moves[rand_i], 1, 1) do
                rand_i = math.random(1, #moves)
            end
        end
        table.insert(scramble, moves[rand_i])
    end
    return table.concat(scramble, " ")
end

local function round_to_decimal_place(number, decimal_place)
    local multiplier = 10 ^ decimal_place
    return math.floor(number * multiplier + 0.5) / multiplier
end

local function display_ao(n)
    if #M.state.times >= n then
        local notimes = #M.state.times
        local avg = 0
        local min = M.state.times[notimes - n + 1]
        local max = M.state.times[notimes - n + 1]
        for i = notimes - n + 1, notimes do
            avg = avg + M.state.times[i]
            if M.state.times[i] < min then
                min = M.state.times[i]
            end
            if M.state.times[i] > max then
                max = M.state.times[i]
            end
        end
        avg = avg - min - max
        avg = round_to_decimal_place(avg / (n - 2), 2)
        table.insert(M.state.screen, "Ao" .. n .. ": " .. avg .. "s")
    else
        table.insert(M.state.screen, "Ao" .. n .. ": -")
    end
end

function M.redraw_screen()
    M.state.screen = { "[" .. M.state.scramble_type .. "] Scramble: ", M.state.scramble }

    table.insert(M.state.screen, "")
    if M.state.timer_running == true then
        table.insert(M.state.screen, "Timer running...")
    else
        if M.state.last_time == nil then
            table.insert(M.state.screen, "[TIME]: start the timer using <space>")
        else
            table.insert(M.state.screen, "[TIME]: " .. M.state.last_time .. "s")
        end
    end
    table.insert(M.state.screen, "")

    display_ao(5)
    display_ao(12)

    table.insert(M.state.screen, "")
    table.insert(M.state.screen, "Last times:")
    if #M.state.times == 0 then
        table.insert(M.state.screen, "-")
    else
        for i, v in ipairs(M.state.times) do
            table.insert(M.state.screen, i .. ". " .. v .. "s")
        end
    end

    vim.schedule(function()
        M.state.programatic_change = true
        if M.state.buf ~= nil then
            table.insert(M.state.screen, "")
            api.nvim_buf_set_lines(M.state.buf, 0, -1, false, M.state.screen)

            -- Put cursor in the right place
            api.nvim_win_set_cursor(0, { 1, 0 })
        end
        api.nvim_command("redraw")
        M.state.programatic_change = false
    end)
end

function M.handle_click(_, _, _, start_row, start_col, _, _, _)
    if M.state.buf == nil or M.state.programatic_change == true then
        return
    end

    local lines = api.nvim_buf_get_lines(M.state.buf, start_row, start_row + 1, false)
    local line = lines[1]

    local col = start_col + 1
    local key = line:sub(col, col)

    if key == " " then
        if M.state.timer_running == true then
            M.state.last_time = round_to_decimal_place((vim.loop.hrtime() - M.state.timer) / 1e9, 2)
            table.insert(M.state.times, M.state.last_time)
            M.state.scramble = M.generate_scramble()
            M.state.timer_running = false
        elseif M.state.timer_running == false then
            M.state.timer = vim.loop.hrtime()
            M.state.timer_running = true
        end
    elseif key == "\\" then
        if M.state.timer_running == false then
            local choice = vim.fn.confirm("Do you want to remove latest time?", "&Yes\n&No", 2)

            if choice == 1 then
                table.remove(M.state.times, #M.state.times)
            end
        end
    elseif key == "|" then
        if M.state.timer_running == false then
            local choice = vim.fn.confirm("Do you want to remove ALL times?", "&Yes\n&No", 2)

            if choice == 1 then
                M.state.times = {}
            end
        end
    elseif key == "2" or key == "3" or key == "4" then
        if M.state.timer_running == false then
            M.state.scramble_type = key .. "x" .. key
            M.state.scramble = M.generate_scramble()
        end
    elseif key == "q" then
        if M.state.buf ~= nil then
            vim.schedule(function()
                api.nvim_buf_delete(M.state.buf, { force = true })
                M.state.buf = nil
                api.nvim_command('stopinsert')
            end)
        end
        return
    end

    M.redraw_screen()
end

function M.start()
    -- Create a new buffer
    M.state.buf = api.nvim_create_buf(false, true)

    -- Change some buffer options
    api.nvim_buf_set_name(M.state.buf, "Cube Timer")
    api.nvim_set_option_value("filetype", "cube-timer", { buf = M.state.buf })

    local ui_info = api.nvim_list_uis()[1]
    local width = math.floor(math.floor(ui_info.width * M.state.size) / 2)
    local height = math.floor(ui_info.height * M.state.size)
    local border = "rounded"

    if M.state.size == 1 then
        border = "none"
    end

    M.state.win_handle = api.nvim_open_win(M.state.buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = (ui_info.height - height) * 0.5 - 1,
        col = (ui_info.width - width) * 0.5,
        style = "minimal",
        border = border
    })

    -- Generate initial scramble
    M.state.scramble = M.generate_scramble()

    -- Initial screen
    M.redraw_screen()

    -- Put cursor in the right place and start insert mode
    api.nvim_win_set_cursor(0, { 1, 0 })
    api.nvim_command("startinsert")

    -- Execute callback on every buffer change (key stroke)
    api.nvim_buf_attach(M.state.buf, false, {
        on_bytes = M.handle_click
    })
end

function M.setup(opts)
    opts = opts or {}
    M.state.size = opts.size or M.state.size
    M.state.scramble_lenghts = opts.scramble_lenghts or M.state.scramble_lenghts

    -- NOTE: ? inspection time + config (and also to show or not the timer)

    api.nvim_create_user_command("CubeTimer", function()
        M.start()
    end, {})
end

return M
