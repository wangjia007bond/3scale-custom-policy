# APIcast GUID Policy

This policy is a policy to add a GUID into the header for APIcast.

## OpenShift

Create the image stream of the apicast.

```shell
oc import-image amp-apicast:3scale2.9.1 --from=registry.redhat.io/3scale-amp2/apicast-gateway-rhel8:3scale2.9.1 --confirm
```

Create the secret for the apicast.

```shell
oc create secret generic apicast-configuration-url-secret --from-literal=password=https://01925f77867291e3c4c1037a6c29f85a@3scale-admin.apps-crc.testing --type=kubernetes.io/basic-auth
```

To install this on OpenShift you can use provided template:

```shell
oc new-app -f openshift.yml --param AMP_RELEASE=2.2.0
```

Staging

```shell
oc new-app -f apicast.yml -p APICAST_NAME=apicast-staging -p CONFIGURATION_CACHE=0 -p DEPLOYMENT_ENVIRONMENT=staging -p LOG_LEVEL=debug -p CONFIGURATION_LOADER=lazy -o yaml > apicast/apicast.yml
```

Production

```shell

```

# License

MIT
