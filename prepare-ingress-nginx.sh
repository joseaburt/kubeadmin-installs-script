kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.0/deploy/static/provider/baremetal/deploy.yaml

kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission

kubectl get all -n ingress-nginx