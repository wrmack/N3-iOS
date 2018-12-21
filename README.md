# N3-iOS
Using the N3 library in iOS with the Javascriptcore api

This might assist others trying to integrate rdf and Solid into iOS.

I installed the N3 library from https://github.com/rdfjs/N3.js

Then bundled with browserify in standalone mode:

```
browserify node_modules/n3/N3.js --standalone N3  > n3bundle.js
```

Standalone mode gives you access to all exports in N3.js from Swift.

