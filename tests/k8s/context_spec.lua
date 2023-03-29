local context = require("k8s.context")
local utils = require("k8s.utils")
local mock = require("luassert.mock")

describe("contexts", function()
	it("get", function()
		it("should return list of contexts", function()
			local mock_utils = mock(utils, true)

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

			mock_utils.readfile.returns(mock_kubeconfig)

			context.config = {}
			context.config.context = {
				location = "~/.kube/config",
			}
			local contexts = context._get()
			assert.are.same({ "minikube-1", "minikube-2" }, contexts)
		end)
	end)
end)
