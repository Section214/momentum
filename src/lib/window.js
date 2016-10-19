/**
 * Window handler
 *
 * @author      Daniel J Griffiths <dgriffiths@getmomentum.io>
 * @since       0.0.1
 */


'use strict';


require('pkginfo')(module, 'version');


const electron      = require('electron');
const BrowserWindow = electron.BrowserWindow;
const windowParams  = {
    width:       900,
    height:      600,
    show:        false,
    title:       'Momentum - ' + module.exports.version,
    skipTaskbar: true
};

let loadingScreen = null;


/**
 * Window class
 *
 * @since       0.0.1
 */
class window {

    /**
     * Create the application window
     *
     * @since       0.0.1
     * @return      {void}
     */
    createWindow() {
        this.createLoadingScreen();
        this.createMainWindow();
    }


    /**
     * Create a pretty loading screen
     *
     * @since       0.0.1
     * @return      {void}
     */
    createLoadingScreen() {
        loadingScreen = new BrowserWindow(Object.assign(windowParams, {parent: global.momentum.window}));

        loadingScreen.loadURL('file://' + global.momentum.path + '/lib/loading.html');
        loadingScreen.on('closed', () => loadingScreen = null);
        loadingScreen.webContents.on('did-finish-load', () => {
            loadingScreen.show();
        });
    }


    /**
     * Create the main content window
     *
     * @since       0.0.1
     * @return      {void}
     */
    createMainWindow() {
        global.momentum.window = new BrowserWindow(windowParams);

        global.momentum.window.loadURL('file://' + global.momentum.path + '/lib/index.html');
        global.momentum.window.webContents.on('did-finish-load', () => {
            global.momentum.window.show();

            if (loadingScreen) {
                let loadingScreenBounds = loadingScreen.getBounds();

                global.momentum.window.setBounds(loadingScreenBounds);
                loadingScreen.close();
            }
        });

        // Open the dev tools
        global.momentum.window.webContents.openDevTools();

        // Emitted when the window is closed
        global.momentum.window.on('closed', function() {
            global.momentum.window = null;
        });
    }
}

module.exports = new window();
