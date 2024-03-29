<p align="center"><img width="50%" height="50%" src="docs/images/image-logo-graphic.png" title="Learnosity logo, an open book with multicolored pages."></p>
<h1 align="center">Learnosity SDK - Ruby</h1>
<p align="center">Everything you need to start building your app in Learnosity, with the Ruby programming language.<br> 
(Prefer another language? <a href="https://help.learnosity.com/hc/en-us/sections/360000194318-Server-side-development-SDKs">Click here</a>)<br>
An official Learnosity open-source project.</p>

[![Latest Stable Version](https://badge.fury.io/gh/Learnosity%2Flearnosity-sdk-ruby.svg)](https://rubygems.org/gems/learnosity-sdk)
[![Build Status](https://app.travis-ci.com/Learnosity/learnosity-sdk-ruby.svg?branch=master)](https://app.travis-ci.com/Learnosity/learnosity-sdk-ruby)
[![License](docs/images/apache-license.svg)](LICENSE.md)
[![Downloads](docs/images/downloads.svg)](https://github.com/Learnosity/learnosity-sdk-ruby/releases)
---

## Table of Contents

* [Overview: what does it do?](#overview-what-does-it-do)
* [Requirements](#requirements)
* [Installation](#installation)
* [Quick start guide](#quick-start-guide)
* [Next steps: additional documentation](#next-steps-additional-documentation)
* [Contributing to this project](#contributing-to-this-project)
* [License](#license)
* [Usage tracking](#usage-tracking)
* [Further reading](#further-reading)

## Overview: what does it do?
The Learnosity Ruby SDK makes it simple to interact with Learnosity APIs.

![image-concept-overview.png](docs/images/image-concept-overview.png "Conceptual overview, showing your app, connecting to the Learnosity SDK, then the Learnosity Items API.")

It provides a number of convenience features for developers, that make it simple to do the following essential tasks:

* Creating signed security requests for API initialization, and
* Interacting with the Data API.

For example, the SDK helps with creating a signed request for Learnosity:

![image-signed-request-creation.png](docs/images/image-signed-request-creation.png "Diagram showing the flow of information from your app, sending key, secret and parameters to the Learnosity SDK, then the Learnosity SDK sending back a fully formed request.")

Once the SDK has created the signed request for you, your app sends that on to an API in the Learnosity cloud, which then retrieves the assessment you are asking for, as seen in the diagram below:

![image-assessment-retrieval.png](docs/images/image-assessment-retrieval.png "Diagram showing your app sending the fully formed request to the Learnosity cloud, then the cloud retrieving your assessment, which is then rendered in the student's browser.")

This scenario is what you can see running in the quick start guide example ([see below](#quick-start-guide)).

There's more features, besides. See the detailed list of SDK features on the [reference page](REFERENCE.md).

[(Back to top)](#table-of-contents)

## Requirements

1. Runtime libraries for Ruby installed. ([instructions](https://www.ruby-lang.org/en/downloads/branches/))

2. The [RubyGems](https://rubygems.org/) package manager installed. You use this to access the Learnosity Ruby SDK on [RubyGems](https://rubygems.org/gems/learnosity-sdk).

Not using Ruby? See the [SDKs for other languages](https://help.learnosity.com/hc/en-us/sections/360000194318-Server-side-development-SDKs).

### Supported Ruby Versions
The Ruby SDK supports the “normal maintenance” and “security maintenance” versions listed on the [Ruby home page](https://www.ruby-lang.org/en/downloads/branches/). Please contact our support team if you are having trouble with a specific version.

[(Back to top)](#table-of-contents)

## Installation
### **Installation via RubyGems**
Using RubyGems is the recommended way to install the Learnosity SDK for Ruby in production. The easiest way is to run this from your project folder:

``` bash
    gem install learnosity_sdk
```

### **Alternative method 1: download the zip file**
Download the latest version of the SDK as a self-contained ZIP file from the [GitHub Releases](https://github.com/Learnosity/learnosity-sdk-ruby/releases) page. The distribution ZIP file contains all the necessary dependencies. 

Note: after installation, run this command in (docs/quickstart/lrn-sdk-rails/):

``` bash
    bundle install
```

### **Alternative 2: development install from a git clone**
To install from the terminal, run this command:

``` bash
    git clone git@github.com:Learnosity/learnosity-sdk-Ruby.git
```

Note: after installation, run this command in (docs/quickstart/lrn-sdk-rails/):

``` bash
    bundle install
```

Note that these manual installation methods are for development and testing only.
For production use, you should install the SDK using the RubyGems package manager for Ruby, as described above.

[(Back to top)](#table-of-contents)

## Quick start guide
Let's take a look at a simple example of the SDK in action. In this example, we'll load an assessment into the browser.

### **Start up your web server and view the standalone assessment example**
To start up your Ruby web server, first find the following folder location under the SDK. Change directory ('cd') to this location on the command line.

``` bash
    cd docs/quickstart/lrn-sdk-rails/
```

To start, run this command from that folder:

``` bash
    rails server
```

From this point on, we'll assume that your web server is available at this local address (it will report the port being used when you launch it, by default it's port 3000): 

http://localhost:3000

You can now access the APIs using the following URL [click here](http://localhost:3000)

<img width="50%" height="50%" src="docs/images/image-quickstart-index.png">

Following are the routes to access our APIs.

* Author API : http://localhost:3000/author/index
* Questions API : http://localhost:3000/questions/index
* Items API : http://localhost:3000/items/index
* Reports API : http://localhost:3000/reports/index

Open these pages with your web browser. These are all basic examples of Learnosity's integration. You can interact with these demo pages to try out the various APIs. The Items API example is a basic example of an assessment loaded into a web page with Learnosity's assessment player. You can interact with this demo assessment to try out the various Question types.

<img width="50%" height="50%" src="docs/images/image-quickstart-examples-assessment.png">

[(Back to top)](#table-of-contents)

### **How it works**
Let's walk through the code for this standalone assessment example. The source files are included under the `docs/quickstart/lrn-sdk-rails/` folder.

Let's consider the Items API code. The first section is a controller file in Ruby, [items_controller.rb](docs/quickstart/lrn-sdk-rails/app/controllers/items_controller.rb) from `docs/quickstart/lrn-sdk-rails/app/controllers/` and it is executed server-side. It constructs a set of configuration options for Items API, and securely signs them using the consumer key. We also add a few lines to [application.rb](docs/quickstart/lrn-sdk-rails/config/application.rb) for our Learnosity credentials. The second section is HTML and JavaScript in an [ERB](https://docs.ruby-lang.org/en/2.3.0/ERB.html) template [index.html.erb](docs/quickstart/lrn-sdk-rails/app/views/items/index.html.erb) and is executed client-side, once the page is loaded in the browser. It renders and runs the assessment functionality.

[(Back to top)](#table-of-contents)

### **Server-side code**
We start by including some LearnositySDK helpers in [items_controller.rb](docs/quickstart/lrn-sdk-rails/app/controllers/items_controller.rb) - they'll make it easy to generate and sign the config options, and unique user and session IDs.

``` ruby
require 'learnosity/sdk/request/init' # Learnosity helper.
require 'securerandom'                # Library for generating UUIDs.
```

Now we'll declare the configuration options for Items API. The following options specify which assessment content should be rendered, how it should be displayed, which user is taking this assessment and how their responses should be stored. 

``` ruby
class IndexController < ApplicationController
    @@items_request = {
        "user_id" => SecureRandom.uuid,
        "activity_template_id" => "quickstart_examples_activity_template_001",
        "session_id" => SecureRandom.uuid,
        "activity_id" => "quickstart_examples_activity_001",
        "rendering_type" => "assess",
        "type" => "submit_practice",
        "name" => "Items API Quickstart",
        "state" => "initial"
  }
```

* `user_id`: unique student identifier. Note: we never send or save student's names or other personally identifiable information in these requests. The unique identifier should be used to look up the entry in a database of students accessible within your system only. [Learn more](https://help.learnosity.com/hc/en-us/articles/360002309578-Student-Privacy-and-Personally-Identifiable-Information-PII-).
* `activity_template_id`: reference of the Activity to retrieve from the Item bank. The Activity defines which Items will be served in this assessment.
* `session_id`: uniquely identifies this specific assessment attempt for save/resume, data retrieval and reporting purposes. Here, we're using the `Uuid` helper to auto-generate a unique session id.
* `activity_id`: a string you define, used solely for analytics to allow you run reporting and compare results of users submitting the same assessment.
* `rendering_type`: selects a rendering mode, `assess` mode is a "standalone" mode (loading a complete assessment player for navigation, as opposed to `inline` for embedding without).
* `type`: selects the context for the student response storage. `submit_practice` mode means the student responses will be stored in the Learnosity cloud, allowing for grading and review.
* `name`: human-friendly display name to be shown in reporting, via Reports API and Data API.
* `state`: Optional. Can be set to `initial`, `resume` or `review`. `initial` is the default.

**Note**: you can submit the configuration options either as an array as shown above, or a JSON string.

Next, we declare the Learnosity consumer credentials we'll use to authorize this request. 

We'll now open the file [application.rb](docs/quickstart/lrn-sdk-rails/config/application.rb), under `docs/quickstart/lrn-sdk-rails/config/` to set our Learnosity login credentials. Notice the two values *config.consumer_key* and *config.consumer_secret*.

``` ruby
require 'rails/all'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LrnSdkRails
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # The consumerKey and consumerSecret are the public & private
    # security keys required to access Learnosity APIs and
    # data. Learnosity will provide keys for your own private account.
    # Note: The consumer secret should be in a properly secured credential store, 
    # and *NEVER* checked into version control. 
    # The keys listed here grant access to Learnosity's public demos account.
    config.consumer_key = 'yis0TYCu7U9V4o7M'
    config.consumer_secret = '74c5fd430cf1242a527f6223aebd42d30464be22'
  end
end
```

The consumer key and consumer secret in this example are for Learnosity's public "demos" account. Once Learnosity provides your own consumer credentials, your Item bank and assessment data will be tied to your own consumer key and secret.
<i>(of course, you should never normally put passwords into version control)</i>

Now, back in [index_controller.rb](docs/quickstart/lrn-sdk-rails/app/controllers/index_controller.rb), we reference the key and secret, and also construct security settings that ensure the report is initialized on the intended domain. The value provided to the domain property must match the domain from which the file is actually served.

``` ruby
    @@security_packet = {
        # XXX: This is a Learnosity Demos consumer; replace it with your own consumer key
        'consumer_key'   => Rails.configuration.consumer_key,
        'domain'         => 'localhost'
    }
    # XXX: The consumer secret should be in a properly secured credential store, and *NEVER* checked into version control
    @@consumer_secret = Rails.configuration.consumer_secret
```

Now we call LearnositySDK's `Init()` helper to construct our Items API configuration parameters, and sign them securely with the `security_packet`, `consumerSecret` and `items_request` parameters. 

``` ruby
  def index
    @init = Learnosity::Sdk::Request::Init.new(
      'items',
      @@security_packet,
      @@consumer_secret,
      @@items_request
    )
  end
```

[(Back to top)](#table-of-contents)

### **Web page content**
We've got our set of signed configuration parameters, so now we can set up our page content for output. The page can be as simple or as complex as needed, using your own HTML and JavaScript to render the desired product experience.

This example uses plain HTML in an ERB template, served by Rails. 

``` html
<h1>Standalone Assessment Example</h1>
<div id="learnosity_assess"></div>
<script src="https://items.learnosity.com/?latest-lts"></script>
<script>
  var eventOptions = {
    readyListener: init
  },
    itemsApp = LearnosityItems.init(<%= raw @init.generate %>);
  function init () {
    var assessApp = itemsApp.assessApp();
    assessApp.on('item:load', function () {
      console.log('Active item:', getActiveItem(this.getItems()));
    });
    assessApp.on('test:submit:success', function () {
      toggleModalClass();
    });
  }
</script>
```

The important parts to be aware of in this HTML are:

* A div with `id="learnosity_assess"`. This is where the Learnosity assessment player will be rendered to deliver the assessment.
* The `<script src="https://items.learnosity.com/?latest-lts"></script>` tag, which includes Learnosity's Items API on the page and makes the global `LearnosityItems` object available. The version specified as `latest-lts` will retrieve the latest version supported. To know more about switching to a specific LTS version, visit our [Long Term Support (LTS) page](https://help.learnosity.com/hc/en-us/articles/360001268538-Release-Cadence-and-Version-Lifecycle). In production, you should always pin to a specific LTS version to ensure version compatibility.
* The call to `LearnosityItems.init()`, which initiates Items API to inject the assessment player into the page.
* The variable `<%= raw @init.generate %>` dynamically sends the contents of our init options to JavaScript, so it can be passed to `init()`.

The call to `init()` returns an instance of the ItemsApp, which we can use to programmatically drive the assessment using its methods. We pull in our Learnosity configuration in a variable `<%= raw @init.generate %>`, that the ERB template will import from the Ruby controller file.

This marks the end of the quick start guide. From here, try modifying the example files yourself, you are welcome to use this code as a basis for your own projects.

Take a look at some more in-depth options and tutorials on using Learnosity assessment functionality below.

[(Back to top)](#table-of-contents)

## Next steps: additional documentation

### **SDK reference**
See a more detailed breakdown of all the SDK features, and examples of how to use more advanced or specialised features on the [SDK reference page](REFERENCE.md).

### **Additional quick start guides**
There are more quick start guides, going beyond the initial quick start topic of loading an assessment, these further tutorials show how to set up authoring and analytics:

* [Authoring Items quick start guide](https://help.learnosity.com/hc/en-us/articles/360000754958-Getting-Started-With-the-Author-API) (Author API) - create and edit new Questions and Items for your Item bank, then group your assessment Items into Activities, and
* [Analytics / student reporting quick start guide](https://help.learnosity.com/hc/en-us/articles/360000755838-Getting-Started-With-the-Reports-API) (Reports API) - view the results and scores from an assessment Activity. 

### **Learnosity demos repository**
On our [demo site](https://demos.learnosity.com/), browse through many examples of Learnosity API integration. You can also download the entire demo site source code, the code for any single demo, or browse the codebase directly on GitHub.

### **Learnosity reference documentation**
See full documentation for Learnosity API init options, methods and events in the [Learnosity reference site](https://reference.learnosity.com/).

### **Technical use-cases documentation**
Find guidance on how to select a development pattern and arrange the architecture of your application with Learnosity, in the [Technical Use-Cases Overview](https://help.learnosity.com/hc/en-us/articles/360000757777-Technical-Use-Cases-Overview).

### **Deciding what to build or integrate**
Get help deciding what application functionality to build yourself, or integrate off-the-shelf with the [Learnosity "Golden Path" documentation](https://help.learnosity.com/hc/en-us/articles/360000754578-Recommended-Deployment-Patterns-Golden-Path-).

### **Key Learnosity concepts**
Want more general information about how apps on Learnosity actually work? Take a look at our [Key Learnosity Concepts page](https://help.learnosity.com/hc/en-us/articles/360000754638-Key-Learnosity-Concepts).

### **Glossary**
Need an explanation for the unique Learnosity meanings for Item, Activity and Item bank? See our [Glossary of Learnosity-specific terms](https://help.learnosity.com/hc/en-us/articles/360000754838-Glossary-of-Learnosity-and-Industry-Terms).

[(Back to top)](#table-of-contents)

## Contributing to this project

### Adding new features or fixing bugs
Contributions are welcome. See the [contributing instructions](CONTRIBUTING.md) page for more information. You can also get in touch via our support team.

[(Back to top)](#table-of-contents)

## License
The Learnosity Ruby SDK is licensed under an Apache 2.0 license. [Read more](LICENSE.md).

[(Back to top)](#table-of-contents)

## Usage tracking
Our SDKs include code to track the following information by adding it to the request being signed:

- SDK version
- SDK language
- SDK language version
- Host platform (OS)
- Platform version

We use this data to enable better support and feature planning.

[(Back to top)](#table-of-contents)

## Further reading
Thanks for reading to the end! Find more information about developing an app with Learnosity on our documentation sites: 

* [help.learnosity.com](http://help.learnosity.com/hc/en-us) -- general help portal and tutorials,
* [reference.learnosity.com](http://reference.learnosity.com) -- developer reference site, and
* [authorguide.learnosity.com](http://authorguide.learnosity.com) -- authoring documentation for content creators.

[(Back to top)](#table-of-contents)
