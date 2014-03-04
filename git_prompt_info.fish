# Port of git_prompt_info for bash and zsh
#
# Usage:
#
# function fish_prompt
#     ...
#     __git_ps1_gitdir  # ideally only called when cwd changes
#     [ -n $GIT_PS1_GITDIR ]; and __git_ps1_vars  # sets vars only if git
#     ...
#
#     if [ -n $GIT_PS1_STATUS ]
#       # set your prompt as you wish according to GIT_PS1_*
#       # see available vars and values at the very end
#       #
#       # examples:
#       echo " ⎇$GIT_PS1_BRANCH "
#       contains t $GIT_PS1_STATUS; and echo "!"
#       contains s $GIT_PS1_STATUS; and echo "±"
#       contains u $GIT_PS1_STATUS; and echo "≠"
#       contains n $GIT_PS1_STATUS; and echo "∅"
#       contains h $GIT_PS1_STATUS; and echo "↰"
#     end
# end


function __gitdir --description "get a folder's git dir (defaults to current)"
    if [ -z "$argv" ]
        if [ -n "$__git_dir" ]
            echo "$__git_dir"
        else if [ -d .git ]
            echo .git
        else
            git rev-parse --git-dir 2>/dev/null
        end
    else if [ -d "$argv[1]/.git" ]
        echo "$argv[1]/.git"
    else
        echo "$argv[1]"
    end
end

function __git_ps1_rebase_merge_head --description 'find head being merged'
    cat "{$argv[1]}/rebase-merge/head-name"
end

function __git_ps1_describe --description "describe according to GIT_PS1_DESCRIBE_STYLE"
    switch "$GIT_PS1_DESCRIBE_STYLE"
        case contains
            git describe --contains HEAD
        case branch
            git describe --contains --all HEAD
        case describe
            git describe HEAD
        case '*' default
            git describe --exact-match HEAD
    end 2>/dev/null
end

# branch name
function __git_ps1_branch --description "get current branch or ref"
    set -l branch (git symbolic-ref HEAD 2>/dev/null | sed 's#^refs/heads/##'); or \
    set -l branch (__git_ps1_describe | sed 's#^refs/heads/##'); or \
    set -l branch (git rev-parse --short HEAD | sed 's#^refs/heads/##'); or \
    set -l branch unknown

    echo $branch
end

function __git_ps1_gitdir --description "set GIT_PS1_GITDIR to __gitdir"
    set -l g (__gitdir)

    # are we in a git repo?
    if [ -z "$g" ]
        set -e GIT_PS1_GITDIR
    else
        set -g GIT_PS1_GITDIR "$g"
    end
end

function __git_ps1_vars --description "compute git status and set environment variables"
    set -l g "$GIT_PS1_GITDIR"

    if [ -z "$g" ]
        set -e GIT_PS1_STATUS
        set -e GIT_PS1_BRANCH
        set -e GIT_PS1_SUBJECT
        set -e GIT_PS1_TOPLEVEL
        set -e GIT_PS1_NAME
        set -e GIT_PS1_PREFIX
        return
    end

    set -l rebase 0
    set -l interactive 0
    set -l apply 0
    set -l merge 0
    set -l bisect 0
    set -l subject ""
    set -l branch ""
    set -l gitdir 0
    set -l bare 0
    set -l work 0
    set -l staged 0
    set -l unstaged 0
    set -l new 0
    set -l untracked 0
    set -l stashed 0

    set -l toplevel ""
    set -l prefix ""
    set -l name ""

    # assess position in repository
    [ "true" = (git rev-parse --is-inside-git-dir 2>/dev/null) ]; and set gitdir 1
    [ "$gitdir" -eq 1 -a "true" = (git rev-parse --is-bare-repository  2>/dev/null) ]; and set bare 1
    [ "$gitdir" -eq 0 -a "true" = (git rev-parse --is-inside-work-tree 2>/dev/null) ]; and set work 1

    # gitdir corner case
    if [ "$g" = '.' ]
        if [ "(basename "$PWD")" = ".git" ]
            # inside .git: not a bare repository!
            # weird: --is-bare-repository returns true regardless
            set bare 0
            set g "$PWD"
        else
            # really a bare repository
            set bare 1
            set g "$PWD"
        end
    end

    # make relative path absolute
    [ (echo "$g" | sed 's#^/##') = "$g" ]; and set g "$PWD/$g"
    set g (echo "$g" | sed 's#/\$##')

    # find base dir (toplevel)
    [ "$bare" -eq 1 ]; and set toplevel "$g"
    [ "$bare" -eq 0 ]; and set toplevel (dirname "$g")

    # find relative path within toplevel
    set prefix (echo "$PWD" | sed "s#^$toplevel##")
    set prefix (echo "$prefix" | sed 's#^/##')
    [ -z "$prefix" ]; and set prefix '.' # toplevel == prefix

    # get the current branch, or whatever describes HEAD
    set branch (__git_ps1_branch)

    # get name
    set name (basename "$toplevel")

    # evaluate action
    if [ -d "$g/rebase-merge" ]
        set rebase 1
        set merge 1
        set subject (__git_ps1_rebase_merge_head)
    end
    if [ $rebase -eq 1 -a -f "$g/rebase-merge/interactive" ]
        set interactive 1
        set merge 0
    end
    if [ -d "$g/rebase-apply" ]
        set rebase 1
        set apply 1
    end
    [ $apply  -eq 1 -a -f "$g/rebase-apply/applying" ]; and set rebase 0
    [ $apply  -eq 1 -a -f "$g/rebase-apply/rebasing" ]; and set apply 0
    [ $rebase -eq 0 -a -f "$g/MERGE_HEAD" ]; and set merge 1
    [ $rebase -eq 0 -a -f "$g/BISECT_LOG" ]; and set bisect 1

    # working directory status
    if [ $work -eq 1 ]
        ## dirtiness, if config allows it
        if [  -n "$GIT_PS1_SHOWDIRTYSTATE" ]
            # unstaged files
            git diff --no-ext-diff --ignore-submodules --quiet --exit-code; or set unstaged 1

            if git rev-parse --quiet --verify HEAD >/dev/null
                # staged files
                git diff-index --cached --quiet --ignore-submodules HEAD --; or set staged 1
            else
                # no current commit, we're a freshly init'd repo
                set new 1
            end
        end

        ## stash status
        if [ -n "$GIT_PS1_SHOWSTASHSTATE" ]
            git rev-parse --verify refs/stash >/dev/null 2>&1; and set stashed 1
        end

        ## untracked files
        if [ -n "$GIT_PS1_SHOWUNTRACKEDFILES" ]
            set -l untracked_files (git ls-files --others --exclude-standard)
            [ -n "$untracked_files" ]; and set untracked 1
        end
    end

    # built environment variables
    set -g GIT_PS1_STATUS ""
    [ $rebase      -eq 1 ]; and set GIT_PS1_STATUS $GIT_PS1_STATUS "R"
    [ $interactive -eq 1 ]; and set GIT_PS1_STATUS $GIT_PS1_STATUS "i"
    [ $apply       -eq 1 ]; and set GIT_PS1_STATUS $GIT_PS1_STATUS "A"
    [ $merge       -eq 1 ]; and set GIT_PS1_STATUS $GIT_PS1_STATUS "M"
    [ $bisect      -eq 1 ]; and set GIT_PS1_STATUS $GIT_PS1_STATUS "B"
    [ $gitdir      -eq 1 ]; and set GIT_PS1_STATUS $GIT_PS1_STATUS "g"
    [ $bare        -eq 1 ]; and set GIT_PS1_STATUS $GIT_PS1_STATUS "b"
    [ $work        -eq 1 ]; and set GIT_PS1_STATUS $GIT_PS1_STATUS "w"
    [ $staged      -eq 1 ]; and set GIT_PS1_STATUS $GIT_PS1_STATUS "s"
    [ $unstaged    -eq 1 ]; and set GIT_PS1_STATUS $GIT_PS1_STATUS "u"
    [ $new         -eq 1 ]; and set GIT_PS1_STATUS $GIT_PS1_STATUS "n"
    [ $untracked   -eq 1 ]; and set GIT_PS1_STATUS $GIT_PS1_STATUS "t"
    [ $stashed     -eq 1 ]; and set GIT_PS1_STATUS $GIT_PS1_STATUS "h"
    set -g GIT_PS1_BRANCH "$branch"
    set -g GIT_PS1_SUBJECT "$subject"
    set -g GIT_PS1_TOPLEVEL "$toplevel"
    set -g GIT_PS1_NAME "$name"
    set -g GIT_PS1_PREFIX "$prefix"
end
