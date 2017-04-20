# worKDir

function kd
  set conf "$HOME/.kdrc"

  # return to project base folder
  if [ (count $argv) = 0 ]
    set candidate "$PWD"
    while [ -n "$candidate" ]
      for file in Gemfile Procfile
        if [ -f "$candidate/$file" ]
          cd "$candidate"
          return $status
        end
      end
      if [ "$candidate" = '/' ]
        return 1
      end
      set candidate (dirname $candidate)
    end
    return 1
  end

  # go to bookmarked folder
  if [ (count $argv) = 1 ]
    set target (grep -e "^$argv[1]" "$conf" | awk '{ print $2 }' | tail -1)
    if [ -n "$target" ]
      cd "$target"
      return $status
    end
    return 1
  end

  # bookmark specified folder
  if [ (count $argv) = 2 ]
    set name "$argv[1]"
    if [ -d "$argv[2]" ]
      set target (cd "$argv[2]"; pwd)
      if [ -n "$target" ]
        sed -i -e "/^$name/d" "$conf"
        echo "$name" "$target" >> "$conf"
      end
    end
    return 1
  end
end

# vim: ft=fish
