/// <reference path="chromecast-bridge.d.ts" /> // Fix for WebStorm
var theoplayerCastUtils;
(function (theoplayerCastUtils) {
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
            if (callback) {
                this.unRegister(id);
            }
            if (callback && callback.handle) {
                callback.handle.apply(callback, params);
            }
        };
        ResultCallbackHandler.prototype.error = function (id, errorCode, description) {
            var callback = this.registry[id.toString()];
            if (callback) {
                this.unRegister(id);
            }
            if (callback && callback.error) {
                callback.error(new CallbackError(errorCode, description));
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
    theoplayerCastUtils.ResultCallbackHandler = ResultCallbackHandler;
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
    theoplayerCastUtils.ListenerCallbackHandler = ListenerCallbackHandler;
})(theoplayerCastUtils || (theoplayerCastUtils = {}));
var chrome;
(function (chrome) {
    var cast;
    (function (cast) {
        var globalSession;
        function addReceiverActionListener(listener) {
            var actualListener = function (receiverName, action) {
                listener(new Receiver(receiverName), action);
            };
            chromecastBridge.addReceiverActionListener(chromecastListenerCallbackHandler.register(actualListener));
        }
        cast.addReceiverActionListener = addReceiverActionListener;
        function initialize(apiConfig, successCallback, errorCallback) {
            var actualSessionListener = function (receiverName) {
                if (globalSession) {
                    apiConfig.sessionListener(globalSession);
                }
            };
            var bridgeApiConfig = {
                autoJoinPolicy: apiConfig.autoJoinPolicy,
                defaultActionPolicy: apiConfig.defaultActionPolicy,
                receiverListener: chromecastListenerCallbackHandler.register(apiConfig.receiverListener),
                sessionListener: chromecastListenerCallbackHandler.register(actualSessionListener),
                sessionRequest: {
                    appId: apiConfig.sessionRequest.appId
                }
            };
            chromecastBridge.initialize(JSON.stringify(bridgeApiConfig), chromecastCallbackHandler.register(successCallback, errorCallback));
        }
        cast.initialize = initialize;
        ;
        function requestSession(givenSuccessCallback, errorCallback, sessionRequest) {
            var actualSuccessCallback = function (receiverName) {
                globalSession = new Session(new Receiver(receiverName));
                givenSuccessCallback(globalSession);
            };
            var callbackId = chromecastCallbackHandler.register(actualSuccessCallback, errorCallback);
            sessionBridge.requestSession(callbackId);
        }
        cast.requestSession = requestSession;
        ;
        var ApiConfig = /** @class */ (function () {
            function ApiConfig(sessionRequest, sessionListener, receiverListener, autoJoinPolicy, defaultActionPolicy) {
                this.sessionRequest = sessionRequest;
                this.sessionListener = sessionListener;
                this.receiverListener = receiverListener;
                this.autoJoinPolicy = autoJoinPolicy;
                this.defaultActionPolicy = defaultActionPolicy;
            }
            return ApiConfig;
        }());
        cast.ApiConfig = ApiConfig;
        var Image = /** @class */ (function () {
            function Image(url) {
                this.url = url;
            }
            ;
            return Image;
        }());
        cast.Image = Image;
        var Receiver = /** @class */ (function () {
            function Receiver(friendlyName) {
                this.friendlyName = friendlyName;
                this.volume = new Volume();
            }
            ;
            return Receiver;
        }());
        cast.Receiver = Receiver;
        var ReceiverAction;
        (function (ReceiverAction) {
            ReceiverAction[ReceiverAction["CAST"] = 0] = "CAST";
            ReceiverAction[ReceiverAction["STOP"] = 1] = "STOP";
        })(ReceiverAction = cast.ReceiverAction || (cast.ReceiverAction = {}));
        var ReceiverDisplayStatus = /** @class */ (function () {
            function ReceiverDisplayStatus(statusText, appImages) {
                this.statusText = statusText;
                this.appImages = appImages;
            }
            ;
            return ReceiverDisplayStatus;
        }());
        cast.ReceiverDisplayStatus = ReceiverDisplayStatus;
        cast.isAvailable = false;
        var Session = /** @class */ (function () {
            function Session(receiver) {
                var _this = this;
                this.receiver = receiver;
                this.mediaSessionList = [];
                this.mediaListeners = new Array();
                this.currMediaSessionId = 0;
                this.callMediaListeners = function (mediaSession) {
                    for (var _i = 0, _a = _this.mediaListeners; _i < _a.length; _i++) {
                        var mediaListener = _a[_i];
                        mediaListener(mediaSession);
                    }
                };
                var mediaBridge = sessionBridge.getCurrentMediaBridge();
                if (mediaBridge) {
                    this.mediaSessionList[this.currMediaSessionId] = new media.Media(mediaBridge.getContentId(), mediaBridge.getContentType(), mediaBridge.getCustomData(), mediaBridge);
                }
            }
            Object.defineProperty(Session.prototype, "status", {
                get: function () {
                    return sessionBridge.getStatus();
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(Session.prototype, "media", {
                get: function () {
                    // TODO: fix this if multiple media elements are possible
                    return this.mediaSessionList;
                },
                enumerable: true,
                configurable: true
            });
            Session.prototype.addMediaListener = function (listener) {
                this.mediaListeners.push(listener);
            };
            ;
            Session.prototype.removeMediaListener = function (listener) {
                delete this.mediaListeners[this.mediaListeners.indexOf(listener)];
            };
            ;
            Session.prototype.addMessageListener = function (nameSpace, listener) {
                sessionBridge.addMessageListener(nameSpace, chromecastListenerCallbackHandler.register(listener)); //TODO test
            };
            ;
            Session.prototype.removeMessageListener = function (nameSpace, listener) {
                sessionBridge.removeMessageListener(nameSpace, chromecastListenerCallbackHandler.lookup(listener)); //TODO test
            };
            ;
            Session.prototype.addUpdateListener = function (listener) {
                sessionBridge.addCastListener(chromecastListenerCallbackHandler.register(listener));
            };
            ;
            Session.prototype.removeUpdateListener = function (listener) {
                sessionBridge.removeCastListener(chromecastListenerCallbackHandler.lookup(listener));
            };
            ;
            Session.prototype.queueLoad = function (queueLoadRequest, onSuccess, onError) {
                // binded but never actually used
                return;
            };
            ;
            Session.prototype.loadMedia = function (loadRequest, givenSuccessCallback, errorCallback) {
                var _this = this;
                //this is used in: ChromecastPlayer.ts: this._session.loadMedia(loadRequest, (media : THEOCastMedia_) => {
                var givenLoadRequest = loadRequest;
                var actualLoadMediaSuccessCallback = function () {
                    _this.mediaSessionList[_this.currMediaSessionId] = new media.Media(givenLoadRequest.media.contentId, givenLoadRequest.media.contentType, givenLoadRequest.media.customData, sessionBridge.getCurrentMediaBridge());
                    givenSuccessCallback(_this.mediaSessionList[_this.currMediaSessionId]);
                    chromecastCallbackHandler.unRegister(successCallbackId);
                };
                var successCallbackId = chromecastCallbackHandler.register(actualLoadMediaSuccessCallback, errorCallback);
                sessionBridge.loadMedia(JSON.stringify(loadRequest), successCallbackId);
            };
            ;
            Session.prototype.sendMessage = function (nameSpace, message, successCallback, errorCallback) {
                //this is used in: ChromecastForwarder.ts: this._session.sendMessage(nameSpace, message, succesHandler, failureHandler);
                sessionBridge.sendMessage(nameSpace, JSON.stringify(message), chromecastCallbackHandler.register(successCallback, errorCallback));
            };
            ;
            Session.prototype.setReceiverMuted = function (muted, successCallback, errorCallback) {
                //this is used in: ChromecastPlayer.ts: this._session.setReceiverMuted(muted, () => {
                sessionBridge.setReceiverMuted(muted, chromecastCallbackHandler.register(successCallback, errorCallback));
            };
            ;
            Session.prototype.setReceiverVolumeLevel = function (newLevel, successCallback, errorCallback) {
                /*
                On Android, the receiver volume is set by the controls of the device and not by our player.
                The volume button only serves as a mute button.
                Therefore, we keep the volume of THEOplayer fixed at 1.
                If this method would actually call through to the native Chromecast SDK,
                then the volume is set to max every time this method is called (THEO-1871).
                 */
                successCallback();
            };
            ;
            Session.prototype.leave = function (successCallback, errorCallback) {
                //this is used in: ChromecastController.ts: this._castContext.endCurrentSession(stopCasting: false)
                sessionBridge.endSession(false, chromecastCallbackHandler.register(successCallback, errorCallback));
            };
            ;
            Session.prototype.stop = function (successCallback, errorCallback) {
                //this is used in: ChromecastController.ts: this._castContext.endCurrentSession(stopCasting: true)
                sessionBridge.endSession(true, chromecastCallbackHandler.register(successCallback, errorCallback));
            };
            ;
            return Session;
        }());
        cast.Session = Session;
        var SenderApplication = /** @class */ (function () {
            function SenderApplication(platform) {
                this.platform = platform;
            }
            ;
            return SenderApplication;
        }());
        cast.SenderApplication = SenderApplication;
        var SessionRequest = /** @class */ (function () {
            function SessionRequest(appId, capabilities, timeout) {
                this.appId = appId;
                this.capabilities = capabilities;
            }
            ;
            return SessionRequest;
        }());
        cast.SessionRequest = SessionRequest;
        var Volume = /** @class */ (function () {
            function Volume() {
            }
            ;
            Object.defineProperty(Volume.prototype, "level", {
                get: function () {
                    return sessionBridge.getVolume(); //In the Android SDK this returns 1 because we don't want to change the player volume since the volume bar is hidden by default
                },
                enumerable: true,
                configurable: true
            });
            ;
            Object.defineProperty(Volume.prototype, "muted", {
                get: function () {
                    return sessionBridge.isMute();
                },
                enumerable: true,
                configurable: true
            });
            return Volume;
        }());
        cast.Volume = Volume;
        var AutoJoinPolicy;
        (function (AutoJoinPolicy) {
            AutoJoinPolicy["TAB_AND_ORIGIN_SCOPED"] = "TAB_AND_ORIGIN_SCOPED";
            AutoJoinPolicy["ORIGIN_SCOPED"] = "ORIGIN_SCOPED";
            AutoJoinPolicy["PAGE_SCOPED"] = "PAGE_SCOPED";
        })(AutoJoinPolicy = cast.AutoJoinPolicy || (cast.AutoJoinPolicy = {}));
        var Capability;
        (function (Capability) {
            Capability["VIDEO_OUT"] = "VIDEO_OUT";
            Capability["AUDIO_OUT"] = "AUDIO_OUT";
            Capability["VIDEO_IN"] = "VIDEO_IN";
            Capability["AUDIO_IN"] = "AUDIO_IN";
        })(Capability = cast.Capability || (cast.Capability = {}));
        var DefaultActionPolicy;
        (function (DefaultActionPolicy) {
            DefaultActionPolicy["CREATE_SESSION"] = "CREATE_SESSION";
            DefaultActionPolicy["CAST_THIS_TAB"] = "CAST_THIS_TAB";
        })(DefaultActionPolicy = cast.DefaultActionPolicy || (cast.DefaultActionPolicy = {}));
        var ErrorCode;
        (function (ErrorCode) {
            ErrorCode["CANCEL"] = "CANCEL";
            ErrorCode["TIMEOUT"] = "TIMEOUT";
            ErrorCode["API_NOT_INITIALIZED"] = "API_NOT_INITIALIZED";
            ErrorCode["INVALID_PARAMETER"] = "INVALID_PARAMETER";
            ErrorCode["EXTENSION_NOT_COMPATIBLE"] = "EXTENSION_NOT_COMPATIBLE";
            ErrorCode["EXTENSION_MISSING"] = "EXTENSION_MISSING";
            ErrorCode["RECEIVER_UNAVAILABLE"] = "RECEIVER_UNAVAILABLE";
            ErrorCode["SESSION_ERROR"] = "SESSION_ERROR";
            ErrorCode["CHANNEL_ERROR"] = "CHANNEL_ERROR";
            ErrorCode["LOAD_MEDIA_FAILED"] = "LOAD_MEDIA_FAILED";
        })(ErrorCode = cast.ErrorCode || (cast.ErrorCode = {}));
        var ReceiverAvailability;
        (function (ReceiverAvailability) {
            ReceiverAvailability["AVAILABLE"] = "AVAILABLE";
            ReceiverAvailability["UNAVAILABLE"] = "UNAVAILABLE";
        })(ReceiverAvailability = cast.ReceiverAvailability || (cast.ReceiverAvailability = {}));
        var ReceiverType;
        (function (ReceiverType) {
            ReceiverType["CAST"] = "CAST";
            ReceiverType["HANGOUT"] = "HANGOUT";
            ReceiverType["CUSTOM"] = "CUSTOM";
        })(ReceiverType = cast.ReceiverType || (cast.ReceiverType = {}));
        var SenderPlatform;
        (function (SenderPlatform) {
            SenderPlatform["CHROME"] = "CHROME";
            SenderPlatform["IOS"] = "IOS";
            SenderPlatform["ANDROID"] = "ANDROID";
        })(SenderPlatform = cast.SenderPlatform || (cast.SenderPlatform = {}));
        var SessionStatus;
        (function (SessionStatus) {
            SessionStatus["CONNECTED"] = "CONNECTED";
            SessionStatus["DISCONNECTED"] = "DISCONNECTED";
            SessionStatus["STOPPED"] = "STOPPED";
        })(SessionStatus = cast.SessionStatus || (cast.SessionStatus = {}));
        var media;
        (function (media_1) {
            var GenericMediaMetadata = /** @class */ (function () {
                function GenericMediaMetadata() {
                }
                ;
                return GenericMediaMetadata;
            }());
            media_1.GenericMediaMetadata = GenericMediaMetadata;
            var MetadataType;
            (function (MetadataType) {
                MetadataType["MOVIE"] = "MOVIE";
                MetadataType["MUSIC_TRACK"] = "MUSIC_TRACK";
                MetadataType["TV_SHOW"] = "TV_SHOW";
                MetadataType["GENERIC"] = "GENERIC";
            })(MetadataType = media_1.MetadataType || (media_1.MetadataType = {}));
            var EditTracksInfoRequest = /** @class */ (function () {
                function EditTracksInfoRequest(activeTrackIds) {
                    this.activeTrackIds = activeTrackIds;
                }
                return EditTracksInfoRequest;
            }());
            media_1.EditTracksInfoRequest = EditTracksInfoRequest;
            var GetStatusRequest = /** @class */ (function () {
                function GetStatusRequest() {
                }
                return GetStatusRequest;
            }());
            media_1.GetStatusRequest = GetStatusRequest;
            var LoadRequest = /** @class */ (function () {
                function LoadRequest(media) {
                    this.media = media;
                }
                ;
                return LoadRequest;
            }());
            media_1.LoadRequest = LoadRequest;
            var Media = /** @class */ (function () {
                function Media(contentId, contentType, customData, nativeMedia) {
                    var _this = this;
                    this._volume = new Volume();
                    this.checkIsAlive = function (alive) {
                        if (alive && !_this._alive) {
                            globalSession.callMediaListeners(_this);
                        }
                        _this._alive = alive;
                    };
                    this._alive = true;
                    this.nativeMedia = nativeMedia;
                    this._media = new MediaInfo(contentId, contentType, customData, this.nativeMedia);
                    this.nativeMedia.addUpdateListener(chromecastListenerCallbackHandler.register(this.checkIsAlive));
                }
                ;
                Object.defineProperty(Media.prototype, "supportedMediaCommands", {
                    get: function () {
                        return JSON.parse(this.nativeMedia.getSupportedMediaCommands());
                    },
                    enumerable: true,
                    configurable: true
                });
                Media.prototype.getStatus = function (getStatusRequest, successCallback, errorCallback) {
                    this.nativeMedia.getStatus(chromecastCallbackHandler.register(successCallback, errorCallback));
                };
                Object.defineProperty(Media.prototype, "playbackRate", {
                    get: function () {
                        return this.nativeMedia.getPlaybackRate();
                    },
                    enumerable: true,
                    configurable: true
                });
                Object.defineProperty(Media.prototype, "activeTrackIds", {
                    get: function () {
                        return JSON.parse(this.nativeMedia.getActiveTrackIds());
                    },
                    enumerable: true,
                    configurable: true
                });
                Object.defineProperty(Media.prototype, "customData", {
                    get: function () {
                        var nativeDescription = this.nativeMedia.getSourceDescription();
                        var source = nativeDescription ? JSON.parse(nativeDescription) : null;
                        var nativeBuffers = this.nativeMedia.getBuffers();
                        var buffers = nativeBuffers ? JSON.parse(nativeBuffers) : null;
                        return {
                            sourceDescription: source,
                            buffers: buffers
                        };
                    },
                    enumerable: true,
                    configurable: true
                });
                ;
                Object.defineProperty(Media.prototype, "idleReason", {
                    get: function () {
                        return this.nativeMedia.getIdleReason();
                    },
                    enumerable: true,
                    configurable: true
                });
                Object.defineProperty(Media.prototype, "media", {
                    get: function () {
                        return this._media;
                    },
                    enumerable: true,
                    configurable: true
                });
                ;
                Object.defineProperty(Media.prototype, "volume", {
                    get: function () {
                        return this._volume;
                    },
                    enumerable: true,
                    configurable: true
                });
                Object.defineProperty(Media.prototype, "playerState", {
                    get: function () {
                        return this.nativeMedia.getMediaPlayerState();
                    },
                    enumerable: true,
                    configurable: true
                });
                ;
                Media.prototype.addUpdateListener = function (listener) {
                    this.nativeMedia.addUpdateListener(chromecastListenerCallbackHandler.register(listener));
                };
                ;
                Media.prototype.editTracksInfo = function (editTracksInfoRequest, successCallback, errorCallback) {
                    this.nativeMedia.setActiveTrackIds(JSON.stringify(editTracksInfoRequest.activeTrackIds), chromecastCallbackHandler.register(successCallback, errorCallback)); //TODO implement in public static JAVA : string = 'JAVA';
                };
                ;
                Media.prototype.getEstimatedTime = function () {
                    return this.nativeMedia.getEstimatedTime();
                };
                ;
                Media.prototype.pause = function (pauseRequest, successCallback, errorCallback) {
                    this.nativeMedia.pause(chromecastCallbackHandler.register(successCallback, errorCallback));
                };
                ;
                Media.prototype.play = function (playRequest, successCallback, errorCallback) {
                    this.nativeMedia.play(chromecastCallbackHandler.register(successCallback, errorCallback));
                };
                ;
                Media.prototype.removeUpdateListener = function (listener) {
                    this.nativeMedia.removeUpdateListener(chromecastListenerCallbackHandler.lookup(listener));
                    chromecastListenerCallbackHandler.unRegister(listener);
                };
                ;
                Media.prototype.seek = function (seekRequest, successCallback, errorCallback) {
                    this.nativeMedia.seek(seekRequest.currentTime, seekRequest.resumeState, chromecastCallbackHandler.register(successCallback, errorCallback));
                };
                ;
                Media.prototype.stop = function (stopRequest, successCallback, errorCallback) {
                    this.nativeMedia.stop(chromecastCallbackHandler.register(successCallback, errorCallback));
                };
                ;
                return Media;
            }());
            media_1.Media = Media;
            var MediaInfo = /** @class */ (function () {
                // constructor(public contentId: string, public contentType: string) {
                function MediaInfo(contentId, contentType, customData, nativeMedia) {
                    this.contentId = contentId;
                    this.contentType = contentType;
                    this.customData = customData;
                    this.nativeMedia = nativeMedia;
                }
                ;
                Object.defineProperty(MediaInfo.prototype, "tracks", {
                    get: function () {
                        var _this = this;
                        var trackListMap = !!this.nativeMedia.getTracks() ? JSON.parse(this.nativeMedia.getTracks()) : undefined;
                        var mergedTracks = [];
                        if (!trackListMap) {
                            return mergedTracks;
                        }
                        trackListMap.audioTracks.map(function (track) { return mergedTracks.push(_this.createCustomTrack(track, TrackType.AUDIO)); });
                        trackListMap.videoTracks.map(function (track) { return mergedTracks.push(_this.createCustomTrack(track, TrackType.VIDEO)); });
                        trackListMap.textTracks.map(function (track) { return mergedTracks.push(_this.createCustomTrack(track, TrackType.TEXT)); });
                        return mergedTracks;
                    },
                    enumerable: true,
                    configurable: true
                });
                MediaInfo.prototype.createCustomTrack = function (track, type) {
                    if (!track.uid) {
                        return {
                            customData: track,
                            language: track.language,
                            name: track.language,
                            trackId: track.trackId,
                            type: type
                        };
                    }
                    else {
                        return {
                            type: type,
                            customData: track,
                            trackId: track.uid,
                            language: track.language,
                            name: track.label
                        };
                    }
                };
                Object.defineProperty(MediaInfo.prototype, "duration", {
                    get: function () {
                        return this.nativeMedia.getDuration();
                    },
                    enumerable: true,
                    configurable: true
                });
                Object.defineProperty(MediaInfo.prototype, "streamType", {
                    get: function () {
                        return this.duration ? StreamType.BUFFERED : StreamType.LIVE;
                    },
                    enumerable: true,
                    configurable: true
                });
                return MediaInfo;
            }());
            media_1.MediaInfo = MediaInfo;
            var PauseRequest = /** @class */ (function () {
                function PauseRequest() {
                }
                return PauseRequest;
            }());
            media_1.PauseRequest = PauseRequest;
            var PlayRequest = /** @class */ (function () {
                function PlayRequest() {
                }
                return PlayRequest;
            }());
            media_1.PlayRequest = PlayRequest;
            var SeekRequest = /** @class */ (function () {
                function SeekRequest() {
                }
                return SeekRequest;
            }());
            media_1.SeekRequest = SeekRequest;
            var StopRequest = /** @class */ (function () {
                function StopRequest() {
                }
                return StopRequest;
            }());
            media_1.StopRequest = StopRequest;
            var TextTrackStyle = /** @class */ (function () {
                function TextTrackStyle() {
                }
                return TextTrackStyle;
            }());
            media_1.TextTrackStyle = TextTrackStyle;
            var Track = /** @class */ (function () {
                function Track() {
                }
                return Track;
            }());
            media_1.Track = Track;
            var VolumeRequest = /** @class */ (function () {
                function VolumeRequest(volume) {
                    this.volume = volume;
                }
                ;
                return VolumeRequest;
            }());
            media_1.VolumeRequest = VolumeRequest;
            var IdleReason;
            (function (IdleReason) {
                IdleReason["CANCELLED"] = "CANCELLED";
                IdleReason["INTERRUPTED"] = "INTERRUPTED";
                IdleReason["FINISHED"] = "FINISHED";
                IdleReason["ERROR"] = "ERROR";
            })(IdleReason = media_1.IdleReason || (media_1.IdleReason = {}));
            var MediaCommand;
            (function (MediaCommand) {
                MediaCommand["PAUSE"] = "PAUSE";
                MediaCommand["SEEK"] = "SEEK";
                MediaCommand["STREAM_VOLUME"] = "STREAM_VOLUME";
                MediaCommand["STREAM_MUTE"] = "STREAM_MUTE";
            })(MediaCommand = media_1.MediaCommand || (media_1.MediaCommand = {}));
            var PlayerState;
            (function (PlayerState) {
                PlayerState["IDLE"] = "IDLE";
                PlayerState["PLAYING"] = "PLAYING";
                PlayerState["PAUSED"] = "PAUSED";
                PlayerState["BUFFERING"] = "BUFFERING";
            })(PlayerState = media_1.PlayerState || (media_1.PlayerState = {}));
            var RepeatMode;
            (function (RepeatMode) {
                RepeatMode["OFF"] = "OFF";
                RepeatMode["ALL"] = "ALL";
                RepeatMode["SINGLE"] = "SINGLE";
                RepeatMode["ALL_AND_SHUFFLE"] = "ALL_AND_SHUFFLE";
            })(RepeatMode = media_1.RepeatMode || (media_1.RepeatMode = {}));
            var ResumeState;
            (function (ResumeState) {
                ResumeState["PLAYBACK_START"] = "PLAYBACK_START";
                ResumeState["PLAYBACK_PAUSE"] = "PLAYBACK_PAUSE";
            })(ResumeState = media_1.ResumeState || (media_1.ResumeState = {}));
            var StreamType;
            (function (StreamType) {
                StreamType["BUFFERED"] = "BUFFERED";
                StreamType["LIVE"] = "LIVE";
                StreamType["NONE"] = "NONE";
            })(StreamType = media_1.StreamType || (media_1.StreamType = {}));
            var TrackType;
            (function (TrackType) {
                TrackType["TEXT"] = "TEXT";
                TrackType["AUDIO"] = "AUDIO";
                TrackType["VIDEO"] = "VIDEO";
            })(TrackType = media_1.TrackType || (media_1.TrackType = {}));
            var TextTrackType;
            (function (TextTrackType) {
                TextTrackType["SUBTITLES"] = "SUBTITLES";
                TextTrackType["CAPTIONS"] = "CAPTIONS";
                TextTrackType["DESCRIPTIONS"] = "DESCRIPTIONS";
                TextTrackType["CHAPTERS"] = "CHAPTERS";
                TextTrackType["METADATA"] = "METADATA";
            })(TextTrackType = media_1.TextTrackType || (media_1.TextTrackType = {}));
        })(media = cast.media || (cast.media = {}));
    })(cast = chrome.cast || (chrome.cast = {}));
})(chrome || (chrome = {}));
var chromecastCallbackHandler = new theoplayerCastUtils.ResultCallbackHandler();
var chromecastListenerCallbackHandler = new theoplayerCastUtils.ListenerCallbackHandler();
function chromecastNotifyApiAvailable() {
    if (!chrome.cast.isAvailable) {
        chrome.cast.isAvailable = true;
        if (typeof __onGCastApiAvailable === 'function') {
            __onGCastApiAvailable(true);
        }
    }
}
