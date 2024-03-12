#!/bin/bash
set -euo pipefail

# User configuration scripts, not to be run as root.

# Must be run before git clones below.
# Add saner defaults for github.com based repos.
cat >/home/ubuntu/.ssh/config<<EOF
Host github.com
     StrictHostKeyChecking accept-new
EOF

# Optional: Install SpaceVim
curl -sLf https://spacevim.org/install.sh | bash

# Optional: Install Oh-My-Bash
#bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended
#cp /home/ubuntu/oh-my-bash.bash /home/ubuntu/.bashrc

# Optional: Install Oh-My-Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
cp -f /home/ubuntu/oh-my-zsh.bash /home/ubuntu/.zshrc

# Everything below must be run after the git clones above

mkdir -p /home/ubuntu/bin

git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1

# Generate .gitconfig, modify these as needed.
cat >/home/ubuntu/.gitconfig<<EOF
[user]
  editor = vim
  pager = delta
[gpg]
  format = ssh
[commit]
  gpgSign = true
[tag]
  gpgSign = true
[url "git@github.com:"]
  insteadOf = https://github.com/
[fetch]
  recurseSubmodules = true
[delta]
  line-numbers = true
  side-by-side = true
[submodule]
  recurse = true
[color]
  ui = true
  branch = false
[color "diff-highlight"]
  oldNormal = "red bold"
  oldHighlight = "red bold 52"
  newNormal = "green bold"
  newHighlight = "green bold 22"
[color "diff"]
  meta = "11"
  frag = "magenta bold"
  commit = "yellow bold"
  old = "red bold"
  new = "green bold"
  whitespace = "red reverse"
EOF

# Generate .tigrc, modify these as needed.
cat >/home/ubuntu/.tigrc<<EOF
# tig settings
set main-view-date = custom
set main-view-date-format = "%Y-%m-%d"
set main-view = date:relative author:full commit-title:graph=true,refs=true
set diff-view = line-number:display=false text:commit-title-overflow=true
set diff-options = --pretty=short
set vertical-split = false
set git-colors = no
set truncation-delimiter  = ~   # Character drawn for truncations, or "utf-8"

# General colors
color default                       246         235
color cursor                        223         236
color status                        default     default
color title-focus                   default     default
color title-blur                    default     default
color delimiter                     245         default
color header                        66          default         bold
color section                       172         default
color line-number                   241         default
color id                            124         default
color date                          172         default
color author                        109         default
color mode                          166         default
color overflow                      241         default
color directory                     106         default         bold
color file                          223         default
color file-size                     default     default
color grep.file                     166         default

# Main view colors
color main.cursor                   223            236
color graph-commit                  166         default
color main-head                     166         default         bold
color main-remote                   172         default
color main-tracked                  132         default
color main-tag                      223         default
color main-local-tag                106         default
color main-ref                      72          default

# Status view colors
color status.header                 172         236             bold
color status.section                214         default
color stat-staged                   106         default
color stat-unstaged                 124         default
color stat-untracked                166         default
color stat-none                     default     default

# Help view colors
color help.header                   241         default         bold
color help.section                  166         default
color help.cursor                   72          236
color help-group                    166         default
color help-action                   166         default

# Diff view colors
color "commit "                     default     default
color "Refs: "                      default     default
color "Author: "                    default     default
color "AuthorDate: "                default     default
color "Commit: "                    106         default
color "CommitDate: "                66          default
color "Merge: "                     default     default
color "---"                         167         default
color "+++ "                        142         default
color "--- "                        167         default
color diff-index                    default     default
color diff-stat                     223         default
color diff-add                      142         default
color diff-add-highlight            106         default
color diff-del                      167         default
color diff-del-highlight            223         default
color diff-header                   132         default
color diff-chunk                    109         default
color "diff-tree "                  214         default
color "TaggerDate: "                default     default

# Log view colors
color "Date: "                      72          default

# Signature colors
color "gpg: "                       72          default
color "Primary key fingerprint: "   72          default

# grep view
color grep.file			        	208     	default         bold
color grep.line-number		        241     	default         bold
color grep.delimiter		        241	        default         bold
color delimiter			            142     	default         bold

# lines in digraph
color palette-0		            	166     	default         bold
color palette-1		            	66	        default         bold
color palette-2		            	172	        default         bold
color palette-3		            	132	        default         bold
color palette-4		            	72	        default         bold
color palette-5		            	106	        default         bold
color palette-6		            	124	        default         bold
color palette-7		            	250	        default         bold
# repeat
color palette-8		            	166	        default
color palette-9		            	66	        default
color palette-10	            	172	        default
color palette-11	            	132	        default
color palette-12	            	72	        default
color palette-13	            	106	        default

EOF

