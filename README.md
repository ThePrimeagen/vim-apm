### Vim APM

Vim apm keeps track of your APM by counting keystrokes and determining
its worth. You will get both your stroke count / time and your score / time.
The score is based on how frequently you type the same command in normal mode,
whereas insert there is only score. Normal mode only keeps track of the last
10 strokes so you are not penalized too heavily

### Example

[Example Video](https://clips.twitch.tv/TenuousCarefulStorkDansGame)

### Getting Started

0.  You must use a master build of NeoVim. The latest master has everything
    that you need.

1.  Use your favorite plugin manager.

```
Plug "ThePrimeagen/vim-apm"
```

2. Execute :VimApm. If you use Ctrl-w o to shut other buffers, you can bring
   back the menu by re-executing :VimApm

3. Execute :VimApmShutdown to stop calculating.

4. Check out your timings csv file at ~/apm.csv

### Values and Meaning

you will see 3 values, n:, i:, and t:. n = normal mode, i = insert, t = total.

There are two numbers Score / Strokes. Score is determined by how repetitive the
last 10 commands are in normal mode, not applicable to insert mode. So an
ideal score would be ~1 ratio for normal mode.

### Enjoy

Made with love, live on [Twitch](https://twitch.tv/ThePrimeagen). Thank you TJ
for all your help
