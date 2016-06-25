var express = require('express')
var bodyParser = require('body-parser')
var mongoose = require('mongoose')
var multer = require('multer')
var request = require('request')
var secret = require('secret')

// nutrient api: https://api.nutritionix.com/v1_1/search/cheddar%20cheese?fields=item_name%2Citem_id%2Cbrand_name%2Cnf_calories%2Cnf_total_fat&appId=[YOURID]&appKey=[YOURKEY]

var nutrient_api_id = secret.nutrient_api_id
var nutrient_api_key = secret.nutrient_api_key

var dataSchema = new mongoose.Schema({
	sodium: Number,
	total_fat: Number,
	trans_fat: Number,
	sat_fat: Number,
	cholesterol: Number,
	carbs: Number,
	protein: Number,
	vit_a: Number,
	vit_c: Number,
	calcium: Number,
	iron: Number,
},
{
	timestamps: true
})

var Data = mongoose.model('Data', dataSchema)

var app = express()

app.use(bodyParser.json())
app.use(express.static('public'))

mongoose.connect('mongodb://localhost/test')

var storage = multer.diskStorage({
	destination: function(req, file, cb){
		cb(null, 'public/uploads/')
	},
	filename: function(req, file, cb){
		crypto.pseudoRandomBytes(16, function (err, raw) {
			cb(null, raw.toString('hex') + Date.now() + '.jpg')
		});
	}
})

app.get('/', function(req, res){
	// call pokitdok api
	// for doctor visit
	res.send("hi")
})

app.get('/get_data', function(req,res){
	// give data

})

app.get('/analyse_data', function(req,res){
	// compare values of datas from mongo
	// little algorithm
})

app.post('/add_data', function(req, res){
	var food = req.body.food
	request('https://api.nutritionix.com/v1_1/search/' + food, function(err, res, body){
		if (!error && response.statusCode == 200) {
			var id = body.hits[0]._id
			request('https://api.nutritionix.com/v1_1/item?id=' + id, function(err, res, body){
				if (!error && response.statusCode == 200) {
					var sodium = body.nf_sodium
					var total_fat = body.nf_total_fat
					var trans_fat = body.nf_trans_fatty_acid
					var sat_fat = body.nf_saturated_fat
					var cholesterol = body.nf_cholesterol
					var carbs = body.nf_total_carbohydrate
					var protein = body.nf_protein
					var vit_a = body.nf_vitamin_a_dv
					var vit_c = body.nf_vitamin_c_dv
					var calcium = body.nf_calcium_dv
					var iron = body.nf_iron_dv
					// get the variables
					var data = new Data({
						sodium: sodium,
						total_fat: total_fat,
						trans_fat: trans_fat,
						sat_fat: sat_fat,
						cholesterol: cholesterol,
						carbs: carbs,
						protein: protein,
						vit_a: vit_a,
						vit_c: vit_c,
						calcium: calcium,
						iron: iron,
					})

					data.save()

					res.send("yee")
				} else {
					res.send("shit")
				}
			})
		} else {
			res.send("shit")
		}
	})
})

app.listen(3000, function(){
	console.log("ayy")
})