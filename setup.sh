# brew install minikube
# brew install helm
# helm repo add stable https://kubernetes-charts.storage.googleapis.com
# minikube service <name>

minikube start --cpus=4 --memory 4000 --disk-size 11000 --vm-driver virtualbox --extra-config=apiserver.service-node-port-range=1-35000

helm repo update

helm install -f srcs/influxdb.yaml influxdb stable/influxdb
helm install -f srcs/grafana.yaml grafana stable/grafana

minikube addons enable ingress

kubectl apply -f srcs/mysql.yaml
kubectl apply -f srcs/wordpress.yaml
kubectl apply -f srcs/nginx.yaml
kubectl apply -f srcs/ingress.yaml

kubectl get all
minikube ip

eval $(minikube docker-env)
minikube dashboard