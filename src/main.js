/**
 * Momentum - Local development perfected
 * Copyright (C) 2016 Section214, LLC
 *
 * @author      Daniel J Griffiths <dgriffiths@getmomentum.io>
 * @version     0.0.1
 */


'use strict';


// Require all the things!
const electron      = require('electron');


// Setup globals... the fewer the better!
global.momentum      = {};
global.momentum.path = __dirname;
global.momentum.app  = electron.app;


// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
global.momentum.window = null;


// On OSX it's common to recreate a window in the app when the dock icon is
// clicked and there are no other windows open.
global.momentum.app.on('activate', function () {
    if (global.momentum.window === null) {
        global.momentum.window = require(global.momentum.path + '/lib/window.js');

        global.momentum.window.createWindow();
    }
});


// Go!
global.momentum.app.on('ready', function() {
    global.momentum.window = require(global.momentum.path + '/lib/window.js');

    global.momentum.window.createWindow();
});


// Quit when all windows are closed.
global.momentum.app.on('window-all-closed', function () {
    if (process.platform !== 'darwin') {
        global.momentum.app.quit();
    }
});
