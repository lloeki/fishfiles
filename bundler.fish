set -l bundled_commands annotate cap capify cucumber foreman guard heroku nanoc rackup rainbows rake rspec ruby shotgun spec spork thin unicorn irb pry

function __bundler_installed
    which bundle > /dev/null 2>&1
end

function __bundler_within_bundle
  set -l check_dir $PWD
  set -l next_check_dir (dirname $check_dir)

  while [ "$next_check_dir" != "/" ]
    [ -f "$check_dir/Gemfile" ]; and return
    set -l check_dir "$next_check_dir"
    set -l next_check_dir (dirname $check_dir)
  end

  false
end

function __bundler_try_exec
    if begin; __bundler_installed; and __bundler_within_bundle; end
        bundle exec $argv
    else
        eval command $argv
    end
end

for cmd in $bundled_commands
    eval "function bundled_$cmd; __bundler_try_exec $cmd \$argv; end"
    eval "function $cmd; bundled_$cmd \$argv; end"
end
