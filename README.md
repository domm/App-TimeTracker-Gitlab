# NAME

App::TimeTracker::Command::Gitlab - App::TimeTracker Gitlab plugin

# VERSION

version 1.004

# DESCRIPTION

Connect tracker with [Gitlab](https://about.gitlab.com/).

Using the Gitlab plugin, tracker can fetch the name of an issue and use
it as the task's description; generate a nicely named `git` branch
(if you're also using the `Git` plugin).

Planned but not implemented: Adding yourself as the assignee.

# CONFIGURATION

## plugins

Add `Gitlab` to the list of plugins.

## gitlab

add a hash named `gitlab`, containing the following keys:

### url \[REQUIRED\]

The base URL of your gitlab instance, eg `https://gitlab.example.com`

### token \[REQUIRED\]

Your personal access token. Get it from your gitlab profile page. For
now you probably want to use a token with unlimited expiry time. We
might implement a way to fetch a shortlived token (like in the Trello
plugin), but gitlab does not support installed-apps OAuth2.

### namespace \[REQUIRED\]

The `namespace` of the current project, eg `validad` if this is your repo: `https://gitlab.example.com/validad/App-TimeTracker-Gitlab`

# NEW COMMANDS

No new commands

# CHANGES TO OTHER COMMANDS

## start, continue

### --issue

    ~/perl/Your-Project$ tracker start --issue 42

If `--issue` is set and we can find an issue with this id in your current repo

- set or append the issue name in the task description ("Rev up FluxCompensator!!")
- add the issue id to the tasks tags ("issue#42")
- if `Git` is also used, determine a save branch name from the issue name, and change into this branch ("42-rev-up-fluxcompensator")
- assign to your user, if `set_assignee` is set and issue is not assigned
- reopen a closed issue if `reopen` is set
- modifiy the labels by adding all labels listed in `labels_on_start.add` and removing all lables listed in `labels_on_start.add`

# AUTHOR

Thomas Klausner <domm@plix.at>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2016 - 2021 by Thomas Klausner.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
