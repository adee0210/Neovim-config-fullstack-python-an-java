return {
    -- Cài đặt plugin harpoon
    "ThePrimeagen/harpoon",
    event = "VeryLazy",  -- Kích hoạt plugin khi sự kiện 'VeryLazy' xảy ra
    dependencies = {
        "nvim-lua/plenary.nvim"  -- Plugin phụ thuộc, cung cấp các hàm tiện ích cho harpoon
    },
    config = function()
        -- Đặt phím tắt <Shift> + m để đánh dấu một tệp với harpoon
        vim.keymap.set("n", "<s-m>", "<cmd>lua require('harpoon.mark').add_file()<cr>", {desc = "Đánh dấu tệp bằng Harpoon"})
        
        -- Đặt phím tắt <TAB> để mở menu harpoon và dễ dàng chuyển đổi giữa các tệp tin
        vim.keymap.set("n", "<TAB>", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", {desc = "Mở/Ẩn menu Harpoon"})
    end
}
