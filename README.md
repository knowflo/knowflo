# Knowflow

Knowflow is a super basic Q&A platform for public and private groups. It
was developed (in a hurry!) to facilitate knowledge sharing for a couple
small communities.

It isn't pretty. It isn't really finished. Did I mention that we're happy
to accept pull requests? :)

## Public Server

There's a public hosted version of Knowflow running on
[Heroku](http://knowflo.info) that you can try out if you like. Note
that the public test group may be cleaned out from time to time.

## Configuration

Generate a secret for the cookie sessions using `rake secret` and add it to
your `.env` file like this:

    echo "SECRET_TOKEN: `rake secret`" >> .env

If you're deploying a production version of the site you'll want this value in
your ENV settings.

You'll need to configure the Facebook and Algolia integrations (or disable
those components). There are environment variables for these as well.
See `config/settings/default.rb` for the appropriate configuration value names.

Finally, you'll also need to configure the mailer. Out of hte box it looks for
`SENDGRID_USERNAME` and `SENDGRID_PASSWORD`. This will hopefully be more
flexible in the future.

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
