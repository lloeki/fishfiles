function prompt_start
    set -g CURRENT_BG 'NONE'
end

function prompt_segment --description "start a new segment"
    if [ -z $RPROMPT_SEGMENT ]
        lprompt_segment $argv
    else
        rprompt_segment $argv
    end
end

function prompt_subsegment --description "start a new subsegment"
    set -l sep

    if [ -z $RPROMPT_SEGMENT ]
        set sep $SUBSEGMENT_SEPARATOR
    else
        set sep $RSUBSEGMENT_SEPARATOR
    end

    echo -n " $sep "
    [ -n $1 ]; and echo -n $argv[1]
end

function lprompt_segment --description "start a new left prompt segment"
    set -l bg
    set -l fg

    if [ -n $argv[1] ]
        set bg $argv[1]
    else
        set bg 'normal'
    end

    if [ -n $argv[2] ]
        set fg $argv[2]
    else
        set fg 'normal'
    end

    if [ $CURRENT_BG != 'NONE' -a $argv[1] != $CURRENT_BG ]
        echo -n " "
        set_color -b $bg
        set_color $CURRENT_BG
        echo -n "$SEGMENT_SEPARATOR"
        set_color $fg
        echo -n " "
    else
        set_color -b $bg
        set_color $fg
        echo -n " "
    end

    set CURRENT_BG $argv[1]
    [ -n $argv[3] ]; and echo -n $argv[3]
end

function prompt_end --description "End the prompt, closing any open segments"
    if [ -n $CURRENT_BG ]
        echo -n ' '
        set_color $CURRENT_BG
        echo -n "$SEGMENT_SEPARATOR"
    else
        set_color -b normal
    end
    set_color normal
    set CURRENT_BG ''
end

function rprompt_start
    set -g RPROMPT_SEGMENT 1
end

function rprompt_segment
    set -l bg
    set -l fg

    if [ -n $argv[1] ]
        set bg $argv[1]
    else
        set bg 'normal'
    end

    if [ -n $argv[2] ]
        set fg $argv[2]
    else
        set fg 'normal'
    end

    if [ $CURRENT_BG != '' -a $argv[1] != $CURRENT_BG ]
        echo -n ' '
        set_color -b $CURRENT_BG
        set_color $bg
        echo -n "$RSEGMENT_SEPARATOR"
        set_color -b $bg
        set_color $fg
        echo -n ' '
    else
        set_color -b $bg
        set_color $fg
        echo -n ' '
    end

    set CURRENT_BG $argv[1]
    [ -n $3 ]; and echo -n $argv[3]
end

function rprompt_end
    echo -n ' '
    set_color -b normal
    set_color normal
    set CURRENT_BG ''
    set -e RPROMPT_SEGMENT
end
