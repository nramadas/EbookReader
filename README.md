# Simple Pub
## An ePub reader
### [Deployed on Heroku](simple.herokuapp.com)

## Features
* De-duplication of ebooks
* Omniauth login for Google and Dropbox
* Dropbox integration
    * Books that are in dropbox folder are auto-added
* Multiple file upload with drag and drop ability
* Delayed Jobs for pulling books from Dropbox
* Dynamic pagination
    * Book remembers where you stopped reading
* Loads current chapter first, to speed up render times
* Responsive design looks great on all devices

## Technology Used
* Rails
* JavaScript/Coffescript
* jQuery
* Google Oauth2
* Dropbox API
* Delayed Jobs
* AJAX
* Devise
* SCSS
* Postgres