- open a terminal
- install homebrew ([docs](https://brew.sh/))  
  `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- install fastly, terraform and other cli tools  
  `brew install fastly terraform vegeta jq`
- gcloud cli ([docs](https://cloud.google.com/sdk/docs/install-sdk#mac))  
  `curl -o https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-442.0.0-darwin-arm.tar.gz`  
  `tar xf google-cloud-cli-*`  
  `./google-cloud-sdk/install.sh`
- clone this repo and cd into it
- copy the variables file to start your own (which will be ignored by git)  
  `cp terraform.tfvars.example terraform.tfvars`
- `terraform init`