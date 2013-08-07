#import "OSViewController.h"




@implementation OSViewController
@synthesize slider = _slider;
@synthesize dock = _dock;
@synthesize iconContentView = _iconContentView;
@synthesize launchpadActive = _launchpadActive;
@synthesize launchpadAnimating = _launchpadAnimating;
@synthesize missionControlActive = _missionControlActive;
@synthesize missionControlAnimating = _missionControlAnimating;
@synthesize switcherBackgroundView = _switcherBackgroundView;
@synthesize pinchInGesture = _pinchInGesture;
@synthesize pinchOutGesture = _pinchOutGesture;


+ (id)sharedInstance{
    static OSViewController *_sharedController;

    if (_sharedController == nil)
    {
        _sharedController = [[self alloc] init];
    }

    return _sharedController;
}


- (id)init{
    if(![super init])
        return nil;

    self.pinchInGesture = [[OSPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    self.pinchInGesture.minimumNumberOfTouches = 5;
    self.pinchInGesture.type = OSPinchGestureRecognizerTypeInwards;


    self.pinchOutGesture = [[OSPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    self.pinchOutGesture.minimumNumberOfTouches = 5;
    self.pinchOutGesture.type = OSPinchGestureRecognizerTypeOutwards;


    return self;
}


- (void)setDockPercentage:(float)percentage{

    if((self.launchpadIsActive && !self.launchpadIsAnimating) || (self.missionControlIsActive && !self.missionControlIsAnimating))
        return;

    BOOL isPortrait = false;

    if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown){
        isPortrait = true;
    }


    CGRect dockFrame = self.dock.frame;

    float dockShownY = (isPortrait ? self.view.frame.size.height : self.view.frame.size.width) - dockFrame.size.height;

    dockFrame.origin.y = dockShownY + (percentage * dockFrame.size.height);

    [self.dock setFrame:dockFrame];
}


- (void)setMissionControlActive:(BOOL)active animated:(BOOL)animated{

    if(active){

        [[UIApplication sharedApplication] setStatusBarHidden:true animated:true];

        self.switcherBackgroundView.hidden = false;
        [[OSThumbnailView sharedInstance] setHidden:false];

        [[[OSSlider sharedInstance] panGestureRecognizer] setMinimumNumberOfTouches:1];

        if(animated){

            self.missionControlAnimating = true;
            self.missionControlActive = true;

            [UIView animateWithDuration:0.25 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                [self setDockPercentage:0.0];
                for(OSPane *pane in [[OSPaneModel sharedInstance] panes]){
                    pane.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
                    pane.userInteractionEnabled = false;
                }

            } completion:^(BOOL finished){
                self.missionControlAnimating = false;
                [self.view insertSubview:[OSThumbnailView sharedInstance] aboveSubview:self.slider];
            }];


        }else{
            [self setDockPercentage:0.0];
            self.missionControlActive = true;
        
            for(OSPane *pane in [[OSPaneModel sharedInstance] panes]){
                pane.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
                pane.userInteractionEnabled = false;
            }
            [self.view insertSubview:[OSThumbnailView sharedInstance] aboveSubview:self.slider];

        }


    }else{
        [self.view insertSubview:[OSThumbnailView sharedInstance] belowSubview:self.slider];
        [[[OSSlider sharedInstance] panGestureRecognizer] setMinimumNumberOfTouches:4];

        if(animated){

            self.missionControlAnimating = true;
            self.missionControlActive = false;

            [UIView animateWithDuration:0.25 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                for(OSPane *pane in [[OSPaneModel sharedInstance] panes]){
                    pane.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                    pane.userInteractionEnabled = true;
                }
                [[OSSlider sharedInstance] updateDockPosition];

            } completion:^(BOOL finished){
                self.switcherBackgroundView.hidden = true;
                [[OSThumbnailView sharedInstance] setHidden:true];
                self.missionControlAnimating = false;
            }];


        }else{
            self.missionControlActive = false;
            for(OSPane *pane in [[OSPaneModel sharedInstance] panes]){
                pane.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                pane.userInteractionEnabled = true;
            }
            [[OSSlider sharedInstance] updateDockPosition];
            self.switcherBackgroundView.hidden = true;
            [[OSThumbnailView sharedInstance] setHidden:true];
        }


    }



}




-(void)loadView{
	self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.switcherBackgroundView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.switcherBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.switcherBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/OS Experience/SwitcherBackgroundImage.png"]];
    self.switcherBackgroundView.hidden = true;
    [self.view addSubview:self.switcherBackgroundView];


    [self.view addSubview:[OSThumbnailView sharedInstance]];


	self.slider = [OSSlider sharedInstance];
	[self.view addSubview:self.slider];

	OSDesktopPane *desktopPane = [[OSDesktopPane alloc] init];
    [[OSPaneModel sharedInstance] addPaneToBack:desktopPane];
    [desktopPane release];



    [self.view addGestureRecognizer:self.pinchInGesture];
    [self.view addGestureRecognizer:self.pinchOutGesture];


	self.iconContentView = [[OSIconContentView alloc] init];
	self.iconContentView.alpha = 0.0f;


    UIView *stockWallpaperView = [[[objc_getClass("SBUIController") sharedInstance] wallpaperView] superview];
    stockWallpaperView.hidden = true;
    stockWallpaperView.alpha = 0.0f;
    [self.iconContentView addSubview:stockWallpaperView];


	[self.view addSubview:self.iconContentView];
	self.launchpadActive = false;


	self.dock = [[objc_getClass("SBIconController") sharedInstance] dock];
	CGRect dockFrame = self.dock.frame;
	dockFrame.origin.y = [[UIScreen mainScreen] bounds].size.height - dockFrame.size.height;
	[self.dock setFrame:dockFrame];
	[self.view addSubview:self.dock];



    self.missionControlAnimating = false;
    self.missionControlActive = false;

}

-(void)handlePinchGesture:(OSPinchGestureRecognizer*)gesture{

    if(gesture.state == UIGestureRecognizerStateRecognized){
        if(gesture.type == OSPinchGestureRecognizerTypeInwards){
            if(!self.launchpadIsActive)
                [self setLaunchpadActive:true animated:true];
        }else if(gesture.type == OSPinchGestureRecognizerTypeOutwards){
            if(self.launchpadIsActive)
                [self setLaunchpadActive:false animated:true];
        }
    }

}


- (void)menuButtonPressed{

	if(self.launchpadIsActive){
		[self setLaunchpadActive:false animated:true];
	}else{
		[self setLaunchpadActive:true animated:true];
	}

}


-(void)animateIconLaunch:(SBIconView*)iconView{

	UIImageView *launchZoomView = [[UIImageView alloc] init];
	launchZoomView.image = [[iconView iconImageView] image];

	CGRect zoomViewFrame;
	zoomViewFrame.origin = [iconView convertPoint:iconView.bounds.origin toView:self.view];
	zoomViewFrame.size = launchZoomView.image.size;

	[launchZoomView setFrame:zoomViewFrame];


	[self.view addSubview:launchZoomView];


	[UIView animateWithDuration:0.25 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        launchZoomView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2.0f, 2.0f);
        launchZoomView.alpha = 0.0f;
    }completion:^(BOOL finished){
    	[launchZoomView removeFromSuperview];
    	[launchZoomView release];
    }];

}



- (void)deactivateLaunchpadWithIconView:(SBIconView*)iconView{
    if(![iconView isInDock])
	   [self animateIconLaunch:iconView];

	[self setLaunchpadActive:false animated:true];
}


-(void)setLaunchpadActive:(BOOL)activated animated:(BOOL)animated{



	if(activated){
		[self.iconContentView prepareForDisplay];

        if([[objc_getClass("SBIconController") sharedInstance] isShowingSearch])
            [[objc_getClass("SBIconController") sharedInstance] _showSearchKeyboardIfNecessary:true];

		if(animated){

			if(self.launchpadIsAnimating)
				return;

			self.iconContentView.alpha = 0.0f;
        	self.iconContentView.contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.90f, 0.90f);

            self.launchpadAnimating = true;
            self.launchpadActive = true;

        	[UIView animateWithDuration:0.25 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{

                [self setDockPercentage:0.0];
                self.iconContentView.contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                self.iconContentView.alpha = 1.0f;

            } completion:^(BOOL finished){
                self.launchpadAnimating = false;
                [[[objc_getClass("SBIconController") sharedInstance] contentView] addSubview:[[OSViewController sharedInstance] dock]];
            }];


    	}else{
            [self setDockPercentage:0.0];
    		self.iconContentView.alpha = 1.0f;
    		self.launchpadActive = true;
            [[[objc_getClass("SBIconController") sharedInstance] contentView] addSubview:[[OSViewController sharedInstance] dock]];

   
    	}

	}else{
        [[objc_getClass("SBIconController") sharedInstance] _showSearchKeyboardIfNecessary:false];


		if(animated){

			if(self.launchpadIsAnimating)
				return;
            self.launchpadAnimating = true;
            self.launchpadActive = false;

            [[[OSViewController sharedInstance] view] addSubview:[[OSViewController sharedInstance] dock]];

			self.iconContentView.alpha = 1.0f;
        	self.iconContentView.contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);

        	[UIView animateWithDuration:0.25 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                [[OSSlider sharedInstance] updateDockPosition];
                self.iconContentView.contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.90f, 0.90f);
                self.iconContentView.alpha = 0.0f;
            } completion:^(BOOL finished){
                self.iconContentView.contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
                self.launchpadAnimating = false;
            }];


    	}else{
    		self.iconContentView.alpha = 0.0f;
    		self.launchpadActive = false;
            [[OSSlider sharedInstance] updateDockPosition];
            [[[OSViewController sharedInstance] view] addSubview:[[OSViewController sharedInstance] dock]];
    	}

	}
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	return true;
}





-(void)dealloc{
    [self.view release];
    [self.iconContentView release];
    [self.switcherBackgroundView release];
    [self.pinchInGesture release];
    [self.pinchOutGesture release];
    [super dealloc];
}


@end