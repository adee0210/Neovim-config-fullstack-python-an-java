local M = {}

-- Hàm phát nhạc từ thư mục Coloi
local function play_music()
    local files = vim.fn.glob("/home/duc/Music/Coloi/*", true, true)
    if not files or type(files) ~= "table" or #files == 0 then
        vim.notify("Không tìm thấy file nhạc hoặc thư mục /home/duc/Music/Coloi không tồn tại", vim.log.levels.ERROR)
        return
    end

    local cmd = { "mpv", "--no-video", "--shuffle" }
    for _, file in ipairs(files) do
        table.insert(cmd, file)
    end

    vim.fn.jobstart(cmd, { detach = true })
    vim.notify("Đang phát nhạc từ Coloi", vim.log.levels.INFO)
end

-- Hàm phát nhạc từ thư mục Khongloi
local function play_music_khongloi()
    local files = vim.fn.glob("/home/duc/Music/Khongloi/*", true, true)
    if not files or type(files) ~= "table" or #files == 0 then
        vim.notify("Không tìm thấy file nhạc hoặc thư mục /home/duc/Music/Khongloi không tồn tại", vim.log.levels.ERROR)
        return
    end

    local cmd = { "mpv", "--no-video", "--shuffle" }
    for _, file in ipairs(files) do
        table.insert(cmd, file)
    end

    vim.fn.jobstart(cmd, { detach = true })
    vim.notify("Đang phát nhạc từ Khongloi", vim.log.levels.INFO)
end

-- Hàm tạm dừng/phát tiếp
local function toggle_music()
    local check_running = vim.fn.system("pgrep mpv")
    if vim.v.shell_error ~= 0 then
        vim.notify("Không có mpv đang chạy", vim.log.levels.WARN)
        return
    end

    local check_paused = vim.fn.system("ps -C mpv -o state | grep T")
    if vim.v.shell_error == 0 then
        vim.fn.system("pkill -SIGCONT mpv")
        vim.notify("Tiếp tục phát nhạc", vim.log.levels.INFO)
    else
        vim.fn.system("pkill -SIGSTOP mpv")
        vim.notify("Đã tạm dừng nhạc", vim.log.levels.INFO)
    end
end

-- Hàm tắt hoàn toàn (kill mpv)
local function kill_music()
    vim.fn.system("pkill -9 mpv")
    vim.notify("Đã tắt hoàn toàn nhạc", vim.log.levels.INFO)
end

-- Hàm Pomodoro 50 phút
local function start_pomodoro()
    local duration = 50 * 60 -- 50 phút tính bằng giây
    local start_time = os.time()
    local end_time = start_time + duration

    vim.notify("Bắt đầu Pomodoro: 50 phút", vim.log.levels.INFO)

    -- Tạo một timer để kiểm tra thời gian
    local timer = vim.loop.new_timer()
    timer:start(1000, 1000, vim.schedule_wrap(function()
        local current_time = os.time()
        local remaining = end_time - current_time

        if remaining <= 0 then
            timer:stop()
            timer:close()
            vim.notify("Hết 50 phút! Nghỉ ngơi đi nhé.", vim.log.levels.INFO)
        else
            local minutes = math.floor(remaining / 60)
            local seconds = remaining % 60
            vim.notify(string.format("Pomodoro còn lại: %02d:%02d", minutes, seconds), vim.log.levels.INFO, { replace = true })
        end
    end))
end

-- Thiết lập phím tắt với mô tả
function M.setup()
    local keymap_opts = { noremap = true, silent = false }
    vim.api.nvim_set_keymap("n", "<leader>Mp", "", {
        callback = play_music,
        noremap = true,
        silent = false,
        desc = "Phát tất cả nhạc trong /home/duc/Music/Coloi/"
    })
    vim.api.nvim_set_keymap("n", "<leader>Mk", "", {
        callback = play_music_khongloi,
        noremap = true,
        silent = false,
        desc = "Phát tất cả nhạc trong /home/duc/Music/Khongloi/"
    })
    vim.api.nvim_set_keymap("n", "<leader>Mt", "", {
        callback = toggle_music,
        noremap = true,
        silent = false,
        desc = "Tạm dừng hoặc tiếp tục phát nhạc"
    })
    vim.api.nvim_set_keymap("n", "<leader>Ms", "", {
        callback = kill_music,
        noremap = true,
        silent = false,
        desc = "Tắt hoàn toàn nhạc (kill mpv)"
    })
    vim.api.nvim_set_keymap("n", "<leader>pomo50", "", {
        callback = start_pomodoro,
        noremap = true,
        silent = false,
        desc = "Bắt đầu Pomodoro 50 phút"
    })
end

M.setup()

return M
