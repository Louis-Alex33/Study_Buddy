// Load all the channels within this directory and all subdirectories.
// Channel files must be named *_channel.js.

import consumer from "./consumer"

// Make consumer available globally as App.cable
window.App = window.App || {}
window.App.cable = consumer
