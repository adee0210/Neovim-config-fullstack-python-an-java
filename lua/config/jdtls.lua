-- Hàm lấy đường dẫn JDTLS từ Mason
local function get_jdtls()
    local mason_registry = require("mason-registry")
    local jdtls = mason_registry.get_package("jdtls")
    local jdtls_path = jdtls:get_install_path()
    local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
    local SYSTEM = "linux" -- Thay đổi nếu cần (win, mac)
    local config = jdtls_path .. "/config_" .. SYSTEM
    local lombok = jdtls_path .. "/lombok.jar"
    return launcher, config, lombok
end

-- Hàm lấy bundles cho DAP
local function get_bundles()
    local mason_registry = require("mason-registry")
    local java_debug = mason_registry.get_package("java-debug-adapter")
    local java_debug_path = java_debug:get_install_path()
    local java_test = mason_registry.get_package("java-test")
    local java_test_path = java_test:get_install_path()

    local bundles = {
        vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", 1),
    }
    vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar", 1), "\n"))
    return bundles
end

-- Hàm lấy workspace directory
local function get_workspace()
    local home = os.getenv("HOME")
    local workspace_path = home .. "/code/workspace/"
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    local workspace_dir = workspace_path .. project_name
    vim.fn.mkdir(workspace_path, "p")
    return workspace_dir
end

-- Hàm kết hợp organize imports và format
local function organize_and_format()
    require('jdtls').organize_imports() -- Sắp xếp imports
    vim.lsp.buf.format({ async = false }) -- Định dạng mã
end

-- Hàm thiết lập keymaps cho Java
local function java_keymaps(bufnr)
    local opts = { buffer = bufnr }
    vim.cmd("command! -buffer -nargs=? -complete=custom,v:lua.require'jdtls'._complete_compile JdtCompile lua require('jdtls').compile(<f-args>)")
    vim.cmd("command! -buffer JdtUpdateConfig lua require('jdtls').update_project_config()")
    vim.cmd("command! -buffer JdtBytecode lua require('jdtls').javap()")
    vim.cmd("command! -buffer JdtJshell lua require('jdtls').jshell()")

    vim.keymap.set('n', '<leader>Jo', organize_and_format, vim.tbl_extend("force", opts, { desc = "Sắp xếp Imports và định dạng mã Java" }))
    vim.keymap.set('n', '<leader>Jv', "<Cmd>lua require('jdtls').extract_variable()<CR>", vim.tbl_extend("force", opts, { desc = "Trích xuất Biến trong Java" }))
    vim.keymap.set('v', '<leader>Jv', "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", vim.tbl_extend("force", opts, { desc = "Trích xuất Biến trong Java" }))
    vim.keymap.set('n', '<leader>JC', "<Cmd>lua require('jdtls').extract_constant()<CR>", vim.tbl_extend("force", opts, { desc = "Trích xuất Hằng số trong Java" }))
    vim.keymap.set('v', '<leader>JC', "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", vim.tbl_extend("force", opts, { desc = "Trích xuất Hằng số trong Java" }))
    vim.keymap.set('n', '<leader>Jt', "<Cmd>lua require('jdtls').test_nearest_method()<CR>", vim.tbl_extend("force", opts, { desc = "Kiểm tra Phương thức Gần nhất trong Java" }))
    vim.keymap.set('v', '<leader>Jt', "<Esc><Cmd>lua require('jdtls').test_nearest_method(true)<CR>", vim.tbl_extend("force", opts, { desc = "Kiểm tra Phương thức Gần nhất trong Java" }))
    vim.keymap.set('n', '<leader>JT', "<Cmd>lua require('jdtls').test_class()<CR>", vim.tbl_extend("force", opts, { desc = "Kiểm tra Lớp trong Java" }))
    vim.keymap.set('n', '<leader>Ju', "<Cmd>JdtUpdateConfig<CR>", vim.tbl_extend("force", opts, { desc = "Cập nhật Cấu hình trong Java" }))
    vim.keymap.set('n', '<C-s>', organize_and_format, vim.tbl_extend("force", opts, { desc = "Lưu và định dạng mã Java" }))
end

-- Hàm chính cấu hình JDTLS
local function setup_jdtls()
    local jdtls = require("jdtls")
    local launcher, os_config, lombok = get_jdtls()
    local workspace_dir = get_workspace()
    local bundles = get_bundles()
    local root_dir = jdtls.setup.find_root({ '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle', 'build.gradle.kts' })

    local capabilities = {
        workspace = { configuration = true },
        textDocument = { completion = { snippetSupport = false } },
    }
    local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
    for k, v in pairs(lsp_capabilities) do capabilities[k] = v end

    local extendedClientCapabilities = jdtls.extendedClientCapabilities
    extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
    extendedClientCapabilities.onCompletionItemSelectedCommand = "editor.action.triggerParameterHints"
    extendedClientCapabilities.classFileContentsSupport = true

    local cmd = {
        'java',
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-Xmx2g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens', 'java.base/java.util=ALL-UNNAMED',
        '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
        '-javaagent:' .. lombok,
        '-jar', launcher,
        '-configuration', os_config,
        '-data', workspace_dir,
    }

    local settings = {
        java = {
            format = {
                enabled = true,
                settings = {
                    url = vim.fn.stdpath("config") .. "/lang_servers/intellij-java-google-style.xml",
                    profile = "GoogleStyle",
                },
            },
            eclipse = { downloadSources = true },
            maven = { downloadSources = true },
            signatureHelp = { enabled = true },
            contentProvider = { preferred = "fernflower" },
            saveActions = { organizeImports = true },
            completion = {
                favoriteStaticMembers = {
                    "org.hamcrest.MatcherAssert.assertThat",
                    "org.hamcrest.Matchers.*",
                    "org.hamcrest.CoreMatchers.*",
                    "org.junit.jupiter.api.Assertions.*",
                    "java.util.Objects.requireNonNull",
                    "java.util.Objects.requireNonNullElse",
                    "org.mockito.Mockito.*",
                },
                filteredTypes = {
                    "com.sun.*",
                    "io.micrometer.shaded.*",
                    "java.awt.*",
                    "jdk.*",
                    "sun.*",
                },
                importOrder = { "java", "jakarta", "javax", "com", "org" },
            },
            sources = { organizeImports = { starThreshold = 9999, staticThreshold = 9999 } },
            codeGeneration = {
                toString = { template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}" },
                hashCodeEquals = { useJava7Objects = true },
                useBlocks = true,
            },
            configuration = { updateBuildConfiguration = "interactive" },
            referencesCodeLens = { enabled = true },
            inlayHints = { parameterNames = { enabled = "all" } },
            project = {
                referencedLibraries = {
                    "lib/**/*.jar",
                },
            },
        },
    }

    local init_options = {
        bundles = bundles,
        extendedClientCapabilities = extendedClientCapabilities,
    }

    local on_attach = function(client, bufnr)
        if vim.api.nvim_buf_get_option(bufnr, 'bufhidden') == 'wipe' then return end
        java_keymaps(bufnr)
        require('jdtls').setup_dap({ hotcodereplace = 'auto' })
        require('jdtls.setup').add_commands()
        vim.lsp.codelens.refresh()

        -- Tự động chạy organize_and_format khi lưu file Java
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            pattern = { "*.java" },
            callback = function()
                pcall(organize_and_format)
            end,
        })
    end

    local config = {
        cmd = cmd,
        root_dir = root_dir,
        settings = settings,
        capabilities = capabilities,
        init_options = init_options,
        on_attach = on_attach,
    }

    require('jdtls').start_or_attach(config)

    vim.api.nvim_create_autocmd("LspAttach", {
        pattern = "*.java",
        callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client and client.name == "jdtls" then
                require('jdtls.dap').setup_dap_main_class_configs()
            end
        end,
        once = true,
    })
end

-- Hàm cấu hình Kotlin Language Server
local function setup_kotlin()
    local lspconfig = require("lspconfig")
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    lspconfig.kotlin_language_server.setup({
        capabilities = capabilities,
        filetypes = { "kotlin", "kts" },
        root_dir = lspconfig.util.root_pattern(".git", "gradlew", "build.gradle.kts", "pom.xml"),
    })
end

-- Hàm cấu hình Groovy Language Server
local function setup_groovy()
    local lspconfig = require("lspconfig")
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    lspconfig.groovyls.setup({
        capabilities = capabilities,
        filetypes = { "groovy" },
        root_dir = lspconfig.util.root_pattern(".git", "gradlew", "build.gradle", "pom.xml"),
    })
end

-- Trả về các hàm cấu hình
return {
    setup_jdtls = setup_jdtls,
    setup_kotlin = setup_kotlin,
    setup_groovy = setup_groovy,
}
