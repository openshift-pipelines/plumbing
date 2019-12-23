This is where you put your local configuration things, for example to create the `openshift4-install` secret, i have a `run.sh` with :

```bash
#!/usr/bin/env bash

oc get secret openshift-install 2>/dev/null >/dev/null || \
    oc create secret generic openshift-install \
       --from-literal=public-ssh-key="$(cat ~/.ssh/id_ed25519.pub)" \
       --from-literal=registry-token="$(cat ~/.docker/openshift-install.json)" \
       --from-literal="$(grep aws_access_key ~/.aws/credentials|sed 's/_/-/g')" \
       --from-literal="$(grep aws_secret_access_key ~/.aws/credentials|sed 's/_/-/g')" \
```

adjust as you wish
