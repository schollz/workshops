# SuperCollider workshops

This repo is designed to teach SuperCollider to beginners through two self-styled workshops. The theme of these workshops is *ambulation* - getting you to take your first steps to walk on your own with SuperCollider. Both are offered as workshops at [Music Hackspace](https://musichackspace.org/events/tone-to-drone-introduction-to-supercollider-for-monome-norns-live-session/) but all the materials are included here and can be used as a self-guided workshop as well.

What is SuperCollider? SuperCollider is a free platform for audio synthesis and algorithm composition. It really excels at real-time analysis, synthesis, sampling, and processing and provides a framework for seamless combination of audio techniques like additive and subtractive synthesis. 

What can you do with SuperCollider? Really, the sky is the limit. I've used SuperCollider to make [my own live-coding environment](https://www.instagram.com/p/CQCu9z3haBD/?utm_source=ig_web_copy_link), to make [new synths](https://www.instagram.com/p/CJTwGz8hxMR/?utm_source=ig_web_copy_link), to make [crazy drum beats](https://www.instagram.com/p/COqOS5lBGDL/?utm_source=ig_web_copy_link
), to [make drum sets](https://www.instagram.com/p/CPghuJUB2Of/?utm_source=ig_web_copy_link), and I've barely scratched the surface.

Why this workshop on SuperCollider? This workshop is entirely goal-oriented. In workshop #1 the goal is to make [a drone](https://en.wikipedia.org/wiki/Drone_music). In workshop #2 the goal is to make a sampler. In both workshops, SuperCollider will be taught in a way that builds up understanding to reach these goals. Of course, SuperCollider is much deeper than either of these two goals, and you can [learn more about SuperCollider in other tutorials](https://supercollider.github.io/tutorials/).



## Workshop 1: tone to drone

<p align="center">
  <img width=400 style="max-width:100%" src="https://user-images.githubusercontent.com/6550035/118573663-db952100-b737-11eb-9a34-560e38778fcb.jpg">
</p>

In this workshop we will start at the very beginning of SuperCollider. I will assume you don't now anything about SuperCollider. 

We will start by making simple sounds, then learn how to modulate those sounds, and then learn how to add effects to those sounds. we will go through all the basics of SuperCollider in a practical way, to build up from a single tone all the way to make a [space drone](https://raw.githubusercontent.com/schollz/ambulation/main/droning/55hz_spacedrone.mp3)!

### Part 0: before you begin

[Install SuperCollider](https://github.com/schollz/ambulation#installing-supercollider) and then you are ready to start this workshop. 

### Part 1: how to make a sound

Open [part1.scd](https://github.com/schollz/ambulation/blob/main/droning/part1.scd) in SuperCollider.

This part will teach the basics of SuperCollider and making sounds. by the end of this part you should be able to mix different sounds together and use additive synthesis to make tones and overtones.

### Part 2: how to modulate the sound

Open [part2.scd](https://github.com/schollz/ambulation/blob/main/droning/part2.scd) in SuperCollider.

This part will teach some SuperCollider tricks to do *modulation*, that is dynamically changing different parts of the sounds. by the end you will be able to modulate frequency, amplitude and get a neat dynamic sound.


### Part 3: how to sculpt the sound 

Open [part3.scd](https://github.com/schollz/ambulation/blob/main/droning/part3.scd) in SuperCollider.

This part will teach about using the non-tonal components of SuperCollider - envelopes, effects, and filters! we will use these, in combination with the tones in part 1, and the modulation in part 2 to make the space drone.

### Part 4: how to manipulate sounds from norns



## Workshop 2: ample samples


<p align="center">
  <img width=400 style="max-width:100%" src="https://user-images.githubusercontent.com/6550035/118573658-da63f400-b737-11eb-9308-e3310a184b9b.jpg">
</p>



In this workshop we will start at the very beginning of SuperCollider. I will assume you don't now anything about SuperCollider. 

We will start by learning how to load a buffer, and then play the buffer with a simple player. We will learn how to add effects to the sound and the sample playback and eventually work our way towards a really efficient sampler that can be placed [into the norns](https://vimeo.com/user126081217).

### Part 0: before you begin

[Install SuperCollider](https://github.com/schollz/ambulation#installing-supercollider) and then you are ready to start this workshop. 

### Part 1: how to use samples

Open [part1.scd](https://github.com/schollz/ambulation/blob/main/sampling/part1.scd) in SuperCollider.

This part will teach the basics of SuperCollider and loading and playing buffers. At the end of this tutorial different types of effects will be addressed.

### Part 2: developing a efficient sampler player

Open [part2.scd](https://github.com/schollz/ambulation/blob/main/sampling/part2.scd) in SuperCollider.

This part will teach some SuperCollider tricks to do develop a sophisticated sample playback engine. We will iterate on the sample playback synth created in part 1.


### Part 3: how to sequence samples

Open [part3.scd](https://github.com/schollz/ambulation/blob/main/sampling/part3.scd) in SuperCollider.

In this part we will take the final sampler player from part 2 and load multiple samples and sequence them so they stay in sync. We will look at effects based on sample rates, and perhaps add other effects.

## Other SuperCollider resources

- [kid_sputnik's intro into norns+SuperCollider](https://medium.com/@kidsputnik/monome-norns-supercollider-and-lua-part-1-d97646306973)
- [Professor Eli Fieldsteel's Youtube tutorials](https://www.youtube.com/c/elifieldsteel/videos)
- [Michelle McKenzie's Youtube tutorials](https://www.youtube.com/c/SoundEngraver/search?query=SuperCollider)
- [Many more...](https://github.com/madskjeldgaard/awesome-supercollider#learning-resources)

## Connecting to norns

### ssh

By `ssh`-ing into norns, you will be able to easily restart the SuperCollider engine in the terminal without having to restart the norns each time.

1. Open a terminal. For Mac OS: use "Terminal". For Windows: use "Powershell".
2. Execute `ssh we@<ip_address_shown_in_norns>`. You'll need to enter a password - the password is "`sleep`".

### Managing files

You might find it easier to edit files on the norns as if they were on your computer. You can do this using *sftp*. Here are the instructions to connect to norns using sftp: https://monome.org/docs/norns/sftp/

## Installing SuperCollider

<details><summary><strong>Windows</strong></summary>

[Click here](https://github.com/supercollider/supercollider/releases/download/Version-3.11.2/SuperCollider-3.11.2-Windows-32bit-VS.exe) to download the latest Windows release. This is the *32-bit* release, rather than the 64-bit release, because [the most recent Windows Update prevents the 64-bit version from starting](https://github.com/supercollider/supercollider/issues/4368#issuecomment-832050665). But 32-bit will work just fine!

Then [click here](https://github.com/supercollider/sc3-plugins/releases/download/Version-3.11.1/sc3-plugins-3.11.1-Windows-32bit-VS.zip) to download the 32-bit sc3-plugins. Unzip these plugins and then copy and paste the `SC3plugins` folder into the following folder:

```
C:\Users\<yourname>\AppData\Local\SuperCollider\Extensions\
```


</details>

<details><summary><strong>Mac OS</strong></summary>


[Click here](https://supercollider.github.io/download) to go to the website to download SuperCollider. *Make sure to check your version* of Mac OS and install the correct version of SuperCollider.

Then, [click here](https://github.com/supercollider/sc3-plugins/releases/download/Version-3.11.1/sc3-plugins-3.11.1-macOS-signed.zip) to download the plugins for Mac OS. Unzip this archive. Then copy the `SC3plugins` folder to your Extensions folder:

```
/Users/<yourname>/Library/Application Support/SuperCollider/Extensions
```

 
</details>



## Sharing SuperCollider over Zoom

<details><summary><strong>Windows</strong></summary>

Share your screen, select the SuperCollider window, and then below click on the carrot symbol next to "Share sound" to select "Stereo (High-fidelity)".

![Screen+Shot+2021-06-13+at+10.25.26+AM.png](https://user-images.githubusercontent.com/6550035/121835422-20a06a80-cc86-11eb-902a-1cd13f741b8c.png)

That's it! There shouldn't be any other steps to share your SuperCollider audio over Zoom on Windows.

</details>

<details><summary><strong>Mac OS</strong></summary>

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
 
</details>
