# AsciiTree

Converts selected text into an ASCII tree using the `:AsciiTree` command. Inspired by the VSCode [Ascii Tree Generator plugin](https://marketplace.visualstudio.com/items?itemName=aprilandjan.ascii-tree-generator).

## Usage

Given the following text:
```
# documents
## word
### school
#### class A
#### class B
### work
#### proposal A
#### proposal B
## excel
### spreadsheet A
### spreadsheet B
### spreadsheet C
# code
## work
## github
### repos
```

Select the text in visual mode, and run the command `:AsciiTree`. You're text will be replaced with:
```
├─ documents
│  ├─ word
│  │  ├─ school
│  │  │  ├─ class A
│  │  │  └─ class B
│  │  └─ work
│  │     ├─ proposal A
│  │     └─ proposal B
│  └─ excel
│     ├─ spreadsheet A
│     ├─ spreadsheet B
│     └─ spreadsheet C
└─ code
   ├─ work
   └─ github
      └─ repos
```

The command accepts 1 argument - the width to use for each tree level. Shown above is the default value of `2`. The default value can be changed using the setup method.

`:AsciiTree 1`
```
├ documents
│ ├ word
│ │ ├ school
│ │ │ ├ class A
│ │ │ └ class B
│ │ └ work
│ │   ├ proposal A
│ │   └ proposal B
│ └ excel
│   ├ spreadsheet A
│   ├ spreadsheet B
│   └ spreadsheet C
└ code
  ├ work
  └ github
    └ repos
```

`:AsciiTree 4`
```
├─── documents
│    ├─── word
│    │    ├─── school
│    │    │    ├─── class A
│    │    │    └─── class B
│    │    └─── work
│    │         ├─── proposal A
│    │         └─── proposal B
│    └─── excel
│         ├─── spreadsheet A
│         ├─── spreadsheet B
│         └─── spreadsheet C
└─── code
     ├─── work
     └─── github
          └─── repos
```

## Installation

```lua
-- Packer
use 'xorid/asciitree.nvim'
```

## Setup

Setup is optional.

```lua
-- Default values
require("asciitree").setup({
	-- Characters used to represent the tree.
	symbols = {
		child = "├",
		last = "└",
		parent = "│",
		dash = "─",
		blank = " ",
	},

	-- How deep each level should be drawn. This value can be overridden by
	-- calling the AsciiTree command with a number, such as :AsciiTree 4.
	depth = 2,

	-- The delimiter to look for when converting to a tree. By default, this
	-- looks for a tree that looks like:
	-- # Level 1
	-- ## Level 2
	-- ### Level 3
	-- #### Level 4
	--
	-- Changing it to "+" would look for the following:
	-- + Level 1
	-- ++ Level 2
	-- +++ Level 3
	-- ++++ Level 4
	delimiter = "#",
})
```
