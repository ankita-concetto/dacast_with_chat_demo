var TrackMirroringMap = /** @class */ (function () {
    function TrackMirroringMap() {
        this.internalDict = {};
        this.stagedForRemovalDict = {};
    }
    TrackMirroringMap.prototype.contains = function (track) {
        return !!this.internalDict[track.uid] || !!this.stagedForRemovalDict[track.uid];
    };
    TrackMirroringMap.prototype.get = function (trackUid) {
        return this.internalDict[trackUid] ? this.internalDict[trackUid] : this.stagedForRemovalDict[trackUid];
    };
    TrackMirroringMap.prototype.register = function (track) {
        this.internalDict[track.uid] = track;
        return track.uid;
    };
    TrackMirroringMap.prototype.removeStagedForRemoval = function () {
        this.stagedForRemovalDict = {};
    };
    TrackMirroringMap.prototype.stageAllForRemoval = function () {
        this.stagedForRemovalDict = this.internalDict;
        this.internalDict = {};
    };
    return TrackMirroringMap;
}());
var CueMirroringMap = /** @class */ (function () {
    function CueMirroringMap() {
        this.internalDict = {};
        this.uidCounter = 0;
    }
    CueMirroringMap.prototype.register = function (cue) {
        this.internalDict[this.uidCounter] = cue;
        return this.uidCounter++;
    };
    CueMirroringMap.prototype.get = function (uid) {
        return this.internalDict[uid];
    };
    CueMirroringMap.prototype.remove = function (uid) {
        delete this.internalDict[uid];
    };
    return CueMirroringMap;
}());
var TheoplayerEventProcessors = /** @class */ (function () {
    function TheoplayerEventProcessors() {
        var _this = this;
        this.trackMirroringMap = new TrackMirroringMap();
        this.cueMirroringMap = new CueMirroringMap();
        this.onSourceChangeEvent = function () {
            _this.trackMirroringMap.removeStagedForRemoval();
            _this.cueMirroringMap = new CueMirroringMap();
        };
        this.onSourceSet = function () {
            _this.trackMirroringMap.stageAllForRemoval();
        };
        this.createLiteCue = function (cue) {
            var content = cue.content;
            if (content && content.outerHTML) {
                content = content.outerHTML;
            }
            return {
                id: cue.id,
                startTime: cue.startTime,
                endTime: cue.endTime,
                content: content,
            };
        };
        this.createLiteTtmlCue = function (cue) {
            var content = cue.content;
            var ttmlType = "unknown" /* UNKNOWN_ */;
            var imageData = _this.parseImageDataFromSMPTETTContent(content);
            if (imageData) {
                content = imageData;
                ttmlType = "ttml_image" /* IMAGE_ */;
            }
            else if (content && content.outerHTML) {
                content = content.outerHTML;
                ttmlType = "ttml_text" /* TEXT_ */;
            }
            return {
                id: cue.id,
                startTime: cue.startTime,
                endTime: cue.endTime,
                content: content,
                ttmlType: ttmlType,
            };
        };
        this.createLiteDateRangeCue = function (cue) {
            var convertedCustomAttributes;
            //converting ArrayBuffers from custom attributes to Java-digestible base64 values
            if (cue.customAttributes) {
                convertedCustomAttributes = {};
                for (var caKey in cue.customAttributes) {
                    var caValue = cue.customAttributes[caKey];
                    if (caValue instanceof ArrayBuffer) {
                        convertedCustomAttributes[caKey] = {
                            value: base64Utils.arrayBufferToBase64String(caValue),
                            type: "daterange-ca-type_arraybuffer" /* ARRAYBUFFER_ */
                        };
                    }
                    else {
                        convertedCustomAttributes[caKey] = {
                            value: caValue,
                            type: ((typeof caValue === "number") ? "daterange-ca-type_number" /* NUMBER_ */ : "daterange-ca-type_string" /* STRING_ */)
                        };
                    }
                }
            }
            return {
                id: cue.id,
                startTime: cue.startTime,
                endTime: cue.endTime,
                content: cue.content,
                class: cue.class,
                startDate: cue.startDate,
                endDate: cue.endDate,
                duration: cue.duration,
                plannedDuration: cue.plannedDuration,
                endOnNext: cue.endOnNext,
                scte35Cmd: base64Utils.arrayBufferToBase64String(cue.scte35Cmd),
                scte35Out: base64Utils.arrayBufferToBase64String(cue.scte35Out),
                scte35In: base64Utils.arrayBufferToBase64String(cue.scte35In),
                customAttributes: convertedCustomAttributes
            };
        };
        this.parseImageDataFromSMPTETTContent = function (content) {
            var imageNode = _this.findImageElement(content);
            if (imageNode) {
                return imageNode.innerHTML;
            }
            return undefined;
        };
        this.findImageElement = function (element) {
            var children = element.children;
            if (children.length === 0) {
                return undefined;
            }
            for (var i = 0; i < children.length; i++) {
                var child = children.item(i);
                if ((child.nodeName === "image") || (child.nodeName === "smpte:image")) {
                    return child;
                }
                else {
                    return _this.findImageElement(child);
                }
            }
        };
        this.createLiteTextTrack = function (track, withCues) {
            var liteTrack = {
                id: track.id,
                uid: track.uid,
                mode: track.mode,
                readyState: track.readyState,
                kind: track.kind,
                type: track.type,
                label: track.label,
                language: track.language,
                inBandMetadataTrackDispatchType: track.inBandMetadataTrackDispatchType
            };
            if (withCues && track.activeCues) {
                liteTrack.activeCues = track.activeCues.map(_this.createLiteCue);
            }
            if (withCues && track.cues) {
                liteTrack.cues = track.cues.map(_this.createLiteCue);
            }
            return liteTrack;
        };
        this.createLiteMediaTrack = function (track) {
            var liteTrack = _this.createLiteTrack(track);
            liteTrack.enabled = track.enabled;
            return liteTrack;
        };
        this.createLiteTrack = function (track) {
            return {
                uid: track.uid
            };
        };
        this.combineEventFuncs = function (func1, func2, dispatcher) {
            return function (e) {
                func2(func1(e, dispatcher), dispatcher);
            };
        };
        this.createLiteEvent = function (event) {
            return {
                type: event.type,
                date: event.date
            };
        };
        this.std_processor = function (event) {
            return event;
        };
        this.empty_processor = function (event) {
            return undefined;
        };
        this.texttrack_CueChangeEvent_processor = function (event) {
            var liteEvent = _this.createLiteEvent(event);
            liteEvent.liteData = {
                activeCues: event.track.activeCues.map(_this.createLiteCue)
            };
            return liteEvent;
        };
        this.texttrack_ChangeEvent_processor = function (event) {
            var liteEvent = _this.createLiteEvent(event);
            liteEvent.liteData =
                {
                    track: _this.createLiteTextTrack(event.track, true)
                };
            return liteEvent;
        };
        this.attachAddTextTrackProcessor = function () {
            var addTrackListener = function (addTrackEvent) {
                var lightAddTrackEvent = theoplayerEventProcessors.texttrack_list_AddEvent_processor(addTrackEvent);
                var newTextTrack = theoplayerJavaTextTracks.handleAddTextTrackEvent(JSON.stringify(lightAddTrackEvent));
                addTrackEvent.track.addEventListener('addcue', function (addcueEvent) {
                    var lightAddCueEvent = theoplayerEventProcessors.texttrack_AddCueEvent_processor(addcueEvent);
                    newTextTrack.handleAddCueEvent(JSON.stringify(lightAddCueEvent));
                });
            };
            player.textTracks.addEventListener('addtrack', addTrackListener);
            player.textTracks.addEventListener('removetrack', function (removeTrackEvent) {
                for (var i = 0; i < player.textTracks.length; i++) {
                    player.textTracks.item(i).removeEventListener('addtrack', addTrackListener);
                }
            });
        };
        this.texttrack_AddCueEvent_processor = function (event) {
            var liteSingleCueEvent = _this.texttrack_singleCueEvent_processor(event);
            liteSingleCueEvent['jsObjectRefId'] = _this.cueMirroringMap.register(event.cue);
            event.cue['jsObjectRefId'] = liteSingleCueEvent['jsObjectRefId'];
            return liteSingleCueEvent;
        };
        this.texttrack_EnterCueEvent_processor = function (event) {
            var liteSingleCueEvent = _this.texttrack_singleCueEvent_processor(event);
            liteSingleCueEvent['jsObjectRefId'] = event.cue['jsObjectRefId'];
            return liteSingleCueEvent;
        };
        this.texttrack_ExitCueEvent_processor = function (event) {
            var liteSingleCueEvent = _this.texttrack_singleCueEvent_processor(event);
            liteSingleCueEvent['jsObjectRefId'] = event.cue['jsObjectRefId'];
            return liteSingleCueEvent;
        };
        this.texttrack_RemoveCueEvent_processor = function (event) {
            var texttrackSingleCueEvent = _this.texttrack_singleCueEvent_processor(event);
            texttrackSingleCueEvent['jsObjectRefId'] = event.cue['jsObjectRefId'];
            return texttrackSingleCueEvent;
        };
        this.texttrackcue_UpdateEvent_processor = function (event) {
            var liteSingleCueEvent = _this.texttrack_singleCueEvent_processor(event);
            liteSingleCueEvent['jsObjectRefId'] = event.cue['jsObjectRefId'];
            return liteSingleCueEvent;
        };
        this.createLiteTask = function (task) {
            return {
                id: theoplayerCacheUtils.registerTaskInIdMap(task),
                status: task.status,
                duration: task.duration,
                cached: task.cached,
                secondsCached: task.secondsCached,
                percentageCached: task.percentageCached,
                bytes: task.bytes,
                bytesCached: task.bytesCached
            };
        };
        this.track_list_RemoveEvent_processor = function (event) {
            var liteEvent = _this.createLiteEvent(event);
            liteEvent.track = _this.createLiteTrack(event.track);
            return liteEvent;
        };
        this.track_event_processor = function (event) {
            var liteEvent = _this.createLiteEvent(event);
            liteEvent.jsObjectRefId = _this.trackMirroringMap.register(event.track);
            return liteEvent;
        };
        this.track_list_AddEvent_processor = function (event) {
            var liteEvent = _this.track_event_processor(event);
            liteEvent.track = event.track;
            return liteEvent;
        };
        this.texttrack_list_AddEvent_processor = function (event) {
            var liteEvent = _this.track_event_processor(event);
            if (event.track) {
                liteEvent.track = _this.createLiteTextTrack(event.track, true);
                if (event.track.cues) {
                    liteEvent.cueObjectRefIdMappings = event.track.cues.map(_this.createJsObjectRefIdObj);
                }
            }
            return liteEvent;
        };
        this.texttrack_list_ChangeEvent_processor = function (event) {
            var liteEvent = _this.createLiteEvent(event);
            liteEvent.liteData = {
                track: _this.createLiteTextTrack(event.track, false)
            };
            return liteEvent;
        };
        this.mediatrack_list_ChangeEvent_processor = function (event) {
            var liteEvent = _this.createLiteEvent(event);
            liteEvent.liteData = {
                track: _this.createLiteMediaTrack(event.track)
            };
            return liteEvent;
        };
        this.cache_StateChangeEvent_processor = function (event) {
            var liteEvent = _this.createLiteEvent(event);
            liteEvent.liteData = {
                status: THEOplayer.cache.status,
            };
            return liteEvent;
        };
        this.replaceTaskIdWithLookedUp = function (task) {
            var taskCopy = _this.createLiteTask(task);
            taskCopy.source = task.source;
            taskCopy.parameters = task.parameters;
            return taskCopy;
        };
        this.cachingtask_Event_processor = function (event, dispatcher) {
            var liteEvent = _this.createLiteEvent(event);
            var liteTask = _this.createLiteTask(dispatcher);
            liteEvent.liteData = {
                task: liteTask,
            };
            return liteEvent;
        };
        this.player_SourceChangeEvent_processor = function (event) {
            _this.onSourceChangeEvent();
            return event;
        };
        this.vr_DirectionChangeEvent_processor = function (event) {
            var liteEvent = _this.createLiteEvent(event);
            liteEvent.liteData = { direction: player.vr.direction };
            return liteEvent;
        };
        this.vr_StereoChangeEvent_processor = function (event) {
            var liteEvent = _this.createLiteEvent(event);
            liteEvent.liteData = { stereo: player.vr.stereo };
            return liteEvent;
        };
        this.vr_StateChangeEvent_processor = function (event) {
            var liteEvent = _this.createLiteEvent(event);
            liteEvent.liteData = { state: player.vr.state };
            return liteEvent;
        };
        this.cachingtasklist_Event_processor = function (event) {
            var liteEvent = _this.createLiteEvent(event);
            liteEvent['task'] = _this.replaceTaskIdWithLookedUp(event.task);
            return liteEvent;
        };
        this.createJsObjectRefIdObj = function (cue) {
            var jsObjectRefId = cue['jsObjectRefId'];
            if (!jsObjectRefId) {
                jsObjectRefId = _this.cueMirroringMap.register(cue);
                cue['jsObjectRefId'] = jsObjectRefId;
            }
            return {
                jsObjectRefId: jsObjectRefId
            };
        };
    }
    TheoplayerEventProcessors.prototype.texttrack_singleCueEvent_processor = function (event) {
        var liteEvent = this.createLiteEvent(event);
        var liteCue = undefined;
        if (event.cue.track && event.cue.track.type === 'ttml') {
            liteCue = this.createLiteTtmlCue(event.cue);
        }
        else if (event.cue.track && event.cue.track.type === 'daterange') {
            liteCue = this.createLiteDateRangeCue(event.cue);
        }
        else {
            liteCue = this.createLiteCue(event.cue);
        }
        liteEvent.liteData = {
            cue: liteCue
        };
        return liteEvent;
    };
    return TheoplayerEventProcessors;
}());
var theoplayerEventProcessors = new TheoplayerEventProcessors();
