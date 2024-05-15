require 'busted.runner'()

describe("serialize", function()
    setup(function()
        serialize = require 'init'
        math = require 'math'
    end)

    it("converts tables to strings and back", function()
        local tests = {
            -- Empty table
            ['{\n\n}'] = {},

            -- Arrays
            ['{\n    true,\n    true,\n    false\n}'] =
                { true, true, false },
            ['{\n    1,\n    2,\n    3\n}'] =
                { 1, 2, 3 },
            ['{\n    1.0,\n    0.5,\n    0.25,\n    0.125,\n    0.0625\n}'] =
                { 1.0, 0.5, 0.25, 0.125, 0.0625 },

            -- Basic types
            ['{\n    key = "strings are double quoted"\n}'] =
                { key = "strings are double quoted" },

            ['{\n    key = "\'string\'"\n}'] =
                { key = "\'string\'" },
            ['{\n    key = "\\"string\\""\n}'] =
                { key = "\"string\"" },

            ['{\n    ikey = 10\n}'] = { ikey = 10 },
            ['{\n    fkey = 0.9843\n}'] = { fkey = 0.9843 },
            ['{\n    falsekey = false\n}'] = { falsekey = false },
            ['{\n    truekey = true\n}'] = { truekey = true },

            -- Mixed
            ['{\n    3,\n    2,\n    1,\n    what = "half array"\n}'] =
                { 3, 2, 1, what = "half array" },
        }

        for k,v in pairs(tests) do
            local s = assert.has_no.errors(function()
                return serialize.pack(v)
            end)
            assert.are.equal(s, k)

            local o = assert(serialize.unpack(s))
            assert.are.same(v, o)
        end
    end)

    it("accepts tables with nil entries", function()
        local tests = {
            ['{ nil }'] = {},
            ['{ key = nil }'] = {},
            ['{ 1, 2, 3, 4, nil, 5 }'] = { 1, 2, 3, 4, nil, 5 },
            ['{ 1, 2, 3, 4, nil }'] = { 1, 2, 3, 4 },
            ['{ nil, 2, 3, 4 }'] = { nil, 2, 3, 4 },
        }

        for k,v in pairs(tests) do
            local o = assert(serialize.unpack(k))
            assert.are.same(v, o)
        end
    end)

    it("errors on attempt to serialize functions in strict mode", function()
        assert.has.error(function()
            serialize.pack({
                boom = function() end
            })
        end)
        assert.has.error(function()
            serialize.pack({
                function() end
            })
        end)
        assert.has.error(function()
            serialize.pack({
                1, 2, 3,
                key = "a key",
                boom = function() end
            })
        end)
        assert.has.error(function()
            serialize.pack({
                1, 2, function() end,
                key = "a key",
                val = 10.0e-4
            })
        end)
    end)

    it("supports tables with complex keys", function()
        local tablekey = { key = "table key", value = { nil, 1, 2, 3 }, booga = true }

        local test = {
            ['key with spaces'] = 1,
            ['key with \'single quotes\''] = 2,
            ['key with "double quotes"'] = 3,
            ['key with "both" \'quotes\''] = 4,
            ['\b key \\ with \a escapes \t'] = 5,
            ['key with embedded \0 zero'] = 6,
            [tablekey] = 7,
            [10] = 8,
            [0.5] = 9,
            [true] = 10,
            [false] = 11,
            [-1] = 12
        }

        local s = assert.has_no.errors(function()
            return serialize.pack(test)
        end)

        local o = assert(serialize.unpack(s))

        -- Compare for equality (table key requires extra care).
        for k,v in pairs(o) do
            if type(k) == 'table' then
                assert.are.same(tablekey, k)
                assert.are.same(test[tablekey], v)
            else
                assert.are.same(test[k], v)
            end
        end

        local function countkeys(o)
            local n = 0
            for _ in pairs(o) do n = n + 1 end
            return n
        end

        assert.are.equal(countkeys(test), countkeys(o))
    end)

    it("supports nested tables", function()
        pending("to be tested...")
    end)

    it("allows explicit skip of functions during pack()", function()
        local expected = {
            '{\n\n}',
            '{\n\n}',
            '{\n    1,\n    2,\n    key = "a key"\n}',
            '{\n    1,\n    2,\n    3,\n    key = "a key"\n}'
        }
        local actual = {}

        assert.has_no.errors(function()
            actual[#actual+1] = serialize.pack({
                boom = function() end
            }, 1, 'skip-functions')
            actual[#actual+1] = serialize.pack({
                function() end
            }, 1, 'skip-functions')
            actual[#actual+1] = serialize.pack({
                1, 2, function() end,
                key = "a key"
            }, 1, 'skip-functions')
            actual[#actual+1] = serialize.pack({
                1, 2, 3,
                key = "a key",
                boom = function() end
            }, 1, 'skip-functions')
        end)

        assert.are.same(expected, actual)
    end)

    it("errors on non-finite keys or values", function()
        assert.has.error(function() serialize.pack({  math.huge }) end)
        assert.has.error(function() serialize.pack({ -math.huge }) end)
        assert.has.error(function() serialize.pack({  0/0 }) end)

        assert.has.error(function() serialize.pack({ [-math.huge] = "-inf" }) end)
        assert.has.error(function() serialize.pack({ [ math.huge] = "inf" }) end)
        assert.has.error(function() serialize.pack({ [ 0/0] = "NaN" }) end)

        assert.has.error(function() serialize.pack({ inf    =  math.huge }) end)
        assert.has.error(function() serialize.pack({ neginf = -math.huge }) end)
        assert.has.error(function() serialize.pack({ nan    =  0/0 }) end)
    end)

    it("may only pack() tables", function()
        assert.has.error(function() serialize.pack("meow") end)
        assert.has.error(function() serialize.pack(true) end)
        assert.has.error(function() serialize.pack(42) end)
        assert.has.error(function() serialize.pack(25.12) end)
        assert.has.error(function() serialize.pack(nil) end)
        assert.has.error(function() serialize.pack(function() end) end)
    end)

    it("may only unpack() strings", function()
        assert.has.error(function() serialize.unpack({}) end)
        assert.has.error(function() serialize.unpack(true) end)
        assert.has.error(function() serialize.unpack(42) end)
        assert.has.error(function() serialize.unpack(25.12) end)
        assert.has.error(function() serialize.unpack(nil) end)
        assert.has.error(function() serialize.unpack(function() end) end)
    end)
end)
