#import "OSWindow.h"
#import "OSViewController.h"
#import "missioncontrol/OSPaneThumbnail.h"
#import "missioncontrol/OSAppMirrorView.h"


@implementation OSWindow
@synthesize windowBar = _windowBar;
@synthesize delegate = _delegate;
@synthesize resizeAnchor = _resizeAnchor;
@synthesize grabPoint = _grabPoint;
@synthesize grabPointInSuperview = _grabPointInSuperview;
@synthesize expandButton = _expandButton;
@synthesize originBeforeGesture = _originBeforeGesture;
@synthesize originInDesktop = _originInDesktop;
@synthesize desktopPaneOffset = _desktopPaneOffset;
@synthesize maxScale = _maxScale;


- (id)initWithFrame:(CGRect)arg1 title:(NSString*)title{


	if(![super initWithFrame:arg1])
		return nil;

	self.layer.masksToBounds = false;
	self.layer.shadowOffset = CGSizeMake(0, 0);
	self.layer.shadowRadius = 10;
	self.layer.shadowOpacity = 0.5;
	self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;

	self.maxScale = 50;

	self.windowBar = [[UIToolbar alloc] init];
	self.windowBar.frame = CGRectMake(0, 0, self.frame.size.width, 40);
	self.windowBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;

	UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMCPanGesture:)];
	panGesture.maximumNumberOfTouches = 1;
	[self addGestureRecognizer:panGesture];
	[panGesture release];

	NSMutableArray *items = [[NSMutableArray alloc] init];

	self.closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopButtonPressed)];
	UIBarButtonItem *titleLabel = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:nil action:nil];
	self.expandButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/OS Experience/167-1.png"] style:UIBarButtonItemStylePlain target:self action:@selector(expandButtonPressed)];
	UIBarButtonItem *flexibleSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *flexibleSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

	[items addObject:self.closeButton];
	[items addObject:flexibleSpace1];
	[items addObject:titleLabel];
	[items addObject:flexibleSpace2];
	if([self showsExpandButton])
		[items addObject:self.expandButton];


	[self.windowBar setItems:items animated:false];
	[self addSubview:self.windowBar];


	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
	[titleLabel.view addGestureRecognizer:panRecognizer];

	UIView *gestureBackdrop = [[UIView alloc] initWithFrame:self.windowBar.frame];
	gestureBackdrop.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	gestureBackdrop.backgroundColor = [UIColor whiteColor];
	gestureBackdrop.alpha = 0.05;
	[self.windowBar addSubview:gestureBackdrop];
	[self.windowBar sendSubviewToBack:gestureBackdrop];
	[self.windowBar sendSubviewToBack:titleLabel.view];
	[self.windowBar sendSubviewToBack:self.windowBar._backgroundView];

	[gestureBackdrop addGestureRecognizer:panRecognizer];

	[panRecognizer release];

	UIPanGestureRecognizer *resizePanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleResizePanGesture:)];
	[self.expandButton.view addGestureRecognizer:resizePanRecognizer];
	[resizePanRecognizer release];

	self.title = title;

	[self.closeButton release];
	[flexibleSpace1 release];
	[flexibleSpace2 release];
	[items release];
	[gestureBackdrop release];
	[self.expandButton release];



	return self;
}

- (NSString*)description{
	return [NSString stringWithFormat:@"%@ title: %@", [super description], self.title];
}

- (void)handleMCPanGesture:(UIPanGestureRecognizer*)gesture{
	if(![[OSViewController sharedInstance] missionControlIsActive]){
		return;
	}

	if(gesture.state == UIGestureRecognizerStateBegan){

		self.grabPoint = [gesture locationInView:self];
		self.grabPointInSuperview = [gesture locationInView:[self superview]];
		self.originBeforeGesture = self.frame.origin;

	}else if(gesture.state == UIGestureRecognizerStateChanged){
		[self updateTransform:[gesture locationInView:[self superview]]];

		CGRect frame = self.frame;

		CGPoint difference = CGPointSub([gesture locationInView:[self superview]], [self convertPoint:self.grabPoint toView:[self superview]]);
		frame.origin = CGPointAdd(difference, self.frame.origin);

		[self setFrame:frame];

		[[OSThumbnailView sharedInstance] updatePressedThumbnails];

	}else if(gesture.state == UIGestureRecognizerStateEnded){

		if([self selectedThumbnailView] == nil){
			[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
				self.transform = CGAffineTransformScale(CGAffineTransformIdentity, self.maxScale * 0.01, self.maxScale * 0.01);
				CGRect frame = self.frame;
				frame.origin = self.originBeforeGesture;
				[self setFrame:frame];
			}completion:^(BOOL finished){

			}];

			[[OSThumbnailView sharedInstance] updatePressedThumbnails];
		}else{
			if([[[self selectedThumbnailView] pane] isKindOfClass:[OSDesktopPane class]]){//If hovering over an OSPaneThumbnail
				OSPaneThumbnail *selectedThumbnail = [self selectedThumbnailView];
				OSPaneThumbnail *fromThumbnail = [[OSThumbnailView sharedInstance] thumbnailForPane:[[OSPaneModel sharedInstance] desktopPaneContainingWindow:self]];

				OSDesktopPane *toPane = (OSDesktopPane*)[[self selectedThumbnailView] pane];

				OSDesktopPane *fromPane = nil;
				for(OSDesktopPane *pane in [[OSPaneModel sharedInstance] panes]){
					if(![pane isKindOfClass:[OSDesktopPane class]])
						continue;
					if([pane.windows containsObject:self])
						fromPane = pane;
				}

				if([self isKindOfClass:[OSAppWindow class]]){

					OSAppMirrorView *mirrorView = [[OSAppMirrorView alloc] initWithApplication:[(OSAppWindow*)self application]];

					[mirrorView addRemoteViews];

					CGRect frame = self.frame;
					frame.origin.y += self.windowBar.bounds.size.height * 0.15;
					frame.size.height -= self.windowBar.bounds.size.height * 0.15;
					mirrorView.frame = frame;

					[[self superview] addSubview:mirrorView];

					[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
						CGRect animationFrame = [selectedThumbnail convertRect:[selectedThumbnail previewRectForWindow:self] toView:[self superview]];
						mirrorView.frame = animationFrame;
					} completion:^(BOOL finished){
						CGRect animationFrame = [[mirrorView superview] convertRect:mirrorView.frame toView:selectedThumbnail.windowContainer];
						mirrorView.frame = animationFrame;
						[selectedThumbnail.windowContainer addSubview:mirrorView];
					}];

					[mirrorView release];
				}

				[UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
					[[selectedThumbnail shadowOverlayView] setAlpha:0.0];
				}completion:^(BOOL finished){
					[[self selectedThumbnailView] setPressed:false];
					[[selectedThumbnail shadowOverlayView] setAlpha:0.5];
					[[OSThumbnailView sharedInstance] updatePressedThumbnails];
				}];

				self.transform = CGAffineTransformScale(CGAffineTransformIdentity, self.maxScale * 0.01, self.maxScale * 0.01);
				CGRect frame = self.frame;
				frame.origin = [OSMCWindowLayoutManager convertPointFromSlider:self.originBeforeGesture toPane:fromPane];
				frame.origin = [OSMCWindowLayoutManager convertPointToSlider:frame.origin fromPane:toPane];
				[self setFrame:frame];

				[self switchToDesktopPane:toPane];

				[[OSSlider sharedInstance] bringSubviewToFront:self];


				[fromThumbnail updateWindowPreviews];

			}
		}

	}
}

- (void)switchToDesktopPane:(OSDesktopPane*)pane{


	for(OSDesktopPane *desktopPane in [[OSPaneModel sharedInstance] panes]){
		if(![desktopPane isKindOfClass:[OSDesktopPane class]])
			continue;
		if([desktopPane.windows containsObject:self])
			[desktopPane.windows removeObject:self];
	}
	[self setDelegate:pane];
	[pane.windows addObject:self];


}

- (OSPaneThumbnail*)selectedThumbnailView{
	CGPoint originInThumbnailWrapper = [[self superview] convertPoint:self.frame.origin toView:[[OSThumbnailView sharedInstance] wrapperView]];

	CGRect rectInWrapper = self.frame;
	rectInWrapper.origin = originInThumbnailWrapper;


	for(OSPaneThumbnail *thumbnail in [[[OSThumbnailView sharedInstance] wrapperView] subviews]){
		if(![thumbnail isKindOfClass:[OSPaneThumbnail class]] || ![[thumbnail pane] isKindOfClass:[OSDesktopPane class]])
			continue;
		if([[thumbnail pane] isKindOfClass:[OSDesktopPane class]])
			if([[(OSDesktopPane*)[thumbnail pane] windows] containsObject:self])
				continue;
		CGRect intersection = CGRectIntersection(thumbnail.frame, rectInWrapper);

		if(CGRectIsNull(intersection)){
			continue;
		}

		if(intersection.size.width > rectInWrapper.size.width / 2 && intersection.size.height > rectInWrapper.size.height / 2){
			return thumbnail;
		}
	}

	return nil;
}

- (void)updateTransform:(CGPoint)fingerPosition{
		const float max = self.grabPointInSuperview.y;
		const float percentage = fingerPosition.y / max;

		float transform = (((percentage * 100) * (self.maxScale - missionControlMinDragScale)) / 100) + missionControlMinDragScale;

		if(transform < missionControlMinDragScale){
			transform = missionControlMinDragScale;
		}else if(transform > self.maxScale){
			transform = self.maxScale;
		}

		transform = transform / 100;
		self.transform = CGAffineTransformScale(CGAffineTransformIdentity, transform, transform);
}

- (void)layoutSubviews{
	self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

- (void)handlePanGesture:(UIPanGestureRecognizer*)gesture{
	[self.delegate window:self didRecievePanGesture:gesture];
}

- (void)stopButtonPressed{

}

- (void)expandButtonPressed{

}

- (void)handleResizePanGesture:(UIPanGestureRecognizer*)gesture{
	[self.delegate window:self didRecieveResizePanGesture:gesture];
}

- (CGRect) CGRectFromCGPoints:(CGPoint)p1 p2:(CGPoint)p2{
	return CGRectMake(MIN(p1.x, p2.x), MIN(p1.y, p2.y), fabs(p1.x - p2.x), fabs(p1.y - p2.y));
}

- (BOOL)showsExpandButton{
	return true;
}

- (void)dealloc{
	[self.title release];
	[self.windowBar release];
	[self.expandButton release];
	[self.closeButton release];
	[super dealloc];
}

@end
