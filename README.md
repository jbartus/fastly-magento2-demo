# what is this
An example configuration using terraform to create a magento site on gcp with fastly in front of it.

# what does it do
- creates a virtual machine on google cloud, installs magento and the fastly magento plugin
- attaches an ngwaf@edge deployment to the service
- spools up some attack tooling to generate traffic and graph data

# diagram
```mermaid
flowchart LR
  puppeteer --> site[site-name.freetls.fastly.net]
  randomhack --> site
  site --> varnish[varnish service]
  varnish --> ngwaf
  ngwaf --> origin[origin vm]
```

# pre-reqs
- a fastly account with the following feature flags enabled
  - `io_entitlement`
- a sigsci account (corp)
- a GCP account with access to the SE development project

# howto
## first time setup
chose one of the following three options for where to run this from

### option 1 - a github codespace
- click the green "Code" button at the top of the github repo
- click the Codespaces tab within the modal
- click the green "Create codespace..." button
- watch and wait for it to setup (takes ~5m)

### option 2 - locally using vscode with a devcontainer
- install the devcontainer extension in vscode
- open this folder in the devcontainer
- wait for it (takes ~5m)
- open another terminal to work in

### option 3 - install dependencies on an M1/M2 mac with homebrew
[click here ](README.mac-arm.md)

### configure authentication(s)
- create a fastly api token for your user ([creating api tokens](https://docs.fastly.com/en/guides/using-api-tokens#creating-api-tokens))
- configure the fastly cli with it   
    `fastly profile create`  
- configure the google terraform provider's access  
    `gcloud auth application-default login`
- click on the file named `terraform.tfvars` in the left menu and populate its values
  - use the same fastly api key from the cli (`fastly profile token`)
  - populate the two `magento_repo` variables ([see here for how to get them](https://experienceleague.adobe.com/docs/commerce-operations/installation-guide/prerequisites/authentication-keys.html))  
  - populate the three `sigsci_` variables ([see here for how to create an api key](https://docs.fastly.com/signalsciences/developer/using-our-api/#managing-api-access-tokens))
  - if enabling hyva configure the location of the private key that matches the public you uploaded to ([hyva's gitlab](https://docs.hyva.io/hyva-themes/getting-started/#for-contributions-and-for-technology-partners))

## test loop
- `terraform apply`
- click the links
- `terraform destroy`

## cleanup (if using codespaces)
- in the same github web modal that you created the codespace you will now see it listed with a random name
- click the "..." next to it
- click Delete