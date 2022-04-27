var __rest = (this && this.__rest) || function (s, e) {
    var t = {};
    for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p) && e.indexOf(p) < 0)
        t[p] = s[p];
    if (s != null && typeof Object.getOwnPropertySymbols === "function")
        for (var i = 0, p = Object.getOwnPropertySymbols(s); i < p.length; i++) if (e.indexOf(p[i]) < 0)
            t[p[i]] = s[p[i]];
    return t;
};
var TimeRangesReplacer = /** @class */ (function () {
    function TimeRangesReplacer() {
    }
    TimeRangesReplacer.prototype.isReplaceable = function (value) {
        return typeof value != "undefined" && value != null &&
            typeof value.start == "function" &&
            typeof value.end == "function" &&
            typeof value.length == "number";
    };
    TimeRangesReplacer.prototype.replace = function (timeRanges) {
        var result = [];
        for (var i = 0; i < timeRanges.length; i++) {
            result[i] = {
                start: timeRanges.start(i),
                end: timeRanges.end(i)
            };
        }
        return result;
    };
    return TimeRangesReplacer;
}());
var AdCycleReplacer = /** @class */ (function () {
    function AdCycleReplacer() {
    }
    AdCycleReplacer.prototype.isReplaceable = function (ad) {
        return ad.integration &&
            ad.integration === 'google-ima' &&
            ad.adBreak;
    };
    AdCycleReplacer.prototype.replace = function (ad) {
        var adBreak = ad.adBreak, filteredAd = __rest(ad, ["adBreak"]);
        return filteredAd;
    };
    return AdCycleReplacer;
}());
var AdBreakCycleReplacer = /** @class */ (function () {
    function AdBreakCycleReplacer() {
    }
    AdBreakCycleReplacer.prototype.isReplaceable = function (adBreak) {
        return adBreak.integration &&
            adBreak.integration === 'google-ima' &&
            adBreak.ads &&
            typeof adBreak.ads.length == "number";
    };
    AdBreakCycleReplacer.prototype.replace = function (adBreak) {
        return {};
    };
    return AdBreakCycleReplacer;
}());
var CompositeReplacer = /** @class */ (function () {
    function CompositeReplacer(replacers) {
        this.replacers = replacers;
    }
    CompositeReplacer.prototype.isReplaceable = function (value) {
        return this.replacers.some(function (replacer) { return replacer.isReplaceable(value); });
    };
    CompositeReplacer.prototype.replace = function (value) {
        if (!value) {
            return undefined;
        }
        for (var _i = 0, _a = this.replacers; _i < _a.length; _i++) {
            var replacer = _a[_i];
            if (replacer.isReplaceable(value)) {
                return replacer.replace(value);
            }
        }
        return undefined;
    };
    return CompositeReplacer;
}());
var AndroidSdkSerializer = /** @class */ (function () {
    function AndroidSdkSerializer() {
    }
    // based on https://github.com/isaacs/json-stringify-safe/blob/02cfafd45f06d076ac4bf0dd28be6738a07a72f9/stringify.js#L4
    // which is used in NodeJS and detects and replaces circular references
    AndroidSdkSerializer.jsonToString = function (obj, replacer, cycleReplacer) {
        if (replacer === void 0) { replacer = AndroidSdkSerializer.DEFAULT_REPLACER; }
        if (cycleReplacer === void 0) { cycleReplacer = AndroidSdkSerializer.DEFAULT_CYCLE_REPLACER; }
        return JSON.stringify(obj, this.serializer(function (key, value) {
            if (replacer.isReplaceable(value)) {
                return replacer.replace(value);
            }
            else {
                return value;
            }
        }, function (key, value) {
            if (cycleReplacer.isReplaceable(value)) {
                return cycleReplacer.replace(value);
            }
            else {
                return "[Circular ~]";
            }
        }));
    };
    ;
    AndroidSdkSerializer.DEFAULT_REPLACER = new CompositeReplacer([
        new TimeRangesReplacer()
    ]);
    AndroidSdkSerializer.DEFAULT_CYCLE_REPLACER = new CompositeReplacer([
        new AdCycleReplacer(),
        new AdBreakCycleReplacer()
    ]);
    AndroidSdkSerializer.serializer = function (replacer, cycleReplacer) {
        var stack = [], keys = [];
        return function (key, value) {
            if (stack.length > 0) {
                var thisPos = stack.indexOf(this);
                ~thisPos ? stack.splice(thisPos + 1) : stack.push(this); //if 'this' is not in stack, then clear stack, otherwise, add 'this' to stack
                ~thisPos ? keys.splice(thisPos, Infinity, key) : keys.push(key);
                if (~stack.indexOf(value))
                    value = cycleReplacer.call(this, key, value);
            }
            else {
                stack.push(value);
            }
            return replacer.call(this, key, value);
        };
    };
    return AndroidSdkSerializer;
}());
