---
title: Self-Updating Go Binaries with go-selfupdate
author: Bob Zoller
layout: post
disqus:
  shortname: goodeggsbytes
  url: "http://bites.goodeggs.com/post/self-updating-go-binaries-with-go-selfupdate"
---

The main developer interface to our bespoke PaaS (called Ranch) is a command line binary written in Go.  At first, a Homebrew recipe was plenty convienent to get it onto my early adopter's OSX laptops.  Once I had a few more users and some Linux hosts (CI/CD), however, I wanted to create a built-in update command.

In this post I'll cover how I built the update command, added it to my pre-existing [goxc](https://github.com/laher/goxc)-based build & release flow, and touch on a few improvements I'd like to make down the road.

<!-- more -->

I experimented with a few OSS libraries and considered using the [equinox.io](https://equinox.io/) service, but ended up settling on a simple library called [go-selfupdate](https://github.com/sanbornm/go-selfupdate).

When I say simple I mean simple: go-selfupdate exposes one public API: [`BackgroundRun`](https://github.com/sanbornm/go-selfupdate/blob/master/selfupdate/selfupdate.go#L98).  This method checks a remote HTTP server for a new version, downloads a binary patch if one was found, and applies it in-place.  `BackgroundRun` is meant to be called as a go subroutine, but I'm not a fan of CLIs that update this way.  Instead, I call it inline as part of an explicit `update` command.

I hit one snag along the way that caused me to fork go-selfupdate: it uses an internally-managed TTL and will only check for updates once every 24 hours.  Since I wanted my users to grab updates explicitly, I [patched](https://github.com/sanbornm/go-selfupdate/pull/18) in a `ForceCheck` option and set that to `true`:

```
diff --git a/selfupdate/selfupdate.go b/selfupdate/selfupdate.go
index 86646f3..4871c90 100644
--- a/selfupdate/selfupdate.go
+++ b/selfupdate/selfupdate.go
@@ -81,6 +81,7 @@ type Updater struct {
        BinURL         string    // Base URL for full binary downloads.
        DiffURL        string    // Base URL for diff downloads.
        Dir            string    // Directory to store selfupdate state.
+       ForceCheck     bool      // Check for update regardless of cktime timestamp
        Requester      Requester //Optional parameter to override existing http request handler
        Info           struct {
                Version string
@@ -117,7 +118,7 @@ func (u *Updater) BackgroundRun() error {
 
 func (u *Updater) wantUpdate() bool {
        path := u.getExecRelativeDir(u.Dir + upcktimePath)
-       if u.CurrentVersion == "dev" || readTime(path).After(time.Now()) {
+       if u.CurrentVersion == "dev" || (!u.ForceCheck && readTime(path).After(time.Now())) {
                return false
        }
        wait := 24*time.Hour + randDuration(24*time.Hour)
```

## The `update` Command

The `update` command itself is basically a one-liner.  Here's what it looks like:

```
updater := &selfupdate.Updater{
	CurrentVersion: VERSION,
	ApiURL:         "http://ranch-updates.goodeggs.com/stable/",
	BinURL:         "http://ranch-updates.goodeggs.com/stable/",
	DiffURL:        "http://ranch-updates.goodeggs.com/stable/",
	Dir:            ".ranch-selfupdate/",
	CmdName:        "ranch",
	Requester:      &HTTPRequester{},
	ForceCheck:     true,
}

return updater.BackgroundRun()
```

* `VERSION` is managed by goxc.  By defining the variable in my `main.go`, goxc will override it at build time, eg `var VERSION = "dev"`
* The URLs point at a plain 'ol static HTTP server (in this case an S3 bucket)
* `Dir` is the name of a directory relative to the binary where go-selfupdate will place its metadata
* `CmdName` is, duh, the name of my binary
* go-selfupdate provides a squeltched default for `Requester`, but I choose to pass in my own so I see log lines when it is doing work
* `ForceCheck` is set to `true`, as I discussed earlier

## Building a New Version

As I said, I'm using goxc for my build pipeline.  It does handy things like cross-compilation and creating Github Releases.  There was a little trick to getting go-selfupdate working with it, however.

The built-in `package` goxc task (which itself is included in `default`) is a meta task that includes removing the binaries once the packages are built.  This is a problem because go-selfupdate needs those binaries.  So I override `Tasks` to include everything in `default` and `package` except for the troublesome `rmbin`:

```
"Tasks": [
	"validate",
	"compile",
	"archive-zip",
	"archive-tar-gz",
	"publish-github"
],
```

A nice bit about go-selfupdate is it will generate binary patches so updates between versions are as small (and downloads quick) as possible.  The catch here is it needs all previous binaries to exist locally so it can generate those diffs.  The other catch is go-selfupdate expects the binaries in a different location than goxc generates them.

To resolve the first, I use `aws s3 sync` to ensure my local directory is up to date before generating new patches, and then again to upload all the latest files to S3.

The second is a simply copy of the goxc binaries to the location go-selfupdate is expecting.  Here's the bit of shell script I use to do this:

```
version=$(cat .goxc.json | jq -r '.PackageVersion')

goxc

echo "syncing ranch-updates S3 bucket"
aws s3 sync s3://ranch-updates.goodeggs.com/stable/ranch/ public/

echo "go-selfupdate generating bindiffs"
mkdir releases/${version}/bins
cp releases/${version}/darwin_amd64/ranch releases/${version}/bins/darwin-amd64
cp releases/${version}/linux_amd64/ranch releases/${version}/bins/linux-amd64
go-selfupdate releases/${version}/bins/ ${version}

echo "syncing ranch-updates S3 bucket"
aws s3 sync --acl public-read public/ s3://ranch-updates.goodeggs.com/stable/ranch/
```

And with that, any `ranch` binaries in the wild can update themselves to the latest version with a simple `ranch update`.

## Future Improvements

go-selfupdate is simple, and perhaps a little too much so.  Here are a few things on my mind:

1. I'd like to check for updates but not apply them directly, but it provides no method for this.
2. I'd like a return value from `BackgroundUpdate` (probably `ForegroundUpdate` now) to indicate whether an update happened or not, so that I can warn the user or restart the binary directly on the new version.
3. The `HTTPRequester` logging is workable, but a first-class logging solution would be better.
4. Binary patches take longer to generate with each new version (N*N).  Perhaps the solution here is to make my scripts smarter and only keep around the last N versions locally with which to generate binary patches.  go-selfupdate already supports this, as it will fall back to a full download if the patch file does not exist.
5. Release Channels.  If you look for the word `stable` in the above code snippets, I think you'll see how go-selfupdate makes it easy to support release channels.

---

Want to help us build a bespoke PaaS and put more of the $50B US grocery spend into sustainable local food systems?  Get in touch!  [We're hiring](http://careers.goodeggs.com/open-positions/).
