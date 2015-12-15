class Software
  DOWNLOAD_PATH="#{ENV['HOME']}/Downloads/Download2AutoInstall".freeze

  attr_reader :url
  attr_accessor :download_status, :install_status #Ideally status module but...

  def initialize(attributes = {})
    @name = attributes[:name]
    @transition = attributes[:transition]
    @url = attributes[:url]

    @download_status = 'Pending'
    @install_status  = 'Pending'

    update_max_file_length
    register
  end

  def name
    @name.gsub(' ', '_')
  end

  def original_name
    @name
  end

  def transition
    @transition.to_s
  end

  def transition_from
    transition.split('>').first
  end

  def transition_to
    transition.split('>').last
  end

  def download_file_path
    "#{DOWNLOAD_PATH}/#{name}.#{transition_from}"
  end

  def self.max_file_name_length
    (@@max_file_name_length ||= 0).to_i
  end

  private

  def register
    #Dependency inject it...grhh
    SoftwareCollection.register(self)
  end

  def update_max_file_length
    if self.class.max_file_name_length < self.name.size
      @@max_file_name_length = self.name.size
    end
  end
end

class Downloader
  OSX_USERAGENT='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_0) AppleWebKit/'\
                '601.2.7 (KHTML, like Gecko) Version/9.0.1 Safari/601.2.7'

  attr_reader :softwares

  def initialize(softwares = [])
    @softwares = softwares
    ensure_directory_exists
  end

  def download_all
    puts "Preparing to download #{softwares.size} software package(s)"

    self.softwares.each do |software|
      if File.exist?(software.download_file_path)
        software.download_status = 'File already exists'
      else
        `curl -A "#{OSX_USERAGENT}" -o #{software.download_file_path} -L #{software.url}`
        if $?.success?
          software.download_status = 'Downloaded'
        else
          software.download_status = 'Failed'
        end
      end
    end
  end

  private

  def ensure_directory_exists
    if !Dir.exist?(Software::DOWNLOAD_PATH)
      Dir.mkdir(Software::DOWNLOAD_PATH)
    end
  end
end

class ZipExtractor
  attr_reader :software

  def initialize(software)
    @software = software
  end

  def extract
    `unzip -e #{software.download_file_path} -d #{extraction_dir}`

    if $?.success?
      software.install_status = 'Extracted'
    else
      software.install_status = 'Failed extraction'
    end

    self
  end

  def extraction_dir
    software.download_file_path.gsub(".#{software.transition_from}", '')
  end
end

class DMGMounter
  attr_reader :software

  def initialize(software)
    @software = software
  end

  def mount
    `hdiutil attach #{software.download_file_path} -mountpoint #{mount_point}`

    if $?.success?
      software.install_status = 'Mounted'
    else
      software.install_status = 'Failed to mount'
    end

    self
  end

  def unmount
    `hdiutil detach #{mount_point}`
  end

  def mount_point
    "/Volumes/#{software.name}"
  end
end

class Installer
  attr_reader :software

  def initialize(software)
    @software = software
    return if software.install_status.downcase.include?('failed')
  end

  def self.install(software)
    # Could use inflection... whatever
    case software.transition_to.to_sym
    when :app
      AppInstaller.new(software).install
    when :pkg
      PKGInstaller.new(software).install
    end
  end

  def install_command
    if $?.success?
      software.install_status = 'Installed'
    else
      software.install_status = 'Install failed'
    end
  end
end

class PKGInstaller < Installer
  def install
    case software.transition_from.to_sym
    when :zip
      extractor = ZipExtractor.new(software).extract
      install_command(extractor.extraction_dir )
    when :dmg
      mounter = DMGMounter.new(software).mount
      install_command(mounter.mount_point)
    end
  end

  private

  def install_command(dir)
    `sudo installer -pkg #{dir}/*.pkg -target /`
    super()
  end
end

class AppInstaller < Installer
  def install
    case software.transition_from.to_sym
    when :zip
      extractor = ZipExtractor.new(software).extract
      install_command(extractor.extraction_dir)
    when :dmg
      mounter = DMGMounter.new(software).mount
      install_command(mounter.mount_point)
    end
  end

  private

  def install_command(dir)
    `cp -R #{dir}/*.app /Applications/`
    super()
  end
end

class SoftwareCollection
  def self.register(software)
    packages << software
  end

  def self.packages
    @@packages ||= []
  end

  def print_status(method_call)
    puts "\nSoftware packages #{method_call.to_s.gsub('_', ' ').capitalize};\n"

    to_a.each do |software|
      name   = software.name.to_s
      status = software.send(method_call.to_sym)
      len    = Software.max_file_name_length - name.size + status.to_s.size

      printf("%s: %#{len+5}s\n", name, status)
    end
  end

  def to_a
    self.class.packages || []
  end
end
