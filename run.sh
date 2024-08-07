#!/bin/sh

# MAKE SURE bins are in usr/bin
# add buildkite-agent to docker group

echo "STARTING SCRIPT"

echo $HOME 
echo $PATH

# Display current kubectl context
echo "-- getting kubectl context"
kubectl config current-context

# Set kubectl context to kind cluster
echo "-- use context"
kubectl config use-context kind-kind

# Create Kubernetes cluster using kind
echo "creating cluster"
kind create cluster --config=infra/cluster.yaml

echo "Apply LoadBalancer"
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml

# Apply the NGINX Ingress Controller
echo "applying nginx ingress"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Delete the validating webhook configuration for NGINX
echo "deleting webhook validation"
kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission

# Apply Resources
echo "applying resources"
kubectl apply -f infra/ingress.yml 
kubectl apply -f infra/go-api.yaml
kubectl apply -f infra/react-app.yaml

# Wait for the NGINX Ingress Controller to be fully deployed
echo "waiting for nginx ingress controller to be ready"
kubectl rollout status deployment/ingress-nginx-controller -n ingress-nginx

# Wait for the services to be assigned external IPs (LoadBalancer services)
echo "waiting for LoadBalancer services to get external IPs"
kubectl get svc --watch &

# Display all resources to verify the deployment
echo "checking deployment"
kubectl get all

# Optionally check if the services are reachable
echo "checking apps are running"
sleep 10
curl -s localhost/random-name || echo "go service is not responding"
echo "SCRIPT FINISHED"
