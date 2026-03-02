# PATH
export PATH="$PATH:$(go env GOPATH)/bin"
export PATH="$HOME/.local/bin:$PATH"

# Aliases
alias tfp='terraform plan -var-file=./env/$(terraform workspace show).tfvars'
alias tfa='terraform apply -var-file=./env/$(terraform workspace show).tfvars'
