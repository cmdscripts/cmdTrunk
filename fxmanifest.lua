fx_version "adamant"
game "gta5"

shared_scripts {
	"@es_extended/imports.lua",
	"config.lua",
}

    client_scripts {
        "source/RageUI/RMenu.lua",
        "source/RageUI/menu/RageUI.lua",
        "source/RageUI/menu/Menu.lua",
        "source/RageUI/menu/MenuController.lua",
        "source/RageUI/components/*.lua",
        "source/RageUI/menu/elements/*.lua",
        "source/RageUI/menu/items/*.lua",
        "source/RageUI/menu/panels/*.lua",
    "source/client.lua",
    "source/functions.lua"

}

server_scripts {
    "@mysql-async/lib/MySQL.lua",
    "source/server.lua",
}