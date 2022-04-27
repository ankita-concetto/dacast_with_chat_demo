//Native Object that actually caches stuff
var THEOplayerCacheUtils = /** @class */ (function () {
    function THEOplayerCacheUtils() {
        this.cacheCallbackHandler = new ResultCallbackHandler();
        this.javaIdToTaskMap = {};
    }
    THEOplayerCacheUtils.prototype.registerTaskId = function (javaId, task) {
        task['jsObjectRefId'] = javaId;
        this.javaIdToTaskMap[javaId] = task;
    };
    THEOplayerCacheUtils.prototype.registerTaskInIdMap = function (task) {
        var javaId = task['jsObjectRefId'];
        if (javaId) {
            return javaId;
        }
        var jsCreatedJavaId = THEOplayerCacheUtils.createNewJavaId();
        this.registerTaskId(jsCreatedJavaId, task);
        return jsCreatedJavaId;
    };
    THEOplayerCacheUtils.createNewJavaId = function () {
        return 'js_' + THEOplayerCacheUtils.jsCreatedJavaIdCounter++;
    };
    THEOplayerCacheUtils.prototype.getCachingTaskForId = function (id) {
        return this.javaIdToTaskMap[id];
    };
    THEOplayerCacheUtils.prototype.createCachingTask = function (source, params, javaId) {
        var task = THEOplayer.cache.createTask(source, params);
        this.registerTaskId(javaId, task);
    };
    THEOplayerCacheUtils.jsCreatedJavaIdCounter = 1;
    return THEOplayerCacheUtils;
}());
var theoplayerCacheUtils = new THEOplayerCacheUtils();
