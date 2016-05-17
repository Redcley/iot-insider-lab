'use strict';


function isAdmin(req) {
  if (req.hostname === "hanford.iotinsiderlab.com") {
    return true;
  }
  return false;
};

module.exports.isAdmin = isAdmin;
