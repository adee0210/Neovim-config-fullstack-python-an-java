local M = {}

-- Hàm phát nhạc
local function play_music()
    local files = vim.fn.glob("/home/duc/Music/*", true, true)
    if not files or type(files) ~= "table" or #files == 0 then
        vim.notify("Không tìm thấy file nhạc hoặc thư mục /home/duc/Music/ không tồn tại", vim.log.levels.ERROR)
        return
    end

    local cmd = { "mpv", "--no-video", "--shuffle" }
    for _, file in ipairs(files) do
        table.insert(cmd, file)
    end

    vim.fn.jobstart(cmd, { detach = true })
    vim.notify("Đang phát nhạc", vim.log.levels.INFO)
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

-- Thiết lập phím tắt với mô tả
function M.setup()
    local keymap_opts = { noremap = true, silent = false }
    vim.api.nvim_set_keymap("n", "<leader>mp", "", {
        callback = play_music,
        noremap = true,
        silent = false,
        desc = "Phát tất cả nhạc trong /home/duc/Music/"
    })
    vim.api.nvim_set_keymap("n", "<leader>mt", "", {
        callback = toggle_music,
        noremap = true,
        silent = false,
        desc = "Tạm dừng hoặc tiếp tục phát nhạc"
    })
    vim.api.nvim_set_keymap("n", "<leader>ms", "", {
        callback = kill_music,
        noremap = true,
        silent = false,
        desc = "Tắt hoàn toàn nhạc (kill mpv)"
    })
end

M.setup()

return M
