var TheoplayerSdkUtils = /** @class */ (function () {
    function TheoplayerSdkUtils() {
        var _this = this;
        this.theoplayerJsToJavaEventListeners = {};
        this.setTargetQuality = function (track, qualityIDs) {
            var ids = Array.isArray(qualityIDs) ? qualityIDs : [qualityIDs];
            track.targetQuality = ids.map(function (qualityID) {
                var qualityIndex = track.qualities.map(function (quality) { return quality.id; }).indexOf(qualityID);
                return track.qualities[qualityIndex];
            });
        };
        this.addSdkEventListener = function (type, dispatcher, listenerMapKey, listener, debug) {
            if (debug === void 0) { debug = false; }
            if (typeof dispatcher == 'undefined' || !dispatcher) {
                if (debug) {
                    window.console.error('addSdkEventListener failed because of invalid dispatcher, type [' + type + '], listenerMapKey [' + listenerMapKey + ']');
                }
                return;
            }
            _this.theoplayerJsToJavaEventListeners[listenerMapKey] = _this.theoplayerJsToJavaEventListeners[listenerMapKey] || {};
            _this.theoplayerJsToJavaEventListeners[listenerMapKey][type] = _this.theoplayerJsToJavaEventListeners[listenerMapKey][type] || {};
            _this.theoplayerJsToJavaEventListeners[listenerMapKey][type] = listener;
            dispatcher.addEventListener(type, _this.theoplayerJsToJavaEventListeners[listenerMapKey][type]);
        };
        this.removeSdkEventListener = function (type, dispatcher, listenerMapKey) {
            var listenersForDispatcher = _this.theoplayerJsToJavaEventListeners[listenerMapKey];
            var listenerForDispatcherForType = listenersForDispatcher && listenersForDispatcher[type];
            if (listenerForDispatcherForType) {
                if (dispatcher) {
                    dispatcher.removeEventListener(type, listenerForDispatcherForType);
                }
                delete _this.theoplayerJsToJavaEventListeners[listenerMapKey][type];
            }
        };
        this.removeAllSdkEventListeners = function (dispatcher, listenerMapKey) {
            if (dispatcher) {
                var theoplayerJsToJavaEventListeners = _this.theoplayerJsToJavaEventListeners;
                if (theoplayerJsToJavaEventListeners && theoplayerJsToJavaEventListeners[listenerMapKey]) {
                    for (var type in theoplayerJsToJavaEventListeners[listenerMapKey]) {
                        dispatcher.removeEventListener(type, theoplayerJsToJavaEventListeners[listenerMapKey][type]);
                    }
                    delete theoplayerJsToJavaEventListeners[listenerMapKey];
                }
            }
        };
    }
    TheoplayerSdkUtils.prototype.setSource = function (source) {
        theoplayerEventProcessors.onSourceSet();
        player.source = source;
    };
    return TheoplayerSdkUtils;
}());
var Base64Utils = /** @class */ (function () {
    function Base64Utils() {
        var _this = this;
        this.lookup = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'.split('');
        this.maxChunkLength = 16383; // must be multiple of 3
        this.fromByteArray = function (uint8) {
            var len = uint8.length;
            var extraBytes = len % 3; // if we have 1 byte left, pad 2 bytes
            var parts = [];
            // go through the array every three bytes, we'll deal with trailing stuff later
            var len2 = len - extraBytes;
            for (var start = 0; start < len2; start += _this.maxChunkLength) {
                parts.push(_this.encodeChunk(uint8, start, Math.min(len2, start + _this.maxChunkLength)));
            }
            // pad the end with zeros, but make sure to not forget the extra bytes
            if (extraBytes === 1) {
                var byte1 = uint8[len - 1];
                parts.push(_this.lookup[(byte1 >> 2)]
                    + _this.lookup[(byte1 & 0x03) << 4]
                    + '==');
            }
            else if (extraBytes === 2) {
                var byte1 = uint8[len - 2];
                var byte2 = uint8[len - 1];
                parts.push(_this.lookup[(byte1 >> 2)]
                    + _this.lookup[((byte1 & 0x03) << 4) | (byte2 >> 4)]
                    + _this.lookup[(byte2 & 0x0f) << 2]
                    + '=');
            }
            return parts.join('');
        };
        this.encodeChunk = function (uint8, start, end) {
            var output = [];
            for (var i = start; i < end; i += 3) {
                output.push(_this.tripletToBase64(uint8[i], uint8[i + 1], uint8[i + 2]));
            }
            return output.join('');
        };
        this.tripletToBase64 = function (byte1, byte2, byte3) {
            return _this.lookup[(byte1 >> 2)]
                + _this.lookup[((byte1 & 0x03) << 4) | (byte2 >> 4)]
                + _this.lookup[((byte2 & 0x0f) << 2) | (byte3 >> 6)]
                + _this.lookup[(byte3 & 0x3f)];
        };
        this.arrayBufferToBase64String = function (arrayBuffer) {
            return _this.fromByteArray(new Uint8Array(arrayBuffer));
        };
    }
    return Base64Utils;
}());
var theoplayerSdkUtils = new TheoplayerSdkUtils();
//TODO: this should be done better, accessing the methods via static class.
var base64Utils = new Base64Utils();
