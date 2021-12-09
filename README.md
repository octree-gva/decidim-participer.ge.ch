<h1 align="center"><img src="https://github.com/octree-gva/meta/blob/main/decidim/static/header.svg?raw=true" alt="Decidim - Octree Participatory democracy on a robust and open source solution"></h1>
<h4 align="center">
    <a href="https://www.octree.ch">Octree</a> |
    <a href="https://octree.ch/en/contact-us/">Contact Us</a> |
    <a href="https://blog.octree.ch">Our Blog (FR)</a><br/><br/>
    <a href="https://decidim.org">Decidim</a> |
    <a href="https://docs.decidim.org/en/">Decidim Docs</a> |
    <a href="https://meta.decidim.org">Participatory Governance (meta decidim)</a><br/><br/>
    <a href="https://matrix.to/#/+decidim:matrix.org">Decidim Community (Matrix+Element.io)</a>
</h4>


<br/><br/>
This app is a Ruby on Rails app running [Decidim](decidim.org) for [participer.ge.ch](participer.ge.ch), the official participatory platform for the state of Geneva.
This app uses Octree's Decidim version, used for all Octree projects.

# Infrastructure

This application's infrastructure is under the responsibility of Office cantonal des systèmes d'information et du numérique (OCSIN). They fully deploy the application into their infrastructures after strict security pipelines. Underlying infrastructure can not be disclosed at this time.

# Docker

A docker image is used for deployment, the docker image is ready for production, with some common configurations for RoR production images. The docker image includes:

- ImageMagick configurations, to avoid ImageTragick issues on image manipulations and avoid Server-side interaction (see [https://thoughtbot.com/blog/paperclip-is-vulnerable-to-the-imagetragick-vulnerability](https://thoughtbot.com/blog/paperclip-is-vulnerable-to-the-imagetragick-vulnerability) and [https://imagetragick.com/](https://imagetragick.com/) for references)
- Non-root user and group to run the puma application (see docker docs [https://docs.docker.com/engine/install/linux-postinstall/](https://docs.docker.com/engine/install/linux-postinstall/) as references, and [https://engineering.bitnami.com/articles/why-non-root-containers-are-important-for-security.html#:~:text=So why would you do,on your server%2C for example](https://engineering.bitnami.com/articles/why-non-root-containers-are-important-for-security.html#:~:text=So%20why%20would%20you%20do,on%20your%20server%2C%20for%20example).)


# Core Customizations

This app uses an Octree version of Decidim, where we do as few changes as possible to stay near the main branch. The updates concern mainly theming and exploitation:

- The main body class has a class for each organization. This allows having multi-tenant instances with different custom themes
- [The theme](https://github.com/octree-gva/decidim-participer.ge.ch-theme) is customized to overload the Foundation for Sites library
- Logs of the system are done on a daily matter, to isolate issues faster
- Puma is optimized and uses a custom SSL certificate, served by the OCSIN


<br /><br />
<h4 align="center">
    <br /><br />
    <img src="https://github.com/octree-gva/meta/blob/main/decidim/static/participerge/mobile_participer_ge.svg?raw=true" /><br /><br />
    <img src="https://github.com/octree-gva/meta/blob/main/decidim/static/participerge/desktop_participer_ge.svg?raw=true" /><br /><br />
</h4>

<br /><br />
<p align="center">
    <img src="https://raw.githubusercontent.com/octree-gva/meta/main/decidim/static/octree_and_decidim.svg" height="90" alt="Decidim Installation by Octree" />
</p>