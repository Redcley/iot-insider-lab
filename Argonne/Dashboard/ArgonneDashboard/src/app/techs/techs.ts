class Tech {
    constructor(
        public logo: string,
        public title: string,
        public text1: string,
        public text2: string
    ) { }
}


class TechsController {
    public techs: Tech[];
    public testString: string;

    constructor(private $http: angular.IHttpService, private $window: angular.IWindowService) {
        debugger;
        this.testString = "Rashid";
        $http
            .get('src/app/techs/techs.json')
            .then(response => {
                this.techs = response.data as Tech[];
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
}

export const techs: angular.IComponentOptions = {
    templateUrl: 'src/app/techs/techs.html',
    controller: ['$http', TechsController]
};
