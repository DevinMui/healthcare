/**
 * App ID for the skill
 */
var request = require('request')
var APP_ID = "amzn1.echo-sdk-ams.app.6e053460-c529-470a-a1b8-273f6879b54a"; //replace with "amzn1.echo-sdk-ams.app.[your-unique-value-here]";
var norm_total_sodium = 10
var norm_total_total_fat = 10
var norm_total_sat_fat = 5
var norm_total_calcium = 5
/**
 * The AlexaSkill prototype and helper functions
 */
var AlexaSkill = require('./AlexaSkill');

/**
 * Hello is a child of AlexaSkill.
 * To read more about inheritance in JavaScript, see the link below.
 *
 * @see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Introduction_to_Object-Oriented_JavaScript#Inheritance
 */
var Hello = function () {
	AlexaSkill.call(this, APP_ID);
};

// Extend AlexaSkill
Hello.prototype = Object.create(AlexaSkill.prototype);
Hello.prototype.constructor = Hello;

Hello.prototype.eventHandlers.onSessionStarted = function (sessionStartedRequest, session) {
	console.log("Hello onSessionStarted requestId: " + sessionStartedRequest.requestId
		+ ", sessionId: " + session.sessionId);
	// any initialization logic goes here
};
/*
Hello.prototype.eventHandlers.onLaunch = function (launchRequest, session, response) {
	console.log("Hello onLaunch requestId: " + launchRequest.requestId + ", sessionId: " + session.sessionId);
	var speechOutput = "Welcome to the Alexa Skills Kit, you can say hello";
	var repromptText = "You can say hello";
	response.ask(speechOutput, repromptText);
};*/

Hello.prototype.eventHandlers.onSessionEnded = function (sessionEndedRequest, session) {
	console.log("Hello onSessionEnded requestId: " + sessionEndedRequest.requestId
		+ ", sessionId: " + session.sessionId);
	// any cleanup logic goes here
};

Hello.prototype.intentHandlers = {
	// are you healthy? what are you too high on and what should you consume
	"GetHealth": function (intent, session, response) {


		var options = {
			url: 'http://16e94129.ngrok.io/get_data'
		};
		request.get(options, function(err, res, body){
			if(!err){
				var statement = ""
				body = JSON.parse(body)
				var total_total_fat = body[0].total_total_fat
				var total_sodium = body[0].total_sodium
				var total_sat_fat = body[0].total_sat_fat
				var total_calcium = body[0].total_calcium

				if(norm_total_sodium - 2 > total_sodium){
					statement += "You should consume more salt. Go play league of legends. "
				} else if(norm_total_sodium + 2 < total_sodium){
					statement += "You fucking salty savage! "
				} else {
					statement += "You consumed just enough sodium. "
				}

				if(norm_total_total_fat - 2 > total_total_fat){
					statement += "You should consume more total fat. "
				} else if(norm_total_total_fat + 2 < total_total_fat){
					statement += "You're consuming too much total fat. "
				} else {
					statement += "You consumed just enough total fat. "
				}

				if(norm_total_sat_fat - 2 > total_sat_fat){
					statement += "Eat a bit more saturated fat. "
				} else if(norm_total_sat_fat + 2 < total_sat_fat){
					statement += "Are you our lord and savior, Gaben? Because you're eating a bit too much sat fat. "
				} else {
					statement += "You consumed just enough saturated fat. "
				}

				if(norm_total_calcium - 2 > total_calcium){
					statement += "Mr. Skeletal doesn't like you. Eat some more calcium. "
				} else if(norm_total_calcium + 2 < total_calcium) {
					statement += "Three spooky five me. You consumed a ton of calcium and became the next level Mr. Skeletal! "
				} else {
					statement += "You consumed just enough calcium. "
				}

				response.tellWithCard(statement);
			} else
				response.tellWithCard("Oh no. We could not reach the server")
		})

	}
};

// Create the handler that responds to the Alexa Request.
exports.handler = function (event, context) {
	// Create an instance of the Hello skill.
	var skill = new Hello();
	skill.execute(event, context);
};