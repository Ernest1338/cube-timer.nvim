<h1><p align=center>Cube-timer.nvim</p></h1>
<h3><p align=center><sup>Rubik's cube timer as a neovim plugin</sup></p></h3>
<br \><br \>

![Screenshot 1](https://github.com/Ernest1338/cube-timer.nvim/assets/45213563/afadf25f-0f75-4e0f-9a9e-e82518734e40)

## ⚙️ Features
- 2x2, 3x3, 4x4 scrambles
- Ao5, Ao12 calculations
- Minial code

## 📦 Installation
- With [folke/lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{ "Ernest1338/cube-timer.nvim" }
```

- With [wbthomason/packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use "Ernest1338/cube-timer.nvim"
```

- With [echasnovski/mini.deps](https://github.com/echasnovski/mini.deps)
```lua
add("Ernest1338/cube-timer.nvim")
```

## 🚀 Usage
Firstly, call the `setup` function with optional config (see configuration options below):
```lua
require("cube-timer").setup()
```

Then use the `CubeTimer` command to show the timer

Key bindings:
- `q` - quit
- `2` - change to 2x2 scramble
- `3` - change to 3x3 scramble
- `4` - change to 4x4 scramble
- `space` - start/stop timer
- `` ` `` - remove last time
- `|` - clear times from current session

## 🔧 Configuration

Options:
- size (popup window size)
- scramble_lenghts (lenghts of scramble for each cube type, see below)

- For [folke/lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
    "Ernest1338/cube-timer.nvim",
    config = {
        size = 0.9,
        scramble_lenghts = { ["2x2"] = 9, ["3x3"] = 21, ["4x4"] = 42 }
    }
}
```

- For [wbthomason/packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use {
    "Ernest1338/cube-timer.nvim",
    config = function()
        require("cube-timer").setup({
            size = 0.5,
            scramble_lenghts = { ["2x2"] = 9, ["3x3"] = 21, ["4x4"] = 42 }
        })
    end
}
```

- For [echasnovski/mini.deps](https://github.com/echasnovski/mini.deps)
```lua
later(function()
    add("Ernest1338/cube-timer.nvim")
    require("cube-timer").setup({
        size = 0.5,
        scramble_lenghts = { ["2x2"] = 9, ["3x3"] = 21, ["4x4"] = 42 }
    })
end)
```

## ⚡ Requirements
- Neovim >= **v0.7.0**

## License

MIT

