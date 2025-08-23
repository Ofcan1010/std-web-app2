# Adımlar
1) Docker build & push (ARM64):
   export U=ofcan1010
   docker build -t $U/db:v1 ./db        && docker push $U/db:v1
   docker build -t $U/backend:v1 ./backend && docker push $U/backend:v1
   docker build -t $U/frontend:v1 ./frontend && docker push $U/frontend:v1

2) Terraform:
   cd terraform
   terraform init
   terraform apply -auto-approve -var region=eu-central-1 -var key_name=student-web-key -var my_ip=185.227.183.150/32

3) Ansible:
   cd ..
   ansible-playbook -i ansible/hosts.ini ansible/site.yml

4) Test:
   kubectl -n prod get pods,svc,ingress
   curl -s http://13.62.39.16/api/health
   curl -s http://13.62.39.16/api/list