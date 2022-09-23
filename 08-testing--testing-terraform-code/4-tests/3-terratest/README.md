# Motivation: why should we use Terratest?

by using Terratest,
we have many more powerful primitives
for defining the nuanced types of tests
that we would want to perform for our infrastructure,
and it allows us to take advantage of all of the normal Golang tooling
for actually testing our code

# How to run this test?

make sure that we have all the dependencies that we are using here
[= in the `hello_world_test.go` file]:
```
go mod download
```

find all the tests within the current working directory, and run them:
```
go test -v --timeout 10m
```
