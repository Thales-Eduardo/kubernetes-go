# seu user do docker hub
docker build -t user/hello-go=v1 .
docker push user/hello-go:v1

cd k8s

# criar um cluster
kind create cluster --config kind.yaml && \
 kubectl config get-contexts && \
 kubectl config use-context kind-kubernetes-go 

# criar spacename
kubectl create namespace kubernetes-namespace-dev
kubectl get namespaces

# aplicando os arquivos server
kubectl apply -f configmap-env.yaml && \
    kubectl apply -f configmap-volume.yaml && \
    kubectl apply -f pvc.yaml && \
    kubectl apply -f secret.yaml && \
    kubectl apply -f deployments.yaml && \
    kubectl apply -f service.yaml && \
    kubectl apply -f hpa.yaml && \
    kubectl apply -f security.yaml

# metrics-server
wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
# no arquivo components.yaml pesquise por Deployments
# não temos tls instalado, então mude esse valor no arquivo components.yaml
# em -args:
# coloque esse valor - --kubelet-insecure-tls
kubectl apply -f metrics-server.yaml
kubectl get apiservices # v1beta1.metrics.k8s.io, kube-system/metrics-server, True

# testar respostas do server
kubectl port-forward svc/kubernetes-go-service 9000:80 -n kubernetes-namespace-dev 

# testando configmap-volume
kubectl get pods -n kubernetes-namespace-dev
kubectl exec -it kubernetes-deployments-564dbbc9cd-2cpmn -- bash -n kubernetes-namespace-dev
cd arquivo
cat qualquerNome.txt

# teste de estresse
kubectl port-forward svc/kubernetes-go-service 9000:80 -n kubernetes-namespace-dev 
kubectl run -it fortio --rm --image=fortio/fortio -- load -qps 800 /
 -t 120s -c 70 "http://kubernetes-go-service/healthz"
watch -n1 kubectl get hpa -n kubernetes-namespace-dev  


