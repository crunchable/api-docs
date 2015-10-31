---
title: API Reference

language_tabs:
  - http: HTTP
  - shell: Shell
  - javascript: Node

toc_footers:
  - <a href='#'>Sign Up for a Developer Key</a>
  - <a href='http://github.com/tripit/slate'>Documentation Powered by Slate</a>

includes:
  - errors

search: true
---

# Introduction

Welcome to the Crunchable.io API!

# Authentication

Every API call must be authenticated by including your secret API key in the request. You can manage your API keys in the [Dashboard](https://crunchable.io/dashboard).

Authentication to the API is performed via [HTTP Basic Auth](http://en.wikipedia.org/wiki/Basic_access_authentication). Provide your API key as the basic auth username value. You do not need to provide a password.

A sample test API key is included in all the examples on this page, so you can test any example right away. To test requests using your account, replace the sample API key with your actual API key.

# Making Requests

Making a request is meant to be as simple and painless as possible. All you need to do is make a single HTTP `POST` operation and provide all the relevant details.

There are several types of requests:

* [**Multiple Choice**](#multiple-choice) - You provide a set of pre-defined potential answers to the question and the response must be among this list.

When making a request, the most important parameter you need to provide is `instruction`. This is a sentence explaining in natural language what exactly is requested in this call. The amazing thing about the crunchable.io API is the fact that instructions can be given in *natural language*. This means the API is not limited and you can pretty much ask anything you want.

## Complete vs pending

```http
GET /v1/requests/44647b6f-b033-4788-9ee2-9d7aa5cb0158 HTTP/1.1
Host: api.crunchable.io
Authorization: Basic dGVzdF9qM3RlcHF2cllJYVlzQlE2RXpsSGVBQkk6
```

```shell
curl "https://api.crunchable.io/v1/requests/44647b6f-b033-4788-9ee2-9d7aa5cb0158" \
  -u "test_j3tepqvrYIaYsBQ6EzlHeABI:"
```

```javascript
var crunchable = require("crunchable")(
  "test_j3tepqvrYIaYsBQ6EzlHeABI"
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

If a request is pending, the simplest method to wait until it's complete is by *polling* continuously. As long as the response is still pending, wait a little longer and try again. Both the [Retrieve response](#retrieve-response) method or the [Retrieve request](#retrieve-request) method can be used for this purpose:

`POST /v1/requests/choice-single { ... }`<br>
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
Authorization: Basic dGVzdF9qM3RlcHF2cllJYVlzQlE2RXpsSGVBQkk6
```

```shell
curl "https://api.crunchable.io/v1/requests/44647b6f-b033-4788-9ee2-9d7aa5cb0158" \
  -u "test_j3tepqvrYIaYsBQ6EzlHeABI:"
```

```javascript
var crunchable = require("crunchable")(
  "test_j3tepqvrYIaYsBQ6EzlHeABI"
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
Authorization: Basic dGVzdF9qM3RlcHF2cllJYVlzQlE2RXpsSGVBQkk6
```

```shell
curl "https://api.crunchable.io/v1/requests/44647b6f-b033-4788-9ee2-9d7aa5cb0158?block=30" \
  -u "test_j3tepqvrYIaYsBQ6EzlHeABI:"
```

```javascript
var crunchable = require("crunchable")(
  "test_j3tepqvrYIaYsBQ6EzlHeABI"
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

# Staging Environment

> This call runs on staging because the API key starts with `test_`

```http
POST /v1/requests/choice-single?block=10 HTTP/1.1
Host: api.crunchable.io
Content-Type: application/json
Authorization: Basic dGVzdF9qM3RlcHF2cllJYVlzQlE2RXpsSGVBQkk6

{
  "instruction": "Does the image contain any sexual content?",
  "attachments_type": "image",
  "attachments": [ "http://i.imgur.com/qRWH5.jpg" ],
  "choices_type": "text",
  "choices": [ "yes", "no", "maybe" ]
}
```

```shell
curl "https://api.crunchable.io/v1/requests/choice-single?block=10" \
  -u "test_j3tepqvrYIaYsBQ6EzlHeABI:" \
  -d instruction="Does the image contain any sexual content?" \
  -d attachments_type="image" \
  -d attachments[0]="http://i.imgur.com/qRWH5.jpg" \
  -d choices_type="text" \
  -d choices[0]="yes" \
  -d choices[1]="no" \
  -d choices[2]="maybe"
```

```javascript
var crunchable = require("crunchable")(
  "test_j3tepqvrYIaYsBQ6EzlHeABI"
);

crunchable.requestChoiceSingle({
  instruction: "Does the image contain any sexual content?",
  attachments_type: "image",
  attachments: [ "http://i.imgur.com/qRWH5.jpg" ],
  choices_type: "text",
  choices: [ "yes", "no", "maybe" ]
}, 10, function (err, res) {
  // handle response here
});
```

When implementing a system using the API, it is very useful to be able to test the system during development without performing real API calls.

<aside class="notice">
Real API calls might provide responses after delays and might require payment. They aren't recommended for testing purposes.
</aside>

For testing purposes, you can use all API in a *staging environment*. In staging:

* API calls reply immediately without delays
* API calls are completely free without any limitation
* Responses for requests are staged so you shouldn't actually rely on them

To make your calls run on staging, use the **Test API Key** available in the [Dashboard](https://crunchable.io/dashboard). Notice that staging API keys always have the prefix `test_` for easy identification.

<h1 id="toc-section">Requests</h1>

A request is a question made to the API server in the effort of receiving a response containing an answer to the question. There are several types of requests:

* [**Multiple Choice**](#multiple-choice) - You provide a set of pre-defined potential answers to the question and the response must be among this list.

# Multiple Choice

## Single answer

```http
POST /v1/requests/choice-single?block=10 HTTP/1.1
Host: api.crunchable.io
Content-Type: application/json
Authorization: Basic dGVzdF9qM3RlcHF2cllJYVlzQlE2RXpsSGVBQkk6

{
  "instruction": "Does the image contain any sexual content?",
  "attachments_type": "image",
  "attachments": [ "http://i.imgur.com/qRWH5.jpg" ],
  "choices_type": "text",
  "choices": [ "yes", "no", "maybe" ]
}
```

```shell
curl "https://api.crunchable.io/v1/requests/choice-single?block=10" \
  -u "test_j3tepqvrYIaYsBQ6EzlHeABI:" \
  -d instruction="Does the image contain any sexual content?" \
  -d attachments_type="image" \
  -d attachments[0]="http://i.imgur.com/qRWH5.jpg" \
  -d choices_type="text" \
  -d choices[0]="yes" \
  -d choices[1]="no" \
  -d choices[2]="maybe"
```

```javascript
var crunchable = require("crunchable")(
  "test_j3tepqvrYIaYsBQ6EzlHeABI"
);

crunchable.requestChoiceSingle({
  instruction: "Does the image contain any sexual content?",
  attachments_type: "image",
  attachments: [ "http://i.imgur.com/qRWH5.jpg" ],
  choices_type: "text",
  choices: [ "yes", "no", "maybe" ]
}, 10, function (err, res) {
  // handle response here
});
```

> Example Response (JSON)

```json
{
  "id": "44647b6f-b033-4788-9ee2-9d7aa5cb0158",
  "status": "complete",
  "response": "yes",
  "type": "choice-single",
  "instruction": "Does the image contain any sexual content?",
  "attachments_type": "image",
  "attachments": [ "http://i.imgur.com/qRWH5.jpg" ],
  "choices_type": "text",
  "choices": [ "yes", "no", "maybe" ]
}
```

Give a question with multiple potential answers and receive a single answer from the list as a response.

### HTTP Request

`POST /v1/requests/choice-single`

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

### Return Value

A `Request` object in a pending or completed state.

Name | Type | Description
--------- | ------- | -----------
id | string | A unique ID for this request, used to identify this request in future calls.
status | string | Current status of the request. Potential values:<br>`complete` - response ready under the `response` field<br>`pending` - response not ready and will be returned later
response *(optional)* | string | The response for the completed request (if available). One of of the values from the `choices` array.
type | string | The request type, always `choice-single`.
 | |
instruction | string | *provided when making the request*
attachments_type | string | *provided when making the request*
attachments | string[] | *provided when making the request*
choices_type | string | *provided when making the request*
choices | string[] | *provided when making the request*

## Multiple answers

```http
POST /v1/requests/choice-multiple?block=10 HTTP/1.1
Host: api.crunchable.io
Content-Type: application/json
Authorization: Basic dGVzdF9qM3RlcHF2cllJYVlzQlE2RXpsSGVBQkk6

{
  "instruction": "Select all the images of dogs",
  "choices_type": "image",
  "choices": [
    "http://i.imgur.com/pIEqBNj.jpg",
    "http://i.imgur.com/TKHgz9H.jpg",
    "http://i.imgur.com/7lLSWqY.jpg",
    "http://i.imgur.com/KwA3PwU.jpg",
    "http://i.imgur.com/3p4o2y4.jpg"
  ]
}
```

```shell
curl "https://api.crunchable.io/v1/requests/choice-multiple?block=10" \
  -u "test_j3tepqvrYIaYsBQ6EzlHeABI:" \
  -d instruction="Select all the images of dogs" \
  -d choices_type="image" \
  -d choices[0]="http://i.imgur.com/pIEqBNj.jpg", \
  -d choices[1]="http://i.imgur.com/TKHgz9H.jpg", \
  -d choices[2]="http://i.imgur.com/7lLSWqY.jpg", \
  -d choices[3]="http://i.imgur.com/KwA3PwU.jpg", \
  -d choices[4]="http://i.imgur.com/3p4o2y4.jpg"
```

```javascript
var crunchable = require("crunchable")(
  "test_j3tepqvrYIaYsBQ6EzlHeABI"
);

crunchable.requestChoiceMultiple({
  instruction: "Select all the images of dogs",
  choices_type: "image",
  choices: [
    "http://i.imgur.com/pIEqBNj.jpg",
    "http://i.imgur.com/TKHgz9H.jpg",
    "http://i.imgur.com/7lLSWqY.jpg",
    "http://i.imgur.com/KwA3PwU.jpg",
    "http://i.imgur.com/3p4o2y4.jpg"
  ]
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
    "http://i.imgur.com/pIEqBNj.jpg",
    "http://i.imgur.com/7lLSWqY.jpg",
    "http://i.imgur.com/KwA3PwU.jpg"
  ],
  "type": "choice-multiple",
  "instruction": "Select all the images of dogs",
  "choices_type": "image",
  "choices": [
    "http://i.imgur.com/pIEqBNj.jpg",
    "http://i.imgur.com/TKHgz9H.jpg",
    "http://i.imgur.com/7lLSWqY.jpg",
    "http://i.imgur.com/KwA3PwU.jpg",
    "http://i.imgur.com/3p4o2y4.jpg"
  ]
}
```

Give a question with multiple potential answers and receive multiple answers from the list as a response.

### HTTP Request

`POST /v1/requests/choice-multiple`

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
min *(optional)* | number | Minimum number of allowed answers Defaults to 1.
max *(optional)* | number | Maximum number of allowed answers. Defaults to the total number of choices.

### Return Value

A `Request` object in a pending or completed state.

Name | Type | Description
--------- | ------- | -----------
id | string | A unique ID for this request, used to identify this request in future calls.
status | string | Current status of the request. Potential values:<br>`complete` - response ready under the `response` field<br>`pending` - response not ready and will be returned later
response *(optional)* | string[] | The response for the completed request (if available). Array of values from the `choices` array.
type | string | The request type, always `choice-multiple`.
 | |
instruction | string | *provided when making the request*
attachments_type | string | *provided when making the request*
attachments | string[] | *provided when making the request*
choices_type | string | *provided when making the request*
choices | string[] | *provided when making the request*
min | number | *provided when making the request*
max | number | *provided when making the request*

# Free Form

## Free text

```http
POST /v1/requests/free-text?block=10 HTTP/1.1
Host: api.crunchable.io
Content-Type: application/json
Authorization: Basic dGVzdF9qM3RlcHF2cllJYVlzQlE2RXpsSGVBQkk6

{
  "instruction": "Translate from Spanish to English",
  "attachments_type": "text",
  "attachments": [ "hola mundo" ]
}
```

```shell
curl "https://api.crunchable.io/v1/requests/free-text?block=10" \
  -u "test_j3tepqvrYIaYsBQ6EzlHeABI:" \
  -d instruction="Translate from Spanish to English" \
  -d attachments_type="text" \
  -d attachments[0]="hola mundo"
```

```javascript
var crunchable = require("crunchable")(
  "test_j3tepqvrYIaYsBQ6EzlHeABI"
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

## Image

```http
POST /v1/requests/image?block=10 HTTP/1.1
Host: api.crunchable.io
Content-Type: application/json
Authorization: Basic dGVzdF9qM3RlcHF2cllJYVlzQlE2RXpsSGVBQkk6

{
  "instruction": "A picture of a birthday cake"
}
```

```shell
curl "https://api.crunchable.io/v1/requests/image?block=10" \
  -u "test_j3tepqvrYIaYsBQ6EzlHeABI:" \
  -d instruction="A picture of a birthday cake"
```

```javascript
var crunchable = require("crunchable")(
  "test_j3tepqvrYIaYsBQ6EzlHeABI"
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

```http
POST /v1/requests/video?block=10 HTTP/1.1
Host: api.crunchable.io
Content-Type: application/json
Authorization: Basic dGVzdF9qM3RlcHF2cllJYVlzQlE2RXpsSGVBQkk6

{
  "instruction": "A video of a cat walking"
}
```

```shell
curl "https://api.crunchable.io/v1/requests/video?block=10" \
  -u "test_j3tepqvrYIaYsBQ6EzlHeABI:" \
  -d instruction="A video of a cat walking"
```

```javascript
var crunchable = require("crunchable")(
  "test_j3tepqvrYIaYsBQ6EzlHeABI"
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

```http
POST /v1/requests/audio?block=10 HTTP/1.1
Host: api.crunchable.io
Content-Type: application/json
Authorization: Basic dGVzdF9qM3RlcHF2cllJYVlzQlE2RXpsSGVBQkk6

{
  "instruction": "Pronounce the word",
  "attachments_type": "text",
  "attachments": [ "encyclopedia" ]
}
```

```shell
curl "https://api.crunchable.io/v1/requests/audio?block=10" \
  -u "test_j3tepqvrYIaYsBQ6EzlHeABI:" \
  -d instruction="Pronounce the word" \
  -d attachments_type="text" \
  -d attachments[0]="encyclopedia"
```

```javascript
var crunchable = require("crunchable")(
  "test_j3tepqvrYIaYsBQ6EzlHeABI"
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
  "type": "video",
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

<h1 id="toc-section">Management</h1>

# Requests

## Retrieve request

```http
GET /v1/requests/44647b6f-b033-4788-9ee2-9d7aa5cb0158?block=10 HTTP/1.1
Host: api.crunchable.io
Authorization: Basic dGVzdF9qM3RlcHF2cllJYVlzQlE2RXpsSGVBQkk6
```

```shell
curl "https://api.crunchable.io/v1/requests/44647b6f-b033-4788-9ee2-9d7aa5cb0158?block=10" \
  -u "test_j3tepqvrYIaYsBQ6EzlHeABI:"
```

```javascript
var crunchable = require("crunchable")(
  "test_j3tepqvrYIaYsBQ6EzlHeABI"
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
  "response": "yes",
  "type": "choice-single",
  "instruction": "Does the image contain any sexual content?",
  "attachments_type": "image",
  "attachments": [ "http://i.imgur.com/qRWH5.jpg" ],
  "choices_type": "text",
  "choices": [ "yes", "no", "maybe" ]
}
```

Retrieve the details of an existing request. Supply the unique request ID returned when the request was initially created.

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

# Responses

## Retrieve response

```http
GET /v1/responses/44647b6f-b033-4788-9ee2-9d7aa5cb0158?block=10 HTTP/1.1
Host: api.crunchable.io
Authorization: Basic dGVzdF9qM3RlcHF2cllJYVlzQlE2RXpsSGVBQkk6
```

```shell
curl "https://api.crunchable.io/v1/responses/44647b6f-b033-4788-9ee2-9d7aa5cb0158?block=10" \
  -u "test_j3tepqvrYIaYsBQ6EzlHeABI:"
```

```javascript
var crunchable = require("crunchable")(
  "test_j3tepqvrYIaYsBQ6EzlHeABI"
);

crunchable.getResponse('44647b6f-b033-4788-9ee2-9d7aa5cb0158', 10, function (err, res) {
  // handle response here
});
```

> Example Response (JSON)

```json
{
  "id": "44647b6f-b033-4788-9ee2-9d7aa5cb0158",
  "response": "yes"
}
```

Retrieve the details of a response to a specific request. Supply the unique request ID returned when the request was initially created.

### HTTP Request

`GET /v1/responses/{request_id}`

### Path Parameters

Name | Type | Description
--------- | ------- | -----------
request_id | string | The unique ID of the request, returned when the request was initially created.

### Query Parameters

Name | Default | Description
--------- | ------- | -----------
block | 0 | Time in seconds the request should block for a response. If the request isn't completed before this timeout, a pending result is returned.

### Return Value

The response content. If the response isn't ready yet because the request is still pending, HTTP error code `449 Pending` is returned.

Name | Type | Description
--------- | ------- | -----------
id | string | A unique ID for this request, used to identify this request in future calls.
response | string | The response for the completed request. Format depends on the request type.

<h1 id="toc-section">Appendix</h1>
