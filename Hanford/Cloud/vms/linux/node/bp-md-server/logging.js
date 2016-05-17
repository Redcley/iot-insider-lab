'use strict';

//
// Author: Sean Kelly
// Copyright (c) 2016 by Microsoft. All rights reserved.
// Licensed under the MIT license.
// See LICENSE file in the project root for full license information.
//

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
};

function out() {
  console.log.apply({}, arguments);
};

module.exports.err = err;
module.exports.out = out;
