#define UIApp [UIApplication sharedApplication]
#define DegreesToRadians(x) ((x) * M_PI / 180.0)



@interface BKProcess{

}

-(void)killWithSignal:(int)arg1;


@end



@interface BKApplication : NSObject{

}

-(int)suspendType;
-(void)setSuspendType:(int)arg1;
//- (id)initWithBundleIdentifier:(id)arg1 queue:(dispatch_queue_s*)arg2;

@end

@interface SBFakeStatusBarView : UIView



@end


@interface UIEvent(OSAdditions)

-(struct __GSEvent*)_gsEvent;

@end


@interface UITouchesEvent : NSObject


- (id)allTouches;
- (struct __GSEvent*)_gsEvent;


@end


@interface UIStatusBar : UIView

+ (int)defaultStatusBarStyleWithTint:(BOOL)arg1;
+ (CGRect)frameForStyle:(int)arg1 orientation:(int)arg2;

@end



@interface SBApplication : NSObject {

}

- (id)displayIdentifier;
- (id)displayValue:(int)arg1;
- (int)contextID;
- (void)setContextID:(int)arg1;
- (id)displayName;
- (id)contextHostViewForRequester:(id)arg1 enableAndOrderFront:(BOOL)arg2;
- (id)bundleIdentifier;
- (void)activate; //New
- (BOOL)activationFlag:(unsigned int)arg1;
- (void)addToSlider; //New
- (unsigned int)eventPort;


@end




@interface SBWorkspace : NSObject

-(void)setCurrentTransaction:(id)arg1;

@end


@interface UITouch(FixAdditions)


- (void)_loadStateFromTouch:(id)arg1;

@end

@interface UITouchesEvent(FixAdditions)


-(void)_addTouch:(id)touch forDelayedDelivery:(BOOL)delayedDelivery;
-(void)_removeTouch:(id)touch;

@end



@interface CPDistributedMessagingCenter : NSObject
{

}

+ (id)centerNamed:(id)arg1;

- (void)registerForMessageName:(id)arg1 target:(id)arg2 selector:(SEL)arg3;
- (void)stopServer;
- (void)runServerOnCurrentThread;
- (id)sendMessageAndReceiveReplyName:(id)arg1 userInfo:(id)arg2 error:(id *)arg3;
- (id)sendMessageAndReceiveReplyName:(id)arg1 userInfo:(id)arg2;
- (BOOL)sendMessageName:(id)arg1 userInfo:(id)arg2;

@end


@interface SBIconController

+ (id)sharedInstance;
- (void)prepareToRotateFolderAndSlidingViewsToOrientation:(int)arg1;
- (id)dock;
- (id)contentView;
- (BOOL)hasOpenFolder;

@end


@interface SBDockIconListView : UIView


@end

@interface SBUIAnimationZoomUpApp

- (void)_noteAnimationDidFinish:(BOOL)arg1;

@end 

@interface SBApplicationIcon


-(void)launch;
-(void)launchFromViewSwitcher;
-(SBApplication*)application;

@end

@interface SBAppToAppTransitionController


-(SBApplication*)activatingApp;
- (void)_cleanupAnimation;
- (void)_cancelAnimation;
- (void)appTransitionViewAnimationDidStop:(id)arg1;

@end



@interface SBIcon : NSObject


- (BOOL)isFolderIcon;
- (BOOL)isNewsstandIcon;
- (void)launch;
- (id)generateIconImage:(int)arg1;
- (id)getIconImage:(int)arg1;


@end


@interface SBIconView : UIImageView

-(SBIcon*)icon;
-(id)iconImageView;
-(BOOL)isGrabbed;


@end






@interface SBHostWrapperView : UIView



@end

@interface BKWorkspaceServerManager

-(id)applicationForBundleIdentifier:(NSString*)bundleIdentifier;
-(id)workspaceForApplication:(id)application;
-(id)currentWorkspace;

@end


@interface BKWorkspaceServer

-(void)activate:(id)arg1 withActivation:(id)arg2 withDeactivation:(id)arg3 token:(id)arg4;
- (BOOL)_activate:(id)arg1 activationSettings:(id)arg2 deactivationSettings:(id)arg3 token:(id)arg4;

@end

@interface BKSWorkspaceActivationToken

+(id)token;

@end


@interface SBApplicationController{

}

+(id)sharedInstance;

-(id)applicationWithDisplayIdentifier:(NSString*)arg1;

@end

@interface BKSApplicationProcessInfo

-(BOOL)suspended;
-(id)bundleIdentifier;

@end

@interface UIApplication(OSAdditions)
-(id)displayIdentifier;


@end



@interface UIWindow(OSAdditions)

-(unsigned int)_contextId;

@end



@interface SBUIController : UIView{

}

+(id)sharedInstance;


-(id)wallpaperView;
-(id)rootView;
- (void)activateApplicationAnimated:(id)arg1;

@end


@interface SBFluidSlideGestureRecognizer : NSObject

-(float)cumulativePercentage;
-(CGPoint)centroidPoint;


@end
