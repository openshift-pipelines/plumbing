set -eu

source $(git rev-parse --show-toplevel)/CI/config.sh

git push

kubectl get -l "tekton.dev/task=repush-images-releases" tr -o name|xargs kubectl delete

kubectl delete -f $(git rev-parse --show-toplevel)/CI/tasks/bootstrap/push-images-release.yaml 2>/dev/null || true
kubectl create -f $(git rev-parse --show-toplevel)/CI/tasks/bootstrap/push-images-release.yaml


tkn task start repush-images-releases --showlog \
    --param UPLOADER_HOST=$(grep host ~/.uploader.cfg|sed 's/host=//') \
	-i plumbing-git=plumbing-git \
    -i tektoncd-pipeline-git=tektoncd-pipeline-git \
    --serviceaccount ${SERVICE_ACCOUNT}
