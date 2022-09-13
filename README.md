TLDR: configuration, specification, definition, declaration

TLDR: infrastructure, resources, cloud infrastructure

TLDR: developer, engineer
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

[part 02 of tutorial]

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

# Basic Terraform usage

[part 03 of tutorial]

0. `tree -a .`

    ```
    $ tree -a .
    .
    └── main.tf

    0 directories, 1 file
    ```

1. `terraform init`

    - initializes your project

    - downloads the code for the providers specified in the `required_providers` block

        ```
        $ tree -a .
        .
        ├── .terraform
        │   └── providers
        │       └── registry.terraform.io
        │           └── hashicorp
        │               └── aws
        │                   └── 3.75.2
        │                       └── darwin_amd64
        │                           └── terraform-provider-aws_v3.75.2_x5
        ├── .terraform.lock.hcl
        └── main.tf
        ```
    
    - the `.terraform.lock.hcl` file contains information about the specific providers and dependencies that are installed within this workspace

    - in addition, if your Terraform files utilize any "Terraform modules" (which will be covered in detail later in this tutorial), downloads those as well into our working directory

        ```
        $ tree -a .
        .
        ├── .terraform
        │   └── modules
        │       └── ...
        │   └── providers
        │       └── registry.terraform.io
        │           └── hashicorp
        │               └── aws
        │                   └── 3.75.2
        │                       └── darwin_amd64
        │                           └── terraform-provider-aws_v3.75.2_x5
        ├── .terraform.lock.hcl
        └── main.tf
        ```

2. `terraform plan`

    - takes your configuration (= "the Terraform configuration"), checks it against "the currently deployed state of the world" (= "the Terraform state") and your "state file", and figures out the sequence of "resource actions" that need to be apply to go from "what is" to "what should be"

3. `terraform apply`

    - applies the "resource actions" (so that you end up with the infrastructure you want)

    - another important concept about Terraform is "the state file" (which gets created or updated after each invocation of `terraform apply`)
    
    - "the state file" is a JSON file, which constitutes Terraform's representation of the world; contains information about every "resource" and "data object" (:= things that were not provisiioned by Terraform, but are referred to in order to influence how infrastructure will ultimately/actually be provisioned) that we have depoyed using Terraform; contains sensitive information, so it needs to be protected accordingly (by making sure that it is encrypted, and that only the correct set of individuals have access to it); can be stored locally or remotely (in an object store, such as an S3 bucket or Google Cloud Storage; or in Terraform's own managed offering called Terraform Cloud, which will host our state files for us, manage things like permissions, etc.)

    - if "the state file" is stored locally, the developer is said to be using a "local backend"; the advantage of this approach is that it is simple to get started; the disadvantages of this approach are that (a) sensitive information is present within "the state file" in plain text (which provides a potential attack target), (b) it is uncollaborative (i.e. it makes it challenging to work with other engineers on your infrastructure configuration), and (c) it is manual in nature

    - if "the state file" is stored "in a remote server somewhere", the developer is said to be using a "remote backend"; the advantages of this approach are that (a) sensitive information is encrypted (and no longer on our local system), (b) it makes collaboration possible (i.e. it makes it possible for multiple engineers to interact with the same remote backend), and (c) it makes automation possible (e.g. it makes it possible to run things like GitHub Actions or other automation pipelines); the disadvantage of this approach is that it is more complex to set up

    - later on in this section, we will explain/demonstrate how to set up a remote backend for storing "the state file" (= store "the state file" in a remote storage)

4. `terraform destroy`

    - tear down the provisioned resources

5. Set up a remote backend - option 1: via Terraform Cloud

    - this is a managed offering from HashiCorp itself

    - within the web UI of Terraform Cloud, create an organization (e.g. `xyz-corporation`) and a workspace name (e.g. `pilot-project`)

    - specify the following within your `main.tf` file:
    
        ```
        terraform {
          backend "remote" {
            organization = "xyz-corporation"

            workspaces {
            name = "pilot-project"
            }
          }
        }
        ```
    
    - advantages: free for up to 5 users within an organization

    - disadvantages: beyond the free tier, it starts to cost 20 US per user per month (while Terraform itself is free to use, it is through this managed offering that HashiCorp makes money from its Terraform product)

5. Set up a remote backend - option 2: via a self-managed backend

    - here we will describe how to implement this option by means of AWS (in short, we can refer to this as the "AWS flavor" of the current option)

    - the "AWS flavor" consists of specifying an S3 bucket and a DynamoDB table within your `main.tf` file, where the former AWS resource is where "the state file" will actually live, whereas the latter AWS resource serves to prevent multiple engineers from trying to apply [= `terraform apply`] different changesets at the same time

    - it is worth saying a few extra words about how the DynamoDB table achieves its purpose; the crux of the matter is that a DynamoDB offers[/has] "atomic guarantees"; it is thanks to those "atomic guarantees" that, if engineer A issues a [`terraform apply`] command, that locks the Terraform configuration so that, if engineer B issues a [`terraform apply`] command from their own machine, engineer B's command will be rejected until engineer A's command is finished

    - at this point, one may wonder, 
    
        > "Suppose I want to provision _everything_ by means of IaC; if I want to use a remote backend, an S3 bucket and a DynamoDB table need to have been created/provisioned _beforehand_ in order for me to be able to specify those within my `main.tf` file. Does that seem to suggest that the provisioning process needs to be broken down into 2 separate sub-steps?"

      indeed, the provisioning process would need to be broken down into 2 distinct sub-steps; fortunately, the 2nd sub-step can be configured not only to use the resources provisioned in the 1st sub-step, but also to keep track of those resources!

      (the entire 2-sub-step process, which makes it possible _also_ for the remote-backend resources to themselves be managed by Terraform, will be demonstrated in the following bulletpoints!)

    - (sub-step 1) 
        ```
        terraform {
          # Skip configuring a remote backend,
          # which will cause Terraform to default to a local backend.

          required_providers {
            aws = {
            source  = "hashicorp/aws"
            version = "~> 3.0"
            }
          }
        }

        provider "aws" {
          region = "us-east-1"
        }

        resource "aws_s3_bucket" "terraform_state" {
          bucket        = "s3-bucket-terraform-state-for-my-web-app"
          force_destroy = true
          versioning {
            enabled = true
          }

          server_side_encryption_configuration {
            rule {
              apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
              }
            }
          }
        }

        resource "aws_dynamodb_table" "terraform_locks" {
          name         = "dynamodb-table-terraform-state-locking"
          billing_mode = "PAY_PER_REQUEST"
          # The following is a key attribute,
          # whose value needs to match exactly in order for this to work.
          hash_key     = "LockID"
          attribute {
            name = "LockID"
            type = "S"
          }
        }
        ```

        ```
        terraform apply
        ```
        (which causes both to provision the those 2 resources within our AWS account, and to record them into "the state file")

    - (sub-step 2) specify the following within your `main.tf` file:
        ```
        terraform {
          backend "s3" {
            bucket         = "s3-bucket-terraform-state-for-my-web-app"
            key            = "tf-infra/terraform.tfstate"
            region         = "us-east-1"
            dynamodb_table = "terraform-state-locking"
            encrypt        = true
          }
        }
        ```