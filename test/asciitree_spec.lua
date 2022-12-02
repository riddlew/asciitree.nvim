local asciitree = require("asciitree")
local say = require("say")

local data = {
	one_root = {
		"# A",
		"## B",
		"### C",
		"#### D",
		"##### E",
		"## F",
		"### G",
		"#### H",
		"### I",
		"## J",
		"### K",
	},
	many_root = {
		"# A",
		"## B",
		"### C",
		"# D",
		"## E",
		"### F",
		"# G",
		"## H",
		"### I",
		"# J",
		"## K",
		"## L",
	},
	default = {
		"#A",
		"## B",
		"### C",
		"#### D",
		"##### E",
		"## F",
		"### G",
		"#### H",
		"### I",
		"## J",
	},
	whitespace = {
		" ",
		"   ",
		"# A",
		"## B",
		"  ",
		" adflafsld",
		"  ",
		"  ",
		"### C",
		"#### D",
		"##### E",
		" -- Lua comment",
		"/* */",
		"## F",
		"### G",
		"#### H",
		"  ",
		"### I",
		"## J",
		"### K",
		"  ",
		" asdf",
	},
	depth = {
		"# A",
		"## B",
		"## C",
		"#### D",
		"# E",
		"## F",
		"### G",
		"### H",
		"#### I",
		"##### J",
		"##### K",
		"### L",
		"## M",
		"# N",
		"## O",
		"### P",
		"## Q",
		"### R",
	},
	custom_delimiter = {
		"- A",
		"-- B",
		"--- C",
		"---- D",
		"----- E",
		"-- F",
		"--- G",
		"---- H",
		"--- I",
		"-- J",
		"--- K",
	},
	custom_delimiter_2 = {
		"* A",
		"** B",
		"*** C",
		"**** D",
		"***** E",
		"** F",
		"*** G",
		"**** H",
		"*** I",
		"** J",
		"*** K",
	},
	custom_delimiter_3 = {
		". A",
		".. B",
		"... C",
		".... D",
		"..... E",
		".. F",
		"... G",
		".... H",
		"... I",
		".. J",
		"... K",
	},
	custom_delimiter_4 = {
		"+ A",
		"++ B",
		"+++ C",
		"++++ D",
		"+++++ E",
		"++ F",
		"+++ G",
		"++++ H",
		"+++ I",
		"++ J",
		"+++ K",
	},
}

local target = {
	one_root = {
		"A",
		"├─ B",
		"│  └─ C",
		"│     └─ D",
		"│        └─ E",
		"├─ F",
		"│  ├─ G",
		"│  │  └─ H",
		"│  └─ I",
		"└─ J",
		"   └─ K",
	},
	many_root = {
		"├─ A",
		"│  └─ B",
		"│     └─ C",
		"├─ D",
		"│  └─ E",
		"│     └─ F",
		"├─ G",
		"│  └─ H",
		"│     └─ I",
		"└─ J",
		"   ├─ K",
		"   └─ L",
	},
	default = {
		"A",
		"├─ B",
		"│  └─ C",
		"│     └─ D",
		"│        └─ E",
		"├─ F",
		"│  ├─ G",
		"│  │  └─ H",
		"│  └─ I",
		"└─ J",
		"   └─ K",
	},
	depth_1 = {
		"├ A",
		"│ ├ B",
		"│ └ C",
		"│   └ D",
		"├ E",
		"│ ├ F",
		"│ │ ├ G",
		"│ │ ├ H",
		"│ │ │ └ I",
		"│ │ │   ├ J",
		"│ │ │   └ K",
		"│ │ └ L",
		"│ └ M",
		"└ N",
		"  ├ O",
		"  │ └ P",
		"  └ Q",
		"    └ R",
	},
	depth_4 = {
		"├─── A",
		"│    ├─── B",
		"│    └─── C",
		"│         └─── D",
		"├─── E",
		"│    ├─── F",
		"│    │    ├─── G",
		"│    │    ├─── H",
		"│    │    │    └─── I",
		"│    │    │         ├─── J",
		"│    │    │         └─── K",
		"│    │    └─── L",
		"│    └─── M",
		"└─── N",
		"     ├─── O",
		"     │    └─── P",
		"     └─── Q",
		"          └─── R",
	},
	depth_8 = {
		"├─────── A",
		"│        ├─────── B",
		"│        └─────── C",
		"│                 └─────── D",
		"├─────── E",
		"│        ├─────── F",
		"│        │        ├─────── G",
		"│        │        ├─────── H",
		"│        │        │        └─────── I",
		"│        │        │                 ├─────── J",
		"│        │        │                 └─────── K",
		"│        │        └─────── L",
		"│        └─────── M",
		"└─────── N",
		"         ├─────── O",
		"         │        └─────── P",
		"         └─────── Q",
		"                  └─────── R",
	},
	symbols = {
		"A",
		"+. B",
		"|  L. C",
		"|     L. D",
		"|        L. E",
		"+. F",
		"|  +. G",
		"|  |  L. H",
		"|  L. I",
		"L. J",
	},
}

local function tbl_equal(_, arguments)
	local first = arguments[1]
	local second = arguments[2]

	if vim.deep_equal(first, second) then
		return true
	end

	return false
end

say:set_namespace("en")
say:set(
	"assertion.tbl_equal.positive",
	"Expected both tables to be equal:\nExpected: %s\nReceived: %s"
)
assert:register(
	"assertion",
	"tbl_equal",
	tbl_equal,
	"assertion.tbl_equal.positive"
)

describe("asciitree", function()
	describe("should get the correct args", function()
		it("given 0 argument", function()
			local args = asciitree.get_args()
			assert.equal(args.depth, asciitree.settings.depth)
			assert.equal(args.delimiter, asciitree.settings.delimiter)
		end)
		it("given 1 argument", function()
			local args = asciitree.get_args(3)
			assert.equal(args.depth, 3)
			assert.equal(args.delimiter, asciitree.settings.delimiter)

			args = asciitree.get_args("-")
			assert.equal(args.depth, asciitree.settings.depth)
			assert.equal(args.delimiter, "-")
		end)
		it("given 2 arguments in any order", function()
			local args = asciitree.get_args(3, "-")
			assert.equal(args.depth, 3)
			assert.equal(args.delimiter, "-")

			args = asciitree.get_args("-", 3)
			assert.equal(args.depth, 3)
			assert.equal(args.delimiter, "-")
		end)
	end)
	it("should collapse top level when only one root directory", function()
		local result = asciitree.format_branches(data.one_root)
		assert.tbl_equal(target.one_root, result)
	end)
	it(
		"should not collapse top level when there is more than one directory",
		function()
			local result = asciitree.format_branches(data.many_root)
			assert.tbl_equal(target.many_root, result)
		end
	)
	it(
		"should ignore any whitespace and lines that do not use a delimiter",
		function()
			local result = asciitree.format_branches(data.whitespace)
			assert.tbl_equal(target.default, result)
		end
	)
	it("should generate a tree with a custom depth", function()
		local result = asciitree.format_branches(data.depth, { depth = 1 })
		assert.tbl_equal(target.depth_1, result)

		result = asciitree.format_branches(data.depth, { depth = 4 })
		assert.tbl_equal(target.depth_4, result)

		result = asciitree.format_branches(data.depth, { depth = 8 })
		assert.tbl_equal(target.depth_8, result)
	end)
	it("should generate a tree with a custom delimiter", function()
		local result = asciitree.format_branches(
			data.custom_delimiter,
			{ delimiter = "-" }
		)
		assert.tbl_equal(target.default, result)

		result = asciitree.format_branches(
			data.custom_delimiter_2,
			{ delimiter = "*" }
		)
		assert.tbl_equal(target.default, result)

		result = asciitree.format_branches(
			data.custom_delimiter_3,
			{ delimiter = "." }
		)
		assert.tbl_equal(target.default, result)

		result = asciitree.format_branches(
			data.custom_delimiter_4,
			{ delimiter = "+" }
		)
		assert.tbl_equal(target.default, result)
	end)
	it("should generate a tree with custom symbols", function()
		asciitree.settings.symbols = {
			child = "+",
			last = "L",
			parent = "|",
			dash = ".",
			blank = " ",
		}
		local result = asciitree.format_branches(data.default)
		assert.tbl_equal(target.symbols, result)
		asciitree.settings.symbols = {
			child = "├",
			last = "└",
			parent = "│",
			dash = "─",
			blank = " ",
		}
	end)
end)
