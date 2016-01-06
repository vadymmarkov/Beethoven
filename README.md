![Beethoven](https://github.com/vadymmarkov/Beethoven/blob/master/Resources/BeethovenPresentation.png)

[![CI Status](http://img.shields.io/travis/vadymmarkov/Beethoven.svg?style=flat)](https://travis-ci.org/vadymmarkov/Beethoven)
[![Version](https://img.shields.io/cocoapods/v/Beethoven.svg?style=flat)](http://cocoadocs.org/docsets/Beethoven)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/Beethoven.svg?style=flat)](http://cocoadocs.org/docsets/Beethoven)
[![Platform](https://img.shields.io/cocoapods/p/Beethoven.svg?style=flat)](http://cocoadocs.org/docsets/Beethoven)

**Beethoven** is an audio processing Swift library that provides an
easy-to-use interface to solve an age-old problem of pitch detection of musical
signals. You can read more about this subject on
[Wikipedia](https://en.wikipedia.org/wiki/Pitch_detection_algorithm).

The basic workflow is to get the audio buffer from the input/output source,
transform it to a format applicable for processing and apply one of the pitch
estimation algorithms to find the fundamental frequency. For the end user it
comes down to choosing transform strategy, estimation algorithm and
implementation of delegate methods.

The library is designed to be flexible, customizable and highly extensible.

The main purpose of the library is to collect Swift implementations of various
time and frequency domain algorithms for monophonic pitch extraction, with
different rate of accuracy and speed, to cover as many as possible pitch
detection scenarios, musical instruments and human voice. Current
implementations could also be not perfect and obviously there is a place for
improvements. It means that [contribution](#contributing) is very important
and more than welcome!

## Table of Contents

<img src="https://github.com/vadymmarkov/Beethoven/blob/master/Resources/BeethovenIcon.png" width="195" height="199" alt="Beethoven Icon" align="right" />

* [Key features](#key-features)
* [Usage](#usage)
  * [Configuration](#configuration)
  * [Pitch engine](#pitch-engine)
  * [Signal tracking](#signal-tracking)
  * [Transform](#transform)
  * [Estimation](#estimation)
  * [Error handling](#error-handling)
* [Pitch detection specifics](#pitch-detection-specifics)
* [Examples](#examples)
* [Installation](#installation)
* [Components](#components)
* [Author](#author)
* [Contributing](#contributing)
* [License](#license)

## Key features

- Audio signal tracking with `AVAudioEngine` and audio nodes (Available in
  iOS 8.0 and later).
- Pre-processing of audio buffer by one of the available "transformers", to
convert `AVAudioPCMBuffer` object to the array of floating numbers (with
  possible optimizations).
- Pitch estimation.  

## Usage

### Configuration
Configure buffer size, transform strategy and estimation strategy with the
`Config` struct that could be used in the initialization of `PitchEngine`. For
the case when a signal needs to be tracked from the device output there is
`audioURL` parameter which is the URL to your audio file.

```swift
// Creates a configuration for the input signal tracking (by default)
let config = Config(
  bufferSize: 4096,
  transformStrategy: .FFT,
  estimationStrategy: .HPS)

// Creates a configuration for the output signal tracking
let config = Config(
  bufferSize: 4096,
  transformStrategy: .FFT,
  estimationStrategy: .HPS,
  audioURL: URL)
```

Initializer has default values:

```swift
public init(bufferSize: AVAudioFrameCount = 4096,
    transformStrategy: TransformStrategy = .FFT,
    estimationStrategy: EstimationStrategy = .HPS,
    audioURL: NSURL? = nil)
```

It means that `Config` could also be instantiated without any parameters:

```swift
let config = Config()
```

### Pitch engine
`PitchEngine` is the main class you are going to work with to find the pitch.
It could be instantiated with a configuration and delegate:

```swift
let pitchEngine = PitchEngine(config: config, delegate: pitchEngineDelegate)
```

Both parameters are optional, standard config is used by default, and delegate
could always be set later:

```swift
let pitchEngine = PitchEngine()
pitchEngine.delegate = pitchEngineDelegate
```

`PitchEngine` uses `PitchEngineDelegate` to inform about results or errors when
the pitch detection has been started:

```swift
func pitchEngineDidRecievePitch(pitchEngine: PitchEngine, pitch: Pitch)
func pitchEngineDidRecieveError(pitchEngine: PitchEngine, error: ErrorType)
```

To start or stop the pitch tracking process just use the corresponding
`PitchEngine` methods:

```swift
pitchEngine.start()
pitchEngine.stop()
```

### Signal tracking
There are 2 signal tracking classes:
- `InputSignalTracker` uses `AVAudioInputNode` to get an audio buffer from the
recording input (microphone) in real-time.
- `OutputSignalTracker` uses `AVAudioOutputNode` and `AVAudioFile` to play an
audio file and get an audio buffer from the playback output.

### Transform
Transform is the first step of audio processing where `AVAudioPCMBuffer` object
is converted to the array of floating numbers. Also it's a place for different
kind of optimizations. Then array is kept in the `elements` property of the
internal `Buffer` struct which also has optional `realElements` and
`imagElements` properties that could be useful in the further calculations.

There are 2 types of transformations at the moment:
- FFT [Fast Fourier transform](https://en.wikipedia.org/wiki/Fast_Fourier_transform)
- `Simple` conversion to use raw float channel data

A new transform strategy could be easily added by implementing of `Transformer`
protocol:

```swift
public protocol Transformer {
  func transformBuffer(buffer: AVAudioPCMBuffer) -> Buffer
}
```

Then it should be added to `TransformStrategy` enum and in the `create` method
of `TransformFactory` struct.

### Estimation
A pitch detection algorithm (PDA) is an algorithm designed to estimate the pitch
or fundamental frequency. Pitch is a psycho-acoustic phenomena, and it's
important to choose the most suitable algorithm for your kind of input source,
considering allowable error rate and needed performance.

The list of available implemented algorithms:
- `MaxValue` - the index of the maximum value in the audio buffer used as a peak.
- `Quadradic` - [Quadratic interpolation of spectral peaks](https://ccrma.stanford.edu/%7Ejos/sasp/Quadratic_Interpolation_Spectral_Peaks.html)
- `Barycentric` - [Barycentric correction](http://www.dspguru.com/dsp/howtos/how-to-interpolate-fft-peak)
- `QuinnsFirst` - [Quinn's First Estimator](http://www.dspguru.com/dsp/howtos/how-to-interpolate-fft-peak)
- `QuinnsSecond` - [Quinn's Second Estimator](http://www.dspguru.com/dsp/howtos/how-to-interpolate-fft-peak)
- `Jains` - [Jain's Method](http://www.dspguru.com/dsp/howtos/how-to-interpolate-fft-peak)
- `HPS` - [Harmonic Product Spectrum](http://musicweb.ucsd.edu/~trsmyth/analysis/Harmonic_Product_Spectrum.html)

A new estimation algorithm could be easily added by implementing of `Estimator`
or `LocationEstimator` protocol:

```swift
public protocol Estimator {
  func estimateFrequency(sampleRate: Float, buffer: Buffer) throws -> Float
  func estimateFrequency(sampleRate: Float, location: Int, bufferCount: Int) -> Float
}

public protocol LocationEstimator: Estimator {
  func estimateLocation(buffer: Buffer) throws -> Int
}
```

Then it should be added to `EstimationStrategy` enum and in the `create` method
of `EstimationFactory` struct.

### Error handling
Pitch detection is not a trivial task due to some difficulties such as attack
transients, low and high frequencies. Also it's a real-time processing, so we
are not protected against different kind of errors. For this purpose there is a
range of error types that should be handled properly.

**Signal tracking errors**

```swift
public enum Error: ErrorType {
  case InputNodeMissing
}
```

**Record permission errors**

`PitchEngine` asks for `AVAudioSessionRecordPermission` on start, but if
permission is denied it produces the corresponding error:

```swift
public enum Error: ErrorType {
  case RecordPermissionDenied
}
```

**Pitch estimation errors**

Some errors could occur during the process of pitch estimation:

```swift
public enum EstimationError: ErrorType {
  case EmptyBuffer
  case UnknownMaxIndex
  case UnknownLocation
  case UnknownFrequency
}
```

## Pitch detection specifics

**Beethoven** performs a pitch detection of a monophonic recording only at the
moment.

**Based on Stackoverflow** [answer](http://stackoverflow.com/a/14503090):

Pitch detection depends greatly on the musical content you want to work with.
Extracting the pitch of a monophonic recording (i.e. single instrument or voice)
is not the same as extracting the pitch of a single instrument from a polyphonic
mixture (e.g. extracting the pitch of the melody from a polyphonic recording).

For monophonic pitch extraction there are various algorithm that could be
implemented both in the time domain and frequency domain
([Wikipedia](https://en.wikipedia.org/wiki/Pitch_detection_algorithm)).

However, neither will work well if you want to extract the melody from
polyphonic material. Melody extraction from polyphonic music is still a
research problem.

## Examples

<img src="https://github.com/vadymmarkov/Beethoven/blob/master/Resources/BeethovenTunerExample.png" width="216" height="384" alt="Beethoven Tuner Example" align="right" />

Check out [Guitar Tuner](https://github.com/vadymmarkov/Beethoven/blob/master/Example/GuitarTuner)
example to see how you can use **Beethoven** in the real-world scenario to tune
your instrument. It uses a combination of [FFT](https://github.com/vadymmarkov/Beethoven/blob/master/Source/Transform/Strategies/FFTTransformer.swift)
transform and [HPS](https://github.com/vadymmarkov/Beethoven/blob/master/Source/Estimation/Strategies/HPSEstimator.swift)  estimation algorithm that appear to be quite accurate in the pitch detection of
guitar strings.

## Installation

**Beethoven** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Beethoven'
```

**Beethoven** is also available through [Carthage](https://github.com/Carthage/Carthage).
To install just write into your Cartfile:

```ruby
github "vadymmarkov/Beethoven"
```

## Components

**Beethoven** uses [Pitchy](https://github.com/vadymmarkov/Pitchy) library to
get a music pitch with note, octave and offsets from a specified frequency.

## Author

Vadym Markov, markov.vadym@gmail.com

## Contributing

Check the [CONTRIBUTING](https://github.com/vadymmarkov/Beethoven/blob/master/CONTRIBUTING.md)
file for more info.

## License

**Beethoven** is available under the MIT license. See the [LICENSE](https://github.com/vadymmarkov/Beethoven/blob/master/LICENSE.md) file
for more info.
