function fish_prompt --description "Write out a nice prompt"
    # ideally only called when pwd changes
    if [ -z "$__last_pwd" -o "$__last_pwd" != "$PWD" ]
        set -g __last_pwd "$PWD"
        __git_info_gitdir
    end

    # evaluate git state only once, and only if needed
    [ -n $GIT_INFO_GITDIR ]; and __git_info_vars

    set_color green
    echo -n (prompt_pwd)

    # add git prompt info
    if [ -n "$GIT_INFO_STATUS" ]
        set_color blue
        echo -n " $GIT_INFO_BRANCH"

        set -l vcs_status ""
        contains h $GIT_INFO_STATUS; and set vcs_status "$vcs_status""↰"
        contains t $GIT_INFO_STATUS; and set vcs_status "$vcs_status""!"
        contains u $GIT_INFO_STATUS; and set vcs_status "$vcs_status""≠"
        contains s $GIT_INFO_STATUS; and set vcs_status "$vcs_status""±"
        contains n $GIT_INFO_STATUS; and set vcs_status "$vcs_status""∅"
        set_color red
        [ -n "$vcs_status" ]; and echo -n " $vcs_status"

        set -l action ""
        contains R $GIT_INFO_STATUS; and set action "$action rebase"
        contains i $GIT_INFO_STATUS; and set action "$action-i"
        contains A $GIT_INFO_STATUS; and set action "$action apply"
        contains M $GIT_INFO_STATUS; and set action "$action merge"
        contains B $GIT_INFO_STATUS; and set action "$action bisect"
        set_color yellow
        [ -n "$action" ]; and echo -n " $action"
    end

    # close prompt
    set_color normal
    echo -n '> '
end
