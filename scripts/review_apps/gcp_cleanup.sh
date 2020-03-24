#!/bin/bash

source scripts/utils.sh

# These scripts require the following environment variables:
# - GCP_REGION - e.g `us-central1`
# - KUBE_NAMESPACE - e.g `review-apps-ee`

function delete_firewall_rules() {
  if [[ ${#@} -eq 0 ]]; then
    echoinfo "No firewall rules to be deleted" true
    return
  fi

  echoinfo "Deleting firewall rules:" true
  echo "${@}"

  if [[ ${DRY_RUN} = 1 ]]; then
    echo "[DRY RUN] gcloud compute firewall-rules delete -q" "${@}"
  else
    gcloud compute firewall-rules delete -q "${@}"
  fi
}

function delete_forwarding_rules() {
  if [[ ${#@} -eq 0 ]]; then
    echoinfo "No forwarding rules to be deleted" true
    return
  fi

  echoinfo "Deleting forwarding rules:" true
  echo "${@}"

  if [[ ${DRY_RUN} = 1 ]]; then
    echo "[DRY RUN] gcloud compute forwarding-rules delete -q" "${@}" "--region ${GCP_REGION}"
  else
    gcloud compute forwarding-rules delete -q "${@}" --region "${GCP_REGION}"
  fi
}

function delete_target_pools() {
  if [[ ${#@} -eq 0 ]]; then
    echoinfo "No target pools to be deleted" true
    return
  fi

  echoinfo "Deleting target pools:" true
  echo "${@}"

  if [[ ${DRY_RUN} = 1 ]]; then
    echo "[DRY RUN] gcloud compute target-pools delete -q" "${@}" "--region ${GCP_REGION}"
  else
    gcloud compute target-pools delete -q "${@}" --region "${GCP_REGION}"
  fi
}

function delete_http_health_checks() {
  if [[ ${#@} -eq 0 ]]; then
    echoinfo "No http health checks to be deleted" true
    return
  fi

  echoinfo "Deleting http health checks:" true
  echo "${@}"

  if [[ ${DRY_RUN} = 1 ]]; then
    echo "[DRY RUN] gcloud compute http-health-checks delete -q" "${@}"
  else
    gcloud compute http-health-checks delete -q "${@}"
  fi
}

function get_related_firewall_rules() {
  local forwarding_rule=${1}

  gcloud compute firewall-rules list --filter "name~${forwarding_rule}" --format "value(name)"
}

function get_service_name_in_forwarding_rule() {
  local forwarding_rule=${1}

  gcloud compute forwarding-rules describe "${forwarding_rule}" --region "${GCP_REGION}" --format "value(description)" | jq -r '.["kubernetes.io/service-name"]'
}

function forwarding_rule_k8s_service_exists() {
  local namespace="${KUBE_NAMESPACE}"
  local namespaced_service_name=$(get_service_name_in_forwarding_rule "$forwarding_rule")

  if [[ ! $namespaced_service_name =~ ^"${namespace}" ]]; then
    return 0 # this prevents `review-apps-ee` pipeline from deleting `review-apps-ce` resources and vice versa
  fi

  local service_name=$(echo "${namespaced_service_name}" | sed -e "s/${namespace}\///g")

  kubectl get svc "${service_name}" -n "${namespace}" >/dev/null 2>&1
  local status=$?

  return $status
}

function gcp_cleanup() {
  local target_pools_to_delete=()
  local firewall_rules_to_delete=()
  local forwarding_rules_to_delete=()
  local http_health_checks_to_delete=()

  for forwarding_rule in $(gcloud compute forwarding-rules list --filter="region:(${GCP_REGION})" --format "value(name)"); do
    echoinfo "Inspecting forwarding rule ${forwarding_rule}" true

    if forwarding_rule_k8s_service_exists "${forwarding_rule}"; then
      echoinfo "Skip clean up for ${forwarding_rule}"
    else
      echoinfo "Queuing forwarding rule, firewall rule, target pool and health check for ${forwarding_rule} to be cleaned up"

      firewall_rules_to_delete+=($(get_related_firewall_rules "${forwarding_rule}"))
      forwarding_rules_to_delete+=(${forwarding_rule})
      target_pools_to_delete+=(${forwarding_rule})
      http_health_checks_to_delete+=(${forwarding_rule})
    fi
  done

  delete_firewall_rules "${firewall_rules_to_delete[@]}"
  delete_forwarding_rules "${forwarding_rules_to_delete[@]}"
  delete_target_pools "${target_pools_to_delete[@]}"
  delete_http_health_checks "${http_health_checks_to_delete[@]}"
}
