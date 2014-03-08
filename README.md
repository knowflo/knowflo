# Knowflo

Knowflo is a super basic Q&A platform for public and private groups. It
was developed (in a hurry!) to facilitate knowledge sharing for a couple
small communities.

It isn't pretty. It isn't really finished. Did I mention that we're happy
to accept pull requests? :)

## Public Server

There's a public hosted version of Knowflo running on
[Heroku](http://knowflo.info) that you can try out if you like. Note
that the public test group may be cleaned out from time to time.

## Configuration

You'll want to configure the Facebook and Algolia integrations (or disable
those components). If you're deploying on Heroku you can set these as
environment variables. See <code>config/settings/default.rb</code> for
app-specific configuration settings. You'll also want to configure the
mailer; out of the box it looks for <code>SENDGRID_USERNAME</code> and <code>SENDGRID_PASSWORD</code>.

## Note on Patches / Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Credits

Originally developed by Nick Plante with help from various other
[contributors](https://github.com/knowflo/knowflo/graphs/contributors).
