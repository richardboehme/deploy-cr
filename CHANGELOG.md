# Changelog

## unreleased

##### Rename Deployment::Task => Deployment

This is needed because the constant resolution in Crystal 1.3.0 changed. This means we cannot use constants like `Task::CloneProject` inside the task.cr file, because it searches for this constant in the current `Deployment::Task` class.

To update you can either copy your `task.cr` file to `deployment.cr` and change the class name to `Deployment` instead of `Deployment::Task` or regenerate the file using `bin/deploy init`.

## Release 0.2.0

* Remove the need for libcrystal.a when using Crystal 1.1.0 or newer.

## Release 0.1.1

* Fix postinstall build command when installing the shard

## Release 0.1.0

Initial Release :tada:
