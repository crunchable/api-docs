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

<h1 id="toc-section">Requests</h1>

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
curl "https://api.crunchable.io/v1/requests/choice-single" \
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

crunchable.choiceSingle({
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
attachments_type *(optional)* | string | The type of the array elements in the `attachments` parameter. Potential values:<br>`text` - plain text *(default)*<br>`image` - URL of an image (jpg,png,gif)<br>`video` - URL of a video (mp4)<br>`sound` - URL of a sound (wav,mp3)<br>`website` - URL of a website (html)
attachments *(optional)* | string[] | An array of strings providing additional resources which are required to perform the instruction.
choices_type *(optional)* | string | The type of the array elements in the `choices` parameter. Potential values:<br>`text` - plain text *(default)*<br>`image` - URL of an image (jpg,png,gif)<br>`video` - URL of a video (mp4)<br>`sound` - URL of a sound (wav,mp3)<br>`website` - URL of a website (html)
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
curl "https://api.crunchable.io/v1/requests/choice-multiple" \
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

crunchable.choiceMultiple({
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
attachments_type *(optional)* | string | The type of the array elements in the `attachments` parameter. Potential values:<br>`text` - plain text *(default)*<br>`image` - URL of an image (jpg,png,gif)<br>`video` - URL of a video (mp4)<br>`sound` - URL of a sound (wav,mp3)<br>`website` - URL of a website (html)
attachments *(optional)* | string[] | An array of strings providing additional resources which are required to perform the instruction.
choices_type *(optional)* | string | The type of the array elements in the `choices` parameter. Potential values:<br>`text` - plain text *(default)*<br>`image` - URL of an image (jpg,png,gif)<br>`video` - URL of a video (mp4)<br>`sound` - URL of a sound (wav,mp3)<br>`website` - URL of a website (html)
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

<h1 id="toc-section">Appendix</h1>
