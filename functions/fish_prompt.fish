function fish_prompt --description 'Write out the prompt'
    # HACK: prevent cursor/line flash on col 0
    #sleep 0.0000001

    # Just calculate these once, to save a few cycles when displaying the prompt
    if not set -q __fish_prompt_hostname
        set -g __fish_prompt_hostname (hostname | cut -d . -f 1)
    end

    if not set -q __fish_prompt_normal
        set -g __fish_prompt_normal (set_color normal)
    end

    if not set -q __fish_prompt_cwd
        set -g __fish_prompt_cwd (set_color $fish_color_cwd)
    end
    
    if not set -q __fish_prompt_user_host
        set -g __fish_prompt_user_host (set_color blue)'['(set_color normal)"$USER"@"$__fish_prompt_hostname"(set_color blue)']'(set_color normal) 
    end

    if not set -q __fish_prompt_mark
        set -g __fish_prompt_mark '$'
    end

    echo -n -s $__fish_prompt_user_host $__fish_prompt_mark ' '
end
