# discover-my-major

Popup the keys and description for the current major mode. The command is inspired by [discover.el](https://github.com/mickeynp/discover.el) and also uses [makey library](https://github.com/mickeynp/makey). I thought, "Hey! Why not parse the information about the major mode bindings somehow and display that like `discover.el` does..."

**Currently this is still in development. The output is pretty bare bones and not optimized**

## Installation

### el-get

```lisp
(:name discover-my-major
       :type git
       :url "https://github.com/steckerhalter/discover-my-major")
```

## Usage

In any mode you should be able to summon the popup by invoking `M-x discover-my-major` which will show you a list of key bindings with descriptions.
