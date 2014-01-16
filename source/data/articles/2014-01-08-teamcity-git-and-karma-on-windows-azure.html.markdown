---
layout: post
title: TeamCity, Git, and Karma, on Windows Azure
published: 1
categories: [JavaScript, Unit Testing]
comments: [disqus]
slug: "Setup a Windows Azure VM with TeamCity and integrate Karma as part of the CI process."
---

<u>Note</u>: After following this post, the end result is pretty awesome:

![Image](/images/articles/2014-01-08-azure-teamcity-angular-karma-17.png)

**Radio Edit (tl;dr)**

1. Create a new Virtual Machine on Windows Azure to install and access TeamCity.
2. Install NodeJS (x86) and make sure the installation adds Node, npm, and modules to the PATH environment variable.
3. Install Karma and karma-teamcity-reporter plugin.
4. Install Chrome.
5. Install Git and add its binaries folder to the PATH environment variable.
6. Log in to TeamCity.
 1. Create a Build Configuration on TeamCity.
 2. Create and attach new VCS root to the newly created Build Configuration.
 3. Add a Build Step and attach the newly created Build Configuration.
  1. In the runner type select Command Line.
  2. Set the working directory to Karma's config folder.
  3. In the run option select "Executable with parameters".
  4. In the command executable option enter `karma`.
  5. In the command parameters option enter `start karma.conf.js --reporters teamcity --single-run`.
7. Include the `karma-teamcity-reporter` plugin in the karma.conf.js file triggering that way also the build process.

**Club Mix (long version)**

Create a new Virtual Machine on Windows Azure to install and access TeamCity.

![Image](/images/articles/2014-01-08-azure-teamcity-angular-karma-1.png)

* Turn off Internet Explorer's Enhanced Security Configuration.
* Download and install NodeJS (x86).
 * Make sure the installation adds Node, npm, and modules to the PATH environment variable.

![Image](/images/articles/2014-01-08-azure-teamcity-angular-karma-3.png)

<ul>
<li>Install Karma and karma-teamcity-reporter plugin:<br><pre><code>  npm install -g karma
  npm install -g karma-teamcity-reporter
</code></pre></li>
</ul>

* Install Chrome (if you want to use Chrome with Karma).
* Install Git.
 * Make sure the installation adds Git to the PATH environment variable.

![Image](/images/articles/2014-01-08-azure-teamcity-angular-karma-4.png)

<u>Optional</u>: [Generate SSH keys](https://help.github.com/articles/generating-ssh-keys) if you use SSH keys to establish a secure connection between the Virtual Machine and Git.

Install TeamCity and choose a port so it can be accessed from a browser (e.g. port 80).

![Image](/images/articles/2014-01-08-azure-teamcity-angular-karma-5.png)

If you use SSH keys to establish a secure connection between the Virtual Machine and Git, make sure to run TeamCity Server under a user account that can access the path where the SSH keys are saved.

Use the `whoami` command in the Command Prompt to find out the Virtual Machine's domain name.

![Image](/images/articles/2014-01-08-azure-teamcity-angular-karma-6.png)

Add a new inbound rule to Windows Firewall with the TeamCity Server port that was entered during installation.

*The remaining steps can be also done from the browser.*

-----

 On Windows Azure Management Portal add a new endpoint with the selected TeamCity Server port that was entered during installation.

![Image](/images/articles/2014-01-08-azure-teamcity-angular-karma-7.png)

Log in to the TeamCity Server:

* Create a new project.
* Create a Build Configuration on TeamCity.
* Attach a new VCS root on Build Configuration for Git.

![Image](/images/articles/2014-01-08-azure-teamcity-angular-karma-8.png)

For the demo, I forked the [angular-phonecat](https://github.com/moodmosaic/angular-phonecat) project.

![Image](/images/articles/2014-01-08-azure-teamcity-angular-karma-9.png)

Select an authentication method and test the connection.

![Image](/images/articles/2014-01-08-azure-teamcity-angular-karma-10.png)
![Image](/images/articles/2014-01-08-azure-teamcity-angular-karma-11.png)

Add a Build Step and attach the newly created Build Configuration.

![Image](/images/articles/2014-01-08-azure-teamcity-angular-karma-12.png)

* In the runner type select Command Line.
* Set the working directory to Karma's config folder.
* In the run option select "Executable with parameters".
* In the command executable option enter `karma`.
* In the command parameters option enter `start karma.conf.js --reporters teamcity --single-run`.

![Image](/images/articles/2014-01-08-azure-teamcity-angular-karma-13.png)

As a last step, include the `karma-teamcity-reporter` plugin in the karma.conf.js file.

![Image](/images/articles/2014-01-08-azure-teamcity-angular-karma-14.png)

Push to Git to trigger the build process and see the commit on TeamCity Server.

![Image](/images/articles/2014-01-08-azure-teamcity-angular-karma-15.png)

The end result is pretty awesome:

![Image](/images/articles/2014-01-08-azure-teamcity-angular-karma-16.png)
![Image](/images/articles/2014-01-08-azure-teamcity-angular-karma-17.png)
