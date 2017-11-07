#ifndef gameviewcontroller_h
#define gameviewcontroller_h

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>



@interface GameViewController : GLKViewController
- (void)tearDownGL; // called from AppDelegate.m
@end



#endif
