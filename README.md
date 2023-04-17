# k8s-lua.nvim

[![Test](https://github.com/BeLeap/k8s-lua.nvim/actions/workflows/test.yaml/badge.svg)](https://github.com/BeLeap/k8s-lua.nvim/actions/workflows/test.yaml)
[![Format](https://github.com/BeLeap/k8s-lua.nvim/actions/workflows/format.yaml/badge.svg)](https://github.com/BeLeap/k8s-lua.nvim/actions/workflows/format.yaml)

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "BeLeap/k8s-lua.nvim",
  dependencies = {
   "nvim-treesitter/nvim-treesitter",
   "nvim-telescope/telescope.nvim",
  },
  cmd = { "Kube" },
  config = true,
}
```

## Contributing

### Format

Uses [stylua](https://github.com/JohnnyMorganz/StyLuahttps://github.com/JohnnyMorganz/StyLua)

```sh
stylua .
```

### Test

```sh
make
```
