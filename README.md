# Github "Export Godot Project" Action

This repo contains the content for the action to create a release of a Godot project.

## Parameters

|Parameter|Description|Required|Default|
|---------|-----------|-|-|
|project-directory|Base directory relative to the base directory of the git repository|true|./|
|export-debug|Export with "debug" symbols|false|""|
|export-pack|Export just the .pck/.zip file|false|""|
|export-platform|Export for platform (.pck + .exe)|false|(yes)
|platform|Platform to export for (from export_presets.cfg)|true|Linux/X11|
|executable-name|Name of executable (for windows append '.exe')|true|"game"|
|godot-version|Version of godot to use (docker)|true|3.4
|base-docker|base docker container url|false|ghcr.io/kuhnchris/godot-github-ci-actions

## Example

[Over here](https://github.com/kuhnchris/github-godot-example-project)
