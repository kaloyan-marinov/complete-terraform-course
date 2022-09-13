# Introduction

[part 01 of tutorial]

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
- 15:30 - ...

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

[part 02 of tutorial]

`Terraform` is a tool for building, changing, and versioning infrastructure safely and efficiently.

`Terraform` is an infrastructure-as-code tool, which means that it allows you to

- _declare_ your entire cloud infrastructure as a set of configuration files (written in the "HashiCorp Configuration Language" [HCL]),

- which then the tool `Terraform` provision and manage on our behalf (by interacting with your cloud provider's API)

`Terraform` can interact with pretty much every cloud provider, which you may decide to rely on for the purpose of deploying your web application.

# Overview of `Terraform` itself

[part 2 of tutorial]

- overview of `Terraform` itself
- how to get set up and authorized with AWS (the process of authorizing `Terraform` to work with each individual cloud provider is ... [described in its official documentation, which available on the Internet])

Terraform Architecture:
- `Terraform Core` takes the following as inputs: Terraform Config Files + Terraform State
- goes on to utilize so-called one or several `Terraform Providers` in order to figure out how to interact with our cloud provider's API to make that state match the config

`Terraform Providers` need to be installed alongside `Terraform Core`.

---

TODO:

1. install `Terraform`

    - https://learn.hashicorp.com/tutorials/terraform/install-cli

    - First, install the HashiCorp tap, a repository of all our Homebrew packages.
        ```
        brew tap hashicorp/tap
        ```

    - Now, install Terraform ...

        [
        NOTE: This installs a signed binary and is automatically updated with every new official release.
        ]

        ```
        brew install hashicorp/tap/terraform
        ```

    - To update to the latest version of Terraform, first update Homebrew.

        ```
        brew update
        ```

    - Then, run the `upgrade` command to download and use the latest Terraform version.

        ```
        brew upgrade hashicorp/tap/terraform
        ```

2. authenticate to AWS

    - create an IAM User group, and attach to it those permissions policies that will be needed for provisioning your desired infrastructure

    - create an IAM User; "Select AWS credential type" as "Access key - Programmatic access"; "Add [the] user [that is about to be created] to [the just-created] group"

    - install the AWS CLI

    - launch a terminal instance, issue `aws configure`, and provide the (relevant pieces of information from) `new_user_credentials.csv`, which you were offered to (and had to!) download in the next-to-last sub-step

3. "Hello world!" tf config

4. init, plan, apply, destroy

    - `cd 02-overview--demo`

    - `terraform init` will initialize a "Terraform backend" (in this part of the tutorial, this backend and state will be stored locally, because we will not specify anything else when issuing this command)

    - `terraform plan` will determine what resources are already deployed (by querying the AWS API); how those resources compare to what is _declared_/specified in `main.tf`; and what "resource actions" need to be "applied" in order to provision the _declared_/specified resources

    - `terraform apply` take the "resource actions", which were determined in "the plan"

    - `terraform destroy` will tear down the provisioned resources (to avoid leaving them running, which we would have to pay for)