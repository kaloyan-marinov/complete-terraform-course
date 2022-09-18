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
- benefit #2: if you are provisioning multiple environments (such as "staging" and "production"), use the power of programming languages to have multiple copies of the same thing and be confindent that they are deployed identically
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

    - in addition, if your Terraform files utilize any "Terraform modules" (which will be covered in detail later on in this tutorial), downloads those as well into our working directory

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

      (the entire 2-sub-step process, which makes it possible _also_ for the remote-backend resources to themselves be managed by Terraform, is demonstrated in [./03-basics--basic-terraform-usage/step-1-aws-backend/main.tf](./03-basics--basic-terraform-usage/step-1-aws-backend/main.tf)!)

    - (sub-step 1) 

      follow the corresponding instructions in the file linked above

      (doing that will result both in provisioning the file's specified resources within our AWS account, and in recording those into "the state file")

    - (sub-step 2)

      specify the following within your `main.tf` file: `aws_s3_bucket.terraform_state.bucket` and `aws_dynamodb_table.terraform_locks.name`
        
      follow the corresponding instructions in the file linked above

# Variables and outputs

[part 04 of tutorial]

1. variable types

    ```
    # [This should be viewed as an excerpt from a `*.tf` file.]

    # A variable of the following type is accessed via
    # `var.<name>`
    variable "intance_type" {
    description = "ec2 instance type"
    type        = string
    default     = "t2.micro"
    }

    # A variable of the following type is accessed via
    # `local.<name>`
    # (Note the singular vs the plural forms!)
    locals {
    service_name = "My Service"
    owner        = "XYZ Corporation"
    }

    # A variable of the following type is accessed via
    # [tbd]
    output "instance_ip_addr" {
    value = aws_instance.instance.public_ip
    }

    ```

2. the order of precedence for setting input variables - from highest to lowest precedence:

    - command line `-var` or `-var-file`

    - `*.auto.tfvars` file

    - `terraform.tfvars` file

      (
      this can be useful
      if you want to have a different set of values
      for different "deployment environments/'targets'"
      [such as "staging", "production", etc.]
      )

    - `TF_VAR_<name>` environment variables

      (
      this is sometimes useful in CI environments or other environments,
      where you would want to change the value based on different attributes
      )

    - default value in declaration block

    - manual entry during `plan`/`apply`

      (
      if you don't specify a variable anywhere and there's no default value,
      running the `terraform plan` command will cause the Terraform CLI to prompt you
      to put a value in;
      you generally don't want to be doing it that way,
      because it makes it very easy to make a typo or have a mistake
      such that the variables change [across] different runs
      )

3. types & validation & sensitive data

    types:

    - primitive types: `string`, `number`, `bool`
    - complex type 1: `list(<TYPE>)`
    - complex type 2: `set(<TYPE>)`
    - complex type 3: `map(<TYPE>)`
    - complex type 4: `object({<ATTR NAME> = <TYPE>, ...})`
    - complex type 5: `tuple([<TYPE>, ...])`

    validation:

    - type-checking takes placed automatically
    - you can also write your own validation rules, and have them be enforced

    sensitive data:

    - set the attribute `Sensitive = true` when you are defining a variable,
      which is responsible for holding sensitive data

    - pass to `terraform apply` with `TF_VAR_<name>`, or `-var` (retrieved from
      secret manager at runtime; in other words, using the `-var` option allows you
      to retrieve the value from the AWS Secrets Manager or the HashiCorp Vault,
      upon issuing your command)
    
    - reference an external secrets store (such as the AWS Secret Manager)
      within your Terraform configuration,
      and then use Terraform's "output variable" type
      to pull those into other portions of your config

    (
    when you have sensitive data stored within an object within Terraform,
    you'll see, when it outputs the `plan` to the command line,
    it will mask those [sensitive data]
    )

    examine the files withn the `step-1-examples/` sub-directory in the following order:
    - `main.tf`
    - `variables.tf`
    - `terraform.tfvars` is where I can defined the values for these variables
      if they're non-sensitive
    - `terraform-not-used-by-default.tfvars` is similar to the previous one,
      but needs to be specified via `terraform apply -var-file=...`
    - `outputs.tf` adds a couple of outputs to this [process],
      as samples of what you might include
      (= you might want to consume those in _either_ another Terraform configuration,
      _or_ some other piece of our automation)

    examine the files within the `step-2-web-app/` sub-directory in the following order:
    - `variables.tf`
    - `outputs.tf`
    - `main.tf` (at this moment, we can draw the following important conclusion:
      by using variables in this way, I'll actually be able to, down the line,
      deploy distinct "staging" and "production" environments
      simply by configuring different variable values)

# Additional language features

[part 05 of tutorial]

1. expressions

    - template string

    - arithmetic operators, equality operators, ...

    - conditionals

    - `for` loop

    - etc.

      The most reliable approach to getting to grips with advanced language features
      is to consult the Terraform documentation when you need to do something specific.

2. functions

    - "math on numbers"

    - date & time functionality

    - hash & cryptographic functions

      (which, for instance, allow you to generate a password on the fly)

3. meta-arguments

    - there's a number of these

    - example of a meta-argument: `depends_on`

      normally, if there's things that need to happen in a certain sequence...
      if you're, like, provisioning a server
      and then you need the IP address from that to pass to a firewall rule
      (or what have you),
      just by passing those data
      and saying `ec2_example.output`
      and putting that into the configuration for the other resource,
      Terraform - when you run the `apply` or `plan` command -
      will figure out the sequence of events and the dependency graph there

      there are cases, though,
      where one resource implicitly depends on another,
      but there's no direct connection within the config

      an example here, shown on the right, is that
      here, if my instance needs to be able to access an S3 bucket,
      I need to have a role policy that can make that happen,
      but there's no direct connection within my config,
      and so I can tell Terraform with this `depends_on` key,
      "Oh, you should make sure to provision this [IAM] role policy
      before you provision the instance; otherwise it's gonna fail"

      [cf the tutorial for the "example"]

      so this allows me to give some hints
      to the parsing and the dependency-graph generation
      to ensure [that] ordering matches what it needs to be
  
    - example of a meta-argument: `count`

      allows me to specify[,]
      if I need multiple of the same configuration/[resource?] provisioned[,]
      ....
      I can use this `count` meta-argument, and it will provision multiple copies

      usually,
      this will be used with, let's say, a module
      [which will be discussed in a later part of this tutorial],
      where I have a single block and I want to make multiple copies of it

      for example,
      the following configuration will provision 4 copies of this instances:
      ```
      resource "aws_instance" "server" {
        # The following statement causes 4 EC2 instances to be created.
        count = 4

        ami           = "ami-a1b2c3d4"
        instance_type = "t2.micro"

        tags {
          Name = "Server ${count.index}"
        }
      }
      ```

      it's very [convenient] to use this
      if you have multiple necessary resources that are nearly identical

    - example of a meta-argument: `for_each`

      this is kind of like the `count` meta-argument
      but it gives us much more control over each resource

      here, we're taking an iterable of some kind,
      and we're using those to create the multiple resources

      for example:
      ```
      locals {
        subnet_ids = toset([
          "subnet-abcdef",
          "subnet-012345",
        ])
      }

      resource "aws_instance" "server" {
        for_each = local.subnet_ids

        ami           = "ami-a1b2c3d4"
        instance_type = "t2.micro"
        subnet_id     = each.key

        tags = {
          Name = "server ${each.key}"
        }
      }
      ```

      it allows us to very easily define copies of things
      while still maintaining the necessary control to individualize them as needed 

    - example of a meta-argument: `lifecycle`

      there are certain things,
      where we need Terraform to take actions in a specific order

      we can use the `create_before_destroy` [sub-meta-]argument to say,
      "If we're replacing this server,
      we want you to provision the new one _before_ you delete the old one";
      [this] can help with zero downtime deployments

      there are also some time,
      where - behind the scenes, _after_ you have provisioned a resource -
      AWS (or whatever service you're using) will add some metadata to that resource;
      those can be very annoying from a Terraform state perspective,
      because it looks as though
      you have a change between your state and the deployed infrastructure,
      and so you can tell Terraform,
      "Oh, yes, that tag exists - we don't need to worry about it"

      ```
      resource "aws_instance" "server" {
        ami           = "ami-a1b2c3d4"
        instance_type = "t2.micro"

        lifecycle {
          create_before_destroy = true

          # Some resources have metadata
          # modified automatically
          # outside of Terraform.
          ignore_changes = [
            tags
          ]
        }
      }
      ```

      the other meta-argument `lifecycle` tag [/ sub-meta-argument]
      that I'll call out here is
      the `prevent_destroy` tag;
      this is kind of a safeguard -
      if you have some piece of your infrastructure that is critical to not delete,
      you can add this tag,
      and then anytime
      if ... the `terraform plan` or `terraform apply` would have deleted that resource,
      this would throw an error;
      and so this can help you
      really lock down some specific core pieces of the infrastructure
      that you don't want to be deleted

4. provisioners

    - another important concept within Terraform is the concept of a "provisioner"

    - a provisioner allows you to perform some action
      either locally, or on a remote machine
    
    - example 1: pattern/[combination] of
      Terraform as a provisioning tool
      and Ansible as a configuration-management tool;
      once ... you have your server up,
      you can use "the Ansible provisioner" to then go off
      and install
      and modify those servers,
      etc.

    - exmaple 2 (a more simple example [than example 1]):
      you could have, let's say, a start-up script
      that we want to execute after we have provisioned our servers;
      and so that could be "a file provisioner" with a Bash script stored there
      that the Terraform configuration could reference

# Organization and modules

[part 06 of tutorial]

1. what is a module?

    - a _module_ is a container for multiple resources
      (defined within our Terraform configuration) that are used together

    - a module consists of
      a collection of `.tf` and/or `.tf.json` files kept together in a directory

    - modules are
      the main way to package and re-use resource configuration with Terraform
      (re-use them across projects;
      re-use them across environments;

      or share them with third parties)

2. types of modules

    - root module: default module containing all `.tf` files in the main working directory

    - child module: a separate ... module referred to from a `.tf` file (e.g. from our root module)

    - these modules can come from a variety of sources:
      if they're all in the same filesystem, we can have local paths
      (e.g. I can have a `directory-a` and a `directory-b`,
      and I can reference one from the other);
      these also can live in "the Terraform Registry";
      etc.

3. inputs + meta-arguments

    - in previous parts of this tutorial, we looked at input variables
      and how they can be used when we're issuing our commands;
      those were for the root module;
      but each child module can also be passed inputs in a similar fashion;
      so we can specify
      whatever the developer of the module has exposed as an input variable

    - we can also then use the meta-arguments that we talked about before

4. what makes a good module?

    - raises the level of abstraction, as compared to the base resource types

    - groups resources in a logical fashion/grouping

    - allows necessary customization
      and enables composition
      by exposing input variables
    
    - provides useful defaults

    - returns outputs
      to make further integrations possible

5. `06-organization-and-modules/`

    `06-organization-and-modules/step-2-1-web-app-module/`

    - you'll ... see [that]
      we don't have a `terraform.tfvars` file here;
      we'll define the `terraform.tfvars` file where we actually consume this module

    - `main.tf`

      all it contains is a "base block",
      in which we specify that we do need that AWS provider

    - `variables.tf`

      I've kept our `variables.tf` file,
      and added a few here that we can take a look at -
      including the `environment_name`;
      this is going to allow us to
      split on `dev` vs. `staging` vs. `production`
      (and avoid some naming conflicts, because I'm deploying into a single AWS account)

    - `outputs.tf`

    ---

    - `compute.tf`

    - `database.tf`
    
    - `storage.tf`

    ---

    - `networking.tf`

    ---

    - `dns.tf`