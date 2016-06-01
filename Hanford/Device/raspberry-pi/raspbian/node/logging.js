'use strict';

// utility to standardize our logging so we always have stack traces
// available for errors.
function err() {
  var failure = {};
  var args = [ "\n" + "-".repeat(80) + "\n" ];

  Array.prototype.push.apply(args, arguments);

  Error.captureStackTrace(failure);
  args.push("\nat stack\n")
  args.push(failure.stack);

  console.error.apply({}, args);
  process.exit();
};

function out() {
  // Uncomment for debugging
  //console.log.apply({}, arguments);
};

module.exports.err = err;
module.exports.out = out;
