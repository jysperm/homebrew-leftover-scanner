require "cask/caskroom"

class Uninstaller < Cask::Artifact::AbstractUninstall
  def scan_paths(paths)
    result = []

    each_resolved_path(:scan, paths) do |path, resolved_paths|
      if $paths_being_used.include? path
        odebug "Skipped path being used: #{path}"
      else
        result.push(*resolved_paths)
      end
    end

    result
  end
end

def get_all_casks
  Tap.default_cask_tap.cask_files.map do |f|
    Cask::CaskLoader::FromTapPathLoader.new(f).load(config: nil)
  rescue Cask::CaskUnreadableError => e
    opoo e.message

    nil
  end.compact
end

def cask_artifacts_exists?(cask)
  app_artifacts = cask.artifacts.select { |a| a.is_a?(Cask::Artifact::App) }

  app_artifacts.map do |app_artifact|
    if Cask::Utils.path_occupied?(app_artifact.target)
      odebug "#{app_artifact.target} from #{Formatter.identifier(cask.token)} exists"
      return true
    end
  end

  return false
end

def get_cask_uninstall_paths(cask, type)
  uninstall_paths = []

  stanzas = cask.artifacts.select do |a|
    a.is_a?(Cask::Artifact::Zap) or a.is_a?(Cask::Artifact::Uninstall)
  end

  stanzas.each do |stanza|
    uninstall_paths.push *stanza.directives[type]
  end

  return uninstall_paths
end

def scan_cask(cask)
  if cask.artifacts.find { |a| a.is_a?(Cask::Artifact::App) }
    odebug "Searching #{cask.token} ..."

    begin
      delete_paths = Uninstaller.from_args(cask).scan_paths get_cask_uninstall_paths cask, :delete
      trash_paths = Uninstaller.from_args(cask).scan_paths get_cask_uninstall_paths cask, :trash

      if delete_paths.length + trash_paths.length > 0
        ohai "Found leftovers from #{Formatter.identifier(cask.token)}, get rid of them via: #{Formatter.identifier("brew uninstall -f --zap #{cask.token}")}"
        puts delete_paths.map { |path| "#{path} (delete #{path.abv})" }
        puts trash_paths.map { |path| "#{path} (trash #{path.abv})" }
      end
    rescue Exception => e
      ofail e
    end
  else
    odebug "Skipped #{cask} because no app artifact in cask"
  end
end

$all_casks = get_all_casks

$casks_installed = Set.new
$paths_being_used = Set.new

ohai "#{$all_casks.length} casks to scan ..."

def scan_install_casks
  cask_installed = Set.new
  cask_artifacts_exists = Set.new

  $all_casks.each do |cask|
    if cask.installed?
      cask_installed.add(cask.token)
      $paths_being_used.merge(get_cask_uninstall_paths(cask, :delete))
      $paths_being_used.merge(get_cask_uninstall_paths(cask, :trash))
    elsif cask_artifacts_exists?(cask)
      cask_artifacts_exists.add(cask.token)
      $paths_being_used.merge(get_cask_uninstall_paths(cask, :delete))
      $paths_being_used.merge(get_cask_uninstall_paths(cask, :trash))
    end
  end

  ohai "Installed from cask:"
  puts cask_installed.to_a.join ', '
  ohai "Installed from other ways:"
  puts cask_artifacts_exists.to_a.join ', '
end

scan_install_casks

$all_casks.each do |cask|
  scan_cask cask
end
