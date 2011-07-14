//
//  SPY.h
//  Inspector
//
//  Created by Xiaochen Du on 11/20/10.
//

#import <Foundation/Foundation.h>

@interface SPY : NSObject {
}

/**
 * Return the root window
 */
+ (UIWindow*) rootWindow;
/**
 * Return the definition of the class
 */
+ (NSString*) defn : (Class) cls;

/** 
 * Print the help. 
 */ 
+ (NSString*) help; 

@end
