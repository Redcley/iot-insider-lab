"use strict";
var Tech = (function () {
    function Tech(logo, title, text1, text2) {
        this.logo = logo;
        this.title = title;
        this.text1 = text1;
        this.text2 = text2;
    }
    return Tech;
}());
var TechsController = (function () {
    function TechsController($http, $window) {
        var _this = this;
        this.$http = $http;
        this.$window = $window;
        debugger;
        this.testString = "Rashid";
        $http
            .get('src/app/techs/techs.json')
            .then(function (response) {
            _this.techs = response.data;
        });
        /*debugger;

        // Declare a proxy to reference the hub.
        var chat = $.connection.argonneHub;
        // Create a function that the hub can call to broadcast messages.
        chat.client.broadcastMessage = function (name, message) {
            // Html encode display name and message.

            var encodedName = $('<div />').text(name).html();
            var encodedMsg = $('<div />').text(message).html();
            // Add the message to the page.
            $('#discussion').append('<li><strong>' + encodedName
                + '</strong>:&nbsp;&nbsp;' + encodedMsg + '</li>');
        };
        // Get the user name and store it to prepend to messages.
        $('#displayname').val(prompt('Enter your name:', ''));
        // Set initial focus to message input box.
        $('#message').focus();
        // Start the connection.
        $.connection.hub.start().done(function () {
            $('#sendmessage').click(function () {
                // Call the Send method on the hub.
                chat.server.send($('#displayname').val(), $('#message').val());
                // Clear text box and reset focus for next comment.
                $('#message').val('').focus();
            });
        });*/
    }
    return TechsController;
}());
exports.techs = {
    templateUrl: 'src/app/techs/techs.html',
    controller: ['$http', TechsController]
};
//# sourceMappingURL=techs.js.map