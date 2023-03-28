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
end)
