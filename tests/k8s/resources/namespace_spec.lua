local namespace = require("k8s.resources.namespace")
local client = require("k8s.api.client")
local mock = require("luassert.mock")

describe("namespace", function()
    it("get", function()
        it("should return table from client get result", function()
            local mock_client = mock(client, true)
            mock_client.get.returns({ "lorem ipsum" })

            local result = namespace.get("foo")

            assert.are.same({ "lorem ipsum" }, result)
            assert.stub(mock_client.get).was_called_with("/api/v1/namespaces/foo")
        end)
    end)

    it("list_iter", function()
        it("should return metadata names in items from client get result", function()
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

            local result = namespace.list_iter()

            assert.are.same({ { metadata = { name = "lorem ipsum" } } }, result:tolist())
            assert.stub(mock_client.get).was_called_with("/api/v1/namespaces")
        end)
    end)
end)
