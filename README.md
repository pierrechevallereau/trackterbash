# trackterbash
 

trackterbash is a bash library designed to trap/tag/color errors and stop smoothly the main process. 

By default,
  - errors are surrounded with red color
  - the main process is stopped on error
  - the ctrl+c maccro is trapped and you can do something on occur

### Available options :

```
🌵 ./trackterbash --help
--no-exit                 : don't stop the main process on error
--exit-function='_exit'   : change exit function when --no-exit is not used
    Extra doc {
      With --exit-function=* option, you can use your own exit function to properly exit when an error occur,
      to limit errors, please set up your own function before source trackterbash.sh 

      Use cases:
        - you have created a temp file and you want to delete it before exit
        - you use a ssh tunnel and you want to kill it before exit
      
      Default function :
      _exit()
      {
        sleep 0.15 # little sleep time to prevent disordered log
        echo 'Exit due to an error'
        exit 1
      }

    }
--no-ctrlc                : don't trap ctrl+c SIGINT
--ctrlc-function='_ctrlc' : change ctrl+c function when --no-ctrlc is not used
    Extra doc {
      With --ctrlc-function=* option, you can use your own function to properly exit when Ctrl+C occur,
      to limit errors, please set up your own function before source trackterbash.sh 

      Use cases:
        - you have created a temp file and you want to delete it before exit
        - you use a ssh tunnel and you want to kill it before exit
      
      Default function :
      _ctrlc()
      {
        sleep 0.15 # little sleep time to prevent disordered log
        echo -e '\nExit due to a Ctrl+C'
        exit 2
      }

    }
--prefix-all              : preffix all output from FD 1&2 with 'date hour script-name'
--no-surround-errors      : don't surround errors with red color
--debug|-d|--verbose|-v   : enable debug mode with set -x
--help|-h                 : print help
```

### Embedded functions [ ▸ this is clickable ]

<details>
<summary><code>_exit</code> to stop the main script when an error is trapped</summary>

```
_exit()
{
  sleep 0.15 # little sleep time to prevent disordered log
  echo 'Exit due to an error'
  exit 1
}
```

</details>

<details>
<summary><code>_ctrlc</code> to trap Ctrl+C maccro and do something if occur</summary>

```
_ctrlc()
{
  sleep 0.15 # little sleep time to prevent disordered log
  echo -e '\nExit due to a Ctrl+C'
  exit 2
}
```

</details>


<details>
<summary><code>_logerr</code> give you the possibility to log something in FD2, this stop the main process if <code>--no-exit</code> isn't use</summary>

```
_logerr()
{
  echo "${@}" >&2
  sleep 0.15 # little sleep time to prevent disordered log
  return 1 # log and return 1 for exit with trap
}
```

</details>

### How to use :

Source trackterbash.sh in your own script :

```
source "${PATH}"/trackterbash.sh # put options here if needed
```

### Example : 

![howtouse.gif](.gif/howtouse.gif)

### Exit codes :

- 1 : error code when error occur
- 2 : error code when a Ctrl+C occur
