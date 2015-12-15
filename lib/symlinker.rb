class Symlinker
  attr_reader :name, :dotfile, :target_path, :target_file_name

  def initialize(name, dotfile, target_path, target_file_name=nil)
    @name = name
    @dotfile = dotfile
    @target_path = target_path
    @target_file_name = target_file_name
  end

  def symlink_it
    res_a = ensure_child_paths_exist
    res_b = symlink_file

    #Check results and echo outcome
    if res_a && res_b
      puts "Symlinked #{name}"
    else
      puts "Symlink #{name} failed (#{res_a} && #{res_b})"
    end
  end

  def ensure_child_paths_exist
    `mkdir -p #{target_path}`
    $?.success?
  end

  def symlink_file
    cmd = "ln -sf #{dotfile} #{target_path}"

    if target_file_name
      `#{cmd}/#{target_file_name}`
    else
      `#{cmd}`
    end

    $?.success?
  end
end
