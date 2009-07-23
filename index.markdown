---
layout: default
syntax: tango
foreground: "#E627A6"
#background: "#FFD4FF"
background: "#000000"
author: blindgaenger
date: 2009-07-23
homepage: http://blindgaenger.github.com/glitter
title: glitter
subtitle: Git-Like Interface for Twitter
tags:
- git
- twitter
- command line
- cli
- ruby
---

What is it?
------------

The idea is to think about [Twitter](http://www.twitter.com/) as a 
[Git](http://git-scm.com/) repository. So you can commit your status and view 
your friends commits in the log. Just for fun to see how far this can go!

At first you have to init your repo (resp. register glitter with your twitter 
account). This has to be done only once, just follow the on-screen instructions. 

{% highlight bash %}
$ glitter init
{% endhighlight %}

Now look what other committers did (resp. show the other's tweets).

{% highlight bash %}
$ glitter log
commit 2799873378
Author: codinghorror <Jeff Atwood>
Date:   Thu Jul 23 15:29:12 +0000 2009

    reminder: anyone who would like to beta test http://superuser.com , password
    is here http://is.gd/1J0yR

commit 2799553049
Author: TechCrunch <Michael Arrington>
Date:   Thu Jul 23 15:09:52 +0000 2009

    The Song of the PowerSquid: The Inside Story of the Life of an Invention 
    http://tcrn.ch/NuB by Guest Author

commit 2799436673
Author: olabini <Ola Bini>
Date:   Thu Jul 23 15:02:53 +0000 2009

    SUCCESS. Switching from Jacc to Jay removed another bottleneck. Yecht is now
    about 5% faster than Syck and JvYAMLb.

{% endhighlight %}

Or commit something (post your status to twitter).

{% highlight bash %}
$ glitter commit -m "command line fun with #glitter on #twitter"
{% endhighlight %}

As you can see there is no need to stage <span class="highlight">$ git add .</span>
something for now. But if you've an idea what it could be used for, let me know! 


Download
--------

You can download this project in either [zip]({{ page.homepage }}/zipball/master) 
or [tar]({{ page.homepage }}/tarball/master) formats. Or you can also clone the 
project with Git by running:

{% highlight bash %}
$ git clone git://github.com/blindgaenger/glitter
{% endhighlight %}


Installation
------------

Currently this is a little tricky and non standard. Because I had to change some 
libraries to get things done. Therefore glitter depends on two submodules until the 
changes will be merged.

The first change is to rely on a fork of the [twitter gem](http://github.com/jnunemaker/twitter).
Because Twitter updated to OAuth 1.0a, but the gem doesn't support this yet.

The other submodule is my own fork of GLI, which is a library by 
[davetron5000](http://davetron5000.github.com/) to build the Git like command 
line interfaces. Nice!

{% highlight bash %}
$ git clone git://github.com/blindgaenger/glitter.git
$ git submodule init
$ git submodule update
{% endhighlight %}

Now you have your own copy of glitter. When I resolved the dependencies I'll 
assemble a gem. Promised! 


