import json
from pathlib import Path

INPUT_LOG = "audit.log"
OUTPUT_LOG = "suspicious_events.json"

suspicious_events = []

def is_monitoring_secret_access(event):
    user = event.get("user", {}).get("username", "")
    obj = event.get("objectRef", {})
    return (
            obj.get("resource") == "secrets"
            and "serviceaccount" in user
            and "monitoring" in user
    )

def is_privileged_pod_creation(event):
    if event.get("verb") != "create":
        return False
    obj = event.get("objectRef", {})
    if obj.get("resource") != "pods":
        return False

    req = event.get("requestObject", {})
    spec = req.get("spec", {})
    for container in spec.get("containers", []):
        sc = container.get("securityContext", {})
        if sc.get("privileged") is True or sc.get("allowPrivilegeEscalation") is True:
            return True
    return False

def is_exec_into_pod(event):
    obj = event.get("objectRef", {})
    return obj.get("subresource") == "exec"

def is_audit_policy_deletion(event):
    if event.get("verb") != "delete":
        return False
    obj = event.get("objectRef", {})
    resource = obj.get("resource", "")
    return "audit" in resource.lower()

def is_rolebinding_creation(event):
    if event.get("verb") != "create":
        return False
    obj = event.get("objectRef", {})
    return obj.get("resource") in (
        "rolebindings",
        "clusterrolebindings"
    )

CHECKS = [
    ("monitoring_secrets_access", is_monitoring_secret_access),
    ("privileged_pod_creation", is_privileged_pod_creation),
    ("pod_exec", is_exec_into_pod),
    ("audit_policy_deletion", is_audit_policy_deletion),
    ("rolebinding_creation", is_rolebinding_creation),
]

with open(INPUT_LOG, "r", encoding="utf-8") as f:
    for line in f:
        line = line.strip()
        if not line:
            continue

        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue

        for label, check in CHECKS:
            if check(event):
                suspicious_events.append({
                    "type": label,
                    "verb": event.get("verb"),
                    "user": event.get("user", {}).get("username"),
                    "namespace": event.get("objectRef", {}).get("namespace"),
                    "resource": event.get("objectRef", {}).get("resource"),
                    "name": event.get("objectRef", {}).get("name"),
                    "decision": event.get("annotations", {}).get("authorization.k8s.io/decision"),
                    "timestamp": event.get("requestReceivedTimestamp"),
                    "raw_event": event
                })
                break

with open(OUTPUT_LOG, "w", encoding="utf-8") as out:
    json.dump(suspicious_events, out, ensure_ascii=False, indent=2)

print(f"Найдено событий: {len(suspicious_events)}")
print(f"Результат сохранён в {OUTPUT_LOG}")