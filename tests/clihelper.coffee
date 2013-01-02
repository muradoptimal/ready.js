{exec} = require 'child_process'
{inspect} = require 'util'
{log, dir} = console
path = require 'path'
fs = require 'fs'
_ = require '../node_modules/underscore'
fileExists = fs.exists || path.exists

r = 
  execute: (files, options={}, callback)->
    files = _.flatten [files]
    [callback, options] = [options, {}] unless callback?
    
    cmd = "./node_modules/.bin/coffee ./bin/ready.coffee #{files.join ' '}"
    cwd = path.resolve './'
    args = r.optionsToArgs options
    log "CMD : #{cmd} #{args}"
    exec "#{cmd} #{args}", {cwd:cwd}, (err, stdout, stderr)->
      err = null if err is ''
      stdout = null if stdout is ''
      
      # Read 'test/all.js' for stdout
      fileExists 'tests/all.js', (exists)->
        if exists
          fs.readFile 'tests/all.js', (err, data)->
            return callback(err) if err?
            data = data.toString()
        else              
          callback err, stdout
      
  optionsToArgs: (options)->
    _.map _.pairs(options), (option)->
      switch option[0]
        when 'recursive'
          if option[1] then '' else '--no-recursive'
        when 'analyze' 
          if option[1] then '' else '--no-analyze'
        when 'output'
          "--output #{option[1]}"
        when 'ignore'
          values = _.flatten [option[1]]
          "--ignore '#{values.join ' '}'"
        
        else throw "Option `#{option[0]}` not mapped"
  
module.exports = r
