require "cask/caskroom"

$paths_being_used = Set.new

class Uninstaller < Cask::Artifact::AbstractUninstall
  def scan_trash_paths
    # puts @cask.to_h
    # puts @cask.installed?
    # puts Array(@directives[:trash])

    each_resolved_path(:trash, Array(@directives[:trash])) do |path, resolved_paths|
      if $paths_being_used.include? path
        puts "Skipped path being used: #{path}"
      else
        resolved_paths.each do | resolved_path|
          ohai "Found #{resolved_path} used by #{Formatter.identifier(@cask.token)} (#{resolved_path.abv})"
        end
      end
    end
  end
end

def get_cask_stanzas(cask)
  cask.artifacts.select { |a| a.is_a?(Cask::Artifact::Zap) }
end

def get_cask_trash_paths(cask)
  nested_paths = get_cask_stanzas(cask).map do |stanza|
    stanza.directives[:trash]
  end

  return nested_paths.flatten
end

def scan_cask(cask)
  if cask.installed?
    puts "Skipped installed cask #{cask.token}"
    return
  else
    puts "Searching #{cask.token} ..."
  end

  begin
    get_cask_stanzas(cask).each do |stanza|
      Uninstaller.from_args(cask, stanza.directives).scan_trash_paths
    end
  rescue Exception => e
    # puts 'Exception', e
  end
end

Cask::Caskroom.casks.each do |cask|
  $paths_being_used.merge(get_cask_trash_paths(cask))
end

puts "#{Cask::Cask.all.length} casks to scan ..."

Cask::Cask.all.each do |cask|
  scan_cask cask
end
