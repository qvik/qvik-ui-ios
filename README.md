# Qvik's iOS UI collection

*This Swift4 library contains some custom UI widgets for use in both Qvik's internal and customer projects.*

## Usage

To use the library in your projects, add the following (or what ever suits your needs) to your Podfile:

```ruby
use_frameworks!
source 'https://github.com/qvik/qvik-podspecs.git'

pod 'QvikUi'
```

And the following to your source:

```swift
import QvikUi
```

## Changelog

* 5.0.0
   * Added swiftlint
   * Swift 4.1 compliance
   * Built against QvikSwift 5
* 4.0.2
   * Fixed visibility of KeyboardConstraint variables
* 4.0.1
   * Added LineHeightAwareLabel
   * Added KeyboardConstraint
   * Improved IBDefinedUIView to support further subclassing
* 4.0.0
   * Ported to Swift4
* 1.0.0 
    * Initial release
* 0.0.1
    * Initial version

## Contributing 

Contributions to this library are welcomed. Any contributions have to meet the following criteria:

* Meaningfulness. Discuss whether what you are about to contribute indeed belongs to this library in the first place before submitting a pull request.
* Code style. Follow our [Swift style guide](https://github.com/qvik/swift) 100%.
* Stability. No code in the library must ever crash; never place *assert()*s or implicit optional unwrapping in library methods.
* Testing. Every util method, function and extension in the library must have unit tests, preferably triggering both successful and unsuccessful calls. All custom views/controls should have proper documentation and usage examples.
* Logging. No production code in the library must write logs. Unit tests may output logs.

### License

The library is distributed with the MIT License. Make sure all your source files contain the license header at the start of the file:

```
// The MIT License (MIT)
//
// Copyright (c) 2016 Qvik (www.qvik.fi)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
```

### Submit your code

All merges to the **master** branch go through a *Merge ('pull') Request* and MUST meet the above criteria.

In other words, follow the following procedure to submit your code into the library:

* Clone the library repository
* Create a feature branch for your code
* Code it, clean it up, test it thoroughly
* Make sure all your methods meant to be public are defined as public
* Push your branch
* Create a merge request

## Updating the pod

As a contributor you do not need to do this; we'll update the pod whenever needed by projects.

* Update QvikUi.podspec and set s.version to match the upcoming tag
* Commit all your changes, merge all pending accepted *Merge ('pull') Requests*
* Create a new tag following [Semantic Versioning](http://semver.org/); eg. `git tag -a 2.2.0 -m "Your tag comment"`
* `git push --tags`
* `pod repo push qvik-podspecs QvikUi.podspec`

Unless already set up, you might do the following steps to set up the pod repo:

* ```pod repo add qvik-podspecs https://github.com/qvik/qvik-podspecs.git```

## Contact

Any questions? Contact matti@qvik.fi.
