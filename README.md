# music.hackspace

## installing SuperCollider

### Windows

#### Downloading

[Click here](https://github.com/supercollider/supercollider/releases/download/Version-3.11.2/SuperCollider-3.11.2-Windows-32bit-VS.exe) to download the latest Windows release. This is the *32-bit* release, rather than the 64-bit release, because [the most recent Windows Update prevents the 64-bit version from starting](https://github.com/supercollider/supercollider/issues/4368#issuecomment-832050665). But it will work just fine.

Then [click here](https://github.com/supercollider/sc3-plugins/releases/download/Version-3.11.1/sc3-plugins-3.11.1-Windows-32bit-VS.zip) to download the 32-bit sc3-plugins. Unzip these plugins and then copy and paste the `SC3plugins` folder into the following folder:

```
C:\Users\<yourname>\AppData\Local\SuperCollider\Extensions\
```

#### Zoom sharing

Share your screen, select the SuperCollider window, and then below click on the carrot symbol next to "Share sound" to select "Stereo (High-fidelity)".

![Screen+Shot+2021-06-13+at+10.25.26+AM.png](https://user-images.githubusercontent.com/6550035/121835422-20a06a80-cc86-11eb-902a-1cd13f741b8c.png)

That's it! There shouldn't be any other steps to share your SuperCollider audio over Zoom on Windows.


### Mac OS

#### Downloading

[Click here](https://supercollider.github.io/download) to go to the website to download SuperCollider. *Make sure to check your version* of Mac OS and install the correct version of SuperCollider.

Then, [click here](https://github.com/supercollider/sc3-plugins/releases/download/Version-3.11.1/sc3-plugins-3.11.1-macOS-signed.zip) to download the plugins for Mac OS. Unzip this archive. Then copy the `SC3plugins` folder to your Extensions folder:

```
/Users/<yourname>/Library/Application Support/SuperCollider/Extensions
```

#### Zoom sharing

Share your screen, select the SuperCollider window, and then below click on the carrot symbol next to "Share sound" to select "Stereo (High-fidelity)".

![Screen+Shot+2021-06-13+at+10.25.26+AM.png](https://user-images.githubusercontent.com/6550035/121835422-20a06a80-cc86-11eb-902a-1cd13f741b8c.png)


In Mac OS it seems there is an extra step to share audio in Zoom. Once you are sharing your screen, you need to restart the SuperCollider audio server to use the Zoom playback. Simply run this line of code and then restart your synthdefs:

```
// run this line *after* you start sharing
s.options.outDevice = "ZoomAudioD"; s.options.inDevice = "ZoomAudioD"; s.reboot;
```

Once you are done sharing, you can run this line of code to get your default output and input back:

```
// run this line when *not* sharing
s.options.outDevice = "Built-in Output"; s.options.inDevice = "Built-in Input"; s.reboot;
```

## workshop 1 - tone to drone

![img](https://user-images.githubusercontent.com/6550035/118573663-db952100-b737-11eb-9a34-560e38778fcb.jpg)

## workshop 2 - ample samples

![img](https://user-images.githubusercontent.com/6550035/118573658-da63f400-b737-11eb-9308-e3310a184b9b.jpg)

