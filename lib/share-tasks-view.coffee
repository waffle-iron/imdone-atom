{$, $$, $$$, View, TextEditorView} = require 'atom-space-pen-views'
{Emitter} = require 'atom'
util = require 'util'
Client = require './services/imdoneio-client'

module.exports =
class ShareTasksView extends View
  @content: (params) ->
    @div class: "share-tasks-container", =>
      @div outlet:'login-pane', class: 'block imdone-login-pane', =>
        @div class: 'input-med', =>
          @subview 'emailEditor', new TextEditorView(mini: true, placeholderText: 'email')
        @div class: 'input-med', =>
          @subview 'passwordEditor', new TextEditorView(mini: true, placeholderText: 'password')
        @div class:'btn-group btn-group-login', =>
          @button outlet: 'loginButton', click: 'login', title: 'WHOOSH!', class:'btn btn-primary inline-block-tight', 'LOGIN'

  initialize: ({@imdoneRepo, @path, @uri}) ->
    @emitter = new Emitter
    @initPasswordField()
    @handleEvents()
    @client = new Client
    @emailEditor.focus()
    
  initPasswordField: () ->
    # [Password fields when using EditorView subview - packages - Atom Discussion](https://discuss.atom.io/t/password-fields-when-using-editorview-subview/11061/7)
    passwordElement = $(@passwordEditor.element.rootElement)
    passwordElement.find('div.lines').addClass('password-lines')
    @passwordEditor.getModel().onDidChange =>
      string = @passwordEditor.getModel().getText().split('').map(->
        '*'
      ).join ''

      passwordElement.find('#password-style').remove()
      passwordElement.append('<style id="password-style">.password-lines .line span.text:before {content:"' + string + '";}</style>')

  login: () ->
    email = @emailEditor.getModel().getText()
    password = @passwordEditor.getModel().getText()
    @client.authenticate email, password

  handleEvents: () ->
    self = @
    @emailEditor.on 'keydown', (e) =>
      code = e.keyCode || e.which
      return true unless code == 9
      self.passwordEditor.focus()
      false

    @passwordEditor.on 'keydown', (e) =>
      code = e.keyCode || e.which
      return true unless code == 9
      self.loginButton.focus()
      false

    @loginButton.on 'keydown', (e) =>
      code = e.keyCode || e.which
      return true unless code == 9
      self.emailEditor.focus()
      false