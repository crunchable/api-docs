---
title: API Reference

language_tabs:
  - http: HTTP
  - shell: Shell
  - javascript: Node

toc_footers:
  - <a href='https://crunchable.io/dev-console/#/register'>Sign Up for a Developer Key</a>
  - <a href='https://github.com/tripit/slate'>Documentation Powered by Slate</a>

includes:
  - errors

search: true
---

# Introduction

Welcome to the Crunchable.io API!

# Authentication

Every API call must be authenticated by including your secret API key in the request. You can manage your API keys in the [Developer Console](https://crunchable.io/dev-console/).

Authentication of an API call is performed using HTTP headers. Provide your API key as a custom HTTP header named `X-Crunch-API-Key`. You can keep your key secure by making API calls over SSL (HTTPS) as this will encrypt the entire request, headers included.

A sample test API key is included in all the examples on this page, so you can test any example right away. To test requests using your account, replace the sample API key with your actual API key.

# Staging Environment

> This call runs on staging because the API key starts with `test_`

```http
POST /v1/requests/multiple-choice?block=30 HTTP/1.1
Host: api.crunchable.io
Content-Type: application/json
X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987

{
  "instruction": "Does the image contain violent content?",
  "attachments_type": "image",
  "attachments": [ "http://i.imgur.com/qRWH5.jpg" ],
  "choices_type": "text",
  "choices": [ "no violence", "mild violence", "intense violence" ]
}
```

```shell
curl "https://api.crunchable.io/v1/requests/multiple-choice?block=30" \
  -H "X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987" \
  -H "Content-Type: application/json" \
  -d '{ "instruction": "Does the image contain violent content?",
        "attachments_type": "image",
        "attachments": ["http://i.imgur.com/qRWH5.jpg"],
        "choices_type": "text",
        "choices": ["no violence", "mild violence", "intense violence"] }'
```

```javascript
var crunchable = require("crunchable")(
  "test_e53bbf19fdd077eda1cd933a54ebe987"
);

crunchable.requestMultipleChoice({
  instruction: "Does the image contain violent content?",
  attachments_type: "image",
  attachments: [ "http://i.imgur.com/qRWH5.jpg" ],
  choices_type: "text",
  choices: [ "no violence", "mild violence", "intense violence" ]
}, 10, function (err, res) {
  // handle response here
});
```

When implementing a system using the API, it is very useful to be able to test the system during development without performing real API calls.

<aside class="warning">
Real API calls might provide responses after delays and might require payment. They aren't recommended for testing purposes!
</aside>

For testing purposes, you can use all API in a *staging environment*. In staging:

* API calls reply immediately without delays
* API calls are completely free without any limitation
* Responses for requests are staged so you shouldn't actually rely on them

To make your calls run on staging, use the **Test API Key** available in the [Developer Console](https://crunchable.io/dev-console/). Notice that staging API keys always have the prefix `test_` for easy identification.

# Making Requests

Making a request is meant to be as simple and painless as possible. All you need to do is make a single HTTP `POST` operation and provide all the relevant details.

There are several types of requests:

* [**Multiple Choice**](#multiple-choice) - You provide a set of pre-defined potential answers to the question and the response must be among this list.

* [**Free Text**](#free-text) - The response is free text - just like asking a question in a sentence and receiving a sentence in return.

* [**Rating**](#rating) - You provide a numeric sliding scale and the response is a numeric rating on this scale.

* [**Media**](#media-coming-soon) - The response is an image, video or audio file according to the request.

* [**Annotations**](#annotations) - You provide a resource such as an image and request annotations over its content (marked points of interest).

When making a request, the most important parameter you need to provide is `instruction`. This is a sentence explaining in natural language what exactly is requested in this call. The amazing thing about the crunchable.io API is the fact that instructions can be given in *natural language*. This means the API is not limited and you can pretty much ask anything you want.

## Complete vs pending

```http
GET /v1/requests/44647b6f-b033-4788-9ee2-9d7aa5cb0158 HTTP/1.1
Host: api.crunchable.io
X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987
```

```shell
curl "https://api.crunchable.io/v1/requests/44647b6f-b033-4788-9ee2-9d7aa5cb0158" \
  -u "test_e53bbf19fdd077eda1cd933a54ebe987:"
```

```javascript
var crunchable = require("crunchable")(
  "test_e53bbf19fdd077eda1cd933a54ebe987"
);

crunchable.getRequest(
  '44647b6f-b033-4788-9ee2-9d7aa5cb0158',
  function (err, res) {
  // handle response here
});
```

> Pending Response (JSON)

```json
{
  "id": "44647b6f-b033-4788-9ee2-9d7aa5cb0158",
  "status": "pending"
}
```

> Completed Response (JSON)

```json
{
  "id": "44647b6f-b033-4788-9ee2-9d7aa5cb0158",
  "status": "complete",
  "response": "42"
}
```

A request might take a little time to process. This means that the response might not be available immediately. You can tell whether a response is ready using the `status` field of the request. This field can have the following values:

* **complete** - The request is completed and the response is ready. There's no need to wait and you can consume the response itself immediately.

* **pending** - The request is still pending and the response is not ready yet. You'll have to wait until the request is completed before you can consume the response.

* **flagged** - The request as it is cannot be completed, probably due to some techincal issue or an unintelligble instruction. For more details - read the 'cruncher_feedback' field on the request. 

* **aborted** - The request was aborted (see [Aborting Requests](#aborting-pending-requests)) 

If a request is pending, the simplest method to wait until it's complete is by *polling* continuously. As long as the response is still pending, wait a little longer and try again. The [Retrieve request](#retrieving-requests) method can be used for this purpose:

`POST /v1/requests/multiple-choice { ... }`<br>
`{ id: "44647b6f-b033-4788-9ee2-9d7aa5cb0158", status: "pending", ... }`

`GET /v1/requests/44647b6f-b033-4788-9ee2-9d7aa5cb0158`<br>
`{ id: "44647b6f-b033-4788-9ee2-9d7aa5cb0158", status: "pending", ... }`

`GET /v1/requests/44647b6f-b033-4788-9ee2-9d7aa5cb0158`<br>
`{ id: "44647b6f-b033-4788-9ee2-9d7aa5cb0158", status: "pending", ... }`

`GET /v1/requests/44647b6f-b033-4788-9ee2-9d7aa5cb0158`<br>
`{ id: "44647b6f-b033-4788-9ee2-9d7aa5cb0158", status: "complete", ... }`

See best practices below for recommendations on how often to make recurring calls.

## Blocking vs non-blocking

> Call that is non-blocking

```http
GET /v1/requests/44647b6f-b033-4788-9ee2-9d7aa5cb0158 HTTP/1.1
Host: api.crunchable.io
X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987
```

```shell
curl "https://api.crunchable.io/v1/requests/44647b6f-b033-4788-9ee2-9d7aa5cb0158" \
  -u "test_e53bbf19fdd077eda1cd933a54ebe987:"
```

```javascript
var crunchable = require("crunchable")(
  "test_e53bbf19fdd077eda1cd933a54ebe987"
);

crunchable.getRequest(
  '44647b6f-b033-4788-9ee2-9d7aa5cb0158',
  function (err, res) {
  // handle response here
});
```

> Call that is blocking for 30 seconds

```http
GET /v1/requests/44647b6f-b033-4788-9ee2-9d7aa5cb0158?block=30 HTTP/1.1
Host: api.crunchable.io
X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987
```

```shell
curl "https://api.crunchable.io/v1/requests/44647b6f-b033-4788-9ee2-9d7aa5cb0158?block=30" \
  -u "test_e53bbf19fdd077eda1cd933a54ebe987:"
```

```javascript
var crunchable = require("crunchable")(
  "test_e53bbf19fdd077eda1cd933a54ebe987"
);

crunchable.getRequest(
  '44647b6f-b033-4788-9ee2-9d7aa5cb0158',
  30, function (err, res) {
  // handle response here
});
```

By default, all calls are *non-blocking*, meaning the server will reply immediately without waiting. Non-blocking calls are great for *polling* because you receive the current status as soon as you ask for it.

<aside class="success">
Non-blocking calls are recommended for production systems running in high loads
</aside>

If you prefer to reduce the amount of polling, you can also make *blocking* calls. Blocking calls let you specify the number of seconds you are willing to wait for a response. The server will wait up-to the specified number of seconds before replying.

For example, we decide to block for 30 seconds. If a response is ready within 15 seconds, the server will reply as soon as the response is ready (after 15 seconds) with a *complete* status. If a response is ready within 60 seconds, the server will reply as late as allowed (after 30 seconds) with a *pending* status.

<aside class="success">
Blocking calls are recommended when you're playing around and testing the API
</aside>

## Best practices

Since server replies might be in the *pending* status, you may need to poll continuously until the status becomes *complete*.

Let's assume you are running a production system with high load and using *non-blocking* calls. The question is how long should you wait before making the next polling call.

The recommended practice is to double your delay time between calls. Let's assume you wait 15 seconds between the first and second calls. If the second call is still *pending*, wait 30 seconds before making the third call. If the third call is still *pending*, wait 60 seconds before making the fourth call... and so forth.

## Using webhooks

If you want to avoid polling the server for responses, you can specify a webhook and crunchable will POST the completed request back to you as soon as it's ready.
To specify a webhook simply add the **hook_url** parameter

`{`<br>
`  instruction: ...,`<br>
`  ...`<br>
`  hook_url: 'http://my.webhook/endpoint/',`<br>
`}`

It is recommended to use webhooks *on top* of other (polling) methods, to avoid cases where a request is "lost" due to temporary unavailability of the webhook.

It makes sense to setup a webhook in order to receive quick updates on request completion, but periodically poll all 'pending' requests to make sure none got lost.

<h1 id="toc-section">Requests</h1>

# Multiple Choice

```http
POST /v1/requests/multiple-choice?block=30 HTTP/1.1
Host: api.crunchable.io
Content-Type: application/json
X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987

{
  "instruction": "Does the image contain violent content?",
  "attachments_type": "image",
  "attachments": [ "http://i.imgur.com/qRWH5.jpg" ],
  "choices_type": "text",
  "choices": [ "no violence", "mild violence", "intense violence" ]
}
```

```shell
curl "https://api.crunchable.io/v1/requests/multiple-choice?block=30" \
  -H "X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987" \
  -H "Content-Type: application/json" \
  -d '{ "instruction": "Does the image contain violent content?",
        "attachments_type": "image",
        "attachments": ["http://i.imgur.com/qRWH5.jpg"],
        "choices_type": "text",
        "choices": ["no violence", "mild violence", "intense violence"] }'
```

```javascript
var crunchable = require("crunchable")(
  "test_e53bbf19fdd077eda1cd933a54ebe987"
);

crunchable.requestMultipleChoice({
  instruction: "Does the image contain violent content?",
  attachments_type: "image",
  attachments: [ "http://i.imgur.com/qRWH5.jpg" ],
  choices_type: "text",
  choices: [ "no violence", "mild violence", "intense violence" ]
}, 10, function (err, res) {
  // handle response here
});
```

> Example Response (JSON)

```json
{
  "id": "44647b6f-b033-4788-9ee2-9d7aa5cb0158",
  "status": "complete",
  "response": [ "no violence" ],
  "type": "multiple-choice",
  "instruction": "Does the image contain violent content?",
  "attachments_type": "image",
  "attachments": [ "http://i.imgur.com/qRWH5.jpg" ],
  "choices_type": "text",
  "choices": [ "no violence", "mild violence", "intense violence" ]
}
```

Give a question with multiple potential answers and receive answers from the list as a response. You can limit to a single answer or multiple answers.

### HTTP Request

`POST /v1/requests/multiple-choice`

### Query Parameters

Name | Default | Description
--------- | ------- | -----------
block | 0 | Time in seconds the request should block for a response. If the request isn't completed before this timeout, a pending result is returned.

### Request Body Parameters

Name | Type | Description
--------- | ------- | -----------
instruction | string | Sentence explaining in natural language what exactly is requested in this call.
attachments_type *(optional)* | string | The type of the array elements in the `attachments` parameter. Potential values:<br>`text` - plain text *(default)*<br>`image` - URL of an image (jpg,png,gif)<br>`video` - URL of a video (mp4)<br>`audio` - URL of an audio file (wav,mp3)<br>`website` - URL of a website (html)
attachments *(optional)* | string[] | An array of strings providing additional resources which are required to perform the instruction.
choices_type *(optional)* | string | The type of the array elements in the `choices` parameter. Potential values:<br>`text` - plain text *(default)*<br>`image` - URL of an image (jpg,png,gif)<br>`video` - URL of a video (mp4)<br>`audio` - URL of an audio file (wav,mp3)<br>`website` - URL of a website (html)
choices | string[] | An array of strings describing the potential choices.
min_answers *(optional)* | number | Minimum number of allowed answers. Defaults to `1`.
max_answers *(optional)* | number | Maximum number of allowed answers. Give `0` for no limit (which is the default).

### Return Value

A `Request` object in a pending or completed state.

Name | Type | Description
--------- | ------- | -----------
id | string | A unique ID for this request, used to identify this request in future calls.
status | string | Current status of the request. Potential values:<br>`complete` - response ready under the `response` field<br>`pending` - response not ready and will be returned later
response *(optional)* | string[] | The response for the completed request (if available). An array of strings containing the chosen values from the `choices` array.
type | string | The request type, always `multiple-choice`.
 | |
instruction | string | *provided when making the request*
attachments_type | string | *provided when making the request*
attachments | string[] | *provided when making the request*
choices_type | string | *provided when making the request*
choices | string[] | *provided when making the request*
min_answers | number | *provided when making the request*
max_answers | number | *provided when making the request*

# Free Text

```http
POST /v1/requests/free-text?block=30 HTTP/1.1
Host: api.crunchable.io
Content-Type: application/json
X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987

{
  "instruction": "Translate from Spanish to English",
  "attachments_type": "text",
  "attachments": [ "hola mundo" ]
}
```

```shell
curl "https://api.crunchable.io/v1/requests/free-text?block=30" \
  -H "X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987" \
  -H "Content-Type: application/json" \
  -d '{ "instruction": "Translate from Spanish to English",
        "attachments_type": "text",
        "attachments": ["hola mundo"] }'
```

```javascript
var crunchable = require("crunchable")(
  "test_e53bbf19fdd077eda1cd933a54ebe987"
);

crunchable.requestFreeText({
  instruction: "Translate from Spanish to English",
  attachments_type: "text",
  attachments: [ "hola mundo" ]
}, 10, function (err, res) {
  // handle response here
});
```

> Example Response (JSON)

```json
{
  "id": "44647b6f-b033-4788-9ee2-9d7aa5cb0158",
  "status": "complete",
  "response": "hello world",
  "type": "free-text",
  "instruction": "Translate from Spanish to English",
  "attachments_type": "text",
  "attachments": [ "hola mundo" ]
}
```

Give a question and receive a free-text response.

### HTTP Request

`POST /v1/requests/free-text`

### Query Parameters

Name | Default | Description
--------- | ------- | -----------
block | 0 | Time in seconds the request should block for a response. If the request isn't completed before this timeout, a pending result is returned.

### Request Body Parameters

Name | Type | Description
--------- | ------- | -----------
instruction | string | Sentence explaining in natural language what exactly is requested in this call.
attachments_type *(optional)* | string | The type of the array elements in the `attachments` parameter. Potential values:<br>`text` - plain text *(default)*<br>`image` - URL of an image (jpg,png,gif)<br>`video` - URL of a video (mp4)<br>`audio` - URL of an audio file (wav,mp3)<br>`website` - URL of a website (html)
attachments *(optional)* | string[] | An array of strings providing additional resources which are required to perform the instruction.
validation *(optional)* | string | Limit the response to certain types of output. Potential values:<br>`number` - numbers only<br>`url` - valid URL addresses

### Return Value

A `Request` object in a pending or completed state.

Name | Type | Description
--------- | ------- | -----------
id | string | A unique ID for this request, used to identify this request in future calls.
status | string | Current status of the request. Potential values:<br>`complete` - response ready under the `response` field<br>`pending` - response not ready and will be returned later
response *(optional)* | string | The response for the completed request (if available).
type | string | The request type, always `free-text`.
 | |
instruction | string | *provided when making the request*
attachments_type | string | *provided when making the request*
attachments | string[] | *provided when making the request*
validation | string | *provided when making the request*

# Rating

```http
POST /v1/requests/rating?block=30 HTTP/1.1
Host: api.crunchable.io
Content-Type: application/json
X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987

{
  "instruction": "Estimate the age of the person in the image",
  "attachments_type": "image",
  "attachments": [ "http://i.imgur.com/GWxg2wC.jpg" ],
  "rating_min": 0,
  "rating_max": 100,
  "rating_step": 5
}
```

```shell
curl "https://api.crunchable.io/v1/requests/rating?block=30" \
  -H "X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987" \
  -H "Content-Type: application/json" \
  -d '{ "instruction": "Estimate the age of the person in the image",
        "attachments_type": "image",
        "attachments": ["http://i.imgur.com/GWxg2wC.jpg"],
        "rating_min": 0,
        "rating_max": 100,
        "rating_step": 5 }'
```

```javascript
var crunchable = require("crunchable")(
  "test_e53bbf19fdd077eda1cd933a54ebe987"
);

crunchable.requestRating({
  instruction: "Estimate the age of the person in the image",
  attachments_type: "image",
  attachments: [ "http://i.imgur.com/GWxg2wC.jpg" ],
  rating_min: 0,
  rating_max: 100,
  rating_step: 5
}, 10, function (err, res) {
  // handle response here
});
```

> Example Response (JSON)

```json
{
  "id": "44647b6f-b033-4788-9ee2-9d7aa5cb0158",
  "status": "complete",
  "response": 35,
  "type": "rating",
  "instruction": "Estimate the age of the person in the image",
  "attachments_type": "image",
  "attachments": [ "http://i.imgur.com/GWxg2wC.jpg" ],
  "rating_min": 0,
  "rating_max": 100,
  "rating_step": 5
}
```

Give a numeric sliding scale and request a rating on it.

### HTTP Request

`POST /v1/requests/rating`

### Query Parameters

Name | Default | Description
--------- | ------- | -----------
block | 0 | Time in seconds the request should block for a response. If the request isn't completed before this timeout, a pending result is returned.

### Request Body Parameters

Name | Type | Description
--------- | ------- | -----------
instruction | string | Sentence explaining in natural language what exactly is requested in this call.
attachments_type *(optional)* | string | The type of the array elements in the `attachments` parameter. Potential values:<br>`text` - plain text *(default)*<br>`image` - URL of an image (jpg,png,gif)<br>`video` - URL of a video (mp4)<br>`audio` - URL of an audio file (wav,mp3)<br>`website` - URL of a website (html)
attachments *(optional)* | string[] | An array of strings providing additional resources which are required to perform the instruction.
rating_min *(optional)* | number | The minimum rating on the scale. Defaults to `0`.
rating_max *(optional)* | number | The minimum rating on the scale. Defaults to `100`.
rating_step *(optional)* | number | The rating step on the scale (granularity). Defaults to `1`.
label_min *(optional)* | string | The label of the minimum edge of the scale.
label_max *(optional)* | string | The label of the maximum edge of the scale.

### Return Value

A `Request` object in a pending or completed state.

Name | Type | Description
--------- | ------- | -----------
id | string | A unique ID for this request, used to identify this request in future calls.
status | string | Current status of the request. Potential values:<br>`complete` - response ready under the `response` field<br>`pending` - response not ready and will be returned later
response *(optional)* | number | The response for the completed request (if available). A numeric rating on the scale.
type | string | The request type, always `rating`.
 | |
instruction | string | *provided when making the request*
attachments_type | string | *provided when making the request*
attachments | string[] | *provided when making the request*
rating_min | number | *provided when making the request*
rating_max | number | *provided when making the request*
rating_step | number | *provided when making the request*
label_min | string | *provided when making the request*
label_max | string | *provided when making the request*

# Media (Coming Soon!)
<aside class="notice">These APIs are planned for a future relase</aside>
## Image

<aside class="notice">This API is planned for a future relase</aside>

```http
POST /v1/requests/image?block=30 HTTP/1.1
Host: api.crunchable.io
Content-Type: application/json
X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987

{
  "instruction": "A picture of a birthday cake"
}
```

```shell
curl "https://api.crunchable.io/v1/requests/image?block=30" \
  -H "X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987" \
  -H "Content-Type: application/json" \
  -d '{ "instruction": "A picture of a birthday cake" }'
```

```javascript
var crunchable = require("crunchable")(
  "test_e53bbf19fdd077eda1cd933a54ebe987"
);

crunchable.requestImage({
  instruction: "A picture of a birthday cake"
}, 10, function (err, res) {
  // handle response here
});
```

> Example Response (JSON)

```json
{
  "id": "44647b6f-b033-4788-9ee2-9d7aa5cb0158",
  "status": "complete",
  "response": "http://i.imgur.com/x83UxTJ.jpg",
  "type": "image",
  "instruction": "A picture of a birthday cake"
}
```

Give a description of an image you would like to receive. There are no guarantees regarding the usage rights or licensing of the image.

### HTTP Request

`POST /v1/requests/image`

### Query Parameters

Name | Default | Description
--------- | ------- | -----------
block | 0 | Time in seconds the request should block for a response. If the request isn't completed before this timeout, a pending result is returned.

### Request Body Parameters

Name | Type | Description
--------- | ------- | -----------
instruction | string | Sentence explaining in natural language what exactly is requested in this call.
attachments_type *(optional)* | string | The type of the array elements in the `attachments` parameter. Potential values:<br>`text` - plain text *(default)*<br>`image` - URL of an image (jpg,png,gif)<br>`video` - URL of a video (mp4)<br>`audio` - URL of an audio file (wav,mp3)<br>`website` - URL of a website (html)
attachments *(optional)* | string[] | An array of strings providing additional resources which are required to perform the instruction.

### Return Value

A `Request` object in a pending or completed state.

Name | Type | Description
--------- | ------- | -----------
id | string | A unique ID for this request, used to identify this request in future calls.
status | string | Current status of the request. Potential values:<br>`complete` - response ready under the `response` field<br>`pending` - response not ready and will be returned later
response *(optional)* | string | The response for the completed request (if available). A URL for the requested image.
type | string | The request type, always `image`.
 | |
instruction | string | *provided when making the request*
attachments_type | string | *provided when making the request*
attachments | string[] | *provided when making the request*

## Video

<aside class="notice">This API is planned for a future relase</aside>

```http
POST /v1/requests/video?block=30 HTTP/1.1
Host: api.crunchable.io
Content-Type: application/json
X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987

{
  "instruction": "A video of a cat walking"
}
```

```shell
curl "https://api.crunchable.io/v1/requests/video?block=30" \
  -H "X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987" \
  -H "Content-Type: application/json" \
  -d '{ "instruction": "A video of a cat walking" }'
```

```javascript
var crunchable = require("crunchable")(
  "test_e53bbf19fdd077eda1cd933a54ebe987"
);

crunchable.requestVideo({
  instruction: "A video of a cat walking"
}, 10, function (err, res) {
  // handle response here
});
```

> Example Response (JSON)

```json
{
  "id": "44647b6f-b033-4788-9ee2-9d7aa5cb0158",
  "status": "complete",
  "response": "https://r15---sn-4g57kn6s.googlevideo.com/videoplayback?sver=3&dur=63.129&signature=7B99F64C8D39C4DFAD25CD22D6818252E2AD4D2E.5E340A4D94BEF14701416B0230EAE8F4098D8D08&keepalive=yes&sparams=clen,dur,expire,gir,id,ip,ipbits,itag,keepalive,lmt,mime,mm,mn,ms,mv,nh,pl,requiressl,source,upn&lmt=1434349079471384&gir=yes&expire=1446342569&id=o-APt8srmH93a9dAjKK_VFO1KKgTyClaCfo8QnodqIQIOt&source=youtube&pl=23&requiressl=yes&mime=video/mp4&ip=149.78.18.80&fexp=9407188,9408495,9408710,9409129,9409206,9413031,9414764,9415435,9416126,9417097,9417223,9417707,9418400,9420309,9421253,9421502,9422349,9422596,9422947,9423037,9423170&clen=1958886&itag=133&ipbits=0&upn=1pYqxKF_qDY&key=cms1&ratebypass=yes&title=Cat%20Walking%20-%20%5Bwww.getlinkyoutube.com%5D&redirect_counter=1&req_id=60d93d744c2ba3ee&cms_redirect=yes&mm=30&mn=sn-4g57kn6s&ms=nxu&mt=1446320978&mv=m&nh=IgpwcjAxLmZyYTAzKgkxMjcuMC4wLjE",
  "type": "video",
  "instruction": "A video of a cat walking"
}
```

Give a description of a video you would like to receive. There are no guarantees regarding the usage rights or licensing of the video.

### HTTP Request

`POST /v1/requests/video`

### Query Parameters

Name | Default | Description
--------- | ------- | -----------
block | 0 | Time in seconds the request should block for a response. If the request isn't completed before this timeout, a pending result is returned.

### Request Body Parameters

Name | Type | Description
--------- | ------- | -----------
instruction | string | Sentence explaining in natural language what exactly is requested in this call.
attachments_type *(optional)* | string | The type of the array elements in the `attachments` parameter. Potential values:<br>`text` - plain text *(default)*<br>`image` - URL of an image (jpg,png,gif)<br>`video` - URL of a video (mp4)<br>`audio` - URL of an audio file (wav,mp3)<br>`website` - URL of a website (html)
attachments *(optional)* | string[] | An array of strings providing additional resources which are required to perform the instruction.

### Return Value

A `Request` object in a pending or completed state.

Name | Type | Description
--------- | ------- | -----------
id | string | A unique ID for this request, used to identify this request in future calls.
status | string | Current status of the request. Potential values:<br>`complete` - response ready under the `response` field<br>`pending` - response not ready and will be returned later
response *(optional)* | string | The response for the completed request (if available). A URL for the requested video.
type | string | The request type, always `video`.
 | |
instruction | string | *provided when making the request*
attachments_type | string | *provided when making the request*
attachments | string[] | *provided when making the request*

## Audio

<aside class="notice">This API is planned for a future relase</aside>

```http
POST /v1/requests/audio?block=30 HTTP/1.1
Host: api.crunchable.io
Content-Type: application/json
X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987

{
  "instruction": "Pronounce the word",
  "attachments_type": "text",
  "attachments": [ "encyclopedia" ]
}
```

```shell
curl "https://api.crunchable.io/v1/requests/audio?block=30" \
  -H "X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987" \
  -H "Content-Type: application/json" \
  -d '{ "instruction": "Pronounce the word",
        "attachments_type": "text",
        "attachments": ["encyclopedia"] }'
```

```javascript
var crunchable = require("crunchable")(
  "test_e53bbf19fdd077eda1cd933a54ebe987"
);

crunchable.requestAudio({
  instruction: "Pronounce the word",
  attachments_type: "text",
  attachments: [ "encyclopedia" ]
}, 10, function (err, res) {
  // handle response here
});
```

> Example Response (JSON)

```json
{
  "id": "44647b6f-b033-4788-9ee2-9d7aa5cb0158",
  "status": "complete",
  "response": "http://static.sfdict.com/staticrep/dictaudio/E01/E0165900.mp3",
  "type": "audio",
  "instruction": "Pronounce the word",
  "attachments_type": "text",
  "attachments": [ "encyclopedia" ]
}
```

Give a description of audio you would like to receive. There are no guarantees regarding the usage rights or licensing of the audio.

### HTTP Request

`POST /v1/requests/audio`

### Query Parameters

Name | Default | Description
--------- | ------- | -----------
block | 0 | Time in seconds the request should block for a response. If the request isn't completed before this timeout, a pending result is returned.

### Request Body Parameters

Name | Type | Description
--------- | ------- | -----------
instruction | string | Sentence explaining in natural language what exactly is requested in this call.
attachments_type *(optional)* | string | The type of the array elements in the `attachments` parameter. Potential values:<br>`text` - plain text *(default)*<br>`image` - URL of an image (jpg,png,gif)<br>`video` - URL of a video (mp4)<br>`audio` - URL of an audio file (wav,mp3)<br>`website` - URL of a website (html)
attachments *(optional)* | string[] | An array of strings providing additional resources which are required to perform the instruction.

### Return Value

A `Request` object in a pending or completed state.

Name | Type | Description
--------- | ------- | -----------
id | string | A unique ID for this request, used to identify this request in future calls.
status | string | Current status of the request. Potential values:<br>`complete` - response ready under the `response` field<br>`pending` - response not ready and will be returned later
response *(optional)* | string | The response for the completed request (if available). A URL for the requested audio file.
type | string | The request type, always `audio`.
 | |
instruction | string | *provided when making the request*
attachments_type | string | *provided when making the request*
attachments | string[] | *provided when making the request*

# Annotations

## Simple annotations

```http
POST /v1/requests/annotations?block=30 HTTP/1.1
Host: api.crunchable.io
Content-Type: application/json
X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987

{
  "instruction": "Mark the fashion accessories in the image",
  "attachments_type": "image",
  "attachments": [ "http://i.imgur.com/piKjc.jpg" ]
}
```

```shell
curl "https://api.crunchable.io/v1/requests/annotations?block=30" \
  -H "X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987" \
  -H "Content-Type: application/json" \
  -d '{ "instruction": "Mark the fashion accessories in the image",
        "attachments_type": "image",
        "attachments": ["http://i.imgur.com/piKjc.jpg"] }'
```

```javascript
var crunchable = require("crunchable")(
  "test_e53bbf19fdd077eda1cd933a54ebe987"
);

crunchable.requestAnnotations({
  instruction: "Mark the fashion accessories in the image",
  attachments_type: "image",
  attachments: [ "http://i.imgur.com/piKjc.jpg" ]
}, 10, function (err, res) {
  // handle response here
});
```

> Example Response (JSON)

```json
{
  "id": "44647b6f-b033-4788-9ee2-9d7aa5cb0158",
  "status": "complete",
  "response": [
    { "x": 123, "y": 207 },
    { "x": 321, "y": 523 },
    { "x": 73, "y": 298 }
  ],
  "type": "annotations",
  "instruction": "Mark the fashion accessories in the image",
  "attachments_type": "image",
  "attachments": [ "http://i.imgur.com/piKjc.jpg" ]
}
```

Give an attachment and request annotations over its content. This can be used to mark points of interest in an image, text, video, audio or website.

### HTTP Request

`POST /v1/requests/annotations`

### Query Parameters

Name | Default | Description
--------- | ------- | -----------
block | 0 | Time in seconds the request should block for a response. If the request isn't completed before this timeout, a pending result is returned.

### Request Body Parameters

Name | Type | Description
--------- | ------- | -----------
instruction | string | Sentence explaining in natural language what exactly is requested in this call.
attachments_type *(optional)* | string | The type of the array elements in the `attachments` parameter. Potential values:<br>`text` - plain text *(default)*<br>`image` - URL of an image (jpg,png,gif)<br>`video` - URL of a video (mp4)<br>`audio` - URL of an audio file (wav,mp3)<br>`website` - URL of a website (html)
attachments *(optional)* | string[] | An array of strings providing additional resources which are required to perform the instruction.
annotations_type *(optional)* | string | The type of requested annotation. Potential values:<br>`point` - pinpointed location (x,y) *(default)*<br>`rectangle` - marked area (x,y,x2,y2)
min_annotations *(optional)* | number | Minimum number of requested annotations. Defaults to `1`.
max_annotations *(optional)* | number | Maximum number of requested answers.

### Return Value

A `Request` object in a pending or completed state.

Name | Type | Description
--------- | ------- | -----------
id | string | A unique ID for this request, used to identify this request in future calls.
status | string | Current status of the request. Potential values:<br>`complete` - response ready under the `response` field<br>`pending` - response not ready and will be returned later
response *(optional)* | array | The response for the completed request (if available). An array of annotation objects, each containing:<br>`x` - horizontal pixel location (for image, video)<br>`y` - vertical pixel location (for image, video)<br>`x2` - 2nd location (on annotations type rectangle)<br>`y2` - 2nd location (on annotations type rectangle)<br>`t` - time offset in seconds (for video, audio)<br>`attachment_index` - when more than one provided
type | string | The request type, always `annotations`.
 | |
instruction | string | *provided when making the request*
attachments_type | string | *provided when making the request*
attachments | string[] | *provided when making the request*
annotations_type | string | *provided when making the request*
min_annotations | number | *provided when making the request*
max_annotations | number | *provided when making the request*

## Annotations with multiple choice

```http
POST /v1/requests/annotations-with-multiple-choice?block=30 HTTP/1.1
Host: api.crunchable.io
Content-Type: application/json
X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987

{
  "instruction": "Mark all the cats in the image",
  "attachments_type": "image",
  "attachments": [ "http://i.imgur.com/2hOoEp1.jpg" ],
  "per_annotation": {
    "instruction": "What color is the cat",
    "choices_type": "text",
    "choices": [ "gray", "white", "black", "ginger" ]
  }
}
```

```shell
curl "https://api.crunchable.io/v1/requests/annotations-with-multiple-choice?block=30" \
  -H "X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987" \
  -H "Content-Type: application/json" \
  -d '{ "instruction": "Mark all the cats in the image",
        "attachments_type": "image",
        "attachments": ["http://i.imgur.com/2hOoEp1.jpg"],
        "per_annotation": {
          "instruction": "What color is the cat",
          "choices_type": "text",
          "choices": ["gray", "white", "black", "ginger"] } }'
```

```javascript
var crunchable = require("crunchable")(
  "test_e53bbf19fdd077eda1cd933a54ebe987"
);

crunchable.requestAnnotationsWithMultipleChoice({
  instruction: "Mark all the cats in the image",
  attachments_type: "image",
  attachments: [ "http://i.imgur.com/2hOoEp1.jpg" ],
  per_annotation: {
    instruction: "What color is the cat",
    choices_type: "text",
    choices: [ "gray", "white", "black", "ginger" ]
  }
}, 10, function (err, res) {
  // handle response here
});
```

> Example Response (JSON)

```json
{
  "id": "44647b6f-b033-4788-9ee2-9d7aa5cb0158",
  "status": "complete",
  "response": [
    { "x": 123, "y": 207, "response": [ "gray" ] },
    { "x": 321, "y": 523, "response": [ "ginger" ] },
    { "x": 73, "y": 298, "response": [ "gray" ] }
  ],
  "type": "annotations-with-multiple-choice",
  "instruction": "Mark all the cats in the image",
  "attachments_type": "image",
  "attachments": [ "http://i.imgur.com/2hOoEp1.jpg" ],
  "per_annotation": {
    "instruction": "What color is the cat",
    "choices_type": "text",
    "choices": [ "gray", "white", "black", "ginger" ]
  }
}
```

Give an attachment and request annotations over its content. For each annotation add a multiple choice request. This can be used to mark points of interest in an image, text, video, audio or website and then answer a question per each point marked.

### HTTP Request

`POST /v1/requests/annotations-with-multiple-choice`

### Query Parameters

Name | Default | Description
--------- | ------- | -----------
block | 0 | Time in seconds the request should block for a response. If the request isn't completed before this timeout, a pending result is returned.

### Request Body Parameters

Name | Type | Description
--------- | ------- | -----------
instruction | string | Sentence explaining in natural language what exactly is requested in this call.
attachments_type *(optional)* | string | The type of the array elements in the `attachments` parameter. Potential values:<br>`text` - plain text *(default)*<br>`image` - URL of an image (jpg,png,gif)<br>`video` - URL of a video (mp4)<br>`audio` - URL of an audio file (wav,mp3)<br>`website` - URL of a website (html)
attachments *(optional)* | string[] | An array of strings providing additional resources which are required to perform the instruction.
annotations_type *(optional)* | string | The type of requested annotation. Potential values:<br>`point` - pinpointed location (x,y) *(default)*<br>`rectangle` - marked area (x,y,x2,y2)
min_annotations *(optional)* | number | Minimum number of requested annotations. Defaults to `1`.
max_annotations *(optional)* | number | Maximum number of requested answers.
per_annotation | object | The request per annotation. A `Request` object containing:<br> `instruction` - natural language request<br>`choices_type` - see [multiple choice](#multiple-choice) request params<br>`choices` - see [multiple choice](#multiple-choice) request params

### Return Value

A `Request` object in a pending or completed state.

Name | Type | Description
--------- | ------- | -----------
id | string | A unique ID for this request, used to identify this request in future calls.
status | string | Current status of the request. Potential values:<br>`complete` - response ready under the `response` field<br>`pending` - response not ready and will be returned later
response *(optional)* | array | The response for the completed request (if available). An array of annotation objects, each containing:<br>`x` - horizontal pixel location (for image, video)<br>`y` - vertical pixel location (for image, video)<br>`x2` - 2nd location (on annotations type rectangle)<br>`y2` - 2nd location (on annotations type rectangle)<br>`t` - time offset in seconds (for video, audio)<br>`attachment_index` - when more than one provided<br>`response` - the response per annotation
type | string | The request type, always `annotations-with-multiple-choice`.
 | |
instruction | string | *provided when making the request*
attachments_type | string | *provided when making the request*
attachments | string[] | *provided when making the request*
annotations_type | string | *provided when making the request*
min_annotations | number | *provided when making the request*
max_annotations | number | *provided when making the request*
per_annotation | object | *provided when making the request*

## Annotations with free text

```http
POST /v1/requests/annotations-with-free-text?block=30 HTTP/1.1
Host: api.crunchable.io
Content-Type: application/json
X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987

{
  "instruction": "Mark all the cats in the image",
  "attachments_type": "image",
  "attachments": [ "http://i.imgur.com/2hOoEp1.jpg" ],
  "per_annotation": {
    "instruction": "What's the facial expression of the cat?"
  }
}
```

```shell
curl "https://api.crunchable.io/v1/requests/annotations-with-free-text?block=30" \
  -H "X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987" \
  -H "Content-Type: application/json" \
  -d '{ "instruction": "Mark all the cats in the image",
        "attachments_type": "image",
        "attachments": ["http://i.imgur.com/2hOoEp1.jpg"],
        "per_annotation": { "instruction": "What's the facial expression of the cat?" } }'
```

```javascript
var crunchable = require("crunchable")(
  "test_e53bbf19fdd077eda1cd933a54ebe987"
);

crunchable.requestAnnotationsWithFreeText({
  instruction: "Mark all the cats in the image",
  attachments_type: "image",
  attachments: [ "http://i.imgur.com/2hOoEp1.jpg" ],
  per_annotation: {
    instruction: "What's the facial expression of the cat?"
  }
}, 10, function (err, res) {
  // handle response here
});
```

> Example Response (JSON)

```json
{
  "id": "44647b6f-b033-4788-9ee2-9d7aa5cb0158",
  "status": "complete",
  "response": [
    { "x": 123, "y": 207, "response": "grumpy" },
    { "x": 321, "y": 523, "response": "curious" },
    { "x": 73, "y": 298, "response": "stunned" }
  ],
  "type": "annotations-with-free-text",
  "instruction": "Mark all the cats in the image",
  "attachments_type": "image",
  "attachments": [ "http://i.imgur.com/2hOoEp1.jpg" ],
  "per_annotation": {
    "instruction": "What's the facial expression of the cat?"
  }
}
```

Give an attachment and request annotations over its content. For each annotation ask a free text question. This can be used to mark points of interest in an image, text, video, audio or website and then answer a question per each point marked.

### HTTP Request

`POST /v1/requests/annotations-with-free-text`

### Query Parameters

Name | Default | Description
--------- | ------- | -----------
block | 0 | Time in seconds the request should block for a response. If the request isn't completed before this timeout, a pending result is returned.

### Request Body Parameters

Name | Type | Description
--------- | ------- | -----------
instruction | string | Sentence explaining in natural language what exactly is requested in this call.
attachments_type *(optional)* | string | The type of the array elements in the `attachments` parameter. Potential values:<br>`text` - plain text *(default)*<br>`image` - URL of an image (jpg,png,gif)<br>`video` - URL of a video (mp4)<br>`audio` - URL of an audio file (wav,mp3)<br>`website` - URL of a website (html)
attachments *(optional)* | string[] | An array of strings providing additional resources which are required to perform the instruction.
annotations_type *(optional)* | string | The type of requested annotation. Potential values:<br>`point` - pinpointed location (x,y) *(default)*<br>`rectangle` - marked area (x,y,x2,y2)
min_annotations *(optional)* | number | Minimum number of requested annotations. Defaults to `1`.
max_annotations *(optional)* | number | Maximum number of requested answers.
per_annotation | object | The request per annotation. A `Request` object containing:<br> `instruction` - natural language request<br>`validation` - see [free text](#free-text) request params

### Return Value

A `Request` object in a pending or completed state.

Name | Type | Description
--------- | ------- | -----------
id | string | A unique ID for this request, used to identify this request in future calls.
status | string | Current status of the request. Potential values:<br>`complete` - response ready under the `response` field<br>`pending` - response not ready and will be returned later
response *(optional)* | array | The response for the completed request (if available). An array of annotation objects, each containing:<br>`x` - horizontal pixel location (for image, video)<br>`y` - vertical pixel location (for image, video)<br>`x2` - 2nd location (on annotations type rectangle)<br>`y2` - 2nd location (on annotations type rectangle)<br>`t` - time offset in seconds (for video, audio)<br>`attachment_index` - when more than one provided<br>`response` - the response per annotation
type | string | The request type, always `annotations-with-free-text`.
 | |
instruction | string | *provided when making the request*
attachments_type | string | *provided when making the request*
attachments | string[] | *provided when making the request*
annotations_type | string | *provided when making the request*
min_annotations | number | *provided when making the request*
max_annotations | number | *provided when making the request*
per_annotation | object | *provided when making the request*

## Annotations with rating

```http
POST /v1/requests/annotations-with-rating?block=30 HTTP/1.1
Host: api.crunchable.io
Content-Type: application/json
X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987

{
  "instruction": "Mark all the cats in the image",
  "attachments_type": "image",
  "attachments": [ "http://i.imgur.com/2hOoEp1.jpg" ],
  "per_annotation": {
    "instruction": "How aggressive is the cat?",
    "rating_min": 0,
    "rating_max": 10,
    "label_min": "not aggressive",
    "label_max": "very aggressive"
  }
}
```

```shell
curl "https://api.crunchable.io/v1/requests/annotations-with-rating?block=30" \
  -H "X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987" \
  -H "Content-Type: application/json" \
  -d '{ "instruction": "Mark all the cats in the image",
        "attachments_type": "image",
        "attachments": ["http://i.imgur.com/2hOoEp1.jpg"],
        "per_annotation": { "instruction": "How aggressive is the cat?",
          "rating_min": 0,
          "rating_max": 10,
          "label_min": "not aggressive",
          "label_max": "very aggressive" } }'
```

```javascript
var crunchable = require("crunchable")(
  "test_e53bbf19fdd077eda1cd933a54ebe987"
);

crunchable.requestAnnotationsWithRating({
  instruction: "Mark all the cats in the image",
  attachments_type: "image",
  attachments: [ "http://i.imgur.com/2hOoEp1.jpg" ],
  per_annotation: {
    instruction: "How aggressive is the cat?",
    rating_min: 0,
    rating_max: 10,
    label_min: "not aggressive",
    label_max: "very aggressive"
  }
}, 10, function (err, res) {
  // handle response here
});
```

> Example Response (JSON)

```json
{
  "id": "44647b6f-b033-4788-9ee2-9d7aa5cb0158",
  "status": "complete",
  "response": [
    { "x": 123, "y": 207, "response": 6 },
    { "x": 321, "y": 523, "response": 2 },
    { "x": 73, "y": 298, "response": 0 }
  ],
  "type": "annotations-with-rating",
  "instruction": "Mark all the cats in the image",
  "attachments_type": "image",
  "attachments": [ "http://i.imgur.com/2hOoEp1.jpg" ],
  "per_annotation": {
    "instruction": "How aggressive is the cat?",
    "rating_min": 0,
    "rating_max": 10,
    "label_min": "not aggressive",
    "label_max": "very aggressive"
  }
}
```

Give an attachment and request annotations over its content. For each annotation add a rating request (choose a value on a numeric sliding scale). This can be used to mark points of interest in an image, text, video, audio or website and then answer a question per each point marked.

### HTTP Request

`POST /v1/requests/annotations-with-rating`

### Query Parameters

Name | Default | Description
--------- | ------- | -----------
block | 0 | Time in seconds the request should block for a response. If the request isn't completed before this timeout, a pending result is returned.

### Request Body Parameters

Name | Type | Description
--------- | ------- | -----------
instruction | string | Sentence explaining in natural language what exactly is requested in this call.
attachments_type *(optional)* | string | The type of the array elements in the `attachments` parameter. Potential values:<br>`text` - plain text *(default)*<br>`image` - URL of an image (jpg,png,gif)<br>`video` - URL of a video (mp4)<br>`audio` - URL of an audio file (wav,mp3)<br>`website` - URL of a website (html)
attachments *(optional)* | string[] | An array of strings providing additional resources which are required to perform the instruction.
annotations_type *(optional)* | string | The type of requested annotation. Potential values:<br>`point` - pinpointed location (x,y) *(default)*<br>`rectangle` - marked area (x,y,x2,y2)
min_annotations *(optional)* | number | Minimum number of requested annotations. Defaults to `1`.
max_annotations *(optional)* | number | Maximum number of requested answers.
per_annotation | object | The request per annotation. A `Request` object containing:<br> `instruction` - natural language request<br>`rating_min` - see [rating](#rating) request params<br>`rating_max` - see [rating](#rating) request params<br>`rating_step` - see [rating](#rating) request params<br>`label_min` - see [rating](#rating) request params<br>`label_max` - see [rating](#rating) request params

### Return Value

A `Request` object in a pending or completed state.

Name | Type | Description
--------- | ------- | -----------
id | string | A unique ID for this request, used to identify this request in future calls.
status | string | Current status of the request. Potential values:<br>`complete` - response ready under the `response` field<br>`pending` - response not ready and will be returned later
response *(optional)* | array | The response for the completed request (if available). An array of annotation objects, each containing:<br>`x` - horizontal pixel location (for image, video)<br>`y` - vertical pixel location (for image, video)<br>`x2` - 2nd location (on annotations type rectangle)<br>`y2` - 2nd location (on annotations type rectangle)<br>`t` - time offset in seconds (for video, audio)<br>`attachment_index` - when more than one provided<br>`response` - the response per annotation
type | string | The request type, always `annotations-with-rating`.
 | |
instruction | string | *provided when making the request*
attachments_type | string | *provided when making the request*
attachments | string[] | *provided when making the request*
annotations_type | string | *provided when making the request*
min_annotations | number | *provided when making the request*
max_annotations | number | *provided when making the request*
per_annotation | object | *provided when making the request*

<h1 id="toc-section">Attachments</h1>

Attaching media to requests

# Embedding Youtube Videos

Embedding videos from YouTube is easy, but instead of using the "normal" link to the video, you should use the YouTube Embedded Player. Here's how to do it:

1. Get the YouTube **video id**. For example, in this case: https://www.youtube.com/watch?v=R0V_D4zaEpU the **video id** is **R0V_D4zaEpU**

2. Add the **video id** to the embedded player url, like this: **https://www.youtube.com/embed/R0V_D4zaEpU**

Use this link when sending requests, together with `{attachments_type: video}`

# Making Phone Calls

```http
POST /v1/requests/free-text HTTP/1.1
Host: api.crunchable.io
Content-Type: application/json
X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987

{
  "instruction": "Please dial the number below and enter the supplied PIN code. An automated system will tell you the current balance in an account. Please write down the balance in the response",
  "attachments_type": "text",
  "attachments": [ 
    "dial:+1212123456",
    "PIN Code: 1234"
  ],
  "validation": "number"
}
```

```shell
curl "https://api.crunchable.io/v1/requests/free-text?block=30" \
  -H "X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987" \
  -H "Content-Type: application/json" \
  -d '{
    "instruction": "Please dial the number below and enter the supplied PIN code. An automated system will tell you the current balance in an account. Please write down the balance in the response",
    "attachments_type": "text",
    "attachments": [ 
      "dial:+1212123456",
      "PIN Code: 1234"
    ],
    "validation": "number"
  }'
```

```javascript
var crunchable = require("crunchable")(
  "test_e53bbf19fdd077eda1cd933a54ebe987"
);

crunchable.requestFreeText({
  "instruction": "Please dial the number below and enter the supplied PIN code. An automated system will tell you the current balance in an account. Please write down the balance in the response",
  "attachments_type": "text",
  "attachments": [ 
    "dial:+1212123456",
    "PIN Code: 1234"
  ],
  "validation": "number"
}, 10, function (err, res) {
  // handle response here
});
```

<aside class="warning">
Additional charges apply when making phone calls
</aside>

If you want to attach a phone number that Crunchers will dial in order to perform your request, please prefix it with the 'dial:' prefix.
This will allow us to recognize that this is a phone number, and optimize call charges by routing the call through the web.

`{`<br>
`  instruction: ...`<br>
`  ...`<br>
`  attachments_type: "text",`<br>
`  attachments: ["dial:+123456789"]`<br>
`}`

<h1 id="toc-section">Management</h1>

# Retrieving Requests

<aside class="success">
This API call is free and isn't counted against your quota
</aside>

```http
GET /v1/requests/44647b6f-b033-4788-9ee2-9d7aa5cb0158?block=30 HTTP/1.1
Host: api.crunchable.io
X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987
```

```shell
curl "https://api.crunchable.io/v1/requests/44647b6f-b033-4788-9ee2-9d7aa5cb0158?block=30" \
  -u "test_e53bbf19fdd077eda1cd933a54ebe987:"
```

```javascript
var crunchable = require("crunchable")(
  "test_e53bbf19fdd077eda1cd933a54ebe987"
);

crunchable.getRequest('44647b6f-b033-4788-9ee2-9d7aa5cb0158', 10, function (err, res) {
  // handle response here
});
```

> Example Response (JSON)

```json
{
  "id": "44647b6f-b033-4788-9ee2-9d7aa5cb0158",
  "status": "complete",
  "response": "no violence",
  "type": "multiple-choice",
  "instruction": "Does the image contain violent content?",
  "attachments_type": "image",
  "attachments": [ "http://i.imgur.com/qRWH5.jpg" ],
  "choices_type": "text",
  "choices": [ "no violence", "mild violence", "intense violence" ]
}
```

Retrieve the details of an existing request, and the response (once the request is completed). 
Supply the unique request ID returned when the request was initially created.

### HTTP Request

`GET /v1/requests/{request_id}`

### Path Parameters

Name | Type | Description
--------- | ------- | -----------
request_id | string | The unique ID of the request, returned when the request was initially created.

### Query Parameters

Name | Default | Description
--------- | ------- | -----------
block | 0 | Time in seconds the request should block for a response. If the request isn't completed before this timeout, a pending result is returned.

### Return Value

A `Request` object in a pending or completed state.

Name | Type | Description
--------- | ------- | -----------
id | string | A unique ID for this request, used to identify this request in future calls.
status | string | Current status of the request. Potential values:<br>`complete` - response ready under the `response` field<br>`pending` - response not ready and will be returned later
response *(optional)* | string | The response for the completed request (if available). Format depends on the request type.
type | string | The request type.
 | |
instruction | string | *provided when making the request*
attachments_type | string | *provided when making the request*
attachments | string[] | *provided when making the request*
... | ... | *other fields provided when making the request*

# Aborting pending requests

<aside class="success">
This API call is free and isn't counted against your quota
</aside>

```http
POST /v1/tasks/abort/44647b6f-b033-4788-9ee2-9d7aa5cb0158?block=30 HTTP/1.1
Host: api.crunchable.io
X-Crunch-API-Key: test_e53bbf19fdd077eda1cd933a54ebe987
```

```shell
curl -X POST "https://api.crunchable.io/v1/tasks/abort/44647b6f-b033-4788-9ee2-9d7aa5cb0158?block=30" \
  -u "test_e53bbf19fdd077eda1cd933a54ebe987:"
```

```javascript
var crunchable = require("crunchable")(
  "test_e53bbf19fdd077eda1cd933a54ebe987"
);

crunchable.abortRequest('44647b6f-b033-4788-9ee2-9d7aa5cb0158', 10, function (err, res) {
  // handle response here
});
```

> Example Response (JSON)

```json
{
  "success": true
}
```

Abort a pending request. Aborting a request is only possible *before* it is completed.

### HTTP Request

`POST /v1/tasks/abort/{request_id}`

### Path Parameters

Name | Type | Description
--------- | ------- | -----------
request_id | string | The unique ID of the request, returned when the request was initially created.

<h1 id="toc-section">Appendix</h1>
