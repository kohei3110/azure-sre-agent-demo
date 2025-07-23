# Azure SRE Agent Demo - Infrastructure

This directory contains the Terraform infrastructure as code (IaC) for the Azure SRE Agent Demo ToDo application.

## Architecture Overview

The infrastructure is designed with cost optimization and zero-scale capabilities in mind:

- **Azure Static Web Apps** (Standard): Frontend hosting with Linked Backend integration
- **Azure Container Apps**: Backend API with zero-scale support (0.25 vCPU, 0.5GB memory)
- **Azure Cosmos DB** (Serverless): Document database for ToDo items
- **Azure Container Registry** (Basic): Container image storage
- **Application Insights**: Application monitoring and logging
- **Azure Load Testing**: Performance and load testing capabilities

## Directory Structure

```
infra/
├── main.tf                    # Main infrastructure resources
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output values
├── providers.tf               # Provider configurations
├── environments/
│   └── demo.tfvars           # Demo environment variables
└── modules/
    ├── static-web-app/       # Static Web Apps module
    ├── container-apps/       # Container Apps module
    ├── cosmos-db/           # Cosmos DB module
    ├── monitoring/          # Application Insights & Log Analytics module
    └── load-testing/        # Load Testing module
```

## Prerequisites

1. **Azure CLI**: Ensure you're logged in to Azure
   ```bash
   az login
   az account set --subscription <your-subscription-id>
   ```

2. **Terraform**: Install Terraform (>= 1.0)
   ```bash
   # On macOS with Homebrew
   brew install terraform
   
   # On Windows with winget
   winget install HashiCorp.Terraform
   ```

## Deployment Steps

### 1. Initialize Terraform

```bash
cd infra
terraform init
```

### 2. Validate Configuration

```bash
terraform validate
```

### 3. Plan Deployment

```bash
terraform plan -var-file="environments/demo.tfvars"
```

### 4. Apply Infrastructure

```bash
terraform apply -var-file="environments/demo.tfvars" -auto-approve
```

## Environment Configuration

### Demo Environment

The demo environment is configured for development and testing purposes:

- **Zero-scale capabilities**: Container Apps can scale down to 0 instances
- **Cost optimization**: Serverless Cosmos DB and minimal resource allocations
- **Basic monitoring**: 90-day log retention with Application Insights

Configuration file: `environments/demo.tfvars`

## Key Features

### Static Web Apps + Container Apps Integration

The infrastructure uses Azure Static Web Apps Standard tier with Linked Backend functionality:

- `/api/*` routes are automatically proxied to Container Apps
- Unified authentication and session management
- SSL termination handled by Static Web Apps
- Cost-effective architecture simplification

### Zero-Scale Container Apps

Container Apps are configured for maximum cost efficiency:

- Minimum replicas: 0 (scales to zero when idle)
- Maximum replicas: 10 (handles traffic spikes)
- Resource allocation: 0.25 vCPU, 0.5GB memory
- HTTP-based scaling triggers

### Serverless Cosmos DB

Optimized for variable workloads:

- Serverless capacity mode (pay-per-use)
- Automatic scaling based on demand
- Session consistency level for optimal performance
- Periodic backups with 7-day retention

## Resource Naming Convention

Resources are named using the following pattern:
```
<resource-type>-<project-name>-<environment>-<random-suffix>
```

Examples:
- `stapp-todo-app-demo-abc123` (Static Web App)
- `ca-todo-app-backend-demo-abc123` (Container App)
- `cosmos-todo-app-demo-abc123` (Cosmos DB)

## Security Features

### Managed Identity

- User-assigned managed identity for Container Apps
- ACR Pull permissions for container image access
- No hardcoded credentials or connection strings

### Network Security

- HTTPS enforcement on all endpoints
- Internal communication between Static Web Apps and Container Apps
- Container Registry access through managed identity

### Secret Management

- Connection strings managed through environment variables
- Application Insights connection string secure handling
- API keys marked as sensitive outputs

## Cost Optimization

### Monthly Cost Estimation

Based on minimal usage patterns:

- Static Web Apps: ~$9/month (Standard plan)
- Container Apps: $0-50/month (zero-scale when idle)
- Cosmos DB: $0-25/month (serverless, usage-based)
- Application Insights: $0-10/month
- Container Registry: ~$5/month (Basic tier)
- Load Testing: $0-20/month (pay-per-test)

**Total estimated cost**: $14-119/month (varies with usage)

### Cost Controls

- Zero-scale Container Apps reduce compute costs during idle periods
- Serverless Cosmos DB charges only for actual usage
- Basic Container Registry tier for minimal image storage costs
- Log Analytics with 90-day retention to control storage costs

## Outputs

After successful deployment, the following outputs are available:

- `static_web_app_url`: The URL of the deployed frontend
- `container_apps_url`: The URL of the backend API
- `cosmos_db_endpoint`: The Cosmos DB endpoint
- `application_insights_connection_string`: For application monitoring

## Monitoring and Observability

### Application Insights

Configured for comprehensive application monitoring:

- Custom metrics and events
- Performance monitoring
- Error tracking and debugging
- Integration with Container Apps logs

### Log Analytics

Centralized logging with:

- 90-day retention period
- Container Apps environment logs
- Application Insights data integration
- Custom queries and alerts support

## Load Testing Integration

Azure Load Testing is configured for:

- Performance validation
- Capacity planning
- Zero-scale behavior verification
- CI/CD pipeline integration

## Troubleshooting

### Common Issues

1. **Resource naming conflicts**: Resources names must be globally unique
2. **Quota limitations**: Ensure sufficient quota in target region
3. **Permission issues**: Verify Azure RBAC permissions for deployment

### Validation Commands

```bash
# Check resource status
az resource list --resource-group <resource-group-name> --output table

# Verify Container Apps
az containerapp list --resource-group <resource-group-name> --output table

# Check Static Web Apps
az staticwebapp list --resource-group <resource-group-name> --output table
```

## Cleanup

To destroy all resources:

```bash
terraform destroy -var-file="environments/demo.tfvars" -auto-approve
```

## Integration with CI/CD

This infrastructure is designed to integrate with GitHub Actions workflows:

- Terraform state management
- Automated deployment pipelines
- Environment-specific configurations
- Secure secret management

See the CI/CD pipeline specification for workflow integration details.
