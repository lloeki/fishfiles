source ~/.config/fish/git_prompt_info.fish
source ~/.config/fish/functions/prompt_segment.fish

function prompt_host
    [ -z "$prompt_host" ]; and set -g prompt_host (hostname | cut -d . -f 1)

    set -l bg 'black'
    set -l fg 'white'

    if [ "$USER" = 'root' ]
        set bg 'red'
    end

    if [ -n "$SSH_CLIENT" ]
        set fg 'yellow'
    end

    prompt_segment $bg $fg $USER"@"$prompt_host
end

function prompt_dir
    prompt_segment green white (echo $PWD | sed "s#^$HOME#~#")
end

function prompt_last_rc
    [ "$LAST_CMD_RC" -ne 0 ]; and prompt_segment red white "$LAST_CMD_RC"
end

function prompt_git
    if [ -n "$GIT_PS1_STATUS" ]
        set -g PROMPT_VCS_DIRTY ""
        set -g PROMPT_VCS_TYPE 'git'
        set -g PROMPT_VCS_REF "$GIT_PS1_BRANCH"
        set -g PROMPT_VCS_WPATH "$GIT_PS1_TOPLEVEL"
        set -g PROMPT_VCS_WNAME "$GIT_PS1_NAME"
        set -g PROMPT_VCS_WPWD "$GIT_PS1_PREFIX"
        contains s $GIT_PS1_STATUS; and set PROMPT_VCS_DIRTY 1
        contains t $GIT_PS1_STATUS; and set PROMPT_VCS_DIRTY 1
        contains u $GIT_PS1_STATUS; and set PROMPT_VCS_DIRTY 1
        return 0
    else
        set -e PROMPT_VCS_TYPE
        return 1
    end
end

function prompt_vcs_repo
    if prompt_git
        set -l branch_icon " ⎇ "
        set -l repo_color
        if [ "$PROMPT_VCS_DIRTY" -eq 1 ]
            set repo_color red
        else
            set repo_color blue
        end

        prompt_segment $repo_color white "$PROMPT_VCS_WNAME$branch_icon$PROMPT_VCS_REF"
        [ -n "$PROMPT_VCS_WPWD" ]; and prompt_segment green white "$PROMPT_VCS_WPWD"

        return 0
    else
        return 1
    end
end

function prompt_vcs_status
    if prompt_git
        set -l vcs_status ""
        contains h $GIT_PS1_STATUS; and set vcs_status "$vcs_status""↰"
        contains t $GIT_PS1_STATUS; and set vcs_status "$vcs_status""!"
        contains u $GIT_PS1_STATUS; and set vcs_status "$vcs_status""≠"
        contains s $GIT_PS1_STATUS; and set vcs_status "$vcs_status""±"
        contains n $GIT_PS1_STATUS; and set vcs_status "$vcs_status""∅"
        [ -n "$vcs_status" ]; and prompt_segment black white "$vcs_status"
    end
end

function prompt_vcs_action
    if prompt_git
        set -l action ""
        contains R $GIT_PS1_STATUS; and set action "$action rebase"
        contains i $GIT_PS1_STATUS; and set action "$action-i"
        contains A $GIT_PS1_STATUS; and set action "$action apply"
        contains M $GIT_PS1_STATUS; and set action "$action merge"
        contains B $GIT_PS1_STATUS; and set action "$action bisect"
        [ -n "$action" ]; and prompt_segment red white "$action"
    end
end

function fish_prompt --description 'Write out the prompt'
    set -g LAST_CMD_RC $status

    __git_ps1_gitdir
    [ -n $GIT_PS1_GITDIR ]; and __git_ps1_vars

    prompt_start
    prompt_host
    prompt_vcs_repo; or prompt_dir
    prompt_end
    echo -n ' '
end
