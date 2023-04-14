local utils = require("k8s.utils")

describe("utils", function()
    it("join_to_string", function()
        it("should join list of string to string with newline", function()
            local given_data = {
                "foo",
                "bar",
            }

            local result = utils.join_to_string(given_data)

            assert.are.equal("foo\nbar", result)
        end)
    end)

    it("union", function()
        it("should concat list without duplicated item", function()
            local list1 = { 1, 2, 3, 4, 5 }
            local list2 = { 1, 3, 5, 7, 9 }

            local result = utils.union(list1, list2)

            local hash = {}
            for _, item in ipairs(result) do
                if hash[item] then
                    assert(false, "duplicated item exists")
                else
                    hash[item] = true
                end
            end

            local expected_hash = {
                [1] = true,
                [2] = true,
                [3] = true,
                [4] = true,
                [5] = true,
                [7] = true,
                [9] = true,
            }
            assert.are.same(expected_hash, hash)
        end)
    end)

    it("calculate_diffs", function()
        local original = {
            lorem = {
                ipsum = {
                    common = "common",
                    dolor = "foo",
                    dolor1 = "test",
                },
            },
        }
        local new = {
            lorem = {
                ipsum = {
                    common = "common",
                    dolor = "bar",
                    dolor2 = "test",
                },
            },
        }

        local diffs = utils.calculate_diffs(original, new)

        assert.are.same({
            { op = "replace", path = "/lorem/ipsum/dolor", value = "bar" },
            { op = "remove", path = "/lorem/ipsum/dolor1" },
            { op = "add", path = "/lorem/ipsum/dolor2", value = "test" },
        }, diffs)
    end)
end)
