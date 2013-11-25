function fish_right_prompt --description 'Write out the right prompt'
    echo -n -s "$__fish_prompt_cwd" (prompt_pwd) "$__fish_prompt_normal"
end
