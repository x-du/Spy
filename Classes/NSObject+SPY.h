//
//  NSObject+SPY.h
//  Inspector
//
//  Created by Xiaochen Du on 10/29/10.
//

#import <Foundation/Foundation.h>


@interface NSObject (SPY) 


/**
 * Return the root window
 */
+ (UIWindow*) rootWindow;

/** 
 * Print the help. 
 */ 
- (NSString*) help; 
+ (NSString*) help;
+ (NSString*) helpSPY;


/**
 * Return the definition of the class
 */
- (NSString*) defn;
- (NSString*) defnC : (Class) cls;
- (NSString*) defn: (NSString*) className;


/**
 * Return the long description that recursively list all ivars. Use visitedInstance dictionary to avoid infinit loop 
 */
- (NSString*) longDescription;
- (NSString*) longDescription:(NSMutableSet*) visitedInstances indentation:(NSInteger) indentation;

/**
 Return the description of the ivars
 */
- (NSString*) ivarDescription:(NSMutableSet*) visitedInstances recursive:(BOOL) recursive indentation:(NSInteger) indentation;	

- (NSString*) spaces:(NSInteger) i;

- (NSString*) convertTypeS: (NSString*) t;

@end
