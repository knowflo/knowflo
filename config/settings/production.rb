default = Configuration.load('default')
Configuration.for('production', default) do
  # customize production settings here
  # NOTE: these will be overidden if ENV settings exist on Heroku
end
