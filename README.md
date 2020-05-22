
# Table of Contents

1.  [What is `home`](#h:0272c5ac-0b7f-4ebb-91f0-defa66c2d285)
2.  [Installation](#h:e289aa81-d0ec-49a0-ba94-933e85d4ee8c)
    1.  [`home-manager` only](#h:62ee62f0-7e1a-4abc-b289-ac24d12e733c)
    2.  [`nixos` only](#h:5529fb57-a55d-4b81-a164-e5d1104b7e0b)
3.  [Organization of the repository](#h:b74304bf-e7e6-4425-9123-e50eca3eb8fa)
4.  [References](#h:e5a95a68-f031-438b-831c-824803d0bc3e)
5.  [COPYING](#h:716e598e-3b1a-4e48-a72b-608c3a970db9)



<a id="h:0272c5ac-0b7f-4ebb-91f0-defa66c2d285"></a>

# What is `home`

This repository is the monorepo for my personal tools and infrastructure. It containers my
dotfiles, some tools and scripts. It is mainly based on `nix` and =home-manager=some shell
script and maybe sometimes ansible — especially on non-NixOS system.

The goal of is repository is to be able to have a way to setup dotfiles and packages in
*one go*, sharing those configuration between multiple computers. The documentation part
is using (or *will*) `org-mode` following principles of "literate programming": a
combination of ordinary language and inline code blocks.

On idea is also to try to do something like "[Leveraging disposability for exploration](https://willschenk.com/articles/2020/leveraging_disposability_for_exploration/)",
aka "how to play around without leaving a mess". I'll try my best to make everything
reproducible and easily testable without making *a mess*. Nix/NixOS should help with that…

This will be a all-time work-in-progress, so please beware that things might change
dramatically or even not working anymore 😛.

See [`./tasks.org`](./tasks.md) for the *work-in-progress* — and there is **a lot of work-in-progress**.


<a id="h:e289aa81-d0ec-49a0-ba94-933e85d4ee8c"></a>

# TODO Installation

*todo: rework that part, link to the `docs` folder*

You should be able to run the `bootstrap.sh` script as is. And if you feel adventurous,
you can use `curl` for this.

    curl https://gitlab.com/vdemeester/home/-/raw/master/bootstrap.sh | sh

Otherwise, clone this repository somewhere, read the `bootstrap.sh` file and execute it if
you feel safe


<a id="h:62ee62f0-7e1a-4abc-b289-ac24d12e733c"></a>

## TODO `home-manager` only

*todo: rework that part*

If you don't have `nix` installed, run `curl https://nixos.org/nix/install | sh` to install it.

-   clone this repository in `$HOME/.config/nixpkgs`
-   create a \`home.nix\` file with the content you want.
    Some machines files already exists that you can use :
    
        { pkgs, ... }:
        
        {
          imports = [
            ./machines/hokkaido.nix
          ];
        }

-   run `nix-shell https://github.com/rycee/home-manager/archive/master.tar.gz -A install` (maybe twice :D)
-   run `home-manager switch;`


<a id="h:5529fb57-a55d-4b81-a164-e5d1104b7e0b"></a>

## TODO `nixos` only

*todo: rework that part*


<a id="h:b74304bf-e7e6-4425-9123-e50eca3eb8fa"></a>

# Organization of the repository

This is probably gonna be a moving target, but this is how it looks (or should look
soon-ish 👼):

-   `assets`: ignored folder where my *automation* puts some *secrets*.
    Most of the `make` commands will try to populate this ahead of time. The assumption is :
    have a `sync` folder where the assets are. *Note: how to bootstrap (as syncthing will
    not be there, and the `sync` folder either)*
-   `docs`: holds documentation about this code, literate configuration, see [literate configuration](#orgc18f61e).
    `make publish` will publish the `README.org` and the `docs` folder to my website.
-   `lib`: shared code used during configuration (mostly `nix` code).
-   `machines`: configuration per machines
-   `modules`: holds nix modules (services, programs, hardware, profiles, …)
-   `overlays`: holds [nix overlays](https://nixos.wiki/wiki/Overlays)
-   `pkgs`: holds nix packages (those should migrate under `overlays` or on `nur-packages`)
-   `private`: holds non-shareable code, like *secrets*.
-   `tmp`: things to… organize (e.g. where I import my other *legacy* configuration)

<a id="orgc18f61e"></a>As I'm slowly, but <span class="underline">surely</span>, going to have `org-mode` files for
literate configuration files in this repository, I have to think of how to organize files
in order to end up with one huge file. The goal of having those `org-mode` files, is
mainly to document my configuration and publish it, most likely on [sbr.pm](https://sbr.pm).


<a id="h:e5a95a68-f031-438b-831c-824803d0bc3e"></a>

# References

Repositories

-   [https://github.com/lovesegfault/nix-config](https://github.com/lovesegfault/nix-config)
-   <https://github.com/utdemir/dotfiles>
-   <https://github.com/davidtwco/veritas>
-   <https://gitlab.com/samueldr/nixos-configuration>
-   <https://github.com/rasendubi/dotfiles>
-   <https://github.com/akirak/nixos-config>
-   <https://github.com/akirak/home.nix>
-   <https://github.com/cstrahan/nixos-config>
-   <https://github.com/jwiegley/nix-config>
-   <https://github.com/arianvp/nixos-stuff>
-   <https://github.com/leotaku/nixos-config>
-   <https://github.com/romatthe/ronix>
-   <https://github.com/rummik/nixos-config>
-   <https://git.tazj.in/about/>
-   <https://github.com/a-schaefers/nix-config.old>
-   <https://github.com/auntieNeo/nixrc>
    -   <https://github.com/glines/nixrc>
-   <https://github.com/therealpxc/pxc.nix.d>
-   <https://github.com/tycho01/nix-config>
-   <https://github.com/ghuntley/dotfiles-nixos>
-   <https://github.com/budevg/nix-conf>
-   <https://github.com/cleverca22/nixos-configs>
-   <https://github.com/coreyoconnor/nix_configs>
-   <https://github.com/danieldk/nix-home>
-   <https://github.com/dejanr/dotfiles>
-   <https://github.com/Ericson2314/nixos-configuration>
-   <https://gitlab.com/garry-cairns/nixos-config>
-   <https://github.com/grahamc/nixos-config>
-   <https://github.com/HugoReeves/nix-home>
-   <https://github.com/jwiegley/nix-config>
-   <https://github.com/kampfschlaefer/nixconfig>
-   <https://github.com/lambdael/nixosconf>
-   <https://github.com/puffnfresh/nix-files>
-   <https://github.com/talyz/nixos-config>
-   <https://github.com/uwap/nixos-configs>
-   <https://github.com/yacinehmito/yarn-nix>
-   <https://github.com/yrashk/nix-home>
-   <https://github.com/pSub/configs>
-   <https://github.com/periklis/nix-config>
-   <https://github.com/peel/dotfiles>
-   <https://github.com/bennofs/etc-nixos>
-   <https://github.com/Baughn/machine-config>


<a id="h:716e598e-3b1a-4e48-a72b-608c3a970db9"></a>

# COPYING

Copyright (c) 2018-2020 Vincent Demeester <vincent@sbr.pm>

This file is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

This file is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this file.  If not, see <http://www.gnu.org/licenses/>.

