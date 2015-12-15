# Package Mate


## What is it

There are several package handlers out this is just a personal one for managing
new installations of osx.

It doesn't do the osx preferences - as this was a large overhead getting it just
right and then the next release breaking it.

So this just symlinks the dotfiles and also installs software not on the app store

## What to run

```
DOTFILE_PATH=~/.dotfiles
DOWNLOAD_PATH=~/Downloads/package_mate.zip
EXTRACT_ROOT=~/Documents/

mkdir -p $DOTFILE_PATH
curl -Lo $DOWNLOAD_PATH https://bitbucket.org/jnormington/package_mate/get/master.zip
unzip -e $DOWNLOAD_PATH -d $EXTRACT_ROOT

cd $EXTRACT_ROOT/jnormington-package_mate-*
mv ./dotfiles/**/* $DOTFILE_PATH/
ruby ./setup.rb

```

## What should happen
 - Clone the public repo
 - Install brew and some programs
 - Symlink the dotfiles
 - Download and install software in setup


# Use at own risk
THE CONFIGS AND INSTALLERS IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
