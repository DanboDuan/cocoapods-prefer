# cocoapods-prefer

A cocoapods plugin to work with pod sources

## Installation

Just install it

```
gem install cocoapods-prefer 
```

or use Gemfile with `bundle install`

```
source 'https://rubygems.org/'

gem 'cocoapods', '>= 1.8.4'
gem 'colored2','~> 3.1'
gem 'neatjson','~> 0.9'
gem 'cocoapods-prefer','~ 1.0'

```

## Usage

- only work with git ssh url

### in Podfile


```ruby

require "cocoapods-prefer"

# only source it
source "git@github.com:DanboDuan/Test_Dislike_Specs.git"
source "git@github.com:DanboDuan/Test_Prefer_Specs.git"



plugin 'cocoapods-prefer'

prefer_source("Test_Prefer","git@github.com:DanboDuan/Test_Prefer_Specs.git")

target 'Example' do

  lock_source_with_url("git@github.com:DanboDuan/Test_Prefer_Specs.git") do
    prefer_source_pod 'AFNetworking'
  end
  
  lock_source_with_url("git@github.com:DanboDuan/Test_Dislike_Specs.git") do
    dislike_source_pod 'FMDB'
  end
  
  pod 'Godzippa'
  pod 'XcodeCoverage'
  
end
```

### rules
 
- AFNetworking then will prefer the source if it meets requirement
	- if it does not meet requirement, the preferred source does not work
- FMDB then will prefer other sources unless only the source meets requirement
- `prefer_source` work for all the pods if it meets requirement
- `Godzippa` is not in the preferred source, so it does not work

## Example

see [TestExample](https://github.com/DanboDuan/TestExample)

## Contribute

if you like

![like it](https://raw.githubusercontent.com/DanboDuan/cocoapods-unit-test/master/like_it.jpg)