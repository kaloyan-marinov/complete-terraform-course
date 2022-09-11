# Introduction

[part 1 of tutorial]

_Infrastructure_ is now provisioned via APIs.

Long-lived + mutable
>>
Short-lived + immutable

3 main approaches for provisioning cloud resources/infrastructure:
- GUI (e.g. the AWS Management Console)
- via an API or a CLI (e.g. the AWS CLI)
- Infrastructure as Code (IaC)

IaC:
- focus of this course
- _declare_/define your infrastructure within your codebase
- benefit #1: you know exactly what is provisioned at any given time
- benefit #2: if you are provisioning multiple environments (such as `staging` and `production`), use the power of programming languages to have multiple copies of the same thing and be confindent that they are deployed identically

Categories of IaC tools:
1. Ad-hoc scripts
2. Configuration management tools
3. Server templating tools
4. Orchestration tools
    - for _declaring_/defining your application['s] deployment (rather than _declaring_/defining the servers behind it)
    - the most popular one these days is Kubernetes
5. Provisioning tools
    - focus of this course

Categories of IaC provisioning tools:
1. Specific to a cloud provider
    - AWS's Cloud Formation
    - Azure's Resource Manager
    - Google's Cloud Deployment Manager
2. Provider-agnostic
    - `Terraform` (focus of this course)
    - Pulumi

# HashiCorp Terraform

`Terraform` is a tool for building, changing, and versioning infrastructure safely and efficiently.

`Terraform` is an infrastructure-as-code tool, which means that it allows you to

- _declare_ your entire cloud infrastructure as a set of configuration files (written in the "HashiCorp Configuration Language" [HCL]),

- which then the tool `Terraform` provision and manage on our behalf (by interacting with your cloud provider's API)

`Terraform` can interact with pretty much every cloud provider, which you may decide to rely on for the purpose of deploying your web application.
