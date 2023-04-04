local this = require("k8s.resources.namespace")
local client = require("k8s.api.client")
local mock = require("luassert.mock")

describe("this", function()
    it("get", function()
        local mock_client = mock(client, true)
        mock_client.get.returns({ "lorem ipsum" })

        local result = this.get("foo")

        assert.are.same({ "lorem ipsum" }, result)
        assert.stub(mock_client.get).was_called_with("/api/v1/namespaces/foo")
    end)

    it("list", function()
        local mock_client = mock(client, true)
        mock_client.get.returns({
            items = {
                {
                    metadata = {
                        name = "lorem ipsum",
                    },
                },
            },
        })

        local result = this.list()

        assert.are.same({ "lorem ipsum" }, result)
        assert.stub(mock_client.get).was_called_with("/api/v1/namespaces")
    end)
end)
