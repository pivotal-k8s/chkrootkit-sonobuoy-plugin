# chkrootkit sonobuoy (example) plugin

This is a small **example** of a [sonobuoy] [plugin] and how you might want to
integrate it into your workflow.

This [plugin] runs [chkrootkit] on all kubernetes nodes, gathers the results,
and reports them back as part of the [sonobuoy snapshot tarball][sb/snap].


## [`sonobuoy-gen.sh`][sb-gen.sh]

... is a small wrapper around [`sonobuoy gen`][sb/gen]. It
injects the plugin's configuration and adds the plugin to the list of plugins
that should be run by [sonobuoy]. 

It takes the same commandline arguments as [`sonobuoy gen`][sb/gen] takes.

This script does not do `sonobuoy run` but
just generates the kubernetes specs configuration, this can be directly applied
by piping to `kubectl`:

```sh
./sonobuoy-gen.sh \
  --kube-conformance-image-version latest \
  --kube-conformance-image gcr.io/heptio-images/kube-conformance \
  --mode quick \
    | kubectl apply -f -
```

You can configure that wrapper to a certain extent by setting the following
variables in the environment:
- `SONOBUOY`: by default, the [sonobuoy] binary in the `$PATH` will be used,
  this gives you a way to use a specific/different binary.
- `PLUGIN_NAME`: by default the plugin will register itself as `chkrootkit`,
  you can change that.
- `PLUGIN_CONF_FILE`: by default the configuration from `./chkrootkit.yaml`
  will be used, you can point this script to a different configuration file.

After you did a `./sonobuoy-gen.sh ... | kubectl apply -f -` there should be no
need for this repo/scripts/... anymore. At this point the plugin is installed
with sonobuoy, all other interactions can be done with the `sonobuoy` CLI
directly.

## [`Dockerfile`][docker] && [`check.sh`][check]

... are the central parts of the plugin. The container image that is created by
this [`Dockerfile`][docker] will run in a `daemonset` pod on all kubernetes
nodes.
[`check.sh`][check] will run inside a container of that `daemonset` pod, will
run [chkrootkit] against the root filesystem of the node, and will finally
report the status of that back to [sonobuoy].

Note: [chkrootkit] will only run once on every node, it will not run
continuously. After [chkrootkit] finished running the container will just wait
doing noting until the whole [sonobuoy] test run is done and the [sonobuoy]
system shuts down and deletes those daemonsets.

## Dependencies

We expect the following tools to be installed and in the `$PATH` to be able to
run [`./sonobuoy-gen.sh`][sb-gen] successfully.

- `sonobuoy`: https://github.com/heptio/sonobuoy
- `jq`: https://stedolan.github.io/jq/
- `yq`: https://github.com/kislyuk/yq


[sonobuoy]: //github.com/heptio/sonobuoy
[chkrootkit]: http://www.chkrootkit.org/
[plugin]: //github.com/heptio/sonobuoy/blob/master/docs/plugins.md
[sb/gen]: //github.com/heptio/sonobuoy/blob/master/docs/gen.md
[sb/snap]: //github.com/heptio/sonobuoy/blob/master/docs/snapshot.md

[sb-gen.sh]:  //github.com/pivotal-k8s/chkrootkit-sonobuoy-plugin/blob/master/sonobuoy-gen.sh
[docker]:  //github.com/pivotal-k8s/chkrootkit-sonobuoy-plugin/blob/master/Dockerfile
[check]:  //github.com/pivotal-k8s/chkrootkit-sonobuoy-plugin/blob/master/check.sh

