# Description

This repository contains a minimal, in-memory implementation of git. 

The purpose of this repository is to guide a learner towards implementing a minimal version of git themselves in order to get a better understanding of how git works.

For a simple overview of how git works internally, please see https://www.kenneth-truyers.net/2016/10/13/git-nosql-database/

# Quickstart

```
current_step=1
bundler --binstubs
while [ "$current_step" -lt 6 ]; do
    if bin/run-tests "$current_step"; then
      current_step=$((current_step + 1))
    else
	  read -p 'Press enter to edit lib/minigit.rb'
      $EDITOR lib/minigit.rb
    fi
done	
```

# How to use this repository

This repository comes with a test suite that is divided into several steps.

The learner progresses through the steps by changing [./lib/minigit.rb](./lib/minigit.rb) enough to make the tests of the current step pass.  Once the tests are green, the learner progresses to the next step.

In order to focus on core git logic, a minimal skeleton for `minigit.rb` is provided.

Tests for all steps up to step N can be run by invoking `bin/run-tests N`, e.g. `bin/run-tests 3` runs all tests for steps 1, 2 and 3.

A version of `minigit.rb` that passes all tests is provided on the branch `solution`.

**Start reading at [./spec/spec_helper.rb](./spec/spec_helper.rb)** to see what objects are available in the tests.

# Steps

1. Writing blobs (strings) to the repository and generating IDs for them
2. Writing trees (maps of strings to blobs or trees) to the repository
3. Building a history through a linked list of commit objects
4. Accessing stored contents through a working copy
5. Using references to associate symbolic names with object IDs

# Code Architecture

* `MiniGit::Repository` manages objects and references to objects and provides query methods for basic data integrity checks (does an object exist, etc)
* Command objects (i.e. classes in the `MiniGit::Commands` module) perform mutations on a `MiniGit::Repository`
* `RepositoryContext` contains common variables used throughout all tests.
