# Shared Scripts

Scripts that people might want. Or not.

## On path
### Git stuffs
A bunch of scripts for manipulating multiple git repos.  
Expects a file in the git repos parent directory called `repos`.  
This file can be generated by `make_repo_file`.
Currently most scripts use `repos` to work out which directories to work on.

Going to use flogging org as an example. So the flow is:
#### One shot
```bash
mkdir flogging
cd flogging
#Checkout your flogging repos into this directory...
make_repo_file
```
Edit repos to contain the directories you commonly work on in `repos`, or leave as is for _all_ repos.  
Note it won't update as repos are added.
#### Workflow
Change to branch mybranch in all repos.  
```bash
repodo 'git checkout -b mybranch'
```
Make some changes in a repo.
What's the status ?  
```bash
statuses
```  
Rebase from remote master.  
```bash
rebase_from_master
```
Keep developing.  
Test.  
```bash
testall
```
Push every single branch upstream:  
```bash
repodo 'git push origin HEAD:mybranch --set-upstream'
```
Back to master and remove the branch:
```bash
repodo 'git checkout master; git branch -D mybranch' 
```
Make sure you're back up to date:  
```bash
rebase_from_master
```

Profit.  

### tmux
Given a collection of directories under an optional top level directory with an optional name prefix,
run a command (relative to each directory or global) in each directory in a separate tmux pane.
e.g.
```bash
mkdir -p somedir/someprefix-project1
echo '#!/usr/bin/env sh' >somedir/someprefix-project1/somescript
echo 'pwd' >>somedir/someprefix-project1/somescript
echo '#!/usr/bin/env sh' >somedir/someprefix-project2/somescript
echo 'Project 2 !' >>somedir/someprefix-project2/somescript
echo 'pwd' >>somedir/someprefix-project2/somescript
chmod 755 somedir/someprefix-project1/somescript
chmod 755 somedir/someprefix-project2/somescript

# Run './somescript' in somedir/someprefix-project1 and somedir/someprefix-project2 in separate tmux panes.
# Ctrl+C <wait for processes to end>, Enter to exit...
command='./somescript' dir_prefix='somedir/someprefix-' tmux_command project1 project2

# Same as above but just show command in pane rather than executing it
dry_run=1 command='./somescript' dir_prefix='somedir/myprefix-' tmux_command project1 project2
```

## [testing](testing)


