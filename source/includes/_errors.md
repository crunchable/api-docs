# Errors

Error Code | Meaning
---------- | -------
200 | OK -- Everything worked as expected.
400 | Bad Request -- The request was unacceptable, often due to missing a required parameter.
401 | Unauthorized -- No valid API key provided.
404 | Not Found -- The requested resource doesn't exist.
429 | Too Many Requests -- You're making too many requests! Slow down!
449 | Pending -- The response is still pending and does not yet exist. Try again later.
500 | Internal Server Error -- We had a problem with our server. Try again later.
503 | Service Unavailable -- We're temporarily offline for maintenance. Please try again later.
