function fish_right_prompt --description 'Write out the right prompt'
    rprompt_start
    prompt_vcs_status
    prompt_vcs_action
    prompt_last_rc
    rprompt_end
end
