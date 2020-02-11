#!/usr/libexec/platform-python
import json
import os
import sys
from urllib.request import Request, urlopen

IMAGE_SUCCESS_URL = 'https://github.com/tektoncd.png'
IMAGE_FAILURE_URL = 'https://uploader-ci-openshift-pipelines.apps.devint.openshiftknativedemo.org/misc/sadcat2.png'

pullreq_params = """$(inputs.params.pullreq_params)"""
pullreq_conditions = """$(inputs.params.pullreq_conditions)"""
pullreq_html_url = "$(inputs.params.pullreq_html_url)"
pipelinerun_name = "$(inputs.params.pipelinerun_name)"

COLLECTLOG_BASE = "https://collectlogs-ci-openshift-pipelines.apps.devint.openshiftknativedemo.org"


def get_params_values(name, pullreq_params):
    for p in pullreq_params:
        if p['name'] == name:
            return p['value']


if pullreq_html_url:
    pullreq_url = "$(inputs.params.pullreq_html_url)"
    webconsole_url = f"{os.environ['CONSOLE_URL']}/k8s/ns/{os.environ['NS']}/tekton.dev~v1alpha1~PipelineRun/{os.environ['PR']}"
    collectlogs_url = COLLECTLOG_BASE + "/log/" + os.environ["PR"]
    subject = f"OpenShift Pipelines CI ran succesfully on {pullreq_url} " \
        ":pipelinedance: :dancing-penguin: :aw_yeah:"
    image_url = IMAGE_SUCCESS_URL
else:
    pullreq_conditions = json.loads(pullreq_conditions)
    pullreq_params = json.loads(pullreq_params)
    # Not doing the succeed since that's cared by the normal pipeline flow (but
    # we could )
    if pullreq_conditions[0]['reason'] != 'Failed':
        sys.exit(0)

    repo = get_params_values("pullreq_repo_full_name", pullreq_params)
    prnumber = get_params_values("pullreq_number", pullreq_params)
    pullreq_url = f"https://github.com/{repo}/pull/{prnumber}"
    webconsole_url = f"{os.environ['CONSOLE_URL']}/k8s/ns/{os.environ['NS']}/tekton.dev~v1alpha1~PipelineRun/$(inputs.params.pipelinerun_name)"
    collectlogs_url = f"{COLLECTLOG_BASE}/log/$(inputs.params.pipelinerun_name)"
    subject = f"OpenShift Pipelines CI has failed on {pullreq_url} " \
        ":fb-sad: :crying_cat_face: :crying:"
    image_url = IMAGE_FAILURE_URL

text = f"""


    • TektonCD Collectlogs: {collectlogs_url}
    • OpenShift Console: {webconsole_url}

"""

msg = {
    "text":
    subject,
    "attachments": [{
        "blocks": [
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": text,
                },
                "accessory": {
                    "type": "image",
                    "image_url": image_url,
                    "alt_text": "TektonCD CI"
                }
            },
        ]
    }]
}
req = Request(
    os.environ.get("SLACK_WEBHOOK_URL"),
    data=json.dumps(msg).encode(),
    headers={"Content-type": "application/json"},
    method="POST")
# TODO: Handle error?
print(urlopen(req).read().decode())
print("slack message has been sent")
