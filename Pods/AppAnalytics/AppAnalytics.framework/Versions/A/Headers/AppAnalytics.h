#import <Foundation/Foundation.h>

/*! Generate debug logs to console */
extern NSString* const DebugLog;

/*! Touches Heat Map */
extern NSString* const HeatMapAnalytics;

/*! Auto tracking exceptions */
extern NSString* const ExceptionAnalytics;

/*! Auto tracking transactions */
extern NSString* const TransactionAnalytics;

/*! Auto tracking navigation */
extern NSString* const NavigationAnalytics;

/*! Auto tracking pop ups */
extern NSString* const PopUpAnalytics;

/*! Auto tracking location services state */
extern NSString* const LocationServicesAnalytics;

/*! Auto tracking Internet connection status (WiFi, cellular, turned off) */
extern NSString* const ConnectionAnalytics;

/*! Auto tracking application state changes (entering background, foreground) */
extern NSString* const ApplicationStateAnalytics;

/*! Auto tracking device orientation changes */
extern NSString* const DeviceOrientationAnalytics;

/*! Auto tracking battery status changes */
extern NSString* const BatteryAnalytics;

/*! Auto tracking keyboard state changes */
extern NSString* const KeyboardAnalytics;

/*!
 @class AppAnalytics
 
 @abstract
 Provide methods to control App Analytics functionality.
 
 @discussion For more information on integrating and using the App Analytics SDK
 please visit our help site documentation at http://www.appanalytics.io/Support
 */

@interface AppAnalytics : NSObject

/*!
 @abstract
 Start App Analytics with API key.
 
 @code
 - (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 {
 // App Analytics startup method
 [AppAnalytics initWithAppKey:@"YOUR_API_KEY"];
 // ....
 }
 @endcode
 
 @param appKey The App Analytics API key for this application.
 
 @discussion This method must be executed before any other App Analytics SDK methods can be used.
 All of the options are set to YES by default.
 */

+ (void)initWithAppKey:(NSString*)appKey;

/*!
 @abstract
 Start App Analytics with API key and options.
 
 @code
 - (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 {
 // App Analytics startup method
 [AppAnalytics initWithAppKey:@"YOUR_API_KEY"
                      options:@{DebugLog : @(NO)}]
 // ....
 }
 @endcode
 
 @param appKey The App Analytics API key for this application.
 
 @param options Options which control default behaviour of the App Analytics SDK.
 
 @discussion This method must be executed before any other App Analytics SDK methods can be used.
 Allows to set custom values for the auto tracking options.
 */

+ (void)initWithAppKey:(NSString *)appKey options:(NSDictionary*)options;

/*!
 @abstract
 Creates App Analytics event and associates it with eventName.
 
 @code
 [AppAnalytics logEvent:@"Cool Event"];
 @endcode
 
 @param eventName Name of the event.
 */

+ (void)logEvent:(NSString*)eventName;

/*!
 @abstract
 Creates App Analytics event and associates it with eventName and parameters.
 
 @code
 [AppAnalytics logEvent:@"Item Purchased" parameters:@{@"Type" : @"Pack of coins"}];
 @endcode
 
 @param eventName Name of the event.
 
 @param parameters Parameters of the event.
 */

+ (void)logEvent:(NSString*)eventName parameters:(NSDictionary*)parameters;

/*! Sets frequence of updates. Lower values produce higher network usage. */
+ (void)setDispatchInverval:(NSTimeInterval)dispatchInterval;

/*! Enable or disable generating debug output */
+ (void)setDebugLogEnabled:(BOOL)enabled;

/*! Enable or disable automatic exception analytics */
+ (void)setExceptionAnalyticsEnabled:(BOOL)enabled;

/*! Enable or disable automatic transactions analytics */
+ (void)setTransactionAnalyticsEnabled:(BOOL)enabled;

/*! Enable or disable automatic navigation analytics */
+ (void)setNavigationAnalyticsEnabled:(BOOL)enabled;

/*! Enable or disable automatic pop ups analytics */
+ (void)setPopUpsAnalyticsEnabled:(BOOL)enabled;

/*! Enable or disable automatic location services analytics */
+ (void)setLocationServicesAnalyticsEnabled:(BOOL)enabled;

/*! Enable or disable automatic connection analytics */
+ (void)setConnectionAnalyticsEnabled:(BOOL)enabled;

/*! Enable or disable automatic application state analytics */
+ (void)setApplicationStateAnalyticsEnabled:(BOOL)enabled;

/*! Enable or disable automatic device orientation analytics */
+ (void)setDeviceOrientationAnalyticsEnabled:(BOOL)enabled;

/*! Enable or disable automatic battery state analytics */
+ (void)setBatteryAnalyticsEnabled:(BOOL)enabled;

/*! Enable or disable automatic heat map analytics */
+ (void)setHeatMapAnalyticsEnabled:(BOOL)enabled;

/*! Enable or disable automatic keyboard state analytics */
+ (void)setKeyboardAnalyticsEnabled:(BOOL)enabled;

@end