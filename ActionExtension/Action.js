//
//  Action.js
//  ActionExtension
//
//  Created by Doug Williams on 12/3/15.
//  Copyright © 2015 Doug Williams. All rights reserved.
//

var Action = function() {};

Action.prototype = {
    
    run: function(arguments) {
        arguments.completionFunction({ "currentURL" : document.URL });
    }

};
    
var ExtensionPreprocessingJS = new Action;
