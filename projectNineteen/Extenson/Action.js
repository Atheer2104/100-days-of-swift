var action = function() { }

action.prototype = {
    
run: function(parameters) {
    parameters.completionFunction({"URL": document.URL, "title": document.title});
},
    
finalize: function(parameters) {
    // the same name as in actionviewController
    var customJavaScript = parameters["customJavaScript"];
    eval(customJavaScript);
    
}
    
};

var ExtensionPreprocessingJS = new action
