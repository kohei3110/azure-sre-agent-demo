# Terraform Variables Template for GitHub Actions
# This template is used by GitHub Actions to generate environment-specific .tfvars files

# Environment configuration
environment_name = "${ENVIRONMENT}"
location         = "${LOCATION}"
project_name     = "${PROJECT_NAME}"

# Resource naming (leave empty to use auto-generated names)
resource_group_name          = "${RESOURCE_GROUP_NAME}"
static_web_app_name         = "${STATIC_WEB_APP_NAME}"
container_app_name          = "${CONTAINER_APP_NAME}"
cosmos_db_account_name      = "${COSMOS_DB_ACCOUNT_NAME}"
container_registry_name     = "${CONTAINER_REGISTRY_NAME}"
application_insights_name   = "${APPLICATION_INSIGHTS_NAME}"
log_analytics_workspace_name = "${LOG_ANALYTICS_WORKSPACE_NAME}"
load_testing_name           = "${LOAD_TESTING_NAME}"

# Static Web Apps configuration
static_web_app_sku = "${STATIC_WEB_APP_SKU}"

# Container Apps configuration
container_app_cpu         = ${CONTAINER_APP_CPU}
container_app_memory      = "${CONTAINER_APP_MEMORY}"
container_app_min_replicas = ${CONTAINER_APP_MIN_REPLICAS}
container_app_max_replicas = ${CONTAINER_APP_MAX_REPLICAS}

# Container image (updated by CI/CD pipeline)
container_image = "${CONTAINER_IMAGE}"

# Cosmos DB configuration
cosmos_db_database_name  = "${COSMOS_DB_DATABASE_NAME}"
cosmos_db_container_name = "${COSMOS_DB_CONTAINER_NAME}"

# Container Registry configuration
container_registry_sku = "${CONTAINER_REGISTRY_SKU}"

# Log Analytics configuration
log_analytics_sku = "${LOG_ANALYTICS_SKU}"

# Common tags
tags = {
  Environment = "${ENVIRONMENT}"
  Project     = "${PROJECT_NAME}"
  Purpose     = "${PURPOSE}"
  CostCenter  = "${COST_CENTER}"
  GitHubRepo  = "${GITHUB_REPO}"
  GitHubRun   = "${GITHUB_RUN}"
  GitHubActor = "${GITHUB_ACTOR}"
  DeployedBy  = "${DEPLOYED_BY}"
  DeployedAt  = "${DEPLOYED_AT}"
  Commit      = "${COMMIT}"
  Branch      = "${BRANCH}"
}
