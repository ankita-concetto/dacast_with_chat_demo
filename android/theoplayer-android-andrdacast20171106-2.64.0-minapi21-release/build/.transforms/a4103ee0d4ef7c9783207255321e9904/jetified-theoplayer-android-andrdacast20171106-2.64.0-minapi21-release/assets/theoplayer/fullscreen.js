function polyfillTHEOplayerViewFullscreen() {
    var MAX_SIGNED_INT = Math.pow(2, 31) - 1;
    var theoFullscreenElement = null;
    function noOp() {
        return;
    }
    function elevateToTopOfStackingContexts(element) {
        element.classList.add("theo-webkit-full-screen" /* WEBKITFULLSCREEN */);
        var parent = element.parentElement;
        while (parent) {
            parent.classList.add("theo-webkit-full-screen-ancestor" /* WEBKITFULLSCREENANCESTOR */);
            parent = parent.parentElement;
        }
    }
    function restoreOrderInStackingContexts(element) {
        element.classList.remove("theo-webkit-full-screen" /* WEBKITFULLSCREEN */);
        var parent = element.parentElement;
        while (parent) {
            parent.classList.remove("theo-webkit-full-screen-ancestor" /* WEBKITFULLSCREENANCESTOR */);
            parent = parent.parentElement;
        }
    }
    Element.prototype["requestFullscreen" /* REQUESTFULLSCREEN */] = function () {
        var replacingOther = false;
        if (theoFullscreenElement) {
            replacingOther = true;
            theoFullscreenElement["exitFullscreen" /* EXITFULLSCREEN */](replacingOther).catch(noOp);
        }
        theoFullscreenElement = this;
        elevateToTopOfStackingContexts(this);
        if (!replacingOther) {
            theoplayerWebViewHelper.onEnterFullScreenView();
        }
        this.dispatchEvent(new Event("fullscreenchange" /* FULLSCREENCHANGE */, { bubbles: true }));
        return Promise.resolve();
    };
    Element.prototype["exitFullscreen" /* EXITFULLSCREEN */] = function (replacingOther) {
        if (theoFullscreenElement !== this) {
            return Promise.reject(new TypeError('Element not fullscreen'));
        }
        theoFullscreenElement = null;
        restoreOrderInStackingContexts(this);
        if (!replacingOther) {
            theoplayerWebViewHelper.onExitFullScreenView();
        }
        this.dispatchEvent(new Event("fullscreenchange" /* FULLSCREENCHANGE */, { bubbles: true }));
        return Promise.resolve();
    };
    document["exitFullscreen" /* EXITFULLSCREEN */] = function () {
        if (theoFullscreenElement) {
            return theoFullscreenElement["exitFullscreen" /* EXITFULLSCREEN */]();
        }
        else {
            return Promise.reject(new TypeError('No fullscreen element'));
        }
    };
    Object.defineProperty(document, "fullscreenEnabled" /* FULLSCREENENABLED */, {
        get: function () {
            return true;
        }
    });
    Object.defineProperty(document, "fullscreenElement" /* FULLSCREENELEMENT */, {
        get: function () {
            return theoFullscreenElement;
        }
    });
    // screen.orientation.lock() would result in a rejected promise, so we just disable it to avoid console errors.
    ScreenOrientation.prototype.lock = ScreenOrientation.prototype.unlock = undefined; //TODO implement this natively
}
polyfillTHEOplayerViewFullscreen();
