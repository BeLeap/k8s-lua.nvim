# k8s-lua.nvim

[![Test](https://github.com/BeLeap/k8s-lua.nvim/actions/workflows/test.yaml/badge.svg)](https://github.com/BeLeap/k8s-lua.nvim/actions/workflows/test.yaml)
[![Format](https://github.com/BeLeap/k8s-lua.nvim/actions/workflows/format.yaml/badge.svg)](https://github.com/BeLeap/k8s-lua.nvim/actions/workflows/format.yaml)

## This Neovim plugin is a work in progress

This Neovim plugin is still under development, and many things could change.
Please do not rely on it for production use,
and report any bugs or issues you find to the [issue tracker](https://github.com/BeLeap/k8s-lua.nvim/issues).

Thank you for your understanding!

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "BeLeap/k8s-lua.nvim",
  dependencies = {
   "nvim-treesitter/nvim-treesitter",
  },
  cmd = { "Kube" },
  config = true,
}
```

## Contributing

All contributions are welcome.
Please open a pull request.

See [CONTRIBUTING.md](CONTRIBUTING.md)
