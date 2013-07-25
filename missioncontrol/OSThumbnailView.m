#import "OSThumbnailView.h"
#import "OSThumbnailPlaceholder.h"




@implementation OSThumbnailView
@synthesize wrapperView = _wrapperView;


+ (id)sharedInstance{
    static OSThumbnailView *_view;

    if (_view == nil)
    {
        _view = [[self alloc] init];
    }

    return _view;
}



- (id)init{

	CGRect frame = [[UIScreen mainScreen] bounds];

	if(![self isPortrait]){
		float width = frame.size.width;
		frame.size.width = frame.size.height;
		frame.size.height = width;
	}

	frame.size.height = frame.size.height / 4;

	if(![super initWithFrame:frame])
		return nil;

	self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.hidden = true;


	self.wrapperView = [[OSThumbnailWrapper alloc] init];
	//self.wrapperView.backgroundColor = [UIColor greenColor];
	[self addSubview:self.wrapperView];


	return self;
}


-(void)willRotateToInterfaceOrientation: (UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration{
	CGRect frame = [[UIScreen mainScreen] bounds];

	if(![self isPortrait]){
		float width = frame.size.width;
		frame.size.width = frame.size.height;
		frame.size.height = width;
	}

	frame.size.height = frame.size.height / 4;

	[self setFrame:frame];

	[self alignSubviews];

}


- (void)alignSubviews{
	for(OSPaneThumbnail *thumbnail in self.wrapperView.subviews){
		[thumbnail updateSize];
		thumbnail.layer.shadowPath = [UIBezierPath bezierPathWithRect:thumbnail.bounds].CGPath;
		thumbnail.frame = CGRectMake((thumbnail.frame.size.width + thumbnailMarginSize) * [[OSPaneModel sharedInstance] indexOfPane:thumbnail.pane], 0, thumbnail.frame.size.width, thumbnail.frame.size.height);
	}

	CGPoint center = self.center;
	center.y -= wrapperCenter;
	self.wrapperView.center = center;

}



- (void)addPane:(OSPane*)pane{
	OSPaneThumbnail *thumbnail = [[OSPaneThumbnail alloc] initWithPane:pane];

	UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleThumbnailPanGesture:)];
  panGesture.maximumNumberOfTouches = 1;
  [thumbnail addGestureRecognizer:panGesture];
  [panGesture release];

	[self.wrapperView addSubview:thumbnail];
	[thumbnail release];
	[self alignSubviews];
}



-(void)handleThumbnailPanGesture:(UIPanGestureRecognizer *)gesture{

    if([gesture state] == UIGestureRecognizerStateChanged){

    	CGRect frame = [[gesture view] frame];
    	CGPoint result = CGPointSub([gesture locationInView:self], [(OSPaneThumbnail*)[gesture view] grabPoint]);//
       	frame.origin.x = result.x;
       	frame.origin.y = self.wrapperView.frame.origin.y;
       	[[gesture view] setFrame:frame];
       	CGPoint pointInWrapper = [self convertPoint:gesture.view.frame.origin toView:self.wrapperView];

       	for(OSPaneThumbnail *thumbnail in self.wrapperView.subviews){
       		if([[OSPaneModel sharedInstance] indexOfPane:thumbnail.pane] > [[OSPaneModel sharedInstance] indexOfPane:[(OSPaneThumbnail*)[gesture view] pane]] && pointInWrapper.x > thumbnail.frame.origin.x){
       			OSPane *selectedPane = [[OSSlider sharedInstance] currentPane];
       			[[OSPaneModel sharedInstance] insertPane:[(OSPaneThumbnail*)[gesture view] pane] atIndex:[[OSPaneModel sharedInstance] indexOfPane:thumbnail.pane]];
       			[[OSSlider sharedInstance] scrollToPane:selectedPane animated:false];

       			[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveLinear animations:^{
              [self alignSubviews];
            }completion:^(BOOL finished){
            
            }];
       			
       		}else if([[OSPaneModel sharedInstance] indexOfPane:thumbnail.pane] < [[OSPaneModel sharedInstance] indexOfPane:[(OSPaneThumbnail*)[gesture view] pane]] && pointInWrapper.x < thumbnail.frame.origin.x){
       			
       			OSPane *selectedPane = [[OSSlider sharedInstance] currentPane];
       			[[OSPaneModel sharedInstance] insertPane:[(OSPaneThumbnail*)[gesture view] pane] atIndex:[[OSPaneModel sharedInstance] indexOfPane:thumbnail.pane]];
       			[[OSSlider sharedInstance] scrollToPane:selectedPane animated:false];
            
            [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveLinear animations:^{
              [self alignSubviews];
            }completion:^(BOOL finished){
            
            }];
       		}
       	}


    }else if([gesture state] == UIGestureRecognizerStateBegan){

    	gesture.view.alpha = 0.5;

    	CGPoint grabPoint = [gesture locationInView:[gesture view]];
    	[(OSPaneThumbnail*)[gesture view] setGrabPoint:grabPoint];




    	OSThumbnailPlaceholder *placeholder = [(OSPaneThumbnail*)[gesture view] placeholder];

    	if(!placeholder){
    		placeholder = [[OSThumbnailPlaceholder alloc] initWithPane:[(OSPaneThumbnail*)[gesture view] pane]];
    		[(OSPaneThumbnail*)[gesture view] setPlaceholder:placeholder];
    		[placeholder release];
    	}

    	[self.wrapperView addSubview:placeholder];
    	
    	[self addSubview:[gesture view]];
    	[self alignSubviews];


    	CGRect frame = [[gesture view] frame];
    	CGPoint result = CGPointSub([gesture locationInView:self], [(OSPaneThumbnail*)[gesture view] grabPoint]);
      frame.origin.x = result.x;
      frame.origin.y = self.wrapperView.frame.origin.y;
      [[gesture view] setFrame:frame];

    }else if([gesture state] == UIGestureRecognizerStateEnded || [gesture state] == UIGestureRecognizerStateCancelled){


      CGRect frame = gesture.view.frame;
      frame.origin = [self convertPoint:frame.origin toView:self.wrapperView];
      [gesture.view setFrame:frame];

      [self.wrapperView addSubview:gesture.view];
      [[(OSPaneThumbnail*)[gesture view] placeholder] removeFromSuperview];

      [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveLinear animations:^{
        gesture.view.alpha = 1.0;
        [self alignSubviews];
      }completion:^(BOOL finished){
        
      }];



    }


}







- (BOOL)isPortrait:(UIInterfaceOrientation)orientation{
	if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown){
        return true;
    }
    return false;
}

- (BOOL)isPortrait{
	if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown){
        return true;
    }
    return false;
}


- (void)dealloc{
	[self.wrapperView release];
	[super dealloc];
}


@end