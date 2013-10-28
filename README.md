# Salmon
A Ruby tool for migrating a collection of repositories from one Github instance to another.

## Usage
- Create ```~/.salmon``` with YAML data for the Github site(s) you plan on using so that your tokens/passwords aren't in bash history
    ```
    #defaults to github.com
    github: 
      basic_auth: 'sheeley:password'      

    # your enterprise install
    enterprise:
      basic_auth: TOKENTOKENTOKEN
      endpoint: https://github.enterprise.com/api/v3
    ```
    For a list of supported settings, check out the [Github API gem](https://github.com/peter-murach/github)
- Run salmon  
    ```
    # copy from one Github account to another
    salmon -s github:sheeley -t github:sheeley2

    # copy from Github.com to an enterprise Github, include tags and git output
    salmon -p -v -s github:sheeley -t enterprise:sheeley
    ```
