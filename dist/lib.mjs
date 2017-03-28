import connect from 'connect';
import http from 'http';
import serveStatic from 'serve-static';

// src/ci.coffee
var ci = function(opts) {
  return task('test:ci', 'Run tests', function(opts) {
    return invoke('test', {
      bail: true,
      coverage: true,
      ci: true
    });
  });
};

// src/server.coffee
var server$1 = function(opts) {
  var ref;
  if (opts.port == null) {
    opts.port = (ref = process.env.PORT) != null ? ref : 3333;
  }
  if (opts.dir == null) {
    opts.dir = process.cwd() + '/test/fixtures';
  }
  if (opts.message == null) {
    opts.message = 'Run static server for tests';
  }
  if (opts.name == null) {
    opts.name = 'static-server';
  }
  return task(opts.name, opts.message, function(cb) {
    var app;
    app = connect();
    app.use(serveStatic(opts.dir));
    return http.createServer(app).listen(opts.port, cb);
  });
};

// src/test.coffee
var test = function(opts) {
  return task('test', 'Run tests', function*(opts) {
    var addons, bail, bin, cmd, coverage, env, grep, k, ref, ref1, ref2, ref3, ref4, ref5, status, test, v, verbose;
    bail = (ref = opts.bail) != null ? ref : true;
    coverage = (ref1 = opts.coverage) != null ? ref1 : false;
    grep = (ref2 = opts.grep) != null ? ref2 : '';
    test = (ref3 = opts.test) != null ? ref3 : 'test/';
    verbose = (ref4 = opts.verbose) != null ? ref4 : '';
    if (opts.requireBuild) {
      yield invoke('build');
    }
    if (opts.serveStatic) {
      yield invoke('static-server', opts.serveStatic);
    }
    bin = 'mocha';
    if (bail) {
      bail = '--bail';
    }
    if (grep) {
      grep = "--grep " + opts.grep;
    }
    env = {
      NODE_ENV: 'test'
    };
    if (verbose) {
      env.VERBOSE = 'true';
    }
    addons = ['--compilers coffee:coffee-script/register', '--require co-mocha'];
    if (coverage) {
      bin = 'istanbul --print=none cover _mocha --';
      addons.push('--require coffee-coverage/register-istanbul');
    } else {
      addons.push('--require postmortem/register');
    }
    ref5 = opts.env;
    for (k in ref5) {
      v = ref5[k];
      env[k] = v;
    }
    env = ((function() {
      var results;
      results = [];
      for (k in env) {
        v = env[k];
        results.push(k + '=' + v);
      }
      return results;
    })()).join(' ');
    cmd = env + " " + bin + " --colors --reporter spec --timeout 10000000 " + (addons.join(' ')) + " --recursive " + bail + " " + grep + " " + test;
    status = (yield exec.interactive(cmd)).status;
    if (opts.serveStatic) {
      server.close();
    }
    if (status) {
      return process.exit(status);
    }
  });
};

// src/watch.coffee
var watch = function(opts) {
  return task('test:watch', 'watch for changes and re-run tests', function() {
    invoke('watch');
    return require('vigil').watch(__dirname, function(filename, stats) {
      if (/^src/.test(filename)) {
        invoke('test');
      }
      if (/^test/.test(filename)) {
        return invoke('test', {
          test: filename
        });
      }
    });
  });
};

// src/index.coffee
var index = function(opts) {
  if (opts == null) {
    opts = {};
  }
  ci(opts);
  server$1(opts);
  test(opts);
  return watch(opts);
};

export default index;
//# sourceMappingURL=lib.mjs.map
