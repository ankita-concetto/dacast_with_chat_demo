#import "DecastPlayerPlugin.h"
#if __has_include(<decast_player_plugin/decast_player_plugin-Swift.h>)
#import <decast_player_plugin/decast_player_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "decast_player_plugin-Swift.h"
#endif

@implementation DecastPlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDecastPlayerPlugin registerWithRegistrar:registrar];
}
@end
