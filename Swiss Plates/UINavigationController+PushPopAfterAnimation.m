//
//  UINavigationController+PushPopAfterAnimation.m
//  Swiss Plates
//
//  Created by Alain Furter on 06.06.12.
//  Copyright (c) 2012 Corporate Finance Manager. All rights reserved.
//

#import "UINavigationController+PushPopAfterAnimation.h"
#import "NSObject+BlockAdditions.h"

//typedef void (^BasicBlock)(void);

@implementation UINavigationController (PushPopAfterAnimation)

/*
void RunAfterDelay(NSTimeInterval delay, BasicBlock block)
{
    [[[block copy] autorelease] performSelector: @selector(my_callBlock) withObject: nil afterDelay: delay];
}
*/
- (void)pushViewControllerAfterAnimation:(UIViewController *)viewController animated:(BOOL)animated animationBlock:(void(^)())animationBlock {

    //[self presentModalViewController:viewController animated:YES];
    
#ifdef tUseCustomPushPop
    
     [UIView animateWithDuration:0.3 animations:^{ 
         
         #ifdef kLoggingIsOn
            NSLog(@"Push run animation");
         #endif
         
         [self pushViewController: viewController animated: YES];
         
     }
     completion:^(BOOL finished){
         animationBlock();
         
         #ifdef kLoggingIsOn
            NSLog(@"Push animation finished");
         #endif
     }];
    
    [UIView commitAnimations];
    
#else
    
    [self pushViewController: viewController animated: YES];
    
#endif 
    
    /*
    RunAfterDelay(2, ^{
        NSLog(@"Run animation block with blocks");
        [UIView animateWithDuration:0.3
                         animations:^{ 
                             NSLog(@"Push run animation");
                             animationBlock();
                             
                         }
                         completion:^(BOOL finished){
                             NSLog(@"Push animation finished");
                             
                         }]; 
        [UIView commitAnimations];

    });
     */
    
    /*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        // heavy code
        [self pushViewController: viewController animated: YES];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            animationBlock();
        });
    });
    */
    
    /*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        sleep(2);
        animationBlock();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissModalViewControllerAnimated:NO];
            //[self.navigationController pushViewController:viewController animated:NO];
        });
    }); */
    /*
    
    dispatch_queue_t queue;
    queue = dispatch_queue_create("ch.fasoft.swissplatesfree.pushuinavi.queue",nil);
    
    // Do the work on the default concurrent queue and then
    // call the user-provided block with the results.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self pushViewController: viewController animated: YES];
        NSLog(@"Push finished 1");
        
        dispatch_async(dispatch_get_main_queue(), animationBlock);
        
         NSLog(@"Push finished 2");
        
        // Release the user-provided queue when done
        //dispatch_release(queue);
    });*/
    /*
    dispatch_sync(dispatch_get_main_queue(), ^{
		[self pushViewController: viewController animated: YES];
        
        NSLog(@"Push finished 1");
	});
    
    dispatch_async(dispatch_get_main_queue(), ^{            
        animationBlock();
        NSLog(@"Push finished 2");
    });
    */
    
    /*
    [UIView animateWithDuration:0.3
                     animations:^{ 
                         NSLog(@"Push run animation");
                         animationBlock();
                         //[UIView commitAnimations];
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Push animation finished");
                         
                     }]; */
    //[UIView commitAnimations];
    
    //animationBlock();
    
    //dispatch_release(queue);
}

- (void)popViewControllerAfterAnimationAnimated:(UIViewController *)viewController animated:(BOOL)animated animationBlock:(void(^)())animationBlock {
    [UIView animateWithDuration:0.3
                     animations:^{ 
                         #ifdef kLoggingIsOn
                            NSLog(@"Pop run animation");
                         #endif
                         
                         animationBlock();
                         //[UIView commitAnimations];
                     }
                     completion:^(BOOL finished){
                         [self popViewControllerAnimated:animated];
                         
                         #ifdef kLoggingIsOn
                            NSLog(@"Pop animation finished");
                         #endif
                     }];
    [UIView commitAnimations];
}

@end
