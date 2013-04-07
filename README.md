parse_bash_history
==================
<pre>
 Author  : Greg Colley
 Date    : 06.04.2013
 Version : 1.3
</pre>

Parsing the .bash_history file and then emailing any commands run from the last time. 

This is usefull if multiple users are using the root login and you wish to keep track of 
what commands are being executed. 

To get a copy of this code you need to pull the git repository you can doe this via the following command.
<pre>
  git clone https://github.com/swooingfish/parse_bash_history.git
</pre>

To update your copy run the following command in the parse_bash_history directory.
<pre>
  git pull
</pre>


Bash History Settings
<pre>
These settings can be set site wide in the /etc/bash.bashrc file
.----------------.----------------------------------------------------------.
|                |                                                          |
| Shell Variable | Description                                              |
|                |                                                          |
'----------------+----------------------------------------------------------'
| HISTFILE       | Controls where the history file gets saved.              |
|                | Set to /dev/null not to save the history.                |
|                | Default: ~/.bash_history                                 |
'----------------+----------------------------------------------------------'
| HISTFILESIZE   | Controls how many history commands to keep in HISTFILE   |
|                | Default: 500                                             |
'----------------+----------------------------------------------------------'
| HISTTIMEFORMAT | Specifies timeformat to be displayed for bash history    |
|                | e.g.  export HISTTIMEFORMAT="%F %T "                     |
'----------------+----------------------------------------------------------'
| HISTSIZE       | Controls how many history commands to keep in the        |
|                | history list of current session.                         |
|                | Default: 500                                             |
'----------------+----------------------------------------------------------'
| HISTIGNORE     | Controls which commands to ignore and not save to the    |
|                | history list. The variable takes a list of               |
|                | colon separated values. Pattern & matches the previous   |
|                | history command.                                         |
'----------------'----------------------------------------------------------'
</pre>
