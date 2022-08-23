# Script Dump
This is a repository where I dump some handy shell scripts I've made over the years on Linux for various purposes.

These have been created for personal reasons and thus cannot be expected to be properly maintained and I'm only dumping them here to store as a backup, but if anyone actually ends up using them and encounters issues feel free to post an issue or pull request, and I may just update.

# Script List

* autoscroll: System-wide autoscroll functionality (allows you to use autoscroll in a lot of programs that don't support it)
* cpu_limit: Limit the CPU to a set maximum frequency via auto-cpufreq (requires auto-cpufreq to be installed)
* disablemousepaste.sh: Disables middle click paste in Xorg while running.
* fio_crystaldiskmark: An imitation of crystaldiskmark using fio to deliver tests and results in a comparable format.
* fixvsyscall: Enables abi.vsyscall32 if it is disabled (some games need it to be disabled for the anti-cheat to work, this is to fix that after you stop playing.)
* gengvtg.sh: Creates a GVT-G device if it is supported by your iGPU.
* headphonetoggle.sh: Toggles between speakers and headphones (-b to turn both on at once), also auto switches your easyeffects/pulseeffects presets. Does not require pulseaudio or pipewire, but supports it.
* holdmouse: Holds down a mousebutton with xdotool.
* igpu_limit: Limit the iGPU to it's minimum allowed frequency (for powersaving purposes)
* mountiso.sh: Script to mount iso files.
* nocrash.sh: A crash recovery script, it makes a program restart itself if it crashes, supports arguments too.
* nvidia_toggle: Toggle your nvidia gpu on/off on reboot (completely powers the card down, it's meant for laptops for powersaving purposes)
* screencast.sh: Records your screen via ffmpeg and saves it to a file; has a bunch of options.
* spamkey: Spam a keyboard button (X11/xdotool only)
* spammouse: Spam a mouse button (X11/xdotool only)
* spamsxhkd: Generates an sxhkd config file which spams a button when you press a specified modifier + that button. Depends on spamkey and spammouse.
* split-audio.sh: Split an audio file using timestamps.
* split-audio-batch.sh: Accepts a list of timestamps and names then uses the split-audio.sh script to split target audio file into multiple files based on the list. (Intended for use with youtube-dl, e.g. you download an artist's album in one file, then copy the description or a comment that provides timestamps to a file, then use this script to read that file)
* swftohtml: Converts an SWF to HTML file to run in a browser (a bit obsolete considering most browsers no longer support flash, but it was super useful once)
* sysinfo: Prints a whole bunch of system information (an alternative to things like inxi)
* timer-lite.sh: A countdown timer using sleep commands (There may be some drift over long time periods, but I reduced the sleep time in an attempt to trivialise it)
* timer.sh: A countdown timer that synchronizes with the system clock to ensure there is no perceivable time drift.
* touchpad_toggle_x11: Toggles the touchpad on & off (x11 only)
* turbo_boost: A script that allows you to set intel turbo boost on or off (requires root, i suggest moving it to /usr/local/bin/)
* vcompress.sh: Compress a video file using ffmpeg, many options which give different quality/size/speed.
* wasdtoarrow-toggle: Rebinds WASD to be the same as the arrow keys, and binds 1-4 to ASDW (useful for certain video games that do not allow you to change keybinds).
* webcamtoggle.sh: Toggles webcam on & off by disabling/enabling the kernel module for it.
