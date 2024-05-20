<ins>NB 1:</ins> the following terms are used interchangeably:
  - configuration
  - specification
  - definition
  - declaration

<ins>NB 2:</ins> the following terms are used interchangeably:
  - infrastructure
  - resources
  - cloud infrastructure

<ins>NB 3:</ins> the following terms are used interchangeably:
  - developer
  - engineer

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

- which then the tool `Terraform` provisions and manages on our behalf (by interacting with your cloud provider's API)

`Terraform` can interact with pretty much every cloud provider, which you may decide to rely on for the purpose of deploying your web application.

# Overview of `Terraform` itself

[part 02 of tutorial]

- overview of `Terraform` itself
- how to get set up and authorized with AWS
  (the process of authorizing `Terraform`
  to work with each individual cloud provider is ...
  [described in its official documentation, which is available on the Internet])

Terraform Architecture:
- `Terraform Core` takes the following as inputs:
  Terraform Configuration Files + Terraform State File
- goes on to utilize so-called one or several `Terraform Provider`s
  in order to figure out how to interact with our cloud providers' API
  to make the state match the configuration

`Terraform Provider`s need to be installed alongside `Terraform Core`.

---

TODO:

1. install `Terraform`

    - https://learn.hashicorp.com/tutorials/terraform/install-cli

    - First, install the HashiCorp tap, a repository of all Hashicorp packages.
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

2. authenticate with AWS

    - create an IAM User group, and attach to it those permissions policies that will be needed for provisioning your desired infrastructure

    - create an IAM User; "Select AWS credential type" as "Access key - Programmatic access"; "Add [the] user [that is about to be created] to [the just-created] group"

    - install the AWS CLI

    - launch a terminal instance, issue `aws configure`, and provide the (relevant pieces of information from) `new_user_credentials.csv`, which you were offered to (and had to!) download in the next-to-last sub-step

3. "Hello world!" tf config

4. init, plan, apply, destroy

    - `cd 02-overview--demo`

    - `terraform init` will initialize a "Terraform backend"
      (in this part of the tutorial,
      the backend and state will be stored locally,
      because we did not specify anything else as part of issuing the command)

    - `terraform plan` will determine
      what resources are already deployed
      (by querying the AWS API);
      how those resources compare to what is _declared_/specified in `main.tf`;
      and what "resource actions" need to be "applied"
      in order to provision the _declared_/specified resources

    - `terraform apply` take the "resource actions",
      which were determined in "the plan"

    - `terraform destroy` will tear down the provisioned resources
      (to avoid leaving them running, which we would have to pay for)

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
    
    - the `.terraform.lock.hcl` file contains
      information about the specific providers and dependencies
      that are installed within this workspace

    - in addition,
      if your Terraform files utilize any "Terraform modules"
      (which will be covered ... later on in this tutorial),
      downloads those as well into our working directory

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

    - takes your configuration (= "the Terraform configuration"),
      checks it against "the currently deployed state of the world"
      (= "the Terraform state (file)"),
      and figures out the sequence of "resource actions" that need to be applied
      in order to go from "what is" to "what should be"

3. `terraform apply`

    - applies the "resource actions"
      (so that you end up with the infrastructure you want)

    - another important concept about Terraform is "the state file"
      (which gets created or updated after each invocation of `terraform apply`)
    
    - "the state file"
      is a JSON file, which constitutes Terraform's representation of the world;
      contains information about every "resource" and "data object" (:= things that
      were not provisioned by Terraform,
      but are referred to
      in order to influence how infrastructure will actually be provisioned)
      that we have depoyed using Terraform;
      contains sensitive information, so it needs to be protected accordingly
      (by making sure that it is encrypted,
      and that only the correct set of individuals have access to it);
      can be stored locally or remotely
      (in an object store,
        such as an S3 bucket or Google Cloud Storage;
      or in Terraform's own managed offering called Terraform Cloud,
        which will host our state files for us, manage things like permissions, etc.)

    - if "the state file" is stored locally,
      the developer is said to be using a "local backend";
      the advantage of this approach is that it is simple to get started;
      the disadvantages of this approach are that
      (a) sensitive information is present within "the state file" in plain text
          (which provides a potential attack target),
      (b) it is uncollaborative
          (i.e. it makes it challenging
          to work with other engineers on your infrastructure configuration), and
      (c) it is manual in nature;

    - if "the state file" is stored "in a remote server somewhere",
      the developer is said to be using a "remote backend";
      the advantages of this approach are that
      (a) sensitive information is encrypted (and no longer on our local system),
      (b) it makes collaboration possible
          (i.e. it makes it possible for multiple engineers
          to interact with the same remote backend), and
      (c) it makes automation possible
          (e.g. it makes it possible
          to run things like GitHub Actions or other automation pipelines);
      the disadvantage of this approach is that it is more complex to set up;

    - later on in this section,
      we will explain/demonstrate
      how to set up a remote backend for storing "the state file"
      (= how to store "the state file" in a remote storage)

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

    - here we will describe how to implement this option by means of AWS
      (in short, we can refer to this as the "AWS flavor" of the current option)

    - the "AWS flavor" consists of
      specifying an S3 bucket and a DynamoDB table within your `main.tf` file,
      where the former AWS resource is where "the state file" will actually live
      and the latter AWS resource serves to prevent multiple engineers
      from trying to apply [= `terraform apply`] different changesets at the same time

    - it is worth saying a few extra words about how the DynamoDB table achieves its purpose;
      the crux of the matter is that a DynamoDB offers[/has] "atomic guarantees";
      it is thanks to those "atomic guarantees" that,
      if engineer A issues a [`terraform apply`] command,
      that locks the Terraform configuration so that,
      if engineer B issues a [`terraform apply`] command from their own machine,
      engineer B's command will be rejected until engineer A's command has finished;

    - at this point, one may wonder, 
    
        > "Suppose I want to provision _everything_ by means of IaC;
        if I want to use a remote backend,
        an S3 bucket and a DynamoDB table need to have been created/provisioned _beforehand_
        in order for me to be able to specify those within my `main.tf` file.
        Does that seem to suggest that
        the provisioning process needs to be broken down into 2 separate sub-steps?"

      indeed,
      the provisioning process would need to be broken down into 2 distinct sub-steps;
      fortunately, the 2nd sub-step can be configured
      not only to use the resources provisioned in the 1st sub-step,
      but also to keep track of those resources!

      (the entire 2-sub-step process,
      which makes it possible _also_ for the remote-backend resources
      to themselves be managed by Terraform,
      is demonstrated in [./03-basics--basic-terraform-usage/step-1-aws-backend/main.tf](./03-basics--basic-terraform-usage/step-1-aws-backend/main.tf) !)

    - (sub-step 1) 

      follow the corresponding instructions in the file linked above

      (doing that will result
      both in provisioning the file's specified resources within our AWS account,
      and in recording those into "the state file")

    - (sub-step 2)

      specify the following within your `main.tf` file:
      `aws_s3_bucket.terraform_state.bucket` and `aws_dynamodb_table.terraform_locks.name`
        
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

# Managing multiple environments

[part 07 of tutorial]

[the] example that we have been building [and re-building in the different parts of this tutorial] consists of different components,
and we've defined those as a Terraform configuration
that we can deploy

but now, in addition to a `production` environment, we want a `staging` environment;
we want to have them be very similar so that we can be confident - as we make changes, we can test them out in `staging` and see how it goes;
we also may want a `development` environment that we're deploying to all the time, rapidly changing, testing things

and so we want to take our single config or module, and deploy it multiple times;
and there's 2 main approaches that people use
when doing this sort of thing:

(a) a concept called "workspaces";
    this is how you can use multiple named sections within a single remote backend;
    we can use the `terraform workspaces` command
    to create and manage these different "environments" or [, more precisely,] workspaces
    that live as different "state files" within our backend;
    and so we could say,
    "switch to the `development` workspace [and] deploy that"
    [and/or]
    "switch to the `staging` workspace [and] deploy that"

(b) break things out as different sub-directories within your filesystem[/repository];
    we can have a `modules` directory (which has ... different modules that we've built);
    and then we can have [- at the same level in the directory hierarchy! -] ... `development`, `staging`, and `production` sub-directories,
    [each of which consumes] those modules in different ways

[those] two approaches have pros and cons that [will be listed below]

1. Terraform workspaces

   pros:

    - easy to get started with

    - within your Terraform files,
      you can reference `terraform.workspace` as an expression
      to, let's say, populate the name of your resource;
      so you can call your database the `staging-database` or the `production-database`

    - minimizes the code duplication
      you have between your different environments

   cons:

    - prone to human error
      
      (if you're interacting with these things manually,
      it can be very easy to forget
      which workspace you happen to have configured;
      and make a change;
      and apply it to the wrong environment)

      (if you've automated a lot of this and it's all happening from within a pipeline,
      that can be less of an issue
      but it's still something to think about)

    - the state files are all stored within [the] same remote backend
    
      (and so permissioning and access to those different environments - you can't really isolate them;
      so, if someone has access to the `development` space,
      [that] someone then also generally has access to the `production` space)

      (within the cloud offering that Hashicorp provides,
      there is some more nuanced configuration there;
      but if you're a self-managed backend, this can be a challenge)
    
    - just by looking at the codebase, you can't tell specifically what's deployed everywhere

2. file structure

   pros:

    - can isolate the backends,
      i.e. can have one backend configuration for `production`,
      another one for `staging`,
      and yet another one for `development`

      - improved security
        (= we can handle the permissions for those backends differently)
      
      - decreased potential for human error
        (= it is less likely for you to think you're operating in one Terraform workspace
        while[/when] you're actually working in another)

    - looking at the codebase, it fully represents the deployed state
      (= I can very clearly look at my directory ... structure,
      and ... see what environments I [can] have deployed
      and how my configuration maps onto those
      = it's much easier to look at the codebase
      and reason about the actual infrastructure [environments that] we [can] have deployed)

   cons:
  
    - `terraform apply` needs to be issued multiple times to provision environments
    
    - more code duplication
      (but can be minimized with modules!)
    
   [?!]depending on how complex our infrastructure is,
   we probably want to start separating things out into
   not just having a single massive Terraform config for all of our infrastructure[?!];
   as your organization starts to grow and your infrastructure becomes more complex,
   you probably want to break things out
   into logical component groups
   rather than having everything bundled into one section

    - isolate things that change frequently from those which don't (e.g. `compute` from `networking`)

    there is also the ability for us to reference state
    from a module or a configuration,
    which is completely separate from our current configuration -
    using `terraform_remote_state`

3. Terragrunt

    - a tool by gruntwork.io

    - meta-tooling that can be applied on top of Terraform

    - helps manage some of the complexity
      that comes with breaking things out into a file structure:
      
      (a) keeping our configurations (= Terraform code) DRY;

      (b) executing commands across multiple TF configs

      (c) working with multiple cloud accounts

4. Terraform workspaces: demo

   ```
   terraform init

   terraform workspace list

   terraform workspace new production
   terraform workspace list
   terraform apply \
      -var="db_pass=1234abcd"

   terraform workspace new staging
   terraform workspace list
   terraform apply \
      -var="db_pass=5678efgh"

   terraform destroy \
      -var="db_pass=not-5678efgh"
   
   terraform workspace select production
   terraform workspace list
   terraform destroy \
      -var="db_pass=not-1234abcd"
   ```

   01:48:39
   = "Now, I just updated those nameservers again.
   If I were using this set-up in a true(r) production environment,
   I would want to automate the setting of those nameservers.
   And there is a provider for Google Domains, so I could
   either continue to host the DNS within Amazon's Route53
   and continue to update these name servers automatically[/manually(?)],
   or I could just use Terraform to set A records directly on my Google Domains account
   (by utilizing the `google_dns_record_set` provider).
   (I didn't want to go through the set-up of an additional provider here,
   but just know that that's how you would handle it
   if you wanted to fully automate setting up that process."

5. file structure: demo
   (of how to use a directory layout without our filesystem
   to organize the different environments)

   the `1-global/` sub-directory is for anything that is shared across the multiple environments

   (if `07-managing-multiple-environments/option-2-file-structure/1-global/main.tf`
   actually provisioned some resources,
   then the first step for deploying this would be going into that sub-directory,
   and then issuing `terraform init` and `terraform apply`)

   ```
   cd 07-managing-multiple-environments/option-2-file-structure/2-production/
   
   terraform init

   terraform apply \
       -var="db_pass=1234abcd"
   ```

   ```
   cd 07-managing-multiple-environments/option-2-file-structure/3-staging/
   
   terraform init

   terraform apply \
       -var="db_pass=5678efgh"
   ```

# Testing Terraform code

[part 08 of tutorial]

1. introduction

   a concept that is fairly new to the infrastructure [or IaC](?) world
   is how we can use testing - like we can use with software development! -
   to ensure that our IaC configurations are high-quality
   and continuing to perform how we want them to

   why is this useful?

   to prevent "code rot"

   but what is "code rot"?
   "code rot", in general, refers to this concept that,
   over time, things change about your software system(s)
   and, if you don't test and use code, it will often time degrade over time

2. "code rot"
   in the (more specific) context of Terraform and infrastructure

   - out-of-band changes

     if I deploy something with Terraform,
     and then my colleague goes in and changes something via the UI,
     that is now a misconfiguration that could be a challenge
  
   - unpinned versions

     if we forgot to specific a specific version of our provider
     and it just used the latest one,
     that could cause a conflict
     _if_ that provider was updated in the background
  
   - deprecated dependencies

     we are depending on an external module
     or a specific resource type within the cloud provider,
     and that was then deprecated
  
   - unapplied changes

     if we have made a change to our infrastructure config or a our Terraform config
     but that never got applied to a specific environment;
     let's say we rolled it out to `staging`
     but we forgot - because we didn't automate it! -
     ... to actually apply that to `production`,
     so that unapplied change now is a conflict
     between our config file and our state file

3. static checks

   (a) some are built into the `terraform` binary itself

      - `terraform fmt -check` and `terraform fmt`

        (
        give us an opinionated formatting,
        making sure that everyone adheres to the same style
        )

      - `terraform validate`

        (
        does a check to see
        whether all of my configurations are using all of the required input variables,
        or whether a number is passed to a boolean variable,
        etc.
        )

      - `terraform plan`

        (
        can be a great way to check
        if something has changed out-of-band;
        so, if I run a `terraform plan` command and it says "0 changes required",
        that means (we're good to go i.e.) our config has not been modified;
        on the flipside, if I run a `terraform plan` [command]
        and it says "We need to ... change these 4 things",
        that means something happened -
        unless I changed my config and I wanted those changes! -
        ... if I haven't changed my config, that means something happened out-of-band;
        often, a good check is
        to run a `terraform plan` command once a day or once a week,
        and if it says that there's changes need
        but there's been no change to the config,
        then that indicates that something can be wrong
        )

      - custom validation rules

   (b) there's also some third-party tools
       (that we can use to do some additional checks against our codebase)

      - `tflint`

      - some scanning tools,
        which are focused on the security aspects of your Terraform config:
        `checkov`, `tfsec`, `terrascan`, `terraform-compliance`, `snyk`

      - the managed cloud offering [from Hashicorp] offers a tool called Terraform Sentinel,
        which is enterprise-only ...,
        but it can help you to validate some security configurations
        and then force some rules on your codebase
        ... (which can be great from a security and compliance perspective
        if you need that sort of level of guarantees about the configurations
        that you're managing)

4. manual testing

   you can always, as you might expect, do manual testing of things

   this would just be following that similar lifecycle of commands
   that we talked about many times throughout the course:
    - `terraform init`
    - `terraform plan`
    - `terraform apply`
    - `terraform destroy`

   so this can give you a sense of,
   "Hey, does this configuration produce a working set of infrastructure?"

   and that's great,
   but we would much prefer for this type of testing to be automated;
   so we can take that type of manual testing
   and just automate all of those steps
   (with a shell script or whatever other technique we want)

4. automated testing

   - with Bash

      for example, we could write a script like the one in
      `08-testing--testing-terraform-code/4-tests/2-bash/hello_world_test.sh`

      we coud ... run this script in CI
  
   - with Terratest

      we probably don't want to just have a hacky shell script as our end-all-be-all

      and so, there are tools
      that allow us to define tests within actual programming languages,
      to test our infrastructure
      and make more complex assertions about what we expect to happen

      so I've taken that same test that we had before
      and now implemented it in Go using a tool called Terratest;
      cf the following file: 
      `08-testing--testing-terraform-code/4-tests/3-terratest/hello_world_test.go`

5. another powerful test that I like to add to any Terraform project is
   to periodically execute a `terraform plan` command within your CI/CD system

   what that's going to do is:
   if there have been any changes (either via the CLI or via the UI)
   outside of what Terraform knows about,
   you can set it up so that
   (a) it will fail the test
   and (b) that will notify you,
   so that you can go check,
   "Hey, what's different about my deployed infrastructure from my IaC configuration?"

   and, if it was by accident, I want to revert those changes;
   if it was on purpose, I want to bring those changes back into the configuration;

# Developer workflows

[part 09 of tutorial]

1. overview

   at this point, we understand:

    - how Terraform works

    - how to use the Hashicorp Configuration Language (HCL)

    - how we should be organizing and structuring our code with these modules

    - how to manage multiple environments

    - how to test our code
  
   [in] this final portion,
   I want to kind of bring it all together
   and help you to understand what different workflows would look like
   both from a developer perspective
   [and] from [the perspective of] automating the operations of using a tool like Terraform
   to ensure that
   we have reliable infrastructure and can update it accordingly

2. general workflow
   (that a developer, who is using Terraform, is gonna go through)

   - write and update that code

   - run those changes locally
     (for a development environment)
     (= maybe you have a development environment that you can change without having any issues)
  
   - (once you're satisfied that your config matches what you want it to, you would then) create a pull request _and_ trigger a run of tests from within our Continuous Integration system (e.g. GitHub Actions)

     so that could run, maybe that Terratest ... that I had shown before;
     spin up a copy of the infrastructure;
     make sure things are still working as they are expected to;
     if they are, give us a green check mark and tear that infrastructure down;

     (
     and that gives us confidence that,
     when we do end up deploying this to `production`,
     we're not going to run into any issues
     )

   - if[/when] we merge that pull request to the `main` branch,
     we could have an automated pipeline
     (within GitHub actions again = our whatever-Continuous-Integration-Continuous-Delivery-pipelining-tool-of-choice)
     and deploy those changes to `staging` automatically

     (
     rather than have a developer issue a `terraform apply` command locally on their laptop,
     we want those things to be automated
     so that we can avoid the potential for human error
     )
    
    - maybe[?] on the next release
      so that, let's say, we tag a release within GitHub,
      that could kick off a separate pipeline,
      which now takes those same changes that were made on `main`
      and deployes them to our `production` [environment]

   ---

   so, this is kind of the general workflow that I would recommend

   ---

   I would also recommend
   having a testing schedule on a Cron ...
   so periodically running just a `terraform plan`
   from within your Continuous Integration tool;
   and, if that plan shows any changes from the deployed state to the current ... config on your `main` branch, to raise an error;
   and so, that could be an easy check to see if something was changed out-of-band, and find that very quickly,
   and [either] make sure that gets reverted,
   or ... integrated back into the config if it was a purposeful change

3. (there's also an important consideration here of working with) multiple accounts [within AWS] [= "projects" withing GCP]

   often times, it is beneficial from a security perspective to have
       one account for `staging`,
       one account for `production`,
       one account for `development`,
       etc.

   pros:

    - having these resources deployed into different accounts
      makes it much easier to manage the level of granularity for access "that you need to"[?] within IAM policies,
      to enforce the controls for the different environments -
      "both from the infrastructure that's deployed,
      as well as for these Terraform backends"
    
    - we want to isolate the environments to protect against potential issues

      isolate environments to "protect minimize" blast radius
      
      (
      so, if you make a mistake and blow up the `development` environment,
      that doesn't impact `staging` and `production`
      )

    - it also helps us avoid naming conflicts [for things]

      reduce naming conflicts for resources

      (
      so, if we're deploying everything into one account,
      you often times cannot have the same name for an individual resource within that account

      and so you end up having to add all these prefixes or postfixes -
      so maybe you say `database-production`, `database-staging` -
      ... those changes now need to be templated across any place that's used

      and that can just be annoying to deal with
      )

      if you're working with a multi-account setup,
      you can just name the database whatever the application name is,
      and that can be identical across all those different accounts

      and that allows you ... to avoid having to template that in in as many places,
      which can be nice

   cons:

    - it does add some complexity to your TF config
      (but, in general, I think it is still worth it to think about multi-account ... setups wherever possible + tooling can help)
  
   as you need to start tightening up your security,
   this is going to be an important way to go about doing that

   if you want to do a deep dive on how this would look
   and how you can go about implementing this within your own project:
   https://www.hashicorp.com/resources/going-multi-account-with-terraform-on-aws

4. a couple of 3rd-party tools, that are from a company called Gruntwork, that make working with Terraform much nicer

   - `gruntwork-io/terragrunt`

     - minimizes code repetition

     - [reduces the tedium required to achieve] multi-account separation (improved security/isolation)
  
   - `gruntwork-io/cloud-nuke`

     - allows you to very easily clean up a bunch of reasources
  
   - `Makefile`s (or shell scripts)

     - prevent human error

5. Continuous Integration / Continuous Deployment

   - GitHub Actions

   - CircleCI

   - GitLab

   - Atlantis
     (is kind of a Terraform-specific one)

6. Potential gotchas with Terraform

   - name changes when refactoring

     can lead Terraform to think,
     "Oh, they want to delete this resource, and create a new one"
  
   - sensitive data in Terraform state files

     your Terraform state files do have sensitive data in them,
     so be careful in making sure to encrypt and manage permissions accordingly
  
   - cloud timeouts

     Terraform sometimes has timeouts

     usually, if you just re-issue the `terraform apply` command, it will fix that,
     but they can be a little challenging
  
   - naming conflicts

   - forgetting to destroy your test infrastructure

   - uni-directional version upgrades

     if you have a large team,
     you want to make sure everyone is using the same version of Terraform on their local system,
     as well as matching that version in your CI/CD system
  
   - multiple ways to accomplish the same configuration

   - there's some parameters within a given resource that are immutable

   - out-of-band changes

     making changes out of "the normal Terraform sequence of events"

     that is something that you just want to avoid whenever possible

     your team needs to be bought into Terraform
     as _the only_ means of deploying this infrastructure
