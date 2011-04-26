Purpose:
--------

ADOAuthorizeiOS is a static library designed to simplify going through the OAuth flow to get an access token. 
It borrows concepts from Ben Gottlieb's [Twitter-OAuth-iPhone](https://github.com/bengottlieb/Twitter-OAuth-iPhone).

Building/Running:
----------------

ADOAuthorizeiOS depends on several git submodules.
The steps to get up and running are:

     git clone https://github.com/adamvduke/ADOAuthorizeiOS.git
     cd ADOAuthorizeiOS
     git submodule init
     git submodule update

The submodules will be their own git repositories in the directories ADOAuthorizeiOS/External/