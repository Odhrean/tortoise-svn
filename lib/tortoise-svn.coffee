{CompositeDisposable} = require "atom"
path = require "path"
fs = require "fs"

tortoiseSvn = (args, cwd) ->
  spawn = require("child_process").spawn
  command = atom.config.get("tortoise-svn.tortoisePath") + "/TortoiseProc.exe"
  options =
    cwd: cwd

  tProc = spawn(command, args, options)

  tProc.stdout.on "data", (data) ->
    console.log "stdout: " + data

  tProc.stderr.on "data", (data) ->
    console.log "stderr: " + data

  tProc.on "close", (code) ->
    console.log "child process exited with code " + code

resolveTreeSelection = ->
  if atom.packages.isPackageLoaded("tree-view")
    treeView = atom.packages.getLoadedPackage("tree-view")
    treeView = require(treeView.mainModulePath)
    serialView = treeView.serialize()
    serialView.selectedPath

resolveEditorFile = ->
  editor = atom.workspace.getActivePaneItem()
  file = editor?.buffer.file
  file?.path

blame = (currFile)->
  stat = fs.statSync(currFile)
  args =  [ "/command:blame" ]
  if stat.isFile()
    args.push("/path:"+path.basename(currFile))
    cwd = path.dirname(currFile)
  else
    args.push("/path:.")
    cwd = currFile
  args.push("/startrev:1", "/endrev:-1") if atom.config.get("tortoise-svn.tortoiseBlameAll")
  tortoiseSvn(args, cwd)

commit = (currFile)->
  stat = fs.statSync(currFile)
  if stat.isFile()
    tortoiseSvn(["/command:commit", "/path:"+path.basename(currFile)], path.dirname(currFile))
  else
    tortoiseSvn(["/command:commit", "/path:."], currFile)

diff = (currFile)->
  stat = fs.statSync(currFile)
  if stat.isFile()
    tortoiseSvn(["/command:diff", "/path:"+path.basename(currFile)], path.dirname(currFile))
  else
    tortoiseSvn(["/command:diff", "/path:."], currFile)
#+
log = (currFile)->
  stat = fs.statSync(currFile)
  if stat.isFile()
    tortoiseSvn(["/command:log","/path:"+path.basename(currFile)], path.dirname(currFile))
  else
    tortoiseSvn(["/command:log","/path:."], currFile)


revert = (currFile)->
  stat = fs.statSync(currFile)
  if stat.isFile()
    tortoiseSvn(["/command:revert", "/path:"+path.basename(currFile)], path.dirname(currFile))
  else
    tortoiseSvn(["/command:revert", "/path:."], currFile)

update = (currFile)->
  stat = fs.statSync(currFile)
  if stat.isFile()
    tortoiseSvn(["/command:update", "/path:"+path.basename(currFile)], path.dirname(currFile))
  else
    tortoiseSvn(["/command:update", "/path:."], currFile)

module.exports = TortoiseSvn =
  config:
    tortoisePath:
      title: "Tortoise SVN bin path"
      description: "The folder containing TortoiseProc.exe"
      type: "string"
      default: "C:/Program Files/TortoiseSVN/bin"
    tortoiseBlameAll:
      title: "Blame all versions"
      description: "Default to looking at all versions in the file's history. Uncheck to allow version selection."
      type: "boolean"
      default: true

  activate: (state) ->
    atom.commands.add "atom-workspace", "tortoise-svn:blameFromTreeView": => @blameFromTreeView()
    atom.commands.add "atom-workspace", "tortoise-svn:blameFromEditor": => @blameFromEditor()

    atom.commands.add "atom-workspace", "tortoise-svn:commitFromTreeView": => @commitFromTreeView()
    atom.commands.add "atom-workspace", "tortoise-svn:commitFromEditor": => @commitFromEditor()

    atom.commands.add "atom-workspace", "tortoise-svn:diffFromTreeView": => @diffFromTreeView()
    atom.commands.add "atom-workspace", "tortoise-svn:diffFromEditor": => @diffFromEditor()

    atom.commands.add "atom-workspace", "tortoise-svn:logFromTreeView": => @logFromTreeView()
    atom.commands.add "atom-workspace", "tortoise-svn:logFromEditor": => @logFromEditor()

    atom.commands.add "atom-workspace", "tortoise-svn:revertFromTreeView": => @revertFromTreeView()
    atom.commands.add "atom-workspace", "tortoise-svn:revertFromEditor": => @revertFromEditor()

    atom.commands.add "atom-workspace", "tortoise-svn:updateFromTreeView": => @updateFromTreeView()
    atom.commands.add "atom-workspace", "tortoise-svn:updateFromEditor": => @updateFromEditor()

  blameFromTreeView: ->
    currFile = resolveTreeSelection()
    blame(currFile) if currFile?

  blameFromEditor: ->
    currFile = resolveEditorFile()
    blame(currFile) if currFile?

  commitFromTreeView: ->
    currFile = resolveTreeSelection()
    commit(currFile) if currFile?

  commitFromEditor: ->
    currFile = resolveEditorFile()
    commit(currFile) if currFile?

  diffFromTreeView: ->
    currFile = resolveTreeSelection()
    diff(currFile) if currFile?

  diffFromEditor: ->
    currFile = resolveEditorFile()
    diff(currFile) if currFile?

  logFromTreeView: ->
    currFile = resolveTreeSelection()
    log(currFile) if currFile?

  logFromEditor: ->
    currFile = resolveEditorFile()
    log(currFile) if currFile?

  revertFromTreeView: ->
    currFile = resolveTreeSelection()
    revert(currFile) if currFile?

  revertFromEditor: ->
    currFile = resolveEditorFile()
    revert(currFile) if currFile?

  updateFromTreeView: ->
    currFile = resolveTreeSelection()
    update(currFile) if currFile?

  updateFromEditor: ->
    currFile = resolveEditorFile()
    update(currFile) if currFile?
