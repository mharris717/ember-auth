describe 'Em.Auth.Request', ->
  auth    = null
  spy     = null
  request = null

  beforeEach ->
    Em.run ->
      auth = Em.Auth.create
        responseAdapter: 'dummy'
        strategyAdapter: 'dummy'
      request = auth._request
  afterEach ->
    auth.destroy() if auth
    sinon.collection.restore()

  follow 'adapter init', 'request'

  example 'request method injection', (method) ->
    it "injects #{method} method to Auth", ->
      expect(auth[method]).toBeDefined()

    it 'preserves args', ->
      spy = sinon.collection.spy request, method
      Em.run -> auth[method]('foo')
      expect(spy).toHaveBeenCalledWithExactly('foo')

  follow 'request method injection', 'signIn'
  follow 'request method injection', 'signOut'
  follow 'request method injection', 'send'

  example 'request server api', (type) ->
    describe "##{type}", ->
      beforeEach ->
        opts = { responseAdapter: 'dummy', strategyAdapter: 'dummy' }
        opts["#{type}EndPoint"] = '/foo'
        Em.run ->
          auth    = Em.Auth.create opts
          request = auth._request

      it 'resolves url', ->
        spy = sinon.collection.spy request, 'resolveUrl'
        request[type]('bar')
        expect(spy).toHaveBeenCalledWithExactly('/foo')

      it 'delegates to adapter', ->
        spy = sinon.collection.spy request.adapter, type
        request[type]('bar')
        expect(spy).toHaveBeenCalledWithExactly('/foo', 'bar')

  follow 'request server api', 'signIn'
  follow 'request server api', 'signOut'

  describe '#send', ->
    it 'delegates to adapter#send', ->
      follow 'adapter delegation', request, 'send', ['foo']
    it 'serializes opts', ->
      spy = sinon.collection.spy auth._strategy, 'serialize'
      request.send('foo')
      expect(spy).toHaveBeenCalledWithExactly('foo')

  describe '#resolveUrl', ->

    example 'request resolve url', ({ input, output, isAppend }) ->
      desc = if isAppend then 'appends path to baseUrl' else 'returns path'
      it desc, ->
        expect(auth._request.resolveUrl(input)).toEqual output
        expect(auth._request.resolveUrl("/#{input}")).toEqual output

    describe 'baseUrl defined with trialing slash', ->
      beforeEach -> Em.run -> auth = Em.Auth.create { baseUrl: 'foo/' }
      follow 'request resolve url',
      { input: 'bar', output: 'foo/bar', isAppend: true }

    describe 'baseUrl defined without trialing slash', ->
      beforeEach -> Em.run -> auth = Em.Auth.create { baseUrl: 'foo' }
      follow 'request resolve url',
      { input: 'bar', output: 'foo/bar', isAppend: true }

    describe 'baseUrl = null', ->
      beforeEach -> Em.run -> auth = Em.Auth.create { baseUrl: null }
      follow 'request resolve url',
      { input: 'bar', output: '/bar', isAppend: false }

    describe 'baseUrl = empty string', ->
      beforeEach -> Em.run -> auth = Em.Auth.create { baseUrl: '' }
      follow 'request resolve url',
      { input: 'bar', output: '/bar', isAppend: false }
