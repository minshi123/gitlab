# Admin instance level variables API

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/14108) in GitLab 13.0

## List instance variables

Get list of instance level variables.

```plaintext
GET /admin/ci/instance_variables
```

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/admin/ci/instance_variables"
```

```json
[
    {
        "key": "TEST_VARIABLE_1",
        "variable_type": "env_var",
        "value": "TEST_1",
        "protected": false,
        "masked": false
    },
    {
        "key": "TEST_VARIABLE_2",
        "variable_type": "env_var",
        "value": "TEST_2",
        "protected": false,
        "masked": false
    }
]
```

## Show variable details

Get the details of a specific instance level variable.

```plaintext
GET /admin/ci/instance_variables/:key
```

| Attribute | Type    | required | Description           |
|-----------|---------|----------|-----------------------|
| `key`     | string  | yes      | The `key` of a variable |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/admin/ci/instance_variables/TEST_VARIABLE_1"
```

```json
{
    "key": "TEST_VARIABLE_1",
    "variable_type": "env_var",
    "value": "TEST_1",
    "protected": false,
    "masked": false
}
```

## Create variable

Create a new variable.

```plaintext
POST /admin/ci/instance_variables
```

| Attribute       | Type    | required | Description           |
|-----------------|---------|----------|-----------------------|
| `key`           | string  | yes      | The `key` of a variable; must have no more than 255 characters; only `A-Z`, `a-z`, `0-9`, and `_` are allowed |
| `value`         | string  | yes      | The `value` of a variable |
| `variable_type` | string  | no       | The type of a variable. Available types are: `env_var` (default) and `file` |
| `protected`     | boolean | no       | Whether the variable is protected |
| `masked`        | boolean | no       | Whether the variable is masked |

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/admin/ci/instance_variables" --form "key=NEW_VARIABLE" --form "value=new value"
```

```json
{
    "key": "NEW_VARIABLE",
    "value": "new value",
    "variable_type": "env_var",
    "protected": false,
    "masked": false
}
```

## Update variable

Update a instance level variable.

```plaintext
PUT /admin/ci/instance_variables/:key
```

| Attribute       | Type    | required | Description             |
|-----------------|---------|----------|-------------------------|
| `key`           | string  | yes      | The `key` of a variable   |
| `value`         | string  | yes      | The `value` of a variable |
| `variable_type` | string  | no       | The type of a variable. Available types are: `env_var` (default) and `file` |
| `protected`     | boolean | no       | Whether the variable is protected |
| `masked`        | boolean | no       | Whether the variable is masked |

```shell
curl --request PUT --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/admin/ci/instance_variables/NEW_VARIABLE" --form "value=updated value"
```

```json
{
    "key": "NEW_VARIABLE",
    "value": "updated value",
    "variable_type": "env_var",
    "protected": true,
    "masked": true
}
```

## Remove variable

Remove a instance level variable.

```plaintext
DELETE /admin/ci/instance_variables/:key
```

| Attribute | Type    | required | Description             |
|-----------|---------|----------|-------------------------|
| `key`     | string  | yes      | The `key` of a variable |

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/admin/ci/instance_variables/VARIABLE_1"
```
