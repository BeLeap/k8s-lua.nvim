local pod = require("k8s.resources.pod")
local client = require("k8s.api.client")
local mock = require("luassert.mock")

local resources_namespace = require("k8s.resources.namespace")

describe("pod", function()
    after_each(function()
        resources_namespace.target = nil
    end)

    it("get", function()
        it("should request pod info", function()
            local mock_client = mock(client, true)
            mock_client.get.returns({ "lorem ipsum" })

            local result = pod.get("foo", "bar")

            assert.are.same({ "lorem ipsum" }, result)
            assert.stub(mock_client.get).was_called_with("/api/v1/namespaces/foo/pods/bar")
        end)
    end)

    it("list_iter", function()
        it("should request pods info", function()
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

            local result = pod.list_iter()

            assert.are.same({ { metadata = { name = "lorem ipsum" } } }, result:tolist())
            assert.stub(mock_client.get).was_called_with("/api/v1/pods")
        end)

        it("should request pods info with namespace if namespace target exists", function()
            resources_namespace.target = "foo"

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

            local result = pod.list_iter()

            assert.are.same({ { metadata = { name = "lorem ipsum" } } }, result:tolist())
            assert.stub(mock_client.get).was_called_with("/api/v1/namespaces/foo/pods")
        end)
    end)
end)
