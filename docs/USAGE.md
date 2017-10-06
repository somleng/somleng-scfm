# Usage

## Rake Tasks

### Callouts

Creates a new callout and prints the callout id. If `CALLOUTS_TASK_CREATE_METADATA` is set to a JSON string the callout will be created with the specified metadata.

```
$ CALLOUTS_TASK_CREATE_METADATA='{}' rake task:callouts:create
```
