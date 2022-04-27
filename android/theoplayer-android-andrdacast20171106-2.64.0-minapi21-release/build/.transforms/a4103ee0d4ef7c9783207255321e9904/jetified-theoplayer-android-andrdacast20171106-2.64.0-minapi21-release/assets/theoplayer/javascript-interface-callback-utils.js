var CallbackError = /** @class */ (function () {
    function CallbackError(code, description, details) {
        this.code = code;
        this.description = description;
        this.details = details;
    }
    ;
    return CallbackError;
}());
var ResultCallbackHandler = /** @class */ (function () {
    function ResultCallbackHandler() {
        this.currentCallbackId = 0;
        this.registry = {};
    }
    ResultCallbackHandler.prototype.handle = function (id) {
        var params = [];
        for (var _i = 1; _i < arguments.length; _i++) {
            params[_i - 1] = arguments[_i];
        }
        var callback = this.registry[id.toString()];
        if (callback && callback.handle) {
            callback.handle.apply(callback, params);
        }
        if (callback) {
            this.unRegister(id);
        }
    };
    ResultCallbackHandler.prototype.error = function (id, errorCode, description) {
        var callback = this.registry[id.toString()];
        if (callback && callback.error) {
            callback.error(new CallbackError(errorCode, description));
        }
        if (callback) {
            this.unRegister(id);
        }
    };
    ResultCallbackHandler.prototype.register = function (callback, error) {
        var callbackId = this.currentCallbackId++;
        this.registry[callbackId.toString()] = {
            handle: callback,
            error: error
        };
        return callbackId;
    };
    ResultCallbackHandler.prototype.unRegister = function (id) {
        this.registry[id.toString()] = undefined;
    };
    return ResultCallbackHandler;
}());
var ListenerCallbackHandler = /** @class */ (function () {
    function ListenerCallbackHandler() {
        this.currentCallbackId = 0;
        this.registry = {};
        this.listenerMap = {};
    }
    ListenerCallbackHandler.prototype.handle = function (id) {
        var params = [];
        for (var _i = 1; _i < arguments.length; _i++) {
            params[_i - 1] = arguments[_i];
        }
        var listener = this.registry[id.toString()];
        if (listener) {
            listener.apply(void 0, params);
        }
    };
    ListenerCallbackHandler.prototype.register = function (listener) {
        var callbackId = this.currentCallbackId++;
        this.registry[callbackId.toString()] = listener;
        this.listenerMap[listener] = callbackId;
        return callbackId;
    };
    ListenerCallbackHandler.prototype.lookup = function (listener) {
        return this.listenerMap[listener];
    };
    ListenerCallbackHandler.prototype.unRegister = function (listener) {
        if (this.listenerMap[listener]) {
            this.registry[this.lookup(listener).toString()] = undefined;
            this.listenerMap[listener] = undefined;
        }
    };
    return ListenerCallbackHandler;
}());
