##
# Sync the codebases for a branch
#
# from @benmatselby
function code-sync()
{
    for dir in */; do
        (
            echo "${dir}"
            cd "${dir}" > /dev/null 2>&1 || exit

            if [ -d .git ]; then
                git fetch -p origin && \
                git pull origin "$(git_current_branch)"
            else
                echo 'Not a git repo, skipping...'
            fi
            echo ""
        )
    done
}

##
# Clean all local branches
#
function clean-locals()
{
    for dir in */; do
        (
            echo "${dir}"
            cd "${dir}" > /dev/null 2>&1 || exit
            if [ -d .git ]; then
                cmd=$(git branch --merged master | grep -q -v "master")
                if [ -z $cmd ]; then
                    echo 'No local branches to delete, skipping...'
                else
                    git branch --merged master | grep -v "master" | xargs git branch -D
                fi
            else
                echo 'Not a git repo, skipping...'
            fi
            echo ""
        )
    done
}

##
# What branch is the codebase on and red/green depending if it's dirty or not
#
# from @benmatselby
function code-branch()
{
    local reset=$'\e[0m'
    local red=$'\e[1;31m'
    local green=$'\e[1;32m'
    color=${red}

    for dir in */; do
    (
        cd "${dir}" > /dev/null 2>&1 || exit
        cmd=$(git status --short)
        if [ -z "${cmd}" ] ; then
            color=${green}
        fi
        printf "${dir} %s$(git rev-parse --abbrev-ref HEAD)%s\\n" "${color}" "${reset}"
    )
    done
}

##
# Based on a cli config ID set the environment variables
#
# from @benmatselby
function set-aws-creds()
{
    # Check that the AWS profile parameter has been provided
    if [ -z "$1" ]
    then
        echo "usage: $0 [aws_profile]"
        return
    fi

    # Clear the AWS CLI cached credentials
    rm ~/.aws/cli/cache/*.json

    # Run the 'aws s3 ls' command to allow MFA authentication
    aws s3 ls --profile $1

    # Get the required AWS credentials from the AWS CLI cache
    AccessKeyId=$(cat ~/.aws/cli/cache/*.json | jq '.Credentials.AccessKeyId')
    SecretAccessKey=$(cat ~/.aws/cli/cache/*.json | jq '.Credentials.SecretAccessKey')
    SessionToken=$(cat ~/.aws/cli/cache/*.json | jq '.Credentials.SessionToken')

    # Echo the export commands required to set the environment variables
    # to authenticate via MFA when using the CDK CLI
    echo -e "export AWS_ACCESS_KEY_ID=${AccessKeyId}\nexport AWS_SECRET_ACCESS_KEY=${SecretAccessKey}\nexport AWS_SESSION_TOKEN=${SessionToken}\n" | clip.exe
}

##
# Clear down the AWS_* environment variables
#
# from @benmatselby
function reset-aws-creds()
{
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN
}


##
# Configure Azure portal environment and jump to corresponding VM
#

# Azure subscription mapping
declare -A AZ_SUBS=(
  [dev]="xxx"
  [qat]="xxx"
  [ppe]="xxx"
  [prd]="xxx"
)

# Function to switch subscription
azenv() {
  local env="$1"
  if [[ -z "$env" ]]; then
    echo "Usage: azenv {dev|qat|ppe|prd}"
    return 1
  fi
  if [[ -z "${AZ_SUBS[$env]}" ]]; then
    echo "Unknown environment: $env"
    return 1
  fi
  az account set --subscription "${AZ_SUBS[$env]}"
}

# Function to access linux jump box
azjump() {
  local env="$1"
  if [[ -z "$env" ]]; then
    echo "Usage: azjump {dev|qat|ppe|prd}"
    return 1
  fi

  case "$env" in
    dev|qat)
      rg="main-shared-infrastructure"
      vm="main-jump-box"
      ;;
    ppe|prd)
      rg="uk-shared-infrastructure"
      vm="uk-jump-box"
      ;;
    *)
      echo "Unknown environment: $env"
      return 1
      ;;
  esac

  azenv "$env" && az ssh vm --resource-group "$rg" --name "$vm"
}
