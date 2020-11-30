# APIcast GUID Policy

This policy is a policy to add a GUID into the header for APIcast.

## Pre-requisites

The following pre-requisites need to be verified before proceeding with the installation.

- Openshift 4.x installed and running
- 3scale 2.9 installed and running

## Overview

This policy adds a new header attribute with a GUID or UUID to the request before sending to a Backend.

There are two builds that we need to keep in mind.

- `apicast-guid-policy`: This first runs the default source to image scripts and copies the contents of the [policies](policies) folder.
- `apicast-custom`: Takes the output of the first build, runs copies the contents to the right place, also runs some tests.

So, both of them are required to run.

The API Manager get's the list of policies including the custom ones from the API Cast that is being referenced from the `APICAST_REGISTRY_URL`. So, don't forget to update the value of this environmnet variable to point the same API Cast instance that you are using to deploy your image. In this procedure we will be deploying the policies to the operator provisioned API Casts.

---

**NOTE**

If you are taking this as a reference to develop your own policy then don't forget the following rules:

1. Update the policy folder name inside the [policies](policies) folder with the name of your policy.
2. Update the policy folder with the version of your policy.
3. Update the [apicast-policy.json](policies/guid/0.1/apicast-policy.json) with the information of your policy. Here you can add parameters to it.
4. The other lua files inside [policies/guid/0.1](policies/guid/0.1) are where you will need to implement your policy.
5. Update the [openshift.yml:L70](https://github.com/mgohashi/3scale-custom-policy/blob/382253ce1c44d6876f76c3cd288764e4498999a7/openshift.yml#L70) with the name of 

---

Parameters of this policy:
- Header name: If provided, if will use the deafult header name which is `GUID`.

## Installation OpenShift

1. Open a terminal window and run the following commands from within the cloned version of this repository root folder.

2. Update the following variables with your own envrironment.

   ```shell
   3SCALE_NAMESPACE="the name of your 3scale namespace"
   3SCALE_SERVICE_TOKEN="your 3scale service token"
   3SCALE_ADMIN_PORTAL_ENDPOINT="your admin portal endpoint"
   GIT_REPO="your GIT repository containing this policy"
   ```

3. Access the current 3scale namespace for your API casts.

   ```shell
   oc project $3SCALE_NAMESPACE
   ```

4. Create the image stream of the apicast.

   ---
   **NOTE**
   
   You can also import this image to the same namespace of 3scale.
   
   ---

   ```shell
   oc -n openshift import-image amp-apicast:3scale2.9.1 --from=registry.redhat.io/3scale-amp2/apicast-gateway-rhel8:3scale2.9.1 --confirm
   ```

5. Create the secret for the apicast.

   ```shell
   oc -n $3SCALE_NAMESPACE create secret generic apicast-configuration-url-secret --from-literal=password=https://$3SCALE_SERVICE_TOKEN@$3SCALE_ADMIN_PORTAL_ENDPOINT --type=kubernetes.io/basic-auth
   ```

6. To install the build configs on OpenShift you can use provided template:

   ```shell
   oc -n $3SCALE_NAMESPACE new-app -f openshift.yml -o yaml -p GIT_REPO=$GIT_REPO | oc apply -f -
   ```

## Starting the build

1. To start the first build run the following command:

   ```shell
   oc -n $3SCALE_NAMESPACE start-build apicast-guid-policy --wait --follow
   ```

2. To start the second build run the following command:

   ```shell
   oc -n $3SCALE_NAMESPACE start-build apicast-custom --wait --follow
   ```

If you didn't change the output image of the second build, you should see the API Casts being redeployed.

Once you deploy the new image, you should see the new policy appearing in the list of policies to add.

## Configuring API

1. Log into your Admin portal;
2. From the dropdown menu on the top Access your API or Service and click on `Integration` > `Policies`;
3. Click on the link `Add policy`;
4. Click on the `GUID Policy`:
   
   ![](docs/guid-police.png)
5. Move the new policy to before the default **API Cast** policy;
6. Click on the **GUID Policy** again and you should see its properties;
7. There you can change the header name to be used to add the **UUID** value;
8. Once you finish changing the settings, you can click on **Update policy** button and then `Update Policy Chain`;
9. Go to configuration and promote your changes to staging;
10. Finally you can test your new policy.

## Testing your changes

A sample response of the configured API:

---
**NOTE**

Some attributes have been omitted for brevity.

---

```json
{
    "method": "GET",
    "path": "/",
    "args": "",
    "body": "",
    "headers": {
        ...,
        "HTTP_GUID": "69581a25-685f-4bbc-8224-2d8aea9b38de",
        ...
    },
    "uuid": "89f9dca6-c85d-4044-a3ff-4a3d4e32c4e2"
}
```