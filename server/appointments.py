import pokitdok
import secret

pd = pokitdok.api.connect(secret.pokitdok_api_id, secret.pokitdok_api_secret)

print pd.appointments(appointment_type='SS1', start_date='2015-01-25T08:00:00',
	end_date='2015-01-25T17:00:00', patient_uuid='8ae236ff-9ccc-44b0-8717-42653cd719d0')