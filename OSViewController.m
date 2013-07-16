#import "OSViewController.h"




@implementation OSViewController
@synthesize slider = _slider;
@synthesize dock = _dock;
@synthesize iconContentView = _iconContentView;
@synthesize launchpadActive = _launchpadActive;
@synthesize launchpadIsAnimating = _launchpadIsAnimating;


+ (id)sharedInstance
{
    static OSViewController *_sharedController;

    if (_sharedController == nil)
    {
        _sharedController = [[self alloc] init];
    }

    return _sharedController;
}




-(void)loadView{
	self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	//self.view.autoresizesSubviews = true;
	
	self.slider = [OSSlider sharedInstance];
	[self.view addSubview:self.slider];

	OSDesktopPane *desktopPane = [[OSDesktopPane alloc] init];
	[self.slider addPane:desktopPane];
	[self.slider addPane:[[OSDesktopPane alloc] init]];




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


	
	
}

- (void)menuButtonPressed{

	if(self.launchpadActive){
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


	[UIView animateWithDuration:0.25
                              delay:0.0
                            options: UIViewAnimationCurveLinear
                         animations:^{
                             launchZoomView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2.0f, 2.0f);
                             launchZoomView.alpha = 0.0f;
                         }
        completion:^(BOOL finished){
    		[launchZoomView removeFromSuperview];
    		[launchZoomView release];
    }];




}

- (void)deactivateWithIconView:(SBIconView*)iconView{
	[self animateIconLaunch:iconView];
	[self setLaunchpadActive:false animated:true];
}


-(void)setLaunchpadActive:(BOOL)activated animated:(BOOL)animated{



	if(activated){
		[self.iconContentView prepareForDisplay];

		if(animated){

			if(self.launchpadIsAnimating)
				return;

			self.iconContentView.alpha = 0.0f;
        	self.iconContentView.contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.90f, 0.90f);

        	[UIView animateWithDuration:0.25
                              delay:0.0
                            options: UIViewAnimationCurveLinear
                         animations:^{
                             self.iconContentView.contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                             self.iconContentView.alpha = 1.0f;
                         }
                         completion:^(BOOL finished){
                         self.launchpadIsAnimating = false;
                         self.launchpadActive = true;
                         [[[objc_getClass("SBIconController") sharedInstance] contentView] addSubview:[[OSViewController sharedInstance] dock]];
            }];


    	}else{
    		self.iconContentView.alpha = 1.0f;
    		self.launchpadActive = true;
            [[[objc_getClass("SBIconController") sharedInstance] contentView] addSubview:[[OSViewController sharedInstance] dock]];
    	}

	}else{


		if(animated){

			if(self.launchpadIsAnimating)
				return;

            [[[OSViewController sharedInstance] view] addSubview:[[OSViewController sharedInstance] dock]];

			self.iconContentView.alpha = 1.0f;
        	self.iconContentView.contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);

        	[UIView animateWithDuration:0.25
                              delay:0.0
                            options: UIViewAnimationCurveLinear
                         animations:^{
                             self.iconContentView.contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.90f, 0.90f);
                             self.iconContentView.alpha = 0.0f;
                         }
                         completion:^(BOOL finished){
                         self.launchpadIsAnimating = false;
                         self.launchpadActive = false;
            }];


    	}else{
    		self.iconContentView.alpha = 0.0f;
    		self.launchpadActive = false;
            [[[OSViewController sharedInstance] view] addSubview:[[OSViewController sharedInstance] dock]];
    	}

	}

}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	return true;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
  
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
  
}



@end