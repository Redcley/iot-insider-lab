'use strict';

//
// Author: Sean Kelly
// Copyright (c) 2016 by Microsoft. All rights reserved.
// Licensed under the MIT license.
// See LICENSE file in the project root for full license information.
//

// Rather than use the template plugin of the day and
// potentially make this sample harder to undeerstand,
// instead, employ a minimal amount of html formatting.
function applyLayout(body) {
  return `<html><head><title>IoT Management Console</title></head><body>${body}</body></html>`;
};

function makeTable(rows) {
  return `<table border=1>${rows}</table>`;
};

function makeRow(cols) {
  return `<tr>${cols}</tr>`;
};

function makeCol(content, cols) {
  if (cols) {
    return `<td colspan=${cols}>${content}</td>`;
  }
  return `<td>${content}</td>`;
};

function makeLink(uri, label) {
  return `<a href=\"${uri}\">${label}</a>`;
};

function makeForm(action, inputs) {
  return `<form action="${action}" method="POST">${inputs}</form>`;
};

function makeTextInput(id, name) {
  return `<label for="${id}">${name}</label><input type="text" name="${id}">`;
};

function makeChoice(id, name, choices) {
  var result = `<label for="${id}">${name}</label><select name="${id}">`;
  choices.forEach(function(val){
    result += `<option value="${val}">${val}</option>`;
  });
  result += "</select>";
  return result;
};

function makeHidden(id, name, value) {
  return `<input type="hidden" name="${id}" value="${value}">`;
};

function makeSubmitButton(name) {
  return `<input type="submit" value="${name}">`;
}

function renderTable(table) {
  var rows = "";
  table.forEach(function (row) {
    var cols = "";
    row.forEach(function (col) {
      cols += makeCol(col);
    })
    rows += makeRow(cols);
  });
  return makeTable(rows);
};

function renderArrayAsTable(arr) {
  var table = [];
  table.push(["Index", "Value"]);
  arr.forEach(function (value, index) {
    table.push([index, renderValue(value)]);
  })
  return renderTable(table);
};

function renderObjectAsTable(obj) {
  var table = [];
  table.push(["Property", "Value"]);
  Object.keys(obj).forEach(function (key) {
    table.push([key, renderValue(obj[key])]);
  });
  return renderTable(table);
};

function renderValue(value) {
  if (Array.isArray(value)) {
    return renderArrayAsTable(value);
  }
  if (value !== null && typeof value === "object") {
    return renderObjectAsTable(value);
  }
  return String(value);
};

module.exports.applyLayout = applyLayout;
module.exports.makeTable = makeTable;
module.exports.makeRow = makeRow;
module.exports.makeCol = makeCol;
module.exports.makeLink = makeLink;

module.exports.makeForm = makeForm;
module.exports.makeTextInput = makeTextInput;
module.exports.makeChoice = makeChoice;
module.exports.makeHidden = makeHidden;
module.exports.makeSubmitButton = makeSubmitButton;

module.exports.renderTable = renderTable;
module.exports.renderValue = renderValue;
