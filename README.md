# node-atlassian-confluence
Node.js client library to interact with Atlassian Confluence

## Requirements
This module currently only support Confluence 5.5+

## Installation

If you have the node package manager, npm, installed:

```shell
npm install --save atlassian-confluence
```

## Getting Started


Example:

```javascript
var confluence = require('atlassian-confluence');

confluence.useSSL = false
confluence.username = 'your_username';
confluence.password = 'your_password';
confluence.host = 'confluence_host.com';
confluence.port = 9080; // Defaults to 443 if useSSL is true. Otherwise, defaults to 80
confluence.context = '/wiki'; // Optional

confluence.simpleSearch('help', { limit : 3 }, function (res) {
    if (res) {
        res.results.forEach(function(result) {
            console.log(result.title);
        })
    }
});
```

Refer to https://docs.atlassian.com/atlassian-confluence/REST/latest for additional documentation.