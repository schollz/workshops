// Part 1
// This part will teach the basics of SuperCollider
// and making sounds. By the end of this part, you
// should be able to mix different sounds together and
// use additive synthesis to make tones and overtones.

s.boot;
s.meter;
s.plotTree;
s.freqscope;




//////// 1 ////////
// this is a comment! it is valid code but doesn't do anything




//////// 2 ////////
// now, this is a line of code that does something!
// this line prints something in the window over there ->
// run any line of code by putting your cursor on it and then
// press <Ctl>+<Enter>
"I love SuperCollider".postln; // <- make sure to always have a ";" after code




//////// 3 ////////
// parentheses make it easy to
// run multiple lines of code with <Ctl>+<Enter>
(
"I love SuperCollider".postln;
"SuperCollider loves me".postln;
)




//////// 4 ////////
// disorder of operations!
// there is no order of operations in SuperCollider!
// beware beware beware beware
(
 (100+2/2).postln; // what does this equal?
 (100+(2/2)).postln; // force order of operations using parentheses
)




//////// 5 ////////
// semicolons make functions
// you can assign variables using letters a-z or with ~variableName
// execute each step, incrementally

// step 1: create functions stored in a variable
(
a={"I love SuperCollider".postln;};
~someVariable={"SuperCollider loves me".postln;};
)
// step 2a: run the first function
a.value; // .value evaluates the function stored in "a"
// step 2b: run the second function
~someVariable.value;





//////// 6 ////////
// functions can have arguments and variables!
// arguments and variables are similar, except that arguments can be passed into functions when the function is called.
// step 1: create a function that contains arguments and variable
(
a={
	arg name; // arguments must be defined first
	var something; // then variables must be defined next
	something="SuperCollider"; // variables can be assigned later
	(name++", do you like "++something++"?").postln;
};
)

// step 2: replace '<your name>' with your name and execute the function
a.value("<your name>");




//////// 7 ////////
// you can make arrays or "lists" with brackets
(
a=["first item","second item"];
a[0].postln;
)




//////// 8 ////////
// "multichannel expansion" is the secret sauce of SuperCollider
// which lets you make lists (or multichannel audio) very easily
(
a=1!10; // creates a list with 10 1's
)
(
a=Array.fill(10,{arg i; 1}); // creates a list with 10 1's
)
(
a=Array.fill(10,{arg i; i*2}); // creates a list with 10 even numbers
)




//////// 9 ////////
// let's get into the sound waves now!
// we need to boot the server to start music making:
// goto Server -> Boot Server
// or press <Ctl>+B (windows)




//////// 10 ////////
// playing and modulating a simple Sine wave
// oscillators / playback functions are "UGens" - unit generators
// a "UGen" is basically a stream of numbers
// you can treat it like a number (add it, subtract it, etc.)

// a simple "UGen" - the sine wave
// lets plot it
(
{
	SinOsc.ar(freq:220);
}.plot(0.02); // .plot(x) will plot it for x seconds
)

// lets hear it
(
{
	SinOsc.ar(freq:220);
}.play; // .play will play it
)

// lets modulate it
// .ar = audio rate (things that you hear)
// .kr = control rate (thing that modulate things you hear)
(
{
	SinOsc.ar(freq:220+SinOsc.kr(2,mul:40));
}.play;
)

// you can add modulation to anything, even modulation
(
{
	SinOsc.ar(freq:220+SinOsc.kr(SinOsc.kr(1)+2,mul:40));
}.play;
)

// mouse modulation!
// there is a special modulation source in SuperCollider - your mouse
(
{
	SinOsc.ar(freq:MouseX.kr(100,400,1));
}.play; // .plot(x) will plot it for x seconds
)



//////// 10 ////////
// putting it all together
// we assign a function (a Sine oscillator) with arguments
// that can be set later
(
x={
	arg volume=0.1;
	SinOsc.ar(freq:MouseX.kr(100,400,1),mul:volume);
}.play; // .plot(x) will plot it for x seconds
)
x.set(\volume,0.1);




//////// 11 ////////
// we can easily create multiple oscillators with
// -- multichannel expansion --
// (i.e. we put an array in one of the arguments and
// it automatically creates multiple oscillators)
(
x={
	arg volume=0.1;
	SinOsc.ar(freq:[MouseX.kr(100,400,1),MouseX.kr(100,400,1)/2],mul:volume);
}.play; // .plot(x) will plot it for x seconds
)
x.set(\volume,0.1);




//////// part 1 recap ////////
// SuperCollider has functions, arguments, variables, lists
// UGens are SuperCollider functions that stream numbers (audio or modulation)
// UGens are basically treated like numbers (can be added, used as arguments, etc)