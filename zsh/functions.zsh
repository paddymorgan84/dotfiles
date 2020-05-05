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
