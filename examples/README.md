# Examples

- Define `test/fixtures/credentials.tfvars`:

```
access_key = "<access_key>"
public_key_pathname = "<pathname_for_public_ssh_key>"
secret_key = "<secret_key>"
```

- `bundle`

- `bundle exec kitchen converge`

- Wait for the instances to be ready...

- `bundle exec kitchen verify`

- `bundle exec kitchen destroy`
