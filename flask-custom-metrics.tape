# VHS documentation
#
# Output:
#   Output <path>.gif               Create a GIF output at the given <path>
#   Output <path>.mp4               Create an MP4 output at the given <path>
#   Output <path>.webm              Create a WebM output at the given <path>
#
# Require:
#   Require <string>                Ensure a program is on the $PATH to proceed
#
# Settings:
#   Set FontSize <number>           Set the font size of the terminal
#   Set FontFamily <string>         Set the font family of the terminal
#   Set Height <number>             Set the height of the terminal
#   Set Width <number>              Set the width of the terminal
#   Set LetterSpacing <float>       Set the font letter spacing (tracking)
#   Set LineHeight <float>          Set the font line height
#   Set LoopOffset <float>%         Set the starting frame offset for the GIF loop
#   Set Theme <json|string>         Set the theme of the terminal
#   Set Padding <number>            Set the padding of the terminal
#   Set Framerate <number>          Set the framerate of the recording
#   Set PlaybackSpeed <float>       Set the playback speed of the recording
#   Set MarginFill <file|#000000>   Set the file or color the margin will be filled with.
#   Set Margin <number>             Set the size of the margin. Has no effect if MarginFill isn't set.
#   Set BorderRadius <number>       Set terminal border radius, in pixels.
#   Set WindowBar <string>          Set window bar type. (one of: Rings, RingsRight, Colorful, ColorfulRight)
#   Set WindowBarSize <number>      Set window bar size, in pixels. Default is 40.
#   Set TypingSpeed <time>          Set the typing speed of the terminal. Default is 50ms.
#
# Sleep:
#   Sleep <time>                    Sleep for a set amount of <time> in seconds
#
# Type:
#   Type[@<time>] "<characters>"    Type <characters> into the terminal with a
#                                   <time> delay between each character
#
# Keys:
#   Escape[@<time>] [number]        Press the Escape key
#   Backspace[@<time>] [number]     Press the Backspace key
#   Delete[@<time>] [number]        Press the Delete key
#   Insert[@<time>] [number]        Press the Insert key
#   Down[@<time>] [number]          Press the Down key
#   Enter[@<time>] [number]         Press the Enter key
#   Space[@<time>] [number]         Press the Space key
#   Tab[@<time>] [number]           Press the Tab key
#   Left[@<time>] [number]          Press the Left Arrow key
#   Right[@<time>] [number]         Press the Right Arrow key
#   Up[@<time>] [number]            Press the Up Arrow key
#   Down[@<time>] [number]          Press the Down Arrow key
#   PageUp[@<time>] [number]        Press the Page Up key
#   PageDown[@<time>] [number]      Press the Page Down key
#   Ctrl+<key>                      Press the Control key + <key> (e.g. Ctrl+C)
#
# Display:
#   Hide                            Hide the subsequent commands from the output
#   Show                            Show the subsequent commands in the output

Output ./flask_custom_metrics.mp4
# Output ./flask_custom_metrics.txt

Require echo

Set Shell "bash"
Set FontSize 22
Set Width 1200
Set Height 750
Set Padding 0
Set TypingSpeed 30ms

Source ./utils-create-charm-dev.tape
Source ./utils-shell-charm-dev.tape
Source ./utils-prepare-charm-dev.tape

Type "juju add-model demo"  Sleep 500ms  Enter
Hide Wait /ubuntu@charm-dev:~\$/ Show
Sleep 5s

# Deploy COS in the demo model.
# A better option is to deploy in another model, but his is easier.
Type `juju deploy cos-lite --trust`  Sleep 500ms  Enter
Hide Wait@180s /ubuntu@charm-dev:~\$/ Show
Sleep 5s

Type `git clone https://github.com/javierdelapuente/12-factor-examples.git`  Sleep 500ms  Enter
Hide Wait /ubuntu@charm-dev:~/ Show
Sleep 5s

Type `cd 12-factor-examples/flask-custom-metrics`  Sleep 500ms  Enter
# \x{2F} = /. No way to escape it. See https://github.com/charmbracelet/vhs/issues/592
Hide Wait /ubuntu@charm-dev:~\x{2F}12-factor-examples\x{2F}flask-custom-metrics\$/ Show
Sleep 5s

Type `rockcraft init --profile flask-framework`  Sleep 500ms  Enter
Hide Wait /ubuntu@charm-dev:~/ Show
Sleep 5s

Type `rockcraft pack`  Sleep 500ms  Enter
Hide Wait@900 /ubuntu@charm-dev:~/ Show
Sleep 5s


Type `rockcraft.skopeo --insecure-policy copy --dest-tls-verify=false oci-archive:flask-custom-metrics_0.1_$(dpkg --print-architecture).rock docker://localhost:32000/flask-custom-metrics:0.1`  Sleep 500ms  Enter
Hide Wait@120 /ubuntu@charm-dev:~/ Show
Sleep 5s

Type `cd charm`  Sleep 500ms  Enter
Hide Wait /ubuntu@charm-dev:~/ Show
Sleep 5s

# Force because we have the cos dir in here.
Type `charmcraft init --profile flask-framework --name flask-custom-metrics --force`  Sleep 500ms  Enter
Hide Wait /ubuntu@charm-dev:~/ Show
Sleep 5s

# vi in action...
Type "vi src/charm.py" Sleep 2000ms  Enter
Type "gg" Sleep 50ms
Type ":set paste" Sleep 100ms Enter
Type "/import" Enter Sleep 50ms
Type "o"
Type "import pathlib" Sleep 50ms
Escape Sleep 50ms
Type "/__main__" Enter Sleep 50ms
Type "O"
Type `    def get_cos_dir(self) -> str:` Enter
Type `        """Return the directory with COS related files.` Enter
Enter
Type `        Returns:` Enter
Type `            Return the directory with COS related files.` Enter
Type `        """` Enter
Type `        return str(pathlib.Path(__file__).parent.parent.absolute())` Enter
Enter
Escape Sleep 50ms
Sleep 10s
Type ":wq" Sleep 500ms  Enter
Sleep 500ms

Type `charmcraft pack`  Sleep 500ms  Enter
Hide Wait@900 /ubuntu@charm-dev:~/ Show
Sleep 5s

Type `juju deploy ./flask-custom-metrics_ubuntu-22.04-amd64.charm --resource flask-app-image=localhost:32000/flask-custom-metrics:0.1` Sleep 500ms Enter
Hide Wait@60 /ubuntu@charm-dev:~/ Show
Sleep 10s


Type `juju integrate traefik flask-custom-metrics` Sleep 500ms Enter
Type `juju integrate grafana flask-custom-metrics` Sleep 500ms Enter
Type `juju integrate loki flask-custom-metrics` Sleep 500ms Enter
Type `juju integrate prometheus flask-custom-metrics` Sleep 500ms Enter
Hide Wait /ubuntu@charm-dev:~/ Show
Sleep 10s

Type `juju wait-for application flask-custom-metrics 2> /dev/null` Sleep 500ms Enter
Hide Wait@360s /ubuntu@charm-dev:~/ Show
Sleep 5s

Type `juju status` Sleep 500ms Enter
Hide Wait /ubuntu@charm-dev:~/ Show
Sleep 10s

Type `juju run grafana/0 get-admin-password --format json | jq -r '."grafana/0".results."admin-password"'` Sleep 500ms Enter
Sleep 10s


Type `juju run grafana/0 get-admin-password --format json | jq -r '."grafana/0".results."url"'` Sleep 500ms Enter
Sleep 10s


Type `juju run traefik/0 show-proxied-endpoints --format=json | jq -r '."traefik/0".results."proxied-endpoints"'  | jq -r  '."flask-custom-metrics".url'` Sleep 500ms Enter
Hide Wait+Screen@20s /http/ Show
Sleep 10s


Type `FLASK_URL=$(juju run traefik/0 show-proxied-endpoints --format=json | jq -r '."traefik/0".results."proxied-endpoints"'  | jq -r  '."flask-custom-metrics".url')` Sleep 500ms Enter


Hide Type `set -x` Enter Show
Type `curl "${FLASK_URL}"` Sleep 500ms Enter
Sleep 5s
Hide Type `set +x` Enter Show


# juju refresh flask-custom-metrics --path ./flask-custom-metrics_ubuntu-22.04-amd64.charm --resource flask-app-image=localhost:32000/flask-custom-metrics:0.1
# juju destroy-model  --no-prompt --destroy-storage --no-wait --force demo
