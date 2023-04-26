local context = require("k8s.resources.context")
local utils = require("k8s.utils")
local mock = require("luassert.mock")

local mock_kubeconfig = [[
apiVersion: v1
kind: Config
clusters:
- name: minikube-1
  cluster:
    certificate-authority: /home/foo/.minikube/ca.crt
    server: https://172.20.0.1:8443
- name: minikube-2
  cluster:
    certificate-authority: /home/bar/.minikube/ca.crt
    server: https://172.20.0.2:8443
users:
- name: minikube-1
  user:
    client-certificate: /home/foo/.minikube/profiles/minikube/client.crt
    client-key: /home/foo/.minikube/profiles/minikube/client.key
- name: minikube-2
  user:
    client-certificate: /home/bar/.minikube/profiles/minikube/client.crt
    client-key: /home/bar/.minikube/profiles/minikube/client.key
contexts:
- name: minikube-1
  context:
    cluster: minikube-1
    namespace: default
    user: minikube-1
- name: minikube-2
  context:
    cluster: minikube-2
    namespace: default
    user: minikube-2
current-context: minikube-1
]]

describe("contexts", function()
  before_each(function()
    context.config = {}
    context.config.context = {
      location = "~/.kube/config",
    }
  end)

  it("get_current", function()
    it("should return current context", function()
      local mock_utils = mock(utils, true)
      mock_utils.readfile.returns(mock_kubeconfig)

      local contexts = context.get_current()
      assert.are.same("minikube-1", contexts)
    end)

    it("should return nil if no current-context specified", function()
      local mock_kubeconfig_without_current_context = [[
            apiVersion: v1
            kind: Config
            clusters:
            - name: minikube-1
              cluster:
                certificate-authority: /home/foo/.minikube/ca.crt
                server: https://172.20.0.1:8443
            - name: minikube-2
              cluster:
                certificate-authority: /home/bar/.minikube/ca.crt
                server: https://172.20.0.2:8443
            users:
            - name: minikube-1
              user:
                client-certificate: /home/foo/.minikube/profiles/minikube/client.crt
                client-key: /home/foo/.minikube/profiles/minikube/client.key
            - name: minikube-2
              user:
                client-certificate: /home/bar/.minikube/profiles/minikube/client.crt
                client-key: /home/bar/.minikube/profiles/minikube/client.key
            contexts:
            - name: minikube-1
              context:
                cluster: minikube-1
                namespace: default
                user: minikube-1
            - name: minikube-2
              context:
                cluster: minikube-2
                namespace: default
                user: minikube-2
            ]]

      local mock_utils = mock(utils, true)
      mock_utils.readfile.returns(mock_kubeconfig_without_current_context)

      local contexts = context.get_current()
      assert.are.same(nil, contexts)
    end)
  end)

  it("list", function()
    it("should return list of contexts", function()
      local mock_utils = mock(utils, true)
      mock_utils.readfile.returns(mock_kubeconfig)

      local contexts = context:list()
      assert.are.same({ { metadata = { name = "minikube-1" } }, { metadata = { name = "minikube-2" } } }, contexts)
    end)
  end)
end)
