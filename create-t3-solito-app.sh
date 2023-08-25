#! /usr/bin/bash

# VARIABLES
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SECRET=$(openssl rand -base64 32)
DEFAULT_DIR=~/Projects

# FUNCTIONS
function help {
    cd $SCRIPT_DIR
    cat help.txt
}

# CHECK FLAGS
while getopts :n:p:h FLAGS;
do
    case $FLAGS in
        n)
            PROJECT_NAME=$OPTARG
            ;;
        p)
            PROJECT_DIR=$OPTARG
            ;;
        h)
            help
            exit 1
            ;;
        ?)
            echo ""
            echo "-$OPTARG is not an option."
            help
    esac
done


if [ -n "$PROJECT_NAME" ]
then 
    if [ -n "$PROJECT_DIR" ]
    then
        if [ -d "$PROJECT_DIR" ]
        then 
            cd $PROJECT_DIR
        else
           mkdir $PROJECT_DIR
           cd $PROJECT_DIR
        fi
    else
        if [ -d "$DEFAULT_DIR" ]
        then
            cd $DEFAULT_DIR
        else
            mkdir $DEFAULT_DIR
            cd $DEFAULT_DIR
        fi
    fi
    git clone https://github.com/joegoggin/t3-solito-template.git
    mv t3-solito-template $PROJECT_NAME
    cd $PROJECT_NAME
    rm -rf .git
    git init
    cd ./packages/db
    echo "DATABASE_URL=\"postgresql://postgres:**Password**@localhost:5432/**DB**\"" >> .env
    cd ../app
    echo "import { Platform } from \"react-native\";" >> env.ts
    echo "" >> env.ts
    echo "const tunnel = \"**tunnel**\";" >> env.ts
    echo "" >> env.ts
    echo "export const API = Platform.OS === \"web\" ? \"http://localhost:3000/api/trpc\" : \`\${tunnel}/api/trpc\`;" >> env.ts
    cd ../server
    echo "export const JWT_SECRET = \"$SECRET\";" >> env.ts
    yarn
    echo ""
    echo "$PROJECT_NAME was successfully created!"
    echo ""
else
    cd $SCRIPT_DIR
    cat error.txt
    exit 1
fi
