var request = require("request")

var norm_total_sodium = 10
var norm_total_total_fat = 10
var norm_total_sat_fat = 5
var norm_total_calcium = 5

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
