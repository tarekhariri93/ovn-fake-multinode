# ovn-fake-multinode

Using this repo, you can leverage nested namespaces to deploy
an OVN cluster where outer namespaces represent a compute node -- aka
OVN chassis. Inside each of these emulated chassis, we are then able
to create inner namespaces to emulate something comparable to ports of
a VM in a compute node.

For more details, take a look at this talk
from the [2019 OVScon](https://www.openvswitch.org/support/ovscon2019/):
[Deploying multi chassis OVN using docker in docker by Numan Siddique, Red Hat](https://www.openvswitch.org/support/ovscon2019/#7.3L):
[**Slides**](https://www.openvswitch.org/support/ovscon2019/day2/1319-siddique.pdf)
[**Video**](https://youtu.be/Pdd_pOMzQQM?t=97)

## Steps

Step 1: Build the container images

OVN and OVS will be retrieved from the GitHub repository and subsequently installed. You have the flexibility to alter the version tags using the `OVN_TAG` and `OVS_TAG` variables. The default versions utilized are v23.09.0 for OVN and v2.17.9 for OVS.

By default, Docker is employed (users have the ability to manage the container runtime via the RUNC_CMD environment variable). Execute the command from the root directory:
```bash
./ovn_cluster.sh build
```

This will create 2 container images

- **ovn/cinc**: base image that gives us the nesting capability
- **ovn/ovn-multi-node**: built on top of cinc where ovs+ovn is compiled and installed

By default, these container images are built on top of `fedora:latest`. This behavior can be controlled
by two environment variables:

- `OS_IMAGE`: URL from which the base OCI image is pulled (default: `quay.io/fedora/fedora:latest`)
- `OS_BASE`: Which OS is used for the base OCI image. Supported values are `fedora` and `ubuntu`
  (default: `fedora`)

Step 2: Start the ovn-fake-multinode

OVN central container will run with forwarding PORT through the `OVN_FORWARDED_PORT` environment variable,
by default we are using port 6641.

number of running chanssis can be configured by the environment variable `CHASSIS_COUNT` (default: 2)

```bash
./ovn_cluster.sh start
```

Step 4: Stop the ovn-fake-multinode and tweak cluster as needed
```bash
./ovn_cluster.sh stop

# look for start-container and configure-ovn functions in
vim ./ovn_cluster.sh

# Go back to step 3 and have fun!
```

### Getting into underlay

A port called *ovnfake-ext* is created in the fake underlay
network as part of *ovn_cluster.sh start*. You can use that
as an easy way of getting inside the cluster (via NAT in OVN).
Look for *ip netns add ovnfake-ext* in *ovn_cluster.sh*.
An example for doing that is shown here:
```
ip netns exec ovnfake-ext bash
```

Similarly, a port called *ovnfake-int* is created in the fake node
network. It can be used to access the emulated chassis.
Here is an example:
```
ip netns exec ovnfake-int bash
```
