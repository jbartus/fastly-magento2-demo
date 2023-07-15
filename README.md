# fsly demo

## what is this
- short term: a place for me to learn and rough out minimal examples of fastly products with terraform
- medium term: a foundation on which to build live product demonstrations
- long term: a resource for managing bespoke partner demonstration environments

## pre-reqs
- a fastly account (with `io_entitlement` and `rate_limiting` feature flags)
- the fastly cli, configured with an api token with engineer or higher permission
- another api token with read-only access and user or higher permission (for the edgeapp)
- a sigsci account (corp)
- an api key from that corp
- a GCP account
- the gcloud cli tool installed and authenticated
`gcloud auth application-default login`
- terraform
- vegeta
- jq

## howto
### first time setup
- clone this repo and cd into it
- `terraform init`
- `cp .env.example .env`
- edit `.env` and populate the three `SIGSCI_` variables
- `source .env`
- generate a read-only fastly api token and put it in `./edgeapp/.secret`
### test loop
- `source bin/secrets-apply.sh`
- `terraform apply`
- do your thing
- `terraform destroy`
- `./bin/secrets-destroy.sh`

## wishlist
- integrate dcorbett's sqli demo
- figure out how to demonstrate purging
- figure out how to demonstrate edge rate limiting
- figure out how to demonstrate live stats and logs
- figure out how to demonstrate fast config changes
- figure out how to demonstrate websockets
- figure out how to demonstrate the frustration of latency