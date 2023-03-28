# Lush Sound Baths SuperCollider workshop

In this workshop we will

- learn the basics of SuperCollider
- experiment with synthesis in SuperCollider
- develop a personalized sound pad


## Slides

Download the slides [here](https://docs.google.com/presentation/d/1O3bxRUxgUh74-HYxpOA3cblAVFEAjmFF7cgtg4bgjUM/edit?usp=sharing).

## Installation

To get started we will need to install SuperCollider and then install the nessecary libraries.

**1. Install SuperCollider**

Goto [supercollider.github.io/downloads.html](https://supercollider.github.io/downloads.html) to download SuperCollider. Make sure to install the latest version for your operating system. Once its downloaded and installed, run SuperCollider.

**2. Install SuperCollider Safety Quark**

Open SuperCollider and type in the following:

```
Quarks.install("SafetyNet")
```


Then goto `Language -> Evaluate File`. You should see some output that says "Installing SafetyNet / SafetyNet installed." 

To test to make sure its working, close and restart SuperCollider. Then you can do `Server -> Boot Server` and you should see something like:

```
Safety('localhost') is running, using 'safeClip_2'.
```

This will run automatically and will serve to automatically limit problematic sounds.

**3. Download SuperCollider extensions**

Open SuperCollider and goto `File -> Open user support directory`. This will open a folder on your operating system. From that folder, open the `Extensions` directory. In this directory we will add some extensions. We need to install two extensions:

1. Goto [github.com/supercollider/sc3-plugins/releases](https://github.com/supercollider/sc3-plugins/releases/tag/Version-3.13.0) and download the archive that corresponds to your system. Unzip the archive and copy and paste the unzipped contents into the `Extensions` directory.
2. Goto [github.com/schollz/portedplugins/releases](https://github.com/schollz/portedplugins/releases/tag/v0.4.5) and download the archive that corresponds to your system. Unzip the archive and copy and paste the unzipped contents into the `Extensions` directory.

That's it! You can verify it working by doing `Language -> Recompile Class Library` and if all works well you should see the welcome message in the `Post window`:

```
*** Welcome to SuperCollider 3.13.0-rc1. ***
```

**4. Test SuperCollider**

Once you have completed steps 1-3 we can test that SuperCOllider is working.

Open SuperCollider and copy-and-paste this into the main window: 

```
{ [SinOsc.ar(440, 0, 0.2), SinOsc.ar(442, 0, 0.2)] }.play;
```

Now goto `Server` -> `Boot Server` and then do `Language` -> `Evaluate File`. You should hear a sound! If you do you are all set. If not, check the `Post Window` as something may have gone wrong.

## Workshop

The workshop is guided through `workshop.scd` which you can open up in SuperCollider.

## Other SuperCollider resources/inspiration

- [Nathan Ho's tutorials and advice](https://nathan.ho.name/posts/supercollider-beginner-advice/)
- [kid_sputnik's intro into norns+SuperCollider](https://medium.com/@kidsputnik/monome-norns-supercollider-and-lua-part-1-d97646306973)
- [Professor Eli Fieldsteel's Youtube tutorials](https://www.youtube.com/c/elifieldsteel/videos)
- [Michelle McKenzie's Youtube tutorials](https://www.youtube.com/c/SoundEngraver/search?query=SuperCollider)
- [Yota Morimoto's amazing creations](https://www.youtube.com/c/yotamorimoto/search?query=SuperCollider)
- [Mads' list of awesome SuperCollider](https://github.com/madskjeldgaard/awesome-supercollider#learning-resources)

