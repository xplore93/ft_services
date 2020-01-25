# brew install minikube
# brew install jq
# kubectl delete daemonsets,replicasets,services,deployments,pods,rc,pv,pvc,secrets --all
# minikube service list

#minikube start --cpus=4 --memory 4000 --disk-size 5000 --vm-driver virtualbox --extra-config=apiserver.service-node-port-range=1-35000

# Script by https://github.com/nicokla for waiting while the POD is not ready
wait_for_deploy () {
	printf "\e[0;34mWaiting for \e[0;35m"$1"\e[0;34m...\e[0m"
	sleep 5s
	MYSQL=$(kubectl get pod mysql-0)
	RES="Error from server (NotFound): pods \"mysql\" not found"
	while [ $MYSQL == $RES ] do
		printf "\e[0;34m.\e[0m"
		sleep 5s
		MYSQL=$(kubectl get pod mysql-0)
	done
	sleep 5s
	printf "\e[0;34mDONE\e[0m\n"
}

# Activate adddons
minikube addons enable metrics-server
minikube addons enable ingress

# Change the IP variable to an actual kubernetes' IP in SQL file
MINIKUBE_IP=$(minikube ip)
cp srcs/db/mysql.sql srcs/db/mysql-target.sql
sed -i '' "s/##MINIKUBE_IP##/$MINIKUBE_IP/g" srcs/db/mysql-target.sql

# Apply all Deployments, Services and Volume Claims
kubectl apply -k srcs

# Wait while My_SQL's POD is not ready
# export MYSQL_POD=$(kubectl get pods | grep mysql | cut -d" " -f1)
wait_for_deploy mysql

# Execute the command to import SQL into the POD
kubectl exec -it mysql-0 -- mysql -u root -ppassword < srcs/db/mysql-target.sql

# Open Kubernetes' Dashboard
minikube dashboard