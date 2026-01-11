1. Minikube:Запустите minikube start.
2. Namespace: kubectl apply -f 01-create-namespace.yaml.
3. Gatekeeper: kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/v3.21.0/deploy/gatekeeper.yaml.
4. Шаблоны и constraints Gatekeeper: Примените файлы из gatekeeper/.
6. Тестирование манифестов: kubectl apply -f <manifest>.yaml — insecure должны блокироваться, secure — создаваться.