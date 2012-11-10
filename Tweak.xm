#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

#import "UIImage+Editor.h"



#define FACEBOOK_APP_ID @"com.facebook.Facebook"


@interface SBIcon : NSObject
-(NSString *)applicationBundleID;
@end

@interface SBIconView : UIView
@property (readonly,retain) SBIcon *icon;
@end


UIKIT_EXTERN CGImageRef UIGetScreenImage();

static UIImageView *upper;
static UIImageView *lower;
static UIWindow *containerWindow;
static BOOL isAnimating = NO;
static UIWebView *webView;


%hook SBIconView

-(void)longPressTimerFired{
	if ([[[self icon] applicationBundleID] isEqualToString:FACEBOOK_APP_ID] && ! [[%c(SBIconController) sharedInstance] isEditing]){
        isAnimating = YES;
		[self openFacebookFolder];
        //[[[UIAlertView alloc] initWithTitle:@"Position" message:[NSString stringWithFormat:@"%i",[self frame].origin.y] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	}
    else {
        %orig;
    }
}


%new(@:@)

-(void)openFacebookFolder{
	CGImageRef screen = UIGetScreenImage();
    UIImage *img = [UIImage imageWithCGImage:screen];
    CGImageRelease(screen);
    
    upper = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 210)];
    lower = [[UIImageView alloc] initWithFrame:CGRectMake(0, 210, 320, 270)];

    upper.contentMode = UIViewContentModeScaleToFill;
    lower.contentMode = UIViewContentModeScaleToFill;

    UIImage *upperImage = [img croppedToRect:CGRectMake(0,0,640,420)];
    UIImage *lowerImage = [img croppedToRect:CGRectMake(0,420,640,540)];

    //[img release];

    upper.clipsToBounds = YES;
    lower.clipsToBounds = YES;

    upper.image = upperImage;
    lower.image = lowerImage;

    containerWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    containerWindow.windowLevel = [[UIApplication sharedApplication] keyWindow].windowLevel + 1;
    containerWindow.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    [containerWindow makeKeyAndVisible];
    
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,110,320,300)];
    [containerWindow addSubview:webView];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://facebook.com"]]];
    

    UITapGestureRecognizer *reco = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeFacebookFolder)];
    [containerWindow addGestureRecognizer:reco];
    [reco release];

    [containerWindow addSubview:upper];
    [containerWindow addSubview:lower];



    [UIView beginAnimations:@"Facebook folder opening animation" context:nil];
    [UIView setAnimationDuration:.6f];
    [UIView setAnimationDidStopSelector:nil];

    upper.frame = CGRectMake(0, -100, 320, 210);
    lower.frame = CGRectMake(0, 410, 320, 270);

    [UIView commitAnimations];

}

%new(@:@)
-(void)closeFacebookFolder{
   
    [UIView animateWithDuration:.6f animations:^{

        upper.frame = CGRectMake(0, 0, 320, 210);
        lower.frame = CGRectMake(0, 210, 320, 270);

        } completion:^(BOOL finished){

            containerWindow.hidden = YES;
            [containerWindow release];
            isAnimating = NO;

        }];
}

%end


%hook SBApplicationIcon

-(BOOL)launchEnabled{
    if (isAnimating){
        return NO;
    }
    else {
        return %orig;
    }
}
%end

/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.

%hook ClassName

// Hooking a class method
+ (id)sharedInstance {
	return %orig;
}

// Hooking an instance method with an argument.
- (void)messageName:(int)argument {
	%log; // Write a message about this call, including its class, name and arguments, to the system log.

	%orig; // Call through to the original function with its original arguments.
	%orig(nil); // Call through to the original function with a custom argument.

	// If you use %orig(), you MUST supply all arguments (except for self and _cmd, the automatically generated ones.)
}

// Hooking an instance method with no arguments.
- (id)noArguments {
	%log;
	id awesome = %orig;
	[awesome doSomethingElse];

	return awesome;
}

// Always make sure you clean up after yourself; Not doing so could have grave consequences!
%end
*/
