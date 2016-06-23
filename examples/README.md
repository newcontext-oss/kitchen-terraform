# Examples

1. Define `test/fixtures/credentials.tfvars`:

```
access_key = "<access_key>"
public_key_pathname = "<pathname_for_public_ssh_key>"
secret_key = "<secret_key>"
```

1. `bundle`

1. `bundle exec kitchen converge`

1. Wait for the instances to be ready...

1. `bundle exec kitchen verify`

1. `bundle exec kitchen destroy`
