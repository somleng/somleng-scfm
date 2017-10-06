# Usage

## Rake Tasks

### Callouts

#### Create a new Callout

Creates a new callout and prints the callout id. If `CALLOUTS_TASK_CREATE_METADATA` is set to a JSON string the callout will be created with the specified metadata.

```
$ CALLOUTS_TASK_CREATE_METADATA='{}' rake task:callouts:create
```

#### Populate a Callout

Populates a callout with phone numbers. If `CALLOUTS_TASK_POPULATE_METADATA` is set to a JSON string the resulting phone numbers will be created with the specified metadata. If `CALLOUTS_TASK_CALLOUT_ID` is specified then the callout with the specified id will be populated. If `CALLOUTS_TASK_CALLOUT_ID` is not specified it's assumed there is only one callout in the database. If there are multiple an exception is raised.

By default callouts are populated with all the contacts in the Contacts table. Override the `contacts_to_populate_with` in the [callouts task](https://github.com/somleng/somleng-scfm/blob/master/app/tasks/callouts_task.rb) to modify this behavior.

```
$ CALLOUTS_TASK_POPULATE_METADATA='{}' CALLOUTS_TASK_CALLOUT_ID= rake task:callouts:populate
```

#### *Start*, *Stop*, *Pause* and *Resume* a callout

*start*, *stop*, *pause* or *resume* a callout given a valid `CALLOUTS_TASK_ACTION`. If `CALLOUTS_TASK_CALLOUT_ID` is specified then the callout with the specified id will be actioned. If `CALLOUTS_TASK_CALLOUT_ID` is not specified then it's assumed there is only one callout in the database. If there are multiple an exception is raised.

```
$ CALLOUTS_TASK_ACTION='start|stop|pause|resume' CALLOUTS_TASK_CALLOUT_ID= rake task:callouts:run
```

#### Print Callout Statistics

Prints statistics for a given callout. If `CALLOUTS_TASK_CALLOUT_ID` is specified then statistics for the callout with the specified id will be printed. If `CALLOUTS_TASK_CALLOUT_ID` is not specified then it's assumed there is only one callout in the database. If there are multiple an exception is raised.

```
$ CALLOUTS_TASK_CALLOUT_ID= rake task:callouts:statistics
```
