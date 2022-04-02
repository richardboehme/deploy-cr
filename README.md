# deploy-cr

[![GitHub release](https://img.shields.io/github/release/richardboehme/deploy-cr.svg)](https://github.com/richardboehme/deploy-cr/releases)
![CI](https://github.com/richardboehme/deploy-cr/actions/workflows/specs.yml/badge.svg)

Simple and powerful deployment for your crystal application.

**Note**: This project is at a very early stage of development. Please do not hesitate to open an issue if you experience any problems.

## Features

* Fully configurable
* Simple to understand
* Amber integration (more to come)
* Cross-compile support
* CLI to set everything up

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   development-dependencies:
     deploy-cr:
       github: richardboehme/deploy-cr
       version: ~> 0.2.0
   ```

2. Run `shards install`. This will build the deploy-cr CLI binary at `bin/deploy`.

## Usage

### Setup

To make your application ready to use `deploy-cr`, run `bin/deploy init [options]`.

The following options are available:

**--cross-compile** *(required)*: Cross compiles your binary. This is currently required as normal compilation is not supported yet. (see [Cross Compilation](#cross-compilation))

**--npm**: Compile NPM assets which is useful when compiling web applications. (see [Asset Compilation](#asset-compilation))

**--amber**: Enable the [Amber](#amber) integration.

After running the command you should go ahead and configure the deployment process to fit your needs.

### Configuration

After setting up there will be `config/deployment/deployment.cr` and a `config/deployment/production.cr` file.

The `deployment.cr` file includes all steps that are necessary to deploy your application. You can easily customize this operation.

The `production.cr` file contains the configuration used for your production stage. You can also create other files with different configurations for different stages (for example a `staging.cr` file).

#### deployment<area>.cr

The Deployment class is a Hathor Operation. This means, that the deployment process is structured into multiple steps that run in order of definition. If one step fails the execution is terminated. You can read more about Hathor Operations on their [repository](https://github.com/ikaru5/hathor-operation).

This makes it really easy to add custom steps to your deployment task. For example one may need a step to restart the application after a successful deployment. You can simply add it like that:

```crystal
class Deployment < DeployCR::Deployment
  # ...
  step restart!

  def restart!
    run("systemctl", ["restart", "--user", "app"])
  end
end
```

You can use the `run` method to run a command locally and the `ssh` method to run a command on the target machine.

#### Stage configurations

By default configuration file for one stage (`production.cr`) will be created. It looks like this:

```crystal
require "./deployment"

Deployment.configure do |config|
  config.app_name = "your-binary-name"
  config.path = "path/to/your/app"

  config.host = "remote-host"
  config.user = "deploy"

  config.source = "git-repo-path"

  config.llvm_command = "llvm-config"
end
```

As you can see it contains several configuration options that you should change to fit your needs. All possible configuration options are described in the specifc task that needs it. The following options are not described there:

**host**: The hostname of the server where your code should be upstreamed to.<br/>
**user**: The user name that should be used when communicating with the server.<br/>
**path**: The path where to store your application on the server.

You can add new stage files by simply copying the `production.cr` to a new file (for example `staging.cr`) and modifying the configuration to match the other environment.

### Tasks

#### Clone Project

By default the `Task::CloneProject` task is included in your deployment task. It will clone your project from a git source when deploying.

The following configuration options are available:

**source**: The git source which should be used to clone the repository.

#### Cross Compilation

Cross Compilation is separated into two tasks. Firstly, the object file for your binary has to be compiled. After uploading this file to the server, the binary has to be linked on the target machine.

You can enable cross compilation by using the `--cross-compile` option when setting up deploy-cr. Alternatively, you can add the tasks manually.

##### Compile

Compilation happens by the `Task::CrossCompile::Compile` step.

After compiling the object file, it will be added to the files that need to be uploaded.

The following configuration options are available:

**app_name**: Defines your binary and object file name. When not defined, the app name will be defined by the folder name of your project.

**llvm_command**: Defines the command used to retrieve the llvm target that the object file should aim at. This defaults to `llvm-config`.

##### Link

After the object file was uploaded linking happens by the `Task::CrossCompile::Link` step.

You only have to configure the following option when running on a Crystal version < 1.1.0. From Crystal 1.1.0 the file is not needed to link the object file on the target machine.

**libcrystala_location**: libcrystal is needed to link your binary on projects that use Crystal < 1.1.0. This means the file `libcrystal.a` has to be present at the target machine. Set the location of this file here so that we can replace it when linking. You can get the `libcrystal.a` file by checking out the [Crystal](https://github.com/crystal-lang/crystal) repository on the target machine and run `make libcrystal`.

#### Asset Compilation

A lot of application need assets that should be compiled when deploying. When using NPM one can use the `Task::CompileAssets` task to do so. Be sure to do this before syncing the files to the server.

### Integrations

Integrations help to quickly setup a specific crystal application.

#### Amber

The Amber integration is added by adding the `step Integration::Amber` to your deployment task before uploading files to the destination or by using the `--amber` option when setting up deploy-cr.

The following files/directories will be added by the integration:

* `config/environments/.production.enc`
* `config/database.yml`
* `public/**/**`

Note that you still need to enable asset compilation if you want your assets to be compiled before deploying your binary.

### Run deployments

A deployment can be started by running:

```
bin/deploy run <stage>
```

The `stage` argument specifies the configuration file that should be used. For example if you want to deploy using the `production.cr` configuration file you can run:

```
bin/deploy run production
```

This CLI command is just a convenience wrapper around executing the stage file directly. The above command is roughly equal to

```
crystal config/deployment/production.cr
```

## Planned Features

- [x] Create Amber default settings
- [ ] Make File Uploading more elegant
- [x] Extend tests (CLI + Main Operation)
- [ ] Document everything
- [ ] Input validation at compile time
- [ ] Implement some kind of more sophisticated logger (better than puts I guess)
- [x] Add CI
- [ ] Make deployment scripts compilable

## Contributing

Bug reports and pull requests are highly welcomed and appreciated. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](CODE_OF_CONDUCT.md).

1. Fork it (<https://github.com/richardboehme/deploy-cr/fork>)
2. Create your feature branch by branching off of **main** (`git checkout -b my-new-feature`)
3. Make your changes
4. Make sure all specs run successfully (`crystal spec`)
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create a new pull request

## License

Copyright (c) 2021-2022 Richard Böhme (richard.boehme1999@gmail.com)

deploy-cr is released under the [MIT License](https://opensource.org/licenses/MIT).
