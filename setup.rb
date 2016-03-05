require_relative 'lib/software_installer'
require_relative 'lib/symlinker'

dotfile_path = ENV['DOTFILES_PATH'] ||= "~/.dotfiles"

# Prefenences on osx need to be done manually too many changes from version to
# version make it a management overhead.

# Brew installation
system("ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\"")

# Brew backed apps
system("brew install wget git qpdf vim")

# Clone Vundle
system('git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim')

#Symlink them all
file_linkers = [
  Symlinker.new('ssh_config',   "#{dotfile_path}/ssh/config",           '~/.ssh'),
  Symlinker.new('git_config',   "#{dotfile_path}/git/gitconfig",        '~/', '.gitconfig'),
  Symlinker.new('git_ignore',   "#{dotfile_path}/git/gitignore_global", '~/', '.gitignore_global'),
  Symlinker.new('bash_rc',      "#{dotfile_path}/bash/bashrc",          '~/', '.bashrc'),
  Symlinker.new('bash_alias',   "#{dotfile_path}/bash/bash_aliases",    '~/', '.bash_aliases'),
  Symlinker.new('bash_profile', "#{dotfile_path}/bash/bash_profile",    '~/', '.bash_profile'),
  Symlinker.new('vimrc',        "#{dotfile_path}/vim/vimrc",            '~/', '.vimrc')
]

#Required Software
Software.new({name: 'Iterm2',         transition: 'zip>app', url: 'https://iterm2.com/downloads/stable/iTerm2-2_1_4.zip'})
Software.new({name: 'Firefox',        transition: 'dmg>app', url: 'https://download-installer.cdn.mozilla.net/pub/firefox/releases/42.0/mac/en-GB/Firefox%2042.0.dmg'})
Software.new({name: 'MacDown',        transition: 'zip>app', url: 'http://macdown.uranusjr.com/download/latest/'})
Software.new({name: 'Dash',           transition: 'zip>app', url: 'https://london.kapeli.com/downloads/v3/Dash.zip'})
Software.new({name: 'Chrome Browser', transition: 'dmg>app', url: 'https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg'})
Software.new({name: 'VLC Player',     transition: 'dmg>app', url: 'http://www.mirrorservice.org/sites/videolan.org/vlc/2.2.1/macosx/vlc-2.2.1.dmg'})
Software.new({name: 'Amazon Music',   transition: 'dmg>app', url: 'https://images-na.ssl-images-amazon.com/images/G/01/digital/music/morpho/installers/20151118/201234b234/AmazonMusicInstaller.dmg'})
Software.new({name: 'VirtualBox',     transition: 'dmg>pkg', url: 'http://download.virtualbox.org/virtualbox/5.0.10/VirtualBox-5.0.10-104061-OSX.dmg'})
Software.new({name: 'Vagrant',        transition: 'dmg>pkg', url: 'https://releases.hashicorp.com/vagrant/1.7.4/vagrant_1.7.4.dmg'})
Software.new({name: 'Google Drive',   transition: 'dmg>app', url: 'https://dl.google.com/drive/installgoogledrive.dmg'})

collection = SoftwareCollection.new
downloader = Downloader.new(collection.to_a)

downloader.download_all
collection.print_status(:download_status)

collection.to_a.each {|software| Installer.install(software) }
collection.print_status(:install_status)

file_linkers.each {|symlinker| symlinker.symlink_it }

puts "Don't forget to run :PluginInstall in vim"

